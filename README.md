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

1. Install Ruby on your machine.  The production version of the project uses Ruby v 2.5.1. Other versions may work, but only 2.5.1 is currently fully supported.

- You can check which version of ruby you are running with the command `ruby -v`, and the location with `which ruby`

- If the version of ruby that comes up is not 2.5.1 and you are using rvm use the command `rvm list` to list which ruby versions you have. To set the ruby version for the current directory use the command `rvm use 2.5.1`, or to set your default use `rvm --default use 2.5.1`

2. Download the source code from this github repo.

3. The user will then need to setup a local Postgres DB to connect to the app. _\*NOTE: make sure to install Postgres 9.6, because 10.\* is known to cause issues with running tests._

- Macs come pre-installed with PSQL (and a common way to manage it is with [PGAdmin](https://www.pgadmin.org/download/).

- _From the command line/Terminal_ - enter the psql command line with the command `psql`

- You will then be prompted for your password

- I you run into the issue of `password authentication failed for user` – try the command `psql -U postgres -h localhost` and enter in the password for your computer

- If you run into the issue of `psql: FATAL: database "<user>" does not exist` - see [this link](https://stackoverflow.com/questions/17633422/psql-fatal-database-user-does-not-exist)

- Some people may find they need to create an initial database to connect to with `/usr/local/opt/postgresql@9.6/bin/createdb -h localhost`

4. From the PSQL console, you will need to add a `SUPERUSER` matching the username values shown in `config/database.yml` within the project repo. The development & test DB's both are in local Postgres. There are many ways to create a postgres db and superuser.  These links can help –  [here](https://launchschool.com/blog/how-to-install-postgresql-on-a-mac) and [here](https://www.postgresql.org/docs/9.1/static/sql-createrole.html).

- With user information from `config/database.yml`, the commands will look like: `CREATE ROLE <user> WITH SUPERUSER PASSWORD '<password>';`

- Create both the development and test users

- To see if you have a successfully created a user, use the command `\du` in the psql console

- After you have finished creating the users, exit out of the psql console with the command `\q`

5. Start the Postgres server on your machine. This command will depend on how you installed.

6. The user should then navigate into the project directory and run the 'bundle install' command to install all needed dependencies (you might need to do the command `gem install bundler` to get the bundler gem). Sometimes there are build conflicts on the local machine during this process.  Most solutions can be found on stack overflow. If you encounter any bundle install failures, please post the error notice and solution here so they can be updated in the source directory.

	1. If Puma is problematic (as observed on the Mac OS 10.13) , try the following: `gem install puma -v '3.6.2' -- --with-opt-dir=/usr/local/opt/openssl`.

7. Once installation of gems is complete, to create the Database the user should run the commands `rake db:create`, `rake db:migrate`, and rake `db:seed` in that order. These commands will create the db required to run the project.

- The `seeds.rb` file currently will only seed some user data required for testing.

8. To ensure that you've created the proper databases – you can go back into the psql console and use the command `\l`

9. An application.yml file will be needed before starting the server.  This file can only be obtained from a teammate on the project, it does not reside on the repo.  Once received, copy the file into your config folder. The application.yml is set to be ignored by git.  However, if somehow you accidentally commit the file or send the file to the cloud repo, let someone on the team know immediately.  All env variables will need to be reset across platforms to ensure safety of the system.

10. The last piece of software that needs to be installed is python. The production version uses 2.7. Using pip you'll need to install the "requests" package, e.g,:
/usr/bin/pip install requests

11. Now the project should be ready to go. Navigate to the home directory and execute `rails s` to start the server.

12. The homepage will be served at the address `localhost:3000` in your browser. To use the tool locally you will need to:

- Register for an [Earthdata Login account](https://sit.urs.earthdata.nasa.gov/) for the SIT environment.

- Request ACL permissions to access the tool in the SIT environment by emailing [Earthdata Support](mailto:support@earthdata.nasa.gov). In order to Ingest collections into the tool, you may need Admin or Arc Curator permissions as well.

## Other Known Issues

During the RAILS 5.2 upgrade, there was an issue with the CSRF authenticity tokens.   Namely, this specific 
workflow:  if a user clicks See Review Details, then clicks Curation Home, then clicks Revert Record,
they will get a Invalid Authenticity Token.   Workaround is to tell form_with it should not auto include the
token, rather we should explicitly include it ourselves. i.e.,
`<%= hidden_field_tag :authenticity_token, form_authenticity_token %>`

See [https://bugs.earthdata.nasa.gov/browse/CMRARC-484] and [https://github.com/rails/rails/issues/24257]
for more details.

