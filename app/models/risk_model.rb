class RiskModel < ActiveRecord::Base
	has_many :area_models, -> { order(name: :asc) } , :dependent => :destroy
	has_many :model_objects, -> { order(name: :asc) }
end
