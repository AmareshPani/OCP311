#!/bin/bash

yum install docker-distribution -y
mkdir /etc/docker-distribution/certs
cd /etc/docker-distribution/certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt
mv /etc/docker-distribution/registry/config.yml /root/original-docker-distribution-config.xml

cat <<EOF > /etc/docker-distribution/registry/config.yml
version: 0.1
log:
  fields:
    service: registry
    environment: development
storage:
    cache:
        layerinfo: inmemory
    filesystem:
        rootdirectory: /opt/docker-registry
    delete:
        enabled: true
http:
    addr: :5000
    tls:
      certificate: /etc/docker-distribution/certs/domain.crt
      key: /etc/docker-distribution/certs/domain.key
    host: https://$HOSTNAME:5000
    secret: testsecret
    relativeurls: false
EOF

systemctl enable docker-distribution
systemctl start docker-distribution

#curl -k https://localhost:5000/v2/_catalog
#echo "** should return blank"

mkdir /etc/docker/certs.d/$HOSTNAME:5000
ansible ocp -a "mkdir /etc/docker/certs.d/$HOSTNAME:5000" -u $USER

cp /etc/docker-distribution/certs/domain.crt /etc/docker/certs.d/$HOSTNAME\:5000/domain.crt
cp /etc/docker-distribution/certs/domain.crt /etc/pki/ca-trust/source/anchors/$HOSTNAME.crt

while : ; do
 read -rp "Do you want to add (or add more) master/worker nodesfor the secured registry? (Yes/No): " choice;
 if [ "$choice" = "No" ] ; then
    break
 else
   read -rp "OpenShift Master/Worker (FQDN): " choice;
   if [ "$choice" != "" ] ; then
      #ar_ocp_masters+=("$choice")
      scp /etc/docker-distribution/certs/domain.crt $choice:/etc/docker/certs.d/$HOSTNAME\:5000/domain.crt
      scp /etc/docker-distribution/certs/domain.crt $choice:/etc/pki/ca-trust/source/anchors/$HOSTNAME.crt
   fi
 fi
done

ansible-playbook nodes.yml --user=$USER
ansible ocp -a "sed -i 's/DOCKHOST/$HOSTNAME\:5000/g' /etc/containers/registries.conf" -u $USER

sed -i 's/DOCKHOST/'"$HOSTNAME"'\:5000/g' /etc/containers/registries.conf