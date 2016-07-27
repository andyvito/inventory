class RiskModel < ActiveRecord::Base
	has_many :area_models, -> { order(name: :asc) } , :dependent => :destroy
end
