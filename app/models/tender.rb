# encoding: utf-8

class Tender < ActiveRecord::Base

  before_create :get_price
  after_create  :gen_tender_log

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

  # 未成交的报价
  scope :uncompleted, -> { where(status: 0) }
  # 已成交的报价
  scope :completed, -> { where(status: 1) }

  delegate :car_license_area, :color, :publish_time, :title, to: :post, prefix: true, allow_nil: true
  delegate :name, to: :user, prefix: true, allow_nil: true

  def get_price
    self.price =  case discount_way
                    when 1 then (post.base_car.base_price * discount_content).to_f
                    when 2 then (post.base_car.base_price - discount_content).to_f
                    when 3 then (post.base_car.base_price + discount_content).to_f
                    when 4 then discount_content.to_f
                  end
  end

  def gen_tender_log
    Log::Post.create(user_id: user_id, post_id: post_id, method_name: 'tender')
  end

  # 逻辑删除 物理删除用real_delete
  alias :real_delete :delete

  def delete
    self.update(status: STATUS.keys[2])
  end

  def to_hash
    {
      id:                 id,
      title:              post.title,
      area:               post.app_area,
      color:              post.color,
      owner:              post.owner,
      time:               post.publish_time,
      tender:             price.to_f,
      status:             status,
      base_price:         base_price.to_f,
      self_time:          publish_time,
      self_user_id:       user_id,
      self_user_name:     user.try(:name_area),
      level:              User::LEVELS[user.level],
      user_avatar:        post.user.avatar,
      user_introduction:  post.user.contact[:self_introduction],
      area:               post.car_in_area,
      price_status:       base_price,
      take_car_data:      Post::TAKE_DATES[post.take_car_date],
      mobile:             post.user_mobile
    }
  end

  def publish_time
    updated_at < Date.today ? updated_at.strftime("%m/%d") : updated_at.strftime("%H:%M")
  end

  def base_price
    "#{post.guiding_price}万/#{human_discount}"
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

end
