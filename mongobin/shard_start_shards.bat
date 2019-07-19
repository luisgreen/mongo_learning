start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard1 --auth --keyFile .\keyfile --dbpath .\data\a0 --port 27001 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard1 --auth --keyFile .\keyfile --dbpath .\data\a1 --port 27002 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard1 --auth --keyFile .\keyfile --dbpath .\data\a2 --port 27003 --smallfiles --oplogSize 50 

sleep 2

start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard2 --auth --keyFile .\keyfile --dbpath .\data\b0 --port 27011 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard2 --auth --keyFile .\keyfile --dbpath .\data\b1 --port 27012 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard2 --auth --keyFile .\keyfile --dbpath .\data\b2 --port 27013 --smallfiles --oplogSize 50 

sleep 2

start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard3 --auth --keyFile .\keyfile --dbpath .\data\c0 --port 27021 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard3 --auth --keyFile .\keyfile --dbpath .\data\c1 --port 27022 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard3 --auth --keyFile .\keyfile --dbpath .\data\c2 --port 27023 --smallfiles --oplogSize 50 

sleep 2

start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard4 --auth --keyFile .\keyfile --dbpath .\data\d0 --port 27031 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard4 --auth --keyFile .\keyfile --dbpath .\data\d1 --port 27032 --smallfiles --oplogSize 50 
start /MIN .\bin\mongod.exe --shardsvr --replSet AuxisRepSetShard4 --auth --keyFile .\keyfile --dbpath .\data\d2 --port 27033 --smallfiles --oplogSize 50 