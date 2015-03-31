# encoding: utf-8

class PhotosController < BaseController
  
  # 用户升级上传图片
  def upload      
    raise '请上传图片' if params[:file].blank?
    
    file_tmp = params[:file]
    
    tmp_dir = File.join(Rails.root, 'public', 'uploads', 'tmp')
    
    tmp_dir.tap(&:mkdir_p) unless Dir.exist? tmp_dir
    
    secure_name = SecureRandom.uuid + "-" + file_tmp.original_filename.downcase
    
    FileUtils.chmod(0644, file_tmp.tempfile.path)
    FileUtils.mv(file_tmp.tempfile.path, tmp_dir + secure_name)
    
    @file_path = tmp_dir + secure_name
    render js: {}
  # rescue => ex
  #   render nothing: true
  end
  
end