class TheDanceController < ApplicationController
  # This is the process of logging a key in
  
  def index
    @service_providers = ServiceProvider.find(:all, :include => [ :access_tokens ], :order => :label )
  end

  def get_request_token
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    callback_url = ""
    if @service_provider.use_out_of_band?
      callback_url = "oob"
    else
      callback_url = url_for(:controller => "the_dance", :action => "process_callback", :service_provider_id => @service_provider.id)
    end
    GhostTrap.trap! :oauth_callback, callback_url
    
    @consumer = @service_provider.to_oauth_consumer
    @request_token = @consumer.get_request_token(callback_url)
    
    GhostTrap.trap! :request_token, @request_token.token
    GhostTrap.trap! :request_token_secret, @request_token.secret
    
    # temporarily store the request_token in the session
    session[@request_token.token] = @request_token.secret
    
    # We'll be picking up this flow later in out of band requests.
    if @service_provider.use_out_of_band?
      GhostTrap.trap! :out_of_band, "Setup session for out of band processing."
      session[:out_of_band] = { :request_token => @request_token.token, 
                                :request_token_secret => @request_token.secret,
                                :service_provider_id => @service_provider.id}      
    end
    
    # Now send the user off to authorization
    send_to_authorization
  end

  def process_callback
  end
  
  def process_out_of_band
  end
  
  def send_to_authorization
    url = @request_token.authorize_url
    GhostTrap.trap! :authorize_url, "Redirecting to #{url}"
    redirect_to @request_token.authorize_url
  end

  def get_access_token
  end

  def take_a_bow
  end

end
