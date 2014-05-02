
include GameSearchHelper 
include GameHelper

#Controls all actions that refer to games.
class GameController < ApplicationController
  
  #Action called when searching for a game
  #Paginates a list of search results for the HTML file.
  def search
  	
     @results = nil

     if signed_in? && current_user.filter
       @results = GameSearchHelper.find_and_filter_games(params[:stuff],current_user)
     else
       @results = GameSearchHelper.find_game(params[:stuff])
     end

     if params[:genre] != ''
       @results = GameSearchHelper.find_games_by_genre(params[:genre],@results,params[:method])
     end     

     if params[:method] == '1'
       @results = GameSearchHelper.sort_games_by_metacritic_desc(@results)
     end

     if params[:method] == '2'
       @results = GameSearchHelper.sort_games_by_metacritic_asc(@results)
     end

     @results = GameSearchHelper.filter_games_by_metacritic(@results,params[:low].to_i,params[:high].to_i)
     @results = @results.paginate(page: params[:page], per_page: params[:per])
  end

  #Action to show a game's profile to the user.
  def show
    @current_ID = params[:id]
  	@game = Game.find(@current_ID)
    @user = current_user
    @best = GameHelper.best_price(@game)
    @alert = nil
    if current_user
      @alert = (@user.alerts & @game.alerts)[0]
    end
    @lowest = @game.game_sale_histories.order(price: :asc).first
  end

  #Add a game to the database.
  def add
  	@blah = Game.find(params[:gameid])
  	if current_user != nil
      if current_user.games.find_by_title(@blah.title) == nil
  		  current_user.games << @blah
        flash[:success] = "Game added successfully"
      end
  	end
  	redirect_to :back
  end
end
