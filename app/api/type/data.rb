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


module Type
	class Data < Grape::API
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
