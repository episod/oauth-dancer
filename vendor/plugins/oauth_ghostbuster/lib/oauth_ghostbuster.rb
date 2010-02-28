# Log a dance move!
class GhostTrap
  @@log = []
  
  def GhostTrap.trap!(key, value)
    @@log << { key => value }
  end
  
  def GhostTrap.clear!
    @@log = [ "light is green" => "trap is clean" ]
  end
  
  def DanceMoves.ghosts
    @@log
  end
end

# These are all overrides for OAuth gems to make them more debuggable.
module OAuth::Client
  class Helper
    def signature_base_string(extra_options = {})
      basestring = OAuth::Signature.signature_base_string(@request, { :uri        => options[:request_uri],
                                                         :consumer   => options[:consumer],
                                                         :token      => options[:token],
                                                         :parameters => oauth_parameters}.merge(extra_options) )
     GhostTrap.trap! :signature_base_string, basestring
     basestring
    end

end

module OAuth::RequestProxy::Net
  module HTTP
    class HTTPRequest < OAuth::RequestProxy::Base
      def auth_header_params
        return nil unless request['Authorization'] && request['Authorization'][0,5] == 'OAuth'
        auth_params = request['Authorization']
        GhostTrap.trap! :inbound_auth_params, auth_params
      end
    end
  end
end

module OAuth
  module Signature
    # The signature base string is the most valuable piece of information while debugging
    def self.signature_base_string(request, options = {}, &block)
      basestring = self.build(request, options, &block).signature_base_string
      GhostTrap.trap! :signature_base_string, basestring
      basestring
    end
    
    # Knowing all variables and the signature allows you to understand everything.
    def self.sign(request, options = {}, &block)
      sig = self.build(request, options, &block).signature
      GhostTrap.trap! :signature, sig
      sig
    end
    
  end
end

# Hey, sometimes when you're testing you don't want to worry about silly stuff like this
module OAuth
  class Consumer
    CA_FILE = nil
  end
end

# Make the final, most reliable URL fully accessible.
class Net::HTTPRequest
  def public_request_uri(http)
    final_url = oauth_full_request_uri(http)
    GhostTrap.trap! :full_request_url, final_url
    final_url
  end
end

