module Type
	class Data < Grape::API
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper    
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :type_distinct do
			desc "List all distinct types"
			get do
				present :types, ModelObject.uniq.order('cat').where("cat IS NOT NULL").pluck(:cat)
			end
		end
	end
end
