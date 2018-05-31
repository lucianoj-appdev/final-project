class LocationsController < ApplicationController
  def index
    @locations = Location.where(user_id: current_user.id).all

    render("location_templates/index.html.erb")
  end

  def show
    @location = Location.find(params.fetch("id_to_display"))
    
    address = URI.encode(@location.address)
    @url = String.new("https://maps.googleapis.com/maps/api/geocode/json?address=").concat(address)
    parsed_data = JSON.parse(open(@url).read)
    
    if parsed_data.dig("results", 0, "formatted_address").nil? == FALSE
      @location.address = parsed_data.dig("results", 0, "formatted_address")
      @location.save
    end
    
    @latitude = parsed_data.dig("results", 0, "geometry", "location", "lat")
    @longitude = parsed_data.dig("results", 0, "geometry", "location", "lng")

    render("location_templates/show.html.erb")
  end

  def new_form
    render("location_templates/new_form.html.erb")
  end

  def create_row
    @location = Location.new

    @location.name = params.fetch("name")
    @location.address = params.fetch("address")
    @location.user_id = current_user.id

    if @location.valid?
      @location.save

      redirect_to("/locations", :notice => "Location created successfully.")
    else
      render("location_templates/new_form.html.erb")
    end
  end

  def edit_form
    @location = Location.find(params.fetch("prefill_with_id"))

    render("location_templates/edit_form.html.erb")
  end

  def update_row
    @location = Location.find(params.fetch("id_to_modify"))

    @location.name = params.fetch("name")
    @location.address = params.fetch("address")

    if @location.valid?
      @location.save

      redirect_to("/locations/#{@location.id}", :notice => "Location updated successfully.")
    else
      render("location_templates/edit_form.html.erb")
    end
  end

  def destroy_row
    @location = Location.find(params.fetch("id_to_remove"))

    @location.destroy

    redirect_to("/locations", :notice => "Location deleted successfully.")
  end
end
