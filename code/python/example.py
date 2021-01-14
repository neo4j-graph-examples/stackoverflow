# pip3 install neo4j-driver
# python3 example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
  "neo4j+s://demo.neo4jlabs.com:7687",
  auth=basic_auth("mUser", "s3cr3t"))

cypher_query = '''
MATCH (m:Movie {title:$movieTitle})<-[:ACTED_IN]-(a:Person) RETURN a.name as actorName
'''

with driver.session(database="movies") as session:
  results = session.read_transaction(
    lambda tx: tx.run(cypher_query,
                      movieTitle="The Matrix").data())
  for record in results:
    print(record['actorName'])

driver.close()
