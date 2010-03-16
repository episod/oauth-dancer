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
    @is_two_legged = params[:access_token_id] == "two-legged"

    unless @is_two_legged
      @access_token = @service_provider.access_tokens.find(params[:access_token_id])
    end
    
    options = {}
    if params[:request_content_type]
      options[:headers] = { "Content-Type" => params[:request_content_type]}
    end
    some_headers = process_headers(4, params)
    options[:headers].merge!(some_headers)
    @these_headers = {} unless @these_headers
    
    options[:method] = params[:method]
    options[:postdata] = params[:request_body]
    unless @is_two_legged
      GhostTrap.trap! :three_legged, "We are dancing on three legs."
      @api_request = ApiRequest.make_request(params[:resource_url], @access_token, options)
    else
      GhostTrap.trap! :two_legged, "We are dancing on two legs."
      @api_request = ApiRequest.make_two_legged_request(params[:resource_url], @service_provider, options)
    end
  end
  
  def select_service_provider
    @service_providers = ServiceProvider.find(:all)
  end

end
