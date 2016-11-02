class CreateModelObjects < ActiveRecord::Migration
  def change
    create_table :model_objects do |t|
      t.integer :consecutive
      t.string :name
      t.text :description
      t.string :len
      t.string :cat
      t.string :kind
      t.integer :frecuency
      t.text :met_validation
      t.float :met_hours_man
      t.float :qua_hours_man
      t.float :cap_area
      t.float :cap_qua
      t.float :cap_total
      t.text :comments
      t.text :more_info
      t.boolean :curriculum
      t.string :file_doc
      t.integer :current_version 
      t.boolean :is_qua
      t.boolean :active
      t.references :risk_model, foreign_key: true
	    t.references :area_model, foreign_key: true
      t.timestamps null: false
    end
  end
end
