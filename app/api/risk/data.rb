module Risk
	class Data < Grape::API
		format :json
		rescue_from :all

		error_formatter :json, lambda { |message,backtrace, options, env|
			{
				status: 'failed',
				message: message,
				error_code: 123 #TODO: remove hardcoded error code and put dynamic
			}
		}

		resource :risk_model_data do
			desc "List all Risks"
			get do
				RiskModel.all
			end

			desc "create a new Risk Model"
			params do
			  requires :name, type: String
			end
			post do
			  RiskModel.create!({
			    name:params[:name]
			  })
			end

			desc "delete an Risk Model"
			params do
				requires :id, type: String
			end
			delete ':id' do
				RiskModel.find(params[:id]).destroy!
			end

			desc "update an Risk Model name"
			params do
			  requires :id, type: String
			  requires :name, type:String
			end
			put ':id' do
			  RiskModel.find(params[:id]).update({
			    name:params[:name]
			  })
			end
		end
	end
end