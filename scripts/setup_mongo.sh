#!/bin/bash
echo "Running script to setup mongoDB..."
CONNECTION_STRING="mongodb://${MONGODB_INITDB_ROOT_USERNAME}:${MONGODB_INITDB_ROOT_PASSWORD}@raidline_mongodb"
# Look if DB exists in mongo
if [ $(mongosh $CONNECTION_STRING --eval 'db.getMongo().getDBNames().indexOf("game")' --quiet) -lt 0 ]; then
    echo "[+] Creating mongoDB database..."
    mongosh $CONNECTION_STRING --eval 'db.getMongo().getDB("game").createCollection("setup")'
fi

echo "[+] Importing colllections..."
# Loop through all JSON files in the current directory
for file in ./mongo/*.json; do
  # Check if there are any JSON files present
  if [ -f "$file" ]; then
    # Extract the collection name from the filename (removing .metadata.json)
    collection_name=$(basename "$file" .metadata.json)
    # Run mongoimport command for each file
    echo "[+] Importing $collection_name..."
    mongoimport --uri $CONNECTION_STRING --db game --collection "$collection_name" --file "$file" --authenticationDatabase=admin
  fi
done
