class TheDanceController < ApplicationController
  before_filter :clear_ghost_trap, :only => [ :index, :get_request_token ]

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

    @consumer = @service_provider.to_oauth_consumer({ :context => :request_token })
    headers = { } # optional headers to attach to the request
    @request_token = @consumer.get_request_token({:oauth_callback => callback_url}, nil, headers)

    GhostTrap.trap! :request_token, @request_token.token
    GhostTrap.trap! :request_token_secret, @request_token.secret

    # temporarily store the request_token in the session
    session[@request_token.token] = @request_token.secret

    if @request_token.has_xoauth_request_auth_url?
      GhostTrap.trap! :auth_url_forward, "The service provider has indicated a different URL for authorization with xoauth_request_auth_url"
      GhostTrap.trap! :xoauth_request_auth_url, @request_token.xoauth_request_auth_url
    end

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
    send_to_authorization(@request_token, @request_token.xoauth_request_auth_url || nil)
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

  def oob
    # Not yet ready
    GhostTrap.trap! :oob_mode, "Waiting to collect OAuth veirfier in OOB mode"
    session[:oob] = false
    if request.post?
      rt = session[:oob_token]
      rs = session[:oob_secret]
      id = session[:oob_id]
      session[:oob_secret] = nil
      session[:oob_token] = nil
      session[:oob_id] = nil
      @service_provider = ServiceProvider.find id
      @request_token = OAuth::RequestToken.from_hash(@service_provider.to_oauth_consumer, { :oauth_token => rt, :oauth_token_secret => rs})
      begin
        get_access_token(@service_provider, @request_token )
      rescue
      end
      redirect_to :controller => "oauth_consumers", :action => "callback", :oauth_token => rt, :oauth_token_secret => rs, :oauth_verifier => params[:oauth_verifier], :id => id
    end
  end

  def cancel_oob
    # Not yet ready
    session[:oob] = false
    session[:oob_secret] = nil
    session[:oob_token] = nil
    session[:oob_id] = nil
    flash[:notice] = "Cancelled OOB mode"
    redirect_to :controller => "home", :action => "index"
  end


  def send_to_authorization(request_token, xoauth_override = nil)
    # make sure to use the specific authorize URL specified by the app.
    url = request_token.authorize_url
    uri = URI.parse(url)
    params = uri.query
    if @service_provider.authorize_host.to_s == uri.host.to_s
      uri.host = @service_provider.authorize_host
    end
    if @xoauth_override
      new_host_uri = URI.parse(xoauth_override)
      uri.host = new_host_uri.host
      uri.path = new_host_uri.path
      if new_host_uri.query && !new_host_uri.query.empty?
        uri.query = uri.query + "&" + new_host_uri.query
      end
    end
    url = uri.to_s
    GhostTrap.trap! :authorize_url, "Redirecting to #{url}"
    redirect_to url
  end

  def get_access_token(service_provider, request_token, oauth_verifier)
    consumer = service_provider.to_oauth_consumer(:context => :access_token)
    access_token = consumer.get_access_token(request_token, { :oauth_verifier => oauth_verifier})
    store_access_token(service_provider, access_token)
  end

  def get_access_token_with_xauth
    GhostTrap.trap! :xauth_mode, "using xAuth to sign in"
    @service_provider = ServiceProvider.find(params[:service_provider_id])
    consumer = @service_provider.to_oauth_consumer(:context => :access_token)
    options = {}
    options[:x_auth_username] = params[:login]
    options[:x_auth_password] = params[:password]
    options[:x_auth_mode] = "client_auth"
    # options[:oauth_nonce] = params[:oauth_nonce] if params[:oauth_nonce]
    # options[:oauth_timestamp] = params[:oauth_timestamp] if params[:oauth_timestamp]
    if params[:oauth_timestamp]
      GhostTrap.trap! :oauth_timestamp, "Using a hardcoded timestamp: #{params[:oauth_timestamp]}"
      GhostTrap.keep! :oauth_timestamp, params[:oauth_timestamp]
    end
    if params[:oauth_nonce]
      GhostTrap.trap! :oauth_nonce, "Using a hardcoded nonce: #{params[:oauth_nonce]}"
      GhostTrap.keep! :oauth_nonce, params[:oauth_nonce]
    end

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
