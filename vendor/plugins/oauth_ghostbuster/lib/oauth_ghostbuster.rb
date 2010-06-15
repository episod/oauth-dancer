# Trap a ghost!
class GhostTrap
  @@log = []
  @@trapper_keeper = {}

  def GhostTrap.trap!(key, value)
    @@log << { key => value }
  end

  def GhostTrap.clear!(silence = false)
    unless silence
      @@log = [ "light is green" => "trap is clean" ]
    else
      @@log = []
    end
  end

  def GhostTrap.ghosts
    @@log
  end

  def GhostTrap.keep!(key, value)
    # puts "Storing #{key} : #{value}"
    @@trapper_keeper[key] = value
  end

  def GhostTrap.pluck!(key)
    # puts "Getting #{key} : #{@@trapper_keeper[key]}"
    v = @@trapper_keeper[key]
    @@trapper_keeper[key] = nil
    v
  end

end

# These are all overrides for OAuth gems to make them more debuggable.
# This could all be done more cleanly. But it isn't. So there.


module OAuth::Client
  class Helper
    def signature_base_string(extra_options = {})
      GhostTrap.trap! :oauth_parameters, oauth_parameters
      basestring = OAuth::Signature.signature_base_string(@request, { :uri => options[:request_uri],
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

module OAuth::RequestProxy
  class Base
    def signature_base_string
      base = [method, normalized_uri, normalized_parameters]
      basestring = base.map { |v| escape(v) }.join("&")
      GhostTrap.trap! :signature_base_string, basestring
      basestring
    end
  end
end



module OAuth::Signature
  class Base
    def secret
      s = "#{escape(consumer_secret)}&#{escape(token_secret)}"
      GhostTrap.trap! :signing_secret, s
      s
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
    def token_request(http_method, path, token = nil, request_options = {}, *arguments)
      response = request(http_method, path, token, request_options, *arguments)
      GhostTrap.trap! :response_body, response.body
      GhostTrap.trap! :response_code, response.code.to_i
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

  # The RequestToken is used for the initial Request.
  # This is normally created by the Consumer object.
  class RequestToken < ConsumerToken
    def has_xoauth_request_auth_url?
      params[:xoauth_request_auth_url] ? true : false
    end

    def xoauth_request_auth_url
      params[:xoauth_request_auth_url]
    end

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
    # TODO This will get better.
    def initialize(problem, request = nil, params = {})
      super(request)
      GhostTrap.trap! :oauth_problem, problem
      GhostTrap.trap! :oauth_problem_params, params
      @problem = problem
      @params  = params
      puts @problem
      puts @params.inspect
    end
  end
end

module OAuth
  class TwoLeggedMockToken < OAuth::ConsumerToken
    def request(http_method, path, *arguments)
      request_uri = URI.parse(path)
      site_uri = consumer.uri
      is_service_uri_different = (request_uri.absolute? && request_uri != site_uri)
      consumer.uri(request_uri) if is_service_uri_different
      @response = super(http_method, path, *arguments)
      # NOTE: reset for wholesomeness? meaning that we admit only AccessToken service calls may use different URIs?
      # so reset in case consumer is still used for other token-management tasks subsequently?
      consumer.uri(site_uri) if is_service_uri_different
      @response
    end
  end
end

module Net
  class HTTP
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        unless use_ssl?
          req.proxy_basic_auth proxy_user(), proxy_pass()
        end
      end
      req.set_body_internal body
      GhostTrap.trap! :body_internal, req.body
      request_headers = []
      req.each_header{|k,v|request_headers << "#{k}: #{v}"}
      GhostTrap.trap! :request_headers, request_headers.join("\n")
      begin_transport req
        req.exec @socket, @curr_http_version, edit_path(req.path)
        begin
          res = HTTPResponse.read_new(@socket)
        end while res.kind_of?(HTTPContinue)
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
      end_transport req, res
      response_headers = []
      res.each_header{|k,v|response_headers << "#{k}: #{v}"}
      GhostTrap.trap! :response_headers, response_headers.join("\n")
      res
    rescue => exception
      D "Conn close because of error #{exception}"
      # backporting fix - TS
      @socket.close if @socket and not @socket.closed?
      raise exception
    end
  end
end

module OAuth
  module Helper

    # Generate a random key of up to +size+ bytes. The value returned is Base64 encoded with non-word
    # characters removed.
    def generate_key(size=32)
      alternate_nonce = GhostTrap.pluck!(:oauth_nonce)
      return alternate_nonce if alternate_nonce
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end

    alias_method :generate_nonce, :generate_key

    def generate_timestamp #:nodoc:
      alternate_timestamp = GhostTrap.pluck!(:oauth_timestamp)
      return alternate_timestamp if alternate_timestamp
      Time.now.to_i.to_s
    end
  end
end