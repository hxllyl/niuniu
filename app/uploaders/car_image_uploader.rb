# encoding: utf-8

# author: depp.yu

class CarImageUploader < ImageUploader
  
  version :large do
    process :resize_to_fit => [360, 270]
  end
  
end