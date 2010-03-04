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
      [ "application/x-www-form-urlencoded; charset=utf-8", "application/json; charset=utf-8", "application/xml; charset=utf-8"]
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
      if self.headers['Content-Type'] =~ /url/ || !want_pristine
        parsed = CGI.parse(@postdata)
        parsed
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
      
      PROXY_CONFIG.apply(:read_timeout => 5) do 
        if [:post, :put, :delete].include?(api_request.method)
          response = access_token.request(api_request.method, api_request.resource_url, api_request.postdata, api_request.headers)
        else
          response = access_token.request(api_request.method, api_request.resource_url, api_request.headers)
        end
      end
      api_request.response_body = response.body
      api_request.response_headers = {}
      response.each do | key, value |
        api_request.response_headers[key] = value
      end
      api_request.response_code = response.code
      api_request.response_message = response.message
      if GhostTrap.ghosts && !GhostTrap.ghosts.empty?
        GhostTrap.ghosts.each do | ghost |
          if ghost[:signature_base_string]
            api_request.signature_base_string = ghost[:signature_base_string]
          end
          if ghost[:signature]
            api_request.signature = ghost[:signature]
          end
          if ghost[:signing_secret]
            api_request.signing_secret = ghost[:signing_secret]
          end
          if ghost[:authorization_header]
            api_request.authorization_header = ghost[:authorization_header]
          end
        end
      end
      api_request
    end
  
    def ApiRequest.make_two_legged_request(url, service_provider, options = {})
    end
  
    def access_token
      @access_token ||= AccessToken.find(self.access_token_id)
    end
    
    def service_provider
      @service_provider ||= ServiceProvider.find(self.service_provider_id)
    end
end
