module AreasByRisk
	class Data < Grape::API
	    helpers ApiHelpers::JSendSuccessFormatterHelper
	    helpers ApiHelpers::JSendErrorFormatterHelper

		format :json
		rescue_from :all
		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter


		helpers do
	      def current_risk
	        key = params[:riskid]
	        @current_risk ||= RiskModel.find(key)
	      end

	      #def authenticate!
	      #  error!({ "status" => "Fail", "error_message" => "Bad Key" }, 401) unless current_company
	      #end
	    end

		
		resource :areasByRisk do
			desc "List all Areas By Risks"
			params do
			  requires :riskid, type: String
			end
			get do
				areas = current_risk.area_models
				present :riskid, params[:riskid]
				present :name, current_risk[:name]
				present :areas, areas, :with => AreaModel::AreaLong
			end

			desc "create a new Area by Risk"
			params do
			  requires :riskid, type: String
			  requires :code, type: String
			  requires :name, type: String
			  requires :lead, type: String
			end
			post do
			  	ActiveRecord::Base.transaction do
			  		begin
						@curRisk = current_risk.area_models.create!({code:params[:code],name:params[:name], lead:params[:lead]})   
						present :riskid, params[:riskid]
						present :name, current_risk[:name]
						present :new_area, @curRisk, :with => AreaModel::AreaLong
					rescue Exception => e
						p e.message
						ActiveRecord::Rollback
						raise StandardError.new("error create new area in risk")
			   		end
			   	end
			end

			desc "delete an Area by Risk"
			params do
				requires :riskid, type: String
				requires :areaid, type: String
			end
			delete ':riskid' do
			  	ActiveRecord::Base.transaction do
			  		begin
						@models = ModelObject.find_by_area_model_id(params[:areaid])
						unless @models.nil?
							@models.destroy
						end 

						area = current_risk.area_models.find(params[:areaid])
						area.destroy!

						present :area, area, :with => AreaModel::AreaLong
					rescue Exception => e
						p e.message
						ActiveRecord::Rollback
						raise StandardError.new("error delete area in risk")
					end
			   	end
			end

			desc "update an Area by Risk"
			params do
			  requires :riskid, type: String
			  requires :areaid, type: String
			  requires :name, type:String
			  requires :lead, type:String
			end
			put ':riskid' do
			  	ActiveRecord::Base.transaction do
			  		begin				
						area = current_risk.area_models.find(params[:areaid])
						area.update({name:params[:name],lead:params[:lead]})
						present :area, area, :with => AreaModel::AreaLong
			  		rescue Exception => e
						p e.message
						ActiveRecord::Rollback
						raise StandardError.new("error update area in risk")
					end
			   	end
			end	
		end

		resource :area_delete do
			desc 'could an area be deleted?.'
			params do
				requires :riskid, type: String
				requires :areaid, type: String
			end
			get do
				present :area, AreaModel.where('risk_model_id = ? AND id = ?',params[:riskid],params[:areaid])[0], :with => AreaModel::AreaRemoved
			end
		end		


	end
end