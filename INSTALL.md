#Installation Guide

##Version and Dependency Information
We used ruby 2.0.0 with Rails 4. 

In order to bundle install you will need the postgres development libraries. This can be installed on ubuntu with 

`apt-get install postgresql-server-dev-all`


##Getting Rails Installed

This is the hardest part of getting your development environment set up. The best resource for this is probably the installation guide on [The Rails Tutorial](http://www.railstutorial.org/book/beginning#sec-development_tools).

This guide assumes that you know how to install git.

###Installing Ruby

Before we start we need to make sure that there is no version of ruby currently installed. This can be checked by seeing if

`ruby -v` 

returns anything, if it does then uninstall it. This measure is important because standard repos for ubuntu and some other OS's are broken.

To install ruby we are going to use the [Ruby Version Manager](http://rvm.io). We need to download the ruby version manager you can do this with the command 

`curl -sSL https://get.rvm.io | bash -s stable`

This will download and install the stable version. If you already have rvm(do not use the version in the ubuntu repo, it is broken) you can update it by just running.

`rvm get stable`

Once you have rvm you need to install all the requirements for ruby, this can be done with the command

`rvm requirements`

If this doesn't work you may need to manually install some librarys. These could be 


* libtool
* libxslt
* libksba
* openssl
* libyaml-dev

this step is fairly system dependent and may take some googling to find someone that may have a similar setup.

Now that you have rvm setup and all of rubies dependencies installed it is time to install ruby. We used ruby 2.0.0 to develop our app. This can be installed with 

`rvm install 2.0.0`

This will probably take a while so be patient. Once you have ruby installed through rvm you will have the ability to use the bundler. The proper version of rails should then be installed the first time you run `bundle install` from our project.

##Running the app

Since the github has a populated games database, you will not need to worry about seeding the site with games. Pre-existing sales data is also included, but it may be out of date by the time you read this. If you wish to have up to date sales data and/or add new game releases to the games database, please refer to the Adding Data section. Instructions on setting up a fresh db will be at the bottom of this document. 


Running the app is fairly simple.

* First you need to run `bundle update && bundle install` to make sure that all the necessary gems are installed. 
* Then you start the development server with `rails s`

Thats it, you can now navigate to http://localhost:3000 and navigate the app

##Adding Data

###Adding Sales Data

* Run `rails runner DailyParseHelper.parse_all`. You should probably do this in a separate terminal window as this is a long-running process. 


* Alternatively, if you want to only run the parser for a certain vendor, you can do the following:


  * `GameSale.where(:store => "INSERT STORE NAME HERE").destroy_all`

  * Then, for each of the vendors, do the corresponding action:  

        * Amazon: `rails runner AmazonHelper.parse_amazon_site`
        * Steam: `rails runner SteamHelper.parse_steam_site`
        * Green-Man-Gaming: `rails runner GmgHelper.parse_gmg_site`
       	* Gamers Gate: `rails runner GamersGateHelper.parse_ggate_site`

  * Then, if you want to send any alerts out, run the following: `rails runner AlertHelper.send_alerts`



###Adding Games Data

Run `bundle exec rake db:seed`. You should probably do this in a separate terminal window as this is a long-running process. 


##Development Stuff
If you ever change the schema of the database you will need run `bundle exec rake db:migrate`
