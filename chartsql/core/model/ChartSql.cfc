/**
 * Entry point for ChartSql core libary
*/
component accessors="true" {

	property name="SqlScripts";

	public function init(){
		variables.SqlScripts = [];
	}

	public function createSqlScriptFromPath(required string filePath){
		var SqlScript = new SqlScript( this, filePath );
		return SqlScript;
	}

	public function createSqlScript(string sql){
		var SqlScript = new SqlScript( this, sql?:nullValue() );
		return SqlScript;
	}

}