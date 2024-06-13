/**
* Base class for JDBC datasources that we can access with SQL
*/
abstract component extends="Datasource" accessors="true" {

	public query function execute(SqlScript){
		var results = "";
		this.executeSql(SqlScript.stripDirectives());
		return result;
	}

	public query function executeSql(string sql){
		var results = "";
		query name="result" datasource="#this.getConnectionInfo()#" {
			echo(sql);
		}
		return result;
	}

	public any function executeDdl(string sql){
		var results = "";
		query name="results" datasource="#this.getConnectionInfo()#" result="results" {
			echo(sql);
		}
		return results;
	}

	public function getConnectionInfo(){
		var out = {
			class: '#this.getClass()#',
			connectionString: 'jdbc:mysql://#this.getHost()#:#this.getPort()#/#this.getDatabase()#?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&allowMultiQueries=true&useLegacyDatetimeCode=false&serverTimezone=UTC',
			username: '#this.getUsername()#',
			password: '#this.getPassword()#',
			timezone:'UTC'
		};

		return out;
	}

	public void function verify(numeric timeout=5){

		query name="test" datasource="#this.getConnectionInfo()#" timeout="#arguments.timeout#" {
			echo("select 1;");
		}

	}

	public function getTableInformationSchema(){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM information_schema.tables
			WHERE 1 = 1
			AND table_schema = '#this.getDatabase()#'; -- Or the appropriate schema name
		";
		var results = this.executeSql(sql);
		return results;
	}

	public function getTableFieldInformationSchema(string tableName){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM information_schema.columns
			WHERE 1 = 1
			AND table_schema = '#this.getDatabase()#'
			AND table_name = '#tableName#';
		";
		var results = this.executeSql(sql);
		return results;
	}

	public TableInfo[] function getTableInfos(){
		var out = [];
		var tables = this.getTableInformationSchema();
		for (var table in tables){
			var tableInfo = new TableInfo(
				Name = table.TABLE_NAME
			);
			out.append(tableInfo);
		}
		return out;
	}

	public FieldInfo[] function getFieldInfos(required string tableName){

		var fieldInformationSchema = this.getTableFieldInformationSchema(
			tableName = arguments.tableName
		)
		var out = [];
		for (var field in fieldInformationSchema){
			var Field = new FieldInfo(
				Name = field.column_name,
				Type = field.column_type?:field.data_type
			);
			out.append(Field);
		}
		return out;
	}

}