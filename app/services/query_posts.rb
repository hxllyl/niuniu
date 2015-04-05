module Services
  class QueryPost
    attr_reader :query, :brands, :car_models, :standards, :base_cars

    def initialize(opts = {})
      @query = String(opts[:q])
      @_type = 0 # 资源
    end

    def search_multi_tables
      @brands = Brand.where("name LIKE :name", name: "%#{@query}%")
      @standards = Standard.where('name LIKE :name', name: "%#{@query}%")
      @car_models = CarModel.where('name LIKE :name', name: "%#{ @query }%")
      # @base_cars = BaseCar.where("base_price LIKE :price OR style LIKE :style", price: /#{@query}/, style: "%#{@query}%")
      @base_cars = BaseCar.where(" style LIKE :style", style: "%#{@query}%")

    end

    def search

      search_multi_tables

#       sql =<<SQL_STRING
#         1=1 AND brand_id IN :brands OR standard_id IN :standards OR car_model_id IN :car_models OR base_car_id IN :base_cars OR
#                               outer_color LIKE :outer_color OR inner_color LIKE :inner_color
# SQL_STRING
#
#       valid_posts = Post.includes(:standard, :brand, :car_model, :base_car).where(sql,
#           brands: @brands.pluck(:id), standards: @standards.pluck(:id), car_models: @car_models.pluck(:id), base_cars: @base_cars.pluck(:id),
#                               outer_color: "%#{@query}%", inner_color: "%#{@query}%")

      s_ids = Post.resources.where(:standard_id => @brands).pluck(:id)
      b_ids = Post.resources.where(:brand_id => @brands).pluck(:id)
      car_ids = Post.resources.where(:car_model_id => @car_models).pluck(:id)
      base_ids = Post.resources.where(:base_car_id=> @base_cars).pluck(:id)
      post_ids = Post.resources.where("outer_color LIKE :outer_color OR inner_color LIKE :inner_color", outer_color: "%#{@query}%", inner_color: "%#{@query}%")
      Post.resources.where(:id => Array(s_ids + car_ids + base_ids + b_ids + post_ids))
    end
  end
end