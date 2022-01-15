class CreateAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :areas do |t|
      t.string :code
      t.string :name
      t.integer :total_schools

      t.timestamps
    end
  end
end
