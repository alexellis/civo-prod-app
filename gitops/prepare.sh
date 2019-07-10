#!/bin/bash

sudo gem install civo_cli
civo apikey add production "${CIVO_API_KEY}"
civo apikey current production

civo instance list

mkdir -p ~/.ssh/


# Convert the text back into human-readable format:
echo -n $SSH_PUBLIC_KEY | base64 --decode > ~/.ssh/id_rsa.pub
echo -n $SSH_PRIVATE_KEY | base64 --decode > ~/.ssh/id_rsa

echo -n $SSH_KEY_ID > $HOME/key_ids.txt

echo `pwd`
