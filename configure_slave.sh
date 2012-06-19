#!/bin/bash

# Requires wal archiving, base backup and wal archiving to be completed

. ./utils.sh

verify_postgres_user

if [ "$1" != "" ]; then
    master_ip="$1"
else
    read_value master_ip "Master IP"
fi

echo "Stop postgres"
/etc/init.d/postgresql stop
exit_if_failed "Unable to shutdown postgres."

echo "Set wal_level to hot_standby"
replace_pgconf_setting wal_level hot_standby

echo "Turn hot_standby on"
replace_pgconf_setting hot_standby on

echo "Create recovery.conf. The existence of this file will tell postgresql to operate in stand by mode."
echo "
standby_mode = 'on'

# Specifies a connection string which is used for the standby server to connect
# with the primary.
primary_conninfo = 'host=${master_ip} port=5432 user=postgres'

# Specifies a trigger file whose presence should cause streaming replication to
# end (i.e., failover).
trigger_file = '/tmp/postgres-failover.trigger'

# Specifies a command to load archive segments from the WAL archive. If
# wal_keep_segments is a high enough number to retain the WAL segments
# required for the standby server, this may not be necessary. But
# a large workload can cause segments to be recycled before the standby
# is fully synchronized, requiring you to start again from a new base backup.
restore_command = 'cp /var/lib/postgresql/wal_archive/%f \"%p\"'

archive_cleanup_command = '/usr/lib/postgresql/9.1/bin/pg_archivecleanup /var/lib/postgresql/wal_archive/ %r'
" > /var/lib/postgresql/9.1/main/recovery.conf

exit_if_failed "Unable to create recovery.conf file"

echo "Verify that it worked"
grep "standby_mode = 'on'" /var/lib/postgresql/9.1/main/recovery.conf
exit_if_failed "recovery.conf file not configured properly."

echo "Start postgres"
/etc/init.d/postgresql start

echo "Done. Please check the postgres log to make sure things are ok.

tail /var/log/postgresql/postgresql-9.1-main.log
"