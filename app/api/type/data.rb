module Type
	class Data < Grape::API

		#https://www.sitepoint.com/build-great-apis-grape/
		format :json
		rescue_from :all

		error_formatter :json, lambda { |message,backtrace, options, env|
			{
				status: 'failed',
				message: message,
				error_code: 123 #TODO: remove hardcoded error code and put dynamic
			}
		}

		resource :type_model_data do
			desc "List all Type Models"
			get do
				TypeModel.all
			end

			desc "create a new Type Model"
			params do
			  requires :name, type: String
			end
			post do
			  TypeModel.create!({
			    name:params[:name]
			  })
			end

			desc "delete an Type Model"
			params do
				requires :id, type: String
			end
			delete ':id' do
				TypeModel.find(params[:id]).destroy!
			end

			desc "update an Type Model name"
			params do
			  requires :id, type: String
			  requires :name, type:String
			end
			put ':id' do
			  TypeModel.find(params[:id]).update({
			    name:params[:name]
			  })
			end
		end
	end
end