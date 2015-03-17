# encoding: utf-8
class Post < ActiveRecord::Base

  # constants
  TYPES = {
    1 => '资源',
    2 => '寻车'
  }

  # relations
  belongs_to :user, class_name: 'User'
  has_many :tenders, -> {where(_type: TYPES[2])}, class_name: 'Tender'

  # class methods
  scope :resources, -> {where(_type: 0)}
  scope :needs,     -> {where(_type: 1)}


  # instance methods
  def to_0_hash
    {
      id: id,
      user_id: user_id
    }
  end

  def to_1_hash
    {
      id: id,
      user_ids: user_id
    }
  end
end
