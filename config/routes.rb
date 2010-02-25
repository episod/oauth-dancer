ActionController::Routing::Routes.draw do |map|
  map.resources :service_providers, :has_many => :access_tokens
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
#== Route Map
# Generated on 25 Feb 2010 11:56
#
#     service_provider_access_tokens GET    /service_providers/:service_provider_id/access_tokens(.:format)          {:controller=>"access_tokens", :action=>"index"}
#                                    POST   /service_providers/:service_provider_id/access_tokens(.:format)          {:controller=>"access_tokens", :action=>"create"}
#  new_service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/new(.:format)      {:controller=>"access_tokens", :action=>"new"}
# edit_service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/:id/edit(.:format) {:controller=>"access_tokens", :action=>"edit"}
#      service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:controller=>"access_tokens", :action=>"show"}
#                                    PUT    /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:controller=>"access_tokens", :action=>"update"}
#                                    DELETE /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:controller=>"access_tokens", :action=>"destroy"}
#                  service_providers GET    /service_providers(.:format)                                             {:controller=>"service_providers", :action=>"index"}
#                                    POST   /service_providers(.:format)                                             {:controller=>"service_providers", :action=>"create"}
#               new_service_provider GET    /service_providers/new(.:format)                                         {:controller=>"service_providers", :action=>"new"}
#              edit_service_provider GET    /service_providers/:id/edit(.:format)                                    {:controller=>"service_providers", :action=>"edit"}
#                   service_provider GET    /service_providers/:id(.:format)                                         {:controller=>"service_providers", :action=>"show"}
#                                    PUT    /service_providers/:id(.:format)                                         {:controller=>"service_providers", :action=>"update"}
#                                    DELETE /service_providers/:id(.:format)                                         {:controller=>"service_providers", :action=>"destroy"}
#                                           /:controller/:action/:id                                                 
#                                           /:controller/:action/:id(.:format)                                       
