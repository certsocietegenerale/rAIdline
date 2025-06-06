docker compose down
docker compose down -v
rm -rf ./data-mongo/*
rm -rf ./temporary_raidline
docker volume rm raidline_raidline_n8n_storage
docker volume rm raidline_raidline_db_storage
rm -r ../data-mongo/*
rm .env
# docker volume prune
