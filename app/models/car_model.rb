# encoding: utf-8

class CarModel < ActiveRecord::Base

  # constants
  STATUS = {
    1 => '激活',
    0 => '未激活'
  }

  # relations
  belongs_to :standard,  class_name: 'Standard' # 属于那种标准
  belongs_to :brand,     class_name: 'Brand'    # 属于品牌
  has_many   :base_cars, class_name: 'BaseCar'  # 拥有多种基础车辆
  has_many   :posts

  def to_hash
    {
      id:             id,
      resource_name:  'CarModel',
      name:           name,
      base_cars:      base_cars.map(&:to_hash)
    }
  end


  def self.with_brand(brand)
    where(brand_id: brand)
  end

end
