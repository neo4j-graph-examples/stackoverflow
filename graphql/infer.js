
const neo4j = require("neo4j-driver");
const { inferSchema } = require("neo4j-graphql-js");
const fs = require("fs");
const dotenv = require("dotenv");

dotenv.config();

const driver = neo4j.driver(
  process.env.NEO4J_URI,
  neo4j.auth.basic(process.env.NEO4J_USER, process.env.NEO4J_PASSWORD)
);

const schemaInferenceOptions = {
  alwaysIncludeRelationships: false
};

const updatedPackageJson = {
  scripts: {
    start: "node index.js"
  },
  dependencies: {
    "neo4j-graphql-js": "^2.13.0",
    dotenv: "^8.2.0",
    "apollo-server": "^2.12.0"
  }
};

inferSchema(driver, schemaInferenceOptions).then(result => {
  fs.writeFile("schema.graphql", result.typeDefs, err => {
    if (err) throw err;
    console.log("Updated schema.graphql");
    fs.writeFile("package.json", JSON.stringify(updatedPackageJson, null, 4), err => {
      if (err) throw err;
      console.log("Update package.json");
      process.exit(0);
    })
  });
});