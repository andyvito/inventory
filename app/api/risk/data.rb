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

module Risk
	class Data < Grape::API
		#helpers ApiHelpers::JSendSuccessFormatterHelper
    	#helpers ApiHelpers::JSendErrorFormatterHelper
		format :json
		rescue_from :all

		formatter :json, JSendSuccessFormatter
  		error_formatter :json, JSendErrorFormatter

		resource :risk_model_data do
			desc "List all Risks"
			get do
				present :risks, RiskModel.all, :with => RiskModel::Risk
			end

			desc "create a new Risk Model"
			params do
			  requires :code, type: String
			  requires :name, type: String
			end
			post do
				ActiveRecord::Base.transaction do
          			begin 
			  			present :risk, RiskModel.create!({code:params[:code],name:params[:name]}), :with => RiskModel::Risk
			  		rescue Exception => e
			            p e.message
			            ActiveRecord::Rollback
			            raise StandardError.new("error create a new risk")
		          	end
		        end
			end

			desc "delete an Risk Model"
			params do
				requires :riskid, type: String
			end
			delete ':riskid' do
				ActiveRecord::Base.transaction do
          			begin
						#Delete all models associated to this risk and ares
						@models = ModelObject.find_by_risk_model_id(params[:riskid])
						@areas = AreaModel.find_by_risk_model_id(params[:riskid]) 
						unless @models.nil?
							@models.destroy
						end 

						unless @areas.nil?
							@areas.destroy
						end
						
						present :risk, RiskModel.find_by_id(params[:riskid]).destroy!, :with => RiskModel::Risk
			  		rescue Exception => e
			            p e.message
			            ActiveRecord::Rollback
			            raise StandardError.new("error delete a risk")
		          	end
		        end
			end

			desc "update an Risk Model name"
			params do
			  requires :id, type: String
			  requires :name, type:String
			end
			put ':id' do
				ActiveRecord::Base.transaction do
          			begin				
					  RiskModel.find(params[:id]).update({name:params[:name]})
					  present :risk, RiskModel.find_by_id(params[:id]), :with => RiskModel::Risk
			  		rescue Exception => e
			            p e.message
			            ActiveRecord::Rollback
			            raise StandardError.new("error delete a risk")
		          	end
		        end
			end
		end



		resource :risk_delete do
			desc 'could a risk be deleted?.'
			params do
				requires :riskid, type: String
			end
			get do
				present :risk, RiskModel.find_by_id(params[:riskid]), :with => RiskModel::RiskRemoved
			end
		end

	end
end