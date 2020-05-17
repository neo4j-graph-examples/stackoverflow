// npm install --save neo4j-driver
// node example.js
var neo4j = require('neo4j-driver');
var driver = neo4j.driver('bolt://<HOST>:<BOLTPORT>', 
                  neo4j.auth.basic('<USERNAME>', '<PASSWORD>'), 
                  {encrypted: 'ENCRYPTION_OFF'});

var query = 
  `<QUERY>`;

var params = {"<PARAM-NAME>": ["<PARAM-VALUE>"]};

var session = driver.session();

session.run(query, params)
  .then(function(result) {
    result.records.forEach(function(record) {
        console.log(record.get('<RESULT-COLUMN>'));
    })
	session.close();
    driver.close();
  })
  .catch(function(error) {
    console.log(error);
  });
