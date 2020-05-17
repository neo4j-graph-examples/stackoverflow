NEO4J_GUIDES=/tmp/neo4j-guides
NAME=name

if [ ! -d $NEO4J_GUIDES ]; then
  git clone https://github.com/neo4j-contrib/neo4j-guides $NEO4J_GUIDES

fi

$NEO4J_GUIDES/run.sh guide.adoc guide.html +1 https://guides.neo4j.com/$NAME
#aws s3 cp guide.html s3://guides.neo4j.com/$NAME/index.html --acl public-read
aws s3 cp guide.html s3://guides.neo4j.com/$NAME --acl public-read
aws s3 cp img s3://guides.neo4j.com/$NAME/img/ --acl public-read --recursive
aws cloudfront create-invalidation  --distribution-id EXDZTP45K2RVV --paths "/$NAME/*"
