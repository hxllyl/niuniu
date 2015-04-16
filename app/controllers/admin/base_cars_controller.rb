# encoding: utf-8
class Admin::BaseCarsController < Admin::BaseController

  def index
    @base_cars = BaseCar.includes(:standard, :brand, :car_model).order(updated_at: :desc).page(params[:page]||1).per(30)
  end

  def st_list
    @sts = Standard.includes(:brands).page(params[:page]||1).per(30)
  end

  def br_list
    @brs = Brand.includes(:standards).order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def cm_list
    @cms = CarModel.includes(:standard, :brand).order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def show
    @base_car = BaseCar.find_by_id(params[:id])
  end
end
