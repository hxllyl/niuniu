# encoding: utf-8

# author: depp.yu
class Standard < ActiveRecord::Base
  
  validates :name, presence: true
  
  has_many :base_cars, class_name: 'BaseCar' # 多种基础车辆数据
  has_many :brands, class_name: 'Brand' # 多种车辆品牌
end
