# CMR Metadata Review

The CMR Metadata Review tool is used to curate NASA EOSDIS collection and granule level metadata in CMR for correctness, completeness and consistency.

## Synopsis

The CMR Metadata Review tool is designed to aid in the process of performing quality checks on metadata records in the Common Metadata Repository (CMR). A series of initial automated metadata quality checks are performed when ingesting a selected record into the tool, after which the record is available for manual review. Metadata reviewers perform manual quality checks in the tool, with the option to flag identified issues as high (red), medium (yellow), or low (blue) priority. Additionally, the tool allows reviewers to leave specific recommendations on how to resolve identified issues. Metrics are tracked for all of the data entered into the tool (e.g. number of high, medium, and low priority issues flagged) allowing for the generation of reports on the fly. Detailed reports can be generated for individual record reviews, which summarize the number of red, yellow and blue flagged elements along with recommendations made on how to resolve identified issues. Higher level reports, summarizing metrics across all records in the tool or from a certain data provider, can also be generated. Reports can be shared directly in the tool with other users.

## Motivation

This tool was specifically developed for the Analysis and Review of CMR (ARC) Team, which is responsible for conducting quality evaluations of NASA's metadata records in the Common Metadata Repository (CMR). The overarching goal of this project is to ensure that NASA data in the CMR is discoverable and accessible, and that the user experience is consistent when exploring data holdings across NASA's multiple data centers. Achieving this goal involves evaluating metadata for completeness, correctness, and consistency; a process largely supported by this tool.

## Development Environment Set Up

This can be found (with pictures) [here](https://wiki.earthdata.nasa.gov/display/CMRARC/Dev+Environment+Set+Up).

## Setting Up Local Development Project

All development work is done on local copies of the code base.  Follow the steps below to prepare a local copy on your machine. *NOTE: ONLY RUBY 2.3 WILL WORK currently but we are migrating to 2.5*

1. Install Ruby on your machine.  The production version of the project uses Ruby v 2.3.   Other versions may work, but only 2.3 is currently fully supported.

- You can check which version of ruby you have with the command "which ruby"

- If the version of ruby that comes up is not 2.3.x use the command "rvm list" to list which ruby versions you have. Choose your default with the command "rvm --default use 2.3"

2. Download the source code from the ECC repo. Within that page the address to clone from can be located from this section in the top left of the screen.  The command line command is +git clone CLONE_ADDRESS+ and then the user will be prompted for their ECC password.

3. The user will then need to setup a local Postgres DB to connect to the app

- Macs come pre-installed with PSQL (and a common way to manage it is with [PGAdmin.](https://www.pgadmin.org/download/)

- _From the command line/Terminal_ - enter the psql command line with the command +psql+

- You will then be prompted for your password

- I you run into the issue of +password authentication failed for user+ – try the command +psql -U postgres -h localhost+ and enter in the password for your computer

4. From the PSQL console, you will need to add a +SUPERUSER+ and +DATABASE+ matching the database and username values shown in +config/database.yml+ within the project repo.  The development & test DB's both are in local Postgres.  There are many ways to create a postgres db and superuser.  These links can help –  [here](https://launchschool.com/blog/how-to-install-postgresql-on-a-mac) and [here.](https://www.postgresql.org/docs/9.1/static/sql-createrole.html)

- The commands will look like: +CREATE USER user_found_in_config/database.yml WITH SUPERUSER PASSWORD: 'password_found_in_config/database.yml+

- Create a user for both development and test

- To see if you have a successfully created a user, use the command +\du+ in the psql console

- After you have finished creating the users, exit out of the psql console with the command +\q+

5. Start the Postgres server on your machine. This command will depend on how you installed.

6. The user should then navigate into the project directory and run the 'bundle install' command to install all needed dependencies (you might need to do the command +gem install bundler+ to get the bundler gem).  Sometimes there are build conflicts on the local machine during this process.  Most solutions can be found on stack overflow.  If you encounter any bundle install failures, please post the error notice and solution here so they can be updated in the source directory.

7. Once installation of gems is complete, the user should run the commands +rake db:create+, +rake db:migrate+, and rake +db:seed+ in that order.  These commands will create the db required to run the project.

8. To ensure that you've created the proper databases – you can go back into the psql console and use the command +\l+

9. An ENV file will be needed before starting the server.  This file can only be obtained from a teammate on the project, it does not reside on the repo.  Once received, copy the file into your repo at the top level and name it +.env+
The .env is set to be ignored by git.  However, if somehow you accidentally commit the env file or send the env file to the cloud repo, let someone on the team know immediately.  All env variables will need to be reset across platforms to ensure safety of the system.

10. Now the project should be ready to go.  Navigate to the home directory and execute +rails s+ to start the server.

11. The homepage will be served at the address +localhost:3000+ in your browser.  The seeded (default) master username and password will be shown in the seeds.rb file.  This can be changed locally to whatever you want.


