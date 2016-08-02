require "entities"

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


module AreasByRisk
	class Data < Grape::API
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
				present :areas, areas, :with => Entities::AreaModel
			end

			desc "create a new Area by Risk"
			params do
			  requires :riskid, type: String
			  requires :name, type: String
			  requires :lead, type: String
			end
			post do
			  present :riskid, params[:riskid]
			  present :name, current_risk[:name]
			  present :new_area, current_risk.area_models.create!({name:params[:name], lead:params[:lead]}), :with => Entities::RiskModel
			end

			desc "delete an Area by Risk"
			params do
				requires :riskid, type: String
				requires :areaid, type: String
			end
			delete ':riskid' do
				area = current_risk.area_models.find(params[:areaid])
				area.destroy!
				present :area, area, :with => Entities::AreaModel
			end

			desc "update an Area by Risk"
			params do
			  requires :riskid, type: String
			  requires :areaid, type: String
			  requires :name, type:String
			  requires :lead, type:String
			end
			put ':riskid' do
			  area = current_risk.area_models.find(params[:areaid])
			  area.update({name:params[:name],lead:params[:lead]})
			  present :area, area, :with => Entities::AreaModel
			  
			end


			
		end
	end
end