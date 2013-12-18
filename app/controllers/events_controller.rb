class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :index]
  
	def index
    @events = Event.order("id desc")    
    
    @ev = Event.all
    @locations=Location.all
    @hash = Gmaps4rails.build_markers(@locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
      @x = Event.where(:location_id => location.id)
      if @x.count > 0 then
        heading = @x.count > 1 ? "Latest of #{@x.count} events from #{location.name}:" : "One event reported in #{location.name}:"
        box=[heading, 
          "<strong>#{@x.last.title}</strong>",
          "<a href='/events/#{@x.last.id}'>view this event &raquo;</a>"].join("\n")
        marker.infowindow box.gsub(/\n/, '<br />')
        marker.title @x.last.title
      end
    end
	end

	def new
		@event = Event.new
	end

  def add
    # COORDINATE PARSING ================================================================
		if params[:address].present?
  			@coord=Geocoder.search(params[:address])
		end  

    # check whether an address was entered, and a location found for this address
    if !@coord.nil? and !@coord[0].nil? then


      coords = "#{@coord[0].latitude},#{@coord[0].longitude}"
      @query = " "
      if params[:query].present?
        @query = params[:query]
      end 

  		# call search function
      search = Event.t_exec_search(coords,@query)

  		@tweets = Array.new
  		search.each do |tweet|
  			@tweets << tweet
    	end

      # get corresponding instagram photos from location
      Event.i_config
      @photos = Instagram.media_search("#{@coord[0].latitude}","#{@coord[0].longitude}")


    else
      redirect_to new_event_path
    end

	end

	def create
    if params[:tweet].nil? and params[:photo].nil?
      redirect_to events_add_path
    else
    # regular expression for the parameters of the event/group of tweets
    re = /([\w\s]*),(\S*)\s([\S\s]*);([\S\s]*)/ 
    regm = params[:evnt].match re
    query = regm[1] # search query
    coords = regm[2] # coordinates of the chosen location
    country = regm[3] # country of the location
    locname = regm[4] # name of the chosen location

    re = /([\-\.\d]*),([\-\.\d]*)/ 
    regm = coords.match re
    lat = regm[1]
    lng = regm[2]

    if !Event.exists?(:title => params[:title]) then
    
      # create location for the event
      if !Location.exists?(:name => locname) then
        @loc = Location.create!({
          :country => country,
          :latitude => lat,
          :longitude => lng,
          :name => locname
          })
      end
      @loc = Location.find_by_name(locname)

      # create the event
      @event = Event.create!({
        :title => params[:title],
        :text => params[:text],
        :date => Time.now,
        :location_id => @loc.id,
        :user_id => current_user.id
        })

      if !params[:tweet].nil? then
        # create the associated tweets
        client = Event.t_config

        params[:tweet].each do |t|
          item = client.status(t)
          Tweet.create!({
            :user => item.user.name,
            :text => item.text,
            :event_id => @event.id
          })
        end
      end

      if !params[:photo].nil? then
        # create the associated photos
        Event.i_config

        params[:photo].each do |p|
          item = Instagram.media_item(p)
          Photo.create!({
            :user => item.user.username,
            #:caption => item.caption.nil ? "" : item.caption.text,
            :thumbnail => item.images.thumbnail.url,
            :image => item.images.standard_resolution.url,
            :link => item.link,
            :event_id => @event.id            
            })
        end
      end

      current_user.update_attribute(:level, current_user.level + 1)
    end

  	redirect_to @event
  end
	end

	def show
  		@event = Event.find(params[:id])
	end

end
