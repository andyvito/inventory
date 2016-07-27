class CreateRiskModels < ActiveRecord::Migration
  def change
    create_table :risk_models do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
