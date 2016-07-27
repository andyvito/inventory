module Kind
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

		resource :kind_model_data do
			desc "List all Kind Models"
			get do
				KindModel.all
			end

			desc "create a new Kind Model"
			params do
			  requires :name, type: String
			end
			post do
			  KindModel.create!({
			    name:params[:name]
			  })
			end

			desc "delete an Kind Model"
			params do
				requires :id, type: String
			end
			delete ':id' do
				KindModel.find(params[:id]).destroy!
			end

			desc "update an Kind Model name"
			params do
			  requires :id, type: String
			  requires :name, type:String
			end
			put ':id' do
			  KindModel.find(params[:id]).update({
			    name:params[:name]
			  })
			end
		end
	end
end