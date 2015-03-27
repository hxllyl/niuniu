class SearchResource
  attr_reader :brand_id, :model_id

  def initialize(options = {})
    @brand_id = options[:brand_id]
    @model_id = options[:car_model_id]
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

  def standards
    Standard.where(id: brand.standard_ids)
  end

  def all_standards
    Standard.all
  end

  def all_brands
    Brand.all
  end

  def all_car_models
    CarModel.all
  end

end