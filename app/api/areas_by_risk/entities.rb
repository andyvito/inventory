module AreasByRisk
	module Entities
    	class RiskModel < Grape::Entity
      		expose :id
      		expose :name
    	end

    	class AreaModel < Grape::Entity
      		expose :id
      		expose :name
          expose :lead
    	end
  	end
end