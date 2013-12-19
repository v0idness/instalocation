class LocationsController < ApplicationController

	def index
		@locs = Location.select(:country).map(&:country).uniq
		@locs.sort_by!{ |char| char.downcase }

		@ev = Event.all
		@locations=Location.all
		@hash = Gmaps4rails.build_markers(@locations) do |location, marker|
  			marker.lat location.latitude
  			marker.lng location.longitude
  			@x = Event.where(:location_id => location.id)
  			if @x.count > 0 then
	  			heading = @x.count > 1 ? "Latest of #{@x.count} events from #{location.name}:" : "One event reported in #{location.name}:"
	  			photo = ""
	  			if @x.last.photos.first!=nil
	  				photo="<img src='#{@x.last.photos.first.thumbnail}' alt='#{@x.last.photos.first.user}' />"	
				end
	  			box=[heading, 
	  				"<strong>#{@x.last.title}</strong>", 
	  				photo,
	  				"<a href='/events/#{@x.last.id}'>view this event &raquo;</a>"].join("\n")
	  			marker.infowindow box.gsub(/\n/, '<br />')
	  			marker.title @x.last.title
	  		end
  		end
	end

	def bycountry
		@locs = Location.where('lower(country) = ?', params[:country].downcase)		
		@events = []
		@locs.each do |l|
			Event.where(:location_id => l.id).each do |e|
				@events << e
			end
		end
		@events.reverse!
	end
end
