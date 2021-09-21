// install dotnet core on your system
// dotnet new console -o .
// dotnet add package Neo4j.Driver
// paste in this code into Program.cs
// dotnet run

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Neo4j.Driver;
  
namespace dotnet {
  class Example {
  static async Task Main() {
    var driver = GraphDatabase.Driver("neo4j+s://demo.neo4jlabs.com:7687", 
                    AuthTokens.Basic("mUser", "s3cr3t"));

    var cypherQuery =
      @"
      MATCH (t:Tag {name:$tagName})<-[:TAGGED]-(q:Question)<-[:ANSWERED]-(a:Answer {is_accepted:true})<-[:PROVIDED]-(u:User) RETURN u.display_name as answerer
      ";

    var session = driver.AsyncSession(o => o.WithDatabase("stackoverflow"));
    var result = await session.ReadTransactionAsync(async tx => {
      var r = await tx.RunAsync(cypherQuery, 
              new { tagName="neo4j"});
      return await r.ToListAsync();
    });

    await session?.CloseAsync();
    foreach (var row in result)
      Console.WriteLine(row["answerer"].As<string>());
	  
    }
  }
}