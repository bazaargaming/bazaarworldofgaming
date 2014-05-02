#Installation Guide

##Ruby

You should use rvm to install ruby 2.0.0

##Getting Rails Installed

This is the hardest part of getting your development environment set up. The best resource for this is probably the installation guide on [The Rails Tutorial](http://www.railstutorial.org/book/beginning#sec-development_tools).

##Running the app

Since the github has an up to date database so you will not need to seed the games data. Instructions on setting up a fresh db will be at the bottom of this document. 

Running the app is fairly simple.

* First you need to run `bundle update && bundle install` to make sure that all the necessary gems are installed. 
* Then you start the development server with `rails s`

Thats it, you can now navigate to http://localhost:3000 and navigate the app

##Seeding Data

###Seeding/Adding Sales Data

1. Copy the contents of [grab_vendor_data](db/grab_vendor_data.rb) into the seeds.rb file.
2. Run `bundle exec rake db:seed`

###Seeding/Adding Games Data

1. Copy the contents of [game_and_metacritic_parser](db/game_and_metacritic_parser.rb) into seeds.rb
2. Run `bundle exec rake db:seed`

##Development Stuff
If you ever change the schema of the database you will need run `bundle exec rake db:migrate`