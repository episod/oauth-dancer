class ApiRequest < PassiveRecord::Base
    define_fields :access_token_id, 
                  :headers, 
                  :method,
                  :resource_url, 
                  :signature_base_string, 
                  :signature,
                  :signing_secret, 
                  :postdata,
                  :response_body,
                  :response_headers,
                  :response_code,
                  :response_message,
                  :service_provider_id
    belongs_to :access_token
    belongs_to :service_provider
    
    def ApiRequest.make_request(url, model_access_token, options = {})
      GhostTrap.clear!
      api_request = ApiRequest.new(
                      { :resource_url => url, 
                        :access_token_id => access_token.id,
                        :method => options[:method] || :get,
                        :postdata => options[:postdata],
                        :headers => options[:headers] || {}, 
                      })
      api_request.service_provider = access_token.service_provider
      consumer = api_request.service_provider.to_oauth_consumer
      access_token = model_access_token.to_oauth_access_token
      if [:post, :put, :delete].include?(api_request.method.downcase.to_sym)
        response = access_token.request(api_request.method.downcase.to_sym, api_request.resource_url, api_request.postdata, api_request.headers)
      else
        response = access_token.request(api_request.method.downcase.to_sym, api_request.resource_url, api_request.headers)
      end
      api_request.response_body = response.body
      response.each do | key, value |
        api_request.response_headers[:key] = value
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
        end
      end
      api_request
    end
    
    def ApiRequest.make_two_legged_request(url, service_provider, options = {})
    end
    
end
