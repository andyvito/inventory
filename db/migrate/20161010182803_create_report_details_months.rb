class CreateReportDetailsMonths < ActiveRecord::Migration
  def change
    #create_table :report_details_months, {:id => false} do |t|
    create_table :report_details_months do |t|
      t.references :report_month, foreign_key: true
      t.references :model_object, foreign_key: true
      t.references :backtest_history_model, foreign_key: true
      t.timestamps null: false
    end
    #execute "ALTER TABLE report_details_months ADD PRIMARY KEY (report_month_id,model_object_id);"
  end
end
