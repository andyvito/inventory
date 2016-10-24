module ApiHelpers
  module BacktestingHelper

    def self.getLastBacktestByModelId(modelId)
      m = ModelObject
          .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id")
          .select('model_objects.id, last.next_year, last.next_month')
          .where('model_objects.id = ?', modelId)[0]  

      return m    
    end

    def incrementReportMonth(current_year, current_month, modelId)
      report = ReportMonth.where('year = ? AND month = ?', current_year, current_month)[0]
      report.total_models += 1
      report.total_unvalidated += 1
      report.save

      report_details = ReportDetailsMonth.new
      report_details.report_month_id = report.id
      report_details.model_object_id = modelId
      report_details.save
    end

    def decrementReportMonth(current_year, current_month, modelId)
      report = ReportMonth.where('year = ? AND month = ?', current_year, current_month)[0]
      rd = ReportDetailsMonth.where('report_month_id = ? AND model_object_id = ?', report.id, modelId)[0]
      if (rd.backtest_history_model_id == nil)
        report.total_models -= 1
        report.total_unvalidated -= 1
        rd.destroy
      end
      report.save
    end




    def updateReportFromActive(old_active, new_active, modelId)
      #if old_active is the same new_active means the active doesn't change, so we
      #don't have to update the report. Else, when a model pass inactive to active 
      #(or viceversa), the report changes|
      if (old_active != new_active)

        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i
        m = BacktestingHelper.getLastBacktestByModelId(modelId)

        if (DateTime.parse(m.next_year.to_s+'-'+m.next_month.to_s+'-01') <= DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))          
          if (new_active == true) #is active
            incrementReportMonth(current_year, current_month, modelId)
          else
            decrementReportMonth(current_year, current_month, modelId)    
          end
        end
      end
    end



    def updateReportFromFrecuency(paramYear, paramMonth, oldYear, oldMonth, modelId)
      current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
      current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

      #when the backtesting's next_year and next_month is equals to current year and month, the report month changes
      if (DateTime.parse(paramYear.to_s+'-'+paramMonth.to_s+'-01') == DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))
        incrementReportMonth(current_year, current_month, modelId)
      end

      if (DateTime.parse(oldYear.to_s+'-'+oldMonth.to_s+'-01') == DateTime.parse(current_year.to_s+'-'+current_month.to_s+'-01'))
          decrementReportMonth(current_year, current_month, modelId)   
      end
    end





  end #end module
end