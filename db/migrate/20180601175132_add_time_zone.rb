class AddTimeZone < ActiveRecord::Migration[5.1]
  def change
      add_column :locations, :time_zone, :string
  end
end
