class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :code
      t.string :name
      t.string :area_id
      t.string :city_id
      t.string :county_id
      t.integer :total_students
      t.integer :yx
      t.integer :lh
      t.integer :jg
      t.integer :bjg
      t.integer :qk
      t.string :category

      t.timestamps
    end
  end
end
