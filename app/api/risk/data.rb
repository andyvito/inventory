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


module Risk
	class Data < Grape::API
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :risk_model_data do
			desc "List all Risks"
			get do
				present :risks, RiskModel.all, :with => RiskModel::Risk
			end

			desc "create a new Risk Model"
			params do
			  requires :name, type: String
			end
			post do
			  present :risk, RiskModel.create!({name:params[:name]}), :with => RiskModel::Risk
			end

			desc "delete an Risk Model"
			params do
				requires :riskid, type: String
			end
			delete ':riskid' do
				present :risk, RiskModel.find(params[:riskid]).destroy!, :with => RiskModel::Risk
			end

			desc "update an Risk Model name"
			params do
			  requires :id, type: String
			  requires :name, type:String
			end
			put ':id' do
			  RiskModel.find(params[:id]).update({name:params[:name]})
			  present :risk, RiskModel.find(params[:id]), :with => RiskModel::Risk
			end
		end
	end
end