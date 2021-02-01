#!/bin/bash

### BEGIN INIT INFO
### Provides     : Mod_jk
### Supported OS : Ubuntu 18.04
### Description  : Link Apache and Tomcat using Mod_JK Protocol
### END INIT INFO


### Check if this user has sudo privilege or not
if [ "$EUID" -ne 0 ]; then
    echo "##############################################"
    echo ""
    echo "ROOT Privilege is required."
    echo ""
    echo "Usage : sudo ./ubuntu_mod_jk_link.sh"
    echo ""
    echo "##############################################"
    exit
fi


### Set Variable

TOMCAT_CONNECTOR_VER=1.2.48
read -rp "Input Tomcat_IP >>" TOMCAT_IP


### Define Functions

message_show() {
    echo "#############################################"
    echo ""
    echo "$1"
    echo ""
    echo "#############################################"
    sleep 5
}



### Exit immediately if a command exits with a non-zero status
set -e


### Check if this server is Ubuntu or not
if [ $(cat /etc/os-release | grep "^NAME" | awk -F= '{print $2}' | awk -F\" '{print $2}') != 'Ubuntu' ]; then
    message_show "This script is for Ubuntu 18.04 Only"
fi

### Check if this user has sudo privilege or not
if [ "$EUID" -ne 0 ]; then
    echo "##############################################"
    echo ""
    echo "ROOT Privilege is required."
    echo ""
    echo "Usage : sudo ./ubuntu_mod_jk_link.sh"
    echo ""
    echo "##############################################"
    exit
fi


# 1. Prerequisite

apt-get update -y

# Get apxs from this package
apt-get install apache2-dev -y


# 2. Get mod_jk module
message_show "Install tomcat_connector $TOMCAT_CONNECTOR_VER"

cd /usr/local/src

wget http://apache.tt.co.kr/tomcat/tomcat-connectors/jk/tomcat-connectors-$TOMCAT_CONNECTOR_VER-src.tar.gz

tar zxvf tomcat-connectors-$TOMCAT_CONNECTOR_VER-src.tar.gz

APXS_PATH=$(which apxs)

cd tomcat-connectors-$TOMCAT_CONNECTOR_VER-src/native/

./configure --with-apxs="$APXS_PATH"

make; make install

mv apache-2.0/mod_jk.so /usr/local/apache2.4/modules/


# 3. Edit Apache configuration Files
message_show "Edit Apache Configuration Files"


# Edit httpd.conf

message_show "1. httpd.conf"

cat << EOF >> /usr/local/apache2.4/conf/httpd.conf

Include conf/mod_jk.conf

EOF

# Add mod_jk.conf file

message_show "2. mod_jk.conf"

if [ -d /usr/local/apache2.4/runs ]; then

cat << EOF >> /usr/local/apache2.4/conf/mod_jk.conf

JkWorkersFile conf/workers.properties
JkShmFile     runs/mod_jk.shm
JkLogFile     logs/mod_jk.log
JkLogLevel    info
JKMountFile conf/uriworkermap.properties
JKLogStampFormat "[%a %b %d %H:%M:%s %Y]"
JKRequestLogFormat "%w %V %T"

EOF

else

cat << EOF >> /usr/local/apache2.4/conf/mod_jk.conf

JkWorkersFile conf/workers.properties
JkShmFile     logs/mod_jk.shm
JkLogFile     logs/mod_jk.log
JkLogLevel    info
JKMountFile conf/uriworkermap.properties
JKLogStampFormat "[%a %b %d %H:%M:%s %Y]"
JKRequestLogFormat "%w %V %T"

EOF

fi

# Add workers.properties File

message_show "3. workers.properties"


cat << EOF >> /usr/local/apache2.4/conf/workers.properties
##### workers.properties ##
worker.list=worker1
worker.worker1.type=ajp13
worker.worker1.host=$TOMCAT_IP
worker.worker1.port=8009
EOF


# Add uriworkermap.properties

message_show "4. uriworkermap.properties"


cat << EOF >> /usr/local/apache2.4/conf/uriworkermap.properties
/*=worker1
!/*.html=worker1
EOF



message_show "Apache configuration completed.

Please Open 8009 Port in the Tomcat Server.

1. Go to Tomcat Server

2. Open server.xml file using Vim Editor

3. Open 8009 Connector"