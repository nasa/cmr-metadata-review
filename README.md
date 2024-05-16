# Test PR to be deleted
# CMR Metadata Review

The CMR Metadata Review tool is used to curate NASA EOSDIS collection and granule level metadata in CMR for correctness, completeness and consistency.

## Synopsis

The CMR Metadata Review tool is designed to aid in the process of performing quality checks on metadata records in the Common Metadata Repository (CMR). A series of initial automated metadata quality checks are performed when ingesting a selected record into the tool, after which the record is available for manual review. Metadata reviewers perform manual quality checks in the tool, with the option to flag identified issues as high (red), medium (yellow), or low (blue) priority. Additionally, the tool allows reviewers to leave specific recommendations on how to resolve identified issues. Metrics are tracked for all of the data entered into the tool (e.g. number of high, medium, and low priority issues flagged) allowing for the generation of reports on the fly. Detailed reports can be generated for individual record reviews, which summarize the number of red, yellow and blue flagged elements along with recommendations made on how to resolve identified issues. Higher level reports, summarizing metrics across all records in the tool or from a certain data provider, can also be generated. Reports can be shared directly in the tool with other users.

## Motivation

This tool was specifically developed for the Analysis and Review of CMR (ARC) Team, which is responsible for conducting quality evaluations of NASA's metadata records in the Common Metadata Repository (CMR). The overarching goal of this project is to ensure that NASA data in the CMR is discoverable and accessible, and that the user experience is consistent when exploring data holdings across NASA's multiple data centers. Achieving this goal involves evaluating metadata for completeness, correctness, and consistency; a process largely supported by this tool.

## Development Environment Set Up

