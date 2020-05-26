#!/bin/bash

## Composer project name instead of git main folder name
export COMPOSE_PROJECT_NAME=mongodbdocker

## Generate global auth key between cluster nodes
openssl rand -base64 756 > /home/emp-03/mongo/mongodb.key
chmod 400 /home/emp-03/mongo/mongodb.key
chown 999:999 /home/emp-03/mongo/mongodb.key

## Attach some logs
docker-compose logs -t -f --tail 10
## Start the whole stack
docker-compose up -d 

## delay until the shards are already running
sleep 15

## Config servers setup
docker exec -it mongodbdocker_mongo-configserver-01_1 sh -c "mongo --port 27017 < /mongo-configserver.init.js"

## delay until the shards are already running
sleep 15

## Shard servers setup
docker exec -it mongodbdocker_mongo-shard-01a_1 sh -c "mongo --port 27018 < /mongo-shard-01.init.js" 
## delay until the shards are already running
sleep 15
docker exec -it mongodbdocker_mongo-shard-02a_1 sh -c "mongo --port 27019 < /mongo-shard-02.init.js"
## delay until the shards are already running
sleep 15
docker exec -it mongodbdocker_mongo-shard-03a_1 sh -c "mongo --port 27020 < /mongo-shard-03.init.js"

## Apply sharding configuration
sleep 15
docker exec -it mongodbdocker_mongo-router-01_1 sh -c "mongo --port 27017 < /mongo-sharding.init.js"

## delay until the shards are already running
sleep 15
## Enable admin account
docker exec -it mongodbdocker_mongo-router-01_1 sh -c "mongo --port 27017 < /mongo-auth.init.js"
