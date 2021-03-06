#! /bin/bash

node_type=$1

# all nodes

echo "install qing agent"
curl -o agent.tar.gz https://pek3a.qingstor.com/appcenter/developer/packages/app-agent-linux-amd64.tar.gz
tar -xvf agent.tar.gz
cd /opt/app-agent-linux-amd64/
./install.sh
rm -rf agent.tar.gz
cd /opt

mkdir tomcat_app
tar -xvf tomcat_app.tar.gz -C /opt/tomcat_app
rm -rf tomcat_app.tar.gz

echo "modify the max notify limit"
#mv /etc/sysctl.d/max-users-watch.conf /etc/sysctl.d/max-users-watch.conf_bak
cp /opt/tomcat_app/installpackages/max-users-watch.conf /etc/sysctl.d
sysctl --system

echo "modify ulimit"
mv /etc/security/limits.conf /etc/security/limits.conf_bak
cp /opt/tomcat_app/installpackages/limits.conf /etc/security

echo "install zip unzip"
yum -y install zip unzip

echo "install net tools"
yum -y install net-tools


# tomcat node
if [ $node_type == "tomcat" ]
then
    echo "instal rsync"
    yum install -y rsync

    echo "install wget"
    yum -y install wget

    echo "install openjdk"
    yum -y install java-1.8.0-openjdk

    echo "install tomcat"
    curl -o tomcat.tar.gz http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-7/v7.0.78/bin/apache-tomcat-7.0.78.tar.gz
    tar -xvf tomcat.tar.gz
    rm -rf tomcat.tar.gz

    echo "deploy scripts and templates"

    mkdir /var/log/tomcat
    mkdir /tmp/war-listen
    mkdir /tmp/war-temp
    mkdir /root/.qingstor


    echo "install pyinotify"
    tar -xvf /opt/tomcat_app/installpackages/tomcat_node/pyinotify.tar.gz
    cd /opt/tomcat_app/installpackages/tomcat_node/pyinotify
    python setup.py install
    cd /opt
    rm -rf pyinotify.tar.gz
    rm -rf pyinotify/
    cp /opt/tomcat_app/installpackages/tomcat_node/tomcat_gc_log.conf /etc/rsyslog.d
    chmod +x /opt/tomcat_app/scripts/*.sh
    mv /opt/apache-tomcat-7.0.78/bin/catalina.sh /opt/apache-tomcat-7.0.78/bin/catalina.sh_bak
    cp /opt/tomcat_app/scripts/*.sh /opt/apache-tomcat-7.0.78/bin
    cp /opt/tomcat_app/scripts/*.py /opt/apache-tomcat-7.0.78/bin
    rm -rf /opt/apache-tomcat-7.0.78/bin/catalina.properties
    cp /opt/tomcat_app/catalina.properties /opt/apache-tomcat-7.0.78/conf
    cp /opt/tomcat_app/lib/*.jar /opt/apache-tomcat-7.0.78/lib
    rm -rf /opt/apache-tomcat-7.0.78/lib/tomcat-juli.jar
    mv /opt/apache-tomcat-7.0.78/bin/tomcat-juli.jar /opt/apache-tomcat-7.0.78/bin/tomcat-juli.jar_bak
    cp /opt/tomcat_app/lib/tomcat-juli.jar /opt/apache-tomcat-7.0.78/bin/
    mv /opt/apache-tomcat-7.0.78/conf/logging.properties /opt/apache-tomcat-7.0.78/conf/logging.properties_bak
    cp /opt/tomcat_app/code/tomcat_node/conf.d/*.toml /etc/confd/conf.d
    cp /opt/tomcat_app/code/tomcat_node/template/*.tmpl /etc/confd/templates
    rm -rf /opt/tomcat_app

    echo "install pip"
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    python get-pip.py

    echo "install qsctl"
    pip install qsctl -U
    rm -rf /opt/get-pip.py
fi

# log server node
if [ $node_type == "log" ]
then 
    cd /opt
    mv /etc/rsyslog.conf /etc/rsyslog.conf_bak
    cp /opt/tomcat_app/installpackages/log_node/rsyslog.conf /etc/
    cp /opt/tomcat_app/code/log_node/conf.d/*.toml /etc/confd/conf.d
    cp /opt/tomcat_app/code/log_node/template/*.tmpl /etc/confd/templates
    rm -rf /opt/tomcat_app
fi

#jenkins node
#wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
#rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
#yum install jenkins



