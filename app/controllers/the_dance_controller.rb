class TheDanceController < ApplicationController
  # This is the process of logging a key in
  
  def index
    @service_providers = ServiceProvider.find(:all, :include => [ :access_tokens ], :order => :label )
  end

  def get_request_token
    
  end

  def send_to_authorization
  end

  def get_access_token
  end

  def take_a_bow
  end

end
