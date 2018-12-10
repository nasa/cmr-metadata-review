BUILDING AND RUNNING THE DASHBOARD IN A DOCKER CONTAINER

If you haven't already, create a bridged network:
> ./container.sh create-network

Then build the container.   Note the postgresql container must already be started.
> ./container.sh build

Before starting the container, be sure you have a copy the
database.yml and application.yml file provided to you and placed in
the cmr-metadata-review/config directory.

Now you are all set to start the container.
> ./container.sh start

To access the container, type:
> ./container.sh shell

You will now have a shell inside the docker container for you to execute commands.  If this is the first
time setting up the container, you'll need to execute the following commands:

> bundle install
> rake db:create
> rake db:migrate
> rake db:seed

Then you can start up rails:
> rails s -b 0.0.0.0

Adn point your browser to:
http://localhost:3000 to access the dashboard.
