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

1. Run `rails runner DailyParseHelper.parse_all`. You should probably do this in a separate terminal window as this is a long-running process. 

###Seeding/Adding Games Data

1. Run `bundle exec rake db:seed`. You should probably do this in a separate terminal window as this is a long-running process. 


##Development Stuff
If you ever change the schema of the database you will need run `bundle exec rake db:migrate`
