# encoding: utf-8

# author: depp.yu

class CreateStandards < ActiveRecord::Migration
  def change
    create_table :standards do |t|
      t.column :name, :string, limit: 15, null: false
      t.timestamps null: false
    end
    
    add_index(:standards, :name)
  end
end
