class TheDanceController < ApplicationController
  before_filter :clear_ghost_trap, :only => [ :index ]
  
  def index
    @service_providers = ServiceProvider.find(:all, :include => [ :access_tokens ], :order => :label )
  end

  def xauth_collect
    @service_provider = ServiceProvider.find(params[:service_provider_id])
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
    @request_token = @consumer.get_request_token(:oauth_callback => callback_url)
    
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
    oauth_verifier = params[:oauth_verifier]
    @service_provider = ServiceProvider.find params[:service_provider_id]
    if request_token_secret
      @request_token = OAuth::RequestToken.from_hash(@service_provider.to_oauth_consumer, { :oauth_token => request_token, :oauth_token_secret => request_token_secret})
      begin
        get_access_token(@service_provider, @request_token, oauth_verifier)
      rescue Exception => e
        flash[:error] = "There was a problem securing an access token for #{@service_provider.label}. Check the GhostTrap."
        GhostTrap.trap! :access_token_error, e.inspect
      end
        
    else
      flash[:error] = "There was a problem securing an access token for #{@service_provider.label}"
      GhostTrap.trap! :access_token_error, "No request token secret from the service provider."
      redirect_to :action => "index"
    end    
  end
  
  def process_out_of_band
    # TODO: Process OOB flow
  end
  
  def send_to_authorization(request_token)
    url = request_token.authorize_url
    GhostTrap.trap! :authorize_url, "Redirecting to #{url}"
    redirect_to url
  end

  def get_access_token(service_provider, request_token, oauth_verifier)
    consumer = service_provider.to_oauth_consumer
    access_token = consumer.get_access_token(request_token, { :oauth_verifier => oauth_verifier})
    store_access_token(service_provider, access_token)
  end
  
  def get_access_token_with_xauth
    GhostTrap.trap! :xauth_mode, "using xAuth to sign in"
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    consumer = @service_provider.to_oauth_consumer
    options = {}
    options[:x_auth_username] = params[:login]
    options[:x_auth_password] = params[:password]
    options[:x_auth_mode] = "client_auth"
    url = @service_provider.access_token_path
    response = consumer.token_request(:post, url, nil, {}, options)
    @access_token = OAuth::AccessToken.from_hash(consumer, response)
    store_access_token(@service_provider, @access_token)
  end
  
  def store_access_token(service_provider, access_token)
    token_model = service_provider.access_tokens.find(:first, :conditions => { :oauth_token => access_token.token })
    unless token_model
      token_model = service_provider.access_tokens.create(:oauth_token => access_token.token, :oauth_token_secret => access_token.secret)
      GhostTrap.trap! :store_access_token, "Stored the new access token."
    else
      GhostTrap.trap! :store_access_token, "Already found this access token. Skipping"
    end
    redirect_to :action => "take_a_bow", :access_token_id => token_model.id, :service_provider_id => service_provider.id
  end

  def take_a_bow
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    @access_token = @service_provider.access_tokens.find(params[:access_token_id])
  end

end
