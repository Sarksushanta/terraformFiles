#!/bin/bash

# volume setup
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
#    if [[ $DEVICEEXISTS != "1" ]]; then
#      sleep 15
#    fi
  done
  pvcreate ${DEVICE}
  vgcreate data ${DEVICE}
  lvcreate --name volume1 -l 100%FREE data
  mkfs.ext4 /dev/data/volume1
fi
mkdir -p /var/lib/jenkins
echo '/dev/data/volume1 /var/lib/jenkins ext4 defaults 0 0' >> /etc/fstab
mount /var/lib/jenkins

# install jenkins and docker
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list
sudo apt-get update

#install java 1.8
sudo apt install openjdk-8-jdk openjdk-8-jre -y

#install jenkins unzip docker
sudo apt-get -y install jenkins=${JENKINS_VERSION} unzip docker.io

# enable docker and add perms
sudo usermod -G docker jenkins
sudo systemctl enable docker
sudo service docker start
sudo service jenkins restart

# install python
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.7 -y

## install pip
sudo wget -q https://bootstrap.pypa.io/get-pip.py
#sudo python get-pip.py
sudo python3.7 get-pip.py
sudo rm -f get-pip.py

# install awscli
sudo pip install awscli

#
## install terraform
TERRAFORM_VERSION="0.12.12"
sudo wget -q https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_$${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_$${TERRAFORM_VERSION}_linux_amd64.zip

## clean up
#sudo apt-get clean
#sudo rm terraform_0.7.7_linux_amd64.zip
