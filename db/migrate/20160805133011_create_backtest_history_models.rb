class CreateBacktestHistoryModels < ActiveRecord::Migration
  def change
    create_table :backtest_history_models do |t|
      t.integer :validate_year
      t.integer :validate_month
      t.integer :real_year
      t.integer :real_month
      t.integer :next_year
      t.integer :next_month
      t.text :comentaries
      t.string :result
      t.references :model_object, foreign_key: true
      t.timestamps null: false
    end
  end
end
