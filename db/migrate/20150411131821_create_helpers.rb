class CreateHelpers < ActiveRecord::Migration
  def change
    create_table :helpers do |t|
      t.string :title
      t.string :content

      t.timestamps null: false
    end
  end
end
