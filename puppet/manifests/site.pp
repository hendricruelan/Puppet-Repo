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
}

node /^ctl/ {
  # Configure mysql
  class { 'mysql::server':
    root_password => '8ZcJZFHsvo7fINZcAvi0',
  }
  # include mysql::php
}
