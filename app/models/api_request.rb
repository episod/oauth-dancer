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
                  :service_provider
    belongs_to :access_token
    
    def ApiRequest.make_request(url, access_token)
      
    end
    
    def ApiRequest.make_two_legged_request(url, service_provider)
    end
    
end
