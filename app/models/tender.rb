# encoding: utf-8

class Tender < ActiveRecord::Base

  # relations
  belongs: user, class_name: 'User'
end
