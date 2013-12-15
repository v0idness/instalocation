class LocationsController < ApplicationController

	def index
		@locs = Location.select(:country).map(&:country).uniq
		@locs.sort_by!{ |char| char.downcase }
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
