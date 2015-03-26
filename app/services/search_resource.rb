class SearchResource
  attr_reader :brand_id, :model_id

  def initialize(options = {})
    @brand_id = options[:brand_id]
    @model_id = options[:model_id]
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

end