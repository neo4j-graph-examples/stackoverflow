// dotnet create neo4j-test
// dotnet add Neo4j.Driver
// paste in this code

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Neo4j.Driver;
	
namespace dotnet {
    class Example {
	static async Task Main() {
		var driver = GraphDatabase.Driver("<URL>", 
						AuthTokens.Basic("<USERNAME>", "<PASSWORD>"));

		var cypherQuery =
				@$"
				<QUERY>
				";

		var session = driver.AsyncSession();
		var result = await session.ReadTransactionAsync(async tx =>
		{
			var r = await tx.RunAsync(cypherQuery, 
			                new { <PARAM-NAME>=new[] {"<PARAM-VALUE>"}});
			return await r.ToListAsync();
		});
		await session?.CloseAsync();
		foreach (var row in result)
			Console.WriteLine(row["<RESULT-COLUMN>"].As<string>());
		}
	}
}