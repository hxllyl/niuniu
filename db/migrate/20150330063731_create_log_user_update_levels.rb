# encoding: utf-8

class CreateLogUserUpdateLevels < ActiveRecord::Migration
  def change
    create_table :log_user_update_levels do |t|
      t.references :user, class_name: 'User' # 所属用户
      t.references :operator, class_name: 'Staff' # 后台审核人员
      t.column     :method_name, :string, limit: 20, default: 'update_level'
      t.column     :start_level, :integer # 起始等级
      t.column     :end_level,   :integer # 升级等级
      t.column     :status, :integer, default: 0 # 状态 0 等待审核 1 审核通过 2 审核不同通过 
      t.timestamps null: false
    end
    
    add_index(:log_user_update_levels, :user_id)
    add_index(:log_user_update_levels, :end_level)
    add_index(:log_user_update_levels, :status)
    add_index(:log_user_update_levels, :method_name)
  end
end
