GUIDES=/tmp/neo4j-guides
if [ ! -d $GUIDES ]; then
  git clone https://github.com/neo4j-contrib/neo4j-guides $GUIDES;
fi  
REPO=$1
NAME=${REPO##*/}

pushd $REPO

readme_src=`find . -iname "readme.adoc"`
guide=documentation/${NAME}.neo4j-browser-guide

guide_url=`grep -h ':rendered-guide:' ${readme_src} | cut -b 18- | tr -d '\r'`
echo $guide_url

#if [ ! -f ${guide} ]; then
  curl -L "$guide_url" -o ${guide}
  if [ ! -f $guide ]; then
    guide_src=`find documentation -name "*.adoc" | head -1`
    $GUIDES/run.sh $guide_src $guide +1 ""
  fi
#fi

readme=/tmp/${NAME}-readme.html
asciidoctor ${readme_src} -o $readme

zip -j ${NAME}.zip scripts/*.cypher documentation/*.neo4j-browser-guide data/*.dump $readme

popd