start .\bin\mongod.exe --configsvr --replSet AuxisRepSetCfg --dbpath .\data\cfg0 --port 27101 --oplogSize 50 
start .\bin\mongod.exe --configsvr --replSet AuxisRepSetCfg --dbpath .\data\cfg1 --port 27102 --oplogSize 50 
start .\bin\mongod.exe --configsvr --replSet AuxisRepSetCfg --dbpath .\data\cfg2 --port 27103 --oplogSize 50 