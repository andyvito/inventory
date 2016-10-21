module Report
	class Data < Grape::API
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper

		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  	error_formatter :json, JSendErrorFormatter

		resource :report do
      desc "Get Report By Month and Year"
      params do
        requires :year, type: String
        requires :month, type: String
      end
      get do
        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i
          
        if (DateTime.parse(params[:year].to_s+'-'+params[:month].to_s+'-01') <= DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))
          
          totalModelsRisk = ReportMonth.find_by_sql("SELECT COUNT(m.id) AS 'total', (SELECT COUNT(m1.id) FROM report_months AS rm1 INNER JOIN report_details_months AS d1 ON rm1.id = d1.report_month_id INNER JOIN model_objects AS m1 ON d1.model_object_id = m1.id LEFT JOIN backtest_history_models AS b1 ON d1.backtest_history_model_id = b1.id WHERE (rm1.year = rm.year AND rm1.month = rm.month AND b1.result IS NULL)) AS unvalidated, "+
                    "(SELECT COUNT(m2.id) FROM report_months AS rm2 INNER JOIN report_details_months AS d2 ON rm2.id = d2.report_month_id INNER JOIN model_objects AS m2 ON d2.model_object_id = m2.id LEFT JOIN backtest_history_models AS b2 ON d2.backtest_history_model_id = b2.id WHERE (rm2.year = rm.year AND rm2.month = rm.month AND b2.result IS NOT NULL)) AS validated, "+
                    "(SELECT COUNT(m3.id) FROM report_months AS rm3 INNER JOIN report_details_months AS d3 ON rm3.id = d3.report_month_id INNER JOIN model_objects AS m3 ON d3.model_object_id = m3.id LEFT JOIN backtest_history_models AS b3 ON d3.backtest_history_model_id = b3.id WHERE (rm3.year = rm.year AND rm3.month = rm.month AND b3.result = 1)) AS validatedFullfil, "+
                    "(SELECT COUNT(m4.id) FROM report_months AS rm4 INNER JOIN report_details_months AS d4 ON rm4.id = d4.report_month_id INNER JOIN model_objects AS m4 ON d4.model_object_id = m4.id LEFT JOIN backtest_history_models AS b4 ON d4.backtest_history_model_id = b4.id WHERE (rm4.year = rm.year AND rm4.month = rm.month AND b4.result = 0)) AS validatedNotFullfil "+
                    "FROM report_months AS rm INNER JOIN report_details_months AS d ON rm.id = d.report_month_id INNER JOIN model_objects AS m ON d.model_object_id = m.id WHERE (rm.year = "+params[:year]+" AND rm.month = "+params[:month]+")")

          present :report, totalModelsRisk[0], :with => ReportMonth::Report, year: params[:year], month: params[:month]

        end
      end
		end

    resource :report_models do
      desc "Get Report Month By Month and Year"
      params do
        requires :year, type: String
        requires :month, type: String
      end
      get do
        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i
          
        if (DateTime.parse(params[:year].to_s+'-'+params[:month].to_s+'-01') <= DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))
          
          totalReportModels = ReportMonth.find_by_sql("SELECT r.name AS 'risk', m.code, m.name, a.name AS 'area', a.lead, m.is_qua, b.result "+
                    "FROM report_months AS rm INNER JOIN report_details_months AS d ON rm.id = d.report_month_id "+
                    "INNER JOIN model_objects AS m ON d.model_object_id = m.id "+
                    "LEFT JOIN backtest_history_models AS b ON d.backtest_history_model_id = b.id "+
                    "INNER JOIN risk_models AS r ON m.risk_model_id = r.id INNER JOIN area_models AS a ON m.area_model_id = a.id "+
                    "WHERE (rm.year = "+params[:year]+" AND rm.month = "+params[:month].to_s+")")

          present :report_models, totalReportModels, :with => ReportMonth::ReportModels, year: params[:year], month: params[:month]
          

        end
      end
    end



    resource :indicators do
      desc "Get Indicators Report Current Month"
      get do
               
        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

        total_models = ModelObject.count
        total_inactive = ModelObject.where('active = 0').count
        report = ReportMonth.where('year = ? AND month = ?', current_year, current_month)[0]
        total_backtest = report.total_models
        total_unvalidated = report.total_unvalidated
        total_validated = report.validated
        total_validated_fullfil = report.validated_fullfil
        total_validated_no_fullfil = report.validated_no_fullfil

        indicators ||= {}
        indicators[:total_models] = total_models
        indicators[:total_inactive] ||= {}
        indicators[:total_inactive][:value] = total_inactive
        indicators[:total_inactive][:percentage] = (total_inactive.to_f/total_models.to_f).round(4)
        indicators[:total_backtest] ||= {}
        indicators[:total_backtest][:value] = total_backtest
        indicators[:total_backtest][:percentage] = (total_backtest.to_f/(total_models-total_inactive).to_f).round(4)
        indicators[:total_unvalidated] ||= {}
        indicators[:total_unvalidated][:value] = total_unvalidated
        indicators[:total_unvalidated][:percentage] = (total_unvalidated.to_f/total_backtest.to_f).round(4)
        indicators[:total_validated] ||= {}
        indicators[:total_validated][:value] = total_validated
        indicators[:total_validated][:percentage] = (total_validated.to_f/total_backtest.to_f).round(4)
        indicators[:total_validated_fullfil] ||= {}
        indicators[:total_validated_fullfil][:value] = total_validated_fullfil
        indicators[:total_validated_fullfil][:percentage] = (total_validated_fullfil.to_f/total_validated.to_f).round(4)
        indicators[:total_validated_no_fullfil] ||= {}
        indicators[:total_validated_no_fullfil][:value] = total_validated_no_fullfil
        indicators[:total_validated_no_fullfil][:percentage] = (total_validated_no_fullfil.to_f/total_validated.to_f).round(4)

        present indicators

      end
    end

	end
end