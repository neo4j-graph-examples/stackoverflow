// npm install --save neo4j-driver
// node example.js
const neo4j = require('neo4j-driver');
const driver = neo4j.driver('neo4j+s://demo.neo4jlabs.com:7687',
                  neo4j.auth.basic('mUser', 's3cr3t'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

const query =
  `
  MATCH (m:Movie {title:$movieTitle})<-[:ACTED_IN]-(a:Person) RETURN a.name as actorName
  `;

const params = {"movieTitle": "The Matrix"};

const session = driver.session({database:"movies"});

session.run(query, params)
  .then((result) => {
    result.records.forEach((record) => {
        console.log(record.get('actorName'));
    });
    session.close();
    driver.close();
  })
  .catch((error) => {
    console.error(error);
  });
