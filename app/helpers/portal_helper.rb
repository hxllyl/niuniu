# encoding: utf-8

# author: depp.yu

module PortalHelper

  def all_brand
    # Brand.pluck(:name, :id)
    ary = []
    Brand.valid.group_by {|e| Pinyin.t(e.name)[0].upcase}.keys.sort.each do |letter|
      Brand.valid.group_by {|e| Pinyin.t(e.name)[0].upcase}[letter].each do |ele|
        ary << [letter + ele.name, ele.id]
      end
    end
    ary
  end

  # 选择省市
  def areas(opt = {})
    opt[:level] ||= 'provinces' # provinces, cities
    Area.send(opt[:level]).pluck(:name, :id)
  end

  def options_cities(province_id)
    Area.where(parent_id: province_id).collect {|c| [c.name, c.id]}
  end

  # post在首页的名称显示
  def post_name(post)
    t('find') << (post.base_car_to_human_name || ' ') << ' ' << t('sale') << post.car_license_areas
  end

end
