class ModelObject < ActiveRecord::Base
	belongs_to :area_model
	belongs_to :risk_model
	belongs_to :report_details_month
	has_many :backtest_history_models, -> { order(id: :desc) }


  	class ModelLarge < Grape::Entity
		expose :id
		expose :code #
		expose :name #
		expose :description #
		expose :len #
		expose :cat #
		expose :kind #
		expose :frecuency#
		expose :met_validation #
		expose :met_hours_man #
		expose :qua_hours_man #
		expose :cap_area #
		expose :cap_qua #
		expose :cap_total #
		expose :comments #
		expose :more_info #
		expose :curriculum #
		expose :file_doc
		expose :active
		expose :is_qua #
		expose :version  #
		expose :initial_dates #
		expose :original_author #
		expose :final_dates #
		expose :final_author #
		
      	expose :current_backtest do
      		expose :next_backtest_year
      		expose :next_backtest_month  
      		expose :is_delayed    		
      	end
		expose :risk_model,:using => RiskModel::Risk, as: :risk #
		expose :area_model,:using => AreaModel::AreaShort, as: :area #
		expose :backtest_history_models,:using => BacktestHistoryModel::Backtest, as: :backtest_historial #



      	def is_delayed
      		year = object.next_backtest_year.blank? ? 0 : object.next_backtest_year
      		month = object.next_backtest_month.blank? ? 0 : object.next_backtest_month
	       	current_year = options[:year]
	        current_month = options[:month]

      		delayed = 0
      		if (year > 0 && month > 0)
				delayed = (current_year * 12 + current_month) - (year * 12 + month)
			end
      		delayed > 0 ? delayed : nil
      	end	


  	end

	class ModelShort < Grape::Entity
		expose :id
		expose :code
		expose :name
		expose :len
		expose :active
      	expose :current_backtest do
      		expose :next_year
      		expose :next_month 
      		expose :is_delayed    		
      		expose :val_backtest_cur_month
      	end
		expose :risk_model,:using => RiskModel::Risk, as: :risk
		expose :area_model,:using => AreaModel::AreaShort, as: :area
		expose :backtest_id, :if => Proc.new {|g| g.backtest_id.nil?}, as: :last_backtest
		expose :last_backtest, :unless => Proc.new {|g| g.backtest_id.nil?} do
    	expose :validate_year 
		expose :validate_month
		expose :real_year
		expose :real_month
		expose :next_year
		expose :next_month
		expose :months_delayed
		expose :comentaries
		expose :result
    end

      	def is_delayed
      		year = object.next_year.blank? ? 0 : object.next_year
      		month = object.next_month.blank? ? 0 : object.next_month
	        current_year = options[:year]
	        current_month = options[:month]

      		delayed = 0
      		if (year > 0 && month > 0)
				delayed = (current_year * 12 + current_month) - (year * 12 + month)
			end
      		delayed > 0 ? delayed : nil
      	end	

      	def val_backtest_cur_month
      		val_cur_month = false
      		year = object.next_year.blank? ? 0 : object.next_year
      		month = object.next_month.blank? ? 0 : object.next_month

      		if (year > 0 && month > 0)
	        	current_year = options[:year]
	        	current_month = options[:month]

				if (DateTime.parse(year.to_s+'-'+month.to_s+'-01') <= DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))
					val_cur_month = true					
				end
			end
			val_cur_month
      	end
  	end



  	class ModelClone < Grape::Entity
		expose :id
		expose :code
		expose :name
    end

end
