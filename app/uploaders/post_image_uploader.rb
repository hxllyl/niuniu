# encoding: utf-8

# author: depp.yu

class PostPhotoImageUploader < ImageUploader
  
  version :large do
    process :resize_to_fit => [450, 360]
  end
  
end