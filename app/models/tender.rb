# encoding: utf-8

class Tender < ActiveRecord::Base

  STATUS = {
    0 => '未成交',
    1 => '已成交'
  }

  # relations
  belongs_to :user, class_name: 'User'
  belongs_to :post, class_name: 'Post'

  # 已成交的报价
  scope :completed, -> { where(status: 1) }
end
