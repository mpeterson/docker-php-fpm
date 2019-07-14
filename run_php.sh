#!/bin/bash
if [[ ! "$(ls -A $DATA_DIR)" ]]; then
    cp -a /var/.www.orig/. $DATA_DIR 2>/dev/null || :
fi

# Make docker env variables available from within fpm
CONF_FILE=/etc/php/7.2/fpm/pool.d/www.conf
# Function to update the fpm configuration to make the service environment variables available
function setEnvironmentVariable() {

    if [ -z "$2" ]; then
            echo "Environment variable '$1' not set."
            return
    fi

    # Check whether variable already exists
    if grep -q $1 $CONF_FILE; then
        # Reset variable
        sed -i -e "s|^env\[$1.*|env[$1] = $2|g" $CONF_FILE
    else
        # Add variable
        echo "env[$1] = $2" >> $CONF_FILE
    fi
}

# Clean all docker env variables
sed -i -e "/^env[.*_PORT_.*]/d" $CONF_FILE

# Grep for variables that look like docker set them (_PORT_)
for _curVar in `env | grep _PORT_ | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    setEnvironmentVariable ${_curVar} ${!_curVar}
done

mkdir -p /run/php

/usr/sbin/php-fpm7.2 -F >> /var/log/php7.2-fpm.log
