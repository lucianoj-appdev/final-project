class AddUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :user_id, :integer
    add_column :locations, :user_id, :integer
  end
end
