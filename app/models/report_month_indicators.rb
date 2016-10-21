class ReportMonthIndicators < ActiveRecord::Base
	


	class Indicators < Grape::Entity
		expose :riskId
		expose :risk
		expose :areaId
		expose :area
		expose :result
		expose :total
    end



end