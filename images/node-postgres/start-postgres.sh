#!/bin/bash
set -e

# Check if PostgreSQL is already running
if pgrep -x "postgres" > /dev/null; then
    echo "PostgreSQL is already running"
    exit 0
fi

# Check if data directory exists and has content
if [ ! -d "$PGDATA" ] || [ -z "$(ls -A $PGDATA 2>/dev/null)" ]; then
    echo "Initializing PostgreSQL database..."
    sudo -u postgres /usr/lib/postgresql/${POSTGRES_VERSION}/bin/initdb -D $PGDATA

    # Start PostgreSQL temporarily to set password and create database
    sudo -u postgres /usr/lib/postgresql/${POSTGRES_VERSION}/bin/pg_ctl -D $PGDATA -l /tmp/postgres.log start
    sleep 5

    # Set the postgres password
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_PASSWORD}';"

    # Create the default database if it's not 'postgres'
    if [ "$POSTGRES_DB" != "postgres" ]; then
        sudo -u postgres createdb $POSTGRES_DB
    fi

    # Stop PostgreSQL
    sudo -u postgres /usr/lib/postgresql/${POSTGRES_VERSION}/bin/pg_ctl -D $PGDATA stop
    sleep 2
fi

# Configure PostgreSQL to listen on all interfaces
if ! grep -q "listen_addresses = '\*'" $PGDATA/postgresql.conf; then
    echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf
fi

if ! grep -q "host    all             all             0.0.0.0/0               md5" $PGDATA/pg_hba.conf; then
    echo "host    all             all             0.0.0.0/0               md5" >> $PGDATA/pg_hba.conf
fi

# Start PostgreSQL using supervisor in the background
supervisord -c /etc/supervisor/conf.d/postgres.conf &

echo "PostgreSQL started successfully"
echo "Connection: postgresql://postgres:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB}"
