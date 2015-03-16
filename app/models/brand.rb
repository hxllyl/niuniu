# encoding: utf-8

class Brand < ActiveRecord::Base

  belongs_to :standard, class_name: 'Standard' # 属于那种标准
  has_many :base_cars, class_name: 'BaseCar' # 拥有多种基础车辆
end
