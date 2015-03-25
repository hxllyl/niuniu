# encoding: utf-8

class PhotosController < BaseController
  
  # 用户升级上传图片
  def level_uploads
    case params[:level]
    when User::LEVELS.keys[1] then
      identity = params[:identity]
      current_user.photos <<  
    else
      
    end
      
    
  end
end