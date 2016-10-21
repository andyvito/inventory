class Configuration < ActiveRecord::Base

	class Config < Grape::Entity
		expose :name
		expose :value
    end

    class DateServer < Grape::Entity
    	expose :year
    	expose :month
    	expose :date
    end

end
