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


module Model
	class Data < Grape::API
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :models_data do
			desc "List all Models"
			get do
				#present :models, ModelObject.includes(:risk_model, :area_model), :with => ModelObject::ModelShort
        #m = ModelObject.includes(:risk_model, :area_model).joins(:backtest_history_models).where("backtest_history_models.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = backtest_history_models.model_object_id)")
        m = ModelObject
            .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id")
            .select('model_objects.id, model_objects.name, model_objects.len, model_objects.active, model_objects.next_backtest_year, model_objects.next_backtest_month, model_objects.risk_model_id, model_objects.area_model_id, last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed')
            .order('model_objects.id')
 
            #m = ModelObject
            #.joins("LEFT JOIN backtest_history_models ON backtest_history_models.model_object_id = model_objects.id")
            #.where("backtest_history_models.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = backtest_history_models.model_object_id LIMIT 1)")
            #.select('model_objects.id, model_objects.name, model_objects.len, model_objects.active, model_objects.next_backtest_year, model_objects.next_backtest_month, model_objects.risk_model_id, model_objects.area_model_id, backtest_history_models.validate_year, backtest_history_models.validate_month, backtest_history_models.real_year, backtest_history_models.real_month, backtest_history_models.next_year, backtest_history_models.next_month, backtest_history_models.comentaries, backtest_history_models.result')
            #.order('model_objects.id')
        present :models, m, :with => ModelObject::ModelShort
			end

		end
	end
end