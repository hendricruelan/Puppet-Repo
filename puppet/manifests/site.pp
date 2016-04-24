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
  # Configure mysql
  class { 'mysql::server':
    root_password => '8ZcJZFHsvo7fINZcAvi0',
  }
  # include mysql::php
  }
