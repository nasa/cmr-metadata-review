PG_USER=$1
DB_NAME=$2

psql --host postgresql -U ${PG_USER} -c "CREATE DATABASE ${DB_NAME};"
