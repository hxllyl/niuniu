# encoding: utf-8

# author: depp.yu
require 'digest'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # constants
  ROLES = %w(normal admin)
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
  validates :mobile, presence: true, format: { with:  /\A1[3|4|5|8][0-9]{9}\z/ }, uniqueness: true
  validates :role,  presence: true , inclusion: { in: %w(normal admin) }
  validates :company, presence: true, length: { maximum: 100 }
  validates :level, numericality: true, inclusion: { in: 0..3 }

  # tables relation
  has_many :photos, as: :owner, dependent: :nullify, autosave: true # 与图片类关联起来 处理用户图片
  has_many :posts, class_name: 'Post' # 需求和寻车
  has_many :tenders, class_name: 'Tender' # 报价
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

  belongs_to :area, class_name: 'Area'

  scope :valid_user, -> {where("status != #{STATUS[-1]}")}

  # class methods

  # instance methods
  delegate :name, to: :area, prefix: true, allow_nil: true

  # 定义用户的各种类型图片
  %w(avatar identity hand_id visiting room_outer room_inner license).each do |m|
    unless User.respond_to?(m.to_sym)
      User.class_eval do
        case m
        when 'avatar' then
          define_method m.to_sym do
            self.photos.where(_type: m).first || AVATAR
          end
        else
          define_method m.to_sym do
            self.photos.where(_type: m)
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
      when (LEVELS.keys[0] or LEVELS.keys[1]) then
        'user/typeIcon_p.png'
      when LEVELS.keys[2] then
        'user/typeIcon_s.png'
      when LEVELS.keys[3] then
        'user/typeIcon_z.png'
      else
        'user/typeIcon_4s.png'
    end
  end
  
  # 用户成交量(包括寻车和报价成交总是)
  def dealeds(type)
    conditions = "user_id = #{self.id}"
    conditions << " updated_at >= #{Time.now - 3.months}" if type == :month
    Post.completed.where(conditions).count + Tender.completed.where(conditions).count
  end

  def following?(user)
    followings.include?(user)
  end

end
