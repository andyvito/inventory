module ApiHelpers
  
	module JSendSuccessFormatterHelper
	  def self.call object, env
	    { :status => 'success', :code => 200, :data => object }.to_json
	  end
	end #end module
 
	module JSendErrorFormatter
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