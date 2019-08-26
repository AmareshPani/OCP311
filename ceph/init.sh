#!/bin/bash

for host in installationhost \
ceph-osd01.vs.com \
ceph-osd02.vs.com \
ceph-osd03.vs.com ; \
do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done

for host in installationhost \
o1 \
o2 \
o3 ; \
do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done
