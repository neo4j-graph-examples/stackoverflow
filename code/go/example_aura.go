package main
import (
	"fmt"
	"github.com/neo4j/neo4j-go-driver/neo4j"
)
func main() {
	var driver neo4j.Driver
	var err error
	// Aura requires you to use "bolt+routing" protocol, and process your queries using an encrypted connection
	// (You may need to replace your connection details, username and password)
	boltURL := "bolt+routing://<Bolt url for Neo4j Aura database>"
	auth := neo4j.BasicAuth("<Username for Neo4j Aura database>", "<Password for Neo4j Aura database>", "")

	configurers := []func(*neo4j.Config){
		func (config *neo4j.Config) {
			config.Encrypted = true
		},
	}
	if driver, err = neo4j.NewDriver(boltURL, auth, configurers...); err != nil {
		panic(err)
	}

	// Don't forget to close the driver connection when you are finished with it
	defer driver.Close()

	var writeSession neo4j.Session
	// Using write transactions allow the driver to handle retries and transient errors for you
	if writeSession, err = driver.Session(neo4j.AccessModeWrite); err != nil {
		panic(err)
	}
	defer writeSession.Close()

	// To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
	// The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
	createRelationshipBetweenPeopleQuery := `
		MERGE (p1:Person { name: $person1_name })
		MERGE (p2:Person { name: $person2_name })
		MERGE (p1)-[:KNOWS]->(p2)
		RETURN p1, p2`

	var result neo4j.Result
	result, err = writeSession.Run(createRelationshipBetweenPeopleQuery, map[string]interface{}{
		"person1_name": "Alice",
		"person2_name": "David",
	})

	if err != nil {
		panic(err)
	}

	// You should capture any errors along with the query and data for traceability
	if result.Err() != nil {
		panic(result.Err())
	}

	for result.Next() {
		firstPerson := result.Record().GetByIndex(0).(neo4j.Node)
		fmt.Printf("First: '%s'\n", firstPerson.Props()["name"].(string))
		secondPerson := result.Record().GetByIndex(1).(neo4j.Node)
		fmt.Printf("Second: '%s'\n", secondPerson.Props()["name"].(string))
	}

	var readSession neo4j.Session

	if readSession, err = driver.Session(neo4j.AccessModeRead); err != nil {
		panic(err)
	}
	defer readSession.Close()

	readPersonByName := `
		MATCH (p:Person)
		WHERE p.name = $person_name
		RETURN p.name AS name`

	result, err = readSession.Run(readPersonByName, map[string]interface{}{"person_name": "Alice"})

	if err != nil {
		panic(err)
	}

	if result.Err() != nil {
		panic(result.Err())
	}

	for result.Next() {
		fmt.Printf("Person name: '%s' \n", result.Record().GetByIndex(0).(string))
	}
}
