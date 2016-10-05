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
        m = ModelObject
            .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id")
            .select('model_objects.id, model_objects.code, model_objects.name, model_objects.len, model_objects.active, model_objects.risk_model_id, model_objects.area_model_id, last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed')
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

      desc "create a new Model"
      params do
        requires :area_id, type: String 
        requires :cat, type: String 
        requires :code, type: String 
        optional :comments, type: String 
        requires :curriculum, type: String 
        requires :description, type: String 
        requires :file_doc, type: String 
        optional :final_author, type: String 
        optional :final_dates, type: String 
        requires :initial_dates, type: String 
        requires :original_author, type: String 
        requires :is_qua, type: String 
        requires :kind, type: String 
        requires :len, type: String  
        optional :more_info, type: String 
        requires :name, type: String 
        requires :risk_id, type: String 
      end
      post do
        #get code of new model according to risk and area
        #idCount = ModelObject.where('risk_model_id = ?',params[:risk_id],params[:area_id]).count + 1
        #risk = RiskModel.where(params[:risk_id]).pluck(:code)
        #codeModel = risk + idCount.to_s
        #p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXx'
        #p codeModel

        #the model always begins in active mode and implementation mode and version = 1
        newModel = ModelObject.create!({code:params[:code], name:params[:name], description:params[:description], len:params[:len],
                                             cat:params[:cat], kind:params[:kind], version:'1', initial_dates:params[:initial_dates],
                                             final_dates:params[:final_dates], original_author:params[:original_author], final_author:params[:final_author], 
                                             more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                                             file_doc:params[:file_doc], active:true, is_qua:params[:is_qua], 
                                             risk_model_id:params[:risk_id], area_model_id:params[:area_id]})
  
        # Query the model to use the ModelShort middleware
        m = ModelObject
            .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id")
            .select('model_objects.id, model_objects.name, model_objects.len, model_objects.active, model_objects.risk_model_id, model_objects.area_model_id, last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed')
            .where('model_objects.code = ? AND model_objects.name = ? AND model_objects.id = ?',newModel.code,newModel.name,newModel.id)
            .order('model_objects.id')

        present :model, m, :with => ModelObject::ModelShort
      end


      desc "update an model"
      params do
        requires :modelid, type: String 
        requires :active, type: String  
        requires :area_id, type: String
        requires :cat, type: String
        requires :code, type: String 
        optional :comments, type: String
        requires :curriculum, type: String
        requires :description, type: String
        requires :file_doc, type: String
        optional :final_author, type: String
        optional :final_dates, type: String
        requires :initial_dates, type: String
        requires :len, type: String
        requires :name, type: String 
        requires :original_author, type: String
        requires :is_qua, type: String
        requires :kind, type: String
        optional :more_info, type: String
        requires :version, type: String
        requires :risk_id, type: String 
      end
      put ':modelid' do
        model = ModelObject.find(params[:modelid])
        model.update({code:params[:code], name:params[:name], description:params[:description], len:params[:len],  cat:params[:cat], kind:params[:kind], 
                      version:params[:version], initial_dates:params[:initial_dates],final_dates:params[:final_dates], original_author:params[:original_author], 
                      final_author:params[:final_author], more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                      file_doc:params[:file_doc], active:params[:active], is_qua:params[:is_qua], risk_model_id:params[:risk_id], area_model_id:params[:area_id]})
      end
    end


    resource :model_frecuency do
      desc "update an model's frecuency"
      params do
        requires :modelid, type: String
        requires :year_backtesting, type: String
        requires :month_backtesting, type: String
        requires :frecuency, type: String
        requires :met_validation, type: String#
        requires :met_hours_man, type: String
        requires :qua_hours_man, type: String
        requires :comment, type: String
        requires :cap_area, type: String
        requires :cap_qua, type: String
        requires :cap_total, type: String
      end
      put ':modelid' do
        model = ModelObject.find(params[:modelid])
        model.update({frecuency:params[:frecuency], met_validation:params[:met_validation], met_hours_man:params[:met_hours_man],
                      qua_hours_man:params[:qua_hours_man], cap_area:params[:cap_area], cap_qua:params[:cap_qua], 
                      cap_total:params[:cap_total]})

        #Devault values

        present :newBacktesting, BacktestHistoryModel.create({real_year:Date.today.year, real_month: Date.today.month, 
                                    next_year:params[:year_backtesting], next_month:params[:month_backtesting].to_i+1, 
                                    comentaries:params[:comment], model_object_id: params[:modelid]}), :with => BacktestHistoryModel::Backtest

      end
    end


    resource :model_clone do
      desc "clone an model's"
      params do
        requires :modelid, type: String
        requires :new_code, type: String
        requires :new_name, type: String
      end
      post do
        
        model = ModelObject.find(params[:modelid]).dup
        model.code = params[:new_code]
        model.name = params[:new_name]
        model.save

        present :model, model, :with => ModelObject::ModelClone

      end
    end



	end
end