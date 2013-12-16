class Event < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
  has_many :comments
	has_many :tweets, dependent: :destroy
	has_many :photos, dependent: :destroy 
	validates :title, presence: true

	def self.t_exec_search(coords,query)
		#get a Twitter connection object
  		client = Twitter::REST::Client.new do |config| 
  			config.consumer_key        = "93jNZ8LOHFDlqUs3z5PvEg"; 
  			config.consumer_secret     = "lRSw2AqT3viPYrqc1wzHP0Rnm7q6euYwkrrldFqW8"; 
  			config.access_token        = "2190411696-XGq1cUKpN9EVb8bOvEEwDNE0mXkyn872ysEN1t0"; 
  			config.access_token_secret = "NGNLEwFS9KIylf56sMpZZkeZFZUDfgmHlGesgxgBKtYH3"; 
  		end

  		#execute twitter search
  		search = client.search(query, 
  			:geocode => "#{coords},3km", 
  			:count => 100, 
  			:result_type => "recent")

  		return search
	end

	def self.i_config
		Instagram.configure do |config|
        config.client_id = "4fa1490a44004debbb3117965b3ab141"
        config.client_secret = "8f0e04bf5a494c73b3134f689540f459"
      end
	end

end
