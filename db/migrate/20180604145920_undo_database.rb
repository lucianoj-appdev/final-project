class UndoDatabase < ActiveRecord::Migration[5.1]
  def change
    remove_column :routes, :weather
    remove_column :locations, :time_zone
  end
end
