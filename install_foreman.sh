#!/bin/bash

#
# Command to load this file:
#
# wget https://raw.githubusercontent.com/citec/scripts-public/master/install_foreman.sh && sudo /bin/bash install_foreman.sh
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

# github and grupocitec keys
/usr/bin/ssh-keyscan -H github.com >> /root/.ssh/known_hosts
/usr/bin/ssh-keyscan -H grupocitec.com >> /root/.ssh/known_hosts

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
rm -rf /var/lib/puppet/ssl
puppet cert generate $(hostname -f)
puppet agent --enable --no-daemonize
echo "DONE"

set +e

# Connect to puppet master 
cd /tmp
wget https://raw.githubusercontent.com/citec/scripts-public/master/install_foreman.pp
puppet apply /tmp/install_foreman.pp

echo "Now go to https://$(hostname) and login with 'admin' and 'changeme"
echo ""
echo "Remember to go add this host as SmartProxy"
