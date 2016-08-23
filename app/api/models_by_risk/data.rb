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


module ModelsByRisk
	class Data < Grape::API
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter


		helpers do
	      def current_risk
	        key = params[:riskid]
	        @current_risk ||= RiskModel.find(key)
	      end

	      #def authenticate!
	      #  error!({ "status" => "Fail", "error_message" => "Bad Key" }, 401) unless current_company
	      #end
	    end

		
		resource :modelsByRisk do
			desc "List all Models By Risks"
			params do
			  requires :riskid, type: String
			end
			get do
				models = current_risk.model_objects
				present :riskid, params[:riskid]
				present :models, models, :with => Entities::ModelObject
			end




			
		end
	end
end