class ListResources

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
      Brand.first
    end
  end

  def car_model
    if model_id.present?
      CarModel.find(model_id)
    end
  end

  def car_models
    if brand.present?
      brand.car_models
    end
  end

  def styles
    if car_model.present?
      car_model.base_cars
    else
      brand.car_models.first.base_cars
    end
  end

  def standard
    if standard_id.present?
      Standard.find standard_id
    elsif car_model.present?
      car_model.standard
    else
      brand.standards.first
    end
  end

  def standards
    Standard.where(id: brand.standard_ids)
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