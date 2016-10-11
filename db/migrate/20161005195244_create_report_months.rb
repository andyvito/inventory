class CreateReportMonths < ActiveRecord::Migration
  def change
    create_table :report_months do |t|
      t.integer :year
      t.integer :month 
      t.integer :total_models
      t.integer :total_unvalidated
      t.integer :validated
      t.integer :validated_fullfil
      t.integer :validated_no_fullfil
      t.timestamps null: false
    end
  end
end
