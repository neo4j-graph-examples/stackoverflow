// Add your the driver dependency to your pom.xml build.gradle etc.
// Java Driver Dependency: http://search.maven.org/#artifactdetails|org.neo4j.driver|neo4j-java-driver|4.0.1|jar
// Reactive Streams http://search.maven.org/#artifactdetails|org.reactivestreams|reactive-streams|1.0.3|jar
// download jars into current directory
// java -cp "*" Example.java

import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

public class Example {

  public static void main(String...args) {

    Driver driver = GraphDatabase.driver("neo4j+s://demo.neo4jlabs.com:7687",
              AuthTokens.basic("mUser","s3cr3t"));

    try (Session session = driver.session(SessionConfig.forDatabase("movies"))) {

      String cypherQuery =
        "MATCH (m:Movie {title:$movieTitle})<-[:ACTED_IN]-(a:Person) RETURN a.name as actorName";

      var result = session.readTransaction(
        tx -> tx.run(cypherQuery, 
                parameters("movieTitle","The Matrix"))
            .list());

      for (Record record : result) {
        System.out.println(record.get("actorName").asString());
      }
    }
    driver.close();
  }
}


