// npm install --save neo4j-driver
// node example.js
var neo4j = require('neo4j-driver');
var driver = neo4j.driver('neo4j+s://demo.neo4jlabs.com:7687', 
                  neo4j.auth.basic('mUser', 's3cr3t'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

var query = 
  `
  MATCH (m:Movie {title:$movieTitle})<-[:ACTED_IN]-(a:Person) RETURN a.name as actorName
  `;

var params = {"movieTitle": "The Matrix"};

var session = driver.session({database:"movies"});

session.run(query, params)
  .then(function(result) {
    result.records.forEach(function(record) {
        console.log(record.get('actorName'));
    })
	session.close();
    driver.close();
  })
  .catch(function(error) {
    console.log(error);
  });
