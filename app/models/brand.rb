# encoding: utf-8

class Brand < ActiveRecord::Base

  # constants
  STATUS = {
    0 => '激活',
    1 => '未激活'
  }

  # relations
  belongs_to :standard,  class_name: 'Standard' # 属于那种标准
  has_many   :base_cars, class_name: 'BaseCar' # 拥有多种基础车辆
  has_one    :car_photo, as: :owner, dependent: :nullify # 品牌图片

  # 初始化 object 状态
  after_initialize :init
  def init
    self.status ||= STATUS.keys[0]
  end

  def to_hash
    {
      id:             id,
      resource_name:  'Brand',
      name:           name,
      image:          car_photo.image.url,
      regions:        regions,
      base_cars:      base_cars.map(&:to_hash)
    }
  end

end
