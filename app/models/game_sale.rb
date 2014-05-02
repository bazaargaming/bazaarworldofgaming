#This model keeps track of all current game sales
class GameSale < ActiveRecord::Base
	attr_accessible  :occurrence, :store, :url, :origamt, :saleamt
	validates :occurrence,  presence: true
	validates :store,  presence: true
	validates :url,  presence: true
	validates :origamt,  presence: true
	validates :saleamt,  presence: true
	belongs_to :game
end