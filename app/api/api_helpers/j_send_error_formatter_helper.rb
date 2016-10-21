module ApiHelpers
  
 
	module JSendErrorFormatterHelper
	  def self.call message, backtrace, options, env
	    # This uses convention that a error! with a Hash param is a jsend "fail", otherwise we present an "error"
	    if message.is_a?(Hash)
	      { :status => 'fail', :data => message }.to_json
	    else
	      { :status => 'error', :message => message }.to_json
	    end
	  end
	end #end module



end