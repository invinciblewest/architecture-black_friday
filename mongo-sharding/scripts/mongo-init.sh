#!/bin/bash

###
# Инициализируем сервер конфигурации
###
docker compose exec -T configSrv mongosh --port 27019 <<EOF
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27019" }
    ]
  }
);
EOF

###
# Инициализируем shard1
###
docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
      ]
    }
);
EOF

###
# Инициализируем shard2
###
docker compose exec -T shard2 mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2:27018" },
      ]
    }
);
EOF

###
# Инициализируем роутер
###
echo "Waiting for mongos_router to become healthy..."

until [ "$(docker inspect --format='{{.State.Health.Status}}' mongos_router 2>/dev/null)" = "healthy" ]; do
  echo "mongos_router not healthy yet..."
  sleep 2
done

echo "mongos_router is healthy"

docker compose exec -T mongos_router mongosh <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27018");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF