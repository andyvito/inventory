class BacktestHistoryModel < ActiveRecord::Base
	belongs_to :model_object
	belongs_to :report_details_month

	class Backtest < Grape::Entity

		expose :current_backtest do
      		expose :next_year
      		expose :next_month  
      		expose :is_delayed  
      		expose :val_backtest_cur_month  		
      	end
      	expose :last_backtest do
			expose :validate_year
			expose :validate_month
			expose :real_year
			expose :real_month
			expose :next_year
			expose :next_month
			expose :comentaries
			expose :result
			expose :months_delayed
		end
		expose :model_object_id, as: :modelid

	    def is_delayed
	  		year = object.next_year.blank? ? 0 : object.next_year
	  		month = object.next_month.blank? ? 0 : object.next_month
	  		delayed = 0
	  		if (year > 0 && month > 0)
				delayed = (Date.current.year * 12 + Date.current.month) - (year * 12 + month)
			end
	  		delayed > 0 ? delayed : nil
	  	end	


	  	def val_backtest_cur_month
	  		val_cur_month = false
	  		year = object.next_year.blank? ? 0 : object.next_year
	  		month = object.next_month.blank? ? 0 : object.next_month
	  		if (year > 0 && month > 0)
				if (year <= Date.current.year && month <= Date.current.month)
					val_cur_month = true					
				end
			end
			val_cur_month
	  	end



	end




end
