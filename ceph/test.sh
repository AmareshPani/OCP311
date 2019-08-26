#/bin/bash

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
 
        read -rp "Monitor Interface: ($MONINTF) " choice;
        if [ "$choice" != "" ] ; then
                export MONINTF="$choice";
        fi
        read -rp "RADOSGW Interface: ($GWINTF): " choice;
        if [ "$choice" != "" ] ; then
                export GWINTF="$choice";
        fi

        read -rp "Public Network: ($PUBNW) " choice;
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

        echo "* Storage devices: "${arr_strg[@]}""

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

for i in "${arr_strg[@]}"; do echo "$i"; done
