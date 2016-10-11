class Configuration < ActiveRecord::Base

	class Config < Grape::Entity
		expose :name
		expose :value
    end

end
