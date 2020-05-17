//Install-Package Neo4j.Driver -Version 4.0.1
//Connecting to a 3.5.x Neo4j instance

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Neo4j.Driver;

public class SimpleExample
{
	private readonly IDriver _driver;
	public SimpleExample(string uri, string user, string password)
	{
		_driver = GraphDatabase.Driver(uri, AuthTokens.Basic(user, password), builder => builder.WithEncryptionLevel(EncryptionLevel.None));
	}
	
	public async Task<IEnumerable<string>> Query(string param)
	{
		var cypherQuery =
			  @$"
			  <QUERY>
			  ";
		IAsyncSession session = _driver.AsyncSession();
		var runQuery = await session.ReadTransactionAsync(async tx =>
		{
			var result = await tx.RunAsync(cypherQuery, new { <PARAM-NAME>=new[] {param}});
			return await result.ToListAsync();
		});
		await session?.CloseAsync();
		return runQuery.Select(q => q.Values["<RESULT-COLUMN>"].As<string>());
	}
	
	public static void WriteToConsole(IEnumerable<string> result)
	{
		foreach (var row in result)
			Console.WriteLine(row);
	}
	
	public static async Task Main()
	{
		var example = new SimpleExample("bolt://<HOST>:<BOLTPORT>", "<USERNAME>", "<PASSWORD>");
		var result = await example.Query("<PARAM-VALUE>");
		WriteToConsole(result);
	}
}