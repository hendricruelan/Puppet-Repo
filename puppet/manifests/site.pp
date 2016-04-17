# Public: Install uTorrent.app into /Applications.
#
# Examples
#
#   include utorrent
class utorrent {
  package { 'utorrent':
    provider => 'appdmg_eula',
    source   => 'http://download-new.utorrent.com/endpoint/utmac/os/osx/track/stable/uTorrent.pkg'
  }
}

node default {
  class { 'pxelinux':
      ensure   => present,
      source   => 'puppet:///modules/pxelinux/viridis-default',
      root_dir => '/srv/tftp'
  }
}

node 'db.puppetlabs.vm' {
  # Configure mysql
  class { 'mysql::server':
    root_password => '8ZcJZFHsvo7fINZcAvi0',
  }
  # include mysql::php
}
