#!/bin/bash

################################################################################
#Make the following call to start and stop the database
#/usr/local/opt/postgresql@9.6/bin/pg_ctl -D /usr/local/var/postgresql@9.6 start

########################################
# make some assumptions

action=start
postgresql_home=/usr/local/opt/postgresql
var=/usr/local/var/postgres
version=

########################################

#print out a usage manual
function manual()
{
  printf "usage: cmd -[1dvsS]\n"
  
  FMT="%5s %-15s %-35s - %s\n"
  #the watch,less command is not in interactive mode
  if [ -t 1 ] ; then
    #interactive mode, show some styles
    FMTH="\e[4m%5s\e[0m \e[4m%-15s\e[0m \e[4m%-35s\e[0m - \e[4m%s\e[0m\n"
  else
    #just use text
    FMTH=$FMT
  fi
  printf "$FMTH" "Flag" "Name" "Definition" "Value"
  printf "$FMT" "-d" "data directory" "directory to read/write database to" "${var}"
  printf "$FMT" "-s" "start" "start the database" "-default-"
  printf "$FMT" "-S" "stop" "stop the databases" ""
  printf "$FMT" "-v" "version" "software version" "${version}"
  printf "$FMT" "-h" "help" "This output" ""
}

########################################
# process the user flags

while getopts 1dhvsS opt
do
	case $opt in
    1)
      version="@9.6"
      var=/usr/local/var/postgresql@9.6
      ;;
    d) var=${OPTARG} ;;
	  s) action=start ;;
    S) action=stop ;;
    v) version=${OPTARG} ;;
    h)
      manual
      exit 1
      ;;
  esac
done

########################################
# build variables based on user flags

PG_CTL=${postgresql_home}${version}/bin/pg_ctl

########################################
# run the command

${PG_CTL} -D ${var} ${action}
