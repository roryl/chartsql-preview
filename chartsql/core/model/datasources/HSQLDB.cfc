/**

*/
component
	extends="JdbcDatasource"
	accessors="true"
	isStudioDatasource="true"
	displayName="HyperSQL Database"
	description="Local HyperSQL Database"
	iconClass="ti ti-file-database"
{

	property name="FolderPath" required="true" description="The local folder to store the database file.";
	property name="Database" required="true" description="The name of the database to connect to";
	property name="Username" required="true" description="The username to use when connecting to the database";
	property name="Password" required="true" description="The password to use when connecting to the database";

	public function getConnectionInfo(){

		var path = this.getFolderPath() & server.separator.file;

		//remove double separators
		path = replace(path, server.separator.file & server.separator.file, server.separator.file, "all");

		if(!directoryExists(path)){
			directoryCreate(path, true);
		}

		var finalPath = path & this.getDatabase();
		// writeDump(finalPath);
		var out = {
			class: "org.hsqldb.jdbc.JDBCDriver",
			bundleName: "org.lucee.hsqldb",
			bundleVersion: "2.7.2.jdk8",
			// connectionString: "jdbc:hsqldb:file:C:\websites\chartsql\editor\db\mongo\#this.getDatabase()#",
			connectionString: "jdbc:hsqldb:file:#finalPath#",
			username: "#this.getUsername()#",
			password: "#this.getPassword()#",
			// optional settings
			connectionLimit:-1, // default:-1
			liveTimeout:15, // default: -1; unit: minutes
		}
		return out;
	}

	public void function verify(numeric timeout=5){

		// writeDump(getPageContext());
		// var DatasourceManager = getPageContext().getDatasourceManager();
		// writeDump(DatasourceManager);
		// abort;

		// createObject("java", "lucee.runtime.db.DatasourceManager").getInstance().clearDatasource(this.getConnectionInfo());

		query name="test" datasource="#this.getConnectionInfo()#" timeout="5" {
			echo("SELECT CURRENT_TIMESTAMP FROM (VALUES(0))");
		}

		// writeDump(getMetaData(result));
	}

	/**
	 * Call shutdown on the database which should release it from the connection
	 */
	public void function shutdown(){
		query name="shutdown" datasource="#this.getConnectionInfo()#" timeout="5" {
			echo("SHUTDOWN");
		}
	}

	public function getTableInformationSchema(){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM information_schema.tables
			WHERE 1 = 1
			AND table_schema = 'PUBLIC'; -- Or the appropriate schema name
		";

		var results = this.executeSql(sql);
		// writeDump(results);
		return results;
	}

	public function getTableFieldInformationSchema(string tableName){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM information_schema.columns
			WHERE 1 = 1
			AND table_schema = 'PUBLIC'
			AND table_name = '#tableName#';
		";
		var results = this.executeSql(sql);
		// writeDump(results);
		return results;
	}

}