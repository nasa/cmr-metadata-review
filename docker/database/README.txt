These instructions setup the postgresql database for use by the dashboard (or other apps)

You'll first need to first create a user defined bridged network and
then build the container:
> ./container.sh create-network
> ./container.sh build

Then start it
> ./container.sh start

To stop and remove it, execute:
> ./container.sh stop
> ./container.sh remove

You can connect a client to the postgresql container by:
psql --host localhost --port 5432 -U postgres
(password is root)


