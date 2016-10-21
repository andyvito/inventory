class ReportDetailsMonth < ActiveRecord::Base
	belongs_to :report_month
	has_many :model_objects, -> { order(id: :desc) }
	belongs_to :backtest_history_models, -> { order(id: :desc) }


	class ReportDetails < Grape::Entity
		expose :model_object_id
		expose :backtest_history_model_id
    end



end
