postgres-streaming-utils
========================

This tool makes it easy to setup PostgreSQL Streaming Replication between a two server cluster by automating the configuration.

Only tested on Ubuntu 10.04, but should work elsewhere as they are just shell scripts.


Usage
-----

1. Make sure you have satisfied the prerequisites (see below).

1. On the master server:

        # Need to run this as postgres user
        sudo su postgres
        ./configure_master.sh


1. Then, on the slave server:

        # Need to run this as postgres user
        sudo su postgres
        ./configure_slave.sh



Prerequisites
-------------

1. You need to have Postgresql 9.X installed. If you are running 8.4 on Ubuntu 10.04, you can upgrade:

        # This needs to be done on both master and slave

        # First remove postgresql 8.4 (warning: this will wipe out existing dbs)
        sudo aptitude purge postgresql-8.4
        sudo apt-get install python-software-properties

        # Add the repo that contains the backport
        sudo add-apt-repository ppa:pitti/postgresql
        sudo apt-get update

        sudo apt-get install postgresql-9.1 libpq-dev postgresql-contrib-9.1
        # libpq is required for the standby servers to connect to master for streaming replication
        # postgresql-contrib is for the pg_archivecleanup command


1. You will need to allow passwordless ssh access for the postgres user from master to the slave:

        # On the master

        sudo su postgres

        # Generate ssh key (if one doesn't already exist)
        ssh-keygen -t dsa

        cat ~/.ssh/id_dsa.pub

        # Copy the public key over to the slave
        ssh-copy-id -i ~/.ssh/id_rsa.pub postgres@<REPLACEWITH_slave_ip>
        # Alternatively, you can manually paste the public key into the `~/.ssh/authorized_keys` file on the slave.

        # Verify it worked
        ssh <REPLACEWITH_slave_ip>
        exit

