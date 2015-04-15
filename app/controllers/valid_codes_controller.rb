# encoding: utf-8
class ValidCodesController < BaseController

  skip_before_action :authenticate_user!, only: [:create, :_valid]
  
  before_action :is_registered, only: [:create]
  # 生成valid_code
  # params:
  #   mobile
  # return:
  #   format.json
  def create
    
    @valid_code = ValidCode.where(mobile: params[:mobile].strip, _type: params[:type].to_i).last
    
    if @valid_code and @valid_code.is_valid?
      @valid_code.send_code
      render json: { status: 'success', code: @valid_code.code }
    else
      if @valid_code.blank? or @valid_code._type == ValidCode::TYPES.keys[1]
        
        @valid_code = ValidCode.new(mobile: params[:mobile].strip, _type: params[:type].to_i)
      
        if @valid_code.save
          @valid_code.send_code
          render json: { status: 'success', code: @valid_code.code }
        else
          render json: { status: 'failed', error_msg: "请输入正确的手机号码！" }
        end
      else
        render json: { status: 'failed', error_msg: "号码：#{@valid_code.mobile},已经被注册"}
      end  
    end
  end

  # 验证该手机号码和验证码是否有效
  # params:
  #   mobile
  #   valid_code
  # return:
  #   success
  #   failed
  def _valid
    valid_code = ValidCode.where(mobile: params[:mobile], code: params[:valid_code]).first

    respond_to do |format|
      format.json {
        if valid_code and valid_code.is_valid?
          render json: { status: 'success' }
        else
          render json: { status: 'failed' }
        end
      }
    end

  end
  
  private
  def is_registered
    if params[:type].to_i == ValidCode::TYPES.keys[1]
      u = User.find_by(mobile: params[:mobile])
      render json: { status: 'failed', error_msg: "该号码还未注册，请先注册"} and return if u.blank?
    end
  end 
  
end
