# encoding: utf-8

# author: depp.yu

class User < ActiveRecord::Base

  # validates

  # tables relation
  has_many :photos, as: :owner # 与图片类关联起来 处理用户图片

  # constants

  Roles = %w(normal admin)

  Status = {
    0  => 'unapproved',
    1  => 'approved',
    -1 => 'deleted'
  }

  Levels = {
    0 => '个人',
    1 => '认证资源',
    2 => '认证综展',
    3 => '4S'
  }

  # class methods

  # instance methods

end
