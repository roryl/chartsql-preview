/**
 * Represents a process running on a datasource that we can manipulate
*/
component accessors="true" {

	property name="Id" hint="The id of the process";
	property name="Sql" hint="The sql that the process is running";

	public function init(
		required string id,
		required string sql
		){
		setId(arguments.id);
		setSql(arguments.sql);
		return this;
	}

	public function hasExecutionId(required string id){
		var ChartSQL = new ChartSQL();
		var SqlScript = ChartSQL.createSqlScript(variables.Sql);
		var ExecutionId = SqlScript.getExecutionIdTag();
		return ExecutionId == arguments.id;
	}
}