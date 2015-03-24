# encoding: utf-8
class Comment < ActiveRecord::Base
  # validates
  
  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :resource, polymorphic: true

  belongs_to :parent,  class_name: 'Comment'
  has_many :sub_comments, foreign_key: :parent_id, class_name: 'Comment'


  validates_inclusion_of :resource_type,   in: %w[ Comment Post  ]
end
