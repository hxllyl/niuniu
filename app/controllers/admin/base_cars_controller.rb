# encoding: utf-8
class Admin::BaseCarsController < Admin::BaseController

  def index
    @base_cars = BaseCar.includes(:standard, :brand, :car_model).order(updated_at: :desc).page(params[:page]||1).per(30)
  end

  def new
    @base_car, @url = BaseCar.new, admin_base_cars_path
    @standards, @brands, @car_models = Standard.all, [], []
    @standard, @brand, @car_model = *nil
  end

  def create
    params.require(:base_car).permit!
    @base_car = BaseCar.new(params[:base_car])

    if @base_car.save
      redirect_to admin_base_cars_path
    else
      render action: new, flash: @base_car.errors
    end
  end

  def edit
    @base_car, @url = BaseCar.find_by_id(params[:id]), admin_base_car_path
    @standard, @brand, @car_model = @base_car.standard, @base_car.brand, @base_car.car_model
    @standards, @brands, @car_models = Standard.all, @standard.brands, CarModel.valid.where(standard_id: @standard.id, brand_id: @brand.id)
  end

  def update
    if params[:id] == 'update_cm'
      @cm = CarModel.find_by_id(params[:car_model][:id])
      params[:car_model].delete(:id)
      params.require(:car_model).permit!
      @cm.update_attributes(params[:car_model])

      redirect_to cm_list_admin_base_cars_path
    else
      @base_car = BaseCar.find_by_id(params[:id])
      params.require(:base_car).permit!
      @base_car.update_attributes(params[:base_car])

      redirect_to admin_base_cars_path
    end
  end

  def get_select_infos
    @base_car = BaseCar.find_by_id(params[:base_car][:id])

    if @base_car
      @url = admin_base_car_path(@base_car)
    else
      @base_car, @url = BaseCar.new, admin_base_cars_path
    end

    @standard   = Standard.find_by_id(params[:base_car][:standard_id])
    @brand      = Brand.find_by_id(params[:base_car][:brand_id])
    @car_model  = CarModel.find_by_id(params[:base_car][:car_model_id])

    @standards  = Standard.all
    @brands     = @standard.brands.valid
    @car_models = @brand ? CarModel.where(standard_id: @standard.id, brand_id: @brand.id, status: 1) : []

    render partial: 'form'
  end

  def st_list
    @sts = Standard.includes(:brands).page(params[:page]||1).per(30)
  end

  def new_st
  end

  def create_st
  end

  def edit_st
  end

  def update_st
  end

  def br_list
    @brs = Brand.includes(:standards).order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def new_br
  end

  def create_br
  end

  def edit_br
  end

  def update_br
  end

  def cm_list
    @cms = CarModel.includes(:standard, :brand).order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def new_cm
    @cm, @url = CarModel.new, create_cm_admin_base_cars_path
    @standards, @brands = Standard.all, []
    @standard, @brand = *nil
  end

  def create_cm
    params.require(:car_model).permit!
    @cm = CarModel.new(params[:car_model])

    if @cm.save
      redirect_to cm_list_admin_base_cars_path
    else
      render action: new_cm, flash: @cm.errors
    end
  end

  def edit_cm
    @cm, @url = CarModel.find_by_id(params[:car_model_id]), update_cm_admin_base_cars_path
    @standard, @brand = @cm.standard, @cm.brand
    @standards, @brands = Standard.all, @standard.brands
  end

  def get_cm_select_infos
    if params[:car_model][:id].nil?
      @cm, @url = CarModel.new, create_cm_admin_base_cars_path
    else
      @cm, @url = CarModel.find_by_id(params[:car_model][:id]), update_cm_admin_base_cars_path(car_model_id: params[:car_model][:id])
    end

    @standard   = Standard.find_by_id(params[:car_model][:standard_id])
    @brand      = Brand.find_by_id(params[:car_model][:brand_id])

    @standards  = Standard.all
    @brands     = @standard.brands.valid

    render partial: 'cm_form'
  end
end
