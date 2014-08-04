#!/bin/bash

#
# Command to load this file:
#
# wget https://bitbucket.org/grupocitec/public/raw/master/install_workstation.sh && sudo /bin/bash install_workstation.sh
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

#bitbucket and grupocitec keys
[ ! -d /root/.ssh ] && mkdir /root/.ssh
/usr/bin/ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts
/usr/bin/ssh-keyscan -H grupocitec.com >> /root/.ssh/known_hosts
getent passwd ops || useradd -d /home/ops -s /bin/bash ops
[ ! -d /home/ops/.ssh ] && mkdir /home/ops/.ssh
/usr/bin/ssh-keyscan -H bitbucket.org >> /home/ops/.ssh/known_hosts
/usr/bin/ssh-keyscan -H grupocitec.com >> /home/ops/.ssh/known_hosts


# Gather some data
oldhostname=$(cat /etc/hostname)

# Change hostname
read -r -p "Do you want to change hostname? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]]
    then
        printf "Enter new hostname: "
        read newHostname
        echo $newHostname > /etc/hostname
        sed -i "s/$oldhostname/$newHostname/g" /etc/hosts
        service hostname restart
fi

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
puppet agent --enable --no-daemonize
echo "DONE"

set +e

# Connect to puppet master 
printf "Connection to puppet master to request authentication... "
printf "Call/Write devops@grupocitec.com and ask for activation of your node ($(hostname -f))"
puppet agent --verbose --server=config.grupocitec.com --test --waitforcert 10
echo "DONE"
read ENTER

# Final message
echo "If you didn't see any error messages, your workstation should be ready"
