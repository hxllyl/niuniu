# encoding: utf-8
class HotPost < ActiveRecord::Base

  belongs_to :post, class_name: 'Post'

end
