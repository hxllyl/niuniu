# encoding: utf-8

# author: depp.yu 
# 处理图片综合类

class Photo < ActiveRecord::Base
  
  # validates
  validates  :image, presence: true
  validates  :_type, presence: true
  
  # relations
  belongs_to  :owner, polymorphic: true
  
  # contants
  mount_uploader :image, ImageUploader # 使用 imageuploader 管理图片上传后的操作
  
  # 图片类型,依次：头像 身份证 手持身份证 名片 展厅门头 展厅内部 营业执照
  TYPES = %w(avatar identity hand_id visiting room_outer room_inner license) 
  
  # class_methods
  
  # instance_methods
  
  
end
