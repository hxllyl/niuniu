# encoding: utf-8

# author: utf-8
# user mail字段设为可以为空

class AlterMailColumnForUsers < ActiveRecord::Migration
  def change 
    change_column :users, :email, :string, null: true
  end
end

