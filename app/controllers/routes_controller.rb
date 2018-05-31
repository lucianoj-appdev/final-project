class RoutesController < ApplicationController
  def index
    @routes = Route.where(user_id: current_user.id).all

    render("route_templates/index.html.erb")
  end

  def show
    @route = Route.find(params.fetch("id_to_display"))
    
    # Pull start and end addresses
    
    start_address = URI.encode(Location.find(@route.start_id).address)
    end_address = URI.encode(Location.find(@route.end_id).address)
    
    # Call Google Maps Route API
    
    @route_url = String.new("https://maps.googleapis.com/maps/api/directions/json?origin=").concat(start_address).concat("&destination=").concat(end_address).concat("&key=AIzaSyCng5AA9_lPWRniCZW9nwAbzw5SrZNWzsI")
    
    # Parse Data
    
    @parsed_route_data = JSON.parse(open(@route_url).read)
    
    @duration = @parsed_route_data.dig("routes", 0, "legs", 0, "duration", "value")
    
    polyline_encoded = @parsed_route_data.dig("routes", 0, "overview_polyline", "points")
    @polyline = Polylines::Decoder.decode_polyline(polyline_encoded)
    
    # Interpret Data: determine whick polyline points to grab based on trip duration (every 15 mins)
    
    @columns = @duration/60/15.to_i
    interval = @polyline.length/@columns.to_i
    
    # Call Dark Sky Weather API, create array of API resutls (48 hr forecast) at each polyline location
    
    @weather = Array.new

    (1..@polyline.length).step(interval).each do |i|
      lat = @polyline[i-1][0]
      lon = @polyline[i-1][1]
      weather_url = String.new("https://api.darksky.net/forecast/8cb01bc87b1278fd8200bbf1edfbffb3/").concat(lat.to_s).concat(",").concat(lon.to_s)
      @parsed_weather_data = JSON.parse(open(weather_url).read)
      weather = @parsed_weather_data.dig("hourly", "data")
      @weather.concat([weather])
    end
    
    render("route_templates/show.html.erb")
  end

  def new_form
    render("route_templates/new_form.html.erb")
  end

  def create_row
    @route = Route.new

    @route.start_id = params.fetch("start_id")
    @route.end_id = params.fetch("end_id")
    @route.user_id = current_user.id

    if @route.valid?
      @route.save

      redirect_to("/routes/#{@route.id}", :notice => "Route created successfully.")
    else
      render("route_templates/new_form.html.erb")
    end
  end

  def edit_form
    @route = Route.find(params.fetch("prefill_with_id"))

    render("route_templates/edit_form.html.erb")
  end

  def update_row
    @route = Route.find(params.fetch("id_to_modify"))

    @route.start_id = params.fetch("start_id")
    @route.end_id = params.fetch("end_id")

    if @route.valid?
      @route.save

      redirect_to("/routes/#{@route.id}", :notice => "Route updated successfully.")
    else
      render("route_templates/edit_form.html.erb")
    end
  end

  def destroy_row
    @route = Route.find(params.fetch("id_to_remove"))

    @route.destroy

    redirect_to("/routes", :notice => "Route deleted successfully.")
  end
end
