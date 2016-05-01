node /^zk/ {
  # apparently an issue with the change to 'firewalld' but
  # puppet uses iptables.
  if $::osfamily == "redhat" and $::operatingsystemmajrelease == 7 {
    ensure_packages("iptables-services",{'ensure' => "latest"})
    Package["iptables-services"] -> Firewall <| |>
    service { "firewalld":
      enable => false,
      ensure => stopped,
    }
    service { "iptables":
      enable => true,
      ensure => running,
    }
  }

  host { 'zk1.csw.vm':
    ip           => '192.168.56.101',
    host_aliases => 'zk1',
  }
  host { 'zk2.csw.vm':
    ip           => '192.168.56.102',
    host_aliases => 'zk2',
  }
  host { 'zk3.csw.vm':
    ip           => '192.168.56.103',
    host_aliases => 'zk3',
  }
  host { 'ctl1.csw.vm':
    ip           => '192.168.56.101',
    host_aliases => 'ctl1',
  }
  host { 'ctl2.csw.vm':
    ip           => '192.168.56.102',
    host_aliases => 'ctl2',
  }
  host { 'ctl3.csw.vm':
    ip           => '192.168.56.103',
    host_aliases => 'ctl3',
  }
  class { 'zookeeper':
    cdhver               => '5',
    packages             => ['mesosphere-zookeeper.x86_64'],
    service_name         => 'zookeeper',
    manage_service_file  => 'systemd',
    servers              => ['192.168.56.101', '192.168.56.102', '192.168.56.103'],
    repo                 =>  {
      name  => 'mlmesos',
      url   => 'http://repos.mesosphere.io/el/7/$basearch/',
      descr => 'mlmesosphere'
    }
  }
  class { 'mesos':
    zookeeper => [ 'zk1.csw.vm', 'zk2.csw.vm', 'zk3.csw.vm' ],
  }
  class { 'mesos::master':
    work_dir => '/var/lib/mesos',
    options => {
      quorum   => 2
    }
  }
  class { 'marathon':
    notify  => Firewall["100 allow mesos-master access"],
    manage_firewall => false,
    service_name    => 'marathon',
    manage_user     => true,
    user            => 'root',
    options         => {
      master => 'zk://zk1.csw.vm:2181,zk2.csw.vm:2181,zk3.csw.vm:2181/mesos',
      zk     => 'zk://zk1.csw.vm:2181,zk2.csw.vm:2181,zk3.csw.vm:2181/marathon',
    },
  }
  class { 'docker':
  }
  firewall { '100 allow mesos-master access':
    dport   => [ 8080, 5050, 5051, 2181, 2888, 3888, 4040 ],
    proto  => tcp,
    action => accept,
  }
}

node /^ctl/ {
  if $::osfamily == "redhat" and $::operatingsystemmajrelease == 7 {
    ensure_packages("iptables-services",{'ensure' => "latest"})
    Package["iptables-services"] -> Firewall <| |>
    service { "firewalld":
      enable => false,
      ensure => stopped,
    }
    service { "iptables":
      enable => false,
      ensure => stopped,
    }
  }
  class { 'mesos':
    repo => 'mesosphere',
    zookeeper => [ 'zk1.csw.vm', 'zk2.csw.vm', 'zk3.csw.vm' ],
  }
  #  firewall { '100 allow mesos-slave access':
  #    dport   => [ 8080, 5050, 5051, 2181, 2888, 3888 ],
  #    proto  => tcp,
  #    action => accept,
  #  }
  class { 'docker':
  }
  class { 'mesos::slave':
    zookeeper => ['192.168.56.101:2181', '192.168.56.102:2181', '192.168.56.103:2181'],
    attributes => {
      'env' => 'production',
    },
    resources => {
      'ports' => '[10000-65535]'
    },
    options   => {
      'isolation'      => 'cgroups/cpu,cgroups/mem',
      'containerizers' => 'docker,mesos',
      'hostname'       => $::fqdn,
      'ip'             => $::ipaddress_enp0s8,
    }
  }
}

node /^puppet/ {
  class { 'puppetmaster':
  }
  firewall { '100 allow puppet-master access':
    dport   => [ 8080,5050 ],
    proto  => tcp,
    action => accept,
  }
}
