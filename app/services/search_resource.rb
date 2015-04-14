# encoding: utf-8

class SearchResource
  attr_reader :brand_id, :model_id, :standard_id

  def initialize(options = {})
    @brand_id = options[:brand_id]
    @model_id = options[:car_model_id]
    @standard_id = options[:standard_id]
  end

  def brand
    if car_model.present?
      car_model.brand
    elsif brand_id.present?
      Brand.find brand_id
    else
      nil
    end
  end

  def car_model
    if model_id.present?
      CarModel.find(model_id)
    end
  end

  def standard
    if standard_id.present?
      Standard.find standard_id
    elsif car_model.present?
      car_model.standard
    else
      nil
    end
  end

  def standards
    Standard.where(id: brand.standard_ids) if brand.present?
  end

  def all_standards
    @all_stands ||= Standard.all
  end

  def all_brands
    @all_brands ||= Brand.all
  end

  def all_car_models
    @all_car_models ||= CarModel.all
  end

  def brands_ordered_by_pinyin
    @ordered_brands = all_brands.group_by { |e| Pinyin.t(e.name)[0].upcase }
  end

end