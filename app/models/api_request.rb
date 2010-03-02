class ApiRequest < PassiveRecord::Base
    define_fields :access_token_id, 
                  :headers, 
                  :method,
                  :resource_url, 
                  :signature_base_string, 
                  :signing_key, 
                  :postdata,
                  :response_body,
                  :response_headers,
                  :response_code,
                  :service_provider_id
    belongs_to :access_token
    belongs_to :service_provider
    
    def ApiRequest.make_request(url, model_access_token, options = {})
      api_request = ApiRequest.new(
                      { :resource_url => url, 
                        :access_token_id => access_token.id,
                        :method => options[:method],
                        :postdata => options[:postdata],
                        :headers => options[:headers], 
                      })
      api_request.service_provider = access_token.service_provider
      consumer = api_request.service_provider.to_oauth_consumer
      access_token = model_access_token.to_oauth_access_token
    end
    
    def ApiRequest.make_two_legged_request(url, service_provider, options = {})
    end
    
end
