require 'json'

module PriceHistoryHelper

	def get_sales_histories(game)
		histories = game.game_sale_histories.order('occurred desc')
        return histories.to_json
	end
	
end