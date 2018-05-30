class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.integer :start_id
      t.integer :end_id

      t.timestamps
    end
  end
end
