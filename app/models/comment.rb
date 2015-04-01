# encoding: utf-8
class Comment < ActiveRecord::Base
  # validates
  
  has_ancestry ancestry_column: :ancestry
  
  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :resource, polymorphic: true

  # belongs_to :parent,  class_name:  'Comment'
  # has_many   :replies, foreign_key: :parent_id, class_name: 'Comment'

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
  
  # 一个评论下的回复
  def children_chain
    #list = Comment::get_whole_tree(self).flatten
    self.descendants
  end
  
  def self.get_hash_leaf_nodes(node)
    if node.replies.nil? or node.replies.empty?
      [node]
    else
      leaves = node.replies.map { |child| self.get_hash_leaf_nodes(child) }.
        inject(:+)
    end
  end
  
  # def self.get_whole_tree(comment)
  #   nodes = lambda do |node|
  #     if node.replies.nil? or node.replies.empty?
  #       node.replies.to_a
  #     else
  #       node.replies.map{|child| nodes.call child}.inject(:+)
  #     end
  #   end
  #
  #   nodes.call comment
  # end
  
end
