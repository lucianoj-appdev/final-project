class SaveWeather < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :weather, :array
  end
end
