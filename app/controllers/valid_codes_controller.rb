# encoding: utf-8

class ValidCodesController < BaseController
  
  skip_before_action :authenticate_user!, only: [:create, :_valid]
  
  # 生成valid_code
  # params:
  #   mobile
  # return:
  #   format.json 
  def create
    @valid_code = ValidCode.where(mobile: params[:mobile], _type: params[:type]).first
    if @valid_code and @valid_code.is_valid?
      render json: { status: 'success', code: @valid_code.code } 
    else
      @valid_code = ValidCode.new(mobile: params[:mobile], _type: params[:type])
      
      if @valid_code.save
        render json: { status: 'success', code: @valid_code.code }
      else
        render json: { status: 'failed', error_msg: @valid_code.errors.full_messages.join('\n') }
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
end