#!/bin/bash

ssh-keygen

#------      Update hosts   -----------#
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

10.100.24.45    installer.vs.com
10.100.24.114   installationhost.vs.com installationhost
10.100.24.114   ceph-dashb.vs.com
10.100.24.116   ocp.vs.com ocp1.vs.com lb lb.vs.com *.apps.datahub.vs.com
10.100.24.116   master01.vs.com master01 ceph-mon01.vs.com mon01 m1
10.100.24.117   master02.vs.com master02 ceph-mon02.vs.com mon02 m2
10.100.24.118   master03.vs.com master03 ceph-mon03.vs.com mon03 m3
10.100.24.119   etcd01.vs.com etcd01 
10.100.24.120   etcd02.vs.com etcd02 
10.100.24.121   etcd03.vs.com etcd03 
10.100.24.122   worker01.vs.com worker01 w1
10.100.24.123   worker02.vs.com worker02 w2
10.100.24.124   worker03.vs.com worker03 w3
10.100.24.125   worker04.vs.com worker04 w4
10.100.24.126   gluster01.vs.com gluster01 ceph-osd01.vs.com o1
10.100.24.127   gluster02.vs.com gluster02 ceph-osd02.vs.com o2
10.100.24.128   gluster03.vs.com gluster03 ceph-osd03.vs.com o3
10.100.24.129   gluster04.vs.com gluster04 ceph-osd04.vs.com o4
10.100.24.116   datahub.vs.com
10.100.24.116   lb.vs.com
EOF

for host in installationhost \
master01.vs.com \
master02.vs.com \
master03.vs.com \
worker01.vs.com \
worker02.vs.com \
worker03.vs.com \
worker04.vs.com \
ceph-osd01.vs.com \
ceph-osd02.vs.com \
ceph-osd03.vs.com ; \
do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done

for host in installationhost \
m1 \
m2 \
m3 \
w1 \
w2 \
w3 \
w4 \
o1 \
o2 \
o3 ; \
do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done
