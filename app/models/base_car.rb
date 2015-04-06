# encoding: utf-8

# author: depp.yu

class BaseCar < ActiveRecord::Base

  STATUS = {
    1 => '激活',
    0 => '未激活'
  }

  belongs_to :standard,   class_name: 'Standard' # 属于那种规格
  belongs_to :brand,      class_name: 'Brand' # 属于那种车辆品牌
  belongs_to :car_model,  class_name: 'CarModel' # 属于那种车型
  has_many   :car_photos, as: :owner, dependent: :nullify, autosave: true # 图片数据
  has_many   :posts, class_name: 'Post'

  delegate :name, to: :standard,  prefix: true
  delegate :name, to: :brand,     prefix: true
  delegate :name, to: :car_model, prefix: true

  scope :valid, -> { where(status: 1) }

  # instance_methods
  def to_human_name
    brand_name + car_model_name + self.NO
  end

  def to_hash
    {
      id:             id,
      resource_name:  'BaseCar',
      style:          style,
      number:         self.NO,
      outer_color:    outer_color,
      inner_color:    inner_color,
      base_price:     base_price.to_f,
      regions:        brand.regions
    }
  end

  def select_name
    base_price.to_f == 0.0 ? style : base_price.to_s << '万 ' << style
  end

  def valid?
    status == 1
  end

end
