class LocationsController < ApplicationController

	def index
		@locs = Location.select(:country).map(&:country).uniq
		@locs.sort_by!{ |char| char.downcase }
		@ev = Event.all
		@locations=Location.all
		@hash = Gmaps4rails.build_markers(@locations) do |location, marker|
  			marker.lat location.latitude
  			marker.lng location.longitude
  			@x = Event.find(location.id) 
  			@a="<strong>#{@x.title}</strong>"
  			@b="#{@x.text}"
  			@c=""
  			if @x.photos.first!=nil
  				@c="<img src=#{@x.photos.first.image} width=\"70\" height=\"70\">"	
			end
  			box=[@a, @b, @c].join("\n")
  			#marker.infowindow @x.text
  			marker.infowindow box.gsub(/\n/, '<br />')
  			marker.title @x.title
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
	end
end
