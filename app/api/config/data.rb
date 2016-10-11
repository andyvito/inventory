module JSendSuccessFormatter
  def self.call object, env
    { :status => 'success', :code => 200, :data => object }.to_json
  end
end

module JSendErrorFormatter
  def self.call message, backtrace, options, env
    # This uses convention that a error! with a Hash param is a jsend "fail", otherwise we present an "error"
    if message.is_a?(Hash)
      { :status => 'fail', :data => message }.to_json
    else
      { :status => 'error', :message => message }.to_json
    end
  end
end



module Config
  class Data < Grape::API
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


    resource :close_month do
      desc "Close a Month"
      post do


        current_year = Configuration.where('name = ?', 'current_year')
        current_month = Configuration.where('name = ?', 'current_month')
        if (current_year[0].value.to_i <= Date.today.year and current_month[0].value.to_i <= Date.today.month)
          new_date = DateTime.parse(current_year[0].value.to_s+'-'+current_month[0].value.to_s+'-01') + 1.months  
          current_year[0].value = new_date.year
          current_year[0].save
          current_month[0].value = new_date.month
          current_month[0].save         

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
        end
  
        present :current_date, Configuration.where('name in (?,?)', 'current_year','current_month'), :with => Configuration::Config

      end
    end





  end
end