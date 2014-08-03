#!/bin/bash

#
# Command to load this file:
#
# wget https://bitbucket.org/grupocitec/public/raw/master/install_foreman && sudo /bin/bash install_foreman.sh
#

set -e

# Run only as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Locale
locale-gen pt_BR.UTF-8
dpkg-reconfigure locales

# Install puppet and facter
command -v puppet >/dev/null 2>&1 || { 
    echo "Installing puppet... "
    apt-get install -y puppet facter > /dev/null
    echo "DONE"
    }
command -v facter >/dev/null 2>&1 || { 
    echo "Installing facter... "
    apt-get install -y facter > /dev/null
    echo "DONE"
    }
echo "Stopping puppet service... "
service puppet stop
puppet agent --enable --no-daemonize
echo "DONE"

set +e

# Connect to puppet master 
cd /tmp
wget https://bitbucket.org/grupocitec/public/raw/master/install_foreman.pp
puppet apply /tmp/install_foreman.pp

echo "Now go to https://$(hostname) and login with 'admin' and 'changeme"
echo ""
echo "Remember to go add this host as SmartProxy"
