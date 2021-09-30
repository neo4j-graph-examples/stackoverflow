// npm install --save neo4j-driver
// node example.js
const neo4j = require('neo4j-driver');
const driver = neo4j.driver('bolt://<HOST>:<BOLTPORT>',
                  neo4j.auth.basic('<USERNAME>', '<PASSWORD>'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

const query =
  `
  MATCH (t:Tag {name:$tagName})<-[:TAGGED]-(q:Question)<-[:ANSWERED]-(a:Answer {is_accepted:true})<-[:PROVIDED]-(u:User)
  RETURN u.display_name as answerer LIMIT 5
  `;

const params = {"tagName": "neo4j"};

const session = driver.session({database:"neo4j"});

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
