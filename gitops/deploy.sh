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
    --ssh-key="${SSH_KEY_ID}"
fi

# Instance takes 40 secs +/- to build
for i in {0..120}; do
    echo "Checking instance status, attempt: $i"

    civo instance show "${HOSTNAME}" > instance.txt
    grep "ACTIVE" instance.txt

    if [ "$?" -eq "0" ]
    then
        echo "VM found, and active"

        export IP=$(grep "Public IP" instance.txt | cut -d ">" -f2 |tr -d " ") 
        echo $IP

        ssh -i $HOME/.ssh/id_rsa -oStrictHostKeyChecking=no civo@$IP "uptime"
        # SSH may not be up and running yet, so continue
        if [ "$?" -ne "0" ]
        then
            sleep 5
            continue
        fi

        scp -i $HOME/.ssh/id_rsa -r -oStrictHostKeyChecking=no webroot civo@$IP:~/
        ssh -i $HOME/.ssh/id_rsa -oStrictHostKeyChecking=no civo@$IP "sudo rm -rf /var/www/html/* && sudo cp -r webroot/* /var/www/html/"
        ssh -i $HOME/.ssh/id_rsa -oStrictHostKeyChecking=no civo@$IP "sudo apt update && sudo apt install -qy nginx"

        break
    fi

    sleep 10
done
