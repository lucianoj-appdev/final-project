Rails.application.routes.draw do
  
  devise_for :users
  get("/", { :controller => "routes", :action => "index" })
  
  # Routes for the Route resource:

  # CREATE
  get("/routes/new", { :controller => "routes", :action => "new_form" })
  post("/create_route", { :controller => "routes", :action => "create_row" })

  # READ
  get("/routes", { :controller => "routes", :action => "index" })
  get("/routes/:id_to_display", { :controller => "routes", :action => "show" })

  # UPDATE
  get("/routes/:prefill_with_id/edit", { :controller => "routes", :action => "edit_form" })
  post("/update_route/:id_to_modify", { :controller => "routes", :action => "update_row" })

  # DELETE
  get("/delete_route/:id_to_remove", { :controller => "routes", :action => "destroy_row" })

  #------------------------------

  # Routes for the Location resource:

  # CREATE
  get("/locations/new", { :controller => "locations", :action => "new_form" })
  post("/create_location", { :controller => "locations", :action => "create_row" })

  # READ
  get("/locations", { :controller => "locations", :action => "index" })
  get("/locations/:id_to_display", { :controller => "locations", :action => "show" })

  # UPDATE
  get("/locations/:prefill_with_id/edit", { :controller => "locations", :action => "edit_form" })
  post("/update_location/:id_to_modify", { :controller => "locations", :action => "update_row" })

  # DELETE
  get("/delete_location/:id_to_remove", { :controller => "locations", :action => "destroy_row" })

  #------------------------------

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
