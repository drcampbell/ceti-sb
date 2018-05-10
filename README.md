# README #

## README FOR DOCKER INSTALLATION ##

Install Docker for your OS

Make sure docker-compose is installed


1. Database is to be created and loaded with data.
```
$ docker-compose run web rake db:create

$ docker-compose run web rake db:schema:load

$ docker-compose run web rake db:seed

$ docker-compose run web rake db:migrate
```

2. Build the docker container

`$ docker-compose build`

3. Start the container

`$ docker-compose up`

4. Open the browser and type `$ localhost:3001`



NOTE: The following steps are the manual way of setting up the app locally.If unsuccessful with docker installation please try the manual route.

## README for CETI Web ##
This guide is assuming you are in a linux environment, specifically Ubuntu. This should also work in Debian or other flavors, but can easily be translated to Mac OS X.

### Dependencies ###
JRE

RVM

Ruby 2.2.1p85 This will probably be out of date 

Rails 4.2.1

[Set up Git](https://help.github.com/articles/set-up-git/)

##### AWS Dependencies #####
Python			

"As of writing need 2.7 or 3.4 check AWS"

python-dev		

`$ sudo apt-get install python-dev`

pip				

`$ sudo apt-get install python-pip`

AWS CLI			

`$ sudo pip install awscli`

EB CLI			

`$ sudo pip install awsebcli`

##### PostGreSQL Dependency #####
You'll need an instance of [PostGreSQL](https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-14-04)
running on your local machine to run a development server on your machine. Follow the 
link to view instructions on how to set this up.  

Note that for this Rails is expecting:

Username: `pguser`

Password: `password`

Once you have installed PostGreSQL, you need to generate a database.  

### Install the app ###
```
$ git clone git@bitbucket.org:drcampbell/ceti_sb.git
```

### AWS Identity ###
To configure AWSCLI you will need an identity from IAM.  Have the AWS system admin generate credentials for you.  When you have received your credentials, enter:

```
$ aws configure
AWS Access Key ID [None:] YourKey
AWS Secret Access Key [None]: Your Secret Key
Default region name [None]: us-west-2
Default output format [None]: Press Enter
```

### To set up EB CLI ###
Change your directory to the application directory, and then initialize the Elastic Beanstalk command line in the application directory.  

`$ eb init`

You will now configure EB, choose the following options:

```
Select a default region
3) us-west-2

Select an application to use:
1) ceti_sb

Select the default environment
1) ceti-test-env
```

### Setup Rails Environment ###
To install the necessary gems for the server perform the traditional:

`$ bundle install --without production # We don't want to install PostGres`

Create a PostGreSQL database and then run the migrations:

```
$ rake db:create		# Create the development database
$ rake db:schema:load	# Load the Schemas defined by the migrations
$ rake db:seed
```

At this point you need to make sure that you have a JRE installed.
Now start Sunspot Solr (The Search Engine)

`$ RAILS_ENV=development bundle exec rake sunspot:solr:start`


To start the server:

`$ rails s # Starts the web server`


To start the console:

`$ rails c`

### Upload Builds to AWS ###
Make sure that you are not pushing to the production server:

`$ eb status`

Verify that the CNAME is not the production server. Then you can commit changes to and deploy to AWS. 

```
$ git commit -am "Your message"
$ eb deploy
```
