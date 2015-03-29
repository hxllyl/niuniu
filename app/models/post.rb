# encoding: utf-8
class Post < ActiveRecord::Base
  
  before_create :get_some_must_attr

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

  DISCOUNT_WAYS ={
    1 => '优惠点数',
    2 => '优惠金额',
    3 => '加价金额',
    4 => '直接报价',
    5 => '电议' # 寻车没有 电议
  }

  # 资源类型
  RESOURCE_TYPE = {
    0 => '现车',
    1 => '期货'
  }

  TAKE_DATES = {
    1 => '当天',
    2 => '三天内',
    3 => '一周内',
    4 => '两周内',
    5 => '一月内',
    6 => '一个月以上'
  }

  # relations
  has_many    :tenders, class_name: 'Tender'
  belongs_to  :user,  ->{ includes(:area) },  class_name: 'User' # 消除 N+1 查询
  belongs_to  :brand,   class_name: 'Brand'
  belongs_to  :car_model, class_name: 'CarModel'
  belongs_to  :base_car, -> {includes(:brand, :car_model)}, class_name: 'BaseCar'
  belongs_to  :standard,class_name: 'Standard'
  has_many    :post_photos, as: :owner, dependent: :nullify, autosave: true # 资源图片
  has_many    :respondents, class_name: 'Complaint', as: :resource # 被投诉列表
  has_many    :comments, -> {order('updated_at desc')}, as: :resource

  USER_METHODS = [:name, :mobile, :level, :company, :area, :area_name, :level_icon ]

  delegate :name, to: :standard, prefix: true
  delegate :name, to: :brand, prefix: true
  delegate *USER_METHODS, to: :user, prefix: true, allow_nil: true
  delegate :NO, :to_human_name, :base_price, to: :base_car, prefix: true
  delegate :name, to: :car_model, prefix: true, allow_nil: true
  #delegate :to_human_name, to: :base_car, prefix: true, allow_nil: true

  # class methods
  # 资源
  scope :resources, -> { where(_type: 0) }
  # 寻车
  scope :needs,     -> { where(_type: 1) }
  # 已成交
  scope :completed, -> { where(status: 3) }
  # 未成交
  scope :uncompleted, -> { where("status <> 3") }

  scope :with_brand, ->(brand) { where(brand_id: brand) }

  scope :with_standard, ->(std) { where(standard_id: std) }

  acts_as_list scope: :user
  
  # instance methods
  def get_some_must_attr
    self.expect_price = case discount_way
                          when 1 then base_car.base_price.to_f * discount_content
                          when 2 then base_car.base_price.to_f - discount_content
                          when 3 then base_car.base_price.to_f + discount_content
                          when 4 then discount_content.to_f
                        end

    # 只有资源才有的条件，因为数据库设计不能为空，所以给寻车一个-1的值来区分
    self.resource_type = -1 if _type == 1
    # 寻车的报价方式可以为空，当用户不选时，我们给其一个默认值
    self.discount_way  = 5 unless discount_way
    self.car_license_areas = '' if _type == 0
  end

  # alias method names
  # 别名
  alias_method  :guiding_price, :base_car_base_price

  def complete(tender_id)
    tender = self.tenders.find_by_id(tender_id)
    if tender
      self.update_attributes(status: 3)
      tender.update_attributes(status: 1)
    end
    Log::Post.create(user_id: user_id, post_id: id, method_name: 'post_completed')
    tender_log = Log::Post.find_or_initialize_by(user_id: tender.user_id, post_id: id, method_name: 'tender')
    tender_log.method_name = 'tender_completed'
    tender_log.save
  end

  # {front: 'image_url', side: 'image_url', obverse: 'image_url', inner: 'image_url'}
  def photos
    hash = {}
    post_photos.each do |ele|
      hash[ele._type.to_sym] = ele.image.url
    end

    hash
  end

  def to_hash
    {
      id:                 id,
      user_id:            user_id,
      user_name:          user_name,
      user_mobile:        user_mobile,
      user_company:       user_company,
      user_level:         User::LEVELS[user_level],
      brand:              brand_name,
      model:              car_model.name,
      style:              base_car.style,
      outer_color:        outer_color,
      inner_color:        inner_color,
      car_license_areas:  car_license_areas,
      car_in_areas:       car_in_areas,
      take_car_date:      take_car_date,
      expect_price:       expect_price.to_f,
      discount_way:       DISCOUNT_WAYS[discount_way],
      discount_content:   discount_content.to_f,
      photos:             photos,
      short_name:         base_car_NO,
      updated_at:         updated_at,
      brand_image:        brand.car_photo.image.url,
      base_path:          url,
      tenders_count:      tenders.count
    }
  end

  def color
    "#{outer_color}/#{inner_color}"
  end

  def standard_type
    standard_name << '/' << RESOURCE_TYPE[resource_type]
  end

  def owner
    "#{user_name}(#{user_area_name})"
  end

  def owner_detail
    "#{user_name}(#{user_area_name})#{publish_time}"
  end

  def publish_time
    updated_at < Date.today ? updated_at.strftime("%m/%d %H:%M") : updated_at.strftime("%H:%M")
  end

  def title
    "#{_type == 0 ? '卖 ' : '寻 '}" << standard_name << brand_name << base_car_NO
  end

  def portal_resource_title
    brand_name << car_model_name << base_car_NO
  end

  def brand_model_name
    brand_name << " " << car_model_name.delete(brand_name)
  end

  def standard_resource_type
    standard_name << RESOURCE_TYPE[resource_type]
  end

  # 优惠方式
  def human_discount
    case self.discount_way
    when DISCOUNT_WAYS.keys[0] then
      I18n.t('discount') << discount_content.to_s << I18n.t('point')
    when DISCOUNT_WAYS.keys[1] then
      I18n.t('discount') << discount_content.to_s << I18n.t('wan')
    when DISCOUNT_WAYS.keys[2] then
      I18n.t('add') << discount_content.to_s << I18n.t('wan')
    when DISCOUNT_WAYS.keys[3] then
      if expect_price < guiding_price
        I18n.t('discount') << (guiding_price - expect_price).to_s << I18n.t('wan')
      else
        I18n.t('add') << (expect_price - guiding_price).to_s << I18n.t('wan')
      end
    else
      guiding_price.to_s << I18n.t('wan')
    end
  end

  def is_completed?
    status == 3
  end
  
  # 逻辑删除 物理删除用real_delete
  alias :real_delete :delete
  
  def delete
    self.update(status: STATUS.keys[4])
  end

  def url
    "#{APP_CONFIG['host']}/posts/#{id}?_type=#{_type}"
  end

  def app_area
    "#{_type == 0 ? '卖 ' : '寻 '}" + car_license_areas
  end

end
