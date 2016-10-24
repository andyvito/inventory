class ReportMonth < ActiveRecord::Base
	has_many :report_details_month, -> { order(id: :desc) }

	
    class TotalModelByArea < Grape::Entity	
    	expose :area
    	expose :total

		expose :unvalidated do
      		expose(:value) {|r, options| r.unvalidated.blank? ? 0 : r.unvalidated }
      		expose(:percentage) { |r, options| (r.unvalidated.blank? || r.total.blank?) ? 0 : (r.unvalidated.to_f/r.total.to_f).round(4)  }
      	end
      	expose :validated do
      		expose(:value) {|r, options| r.validated.blank? ? 0 : r.validated }
      		expose(:percentage) { |r, options| (r.validated.blank? || r.total.blank?) ? 0 : (r.validated.to_f/r.total.to_f).round(4)  }
      	end 
      	expose :validatedFullfil do
      		expose(:value) {|r, options| r.validatedFullfil.blank? ? 0 : r.validatedFullfil }
      		expose(:percentage) { |r, options| (r.validatedFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedFullfil.to_f/r.validated.to_f).round(4)}
      	end
      	expose :validatedNotFullfil do
   			expose(:value) {|r, options| r.validatedNotFullfil.blank? ? 0 : r.validatedNotFullfil }
      		expose(:percentage) { |r, options| (r.validatedNotFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedNotFullfil.to_f/r.validated.to_f).round(4)  }
      	end

	end

	
	class TotalModelGroupByRisk < Grape::Entity

		expose :risk 
		expose :total
		expose :unvalidated do
      		expose(:value) {|r, options| r.unvalidated.blank? ? 0 : r.unvalidated }
      		expose(:percentage) { |r, options| (r.unvalidated.blank? || r.total.blank?) ? 0 : (r.unvalidated.to_f/r.total.to_f).round(4)  }
      	end
      	
      	expose :validated do
      		expose(:value) {|r, options| r.validated.blank? ? 0 : r.validated }
      		expose(:percentage) { |r, options| (r.validated.blank? || r.total.blank?) ? 0 : (r.validated.to_f/r.total.to_f).round(4)  }
      	end 
      	
      	expose :validatedFullfil do
      		expose(:value) {|r, options| r.validatedFullfil.blank? ? 0 : r.validatedFullfil }
      		expose(:percentage) { |r, options| (r.validatedFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedFullfil.to_f/r.validated.to_f).round(4)}
      	end
      	expose :validatedNotFullfil do
   			expose(:value) {|r, options| r.validatedNotFullfil.blank? ? 0 : r.validatedNotFullfil }
      		expose(:percentage) { |r, options| (r.validatedNotFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedNotFullfil.to_f/r.validated.to_f).round(4)  }
      	end

		expose :totalModelByRiskGroupByArea, :using => ReportMonth::TotalModelByArea, as: :areas

      	def totalModelByRiskGroupByArea
          	totalModelByRiskGroupByArea = ReportMonth.find_by_sql("SELECT r.name AS 'risk', a.name AS 'area', COUNT(m.id) AS 'total', (SELECT COUNT(m1.id) FROM report_months AS rm1 INNER JOIN report_details_months AS d1 ON rm1.id = d1.report_month_id INNER JOIN model_objects AS m1 ON d1.model_object_id = m1.id LEFT JOIN backtest_history_models AS b1 ON d1.backtest_history_model_id = b1.id WHERE (rm1.year = rm.year AND rm1.month = rm.month AND m1.risk_model_id = r.id  AND m1.area_model_id = a.id  AND b1.result IS NULL) GROUP BY m1.risk_model_id, m1.area_model_id) AS unvalidated,
										(SELECT COUNT(m2.id) FROM report_months AS rm2 INNER JOIN report_details_months AS d2 ON rm2.id = d2.report_month_id INNER JOIN model_objects AS m2 ON d2.model_object_id = m2.id LEFT JOIN backtest_history_models AS b2 ON d2.backtest_history_model_id = b2.id WHERE (rm2.year = rm.year AND rm2.month = rm.month AND m2.risk_model_id = r.id  AND m2.area_model_id = a.id  AND b2.result IS NOT NULL) GROUP BY m2.risk_model_id, m2.area_model_id) AS validated,
										(SELECT COUNT(m3.id) FROM report_months AS rm3 INNER JOIN report_details_months AS d3 ON rm3.id = d3.report_month_id INNER JOIN model_objects AS m3 ON d3.model_object_id = m3.id LEFT JOIN backtest_history_models AS b3 ON d3.backtest_history_model_id = b3.id WHERE (rm3.year = rm.year AND rm3.month = rm.month AND m3.risk_model_id = r.id  AND m3.area_model_id = a.id  AND b3.result = 1) GROUP BY m3.risk_model_id, m3.area_model_id) AS validatedFullfil,
										(SELECT COUNT(m4.id) FROM report_months AS rm4 INNER JOIN report_details_months AS d4 ON rm4.id = d4.report_month_id INNER JOIN model_objects AS m4 ON d4.model_object_id = m4.id LEFT JOIN backtest_history_models AS b4 ON d4.backtest_history_model_id = b4.id WHERE (rm4.year = rm.year AND rm4.month = rm.month AND m4.risk_model_id = r.id  AND m4.area_model_id = a.id  AND b4.result = 0) GROUP BY m4.risk_model_id, m4.area_model_id) AS validatedNotFullfil
										FROM report_months AS rm INNER JOIN report_details_months AS d ON rm.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id  INNER JOIN area_models AS a ON m.area_model_id = a.id WHERE (rm.year = "+options[:year]+" AND rm.month = "+options[:month]+" AND r.id = #{object.riskId}) GROUP BY m.risk_model_id, m.area_model_id ORDER BY r.name, a.name")
        end
    end

    class Report < Grape::Entity
    	expose :total
		expose :unvalidated do
      		expose(:value) {|r, options| r.unvalidated.blank? ? 0 : r.unvalidated }
      		expose(:percentage) { |r, options| (r.unvalidated.blank? || r.total.blank?) ? 0 : (r.unvalidated.to_f/r.total.to_f).round(4)  }
      	end
      	
      	expose :validated do
      		expose(:value) {|r, options| r.validated.blank? ? 0 : r.validated }
      		expose(:percentage) { |r, options| (r.validated.blank? || r.total.blank?) ? 0 : (r.validated.to_f/r.total.to_f).round(4)  }
      	end 
      	
      	expose :validatedFullfil do
      		expose(:value) {|r, options| r.validatedFullfil.blank? ? 0 : r.validatedFullfil }
      		expose(:percentage) { |r, options| (r.validatedFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedFullfil.to_f/r.validated.to_f).round(4)}
      	end
      	expose :validatedNotFullfil do
   			expose(:value) {|r, options| r.validatedNotFullfil.blank? ? 0 : r.validatedNotFullfil }
      		expose(:percentage) { |r, options| (r.validatedNotFullfil.blank? || r.validated.blank?) ? 0 : (r.validatedNotFullfil.to_f/r.validated.to_f).round(4)  }
      	end    	
		
		expose :totalModelGroupByRisk, :using => ReportMonth::TotalModelGroupByRisk, as: :risks
		
        def totalModelGroupByRisk
          	totalModelGroupByRisk = ReportMonth.find_by_sql("SELECT r.id AS riskId, r.name AS 'risk', COUNT(m.id) AS 'total', (SELECT COUNT(m1.id) FROM report_months AS rm1 INNER JOIN report_details_months AS d1 ON rm1.id = d1.report_month_id INNER JOIN model_objects AS m1 ON d1.model_object_id = m1.id LEFT JOIN backtest_history_models AS b1 ON d1.backtest_history_model_id = b1.id WHERE (rm1.year = rm.year AND rm1.month = rm.month AND m1.risk_model_id = r.id  AND b1.result IS NULL) GROUP BY m1.risk_model_id) AS unvalidated,
										(SELECT COUNT(m2.id) FROM report_months AS rm2 INNER JOIN report_details_months AS d2 ON rm2.id = d2.report_month_id INNER JOIN model_objects AS m2 ON d2.model_object_id = m2.id LEFT JOIN backtest_history_models AS b2 ON d2.backtest_history_model_id = b2.id WHERE (rm2.year = rm.year AND rm2.month = rm.month AND m2.risk_model_id = r.id  AND b2.result IS NOT NULL) GROUP BY m2.risk_model_id) AS validated,
										(SELECT COUNT(m3.id) FROM report_months AS rm3 INNER JOIN report_details_months AS d3 ON rm3.id = d3.report_month_id INNER JOIN model_objects AS m3 ON d3.model_object_id = m3.id LEFT JOIN backtest_history_models AS b3 ON d3.backtest_history_model_id = b3.id WHERE (rm3.year = rm.year AND rm3.month = rm.month AND m3.risk_model_id = r.id  AND b3.result = 1) GROUP BY m3.risk_model_id) AS validatedFullfil,
										(SELECT COUNT(m4.id) FROM report_months AS rm4 INNER JOIN report_details_months AS d4 ON rm4.id = d4.report_month_id INNER JOIN model_objects AS m4 ON d4.model_object_id = m4.id LEFT JOIN backtest_history_models AS b4 ON d4.backtest_history_model_id = b4.id WHERE (rm4.year = rm.year AND rm4.month = rm.month AND m4.risk_model_id = r.id  AND b4.result = 0) GROUP BY m4.risk_model_id) AS validatedNotFullfil
										FROM report_months AS rm INNER JOIN report_details_months AS d ON rm.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id INNER JOIN risk_models AS r ON m.risk_model_id = r.id WHERE (rm.year = "+options[:year]+" AND rm.month = "+options[:month]+") GROUP BY m.risk_model_id ORDER BY r.name")
    	end
    end



    class ReportModels < Grape::Entity
    	expose :code
    	expose :risk
    	expose :area
    	expose :lead
    	expose :is_qua
    	expose :name
    	expose :result

    end
  

end
