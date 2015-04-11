# encoding: utf-8

# author: depp.yu
class Standard < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :base_cars, class_name: 'BaseCar' # 多种基础车辆数据
  has_and_belongs_to_many :brands, class_name: 'Brand' # 多种车辆品牌
  has_many :car_models, class_name: 'CarModel' # 多种车型

  def to_hash
    {
      id:             id,
      resource_name:  'Standard',
      name:           name,
      # brands:         brands.map(&:to_hash)
    }
  end

end
