require 'json'

module PriceHistoryHelper

	#Get sales histories for a game
	#Called when user clicks to display the Price history.
	def get_sales_histories(game)
		cleaninghash = {"Amazon"=> {},"Steam"=> {},"GMG"=> {},"GamersGate"=>{}}
		histories = game.game_sale_histories.order('occurred desc')
		for h in histories
			cur = cleaninghash[h.store][h.occurred.to_date]
			if cur !=nil
				if cur.price > h.price
					cleaninghash[h.store][h.occurred.to_date]=h
					histories.reject{|n|  n == cur}
				else
					histories.reject{|n|  n == h}
				end
			else
				cleaninghash[h.store][h.occurred.to_date]=h
			end
		end
        return histories
	end
	
end