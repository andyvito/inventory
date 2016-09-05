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
            .select('model_objects.id, model_objects.name, model_objects.len, model_objects.active, model_objects.risk_model_id, model_objects.area_model_id, last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed')
            .order('model_objects.id')
 
        present :models, m, :with => ModelObject::ModelShort
			end
		end

    resource :model do
      desc "Get Model By Id"
      params do
        requires :id, type: String
      end
      get do
        present :model, ModelObject.find(params[:id]), :with => ModelObject::ModelLarge
      end


      desc "update an model"
      params do
        requires :modelid, type: String
        requires :active, type: String #
        requires :area_id, type: String # 
        requires :cap_area, type: String #
        requires :cap_qua, type: String #
        requires :cap_total, type: String #
        requires :cat, type: String #
        requires :code, type: String #
        requires :curriculum, type: String #
        requires :final_author, type: String #
        optional :final_dates, type: String #
        requires :frecuency, type: String#
        optional :initial_dates, type: String #
        requires :len, type: String #
        requires :met_hours_man, type: String #
        requires :met_validation, type: String #
        requires :name, type: String #
        requires :original_author, type: String #
        requires :qua_hours_man, type: String #
        requires :risk_id, type: String  #   
        

        requires :description, type: String #
        requires :kind, type: String #
        optional :comments, type: String #
        optional :more_info, type: String #
        requires :file_doc, type: String #
        requires :is_qua, type: String #
        requires :version, type: String #
        
           
               

      end
      put ':modelid' do
        model = ModelObject.find(params[:modelid])
        model.update({code:params[:code], name:params[:name], description:params[:description], len:params[:len],  cat:params[:cat], kind:params[:kind], 
                      frecuency:params[:frecuency], met_validation:params[:met_validation], met_hours_man:params[:met_hours_man], 
                      qua_hours_man:params[:qua_hours_man], cap_area:params[:cap_area], cap_qua:params[:cap_qua], cap_total:params[:cap_total], 
                      version:params[:version], initial_dates:params[:initial_dates],final_dates:params[:final_dates], original_author:params[:original_author], 
                      final_author:params[:final_author], more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                      file_doc:params[:file_doc], active:params[:active], is_qua:params[:is_qua], risk_model_id:params[:risk_id], area_model_id:params[:area_id]})
      end
    end


	end
end