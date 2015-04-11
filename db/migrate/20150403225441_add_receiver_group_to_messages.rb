class AddReceiverGroupToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :receiver_group, :integer
  end
end
