// cypher import code goes here

// the query we're using has an added filter which allows us to get the comments and the answers (&filter=!5-i6Zw8Y)4W7vpy91PMYsKM-k9yzEsSC1_Uxlf)

CREATE CONSTRAINT on (q:Question) ASSERT q.uuid IS UNIQUE;
CREATE CONSTRAINT on (t:Tag) ASSERT t.name IS UNIQUE;
CREATE CONSTRAINT on (u:User) ASSERT u.uuid IS UNIQUE;
CREATE CONSTRAINT on (a:Answer) ASSERT a.uuid IS UNIQUE;

// note that stackoverflow considers > 30 request/sec per IP to be very abusive and will throttle the IP maing such a request


// look for several pages of questions

WITH ["neo4j","cypher"] as tags 
UNWIND tags as tagName
UNWIND range(1,10) as page // careful with throttling
WITH "https://api.stackexchange.com/2.3/questions?page="+page+"&pagesize=100&order=desc&sort=creation&tagged="+tagName+"&site=stackoverflow&filter=!5-i6Zw8Y)4W7vpy91PMYsKM-k9yzEsSC1_Uxlf" as url
CALL apoc.load.json(url) YIELD value
CALL apoc.util.sleep(250)
UNWIND value.items AS q
// create the questions
MERGE (question:Question {uuid:q.question_id})
  ON CREATE SET question.title = q.title, 
  	question.link = q.share_link, 
  	question.creation_date = q.creation_date, 
  	question.accepted_answer_id=q.accepted_answer_id, 
  	question.view_count=q.view_count,
   	question.answer_count=q.answer_count,
   	question.body_markdown=q.body_markdown
 // who asked the question
MERGE (owner:User {uuid:coalesce(q.owner.user_id,'deleted')})
  ON CREATE SET owner.display_name = q.owner.display_name
MERGE (owner)-[:ASKED]->(question)
// what tags do the questions have
FOREACH (tagName IN q.tags | MERGE (tag:Tag {name:tagName}) MERGE (question)-[:TAGGED]->(tag))
// who answered the questions?
FOREACH (a IN q.answers |
   MERGE (question)<-[:ANSWERED]-(answer:Answer {uuid:a.answer_id})
    ON CREATE SET answer.is_accepted = a.is_accepted,
    answer.link=a.share_link,
    answer.title=a.title,
    answer.body_markdown=a.body_markdown,
    answer.score=a.score,
   	answer.favorite_score=a.favorite_score,
   	answer.view_count=a.view_count
   MERGE (answerer:User {uuid:coalesce(a.owner.user_id,'deleted')}) 
    ON CREATE SET answerer.display_name = a.owner.display_name
   MERGE (answer)<-[:PROVIDED]-(answerer)
);