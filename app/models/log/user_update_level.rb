# encoding: utf-8

class Log::UserUpdateLevel < ActiveRecord::Base

  STATUS = {
    0 => '待审核',
    1 => '审核通过',
    2 => '审核不通过'
  }

  belongs_to :user, class_name: 'User'
  belongs_to :operator, class_name: 'Staff'

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :operator, prefix: true, allow_nil: true

  scope :unapproved, -> { where('status <> 1') }

  def show_photos_with_level
    types = case end_level
            when User::LEVELS.keys[1] then
              ['identity', 'hand_id']
            when User::LEVELS.keys[2] then
              ['license']
            when User::LEVELS.keys[3] then
              ['visiting', 'room_outer', 'room_inner', 'license']
            else
              ['visiting', 'room_outer', 'room_inner']
            end

    photos = users.photos.where('_type in (?)', types)
  end

  before_create :has_same_request?

  def has_same_request?
    log = Log::UserUpdateLevel.find_by(user: user, start_level: start_level, end_level: end_level, status: STATUS.keys[0])
    return if log
  end

  def is_wait?
    status == STATUS.keys[0]
  end

  def is_approved?
    status == STATUS.keys[1]
  end
end
