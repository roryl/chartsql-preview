component
    accessors="true"
    extends="com.chartsql.core.model.Datasource"
{

	property name="FilePath" required="true" description="The local path to the CSV file";
	property name="Name" required="true" description="The name of the table to put the CSV data into";


	public query function execute(SqlScript){
		return this.executeSql(arguments.SqlScript.stripDirectives());
	}

    /**
    * @sql A SQL statement to execute
    * @returns query
    */
    public query function executeSql(string sql) {
		"#variables.Name#" = new cfcsv().parseCSV(file=variables.FilePath);
		query name="data" dbtype="query" {
			echo(arguments.sql);
		}
        return data;
    }

    /**
    * Returns a lucee datasource struct
    */
    public struct function getConnectionInfo() {
        //code...
    }

    /**
    * Throws an error if the datasource connection cannot
    * be verified otherwise we assume it is successfull
    */
    public void function verify(numeric timeout=5){
		var csv = new cfcsv().parseCSV(file=variables.FilePath);
        //code...
    }

    /**
    * Returns an array of TableInfo for ChartSQL to show
    * available table in the schema browser
    */
    public TableInfo[] function getTableInfos(){
	//code...
    }

    /**
    * Returns an array of FieldInfo for ChartSQL to show
    * available fields/columns in the schema browser
    * @tableName A name of a table in the database
    */
    public FieldInfo[] function getFieldInfos(required string tableName){
        //code...
    }

}