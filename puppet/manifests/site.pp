node /^zk/ {
  class { 'zookeeper':
    cdhver               => '5',
    packages             => ['mesosphere-zookeeper.x86_64'],
    service_name         => 'zookeeper',
    manage_service_file  => 'systemd',
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
    dport   => [ 8080,5050 ],
    proto  => tcp,
    action => accept,
  }
  class { 'mesos::master':
    work_dir => '/var/lib/mesos',
    options => {
      quorum   => 1
    }
  }
  class { 'marathon':
    manage_firewall => true,
    service_name    => 'marathon',
    manage_user     => true,
    user            => 'root',
    options         => {
      master => 'zk.csw.vm:2181',
    },
  }
}

node /^ctl/ {
  class { 'mesos':
    zookeeper => [ 'zk.csw.vm' ],
  }
  class { 'mesos::slave':
    zookeeper => ['192.168.1.1:2181', '192.168.1.2:2181', '192.168.1.3:2181'],
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
