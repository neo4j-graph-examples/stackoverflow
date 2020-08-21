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
echo "$QUERY" 
echo
echo Expecting \"$EXPECT\" with {\"$PARAMNAME\": \"$PARAMVALUE\"} returning \"$RESULTCOLUMN\"

#echo "$QUERY"
#echo "----"
#echo ${PARAMNAME} ${PARAMVALUE} ${RESULTCOLUMN}

echo "Adding language examples to $TARGET, Hit ctrl-c to abort"
read

mkdir -p $TARGET/code
#cp -r code $TARGET

Q=`/bin/echo -n "$QUERY" | tr '\n' '§'`

echo $QUERY
lines=`echo $QUERY | wc -l`
echo Lines $lines
echo $Q

URL="neo4j+s:\/\/demo.neo4jlabs.com:7687"
BOLTURL="bolt:\/\/<HOST>:<BOLTPORT>"

for file in */?xample.*; do
    LANG=${file%%/*}
    echo "Updating $LANG $file"
    mkdir -p $TARGET/code/$LANG
    cp $file $TARGET/code/$file
    indent=`grep 'MATCH (m:Movie' $TARGET/code/$file | cut -d'M' -f1 | cut -d'"' -f1`
#    echo "Indent #$indent#"
    if [ $LANG == "java" ]; then
      Q2=`/bin/echo -n "$QUERY" | sed -e "s/\(.*\)/$indent\"\1\" +/g" | tr '\n' '§' | sed -e 's/\+$/;/g'`
    else
      Q2=`/bin/echo -n "$QUERY" | sed -e "s/\(.*\)/$indent\1/g" | tr '\n' '§'`
    fi
#   echo "$Q2"
    sed -i -e "s/^.*MATCH (m:Movie.*$/$Q2/g" $TARGET/code/$file
    mv $TARGET/code/$file $TARGET/code/$file.tmp
    tr '§' '\n' < $TARGET/code/$file.tmp > $TARGET/code/$file
    rm $TARGET/code/$file.tmp

    sed -i -e "s/$URL/$BOLTURL/g" $TARGET/code/$file
    sed -i -e "s/movieTitle/$PARAMNAME/g" $TARGET/code/$file
    sed -i -e "s/The Matrix/$PARAMVALUE/g" $TARGET/code/$file
    sed -i -e "s/actorName/$RESULTCOLUMN/g" $TARGET/code/$file
    # database
    sed -i -e "s/movies/neo4j/g" $TARGET/code/$file
    sed -i -e "s/mUser/<USERNAME>/g" $TARGET/code/$file
    sed -i -e "s/s3cr3t/<PASSWORD>/g" $TARGET/code/$file
done
