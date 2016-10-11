class ReportDetailsMonth < ActiveRecord::Base
	belongs_to :report_month
	has_many :backtest_history_models, -> { order(id: :desc) }
end
