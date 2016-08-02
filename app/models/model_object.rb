class ModelObject < ActiveRecord::Base
	belongs_to :area_model
	belongs_to :risk_model
end
