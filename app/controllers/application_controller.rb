# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def title
    @title || "Hold me closer"
  end
  
  def set_title(title)
    @title = title
  end
  
  def clear_ghost_trap
    GhostTrap.clear!
  end
  
  protected
    def rescues_path(template_name)
      "#{RAILS_ROOT}/app/views/rescues/#{template_name}.erb"
    end
  
end
