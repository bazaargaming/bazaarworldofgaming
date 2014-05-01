
##
# Used the generate and send emails
#

class Alerter < ActionMailer::Base

  ##
  # Given a user, and a game sale, sends out an alert message to that user's email address, notifying them of the sale
  #

  def alert_message(user,game_sale)
    @user = user
    @game_sale = game_sale
    @game = @game_sale.game
    mail(:to => user.email, :subject => "#{@game.title} is on sale!", :from => "bazaarworldofgaming@gmail.com", :body => "#{@game.title} is on sale either at or lower than your alert price for it! \nGo to the sale here: #{@game_sale.url}")
  end



end
