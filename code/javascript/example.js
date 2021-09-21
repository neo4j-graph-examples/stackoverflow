// npm install --save neo4j-driver
// node example.js
const neo4j = require('neo4j-driver');
const driver = neo4j.driver('neo4j+s://demo.neo4jlabs.com:7687',
                  neo4j.auth.basic('mUser', 's3cr3t'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

const query =
  `
  MATCH (t:Tag {name:$tagName})<-[:TAGGED]-(q:Question)<-[:ANSWERED]-(a:Answer {is_accepted:true})<-[:PROVIDED]-(u:User) RETURN u.display_name as answerer
  `;

const params = {"tagName": "neo4j"};

const session = driver.session({database:"stackoverflow"});

session.run(query, params)
  .then((result) => {
    result.records.forEach((record) => {
        console.log(record.get('answerer'));
    });
    session.close();
    driver.close();
  })
  .catch((error) => {
    console.error(error);
  });
