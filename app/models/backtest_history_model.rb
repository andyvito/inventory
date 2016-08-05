class BacktestHistoryModel < ActiveRecord::Base
	belongs_to :model_object

	class Backtest < Grape::Entity
		expose :validate_year
		expose :validate_month
		expose :real_year
		expose :real_month
		expose :next_year
		expose :next_month
		expose :comentaries
		expose :result
	end

end
