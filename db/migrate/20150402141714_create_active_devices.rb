# encoding: utf-8

class CreateActiveDevices < ActiveRecord::Migration
  def change
    create_table :active_devices do |t|
      t.references :user, class_name: 'User', null: false
      t.column :register_id, :string, limit: 30, null: false
      t.column :active, :boolean, default: false
      t.timestamps null: false
    end
    
    add_index(:active_devices, :user_id)
    add_index(:active_devices, :register_id)
  end
end
