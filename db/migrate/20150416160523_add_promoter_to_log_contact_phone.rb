# encoding: utf-8

class AddPromoterToLogContactPhone < ActiveRecord::Migration
  def change
    add_reference :log_contact_phones, :promoter, class_name: 'User'
  end
end
