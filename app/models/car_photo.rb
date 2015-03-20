# encoding: utf-8

# author: depp.yu

class CarPhoto < Photo
  self.table_name = 'photos'
  
  TYPES = %w(brand base_car)
  
  belongs_to :owner, polymorphic: true
   
  mount_uploader :image, CarImageUploader 
end