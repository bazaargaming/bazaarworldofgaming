#This model has info on previous game sales(pricing data)
class GameSaleHistory < ActiveRecord::Base
	attr_accessible :occurred, :store, :price
	validates :occurred,  presence: true
	validates :store,  presence: true
	validates :price,  presence: true
	belongs_to :game
end
