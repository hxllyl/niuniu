# encoding: utf-8
class Complaint < ActiveRecord::Base

  STATUS = {
    0 => '未处理',
    1 => '已处理'
  }

  # 投诉类型可以为人(resource_type: 'User')或信息(resource_type: 'Post')
  belongs_to :resource, polymorphic: true
  belongs_to :user, class_name: 'User'
  belongs_to :operator, class_name: 'User'
end
