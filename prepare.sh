
gem install civo_cli
civo apikey add production $CIVO_API_KEY
civo apikey current production

mkdir -p ~/.ssh/

echo -n $SSH_PUBLIC_KEY > ~/.ssh/id_rsa.pub

# Convert the single line back into multiple lines
echo -n $SSH_PRIVATE_KEY | base64 --decode > ~/.ssh/id_rsa

echo -n $SSH_KEY_ID > $HOME/key_ids.txt
