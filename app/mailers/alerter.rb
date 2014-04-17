class Alerter < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.alerter.gmail_price_alert.subject
  #
  def gmail_message
    # @greeting = "Hi"

    # mail to: "to@example.org"
    # @subject = "Message  via Gmail"
    # @recipients = "arjunpgarg@gmail.com"
    # @from     =   "bazaarworldofgaming@gmail.com"
    # @body = "This is a test email"


    mail(:to => "arjunpgarg@gmail.com", :subject => "Test", :body => "This is a test email. \n www.google.com", :from => "bazaarworldofgaming@gmail.com")
  end


  def alert_message(user,game_sale)
    @user = user
    @game_sale = game_sale
    @game = @game_sale.game

    mail(:to => user.email, :subject => "#{@game.title} is on sale!", :from => "bazaarworldofgaming@gmail.com", :body => "#{@game.title} is on sale either at or lower than your alert price for it! \nGo to the sale here: #{@game_sale.url}")
  end



end
