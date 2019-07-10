#!/bin/bash

export HOSTNAME="gitops-prod.example.com"

civo apikey current production

civo instance show "${HOSTNAME}"
export EXISTS=$?
export TEMPLATE="811a8dfb-8202-49ad-b1ef-1e6320b20497"

if [ "${EXISTS}" -ne "0" ]
then
    civo instance create \
    ${HOSTNAME} \
    --template=${TEMPLATE} \
    --ssh="${SSH_KEY_ID}"
fi

# Instance takes 40 secs +/- to build
for i in {0..120}; do
    civo instance show "${HOSTNAME}" > instance.txt
    grep "ACTIVE" instance.txt

    if [ "$?" -eq "0" ]
    then
        echo "VM found, and active"

        export IP=$(grep "Public IP" instance.txt | cut -d ">" -f2 |tr -d " ") 
        echo $IP
        ssh -oStrictHostKeyChecking=no root@$IP "sudo apt update && sudo apt install -qy nginx"
        scp -r -oStrictHostKeyChecking=no webroot root@$IP:~/webroot
        ssh -oStrictHostKeyChecking=no root@$IP "sudo rm -rf /var/www/html/* && sudo cp -r webroot/* /var/www/html/"

        break
    fi

    sleep 10
done
