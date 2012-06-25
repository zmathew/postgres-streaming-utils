#!/bin/bash

. ./utils.sh

verify_postgres_user

read_value master_ip "Master IP (ie. this server's IP)"
read_value slave_ip "Slave IP"

netstat -tanup | grep ":5432 \+.\+/postgres"
if [ $? -ne 0 ]; then
    echo "Doesn't look like you are running postgres on port 5432."
    exit 1
fi

echo "Configure WAL archiving to slave"
./enable_wal_archiving.sh ${slave_ip}

echo "Perform base backup to slave"
./base_backup.sh ${slave_ip}

echo "Allow slave server to connect to postgres"
replace_pgconf_setting listen_addresses "'${master_ip}, localhost'"

hba_entry="host     replication     postgres        ${slave_ip}/32       trust"
grep "${hba_entry}" /etc/postgresql/9.1/main/pg_hba.conf
if [ $? -ne 0 ]; then
    echo "${hba_entry}" >> /etc/postgresql/9.1/main/pg_hba.conf
fi

echo "Restart postgres"
/etc/init.d/postgresql restart

echo "Done. Please execute ./configure_slave on the SLAVE server."

