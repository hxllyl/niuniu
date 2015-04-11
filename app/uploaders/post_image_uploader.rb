# encoding: utf-8

# author: depp.yu

class PostImageUploader < ImageUploader

  version :large do
    process :resize_to_fit => [900, 600]
  end

end
