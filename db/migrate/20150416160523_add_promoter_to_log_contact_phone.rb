# encoding: utf-8

class AddPromoterToLogContactPhone < ActiveRecord::Migration
  def change
    add_column :log_contact_phones, :promoter, :references, class_name: 'User'
  end
end
