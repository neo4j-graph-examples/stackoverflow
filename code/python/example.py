# pip install neo4j-driver
# python example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
  "bolt://<HOST>:<BOLTPORT>", 
  auth=basic_auth("<USERNAME>", "<PASSWORD>"))

cypher_query = '''
<QUERY>
'''

with driver.session() as session:
  results = session.read_transaction(
    lambda tx: tx.run(cypher_query,
      <PARAM-NAME>=["<PARAM-VALUE>"]))

  for record in results:
    print(record['<RESULT-COLUMN>'])

driver.close()