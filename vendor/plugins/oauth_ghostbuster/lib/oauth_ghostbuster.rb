# Trap a ghost!
class GhostTrap
  @@log = []
  
  def GhostTrap.trap!(key, value)
    @@log << { key => value }
  end
  
  def GhostTrap.clear!
    @@log = [ "light is green" => "trap is clean" ]
  end
  
  def GhostTrap.ghosts
    @@log
  end
end

# These are all overrides for OAuth gems to make them more debuggable.
# This could all be done more cleanly. But it isn't. So there.
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
  
  def token_request(http_method, path, token = nil, request_options = {}, *arguments)
    response = request(http_method, path, token, request_options, *arguments)
    GhostTrap.trap! :response, response
    GhostTrap.trap! :response_body, response.body
    GhostTrap.trap! :response_code, response_code.code.to_i
    case response.code.to_i

    when (200..299)
      GhostTrap.trap! :response_disposition, "success"
      # symbolize keys
      # TODO this could be considered unexpected behavior; symbols or not?
      # TODO this also drops subsequent values from multi-valued keys
      CGI.parse(response.body).inject({}) do |h,(k,v)|
        h[k.to_sym] = v.first
        h[k]        = v.first
        h
      end
    when (300..399)
      GhostTrap.trap! :response_disposition, "redirected"      
      # this is a redirect
      response.error!
    when (400..499)
      GhostTrap.trap! :response_disposition, "unauthorized, unfound, bad request, or otherwise. think deeply."      
      raise OAuth::Unauthorized, response
    else
      GhostTrap.trap! :response_disposition, "something unusual happened."
      response.error!
    end
  end
  
  # Return the signature_base_string
  def signature_base_string(request, token = nil, request_options = {})
    basestring = request.signature_base_string(http, self, token, options.merge(request_options))
    GhostTrap.trap! :signature_base_string, basestring
    basestring
  end
  
end

class Net::HTTPRequest
  # Make the final, most reliable URL fully accessible.
  def public_request_uri(http)
    final_url = oauth_full_request_uri(http)
    final_url
  end
  
  def signature_base_string(http, consumer = nil, token = nil, options = {})
    options = { :request_uri      => oauth_full_request_uri(http),
                :consumer         => consumer,
                :token            => token,
                :scheme           => 'header',
                :signature_method => nil,
                :nonce            => nil,
                :timestamp        => nil }.merge(options)

    basestring = OAuth::Client::Helper.new(self, options).signature_base_string
    GhostTrap.trap! :signature_base_string, basestring
    basestring
  end
  
  def oauth_full_request_uri(http)
    uri = URI.parse(self.path)
    uri.host = http.address
    uri.port = http.port

    if http.respond_to?(:use_ssl?) && http.use_ssl?
      uri.scheme = "https"
    else
      uri.scheme = "http"
    end
    GhostTrap.trap! :full_request_url, uri.to_s
    uri.to_s
  end
  
  def set_oauth_header
    self['Authorization'] = @oauth_helper.header
    GhostTrap.trap! :authorization_header, self['Authorization']
    self['Authorization']
  end
  
  def set_oauth_query_string
    oauth_params_str = @oauth_helper.oauth_parameters.map { |k,v| [escape(k), escape(v)] * "=" }.join("&")

    uri = URI.parse(path)
    if uri.query.to_s == ""
      uri.query = oauth_params_str
    else
      uri.query = uri.query + "&" + oauth_params_str
    end

    @path = uri.to_s

    @path << "&oauth_signature=#{escape(oauth_helper.signature)}"
    GhostTrap.trap! :oauth_query_string, @path
    @path
  end
  
end

module OAuth
  class Problem < OAuth::Unauthorized
    def initialize(problem, request = nil, params = {})
      super(request)
      GhostTrap.trap! :oauth_problem, problem
      GhostTrap.trap! :oauth_problem_params, params
      @problem = problem
      @params  = params
    end
  end
end


