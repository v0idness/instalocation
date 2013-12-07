class EventsController < ApplicationController
	helper_method :evnt_a # is an array of arrays of tweet object groups
  helper_method :coord
  helper_method :photos

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
        
  		  #get a Twitter connection object
    		client = Twitter::REST::Client.new do |config| 
    			config.consumer_key        = "93jNZ8LOHFDlqUs3z5PvEg"; 
    			config.consumer_secret     = "lRSw2AqT3viPYrqc1wzHP0Rnm7q6euYwkrrldFqW8"; 
    			config.access_token        = "2190411696-XGq1cUKpN9EVb8bOvEEwDNE0mXkyn872ysEN1t0"; 
    			config.access_token_secret = "NGNLEwFS9KIylf56sMpZZkeZFZUDfgmHlGesgxgBKtYH3"; 
    		end

        Instagram.configure do |config|
          config.client_id = "4fa1490a44004debbb3117965b3ab141"
          config.client_secret = "8f0e04bf5a494c73b3134f689540f459"
        end

        # get corresponding instagram photos from location
        @photos = Instagram.media_search("#{@coord[0].latitude}","#{@coord[0].longitude}")

    		#execute twitter search
    		search = client.search(" ", 
    			:geocode => "#{@coord[0].latitude},#{@coord[0].longitude},1km", 
    			:count => 100, 
    			:result_type => "recent")

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
      		if t_group.count >= 10 then
  	    		@evnt_a << t_group
  	    	end
      	end
      	@evnt_a = @evnt_a.sort {|x,y| y.count <=> x.count}

      else
        redirect_to new_event_path
      end

	end

	def create
		render text: params[:event].inspect
		#@event = Event.new(event_params)
  		@event.save
  		#redirect_to @event
	end

	def show
  		@event = Event.find(params[:id])
	end

	private
  		def event_params
    		params.require(:event).permit(:title, :text, :date)
  		end

  		def evnt_a
  			@evnt_a ||= [[[]]]
  		end
      def coord
        @coord ||= []
      end
      def photos
        @photos ||= []
      end
end
