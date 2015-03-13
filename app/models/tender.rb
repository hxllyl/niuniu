# encoding: utf-8

class Tender < ActiveRecord::Base

  # relations
  belongs_to :user, class_name: 'User'
end
