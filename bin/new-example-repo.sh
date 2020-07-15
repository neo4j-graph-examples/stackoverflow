#!/bin/sh
NAME=$1
SANDBOX=${NAME-$2}
DATA=${NAME-$3}
#SCRIPT=${NAME-$4}.cyp

mkdir -p $NAME
cd $NAME

# data
mkdir -p data
cd data 
for v in "v4_0" "v3_5" "v3_4"; do
  echo Downloading s3://neo4j-sandbox-usecase-datastores/${v}/$DATA.db.zip
  aws s3 cp s3://neo4j-sandbox-usecase-datastores/${v}/$DATA.db.zip . && break
done
# TODO generate dump files for 3.5 and 4.0 (4.1)
if [ -f $DATA.db.zip ]; then
   mkdir -p /tmp/data/databases/
   unzip $DATA.db.zip -d /tmp/data/databases
   docker run -p 7687:7687 -v /tmp/data:/data/ -e NEO4J_dbms_active__database=$DATA.db -e NEO4J_dbms_allow__upgrade=true -e NEO4J_AUTH=neo4j/test neo4j:3.5
   docker run -v /tmp/data:/data/ neo4j:3.5 -e active database
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
