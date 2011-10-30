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
  map.root :controller => "home", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
#== Route Map
# Generated on 02 Mar 2010 06:38
#
#     service_provider_access_tokens GET    /service_providers/:service_provider_id/access_tokens(.:format)          {:action=>"index", :controller=>"access_tokens"}
#                                    POST   /service_providers/:service_provider_id/access_tokens(.:format)          {:action=>"create", :controller=>"access_tokens"}
#  new_service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/new(.:format)      {:action=>"new", :controller=>"access_tokens"}
# edit_service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/:id/edit(.:format) {:action=>"edit", :controller=>"access_tokens"}
#      service_provider_access_token GET    /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:action=>"show", :controller=>"access_tokens"}
#                                    PUT    /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:action=>"update", :controller=>"access_tokens"}
#                                    DELETE /service_providers/:service_provider_id/access_tokens/:id(.:format)      {:action=>"destroy", :controller=>"access_tokens"}
#                  service_providers GET    /service_providers(.:format)                                             {:action=>"index", :controller=>"service_providers"}
#                                    POST   /service_providers(.:format)                                             {:action=>"create", :controller=>"service_providers"}
#               new_service_provider GET    /service_providers/new(.:format)                                         {:action=>"new", :controller=>"service_providers"}
#              edit_service_provider GET    /service_providers/:id/edit(.:format)                                    {:action=>"edit", :controller=>"service_providers"}
#                   service_provider GET    /service_providers/:id(.:format)                                         {:action=>"show", :controller=>"service_providers"}
#                                    PUT    /service_providers/:id(.:format)                                         {:action=>"update", :controller=>"service_providers"}
#                                    DELETE /service_providers/:id(.:format)                                         {:action=>"destroy", :controller=>"service_providers"}
#                               root        /                                                                        {:action=>"index", :controller=>"home"}
#                                           /:controller/:action/:id
#                                           /:controller/:action/:id(.:format)
