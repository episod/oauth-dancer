class ApiRequestController < ApplicationController
  def index
    begin
      @service_provider = ServiceProvider.find(params[:service_provider_id])
    rescue
      redirect_to :action => "select_service_provider" and return
    end
    @access_tokens = @service_provider.access_tokens
    @api_request = ApiRequest.new
  end

  def make_request
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    @access_token = @service_provider.access_tokens.find(params[:access_token_id])
    options = {}
    if params[:request_content_type]
      options[:headers] = { "Content-Type" => params[:request_content_type]}
    end
    @api_request = ApiRequest.make_request(params[:resource_url], @access_token, options)
  end
  
  def select_service_provider
    @service_providers = ServiceProvider.find(:all)
  end

end
