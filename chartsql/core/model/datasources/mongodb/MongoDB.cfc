/**
 * Implements a MongoDB datasource
*/
component
	extends="com.chartsql.core.model.Datasource"
	accessors="true"
	isStudioDatasource="true"
	displayName="MongoDB"
	description="MongoDB Database Connector"
	iconClass="ti ti-brand-mongodb"
{
	property name="Username" description="Your MongoDB username" required="true" placeholder="user" order="1";
	property name="Password" description="Your MongoDB password" required="true" placeholder="123456" order="2";
	property name="Host" description="Your MongoDB host" required="true" placeholder="localhost" order="3";
	property name="Port" description="Your MongoDB port" required="true" default="27017" placeholder="27017" order="4";
	property name="Database" description="Your MongoDB database" required="true" placeholder="mydb" order="5";

	public function verify(){
		//Just get the database which should error if it cannot connect
		this.getMongoClient();
		variables.mongoClient.close();
	}

	public function getMongoClient(){

		if(!variables.keyExists("mongoClient")){
			var dbconnection = "mongodb+srv://#this.getUsername()#:#this.getPassword()#@#this.getHost()#/?retryWrites=true&w=majority";
			var MongoClients = createObject("java", "com.mongodb.client.MongoClients");
			var ConnectionString = createObject("java", "com.mongodb.ConnectionString").init(dbconnection);
			var MongoClientSettings = createObject("java", "com.mongodb.MongoClientSettings")
				.builder()
				.applyConnectionString(ConnectionString)
				.build();

			variables.mongoClient = MongoClients.create(MongoClientSettings);
		}
		return variables.mongoclient;
	}

	public function execute(required SqlScript SqlScript){

		var timers = {
			insertRow: 0,
		};

		var setupTick = getTickCount();
			var directives = SqlScript.getParsedDirectives();

			if(!directives.keyExists("mongodb-query")){
				throw("No @mongodb-query directive found");
			}

			if(!isJson(directives["mongodb-query"])){
				throw("Invalid JSON in @mongodb-query directive");
			}

			// Create JAVA based JSON object that we can use to parse the JSON
			var JSON = createObject("java", "com.mongodb.util.JSON");

			// Parse the source JSON query into a CFML structure
			var jsonData = deserializeJson(directives["mongodb-query"]);

			// Get an normalize all of the values from the JSON
			var collectionName = jsonData.collection?:throw("No collection name specified");
			var findMatch = serializeJson(jsonData.find.match?:{});
			var findSort = serializeJson(jsonData.find.sort?:{});
			var findLimit = jsonData.find.limit?:10;
			var findSkip = jsonData.find.skip?:0;
			var findProjection = serializeJson(jsonData.find.projection?:{});
		var timers.setup = getTickCount() - setupTick;

		// Get the mongo client and database connection
		var startTick = getTickCount();
			var mongoClient = this.getMongoClient();
			var databaseConnection = mongoClient.getDatabase(this.getDatabase());
		var timers.connection = getTickCount() - startTick;

		// Get the collection
		var startTick = getTickCount();
			var collection = databaseConnection.getCollection(collectionName);
		var timers.collection = getTickCount() - startTick;

		var startTick = getTickCount();
			var HSQLDB = new core.model.datastores.HSQLDB(
				Database = "mongodb",
				FolderPath = "C:\websites\chartsql\editor\db\mongo\",
				Username = "root",
				Password = "123456"
			);
		var timers.hsqldb = getTickCount() - startTick;



		// Parse the JSON into JAVA objects that mongo collection can use
		var startTick = getTickCount();
			var matchObj = JSON.parse(findMatch);
			var sortObj = JSON.parse(findSort);
			var projectionObj = JSON.parse(findProjection);
		var timers.parseJson = getTickCount() - startTick;


		// Create the find iterable using our query parameters
		var startTick = getTickCount();
			var findIterable = collection.find(matchObj)
				.sort(sortObj)
				.skip(findSkip)
				.limit(findLimit)
				.projection(projectionObj);
		var timers.findIterable = getTickCount() - startTick;

		// Create an array of the projection keys we will use to construct our
		// result table and insert records
		var projectionArray = listToArray(jsonData.find.projection.keyList());

		var startTick = getTickCount();
			var iterator = findIterable.iterator();
		var timers.iterator = getTickCount() - startTick;

		// Iterate through the find results
		var recordCount = 0;
		var processResultTick = getTickCount();
			while (iterator.hasNext()) {
				recordCount++;

				var doc = iterator.next();

				// Parse the JSON result into a CFML structure
				var jsonResult = deserializeJson(doc.toJson());

				// Given the first record, we are going to inspect the data types
				// and create a SQL table that can hold our results and flatten
				// the JSON into a SQL table.
				if(recordCount == 1){

					// Get the data types for each of the columns by inspecing
					// the first record
					var types = []
					for(var key in projectionArray){
						if(isDate(jsonResult[key])){
							types.append("DATETIME");
						} else if(isNumeric(jsonResult[key])){
							types.append("DOUBLE");
						} else {
							types.append("VARCHAR(256)");
						}
					}

					var startTick = getTickCount();
					HSQLDB.dropTable(collectionName);

					// Collect the types with the column names that we will use
					// for the table creation
					var SqlFields = [];
					for(var ii = 1; ii <= arrayLen(projectionArray); ii++){
						SqlFields.append(
							new core.model.datastores.SqlField(
								projectionArray[ii],
								types[ii]
							)
						)
					}

					HSQLDB.createTable(collectionName, SqlFields);
					var timers.tableCreate = getTickCount() - startTick;

				}

				var workingOut = {};
				for(var ii = 1; ii <= arrayLen(projectionArray); ii++){
					if(types[ii] == "DATETIME"){
						var DateTimeObj = ParseDateTime(jsonResult[projectionArray[ii]]);
						var ISODateTime = DateTimeFormat(DateTimeObj, "yyyy-mm-dd HH:nn:ss");
						workingOut[projectionArray[ii]] = ISODateTime;
					} else {
						workingOut[projectionArray[ii]] = jsonResult[projectionArray[ii]];
					}
				}

				var startTick = getTickCount();

				// Inset a row into mongodb datasource
				HSQLDB.insertRow(collectionName, workingOut);
				var timers.insertRow += getTickCount() - startTick;
			}
		var timers.processResult = getTickCount() - processResultTick;

		// Now we can run the original query against the results
		// We use stripDirectives() to remove the @mongodb-query directive and others
		// as we got syntax errors before, even through they should be ignored because
		// they are comments
		var startTick = getTickCount();

			var strippedSql = SqlScript.stripDirectives();
			if(strippedSql contains "@"){
				throw("SQL contains @ symbol");
			}

			var result = HSQLDB.executeSql(SqlScript.stripDirectives());
		var timers.query = getTickCount() - startTick;
		// writeDump(timers);
		return result;

	}

}