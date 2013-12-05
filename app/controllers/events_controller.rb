class EventsController < ApplicationController
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
      coord=Geocoder.coordinates(params[:address])
    else
      redirect_to "/events/new"
    end      
      
		#get a Twitter connection object
  		client = Twitter::REST::Client.new do |config| 
  			config.consumer_key        = "93jNZ8LOHFDlqUs3z5PvEg"; 
  			config.consumer_secret     = "lRSw2AqT3viPYrqc1wzHP0Rnm7q6euYwkrrldFqW8"; 
  			config.access_token        = "2190411696-XGq1cUKpN9EVb8bOvEEwDNE0mXkyn872ysEN1t0"; 
  			config.access_token_secret = "NGNLEwFS9KIylf56sMpZZkeZFZUDfgmHlGesgxgBKtYH3"; 
  		end

  		#execute search
  		search = client.search(" ", 
  			:geocode => "37.781157,-122.398720,1mi", 
  			:lang => "en", 
  			:count => 5, 
  			:result_type => "recent")

  		# list of the locations appearing in all the retrieved tweets
  		t_locations = Array.new
  		search.collect do |tweet|
  			if tweet.place? then
  				t_locations << tweet.place.full_name
  				t_locations = t_locations.uniq
  			end
    	end

    	# array of tweet object arrays for each location
    	groupedtweets = Array.new
    	t_locations.collect do |loc|
    		group = Array.new
    		search.collect do |t|
    			if t.place.full_name == loc then
    				group << t
    			end
    		end
    		groupedtweets << group
    	end

	end

	def create
		render text: params[:event].inspect
		#@event = Event.new(event_params)
  		#@event.save
  		#redirect_to @event
	end

	def show
  		@event = Event.find(params[:id])
	end

	private
  		def event_params
    		params.require(:event).permit(:title, :text, :date)
  		end
end
