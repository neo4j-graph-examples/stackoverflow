// todo add minimal maven/gradle file
// Java Driver Dependency: http://search.maven.org/#artifactdetails|org.neo4j.driver|neo4j-java-driver|4.0.1|jar
// Reactive Streams http://search.maven.org/#artifactdetails|org.reactivestreams|reactive-streams|1.0.3|jar
// javac -cp neo4j-java-driver-*.jar Example.java && java -cp neo4j-java-driver-*.jar:reactive-streams-*.jar:. Example

import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

import static java.util.Arrays.asList;
import static java.util.Collections.singletonMap;

public class Example {

    public static void main(String...args) {
        Driver driver = GraphDatabase.driver("bolt://<HOST>:<BOLTPORT>",
                           AuthTokens.basic("<USERNAME>","<PASSWORD>"));
        try (Session session = driver.session()) {

            String cypherQuery =
                """
                <QUERY>
                """;

            Result result = session.readTransaction(
                tx -> tx.run(cypherQuery, 
                             parameters("<PARAM-NAME>",asList("<PARAM-VALUE>"))));

            while (result.hasNext()) {
                System.out.println(result.next().get("<RESULT-COLUMN>").asString());
            }
        }
        driver.close();
    }
}


