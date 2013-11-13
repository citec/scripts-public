#!/bin/bash

# Run only as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Gather some data
oldhostname=$(cat /etc/hostname)

# Install puppet and facter
apt-get install puppet facter > /dev/null

# Change hostname
echo "Enter new hostname: "
read newHostname
echo $newHostname > /etc/hostname
sed -i "s/$oldhostname/$newHostname/g" /etc/hosts
service hostname restart

# Connect to puppet master 
printf "Connection to puppet master to request authentication..."
puppet agent --server=puppet.grupocitec.com --no-daemonize --onetime 2>&1 > /dev/null
echo "DONE"
printf "Now go to GrupoCITEC's OpenERP and authorize your host, then press enter"
read ENTER

# Connect to puppet master 
echo "Installing workstation..."
puppet agent --server=puppet.grupocitec.com --no-daemonize --onetime --verbose
echo "DONE"

# Final message
echo "If you didn't see any error messages, your workstation should be ready"