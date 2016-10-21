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


module Backtest
  class Data < Grape::API
    format :json
    rescue_from :all

    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter
  
    resource :backtest do
      desc "create a new backtest"
      params do
        requires :modelid, type: String
        requires :result, type: String 
        optional :comments, type: String        
      end
      post do
        maxBacktesting = BacktestHistoryModel.where('model_object_id = ?', params[:modelid]).maximum('id')
        lastBacktest = BacktestHistoryModel.where('model_object_id = ? AND id = ?', params[:modelid], maxBacktesting)[0]
        frecuency = ModelObject.where('id = ?',params[:modelid]).pluck(:frecuency)[0]

        #Default values
        next_month = lastBacktest[:next_month].blank? ? Date.today.month : lastBacktest[:next_month]      
        next_year = lastBacktest[:next_year].blank? ? Date.today.year : lastBacktest[:next_year] 

        backtest_date = DateTime.parse(next_year.to_s+'-'+next_month.to_s+'-01')
        backtest_date = backtest_date + frecuency.to_i.months

        if (backtest_date < Date.today)
          backtest_date = Date.today + frecuency.to_i.months
        end

        next_month = backtest_date.month
        next_year = backtest_date.year

        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

        months_delayed = (current_year * 12 + current_month) - (lastBacktest[:next_year] * 12 + lastBacktest[:next_month])
        months_delayed = months_delayed > 0 ? months_delayed : nil


        #if model's result backtesting doesn't accomplish, so the new state is CALIBRATE, so doesn't save new date of backtesting.
        commentaries = params[:comments]

        if (params[:result].to_i == 0)
          commentaries = 'EN CALIBRACION. ' + commentaries
          next_year = nil
          next_month = nil
        end


        backtest_history = BacktestHistoryModel.create({validate_year: lastBacktest[:next_year], validate_month: lastBacktest[:next_month], 
                                    real_year: current_year, real_month: current_month, 
                                    next_year: next_year, next_month: next_month, 
                                    months_delayed: months_delayed, comentaries: commentaries,
                                    result: params[:result], model_object_id: params[:modelid]})

        present :backtest, backtest_history, :with => BacktestHistoryModel::Backtest 


        report = ReportMonth.where('year = ? AND month = ?', current_year, current_month)[0]
        report.total_unvalidated -= 1
        report.validated += 1

        if (params[:result].to_i == 1)
          report.validated_fullfil += 1
        else
          report.validated_no_fullfil += 1
        end
        report.save


        report_details = ReportDetailsMonth.where('report_month_id = ? AND model_object_id = ?', report.id, params[:modelid])[0]
        report_details.backtest_history_model_id = backtest_history.id
        report_details.save


      end
    end

  end
end