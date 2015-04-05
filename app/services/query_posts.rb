module Services
  class QueryPost
    attr_reader :query, :brands, :car_models, :standards, :base_cars

    def initialize(opts = {})
      @query = String(opts[:q])
      @_type = opts[:_type] || 0 # 默认搜索资源
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

      posts = Post.arel_table
      std = posts[:standard_id].in( @standards.pluck(:id) )
      brd = posts[:brand_id].in( @brands.pluck(:id) )
      car = posts[:car_model_id].in( @car_models.pluck(:id) )
      base = posts[:base_car_id].in( @brands.pluck(:id) )
      cus_post = posts[:outer_color].matches( "%#{@query}%" ).or( posts[:inner_color].matches( "%#{@query}%" ) )

      Post.as_resource(@_type).where(std.or(brd).or(car).or(base).or(cus_post))
    end
  end
end