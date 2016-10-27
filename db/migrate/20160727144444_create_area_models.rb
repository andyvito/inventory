class CreateAreaModels < ActiveRecord::Migration
  def change
    create_table :area_models do |t|
      t.string :code
      t.string :name
      t.string :lead
	  t.references :risk_model, foreign_key: true
      t.timestamps null: false
    end
  end
end
