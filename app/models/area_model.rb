class AreaModel < ActiveRecord::Base
	belongs_to :risk_model
	has_many :model_objects, -> { order(name: :asc) }
end
