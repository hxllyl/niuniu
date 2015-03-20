# encoding: utf-8
class Post < ActiveRecord::Base

  before_create :get_expect_price

  # constants
  TYPES = {
    0 => '资源',
    1 => '寻车'
  }

  STATUS = {
    0  => '未审核',
    1  => '已审核', # 默认状态
    2  => '已过期',
    3  => '已成交', # 仅限寻车
    -1 => '已删除'
  }

  DISCOUT_WAYS ={
    1 => '优惠点数',
    2 => '优惠金额',
    3 => '加价金额',
    4 => '直接报价',
    5 => '电议'
  }

  # relations
  has_many    :tenders, class_name: 'Tender'
  belongs_to  :user,    class_name: 'User'
  belongs_to  :brand,   class_name: 'Brand'
  belongs_to  :base_car,class_name: 'BaseCar'
  belongs_to  :standard,class_name: 'Standard'
  has_many    :post_photos, as: :owner, dependent: :nullify, autosave: true # 资源图片
  
  # class methods
  # 资源
  scope :resources, -> { where(_type: 0) }
  # 寻车
  scope :needs,     -> { where(_type: 1) }
  # 已成交
  scope :completed, -> { where(status: 3) }


  # instance methods
  def get_expect_price
    self.expect_price = case discount_way
                          when 1 then (base_car.base_price * discount_content).to_f
                          when 2 then (base_car.base_price - discount_content).to_f
                          when 3 then (base_car.base_price + discount_content).to_f
                          when 4 then discount_content.to_f
                        end
  end

  def complete(tender_id)
    tender = self.tenders.find_by_id(tender_id)
    if tender
      self.update_attributes(status: 3)
      tender.update_attributes(status: 1)
    end
  end

  def to_0_hash
    {
      id: id,
      user_id: user_id,
      brand:   brand.name
    }
  end

  def to_1_hash
    {
      id: id,
      user_id: user_id
    }
  end
  
end
