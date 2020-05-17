TARGET="movies"
QUERY='
MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie)
WHERE movie.title IN $favorites
RETURN rec.title as title, count(*) as freq
ORDER BY freq DESC LIMIT 5'
PARAMNAME="favorites"
PARAMVALUE="The Matrix"
RESULTCOLUMN="title"
EXPECT="Cloud Atlas"

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
