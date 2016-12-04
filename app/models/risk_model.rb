class RiskModel < ActiveRecord::Base
	has_many :area_models, -> { order(name: :asc) } , :dependent => :destroy
	has_many :model_objects, -> { order(name: :asc) }

	class Risk < Grape::Entity
		expose :id
		expose :code
		expose :name
	end

	class RiskRemoved < Grape::Entity
		expose :id
		expose :code
		expose :name
		expose (:totalAreas)  { |r, options|   RiskModel.find(r.id).area_models.count}
		expose (:totalModels) { |r, options|   RiskModel.find(r.id).model_objects.where('name IS NOT NULL').count}
		expose (:delete) { |r, options|  RiskModel.find(r.id).area_models.count == 0 && RiskModel.find(r.id).model_objects.where('name IS NOT NULL').count == 0 ? true : false }
	end


end
