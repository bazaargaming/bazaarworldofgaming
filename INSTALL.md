#Installation Guide

##Ruby

You should use rvm to install ruby 2.0.0

##Getting Rails Installed

This is the hardest part of getting your development environment set up. The best resource for this is probably the installation guide on [The Rails Tutorial](http://www.railstutorial.org/book/beginning#sec-development_tools).

##Running the app

Since the github has a populated games database, you will not need to worry about seeding the site with games. Pre-existing sales data is also included, but it may be out of date by the time you read this. If you wish to have up to date sales data and/or add new game releases to the games database, please refer to the Adding Data section. Instructions on setting up a fresh db will be at the bottom of this document. 

Running the app is fairly simple.

* First you need to run `bundle update && bundle install` to make sure that all the necessary gems are installed. 
* Then you start the development server with `rails s`

Thats it, you can now navigate to http://localhost:3000 and navigate the app

##Adding Data

###Adding Sales Data

1. Run `rails runner DailyParseHelper.parse_all`. You should probably do this in a separate terminal window as this is a long-running process. 


2. Alternatively, if you want to only run the parser for a certain vendor, you can do the following.

  * GameSale.where(:store => "INSERT STORE NAME HERE").destroy_all
  * Then, for each of the vendors, do the corresponding action:
   > Amazon: 'rails runner AmazonHelper.parse_amazon_site'
   > Steam: 'rails runner SteamHelper.parse_steam_site'
   > Green-Man-Gaming: 'GmgHelper.parse_gmg_site'
   > Gamers Gate: 'GamersGateHelper.parse_ggate_site'

  * Then, if you want to send any alerts out, run the following: 'rails runner AlertHelper.send_alerts'


###Adding Games Data

1. Run `bundle exec rake db:seed`. You should probably do this in a separate terminal window as this is a long-running process. 


##Development Stuff
If you ever change the schema of the database you will need run `bundle exec rake db:migrate`
