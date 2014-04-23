module GameHelper

	def self.best_price(game)
		return game.game_sales.order(saleamt: :asc).first
	end
end
