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


module Report
	class Data < Grape::API
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :report do
      desc "Get Report By Month"
      params do
        requires :month, type: String
      end
      get do
        #present :model, ModelObject.find(params[:id]), :with => ModelObject::ModelLarge        
      end
		end


    resource :indicators do
      desc "Get Indicators Report Current Month"
      get do
        #present :model, ModelObject.find(params[:id]), :with => ModelObject::ModelLarge        
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

        present :total_models, total_models
        present :total_inactive, total_inactive
        present :total_backtest, total_backtest
        present :total_unvalidated, total_unvalidated
        present :total_validated, total_validated
        present :total_validated_fullfil, total_validated_fullfil
        present :total_validated_no_fullfil, total_validated_no_fullfil


      end
    end

	end
end