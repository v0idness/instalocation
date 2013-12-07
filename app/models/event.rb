class Event < ActiveRecord::Base
	belongs_to :location
	has_many :tweets, dependent: :destroy 
	validates :title, presence: true
end
