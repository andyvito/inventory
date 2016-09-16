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
        requires :yearResult, type: Integer
        requires :monthResult, type: Integer 
        requires :comments, type: String        
      end
      post do
        maxBacktesting = BacktestHistoryModel.where('model_object_id = ?', params[:modelid]).maximum('id')
        lastBacktest = BacktestHistoryModel.where('model_object_id = ? AND id = ?', params[:modelid], maxBacktesting)[0]
        frecuency = ModelObject.where('id = ?',params[:modelid]).pluck(:frecuency)[0]

        #Devault values
        next_month = lastBacktest[:next_month].blank? ? Date.today.month : lastBacktest[:next_month]      
        next_year = lastBacktest[:next_year].blank? ? Date.today.year : lastBacktest[:next_year] 

        #Calculate next dates backtesting
        next_month = next_month.to_i + frecuency.to_i
        next_year = next_year.to_i
        if (next_month > 12) 
          next_month -= 12
          next_year += 1 
        end

        if (next_year < Date.today.year && next_month < Date.today.month)
          next_year = Date.today.year
          next_month = Date.today.month
        end

        months_delayed = (params[:yearResult] * 12 + params[:monthResult]) - (lastBacktest[:next_year] * 12 + lastBacktest[:next_month])
        months_delayed = months_delayed > 0 ? months_delayed : nil

        present :backtest, BacktestHistoryModel.create({validate_year: lastBacktest[:next_year], validate_month: lastBacktest[:next_month], 
                                    real_year: params[:yearResult], real_month: params[:monthResult], 
                                    next_year: next_year, next_month: next_month, 
                                    months_delayed: months_delayed, comentaries: params[:comments],
                                    result: params[:result], model_object_id: params[:modelid]}), :with => BacktestHistoryModel::Backtest 

      end
    end

  end
end