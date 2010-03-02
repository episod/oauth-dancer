# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :show_ghosttrap
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def title
    @title || "Hold me closer"
  end
  
  def set_title(title)
    @title = title
  end
  
  def show_ghosttrap
    @ghosts = GhostTrap.ghosts
  end
  
end
