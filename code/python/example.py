# pip install neo4j-driver
# python example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
    "bolt://<HOST>:<BOLTPORT>", 
    auth=basic_auth("<USERNAME>", "<PASSWORD>"))
session = driver.session()

cypher_query = '''
<QUERY>
'''

results = session.run(cypher_query,
  parameters={"<PARAM-NAME>":["<PARAM-VALUE>"]})

for record in results:
  print(record['<RESULT-COLUMN>'])
