# encoding: utf-8

# author: depp.yu

class PostPhoto < Photo
  self.table_name = 'photos'
  
  TYPES = %w(front side obverse inner)
  
  belongs_to :owner, polymorphic: true
  
  mount_uploader :image, PostPhotoUploader
end