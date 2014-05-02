#This class keeps track of any price alerts a user has 
#set for a game.
class Alert < ActiveRecord::Base
	attr_accessible :threshold, :game_id, :user_id
	belongs_to :user
  	belongs_to :game

  	validates :threshold,  presence: true, numericality: true

end
