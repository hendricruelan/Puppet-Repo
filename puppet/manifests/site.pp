node /^zk/ {
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
    zookeeper => [ 'zk.csw.vm' ],
  }
  firewall { '100 allow mesos-master access':
    ensure  => 'absent',
    dport   => [ 8080,5050 ],
    proto  => tcp,
    action => accept,
  }
  class { 'mesos::master':
    work_dir => '/var/lib/mesos',
    options => {
      quorum   => 2
    }
  }
  class { 'marathon':
    manage_firewall => true,
    service_name    => 'marathon',
    manage_user     => true,
    user            => 'root',
    options         => {
      master => '192.168.56.101:2181,192.168.56.102:2181,192.168.56.103:2181',
    },
  }
  class { 'docker':
  }
}

node /^ctl/ {
  class { 'mesos':
    repo => 'mesosphere',
    zookeeper => [ 'zk.csw.vm' ],
  }
  class { 'mesos::slave':
    zookeeper => ['192.168.56.101:2181', '192.168.56.102:2181', '192.168.56.103:2181'],
    attributes => {
      'env' => 'production',
    },
    resources => {
      'ports' => '[10000-65535]'
    },
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
