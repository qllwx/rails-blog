class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :code,unique: true
      t.string :name      
      t.string :cityId
      t.string :countyId
      t.integer :totalStudents
      t.integer :excellentNum
      t.integer :goodNum
      t.integer :passNum
      t.integer :failNum
      t.integer :missexam
      t.string :category
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
