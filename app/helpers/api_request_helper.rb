module ApiRequestHelper
  def request_content_types(default = nil)
    buffer = ""
    types = ApiRequest.request_content_types
    types.each do | type |
      buffer << "<option "
      buffer << "selected" if type == default
      buffer << ">#{type}</option>"
    end
    buffer
  end
  
  def access_tokens_for_select
    options = @access_tokens.collect{|at| [ at.to_s, at.id ]}
    options << [ "Two-Legged Request", "two-legged" ]
    options_for_select(options, params[:access_token_id] ? params[:access_token_id].to_i : nil )
  end
end
