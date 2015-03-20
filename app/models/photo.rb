# encoding: utf-8

# author: depp.yu 
# 处理图片综合类

class Photo < ActiveRecord::Base
  
  # contants
  # 图片类型,依次：头像 身份证 手持身份证 名片 展厅门头 展厅内部 营业执照 品牌
  TYPES = %w(avatar identity hand_id visiting room_outer room_inner license brand)
  
  # validates
  validates  :image, presence: true
  validates  :_type, presence: true, inclusion: { in: TYPES }
  
  # relations
  belongs_to  :owner, polymorphic: true
  mount_uploader :image, ImageUploader # 使用 imageuploader 管理图片上传后的操作
  
  # class_methods
  
  # instance_methods
  
  
end
