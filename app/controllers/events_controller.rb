class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :index]
  
	def index
    #Get the events from the model; order by 'date' descending
    @events = Event.order("date desc")    
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

  		# list of the locations appearing in all the retrieved tweets
  		t_locations = Array.new
  		search.each do |tweet|
  			if tweet.place? then
  				t_locations << tweet.place.full_name
  				t_locations = t_locations.uniq
  			end
    	end

    	# array of tweet object arrays for each location
    	@evnt_a = Array.new
    	t_locations.each do |loc|
    		t_group = Array.new
    		search.each do |t|
    			if t.place.full_name == loc then
    				t_group << t
    			end
    		end
    		# add only if there are XXX tweets/instagram photos for a location
    		if t_group.count >= 3 then
	    		@evnt_a << t_group
	    	end
    	end
    	@evnt_a = @evnt_a.sort {|x,y| y.count <=> x.count}

      # get corresponding instagram photos from location
      Event.i_config
      @photos = Instagram.media_search("#{@coord[0].latitude}","#{@coord[0].longitude}")


    else
      redirect_to new_event_path
    end

	end

	def create
    # regular expression for the parameters of the event/group of tweets
    re = /([\w\s]*),(\S*)\s([\S\s]*);([\S\s]*)/ 
    regm = params[:evnt].match re
    query = regm[1] # search query
    coords = regm[2] # coordinates of the chosen location
    country = regm[3] # country of the location
    locname = regm[4] # name of the chosen location

    puts params[:evnt]
    puts regm

    re = /([\-\.\d]*),([\-\.\d]*)/ 
    regm = coords.match re
    lat = regm[1]
    lng = regm[2]

    if !Event.exists?(:title => params[:title]) then
    
      # create location for the event
      if !Location.exists?(:name => locname) then
        @loc = Location.create({
          :country => country,
          :latitude => lat,
          :longitude => lng,
          :name => locname
          })
      end
      @loc = Location.find_by_name(locname)

      # create the event
      @event = Event.create({
        :title => params[:title],
        :text => params[:text],
        :date => Time.now,
        :location_id => @loc.id,
        :user_id => current_user.id
        })

      # call search function
      search = Event.t_exec_search(coords,query)

      # store tweets
      search.each do |t|
        if t.place.full_name == locname then
          Tweet.create({
            :user => t.user.name,
            :text => t.text,
            :event_id => @event.id
          })
        end
      end

      if !params[:photo].nil? then
        # create the associated photos
        Event.i_config

        params[:photo].each do |p|
          item = Instagram.media_item(p)
          Photo.create({
            :user => item.user.username,
            #:caption => item.caption.nil ? "" : item.caption.text,
            :thumbnail => item.images.thumbnail.url,
            :image => item.images.standard_resolution.url,
            :event_id => @event.id            
            })
        end
      end

      current_user.level += 1
    end

  	redirect_to @event
	end

	def show
  		@event = Event.find(params[:id])
	end

end
