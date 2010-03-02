class ApiRequestController < ApplicationController
  def index
  end

  def make_request
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    @access_token = @service_provider.access_tokens.find(params[:access_token_id])
    @api_request = ApiRequest.make_request(params[:url], @access_token, options = {})
  end

end
