# encoding: utf-8

class Tender < ActiveRecord::Base

  before_create :get_price
  after_create  :gen_tender_log

  STATUS = {
    0  => '未成交',
    1  => '已成交',
    -1 => '已删除'
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
  
  delegate :car_license_areas, :color, :publish_time, :title, to: :post, prefix: true, allow_nil: true

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
end
