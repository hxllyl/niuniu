# encoding: utf-8

class PhotosController < BaseController
  
  # 用户升级上传图片
  def level_uploads      
    
    args_hash = params[:_img]
    file, type, level = args_hash['image'], args_hash['type'], args_hash['level'] 
    raise '用户已经升级过了' if current_user.level >= level.to_i
    
    current_user.level = level if level.present?
    
    photo = Photo.new(image: File.open(file, 'r'), _type: type)
    current_user.photos << photo
    current_user.save
    current_user.reload
    
    respond_to do |format|
      format.html {}
      format.json { render json: { status: 'success',  file: current_user.avatar }}
    end
    
  end
end