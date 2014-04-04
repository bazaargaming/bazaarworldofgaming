include PriceHistoryHelper

class JsonController < ActionController::Base

	def index
   		@game = Game.find(params[:id])
    	@json = PriceHistoryHelper.get_sales_histories(@game)
	end
end
