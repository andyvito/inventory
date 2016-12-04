module Model
	class Data < Grape::API
    helpers ApiHelpers::BacktestingHelper
    helpers ApiHelpers::JSendSuccessFormatterHelper
    helpers ApiHelpers::JSendErrorFormatterHelper
    #before { test_function }

		format :json
		rescue_from :all
		formatter :json, JSendSuccessFormatter
  	error_formatter :json, JSendErrorFormatter

		resource :models_data do
			desc "List all Models"
			get do
        m = ModelObject
            .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id "+
                  "INNER JOIN risk_models AS r ON model_objects.risk_model_id = r.id INNER JOIN area_models AS a ON model_objects.area_model_id = a.id")
            .select("model_objects.id, model_objects.consecutive, model_objects.current_version, model_objects.name, model_objects.len, model_objects.active, model_objects.risk_model_id, model_objects.area_model_id, r.code AS 'rCode', a.code AS 'aCode', " +
                    "last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed")
            .order('model_objects.id')
 

        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

        present :models, m, :with => ModelObject::ModelShort, year: current_year, month: current_month
			end
		end

    resource :model do
      desc "Get Model By Id"
      params do
        requires :id, type: String
      end
      get do
        current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
        current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

        m = ModelObject
            .joins("INNER JOIN risk_models AS r ON model_objects.risk_model_id = r.id INNER JOIN area_models AS a ON model_objects.area_model_id = a.id")
            .select("model_objects.*, r.code AS 'rCode', a.code AS 'aCode'")
            .where('model_objects.id = ?',params[:id])[0]

        present :model, m, :with => ModelObject::ModelLarge, year: current_year, month: current_month
      end

      desc "create a new Model"
      params do
        requires :area_id, type: String 
        requires :cat, type: String 
        optional :comments, type: String 
        requires :curriculum, type: String 
        requires :description, type: String 
        requires :file_doc, type: String 
        requires :is_qua, type: String 
        requires :kind, type: String 
        requires :len, type: String  
        optional :more_info, type: String 
        requires :name, type: String 
        requires :risk_id, type: String 
      end
      post do
        ActiveRecord::Base.transaction do
          begin 

            emptyModel = ModelObject.where('name IS NULL AND risk_model_id = ? AND area_model_id = ?',params[:risk_id],params[:area_id]).order('id, consecutive ASC').pluck('id', 'consecutive')
            unless (emptyModel.blank?)
              newModel = ModelObject.find(emptyModel[0][0])
              newModel.update({name:params[:name], description:params[:description], len:params[:len], cat:params[:cat], kind:params[:kind], 
                          more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                          file_doc:params[:file_doc], active:1, is_qua:params[:is_qua]}) 
            else
              consecutive = ModelObject.where('risk_model_id = ? AND area_model_id = ?',params[:risk_id],params[:area_id]).maximum("consecutive").to_i + 1

              #the model always begins in active mode and implementation mode and version = 1
              newModel = ModelObject.create({consecutive:consecutive, name:params[:name], description:params[:description], len:params[:len],
                                                   cat:params[:cat], kind:params[:kind], more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                                                   file_doc:params[:file_doc], active:1, is_qua:params[:is_qua], risk_model_id:params[:risk_id], area_model_id:params[:area_id]})

            end

            #TODO: Try make this without make the query. In another words, use the ModelObject::ModelShort (or another entity compatible with FE) without re-query  
            # Query the model to use the ModelShort middleware
            m = ModelObject
                .joins("LEFT JOIN backtest_history_models AS last ON last.id = (SELECT MAX(b.id) FROM backtest_history_models b GROUP BY b.model_object_id HAVING b.model_object_id = last.model_object_id) AND last.model_object_id = model_objects.id "+
                      "INNER JOIN risk_models AS r ON model_objects.risk_model_id = r.id INNER JOIN area_models AS a ON model_objects.area_model_id = a.id")
                .select("model_objects.id, model_objects.consecutive, model_objects.current_version, model_objects.name, model_objects.len, model_objects.active, model_objects.risk_model_id, model_objects.area_model_id, r.code AS 'rCode', a.code AS 'aCode', " +
                        "last.validate_year, last.validate_month, last.real_year, last.real_month, last.next_year, last.next_month, last.comentaries, last.result, last.id AS backtest_id, last.months_delayed")
                .where('model_objects.consecutive = ? AND model_objects.id = ?',newModel.consecutive,newModel.id)
                .order('model_objects.id')


            current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
            current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i

            present :model, m, :with => ModelObject::ModelShort, year: current_year, month: current_month

          rescue Exception => e
            p e.message
            ActiveRecord::Rollback
            raise StandardError.new("error create a new model")
          end
        end
      end


      desc "update an model"
      params do
        requires :modelid, type: String 
        requires :active, type: String  
        requires :area_id, type: String
        requires :cat, type: String
        optional :comments, type: String
        requires :curriculum, type: String
        requires :description, type: String
        requires :file_doc, type: String
        requires :len, type: String
        requires :name, type: String 
        requires :is_qua, type: String
        requires :kind, type: String
        optional :more_info, type: String
        requires :risk_id, type: String         
      end
      put ':modelid' do
        ActiveRecord::Base.transaction do
          begin 

            model = ModelObject.find(params[:modelid])
            temp_active = model.active

            if (model.risk_model_id.to_i != params[:risk_id].to_i || model.area_model_id.to_i != params[:area_id].to_i) 
              emptyModel = ModelObject.where('name IS NULL AND risk_model_id = ? AND area_model_id = ?',params[:risk_id],params[:area_id]).order('id, consecutive ASC').pluck('id', 'consecutive')
              unless (emptyModel.blank?)
                consecutive = emptyModel[0][1]
                modelClone = ModelObject.find(emptyModel[0][0])
                modelClone.consecutive = consecutive
                modelClone.name = params[:name]
                modelClone.description = params[:description]
                modelClone.len = params[:len]
                modelClone.cat = params[:cat]
                modelClone.kind = params[:kind]
                modelClone.comments = params[:comments]
                modelClone.more_info = params[:more_info]
                modelClone.curriculum = params[:curriculum]
                modelClone.file_doc = params[:file_doc]
                modelClone.is_qua = params[:is_qua]
                modelClone.active = params[:active]
                modelClone.risk_model_id = params[:risk_id]
                modelClone.area_model_id = params[:area_id]
                modelClone.save
              else
                consecutive = ModelObject.where('risk_model_id = ? AND area_model_id = ?',params[:risk_id],params[:area_id]).maximum("consecutive").to_i + 1
                modelClone = model.dup
                
                modelClone.update({consecutive:consecutive,name:params[:name], description:params[:description], len:params[:len], cat:params[:cat], kind:params[:kind], 
                            more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                            file_doc:params[:file_doc], active:params[:active], is_qua:params[:is_qua], risk_model_id:params[:risk_id], area_model_id:params[:area_id]})          
              end

              if (modelClone.active == 1)
                updateReportFromChangeRisk(model.id, modelClone.id)
              end

              backtest = BacktestHistoryModel.where('model_object_id = ?',params[:modelid])
              unless (backtest.blank?)
                backtest.update_all(model_object_id: modelClone.id.to_s)
              end
              version = ModelVersion.where('model_object_id = ?',params[:modelid])
              unless (version.blank?)
                version.update_all(model_object_id: modelClone.id.to_s)
              end

              lastBacktestByModelId = ApiHelpers::BacktestingHelper.getLastBacktestByModelId(modelClone.id)
              backtest = BacktestHistoryModel.new
              backtest.validate_year = lastBacktestByModelId.validate_year
              backtest.validate_month = lastBacktestByModelId.validate_month
              current_year = Configuration.where('name = ?', 'current_year').pluck('value')[0].to_i
              current_month = Configuration.where('name = ?', 'current_month').pluck('value')[0].to_i
              backtest.real_year = current_year
              backtest.real_month = current_month
              backtest.next_year = lastBacktestByModelId.next_year
              backtest.next_month = lastBacktestByModelId.next_month
              backtest.months_delayed = lastBacktestByModelId.months_delayed

              riskName = RiskModel.where('id = ?', model.risk_model_id).pluck('name')[0]
              areaName = AreaModel.where('id = ?', model.area_model_id).pluck('name')[0]
              backtest.comentaries = 'Este modelo fue trasladado desde el Riesgo (id:' + params[:risk_id] + ') '+ riskName +' y el Área (id:' + params[:area_id] +') ' + areaName
              backtest.model_object_id = lastBacktestByModelId.id
              backtest.save

              oldName = model.name
              model.update({name: nil, description: nil, len: nil, cat: nil, kind: nil, 
                          current_version:nil, more_info:nil, comments:nil, curriculum:nil, file_doc:nil, active:nil, is_qua:nil,
                          frecuency:nil, met_validation:nil, met_hours_man:nil, qua_hours_man:nil, cap_area:nil, cap_qua:nil, 
                          cap_total:nil}) 
              
              updateReportFromActive(temp_active, modelClone.active, modelClone.id)

              present :modelTransfer, modelClone, :with => ModelObject::ModelClone

            else
              model.update({name:params[:name], description:params[:description], len:params[:len], cat:params[:cat], kind:params[:kind], 
                            more_info:params[:more_info], comments:params[:comments], curriculum:params[:curriculum], 
                            file_doc:params[:file_doc], active:params[:active], is_qua:params[:is_qua]})
             updateReportFromActive(temp_active, model.active, model.id)
             present :model, model, :with => ModelObject::ModelClone
            end
          
          rescue Exception => e
            p e.message
            ActiveRecord::Rollback
            raise StandardError.new("error update model")
          end
        end
      end
    end


    resource :model_frecuency do
      desc "update an model's frecuency"
      params do
        requires :modelid, type: String
        requires :date_backtest, type: String
        requires :frecuency, type: String
        requires :met_validation, type: String#
        requires :met_hours_man, type: String
        requires :qua_hours_man, type: String
        requires :comment, type: String
        requires :cap_area, type: String
        requires :cap_qua, type: String
        requires :cap_total, type: String
        requires :author, type: String
        requires :date_created, type: String
      end
      put ':modelid' do
        ActiveRecord::Base.transaction do
          begin 
            date_backtest = Date.parse params[:date_backtest]
            date_created = Date.parse params[:date_created]

            model = ModelObject.find(params[:modelid])
            curVersion = model.current_version.nil? ? 1 : model.current_version.to_i + 1
            model.update({current_version:curVersion, frecuency:params[:frecuency], 
                          met_validation:params[:met_validation], met_hours_man:params[:met_hours_man],
                          qua_hours_man:params[:qua_hours_man], cap_area:params[:cap_area], cap_qua:params[:cap_qua], 
                          cap_total:params[:cap_total]}){{}}

            version = ModelVersion.new
            version.version = curVersion
            version.new_date = params[:date_created]
            version.author = params[:author]
            version.comments = params[:comment]
            version.model_object_id = model.id
            version.save

            model_last_backtest = BacktestHistoryModel.where('model_object_id = ?',model.id).last

            present :newBacktesting, BacktestHistoryModel.create({real_year:Date.today.year, real_month: Date.today.month, 
                                        next_year:date_backtest.year, next_month:date_backtest.month, 
                                        model_object_id: params[:modelid]}), :with => BacktestHistoryModel::Backtest

            updateReportFromFrecuency(date_backtest, model_last_backtest, model.id)

          rescue Exception => e
            p e.message
            ActiveRecord::Rollback
            raise StandardError.new(e.message)
          end
        end
      end
    end


    resource :model_clone do
      desc "clone an model's"
      params do
        requires :modelid, type: String
        requires :new_name, type: String
        requires :date, type: String
        requires :author, type: String
      end
      post do
        ActiveRecord::Base.transaction do
          begin 

            model = ModelObject.find(params[:modelid])
            emptyModel = ModelObject.where('name IS NULL AND risk_model_id = ? AND area_model_id = ?',model.risk_model_id,model.area_model_id).order('id, consecutive ASC').pluck('id', 'consecutive')
            unless (emptyModel.blank?)
              consecutive = emptyModel[0][0]
              new_model = ModelObject.find(emptyModel[0][1])
              new_model.description = model.description
              new_model.len = model.len
              new_model.cat = model.cat
              new_model.kind = model.kind
              new_model.comments = model.comments
              new_model.more_info = model.more_info
              new_model.curriculum = model.curriculum
              new_model.file_doc = model.file_doc
              new_model.is_qua = model.is_qua
              new_model.active = model.active
              new_model.risk_model_id = model.risk_model_id
              new_model.area_model_id = model.area_model_id
              model = new_model.dup
            else
              consecutive = ModelObject.where('risk_model_id = ? AND area_model_id = ?',model.risk_model_id,model.area_model_id).maximum("consecutive").to_i + 1
              new_model = model.dup
              new_model.frecuency = nil
              new_model.met_validation = nil
              new_model.met_hours_man = nil
              new_model.qua_hours_man = nil
              new_model.cap_area = nil
              new_model.cap_qua = nil
              new_model.cap_total = nil
            end

            new_model.name = params[:new_name]
            new_model.consecutive = consecutive.to_s
            new_model.save
            
            present :model, new_model, :with => ModelObject::ModelClone
          rescue Exception => e
            p e.message
            ActiveRecord::Rollback
            raise StandardError.new("error clone a model")
          end
        end
      end
    end



	end
end