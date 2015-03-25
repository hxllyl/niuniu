# encoding: utf-8
class Comment < ActiveRecord::Base
  # validates

  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :resource, polymorphic: true

  belongs_to :parent,  class_name:  'Comment'
  has_many   :replies, foreign_key: :parent_id, class_name: 'Comment'


  # validates_inclusion_of :resource_type,   in: %w[ Comment Post  ]

  def to_hash
    {
      id:         id,
      user_id:    user_id,
      content:    content,
      created_at: created_at.to_s(:db),
      replies:    replies.order(updated_at: :desc).map(&:to_hash)
    }
  end
end
