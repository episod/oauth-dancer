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
    
    if @request_token.callback_confirmed?
      GhostTrap.trap! :callback_confirmed, "The service provider confirmed the oauth_callback"
    else
      GhostTrap.trap! :callback_confirmed, "The service provider did not confirm the oauth_callback"
    end
    
    # Now send the user off to authorization
    send_to_authorization(@request_token)
  end

  def process_callback
    GhostTrap.trap! :oauth_callback, "OAuth callback hit"
    request_token = params[:oauth_token]
    request_token_secret = session[request_token]
    @service_provider = ServiceProvider.find params[:service_provider_id]
    if request_token_secret
      @request_token = OAuth::RequestToken.from_hash(@service_provider.to_oauth_consumer, { :oauth_token => request_token, :oauth_token_secret => request_token_secret})
      @access_token get_access_token(@service_provider, @request_token)
      if @
        flash[:notice] = "#{params[:id].humanize} was successfully connected to your account"
        go_back
      else
        flash[:error] = "An error happened, please try connecting to #{@service_provider.label} again"
        redirect_to :action => "index"
      end
    end    
  end
  
  def process_out_of_band
  end
  
  def send_to_authorization(request_token)
    url = request_token.authorize_url
    GhostTrap.trap! :authorize_url, "Redirecting to #{url}"
    redirect_to url
  end

  def take_a_bow
  end


  def get_access_token(service_provider, request_token)
    
  end
  
  def store_access_token(service_provider, access_token)
  end

end
