class Alert < ActiveRecord::Base
	attr_accessible :threshold
	belongs_to :user
  	belongs_to :game
end
