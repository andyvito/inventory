class CreateReportDetailsMonths < ActiveRecord::Migration
  def change
    create_table :report_details_months, {:id => false} do |t|
      t.references :report_month, foreign_key: true
      t.references :backtest_history_model, foreign_key: true
      t.timestamps null: false
    end
    execute "ALTER TABLE report_details_months ADD PRIMARY KEY (report_month_id,backtest_history_model_id);"
  end
end
