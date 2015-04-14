# encoding: utf-8

# author: depp.yu
require 'digest'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # constants
  # 为什么不用staff这个模型？
  ROLES = %w(normal staff admin super_admin) # 普通用户 业务员 普管 超管

  # 注册状态：来自网站 ios android 后台
  REG_STATUS = {
    0 => 'web',
    1 => 'ios',
    2 => 'android',
    3 => 'background'
  }
  AVATAR = 'index/user_photo.jpg'

  STATUS = {
    0  => 'unapproved',
    1  => 'approved',
    -1 => 'deleted'
  }

  LEVELS = {
    0 => '个人手机认证', # 注册时默认等级
    1 => '个人身份认证', # 上传了身份证照片
    2 => '认证资源', # 上传了营业执照
    3 => '认证综展', # 上传了营业执照和展厅内部和门头照 个人名片
    4 => '4S' # 展厅门头照片、展厅内部照片和个人名片
  }

  # validates
  validates :name, presence: true, length: { maximum: 30 }
  validates :mobile, presence: true, uniqueness: true # format: { with:  /\A1[3|4|5|8][0-9]{9}\z/ }
  validates :role,  presence: true , inclusion: { in: ->(clazz){ clazz.class::ROLES} }
  validates :company, presence: true, length: { maximum: 100 }
  validates :level, numericality: true, inclusion: { in: 0..4 }

  # tables relation
  has_many :photos, as: :owner, dependent: :nullify, autosave: true # 与图片类关联起来 处理用户图片
  has_many :posts, ->{where("posts.status != #{Post::STATUS.keys[4]}").order('posts.position DESC')}, class_name: 'Post' # 需求和寻车
  has_many :tenders, ->{where("tenders.status != #{Tender::STATUS.keys[2]}")}, class_name: 'Tender' # 报价
  has_many :comments, class_name: 'Comment'
  has_many :tokens, class_name: 'Token', dependent: :nullify # 用于api验证
  has_many :follower_ships, foreign_key: :following_id, class_name: 'FollowShip' # 关注关系
  has_many :followers, through: :follower_ships, source: :follower
  has_many :following_ships, foreign_key: :follower_id, class_name: 'FollowShip' # 关注关系
  has_many :followings, through: :following_ships, source: :following
  has_many :notifications, class_name: 'Notification'
  has_many :respondents, class_name: 'Complaint', as: :resource # 被投诉列表
  has_many :complaints, class_name: 'Complaint'
  has_many :operations, class_name: 'Complaint', foreign_key: :operator_id # 投诉操作列表
  # 用户专属于客服

  belongs_to :customer_service, class_name: 'Staff'

  has_many :send_feedbacks, ->{ where("messages._type = ?", Message::TYPES.keys[1])}, class_name: 'Feedback', foreign_key: 'sender_id'
  has_many :received_feedbacks, ->{ where("messages._type = ?", Message::TYPES.keys[1]) }, class_name: 'Feedback', foreign_key: 'receiver_id'

  has_many :user_messages, class_name: 'UserMessage', dependent: :delete # 这个是系统消息与用户的关联表 个人系统消息删除只能删除这个关系
  has_many :system_messages, through: :user_messages, source: :message #区别需求消息（报价，寻车）  用system_message这个名称 这个是message实体表 删除操作 不能删这个

  belongs_to :area, class_name: 'Area'

  has_many :log_posts, class_name: 'Log::Post'

  # 用户升级认证log
  has_many :log_user_update_levels, class_name: 'Log::UserUpdateLevel'

  has_many :active_devices, class_name: 'ActiveDevice' # jpush 用户设备
  has_many :valid_codes, class_name: 'ValidCode', dependent: :nullify

  scope :valid_user, -> {where("status != #{STATUS.keys[2]}")}
  scope :normals, -> {where("users.role = ?", 'normal')}

  accepts_nested_attributes_for :photos

  # class methods

  # instance methods
  delegate :name, to: :area, prefix: true, allow_nil: true

  self.inheritance_column = :mask

  # 定义用户的各种类型图片
  %w(avatar identity hand_id visiting room_outer room_inner license).each do |m|
    unless User.respond_to?(m.to_sym)
      User.class_eval do
        case m
        when 'avatar' then
          define_method m.to_sym do
            (self.photos.where(_type: m).first.image_path(:medium) rescue nil) || AVATAR
          end
        else
          define_method m.to_sym do
            self.photos.where(_type: m).first.image_path rescue nil
          end
        end
      end
    end
  end

  # devise 不用email
  def email_required?
    false
  end

  # 判断是不是admin
  def is_admin?
    self.role == 'admin'
  end

  # 我的资源和寻车
  def resources(type)
    type == :source ? ::Post::TYPES.keys[0] : ::Post::TYPES.keys[1]
    self.posts.where(_type: type)
  end

  # 我的等级
  def i_level
    ::User::LEVELS[self.level]
  end

  # callback define codes bottom
  after_create :gen_token # 在用户完成注册时生成一个token
  def gen_token
    salt  = "#{self.mobile}--#{self.password}"
    token = self.tokens.build(value: Digest::SHA1.hexdigest(salt))
    token.save
  end

  # token 用于api验证 目前使用第一个
  def token
    self.tokens.first
  end

  def skip_confirmation!
    self.current_sign_in_at = Time.now
  end

  def posts_with_type(type)
    posts.where(_type: type)
  end

  # 用户等级logo
  def level_icon
    case self.level
      when LEVELS.keys[0] then
        ''
      when LEVELS.keys[1] then
        'user/typeIcon_p.png'
      when LEVELS.keys[2] then
        'user/typeIcon_s.png'
      when LEVELS.keys[3] then
        'user/typeIcon_z.png'
      else
        'user/typeIcon_4s.png'
    end
  end

  def is_show_icon?
    level != LEVELS.keys[0]
  end

  # 用户成交量(包括寻车和报价成交总是)
  def dealeds(type)
    conditions = "user_id = #{self.id}"
    conditions << " updated_at >= #{Time.now - 3.months}" if type == :month
    Post.completed.where(conditions).count + Tender.completed.where(conditions).count
  end

  def can_upgrade
    #level != LEVELS.keys[3] and level != LEVELS.keys[4]
    level_update_status
  end

  def can_upgrade_levels
    if level == LEVELS.keys[0]
      [1,4]
    elsif level == LEVELS.keys[1]
      [2,3,4]
    elsif level == LEVELS.keys[2]
      [3]
    else
      []
    end
  end

  def had_updated_levels
    levels = log_user_update_levels.where(status: Log::UserUpdateLevel::STATUS.keys[1]).order('end_level asc').pluck(:end_level)
  end

  def following?(user)
    followings.include?(user)
  end

  def to_hash
    {
      id:               id,
      name:             name,
      company:          company,
      mobile:           mobile,
      _type:            _type,
      level:            LEVELS[level],
      area:             area_name,
      avatar:           avatar,
      contact:          contact,
      post_count:       posts.needs.count,
      tender_count:     tenders.count,
      following_count:  followings.count,
      area_id:          area_id,
      dealt_infos:      dealt_infos,
      status:           status,
      role:             role
    }
  end

  def last_month_dealt
    "最近三个月成交#{log_posts.completeds.last_months(3).count}"
  end

  def sum_dealt
    "累积成交#{log_posts.completeds.count}"
  end

  def dealt_infos
    [last_month_dealt, sum_dealt].join(',')
  end

  def name_area
    name + "(" + area_name.to_s + ")"
  end

  def brands_ary
    posts.resources.map(&:brand_name).uniq.join(' ')
  end

  def heading_show
    %w(2 3 4).include?(level) ? company : name
  end

  def level_update_status
    log = log_user_update_levels.where(status: Log::UserUpdateLevel::STATUS.keys[0]).order('updated_at desc').first

    if log.blank?
      [true,  nil]
    else
      [false, log.end_level]
    end
  end

  def  unread_tenders
    Log::Post.not_read.tender_to_posts(posts.needs.pluck(:id))
  end

  def unread_hunts #
    Log::Post.not_read.hunt_completed(self.id)
  end

  def has_unread_tenders? # 判断有否未读之报价
    unread_tenders.count > 0
  end

  def has_unread_hunts? # 判断有否未读之寻车（我对寻车所作之报价已完成）
    unread_hunts.count > 0
  end

  def has_unread_sys_message?
    self.user_messages.unread.count > 0
  end

  def user_avatar
    avatar.class == String ? avatar : avatar.image.try(:url)
  end

  def tendered?(post_id)
    Tender.find_by_user_id_and_post_id(id, post_id) ? true : false
  end

  # 是否可以刷新资源列表
  def could_update_my_resources?
    !log_posts.update_resources.last || log_posts.update_resources.last.created_at < 1.hours.ago
  end

  # 生成POST日志
  def gen_post_log(post, method_name)
    if method_name == 'update_all'
      log = log_posts.find_or_initialize_by(method_name: 'update_all')
      if log.new_record?
        log.post_id = post.id
        log.save
      else
        log.update_attributes(updated_at: Time.now)
      end
    elsif method_name == 'view'
      log = log_posts.find_or_initialize_by(method_name: 'view', post_id: post.id)
      log.new_record? ? log.save : log.update_attributes(updated_at: Time.now)
    else
      log_posts.create(method_name: method_name, post_id: post.id)
    end
  end

  # 最近浏览的
  def later_view_posts(_type = 0)
    Post.includes(:standard, :brand, :car_model, :base_car).where("id in (?) and _type=? and status=1", log_posts.views.order(updated_at: :desc).limit(5).map(&:post_id), _type)
  end

  # after_create :genrate_register_log
  # def genrate_register_log
  #   log = Log::ContactPhone.where(mobile: self.mobile).first_or_initialize
  #   log.is_register = true
  #   log.save
  # end

end
