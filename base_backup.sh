#!/bin/bash

. ./utils.sh

verify_postgres_user

if [ "$1" != "" ]; then
    slave_ip="$1"
else
    read_value slave_ip "Slave IP"
fi

echo "Shutdown postgres on slave server"
ssh ${slave_ip} '/etc/init.d/postgresql stop'
exit_if_failed "Unable to shutdown postgres on the slave over ssh."

echo "pg_start_backup"
psql -c "select pg_start_backup('base_backup');"
exit_if_failed "pg_start_backup failed."

echo "rsync the base backup to the slave server and overwrite it"
rsync -av /var/lib/postgresql/9.1/main/ postgres@${slave_ip}:/var/lib/postgresql/9.1/main/

echo "pg_stop_backup"
psql -c "select pg_stop_backup();"
exit_if_failed "pg_stop_backup failed."

echo "Completed base backup"