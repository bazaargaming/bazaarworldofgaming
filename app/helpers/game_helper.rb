module GameHelper

	#Returns the best price of a game.
	def self.best_price(game)
		return game.game_sales.order(saleamt: :asc).first
	end
end
