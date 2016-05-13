#!/usr/bin/env bash
set -e
set -x
cd /puppet/environments/development/
[ Puppetfile -nt Puppetfile.lock ] && /usr/local/bin/librarian-puppet update
exit 0

apt-get update

MESOS_VERSION=0.18.2
PROTOBUF_VERSION=2.5.0

#Set the hostname
hostname mesos1
echo "mesos1" > /etc/hostname
echo "192.168.56.101    mesos1 jenkins jenkins1 marathon marathon1 aurora aurora1 zookeeper1 nginx1 docker1 chronos chronos1" >> /etc/hosts
echo "192.168.56.102    mesos2 jenkins2 marathon2 aurora2 zookeeper2 nginx2 docker2 chronos2" >> /etc/hosts
echo "192.168.56.103    mesos3 jenkins3 marathon3 aurora3 zookeeper3 nginx3 docker3 chronos3" >> /etc/hosts

#Install base packages
echo "####################################"
echo "Installing base packages........"
echo "####################################"
apt-get -y install g++ python-dev zlib1g-dev libssl-dev libcurl4-openssl-dev libsasl2-modules python-setuptools python-protobuf libsasl2-dev make daemon
apt-get -y install curl git-core mlocate

#Clone Git repo containing config files
echo "###############################################################"
echo "Cloning https://github.com/ahunnargikar/vagrant-mesos........"
echo "###############################################################"
[ -d vagrant-mesos ] || \
   git clone https://github.com/ahunnargikar/vagrant-mesos
cd vagrant-mesos
git pull
cd ..

#Install Java & Maven
echo "####################################"
echo "Installing JDK7 & Maven........"
echo "####################################"
apt-get -y install default-jdk maven
java -version
mvn --version

#Install Docker
echo "####################################"
echo "Installing Docker........"
echo "####################################"
hash docker || curl -sSL https://get.docker.com/ | sh

#Install Zookeeper
echo "####################################"
echo "Installing Zookeeper........"
echo "####################################"
apt-get -y install zookeeperd
echo "1" > /etc/zookeeper/conf/myid
cp vagrant-mesos/zookeeper/zoo.cfg /etc/zookeeper/conf/zoo.cfg

#Install Mesos
echo "####################################"
echo "Installing Mesos........"
echo "####################################"

[ -e mesos_0.28.0-2.0.16.ubuntu1510_amd64.deb ] || \
	curl -O http://repos.mesosphere.com/ubuntu/pool/main/m/mesos/mesos_0.28.0-2.0.16.ubuntu1510_amd64.deb
dpkg -i mesos_0.28.0-2.0.16.ubuntu1510_amd64.deb || \
	apt-get install -fy
cp vagrant-mesos/mesos/mesos/zk /etc/mesos/zk

### #Install protobuf ${PROTOBUF_VERSION}
### echo "####################################"
### echo "Installing Protobuf ${PROTOBUF_VERSION}......."
### echo "####################################"
### rm -rf protobuf*
### wget https://protobuf.googlecode.com/files/protobuf-${PROTOBUF_VERSION}.tar.gz
### tar -xzf protobuf-${PROTOBUF_VERSION}.tar.gz; cd protobuf-${PROTOBUF_VERSION}/
### ./configure
### make
### #make check
### make install
### ldconfig
### protoc --version
### cd ..
### 
#Install Jenkins
echo "####################################"
echo "Installing Jenkins........"
echo "####################################"
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins
update-rc.d jenkins defaults
cp vagrant-mesos/jenkins/jenkins /etc/default/jenkins
cp vagrant-mesos/jenkins/config.xml /var/lib/jenkins/config.xml
cp vagrant-mesos/jenkins/jenkins.model.JenkinsLocationConfiguration.xml /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
mkdir -p /var/lib/jenkins/plugins
cp vagrant-mesos/mesos-plugin/mesos.hpi /var/lib/jenkins/plugins/mesos.hpi
chown -R jenkins:jenkins /var/lib/jenkins/plugins
usermod -g docker jenkins

#Install Marathon
echo "####################################"
echo "Installing Marathon........"
echo "####################################"
#git clone https://github.com/mesosphere/marathon
#cd marathon
#sed -i 's#\(<mesos.version>\).*\(</mesos.version>\)#\1'${MESOS_VERSION}'\2#g' pom.xml
#sed -i 's#\(<protobuf.version>\).*\(</protobuf.version>\)#\1'${PROTOBUF_VERSION}'\2#g' pom.xml
#protoc --java_out=src/main/java/ --proto_path=/usr/local/include/mesos/ --proto_path=src/main/proto/ src/main/proto/marathon.proto
#git status
#mvn package
#cd ..
[ -d /usr/local/marathon ] || { 
	curl -s -O http://downloads.mesosphere.io/marathon/marathon-0.5.1/marathon-0.5.1.tgz
	tar xzf marathon-0.5.1.tgz
	mv marathon-0.5.1 /usr/local/marathon
}
mkdir -p /etc/marathon
cp vagrant-mesos/marathon/marathon.conf /etc/marathon/marathon.conf
cp vagrant-mesos/marathon/marathon.init /etc/init/marathon.conf

#Install & configure Nginx
echo "####################################"
echo "Installing Nginx........"
echo "####################################"
apt-get -y install nginx
cp vagrant-mesos/nginx/app-servers.include /etc/nginx/app-servers.include
cp vagrant-mesos/nginx/nginx.conf /etc/nginx/nginx.conf
rm -rf /etc/nginx/sites-available
cp -rf vagrant-mesos/nginx/sites-available /etc/nginx/sites-available/
update-rc.d nginx defaults

# echo "####################################"
# echo "Rebooting........"
# echo "####################################"
# #reboot
