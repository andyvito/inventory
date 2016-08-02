module ModelsByRisk
	module Entities
	  	class ModelObject < Grape::Entity
	    		expose :id
	    		expose :code
	    		expose :name
				expose :description
				#expose :len
				#expose :cat
				#expose :kind
				#expose :frecuency
				#expose :met_validation
				#expose :met_hours_man
				#expose :qua_hours_man
				#expose :cap_area
				#expose :cap_qua
				#expose :cap_total
				#expose :comments
				#expose :more_info
				#expose :curriculum
				#expose :documentation
				#expose :version 
				#expose :is_qua
				#expose :initial_dates
				#expose :original_author
				#expose :final_dates
				#expose :final_author
				#expose :active
				#expose :implementation
				expose :risk_model_id
				expose :area_model_id
	  	end
	end
end