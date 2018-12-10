PG_USER=$1
DB_USER=$2
DB_PASS=$3
DB=$4
psql --host postgresql -U ${PG_USER} -c "CREATE USER \"${DB_USER}\" WITH SUPERUSER PASSWORD '${DB_PASS}';"
psql --host postgresql -U ${PG_USER} -c "ALTER DATABASE \"${DB}\" OWNER TO \"${DB_USER}\";"
psql --host postgresql -U ${PG_USER} -c "grant all privileges on database \"${DB}\" to \"${DB_USER}\";"
