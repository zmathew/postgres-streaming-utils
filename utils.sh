#!/bin/bash

exit_if_failed() {
    if [ $? -ne 0 ]
    then
        echo $1
        exit 1
    fi
}

replace_pgconf_setting() {
    sed -r s/"^#? *$1 *=.*$"/"$1 = $2"/ /etc/postgresql/9.1/main/postgresql.conf > /etc/postgresql/9.1/main/postgresql.conf.tmp
    exit_if_failed
    mv -f /etc/postgresql/9.1/main/postgresql.conf.tmp /etc/postgresql/9.1/main/postgresql.conf

    # Verify that it worked
    grep "$1 = $2" /etc/postgresql/9.1/main/postgresql.conf
    exit_if_failed "Unable to set $1 to $2"
}

read_value() {
    echo "Please enter a value for $2:"
    read $1
    if [ "${!1}" == "" ]; then
        echo "Invalid value. Exiting"
        exit 1
    fi
}

verify_postgres_user() {
    if [ "`whoami`" != "postgres" ]; then
        echo "Please run this script as the postgres user.";
        exit 1
    fi
}