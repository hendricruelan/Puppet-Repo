# vagrant-cluster
Quickstart for puppet-provisioned mesos cluster (http://mesos.apache.org) and marathon (http://mesosphere.github.io/marathon/).

Start Up
--------
Install
 * Virtualbox (from Oracle)
 * Vagrant    (from HashiCorp)
 * Install plugins
   # vagrant plugin install vagrant-hostmanager
   # vagrant plugin install vagrant-cachier

Clone this, edit the config.yaml to add or remove cattle, and run 'vagrant up'. The execution will download
the base box from my dropbox share and proceed to the provisioning step.

Explore
=======
When provisioning completes, open you browser to http://zk1.vm:5050/#/ to access the Mesos cluster, and http://zk1.vm:8080 for Marathon.

Create
======
Run the script `httpdServer.post` to create two http servers in your marathon instance, feel free to destroy them too. See https://docs.mesosphere.com/usage/tutorials/docker-app/ for other examples.
You can see the created marathon data at http://zk1.vm:8080/#apps/%2Fbridged-webapp and access the served content at http://ctl1.vm:10000/ (for example). 

TODO
====
Add the marathon-lb service instead of marathon. This provides an instance of the HAProxy front end and automatic redirection to running instance(s) of a service.

Hack on Puppet
==============
If you want to experiment with changes or additions in the `puppet/...` folders, try this

```
vagrant ssh zk1
cd /vagrant
./runPuppet
```

This will run `puppet apply` and show you any changes applied. If you change it run `puppet apply --noop`, it will do a dry run.
