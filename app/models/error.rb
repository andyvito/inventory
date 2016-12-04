class Error < ActiveRecord::Base

	class Error < Grape::Entity
		expose :code
		expose :message
	end



end
