class ApiRequest < PassiveRecord::Base
  define_fields :access_token_id, 
                :headers, 
                :method,
                :resource_url,
                :signature_base_string, 
                :signature,
                :signing_secret, 
                :authorization_header,
                :postdata,
                :response_body,
                :response_headers,
                :response_code,
                :response_message,
                :service_provider_id
                    
  def ApiRequest.request_content_types
    [ "application/x-www-form-urlencoded", "application/json", "text/xml"]
  end
  
  def response_format
    my_format = ""
    if self.response_headers
      type = self.response_headers['Content-Type'] || self.response_headers['content-type']
      if type =~ /json/
        my_format = :json
      elsif type =~ /xml/
        my_format = :xml
      else
        my_format = :text
      end
    else
      my_format = :text
    end
    my_format
  end
  
  def postdata(want_pristine = false)
    if want_pristine
      @postdata
    elsif self.headers['Contnent-Type'] =~ /url/
      parsed = CGI.parse(@postdata)
    else
      @postdata
    end
  end
  
  def ApiRequest.make_request(url, model_access_token, options = {})
    GhostTrap.clear!
    api_request = ApiRequest.new(
                    { :resource_url => url, 
                      :access_token_id => model_access_token.id,
                      :method => options[:method] || :get,
                      :postdata => options[:postdata],
                      :headers => options[:headers] || {}, 
                    })
    if api_request.postdata
      GhostTrap.trap! :request_postdata, api_request.postdata
    end
    api_request.service_provider_id = model_access_token.service_provider_id
    consumer = api_request.service_provider.to_oauth_consumer
    access_token = model_access_token.to_oauth_access_token
    api_request.method = api_request.method.to_s.downcase.to_sym
    response = ""
    
    PROXY_CONFIG.apply(:read_timeout => 15) do 
      if [:post, :put, :delete].include?(api_request.method)
        response = access_token.request(api_request.method, api_request.resource_url, api_request.postdata, api_request.headers)
      else
        response = access_token.request(api_request.method, api_request.resource_url, api_request.headers)
      end
    end
    api_request.wrangle_response(response)
    api_request
  end

  def ApiRequest.make_two_legged_request(url, service_provider, options = {})
    GhostTrap.clear!
    api_request = ApiRequest.new(
                    { :resource_url => url, 
                      :method => options[:method] || :get,
                      :postdata => options[:postdata],
                      :headers => options[:headers] || {},
                      :service_provider_id => service_provider.id 
                    })
    if api_request.postdata
      GhostTrap.trap! :request_postdata, api_request.postdata
    end
    
    consumer = api_request.service_provider.to_oauth_consumer
    api_request_method = api_request.method.to_s.downcase.to_sym
    response = ""
    two_legged_token = service_provider.to_two_legged_token(consumer)
    
    # A two-legged request is just a request from a consumer with no access token (and no oauth_token_secret)
    PROXY_CONFIG.apply(:read_timeout => 15) do 
      if [:post, :put, :delete].include?(api_request.method)
        response = two_legged_token.request(api_request.method, api_request.resource_url, api_request.postdata, api_request.headers)
      else
        response = two_legged_token.request(api_request.method, api_request.resource_url, api_request.headers)          
      end
    end
    api_request.wrangle_response(response)    
    api_request
  end

  def access_token
    @access_token ||= AccessToken.find(self.access_token_id)
  end
  
  def service_provider
    @service_provider ||= ServiceProvider.find(self.service_provider_id)
  end
  
  def wrangle_response(response)
    self.response_body = response.body
    self.response_headers = {}
    response.each do | key, value |
      self.response_headers[key] = value
    end
    self.response_code = response.code
    self.response_message = response.message
    if GhostTrap.ghosts && !GhostTrap.ghosts.empty?
      GhostTrap.ghosts.each do | ghost |
        if ghost[:signature_base_string]
          self.signature_base_string = ghost[:signature_base_string]
        end
        if ghost[:signature]
          self.signature = ghost[:signature]
        end
        if ghost[:signing_secret]
          self.signing_secret = ghost[:signing_secret]
        end
        if ghost[:authorization_header]
          self.authorization_header = ghost[:authorization_header]
        end
      end
    end      
  end
end
