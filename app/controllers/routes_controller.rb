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
    
    # Interpret Data: determine whick polyline points to grab based on trip duration
    
    ## Try a 15 min interval, calculate # of columns
    
    @interval = 15
    @columns = @duration/60/@interval.to_i
    
    # Increase interval if needed to keep # of columns below 8
     
    (0..2).each do |i|
      if @columns > 8
        @interval = @interval*2
        @columns = @duration/60/@interval.to_i
      end
    end
    
    poly_interval = (@polyline.length/(@columns+1)).to_i
    
    
    # Call Dark Sky Weather API, create array of API resutls (48 hr forecast) at each polyline location
    
    @weather = Array.new

    begin
      (0..(@polyline.length-1)).step(poly_interval).each do |i|
        lat = @polyline[i][0]
        lon = @polyline[i][1]
        weather_url = String.new("https://api.darksky.net/forecast/8cb01bc87b1278fd8200bbf1edfbffb3/").concat(lat.to_s).concat(",").concat(lon.to_s)
        
        
          @parsed_weather_data = JSON.parse(open(weather_url).read)
          weather = @parsed_weather_data.dig("hourly", "data")
          @weather.concat([weather])
      end
    rescue OpenURI::HTTPError
        puts "HELLO"
        redirect_to("/routes", :notice => "This site has exceeded it's daily limit of DarkSky API calls. Please check back tomorrow.")
        return
    end
    
    # Define weather colors
    
    rain_colors = ["rgb(0, 246, 84)", 
                  "rgb(0, 203, 39)", 
                  "rgb(0, 160, 10)", 
                  "rgb(0, 111, 5)", 
                  "rgb(0, 95, 0)", 
                  "rgb(0, 73, 12)", 
                  "rgb(238, 217, 0)", 
                  "rgb(248, 160, 0)", 
                  "rgb(255, 64, 0)", 
                  "rgb(254, 0, 0)", 
                  "rgb(193, 0, 0)", 
                  "rgb(88, 0, 0)", 
                  "rgb(255, 0, 141)", 
                  "rgb(158, 0, 207)", 
                  "rgb(182, 77, 204)"]
    
    snow_colors = ["rgb(0, 255, 255)", 
                  "rgb(0, 237, 255)", 
                  "rgb(0, 219, 251)", 
                  "rgb(0, 190, 251)", 
                  "rgb(0, 174, 243)", 
                  "rgb(0, 153, 243)", 
                  "rgb(0, 133, 243)", 
                  "rgb(0, 125, 235)", 
                  "rgb(3, 103, 235)", 
                  "rgb(23, 83, 225)", 
                  "rgb(41, 39, 225)", 
                  "rgb(48, 0, 225)", 
                  "rgb(49, 0, 217)", 
                  "rgb(45, 0, 188)", 
                  "rgb(45, 0, 193)"]
    
    sleet_colors = ["rgb(255, 194, 255)", 
                    "rgb(247, 193, 213)", 
                    "rgb(255, 161, 200)", 
                    "rgb(255, 141, 196)", 
                    "rgb(245, 123, 187)", 
                    "rgb(247, 99, 187)", 
                    "rgb(239, 77, 179)", 
                    "rgb(231, 49, 171)", 
                    "rgb(226, 21, 160)", 
                    "rgb(209, 0, 152)", 
                    "rgb(210, 0, 143)", 
                    "rgb(193, 0, 138)", 
                    "rgb(179, 0, 126)", 
                    "rgb(173, 0, 125)", 
                    "rgb(161, 0, 113)"]
    
    @colors = { "rain" => rain_colors, "snow" => snow_colors, "sleet" => sleet_colors }
    
    render("route_templates/show.html.erb")
  end

  def new_form
    render("route_templates/new_form.html.erb")
  end

  def create_row
    
    if params.fetch("start_id") == params.fetch("end_id")
      redirect_to("/routes/new", :alert => "Start and End locations cannot be the same.")
      return
    else
      @route = Route.new
  
      @route.start_id = params.fetch("start_id")
      @route.end_id = 
      @route.user_id = current_user.id
  
      if @route.valid?
        @route.save
  
        redirect_to("/routes/#{@route.id}", :notice => "Route created successfully.")
      else
        render("route_templates/new_form.html.erb")
      end
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
  
  def flip
    @route = Route.find(params.fetch("id_to_flip"))
    
    flip_1 = @route.start_id
    flip_2 = @route.end_id
    
    @route.start_id = flip_2
    @route.end_id = flip_1
    
    if @route.valid?
      @route.save
    end
    
    redirect_to("/routes/#{@route.id}")
  end
end
