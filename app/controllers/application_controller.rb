# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  def title
    @title || "Hold me closer"
  end
  
  def set_title(title)
    @title = title
  end
  
  def clear_ghost_trap
    GhostTrap.clear!
  end
  
  def process_headers(number, params)
    process_kvs("header", number, params)
  end
  
  def process_kvs(pre_label, number, params)
    parameters = { }
    1.upto(number) do | i |
      if params["#{pre_label}_value_#{i}"] 
        next if params["#{pre_label}_value_#{i}"] == ""
        parameters[params["#{pre_label}_key_#{i}"]] = params["#{pre_label}_value_#{i}"]
      end
    end
    parameters    
  end
  
  protected
    def rescues_path(template_name)
      "#{RAILS_ROOT}/app/views/rescues/#{template_name}.erb"
    end
  
end
