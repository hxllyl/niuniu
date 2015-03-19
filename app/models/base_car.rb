# encoding: utf-8

# author: depp.yu

class BaseCar < ActiveRecord::Base
  
  STATUS = {
    0 => '激活',
    1 => '未激活'
  }
  
  belongs_to :standard, class_name: 'Standard' # 属于那种规格
  belongs_to :brand, class_name: 'Brand' # 属于那种车辆品牌
  
  
end
