# CMR Metadata Review

## Development Environment Set Up

This can also be found (with pictures)
[here](https://wiki.earthdata.nasa.gov/display/CMRARC/Dev+Environment+Set+Up)

*Setting Up Local Dev Project*

All development work is done on local copies of the code base.  Follow the
steps below to prepare a local copy on your machine.

1.  Install Ruby on your machine.  The production version of the project uses
    Ruby v 2.3.   Other versions may work, but only 2.3 is currently fully
    supported.

	a. *NOTE: ONLY RUBY 2.3 WILL WORK* 		A. You can check which version of ruby
you have with the command "which ruby" 		B. IF the version of ruby that comes
up is not 2.3.x use the command "rvm list" to list which ruby versions you
have. Choose your default with the command "rvm --default use 2.3"
1.  Download the source code from the ECC repo. Within that page the address
    to clone from can be located from this section in the top left of the
    screen.  The command line command is +git clone CLONE_ADDRESS+ and then
    the user will be prompted for their ECC password.
2.  The user will then need to setup a local Postgres DB to connect to the app

	a. Macs come pre-installed with PSQL (and a common way to manage it is with
[PGAdmin](https://www.pgadmin.org/download/)) 	b. _From the command
line/Terminal_ - enter the psql command line with the command `psql` 		A. You
will then be prompted for your password 			-IF you run into the issue of
+password authentication failed for user+ – try the command +psql -U postgres
-h localhost+ and enter in the password for your computer
1.  From the PSQL console, you will need to add a `SUPERUSER` and `DATABASE`
    matching the database and username values shown in `config/database.yml`
    within the project repo.  The development & test DB's both are in local
    Postgres.  There are many ways to create a postgres db and superuser. 
    These links can help – 
    [here](https://launchschool.com/blog/how-to-install-postgresql-on-a-mac)
    and [here](https://www.postgresql.org/docs/9.1/static/sql-createrole.html)

	a. The commands will look like: +CREATE USER
user_found_in_config/database.yml WITH SUPERUSER PASSWORD:
'password_found_in_config/database.yml+ 		A.Create a user for both development
and test 	b. To see if you have a successfully created a user, use the command
`\du` in the psql console 	c. After you have finished creating the users, exit
out of the psql console with the command `\q`
1.  Start the Postgres server on your machine. This command will depend on how
    you installed.
2.  The user should then navigate into the project directory and run the
    'bundle install' command to install all needed dependencies (you might
    need to do the command +gem install bundler+ to get the bundler gem). 
    Sometimes there are build conflicts on the local machine during this
    process.  Most solutions can be found on stack overflow.  If you encounter
    any bundle install failures, please post the error notice and solution
    here so they can be updated in the source directory.
3.  Once installation of gems is complete, the user should run the commands
    +rake db:create+, +rake db:migrate+, and rake `db:seed` in that order. 
    These commands will create the db required to run the project.
4.  To ensure that you've created the proper databases – you can go back into
    the psql console and use the command `\l`
5.  An ENV file will be needed before starting the server.  This file can only
    be obtained from a teammate on the project, it does not reside on the
    repo.  Once received, copy the file into your repo at the top level and
    name it `.env` The .env is set to be ignored by git.  However, if somehow
    you accidentally commit the env file or send the env file to the cloud
    repo, let someone on the team know immediately.  All env variables will
    need to be reset across platforms to ensure safety of the system.
6.  Now the project should be ready to go.  Navigate to the home directory and
    execute +rails s+ to start the server.
7.  The homepage will be served at the address `localhost:3000` in your
    browser.  The seeded (default) master username and password will be shown
    in the seeds.rb file.  This can be changed locally to whatever you want.

