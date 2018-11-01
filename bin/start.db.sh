#!/bin/bash

################################################################################
#Make the following call to start and stop the database
#/usr/local/opt/postgresql@9.6/bin/pg_ctl -D /usr/local/var/postgresql@9.6 start

# NOTE: Brew installs postgres to /usr/local/opt and uses aliases to match the
# active version.
# >ls -l /usr/local/opt/postgres*
# >ls -l /usr/local/var/postgres*
#
# Example: 
# ./bin/start.db.sh -s -v "@9.6" -d '/usr/local/var/postgresql@9.6'
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
  printf "usage: cmd [-1w] -d <path> -v <@version> [-s|S]\n"
  USAGE_FMT="\tcmd %-15s # %s\n"
  printf "${USAGE_FMT}" -w "list Which version of the database are installed"
  printf "${USAGE_FMT}" "" "start the database"
  printf "${USAGE_FMT}" -s "start the database"
  printf "${USAGE_FMT}" -S "stop the database"
  printf "${USAGE_FMT}" "-v \"@9.6\" -s" "start version 9.6 server"
  printf "\n" 
  
  FMT="%5s %-10s %-10s %-40s - %s\n"
  #the watch,less command is not in interactive mode
  if [ -t 1 ] ; then
    #interactive mode, show some styles
    FMTH="\e[4m%5s\e[0m \e[4m%-10s\e[0m \e[4m%-10s\e[0m \e[4m%-40s\e[0m   \e[4m%s\e[0m\n"
  else
    #just use text
    FMTH=$FMT
  fi
  printf "$FMTH" "Flag" "Params" "Name" "Definition" "Value"
  printf "$FMT" "-d" "<path>" "data" "Override Database data directory." "${var}"
  printf "$FMT" "-s" "" "start" "Start the database." "-default-"
  printf "$FMT" "-S" "" "stop" "Stop the databases." ""
  printf "$FMT" "-v" "<@number>" "version" "Software version, starting with @." "${version}"
  printf "$FMT" "-w" "" "which" "List installed versions of database." ""
  printf "$FMT" "-h" "" "help" "This output." ""
}

########################################
# process the user flags

while getopts 1d:hv:sSw opt
do
	case $opt in
    1)
      version="@9.6"
      var=/usr/local/var/postgresql@9.6
      ;;
    d) var=${OPTARG} ;; #overwrite assumptions
	  s) action=start ;;
    S) action=stop ;;
    v)
      version="${OPTARG}"
      var="/usr/local/var/postgresql${version}" #use versioned path
      ;;
    w) ls -l /usr/local/opt/postgres* ; exit 1 ;;
    h)
      manual
      exit 1
      ;;
  esac
done

########################################
# build variables based on user flags

PG_CTL="${postgresql_home}${version}/bin/pg_ctl"

########################################
# run the command

printf "Launching:\n%s -D %s %s\n\n" "${PG_CTL}" "${var}" "${action}"

if [ -r "${var}" ] ; then
  if [ -x "${PG_CTL}" ] ; then
    ${PG_CTL} -D ${var} ${action}
  else
    printf "Command \"%s\" is not executable.\n" "${PG_CTL}"
  fi
else
  printf "Data directory \"%s\" is not readable.\n" "${var}"
fi
