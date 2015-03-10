# encoding: utf-8

# author: depp.yu

class User < ActiveRecord::Base

  # validates

  # tables relation

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
