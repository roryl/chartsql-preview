/**

*/
component
	accessors="true"
	extends="com.chartsql.core.model.JdbcDatasource"
	isStudioDatasource="true"
	displayName="SQLite"
	description="SQLite Local Database"
	iconClass="ti ti-file-database"
{

	property name="FolderPath" required="true" description="The local folder to store the database file.";
	property name="Database" required="true" description="The name of the database to connect to";

	public function install(){

		var jarName = "sqlite-jdbc-3.45.1.0.jar";
		var source = getDirectoryFromPath(getCurrentTemplatePath()) & jarName;
		// writeDump(source);
		var destination = expandPath("{lucee-server}../bundles/#jarName#")
		// writeDump(destination);
		if(!fileExists(destination)) {
			fileCopy(source, destination);
		}
	}

	public query function executeSql(string sql){
		var results = "";
		query name="result" datasource="#this.getConnectionInfo()#" result="meta" {
			echo(sql);
		}
		// writeDump(result);

		// ------------------------
		// DATE/TIME CONVERSION
		// ------------------------
		// SQLite date/time is stored as strings and does not have any native date/time types.
		// ChartSQL is expecting date/time types to be returned as date/time types so that it
		// can properly format them in the UI and select a time x-axis.  We need to convert
		// the date/time strings to date/time types in the recordset before it is returned to
		// ChartSQL.  This is done by adding a new column to the result set, converting the
		// date/time string to a date/time type, and then removing the old column.  This is
		// done for each date/time column in the result set.
		//
		// FUTURE IDEA:
		// We might improve this by allowing a datasource to override the getMetaData(result) method
		// so that it can control the datatype of each column for rendering. However, this would
		// still interferre with if we want to do an QoQ on dates and times.


		// Setup some structs which will keep track of which columns are date and date/time
		var dateColumns = {};
		var dateTimeColumns = {};
		var columns = queryColumnArray(result);

		// We are doing to assume that each column is a date column and then prove otherwise
		for(var column in columns){
			dateColumns[column] = true;
		}

		for(var column in columns){
			dateTimeColumns[column] = true;
		}

		// Loop through each column and each row to see if the column is a date column. On the
		// first non-date column row, we will set the dateColumns struct to false for that column
		outer: for(var column in columns){
			for(var row in result){

				// writeDump("#row[column]#: #isDate(row[column])#");

				if(!isDate(row[column])){
					dateColumns[column] = false;
					continue outer;
				}
			}
		}

		// writeDump(dateColumns);

		// Now for any of the columns which were marked as dates, we will convert them
		for(var dateColumn in dateColumns){

			if(dateColumns[dateColumn]){

				// Convert and swap the date column
				var newColumn = dateColumn & "_chartsql_date";
				queryAddColumn(result, newColumn, "datetime");
				var ii = 0;
				for(var row in result){
					ii++;
					var newValue = parseDateTime(row[dateColumn]);
					querySetCell(result, newColumn, newValue, ii);
				}

				queryDeleteColumn(result, dateColumn);

				queryAddColumn(result, dateColumn, "datetime");
				ii = 0;
				for(var row in result){
					ii++;
					querySetCell(result, dateColumn, row[newColumn], ii);
				}

				queryDeleteColumn(result, newColumn);

			}
		}
		return result;
	}

	public struct function getConnectionInfo(){

		this.install();

		var path = this.getFolderPath() & server.separator.file;

		//remove double separators
		path = replace(path, server.separator.file & server.separator.file, server.separator.file, "all");

		if(!directoryExists(path)){
			directoryCreate(path, true);
		}

		var finalPath = path & this.getDatabase();

		var out = {
			class: 'org.sqlite.JDBC',
  			connectionString: 'jdbc:sqlite:#finalPath#'
		}
		return out;
	}

	public void function verify(numeric timeout=5){
		query name="test" datasource="#this.getConnectionInfo()#" timeout="5" {
			echo("SELECT CURRENT_TIMESTAMP FROM (VALUES(0))");
		}
	}

	public function getTableInformationSchema(){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM sqlite_master
		";

		var results = this.executeSql(sql);
		// writeDump(results);
		return results;
	}

	public function getTableFieldInformationSchema(string tableName){
		var tableNames = [];
		var sql = "
			PRAGMA table_info(#arguments.tableName#);
		";
		var results = this.executeSql(sql);
		// writeDump(results);
		return results;
	}

	public TableInfo[] function getTableInfos(){
		var tableInfos = [];
		var tables = this.getTableInformationSchema();
		for (var table in tables){
			var tableInfo = new com.chartsql.core.model.TableInfo(
				Name = table.tbl_name
			);
			tableInfos.append(tableInfo);
		}
		return tableInfos;
	}

	public FieldInfo[] function getFieldInfos(required string tableName){

		var fieldInformationSchema = this.getTableFieldInformationSchema(
			tableName = arguments.tableName
		)
		var out = [];
		for (var field in fieldInformationSchema){
			var Field = new com.chartsql.core.model.FieldInfo(
				Name = field.name,
				Type = field.type
			);
			out.append(Field);
		}
		return out;
	}

}