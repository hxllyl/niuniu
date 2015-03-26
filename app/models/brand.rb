# encoding: utf-8

class Brand < ActiveRecord::Base

  # constants
  STATUS = {
     1 => '激活',
     0 => '未激活'
  }
  
  validates :name, presence: true, uniqueness: true

  # relations
  belongs_to :standards, class_name: 'Standard' # 属于那种标准
  has_many   :car_models, class_name: 'CarModel' # 拥有多种车型
  has_many   :base_cars,  class_name: 'BaseCar'  # 拥有多种车款
  has_one    :car_photo, as: :owner, dependent: :nullify # 品牌图片
  has_many   :posts

  def to_hash
    {
      id:             id,
      resource_name:  'Brand',
      name:           name,
      image:          car_photo.image.url,
      regions:        regions,
      car_models:     car_models.map(&:to_hash)
    }
  end

end
