# pip3 install neo4j-driver
# python3 example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
  "neo4j+s://demo.neo4jlabs.com:7687",
  auth=basic_auth("mUser", "s3cr3t"))

cypher_query = '''
MATCH (t:Tag {name:$tagName})<-[:TAGGED]-(q:Question)<-[:ANSWERED]-(a:Answer {is_accepted:true})<-[:PROVIDED]-(u:User) RETURN u.display_name as answerer
'''

with driver.session(database="stackoverflow") as session:
  results = session.read_transaction(
    lambda tx: tx.run(cypher_query,
                      tagName="neo4j").data())
  for record in results:
    print(record['answerer'])

driver.close()
