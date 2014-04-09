require 'json'

module PriceHistoryHelper

	def get_sales_histories(game)
		cleaninghash = {"Amazon"=> {},"Steam"=> {},"GMG"=> {}}
		histories = game.game_sale_histories.order('occurred desc')
		for h in histories
			cur = cleaninghash[h.store][h.occurred.to_date]
			if cur !=nil
				if cur.price > h.price
					cleaninghash[h.store][h.occurred.to_date]=h
					histories.delete(cur)
				else
					histories.delete(h)
				end
			else
				cleaninghash[h.store][h.occurred.to_date]=h
			end
		end
        return histories
	end
	
end