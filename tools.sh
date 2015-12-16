#! /bin/bash

#pré requis
apt-get update
apt-get install -y nano curl wget ntpdate

#time
ntpdate -u ntpsophia.sophia.cnrs.fr