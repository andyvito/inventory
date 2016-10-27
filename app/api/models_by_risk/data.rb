module ModelsByRisk
	class Data < Grape::API
		helpers ApiHelpers::JSendSuccessFormatterHelper
    	helpers ApiHelpers::JSendErrorFormatterHelper
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