#/bin/sh
NAME=${1-movies}
TARGETPATH=${2-/tmp}
TARGET="$TARGETPATH/$NAME"
if [ ! -d $TARGET ]; then
    git clone https://github.com/neo4j-graph-examples/$name $TARGET
fi

QUERY=`grep -e '^\(:query:\| .*\+$\)' $TARGET/README.adoc | cut -d' ' -f2- | sed -e 's/\+$//g'` 
EXPECT=`grep :expected-result: $TARGET/README.adoc | cut -d' ' -f2-`
PARAMNAME=`grep :param-name: $TARGET/README.adoc | cut -d' ' -f2-`
PARAMVALUE=`grep :param-value: $TARGET/README.adoc | cut -d' ' -f2-`
RESULTCOLUMN=`grep :result-column: $TARGET/README.adoc | cut -d' ' -f2-`

# "Cloud Atlas"
echo For example \"$NAME\" running 
echo $QUERY 
echo Expecting \"$EXPECT\" with {\"$PARAMNAME\": \"$PARAMVALUE\"} returning \"$RESULTCOLUMN\"

BOLTPORT=7687
HOST=localhost
USERNAME=neo4j
PASSWORD=secret
JAVA_DRIVER_VERSION=4.0.1
RX_VERSION=1.0.3

# todo enterprise
DOCKER_ID=`docker run -d -p $BOLTPORT:$BOLTPORT -v $TARGET:/repo  --env NEO4J_AUTH=$USERNAME/$PASSWORD neo4j:3.5`

echo $DOCKER_ID
docker exec $DOCKER_ID sh -c "ls /repo"
# sleep 10

docker logs $DOCKER_ID

# todo also handle dump files
exit

docker exec $DOCKER_ID sh -c "cat /repo/scripts/import.cypher | cypher-shell -u $USERNAME -p $PASSWORD"

echo "Node-Count:"
docker exec $DOCKER_ID cypher-shell -u $USERNAME -p $PASSWORD 'MATCH (n) RETURN count(*);'

CODE=/tmp/code
mkdir -p $CODE
pushd $CODE

npm install --save neo4j-driver 
sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/mUser/$USERNAME/g" -e "s/s3cr3t/$PASSWORD/g" $TARGET/code/javascript/example.js > example.js
node example.js | grep "$EXPECT" || echo "JAVASCRIPT FAIL"

pip install neo4j-driver
sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/mUser/$USERNAME/g" -e "s/s3cr3t/$PASSWORD/g" $TARGET/code/python/example.py > example.py
python example.py | grep "$EXPECT" || echo "PYTHON FAIL"

curl -sOL https://repo1.maven.org/maven2/org/reactivestreams/reactive-streams/${RX_VERSION}/reactive-streams-${RX_VERSION}.jar
curl -sOL https://repo1.maven.org/maven2/org/neo4j/driver/neo4j-java-driver/${JAVA_DRIVER_VERSION}/neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar

sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/mUser/$USERNAME/g" -e "s/s3cr3t/$PASSWORD/g" $TARGET/code/java/Example.java > Example.java

javac -cp neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar Example.java
java -cp neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar:reactive-streams-${RX_VERSION}.jar:. Example  | grep "$EXPECT" || echo "JAVA FAIL"

sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/mUser/$USERNAME/g" -e "s/s3cr3t/$PASSWORD/g" $TARGET/code/go/example.go > example.go
go mod init main
go run example.go | grep "$EXPECT" || echo "GO FAIL"

popd

echo rm -rf $TMP
docker rm -f $DOCKER_ID