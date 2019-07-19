#!/bin/bash
rpm -i https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.0/x86_64/RPMS/mongodb-org-server-4.0.10-1.amzn2.x86_64.rpm
rpm -i https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.0/x86_64/RPMS/mongodb-org-shell-4.0.10-1.amzn2.x86_64.rpm
rpm -i https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.0/x86_64/RPMS/mongodb-org-tools-4.0.10-1.amzn2.x86_64.rpm
systemctl restart mongod
systemctl enable mongod