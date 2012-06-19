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

echo "SSH to the slave and create the wal_archive folder"
ssh ${slave_ip} 'rm -rf /var/lib/postgresql/wal_archive/ && mkdir -p /var/lib/postgresql/wal_archive/'
exit_if_failed "Failed to ssh to slave to create wal_archive folder"

echo "Set wal_level to hot_standby"
replace_pgconf_setting wal_level hot_standby

echo "Set the maximum number of concurrent connections from the standby servers."
replace_pgconf_setting max_wal_senders 1

echo "Set the minimum number of segments retained in the pg_xlog directory"
replace_pgconf_setting wal_keep_segments 32

echo "Turn on WAL logging and set the archive_command to ship the WAL files to the slave server"
replace_pgconf_setting archive_mode on
replace_pgconf_setting archive_command "'rsync -av %p postgres@${slave_ip}:\/var\/lib\/postgresql\/wal_archive\/%f'"

echo "Restart postgres"
/etc/init.d/postgresql restart
exit_if_failed "Postgres did not restart properly"

echo "Completed WAL archiving"