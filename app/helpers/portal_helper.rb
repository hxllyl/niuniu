# encoding: utf-8

# author: depp.yu

module PortalHelper

  def all_brand
    Brand.pluck(:name, :id)
  end

  # 选择省市
  def areas(opt = {})
    case opt[:level]
      when :provinces then
        Area.pluck(:name, :id)
      else
        Area.cities.pluck(:name, :id)
    end

  end

  # post在首页的名称显示
  def post_name(post)
    t('find') << post.base_car.to_human_name << ' ' << t('sale') << post.car_license_areas
  end

end
