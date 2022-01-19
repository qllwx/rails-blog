class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :code,unique: true
      t.string :name       
      t.string :countyCode
      t.integer :studentTotal
      t.integer :excellentTotal
      t.integer :goodTotal
      t.integer :passTotal
      t.integer :failTotal
      t.integer :missExamTotal
      t.string :category
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
