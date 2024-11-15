
#!/bin/bash
# This function will retrieve files
N8N_WKFLWS_ID=("qJa6wHpmMEYmGzRp" \
"RUdnumnXGmHLmOXS" \
"tLVrZfdaHkqhbbwI" \
"xL6W3CGZIabbscky" \
"EtnIiEhtTCYxpzuT" \
"Fm9s3HwqRHTL6Lsd" \
"eWEYNeZmT5pA8kEA" \
"9aevxeg2voJv4H4H" \
"DP0Z87X09IwPK62L" \
"RlQBk8rlcxkwJ08A" \
"CJ5YVCTX4firPP7D" \
"6Nth1FoRhbT9VBcf" \
"PjOTpWVyRtzmLD86" \
"k03OTeLG5kNJB9od" \
"UEWqr1HpwjRrC8H9" \
"U5yFfphfOoE0LBql"
)
echo "Importing env"
set -a && source .env && set +a
# If n8n already there ? @ade
env|grep "N8N"
mkdir ./temporary_raidline
# Start the docker-compose
echo "Starting docker compose...."
docker compose up -d

# Wait for docker compose to be started :)

docker compose ps --format "{{.Service}} {{.State}}"

######################
## MATTERMOST SETUP ##
######################
echo "[+] Starting to setup the Mattermost"
# Create a basic admin account
echo "Waiting for MM to finalize initializing"
sleep 20
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."
# Add here the ENV variables for email and MM password
export MATTERMOST_CONTAINER_ID=$(docker inspect --format='{{ .Id }}' $(docker ps -q -f name=raidline-raidline_mattermost-1))
# Add here the ENV variables for email and MM password
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl --local user create --email $MM_USER_EMAIL --username raidline_admin --password $MM_USER_PASSWORD --system-admin
#UPDATE here to pass the ENV value in the container
docker exec -ti $MATTERMOST_CONTAINER_ID bash -c 'echo $MM_USER_PASSWORD >> /tmp/creds.txt'
sleep 1
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl auth login http://localhost:8065 --name raidline --username raidline_admin --password-file /tmp/creds.txt
sleep 1
# Creating a team and setting up the bots.
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl team create --name raidline --display-name "Raidline Response"
sleep 1
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl team users add raidline $MM_USER_EMAIL raidline_admin
sleep 1
docker exec -ti $MATTERMOST_CONTAINER_ID bash -c 'mmctl bot create raidline_gamemaster --display-name gamemaster --with-token | tee /tmp/bot_creds.txt'  
sleep 1
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl team users add raidline raidline_gamemaster 
sleep 1
docker exec -ti $MATTERMOST_CONTAINER_ID mmctl roles system_admin raidline_gamemaster
docker cp $MATTERMOST_CONTAINER_ID:/tmp/bot_creds.txt ./temporary_raidline/
export MATTERMOST_BOT_ACCESS_TOKEN=$(cat ./temporary_raidline/bot_creds.txt | awk 'NR==2 {print; exit}'|cut -d":" -f1)
export MATTERMOST_TEAM_ID=$(docker exec $MATTERMOST_CONTAINER_ID mmctl team list --json| jq '.[].id'| cut -d"\"" -f2)
docker cp ../data-docs/raidline_response_-_player_playbook.json $MATTERMOST_CONTAINER_ID:/tmp/raidline_response_-_player_playbook.json
echo "Creating playbook..."
export MATTERMOST_PLAYBOOK_ID=$(docker exec $MATTERMOST_CONTAINER_ID /bin/bash -c "curl -X POST localhost:8065/plugins/playbooks/api/v0/playbooks/import?team_id=$MATTERMOST_TEAM_ID \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer $MATTERMOST_BOT_ACCESS_TOKEN' \
  --data '@/tmp/raidline_response_-_player_playbook.json'"|jq '.id'|cut -d'"' -f2)

echo "Retrieved $MATTERMOST_PLAYBOOK_ID"

find ../data-docs/workflows/ -type f -name "*json" -exec sed -i "s/MATTERMOST_PLAYBOOK_ID/$MATTERMOST_PLAYBOOK_ID/" {} \; 
  
######################
### mongoDB SETUP  ###
######################
export MONGODB_CONTAINER_ID=$(docker inspect --format='{{ .Id }}' $(docker ps -q -f name=raidline-raidline_mongodb-1))
# Copying files to mongoDB container
docker cp ../mongo $MONGODB_CONTAINER_ID:/tmp/mongo
chmod a+x ./setup_mongo.sh
docker cp ./setup_mongo.sh $MONGODB_CONTAINER_ID:/tmp/
docker exec $MONGODB_CONTAINER_ID bash -c 'chmod a+x /tmp/setup_mongo.sh'
docker exec $MONGODB_CONTAINER_ID bash -c '/tmp/setup_mongo.sh'
# Launching mongo script

######################
##### N8N SETUP  #####
######################

# Build the n8n Credentials file
echo "Generating creds.json file..."

cat creds_template.json|envsubst > ./temporary_raidline/creds.json

# Import the file in n8n
echo "Copying file to n8n..."
export N8N_CONTAINER_ID=$(docker inspect --format='{{ .Id }}' $(docker ps -q -f name=raidline-raidline_n8n-1))
echo "Importing workflows and credentials"
docker cp ./temporary_raidline/creds.json $N8N_CONTAINER_ID:/tmp/
docker exec -it $N8N_CONTAINER_ID n8n import:workflow --separate --input=/home/node/data-docs/workflows
docker exec -it $N8N_CONTAINER_ID n8n import:credentials --input=/tmp/creds.json
echo "Activating workflows"
for wkflw_id in "${N8N_WKFLWS_ID[@]}"; do
    docker exec -it $N8N_CONTAINER_ID n8n update:workflow --id=$wkflw_id --active=true
done
echo "Restarting n8n..."
docker container restart $N8N_CONTAINER_ID
echo "[*] Cleaning up. Deleting ./temporary_raidline"
rm -rf ./temporary_raidline/
echo "Done ! Don't forget to check that all credentials are correctly setup !"
echo "Please visit http://localhost:5678/form/f9cc31d9-9328-40b1-a295-d244a043b13d to setup your environment !"
echo "You can also create your account on http://localhost:8065/"
echo "Finally, the admin panel can be reached via this url : http://localhost:5678/webhook/dba9d340-6994-417b-8cff-7c7abae42a5e"