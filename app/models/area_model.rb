class AreaModel < ActiveRecord::Base
	belongs_to :risk_model
	has_many :model_objects, -> { order(name: :asc) }

	class AreaLong < Grape::Entity
  		expose :id
  		expose :name
      expose :lead
	end

	class AreaShort < Grape::Entity
		expose :id
		expose :name
	end
end
