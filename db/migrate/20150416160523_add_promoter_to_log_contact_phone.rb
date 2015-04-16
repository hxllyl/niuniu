# encoding: utf-8

class AddPromoterToLogContactPhone < ActiveRecord::Migration
  def change
    add_column :LogContactPhones, :promoter, :references, class_name: 'User'
  end
end
