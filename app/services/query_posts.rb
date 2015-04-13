# require 'pry'
module Services
  class QueryPost
    attr_reader :query, :brands, :car_models, :standards, :base_cars
    PER = 10

    def initialize(opts = {})
      @query = String(opts[:q])
      @_type = opts[:_type] || 0 # 默认搜索资源
      @car_model_id = opts[:cid]
      @style = opts[:style]
      @icol = opts[:icol]
      @ocol = opts[:ocol]
      @status = opts[:status]
    end

    def search_multi_tables
      @brands = Brand.where(' name ILIKE :name', name: "%#{@query}%")
      @standards = Standard.where(' name ILIKE :name', name: "%#{@query}%")
      @car_models = CarModel.where(' name ILIKE :name', name: "%#{ @query }%")
      # @base_cars = BaseCar.where("base_price LIKE :price OR style LIKE :style", price: /#{@query}/, style: "%#{@query}%")
      @base_cars = BaseCar.where(" style ILIKE :style OR \"base_cars\".\"NO\" ILIKE :num OR base_price::TEXT  ILIKE :guiding_price", style: "%#{@query}%", num: "%#{@query}%", guiding_price: "%#{@query}%")
    end

    def search

      search_multi_tables

      posts = Post.arel_table
      std = posts[:standard_id].in( @standards.pluck(:id) )
      brd = posts[:brand_id].in( @brands.pluck(:id) )
      car = posts[:car_model_id].in( @car_models.pluck(:id) )
      base = posts[:base_car_id].in( @brands.pluck(:id) )
      cus_post = posts[:outer_color].matches( "%#{@query}%" ).or( posts[:inner_color].matches( "%#{@query}%" ) )

      Post.as_resource(@_type).valid.where(std.or(brd).or(car).or(base).or(cus_post))
    end

    def by_style_and_status_color
      res = Post.resources.valid.where(:base_car_id => @style, :car_model_id => @car_model_id)
      res = res.where(outer_color: @ocol) if @ocol
      res = res.where(inner_color: @icol) if @icol
      res = res.where(status: @status) if @status
      res
    end

    def search_and_order_with_users(user_ids, _page, sort_by = 'updated_at' )

      order_ways = { 'updated_at' => :desc, 'expect_price' =>  :asc }

      results = search
      page = _page || 1
      user_ids = Array( user_ids )

      return results.order(order_ways.slice(sort_by)).page(page).per(PER) if (results.blank? || user_ids.blank?)

      hash = { true => 0, false => 1 }

      values = ''
      results.each_with_index do |post, idx|
        values += ', ' if idx > 0
        values += %(( #{post.id}, #{ hash[user_ids.include?(post.user_id)] } ))
      end

      Post.resources.joins("join (VALUES #{values}) as x(id, ordering)  on posts.id = x.id ").\
          order("x.ordering", order_ways.slice(sort_by)).page(page).per(10)

    end
  end
end
