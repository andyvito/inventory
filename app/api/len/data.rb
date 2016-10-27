module Len
	class Data < Grape::API
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :len_distinct do
			desc "List all distinct lens"
			get do
				present :lens, ModelObject.uniq.order('len').where("len IS NOT NULL").pluck(:len)
			end
		end
	end
end