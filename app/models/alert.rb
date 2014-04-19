class Alert < ActiveRecord::Base
	attr_accessible :threshold, :game_id, :user_id
	belongs_to :user
  	belongs_to :game
end
