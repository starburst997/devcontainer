#!/bin/bash
set -e

echo "Installing PostgreSQL ${VERSION}..."

# Feature options are passed as environment variables
VERSION="${VERSION:-17}"
PASSWORD="${PASSWORD:-postgres}"
DATABASE="${DATABASE:-postgres}"
PORT="${PORT:-5432}"

# Install PostgreSQL
export DEBIAN_FRONTEND=noninteractive

# Add PostgreSQL APT repository
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    sudo

# Add PostgreSQL repository
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install specific PostgreSQL version
apt-get update
apt-get install -y --no-install-recommends \
    postgresql-${VERSION} \
    postgresql-client-${VERSION} \
    postgresql-contrib-${VERSION} \
    supervisor

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

# Create the start script
mkdir -p /usr/local/share/postgres
cat > /usr/local/share/postgres/start.sh << 'EOF'
#!/bin/bash

# Check if PostgreSQL is already running
if pgrep -x "postgres" > /dev/null; then
    echo "PostgreSQL is already running"
    exit 0
fi

# Check if data directory exists and has content
if [ ! -d "/var/lib/postgresql/data" ] || [ -z "$(ls -A /var/lib/postgresql/data 2>/dev/null)" ]; then
    echo "Initializing PostgreSQL database..."
    sudo -u postgres /usr/lib/postgresql/VERSION/bin/initdb -D /var/lib/postgresql/data

    # Start PostgreSQL temporarily to set password
    sudo -u postgres /usr/lib/postgresql/VERSION/bin/pg_ctl -D /var/lib/postgresql/data -l /tmp/postgres.log start
    sleep 5

    # Set the postgres password
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'PASSWORD';"

    # Create the default database if it's not 'postgres'
    if [ "DATABASE" != "postgres" ]; then
        sudo -u postgres createdb DATABASE
    fi

    # Stop PostgreSQL
    sudo -u postgres /usr/lib/postgresql/VERSION/bin/pg_ctl -D /var/lib/postgresql/data stop
    sleep 2
fi

# Configure PostgreSQL to listen on all interfaces
echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/postgresql/data/pg_hba.conf
echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf

# Start PostgreSQL using supervisor in the background
supervisord -c /etc/supervisor/conf.d/postgres.conf &

echo "PostgreSQL started successfully"
EOF

# Replace placeholders in start script
sed -i "s/VERSION/${VERSION}/g" /usr/local/share/postgres/start.sh
sed -i "s/PASSWORD/${PASSWORD}/g" /usr/local/share/postgres/start.sh
sed -i "s/DATABASE/${DATABASE}/g" /usr/local/share/postgres/start.sh
chmod +x /usr/local/share/postgres/start.sh

# Create supervisor configuration
mkdir -p /etc/supervisor/conf.d
cat > /etc/supervisor/conf.d/postgres.conf << EOF
[supervisord]
nodaemon=false
user=root

[program:postgresql]
command=/usr/lib/postgresql/${VERSION}/bin/postgres -D /var/lib/postgresql/data
user=postgres
autostart=false
autorestart=true
stdout_logfile=/var/log/postgresql/postgresql.log
stderr_logfile=/var/log/postgresql/postgresql_error.log
priority=1
stopasgroup=true
killasgroup=true
EOF

# Create log directory
mkdir -p /var/log/postgresql
chown postgres:postgres /var/log/postgresql

# Ensure postgres user has proper permissions
chown -R postgres:postgres /var/lib/postgresql

echo "PostgreSQL ${VERSION} installation complete!"
echo "Database will be initialized on first container start"
echo "Connection: postgresql://postgres:${PASSWORD}@localhost:${PORT}/${DATABASE}"