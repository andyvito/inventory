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

	class AreaRemoved < Grape::Entity
		expose :id
		expose :code
		expose :name
		expose :lead
		expose (:totalModels) { |r, options|   AreaModel.find(r.id).model_objects.where('name IS NOT NULL').count}
		expose (:delete) { |r, options|  AreaModel.find(r.id).model_objects.where('name IS NOT NULL').count == 0 ? true : false }
	end


end
