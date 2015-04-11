# encoding: utf-8

# author: depp.yu

class AreasController < BaseController
  
  skip_before_action :authenticate_user!, only: [:show]
  
  def show
    @area = Area.find params[:id]
    @cities = @area.children.collect { |c| [c.name, c.id] } 
    
    respond_to do |format|
      format.json {
        render json: { status: 'success', datas: @cities }
      }
    end
  rescue Exception => exception
    render json: { status: 'failed', error_msg: exception.message }   
  end
  
end