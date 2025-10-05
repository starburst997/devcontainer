#!/bin/bash
set -e

echo "Activating personal dev environment settings..."

# Feature options are passed as environment variables
CONFIGURE_HISTORY=${CONFIGUREHISTORY:-true}
CONFIGURE_SSH=${CONFIGURESSH:-true}
CONFIGURE_GITHUB=${CONFIGUREGITHUB:-true}

# Ensure command history directory exists if history is configured
if [ "$CONFIGURE_HISTORY" = "true" ]; then
    echo "Configuring persistent command history..."
    mkdir -p /commandhistory
    touch /commandhistory/.bash_history
fi

echo "Personal dev environment settings activated!"