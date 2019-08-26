#!/bin/bash

export INTERACTIVE=${INTERACTIVE:="true"}
export PVS=${INTERACTIVE:="true"}
export RHUSER=${RHUSER:=}
export RHPW=${RHPW:=}
export OCPPOOLID=${CEPHPOOLID:=8a85f99c6c0f63ae016c209832991d11}
export MONINTF=${MONINTF:=ens192}
export GWINTF=${GWINTF:=ens192}
export PUBNW=${PUBNW:=10.100.24.0/24}
export CLNW=${CLNW:=10.100.24.0/24}
export STRG=${STRG:=/dev/sdb}

declare -a arr_strg
#arr_strg=("$STRG")

## Make the script interactive to set the variables
if [ "$INTERACTIVE" = "true" ]; then

        read -rp "Red Hat Username: " choice;
        if [ "$choice" != "" ] ; then
                export RHUSER="$choice";
        fi

        read -rp "Red Hat Password: " choice;
        if [ "$choice" != "" ] ; then
                export RHPW="$choice";
        fi

        read -rp "CEPH Pool ID: ($CEPHPOOLID): " choice;
        if [ "$choice" != "" ] ; then
                export CEPHPOOLID="$choice";
        fi

        read -rp "Monitor Interface: ($MONINTF): " choice;
        if [ "$choice" != "" ] ; then
                export MONINTF="$choice";
        fi
        read -rp "RADOSGW Interface: ($GWINTF): " choice;
        if [ "$choice" != "" ] ; then
                export GWINTF="$choice";
        fi

        read -rp "Public Network: ($PUBNW): " choice;
        if [ "$choice" != "" ] ; then
                export PUBNW="$choice";
        fi
        read -rp "Cluster Network: ($CLNW): " choice;
        if [ "$choice" != "" ] ; then
                export CLNW="$choice";
        fi

        read -rp "Storage Device (eg: /dev/sdb): " choice;
        if [ "$choice" != "" ] ; then
                arr_strg=("$choice")
        fi

        while : ; do
          read -rp "Add more storage device? (Yes/No): " choice;
          if [ "$choice" = "No" ] ; then
            break
          else
            read -rp "Storage Device (eg: /dev/sdb): " choice;
            if [ "$choice" != "" ] ; then
                arr_strg+=("$choice")
            fi
          fi

        done
fi

echo "******"
echo "* Red hat User: $RHUSER "
echo "* Red hat Password: $RHPW "
echo "* Red hat CEPH pool ID: $OCPPOOLID "
echo "* Ceph MONs Interface: $MONINTF "
echo "* Ceph RADOSGW Interface: $GWINTF "
echo "* Ceph Public Network: $PUBNW "
echo "* Ceph Cluster Netwrok: $CLNW "
echo "* Storage devices: "${arr_strg[@]}""
echo "******"

## Make the script interactive to set the variables
if [ "$INTERACTIVE" = "true" ]; then

        read -rp "Do you want to continue? (Yes/No): " choice;
        if [ "$choice" = "No" ] ; then
                echo "User exited!"
                exit 0
        fi
fi

ansible osds -a "subscription-manager clean" -u $USER
echo "ansible osds -a "subscription-manager register --username $RHUSER --password $RHPW --auto-attach" -u $USER"
ansible osds -a "subscription-manager register --username $RHUSER --password $RHPW --auto-attach" -u $USER
ansible osds -a "subscription-manager refresh" -u $USER

##ansible mons -a "subscription-manager register --username $RHUSER --password $RHPW --auto-attach" -u $USER
ansible ceph -a "subscription-manager attach --pool=$CEPHPOOLID" -u $USER
ansible osds -a "subscription-manager repos --disable='*' --enable='rhel-7-server-rpms' --enable='rhel-7-server-extras-rpms'" -u $USER
ansible osds -a "yum -y update" -u $USER
ansible ceph -a "yum install yum-utils vim -y" -u $USER
ansible ceph -a "yum-config-manager --disable epel" -u $USER

ansible mons -a "subscription-manager repos --enable=rhel-7-server-rhceph-3-mon-rpms" -u $USER
ansible mons -a "firewall-cmd --zone=public --add-port=6789/tcp" -u $USER
ansible mons -a "firewall-cmd --zone=public --add-port=6789/tcp --permanent" -u $USER

ansible-playbook ceph.yml --user=$USER

# OSD's
echo "Prepare OSD's"
ansible osds -a "subscription-manager repos --enable=rhel-7-server-rhceph-3-osd-rpms" -u $USER
ansible osds -a "firewall-cmd --zone=public --add-port=6800-7300/tcp" -u $USER
ansible osds -a "firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent" -u $USER

# On the installation host
subscription-manager attach --pool=$CEPHPOOLID
subscription-manager repos --enable=rhel-7-server-rhceph-3-tools-rpms --enable=rhel-7-server-ansible-2.6-rpms
yum install ceph-ansible -y
ls ~/
mkdir ~/ceph-ansible-keys
ln -s /usr/share/ceph-ansible/group_vars /etc/ansible/group_vars
cd /usr/share/ceph-ansible
cp group_vars/all.yml.sample group_vars/all.yml
cp group_vars/osds.yml.sample group_vars/osds.yml
cp site.yml.sample site.yml

echo '##****** Start of VS change' >> group_vars/all.yml 
echo 'ceph_origin: repository' >> group_vars/all.yml
echo 'ceph_repository: rhcs' >> group_vars/all.yml
echo 'ceph_repository_type: cdn' >> group_vars/all.yml
echo 'ceph_rhcs_version: 3' >> group_vars/all.yml
echo "monitor_interface: $MONINTF" >> group_vars/all.yml
echo "radosgw_interface: $GWINTF" >> group_vars/all.yml
echo "public_network: $PUBNW" >> group_vars/all.yml
echo "cluster_network: $CLNW" >> group_vars/all.yml
echo '##****** End of VS change' >> group_vars/all.yml

echo '##****** Start of VS change' >> group_vars/osds.yml
echo 'osd_objectstore: bluestore' >> group_vars/osds.yml
echo 'osd_scenario: lvm' >> group_vars/osds.yml
echo 'devices:' >> group_vars/osds.yml
#echo '  - "$SDRG"' >> group_vars/osds.yml
for i in "${arr_strg[@]}"; do echo "  - $i" >> group_vars/osds.yml; done
echo '##****** End of VS change' >> group_vars/osds.yml

echo "Ceph config complete"

cd /usr/share/ceph-ansible
ansible-playbook site.yml




