#!/bin/bash

PACKAGE_DIR=./package
FEDORA_VERSION=$(cat /etc/redhat-release | awk '{print $3}')

echo "install JDK ..."
if ! command -v java > /dev/null; then
    if (( $FEDORA_VERSION < 17 )); then
        sudo yum install -y java-1.6.0-openjdk
        sudo yum install -y java-1.6.0-openjdk-devel
    else
        sudo yum install -y java-1.7.0-openjdk
        sudo yum install -y java-1.7.0-openjdk-devel
    fi
fi

echo "install ant ..."
if ! command -v ant > /dev/null; then
    sudo yum install -y ant
fi

echo "install MYSQL ..."
if ! command -v mysql > /dev/null; then
    if (( $FEDORA_VERSION < 19 )); then
        sudo yum install -y mysql-server
        sudo yum install -y systemd # for fedora 16
    else 
        sudo yum localinstall -y http://dev.mysql.com/get/mysql-community-release-fc$FEDORA_VERSION-5.noarch.rpm
        sudo yum -y install mysql-community-server
    fi
    sudo service mysqld start
    sudo chkconfig --level 35 mysqld on
    echo "create database openacs" | mysql -uroot
fi

echo "install JBoss ..."
if [ ! -f "/opt/jboss/bin/run.jar" ]; then
    if ! command -v wget > /dev/null; then
        sudo yum install -y wget
    fi
    if ! command -v unzip > /dev/null; then
        sudo yum install -y unzip
    fi
    wget http://sourceforge.net/projects/jboss/files/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA-jdk6.zip -O tmp.zip
    unzip tmp.zip > /dev/null
    sudo mkdir -p /opt/jboss
    sudo mv jboss-4.2.3.GA/* /opt/jboss
    rm -rf tmp.zip jboss-4.2.3.GA
fi

echo "install mysql connector java ..."
if [ ! -f "/usr/share/java/mysql-connector-java.jar" ]; then
    sudo yum install -y mysql-connector-java
fi
if [ ! -f "/opt/jboss/server/default/lib/mysql-connector-java.jar" ]; then
    sudo ln -sf /usr/share/java/mysql-connector-java.jar /opt/jboss/server/default/lib/
fi

echo "install openacs configure file ..."
if [ ! -f "/opt/jboss/server/default/deploy/openacs-ds.xml" ]; then
    cp $PACKAGE_DIR/users.properties $PACKAGE_DIR/roles.properties /opt/jboss/server/default/conf
    cp $PACKAGE_DIR/openacs-ds.xml /opt/jboss/server/default/deploy
fi

echo "================================================================================"
echo "check java version ..."
java -version

echo "check ant version ..."
ant -version

echo "================================================================================"
echo "web url: http://localhost:8080/openacs"
echo "user: admin"
echo "password: openacs"

