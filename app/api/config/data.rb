module Config
  class Data < Grape::API
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper

    format :json
    rescue_from :all

    formatter :json, JSendSuccessFormatter
      error_formatter :json, JSendErrorFormatter

    resource :config do
      desc "Get values by name"
      params do
        requires :names, type: Array[String]
      end
      get do
        present :config, Configuration.where('name in (?)', params[:names]), :with => Configuration::Config
      end
    end

    resource :get_current_date_backtesting do
      desc "Get current month and year for backtesting"
      get do
        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i
        d = Date.new(current_year,current_month)
        present :date, {'date':d, 'year':current_year, 'month':current_month}, :with => Configuration::DateServer 
      end
    end


    resource :close_month do
      desc "Close a Month"
      post do
        ActiveRecord::Base.transaction do
          begin 
            current_year = Configuration.where('name = ?', 'current_year')[0]
            current_month = Configuration.where('name = ?', 'current_month')[0]
            new_date = DateTime.parse(current_year.value.to_s+'-'+current_month.value.to_s+'-01') + 1.months 

            current_year.value = new_date.year
            current_year.save
            current_month.value = new_date.month
            current_month.save         

            #Create report and storage in report_month
            new_report_month = ReportMonth.new
            new_report_month.year = new_date.year
            new_report_month.month = new_date.month
            m = ModelObject.joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id")
                           .where('STR_TO_DATE( CONCAT_WS(",", "01",last.next_month,last.next_year), "%d,%m,%Y") <= STR_TO_DATE( CONCAT_WS(",", "01",?,?), "%d,%m,%Y") AND model_objects.active = 1 AND last.next_month IS NOT NULL AND last.next_year IS NOT NULL',new_date.month,new_date.year)

            new_report_month.total_models = m.count
            new_report_month.total_unvalidated = m.count
            new_report_month.validated = 0
            new_report_month.validated_fullfil = 0
            new_report_month.validated_no_fullfil = 0 
            new_report_month.save


            m.each do |model|
              new_report_detail = ReportDetailsMonth.new
              new_report_detail.report_month_id = new_report_month.id
              new_report_detail.model_object_id = model.id
              new_report_detail.save
            end
            
            present :date, {'date': new_date, 'year': new_date.year, 'month': new_date.month}, :with => Configuration::DateServer 
          rescue Exception => e
            p e.message
            ActiveRecord::Rollback
            raise StandardError.new("error close month")
          end
        end

      end
    end





  end
end