This can be found (with pictures) [here](https://wiki.earthdata.nasa.gov/display/CMRARC/Dev+Environment+Set+Up).

## Setting Up Local Development Project

All development work is done on local copies of the code base.  Follow the steps below to prepare a local copy on your machine.

1. Install Ruby on your machine.  The production version of the project uses Ruby v 3.0.6. Other versions may work, but only 3.0.6 is currently fully supported.

- You can check which version of ruby you are running with the command `ruby -v`, and the location with `which ruby`

- If the version of ruby that comes up is not 3.0.6 and you are using rvm use the command `rvm list` to list which ruby versions you have. To set the ruby version for the current directory use the command `rvm use 3.0.6`, or to set your default use `rvm --default use 3.0.6`

2. Download the source code from this github repo.

3. The user will then need to setup a local Postgres DB to connect to the app. _\*NOTE: make sure to install Postgres 9.6, because 10.\* is known to cause issues with running tests._

- Macs come pre-installed with PSQL (and a common way to manage it is with [PGAdmin](https://www.pgadmin.org/download/).

- _From the command line/Terminal_ - enter the psql command line with the command `psql`

- You will then be prompted for your password

- If you run into the issue of `password authentication failed for user` – try the command `psql -U postgres -h localhost` and enter in the password for your computer.  If that command does not work, you may find it easier to alter the pg_hba.conf file.  The location of this file varies based on where the postgres is trying to run from.  It should be located in the data directory.  Using `ps aux | grep postgres` should list the active processes, one of which should contain something vaguely like: ' /usr/local/opt/postgresql@9.6/bin/postgres -D /usr/local/var/postgresql@9.6'.  The location after the -D is the data directory for the instance that is currently running.  After you alter that file, you will need to restart postgres for the changes to take effect.  

- If you run into the issue of `psql: FATAL: database "<user>" does not exist` - see [this link](https://stackoverflow.com/questions/17633422/psql-fatal-database-user-does-not-exist)

- Some people may find they need to create an initial database to connect to with `/usr/local/opt/postgresql@9.6/bin/createdb -h localhost`

4. From the PSQL console, you will need to add a `SUPERUSER` matching the username values shown in `config/database.yml` within the project repo. The development & test DB's both are in local Postgres. There are many ways to create a postgres db and superuser.  These links can help –  [here](https://launchschool.com/blog/how-to-install-postgresql-on-a-mac) and [here](https://www.postgresql.org/docs/9.1/static/sql-createrole.html).

- With user information from `config/database.yml`, the commands will look like: `CREATE ROLE <user> WITH SUPERUSER PASSWORD '<password>';`

- Create both the development and test users

- To see if you have a successfully created a user, use the command `\du` in the psql console

- If you have error connecting with the two  accounts, run the following command to grant login right: `ALTER ROLE "<user>" WITH LOGIN;`

- After you have finished creating the users, exit out of the psql console with the command `\q`

5. Start the Postgres server on your machine. This command will depend on how you installed.

6. The user should then navigate into the project directory and run the 'bundle install' command to install all needed dependencies (you might need to do the command `gem install bundler` to get the bundler gem). Sometimes there are build conflicts on the local machine during this process.  Most solutions can be found on stack overflow. If you encounter any bundle install failures, please post the error notice and solution here so they can be updated in the source directory.

	1. If Puma is problematic (as observed on the Mac OS 10.13) , try the following: `gem install puma -v '3.6.2' -- --with-opt-dir=/usr/local/opt/openssl`.

7. Once installation of gems is complete, to create the Database the user should run the commands `rake db:create`, `rake db:migrate`, and rake `db:seed` in that order. These commands will create the db required to run the project.

- The `seeds.rb` file currently will only seed some user data required for testing.

8. To ensure that you've created the proper databases – you can go back into the psql console and use the command `\l`

9. An application.yml file will be needed before starting the server.  This file can only be obtained from a teammate on the project, it does not reside on the repo.  Once received, copy the file into your config folder. The application.yml is set to be ignored by git.  However, if somehow you accidentally commit the file or send the file to the cloud repo, let someone on the team know immediately.  All env variables will need to be reset across platforms to ensure safety of the system.

11. The application uses react:rails which has a dependency on having [yarn](https://tecadmin.net/install-yarn-macos/) installed on your system.  Yarn is a package manager used to install Javascript dependencies needed by the frontend.   To install these dependencies, issue the command: `yarn install` from the root directory of the application.
    
11. Now the project should be ready to go. Navigate to the home directory and execute `rails s` to start the server.

12. The homepage will be served at the address `localhost:3000` in your browser. To use the tool locally you will need to:

- Register for an [Earthdata Login account](https://sit.urs.earthdata.nasa.gov/) for the SIT environment.

- Request ACL permissions to access the tool in the SIT environment by emailing [Earthdata Support](mailto:support@earthdata.nasa.gov). In order to Ingest collections into the tool, you may need Admin or Arc Curator permissions as well..  Also see section below entitles "Authentication"

## Quick Start Guide - Installation on Mac

## Installing rvm
    \curl -sSL https://get.rvm.io | bash
    brew install openssl
    PKG_CONFIG_PATH=/usr/local/opt/openssl@1.1/lib/pkgconfig rvm reinstall 3.0.6 --with-openssl --with-openssl-lib=/usr/local/opt/openssl@1.1/lib --with-openssl-include=/usr/local/opt/openssl@1.1/include
    rvm install 3.0.6
    rvm use 3.0.6 --default

### Installing Postgresql 9.6
    brew install postgresql@9.6
    echo 'export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"' >> ~/.zshrc
    createuser -s postgres
    createuser -s cmrdash
    createuser -s cmrdash_test

### Installing source code
    git clone https://[userid]@github.com/nasa/cmr-metadata-review.git
    cd cmr-metadata-review
    rake db:create:all
    rake db:migrate
    cp ~/application.yml config (yml is supplied by another developer)

### Install Gems
    gem install bundle
    bundle install

### Install reactjs deps
    brew install nvm yarn
    nvm install
    nvm use
    export NODE_OPTIONS=--openssl-legacy-provider (this should be added your your .zshrc file too)

### Startup the server
    rails s

## Authentication
The application uses [devise](https://github.com/heartcombo/devise) which is a flexible authentication solution for 
Rails.  The authorization mechanism uses [omniauth](https://github.com/omniauth/omniauth) which is a library/module that standardizes 
multi-provider authentication for web applications.  Any developer can create strategies for OmniAuth that can 
authenticate users via disparate systems.  

One strategy, called [Developer](https://github.com/omniauth/omniauth/blob/master/lib/omniauth/strategies/developer.rb), is included with OmniAuth and provides a completely 
insecure, non-production-usable strategy that directly prompts an user for authentication information and then 
passes it straight through.    If the server is run in "development" mode, you will see a button called "Login with Developer",
you can click that, provide your name and email, and it will log you in using the information you provide.  It will bypass all
typical authorizations you would get with production and assign you the role of `admin`.

The second strategy, called [URS](https://git.earthdata.nasa.gov/projects/CMRARC/repos/omniauth-edl/browse), provides 
a production-usable strategy that directly authenticates with Earth Data Login.   You can register for a account for 
[SIT](https://sit.urs.earthdata.nasa.gov/home), [UAT](https://uat.urs.earthdata.nasa.gov/home), and [PROD](https://urs.earthdata.nasa.gov/home).  Please note, SIT and UAT both require PIV access.   If you want to configure authentication with the production, you'll need to modify these 2 lines 
in `cmr-metadata-review/config/environments/development.rb`:

    config.cmr_base_url = 'https://cmr.earthdata.nasa.gov'
    config.kms_base_url = 'https://gcmd.earthdata.nasa.gov'

This will tell the authorization mechanism to access production CMR for access control rather than SIT. 

## Importing Database 

    psql -U postgres -c 'drop database cmrdash'
    psql -U postgres -c 'create database cmrdash'
    psql --user cmrdash cmrdash < sit-db-dump-2018-09-27.sql
(Note you may see a bunch of ERROR like role "arcdashadmin" does not exist, this can be ignored)

After the import is complete, you'll need to run `db:migrate` again.

Additional note: If you login and view the dashboard home page (with all the sections) and the sections are empty, check the server logs, if you see lots of:

    Record without DAAC: #<Record id: 4489, recordable_id: 1891, recordable_type: "Collection", revision_id: "30", closed_date: nil, format: "echo10", state: "in_daac_review", associated_granule_value: nil, copy_recommendations_note: nil, released_to_daac_date: "2021-03-27 17:00:12", daac: nil, campaign: [], native_format: nil>

It means one of the migration scripts did not run properly (not entirely sure why), but if you
redo the migration for that one script, it will work:

    rake db:migrate:redo VERSION=20200227150658

# Bamboo Testing

Bamboo environment runs cmr dashboard in a docker environment.   It uses two images to setup the environment.
The first image is the base image which includes centos with python38 installed:
https://ci.earthdata.nasa.gov/build/admin/edit/editBuildTasks.action?buildKey=MMT-MMTBUIL-PTA
The second image builds pyQuARC (note should change the version, i.e., --build-arg version=1.2.0)
https://ci.earthdata.nasa.gov/build/admin/edit/editBuildTasks.action?buildKey=MMT-CMRDAS-PTA
It uses this image to build and run the dashboard tests:
https://ci.earthdata.nasa.gov/build/admin/edit/editBuildTasks.action?buildKey=MMT-ARC-BTS
   
## Other Known Issues

During the RAILS 5.2 upgrade, there was an issue with the CSRF authenticity tokens.   Namely, this specific
workflow:  if a user clicks See Review Details, then clicks Curation Home, then clicks Revert Record,
they will get a Invalid Authenticity Token.   Workaround is to tell form_with it should not auto include the
token, rather we should explicitly include it ourselves. i.e.,
`<%= hidden_field_tag :authenticity_token, form_authenticity_token %>`
Note: The above work-around is not necessary on GET requests, only POST, PUT, and DELETE.

See [https://bugs.earthdata.nasa.gov/browse/CMRARC-484] and [https://github.com/rails/rails/issues/24257]
for more details.

## Issues with running puma in daemon mode.
Starting in version 5, puma no longer supports -d.   In order to run it in daemon mode, the 'puma-daemon' gem was added.   Example to launch: `RAILS_ENV=sit bundle exec pumad -C config/puma.rb -e sit`
It is also worth noting that this does not work on a MAC without setting the following env variable: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`, as noted here: https://github.com/rails/rails/issues/38560
