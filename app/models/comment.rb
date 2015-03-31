# encoding: utf-8
class Comment < ActiveRecord::Base
  # validates

  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :resource, polymorphic: true

  belongs_to :parent,  class_name:  'Comment'
  has_many   :replies, foreign_key: :parent_id, class_name: 'Comment'

  delegate :name, to: :user, prefix: true, allow_nil: true
  # validates_inclusion_of :resource_type,   in: %w[ Comment Post  ]

  def to_hash
    {
      id:         id,
      user_id:    user_id,
      user_name:  user_name,
      content:    content,
      created_at: created_at.to_s(:db),
      replies:    replies.order(updated_at: :desc).map(&:to_hash)
    }
  end
  
  # 回复链 
  def children_chain(comments = [])
    if self.replies.empty?
      comments.concat self
    else
      self.replies.map{|c| c.children_chain(comments)}
    end
  end

end
