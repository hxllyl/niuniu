# encoding: utf-8

class Tender < ActiveRecord::Base

  before_create :get_price
  after_create  :gen_tender_log
  after_create  :update_need_time

  STATUS = {
    0  => '未成交',
    1  => '已成交',
    -1 => '已撤销'
  }

  DISCOUNT_WAYS ={
    1 => '优惠点数',
    2 => '优惠金额',
    3 => '加价金额',
    4 => '直接报价',
    5 => '电议'
  }

  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :post, class_name: 'Post'
  has_many :comments, as: :resources

  scope :valid, -> {where("status <> ?", STATUS.keys[2])}
  # 未成交的报价
  scope :uncompleted, -> { where(status: 0) }
  # 已成交的报价
  scope :completed, -> { where(status: 1) }

  delegate :car_license_area, :color, :publish_time, :title, to: :post, prefix: true, allow_nil: true
  delegate :name, :mobile, :level, to: :user, prefix: true, allow_nil: true

  def get_price
    self.price =  case discount_way
                    when 1 then (post.base_car.base_price.to_f * (100 - discount_content.to_f) / 100).round(2)
                    when 2 then (post.base_car.base_price.to_f - discount_content.to_f).round(2)
                    when 3 then (post.base_car.base_price.to_f + discount_content.to_f).round(2)
                    when 4 then discount_content.to_f
                  end
  end

  def gen_tender_log
    Log::Post.create(user_id: user_id, post_id: post_id, method_name: 'tender')
  end

  def update_need_time
    post.update_attributes(updated_at: Time.now)
  end

  # 逻辑删除 物理删除用real_delete
  alias :real_delete :delete

  def delete
    self.update(status: STATUS.keys[2])
  end

  def to_hash
    {
      post_id:                  post_id,
      post_title:               post.title,
      post_detail_title:        post.detail_title,
      post_user_id:             post.user_id,
      post_color:               post.color,
      post_user_name:           post.owner,
      post_user_mobile:         post.user_mobile,
      post_car_in_area:         post.car_in_area,
      post_car_license_area:    post.app_area,
      post_user_introduction:   post.user.contact['self_introduction'],
      post_user_avatar:         post.user.user_avatar,
      post_remark:              post.remark,
      post_publish_time:        post.created_at.strftime("%Y/%m/%d %H:%M"),
      post_expect_price:        post.expect_price.to_f,
      post_price_status:        post.base_price,
      post_tenders_count:       post.tenders.count,
      post_brand_img:           (post.brand.car_photo.image.try(:url) rescue ''),
      post_take_car_date:       Post::TAKE_DATES[post.take_car_date],
      post_base_car_price:      post.base_car_base_price.to_f,
      post_status:              post.status,

      tender_id:                id,
      tender_user_id:           user_id,
      tender_user_name:         user.name_area,
      tender_price:             price.to_f,
      tender_price_status:      base_price,
      tender_publish_time:      created_at.strftime("%Y/%m/%d %H:%M"),
      tender_remark:            remark,
      tender_user_mobile:       user_mobile,
      tender_user_level:        User::LEVELS[user_level],
      tender_discount_way:      discount_way,
      tender_discount_content:  discount_content,
      tender_status:            status
    }
  end

  def publish_time
    created_at < Date.today ? created_at.strftime("%m/%d") : created_at.strftime("%H:%M")
  end

  def base_price
    "#{post.guiding_price}万/#{human_discount}"
  end

  def is_completed?
    status == 1
  end

  # 优惠方式
  def human_discount
    case self.discount_way
    when DISCOUNT_WAYS.keys[0] then
      I18n.t('discount') << discount_content.to_s << I18n.t('point')
    when DISCOUNT_WAYS.keys[1] then
      I18n.t('discount') << discount_content.to_s << I18n.t('wan')
    when DISCOUNT_WAYS.keys[2] then
      I18n.t('add') << discount_content.to_s << I18n.t('wan')
    when DISCOUNT_WAYS.keys[3] then
      if price < post.guiding_price
        I18n.t('discount') << (post.guiding_price - price).to_s << I18n.t('wan')
      else
        I18n.t('add') << (price - post.guiding_price).to_s << I18n.t('wan')
      end
    else
      post.guiding_price.to_s << I18n.t('wan')
    end
  end

  after_create :make_create_message
  def make_create_message
    Message.make_system_message(generate_message(:create), post.user, Message::TYPES.keys[2])
  end


  after_update :make_message
  def make_message
    if status == STATUS.keys[1]
      Message.make_system_message(generate_message(:dealed), user, Message::TYPES.keys[3])
      # Message.make_system_message(generate_post_message, post.user, Message::TYPES.keys[4])
    end
  end


  private
  def generate_message(type)
    message = case type
              when :create then
                <<-EOF
                #{user_name} 给您寻的 #{post.info_for_jpush} 报价了。
                EOF
              when :dealed then
                <<-EOF
                #{post.user_name} 和您报价的寻 #{post.info_for_jpush} 成交了。
                EOF
              end
    message = message.strip          
  end

  # def generate_post_message
  #   message = <<-EOF
  #   #{user_name} 和您寻的 #{post.info_for_jpush} 成交了。
  #   EOF
  # end

end
