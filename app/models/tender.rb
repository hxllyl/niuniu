# encoding: utf-8

class Tender < ActiveRecord::Base

  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :post, class_name: 'Post', conditions: {_type: Post::TYPES[2]}
end
