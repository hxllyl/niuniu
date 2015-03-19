# encoding: utf-8
class Post < ActiveRecord::Base

  # constants
  TYPES = {
    1 => '资源',
    2 => '寻车'
  }

  STATUS = {
    0 => '未审核',
    1 => '已审核', # 默认状态
    2 => '已过期',
    3 => '已成交', # 仅限寻车
    4 => '已删除'
  }

  # relations
  belongs_to :user, class_name: 'User'
  has_many :tenders, -> {where(_type: TYPES[2])}, class_name: 'Tender'
  belongs_to :brand, class_name: 'Brand'

  # class methods
  scope :resources, -> {where(_type: 0)}
  scope :needs,     -> {where(_type: 1)}


  # instance methods
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
