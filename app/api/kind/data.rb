module Kind
	class Data < Grape::API
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper

		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :kind_distinct do
			desc "List all distinct kinds"
			get do
				present :kinds, ModelObject.uniq.order('kind').where("kind IS NOT NULL").pluck(:kind)
			end
		end
	end
end
