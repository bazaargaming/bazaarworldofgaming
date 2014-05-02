include PriceHistoryHelper

class JsonController < ActionController::Base

	#Index for JSON files.
	#Needed for pulling up price history graphs and tables.
	def index
   		@game = Game.find(params[:id])
    	@json = PriceHistoryHelper.get_sales_histories(@game)
    	@body = render json: @json
	end
end
