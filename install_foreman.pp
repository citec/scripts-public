# Creates a file for the apt source
file {'foremanlist':
    path    => '/etc/apt/sources.list.d/foreman.list',
    ensure  => present,
    mode    => 0644,
    content => 'deb http://deb.theforeman.org/ trusty 1.5'
}
->
file {'foremanpluginlist':
    path    => '/etc/apt/sources.list.d/foremanplugin.list',
    ensure  => present,
    mode    => 0644,
    content => 'deb http://deb.theforeman.org/ plugins 1.5'
}
->
exec { "foreman.org":
    command => "/usr/bin/wget -q http://deb.theforeman.org/pubkey.gpg -O - | /usr/bin/apt-key add -",
    unless  => "/usr/bin/apt-key list|/bin/grep -c foreman.org",
}
->
# Call apt-get update which requires the apt key and source file
exec { "apt-update":
    command => "/usr/bin/apt-get update",
    unless  => "/usr/bin/apt-cache search | /bin/grep -c foreman-installer",
}
->
package {'ruby1.9.1-dev':
    ensure => present,
}
->
package { "gem":
    ensure => "installed",
}
->
package {'foreman-installer':
    ensure => present,
}
->
exec {'foreman-installer':
    command => "/usr/sbin/foreman-installer",
}
