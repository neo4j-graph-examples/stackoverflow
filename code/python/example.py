# pip3 install neo4j
# python3 example.py

from neo4j import GraphDatabase, basic_auth

cypher_query = '''
MATCH (t:Tag {name:$tagName})<-[:TAGGED]-(q:Question)<-[:ANSWERED]-(a:Answer {is_accepted:true})<-[:PROVIDED]-(u:User)
RETURN u.display_name as answerer LIMIT 5
'''

with GraphDatabase.driver(
    "neo4j://<HOST>:<BOLTPORT>",
    auth=("<USERNAME>", "<PASSWORD>")
) as driver:
    result = driver.execute_query(
        cypher_query,
        tagName="neo4j",
        database_="neo4j")
    for record in result.records:
        print(record['answerer'])
