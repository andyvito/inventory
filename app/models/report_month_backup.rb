class ReportMonth < ActiveRecord::Base
	has_many :report_details_month, -> { order(id: :desc) }

	

 	class Models < Grape::Entity
    	expose :id
    	expose :name
    end



    class TotalModelByArea < Grape::Entity
		expose :areaId
		expose :area
		expose :total do
      		expose :total, as: :value
      		expose(:percentage) { |r, options| (r.total.to_f/r.totalModelsByArea.to_f).round(4)  }
      	end
		expose :models,:using => ReportMonth::Models, as: :models


		def models
            str_result = object.result.nil? ? ' IS NULL ' : ' = ' + object.result.to_s
			totalModelByArea = ReportMonth
                              .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id LEFT JOIN backtest_history_models AS b ON d.backtest_history_model_id = b.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id INNER JOIN area_models AS a ON m.area_model_id = a.id")
                              .select("m.id, m.name")
                              .where('report_months.year = ? AND report_months.month = ? AND r.id = ? AND a.id = ? AND b.result ' + str_result.to_s ,options[:year], options[:month].to_i+1, object.riskId, object.areaId)
		end
	end


    class TotalModelGroupByRiskAndResult < Grape::Entity
		expose :result
		expose :total do
      		expose :total, as: :value
      		expose(:percentage) { |r, options| (r.total.to_f/r.totalModelsByRisk.to_f).round(4)  }
      	end
		expose :totalModelByArea,:using => ReportMonth::TotalModelByArea, as: :areas

		def totalModelByArea
            str_result = object.result.nil? ? ' IS NULL ' : ' = ' + object.result.to_s
			totalModelByArea = ReportMonth
                              .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id LEFT JOIN backtest_history_models AS b ON d.backtest_history_model_id = b.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id INNER JOIN area_models AS a ON m.area_model_id = a.id")
                              .select("r.id AS riskId,  r.name AS 'risk', a.id AS 'areaId', a.name AS 'area', b.result, #{object.total} AS 'totalModelsByArea', COUNT(m.id) AS 'total'")
                              .where('report_months.year = ? AND report_months.month = ? AND r.id = ? AND b.result ' + str_result.to_s ,options[:year], options[:month].to_i+1, object.riskId)
                              .group('m.risk_model_id, m.area_model_id, b.result')
		end
	end
	
	class TotalModelGroupByRisk < Grape::Entity
		expose :risk
		expose :total do
      		expose :total, as: :value
      		expose(:percentage) { |r, options| (r.total.to_f/r.totalModels.to_f).round(4)  }
      	end
		expose :totalModelGroupByRiskAndResult,:using => ReportMonth::TotalModelGroupByRiskAndResult, as: :details

		def totalModelGroupByRiskAndResult
          #Total Models by Risk and Result
          totalModelGruopByRiskAndResult = ReportMonth
                              .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id LEFT JOIN backtest_history_models AS b ON d.backtest_history_model_id = b.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id")                             
                              .select("r.id AS riskId,  r.name AS 'risk', b.result, #{object.total} AS 'totalModelsByRisk', COUNT(m.id) AS 'total'")
                              .where('report_months.year = ? AND report_months.month = ? AND r.id = ?',options[:year], options[:month].to_i+1, object.riskId)
                              .group('m.risk_model_id, b.result')

		end
    end


    class Report < Grape::Entity
		expose :year
		expose :month
		#expose :total_models do
      	#	expose :total_models, as: :value
      	#	expose(:percentage) { |r, options| 1.0  } #always will be 1
      	#end
		#expose :total_unvalidated do
		#	expose :total_unvalidated, as: :value
		#	expose(:percentage) { |r, options| (r.total_unvalidated.to_f/r.total_models.to_f).round(4)  }
		#end
		#expose :validated do
		#	expose :validated, as: :value
		#	expose(:percentage) { |r, options| (r.validated.to_f/r.total_models.to_f).round(4)  }
		#end
		#expose :validated_fullfil do
		#	expose :validated_fullfil, as: :value
		#	expose(:percentage) { |r, options| (r.validated_fullfil.to_f/r.validated.to_f).round(4)  }
		#end
		#expose :validated_no_fullfil do
		#	expose :validated_no_fullfil, as: :value
		#	expose(:percentage) { |r, options| (r.validated_no_fullfil.to_f/r.validated.to_f).round(4)  }
		#end
		
		expose :totalModelGroupByRisk,:using => ReportMonth::TotalModelGroupByRisk, as: :risks
		

		def totalModelGroupByRisk
			#Total Models by Risk
          	totalModelGroupByRisk = ReportMonth
                              .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id")                             
                              .select("r.id AS riskId,  r.name AS 'risk', #{object.total_models} AS 'totalModels', COUNT(m.id) AS 'total'")
                              .where('report_months.year = ? AND report_months.month = ?',options[:year], options[:month].to_i+1)
                              .group('m.risk_model_id')
		end
    end

    ##############################################################s



	class ExcTotalModelGroupByRisk < Grape::Entity
		expose :risk
		expose :area
		expose :result
		expose :total
		#expose :totalModelGroupByRiskAndResult,:using => ReportMonth::TotalModelGroupByRiskAndResult, as: :details


    end





     class ReportExc < Grape::Entity
     	expose :year
     	expose :month
     	expose :totalModelGroupByRisk,:using => ReportMonth::ExcTotalModelGroupByRisk, as: :risks

     	def totalModelGroupByRisk
			#Total Models by Risk
          	#totalModelGroupByRisk = ReportMonth
            #                  .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id INNER JOIN area_models AS a ON m.area_model_id = a.id")                             
            #                  .select("r.id AS riskId,  r.name AS 'risk', a.name AS 'area',  #{object.total_models} AS 'totalModels', COUNT(m.id) AS 'total'")
            #                  .where('report_months.year = ? AND report_months.month = ?',options[:year], options[:month].to_i+1)
            #                  .group('r.id, a.id')


            #str_result = object.result.nil? ? ' IS NULL ' : ' = ' + object.result.to_s
			totalModelGroupByRisk = ReportMonth
                              .joins("INNER JOIN report_details_months AS d ON report_months.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id LEFT JOIN backtest_history_models AS b ON d.backtest_history_model_id = b.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id INNER JOIN area_models AS a ON m.area_model_id = a.id")
                              .select("r.id AS riskId,  r.name AS 'risk', a.id AS 'areaId', a.name AS 'area', b.result AS 'result', COUNT(m.id) AS 'total'")
                              .where('report_months.year = ? AND report_months.month = ?',options[:year], options[:month].to_i+1)
                              .group('m.risk_model_id, m.area_model_id, b.result')

		end
     end




end
