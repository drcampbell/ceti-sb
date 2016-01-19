# README for CETI Web #
This guide is assuming you are in a linux environment, specifically Ubuntu. This should also work in Debian or other flavors, but can easily be translated to Mac OS X.

### Dependencies ###
JRE

Ruby 2.2.1p85 This will probably be out of date 

Rails 4.2.1

[Set up Git](https://help.github.com/articles/set-up-git/)

Python			"As of writing need 2.7 or 3.4 check AWS"

python-dev		$ sudo apt-get install python-dev

pip				$ sudo apt-get install python-pip

AWS CLI			$ sudo pip install awscli

EB CLI			$ sudo pip install awsebcli

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

Run the migrations:

`$ rake db:migrate`

At this point you need to make sure that you have a JRE installed.
Now start Sunspot Solr (The Search Engine)

`$ rake sunspot:solr:start`

To start the server:

`$ rails s # Starts the web server`


To start the console:

`$ rails c`