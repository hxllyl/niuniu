# encoding: utf-8

# author: depp.yu

module PortalHelper
  
  def all_brand
    brands = Brand.all.collect{|b| [b.name, b.id] }
  end
  
  # 选择省市
  def areas(opt = {})
    case opt[:level]
    when :provinces then
      Area.provinces.collect { |p| [p.name, p.id] }
    else
      Area.cities.collect { |c| [c.name, c.id]}
    end
  end
  
  # post在首页的名称显示
  def post_name(post)
    "寻" post.standard.name
  end
  
end
