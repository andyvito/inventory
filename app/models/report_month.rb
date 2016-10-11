class ReportMonth < ActiveRecord::Base
	has_many :report_details_month, -> { order(id: :desc) }



	




end
