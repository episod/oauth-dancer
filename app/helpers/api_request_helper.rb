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
end
