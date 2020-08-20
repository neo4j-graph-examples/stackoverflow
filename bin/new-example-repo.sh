#!/bin/sh
NAME=$1
SANDBOX=${NAME-$2}
DATA=${NAME-$3}
#SCRIPT=${NAME-$4}.cyp
TARGET=`pwd`
TARGET=${TARGET%/*}
echo Creating Repository in $TARGET/$NAME

mkdir -p $TARGET/$NAME
cd $TARGET/$NAME

# data
mkdir -p data
chmod go+w data
cd data 
if [ -f $DATA.db.zip ]; then
for v in "v4_0" "v3_5" "v3_4"; do
  echo Downloading s3://neo4j-sandbox-usecase-datastores/${v}/$DATA.db.zip
  aws s3 cp s3://neo4j-sandbox-usecase-datastores/${v}/$DATA.db.zip . && break
done
fi
# TODO generate dump files for 3.5 and 4.0 (4.1)
if [ -f $DATA.db.zip ]; then
   mkdir -p /tmp/data/databases/
   rm -rf /tmp/data/databases/*
   unzip $DATA.db.zip -d /tmp/data/databases
   DOCKER_ID=`docker run -d -v /tmp/data:/data/ -e NEO4J_dbms_active__database=$DATA.db -e NEO4J_dbms_allow__upgrade=true -e NEO4J_AUTH=neo4j/test -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:3.5-enterprise`
   sleep 10
   echo 'match () return count(*);' > /tmp/test-upgrade.cypher
   REL_COUNT=`docker exec $DOCKER_ID cypher-shell -u neo4j -p test 'match ()-->() return count(*) > 0;'`
   echo Relationships $REL_COUNT
   docker stop $DOCKER_ID
   docker rm $DOCKER_ID
   docker run -v /tmp/data:/data/ -v $(pwd):/dump -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:3.5-enterprise neo4j-admin dump --database $DATA.db --to /dump/$NAME-35.dump
   # todo
   docker run -v $(pwd):/dump -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:3.5-enterprise chown $(id -u):$(id -g) /dump/$NAME-35.dump
   CLEANED=`echo $NAME | sed -e 's/\W//g'`
   echo Cleaned DB name: $CLEANED
   rm -rf /tmp/data
   rm -rf /tmp/data-40/*
   mkdir -p /tmp/data-40/databases
   mkdir -p /tmp/data-40/transactions
   DOCKER_ID=`docker run -d -v /tmp/data-40:/data/ -v $(pwd):/dump -e NEO4J_dbms_allow__upgrade=true -e NEO4J_AUTH=neo4j/test -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:4.0-enterprise`
   sleep 10
   docker logs $DOCKER_ID
   RUNNING=`docker ps -q -f id=$DOCKER_ID`
   
   echo $RUNNING
   if [ "$RUNNING" != "" ]; then
   docker exec $DOCKER_ID neo4j-admin load --database $CLEANED --from /dump/$NAME-35.dump
   docker exec $DOCKER_ID chown neo4j:neo4j -R /data
   docker exec $DOCKER_ID cypher-shell -u neo4j -p test -d system "CREATE DATABASE $CLEANED;"
   sleep 10
   docker exec $DOCKER_ID cypher-shell -u neo4j -p test -d system "START DATABASE $CLEANED;"
   docker exec $DOCKER_ID cypher-shell -u neo4j -p test -d system "SHOW DATABASES;"
   REL_COUNT=`docker exec $DOCKER_ID cypher-shell -u neo4j -p test -d $CLEANED "MATCH ()-->() RETURN count(*)>0;"`
   echo Relationships $REL_COUNT
   docker exec $DOCKER_ID cypher-shell -u neo4j -p test -d system "STOP DATABASE $CLEANED;"
   docker exec $DOCKER_ID neo4j-admin dump --to /dump/$NAME-40.dump --database $CLEANED
   docker exec $DOCKER_ID chown $(id -u):$(id -g) /dump/$NAME-40.dump
   docker stop $DOCKER_ID
   fi
   rm -rf /tmp/data-40
   #TODO sudo chown `whoami`:`whoami` *
fi
cd ..

# guides
mkdir -p documentation
cd documentation
# html guide, images
aws s3 cp --recursive s3://guides.neo4j.com/sandbox/$SANDBOX/ .
# asciidoc guide, images, bloom?
git clone --depth 1 https://github.com/neo4j-contrib/sandbox-guides.git /tmp/sandbox-guides
cp -r /tmp/sandbox-guides/$SANDBOX/* .
mv index.adoc guide.adoc
rm render.sh
mv bloom .. 
cd ..
# import scripts

mkdir -p scripts
cd scripts
aws s3 cp s3://neo4j-sandbox-import-scripts/$SCRIPT import.cypher
cd ..
