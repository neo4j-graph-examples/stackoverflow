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

echo "$QUERY"
echo "----"
echo ${PARAMNAME} ${PARAMVALUE} ${RESULTCOLUMN}

echo "Adding language examples to $TARGET, Hit ctrl-c to abort"
read

mkdir -p $TARGET/code

Q=`/bin/echo -n "$QUERY" | tr '\n' '§'`

for file in */?xample.*; do
    LANG=${file%%/*}
    echo $LANG $file
    mkdir -p $TARGET/code/$LANG
    sed -e "s/<PARAM-NAME>/$PARAMNAME/g" -e "s/<PARAM-VALUE>/$PARAMVALUE/g" -e "s/<QUERY>/$Q/g" -e "s/<RESULT-COLUMN>/$RESULTCOLUMN/g" -e $'s/§/\\\n/g' $file > $TARGET/code/$file
done
