/**

*/
import com.chartsql.core.model.TableInfo;
import com.chartsql.core.model.FieldInfo;
import com.chartsql.core.model.DatasourceProcess;
component
	extends="com.chartsql.core.model.JdbcDatasource"
	accessors="true"
	isStudioDatasource="true"
	displayName="PostgreSQL Database"
	description="PostgreSQL Database connnector or PostgreSQL wire protocol"
	iconClass="ti ti-sql"
{
	property name="Class" default="org.postgresql.Driver" description="The class name of the JDBC driver to use";
	property name="Port" default="5432" description="The port number of the PostgreSQL server";
	property name="Host" required="true" description="The host name of the database server";
	property name="Database" required="true" description="The name of the database to connect to";
	property name="Username" required="true" description="The username to use when connecting to the database";
	property name="Password" required="true" description="The password to use when connecting to the database";

	public function getConnectionInfo(){

		// 2024-10-31: Started to receive the error:prepared statement "S_2" already exists on Supabase. This
		// seems related to PGBouncer. Needed to add the prepareThreshold=0 to the connection string.
		// https://stackoverflow.com/questions/7611926/postgres-error-prepared-statement-s-1-already-exists
		var out = {
			class: "#this.getClass()#",
			bundleName: "org.postgresql.jdbc",
			bundleVersion: "42.6.0",
			connectionString: 'jdbc:postgresql://#this.getHost()#:#this.getPort()#/#this.getDatabase()#?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&allowMultiQueries=true&useLegacyDatetimeCode=false&serverTimezone=UTC&prepareThreshold=0',
			username: '#this.getUsername()#',
			password: '#this.getPassword()#',
			timezone:'UTC'
		};
		return out;
	}

	public function getTableInformationSchema(){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM pg_catalog.pg_tables
			WHERE 1 = 1
			AND schemaname != 'pg_catalog' AND schemaname != 'information_schema';
		";
		var results = this.executeSql(sql);
		return results;
	}

	public TableInfo[] function getTableInfos(){
		var out = [];
		var tables = this.getTableInformationSchema();
		// writeDump(tables);
		for (var table in tables){
			var tableInfo = new TableInfo(
				Name = table.tablename
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

	public function getTableFieldInformationSchema(string tableName){
		var tableNames = [];
		var sql = "
			SELECT *
			FROM information_schema.columns
			WHERE 1 = 1
			AND table_schema = 'public'
			AND table_name = '#tableName#';
		";
		var results = this.executeSql(sql);
		return results;
	}

	public DatasourceProcess[] function getProcesses(){

		var sql = "
			SELECT pid, usename, datname, state, query
			FROM pg_stat_activity
			WHERE state = 'active';
		";
		var result = this.executeSql(sql);

		var out = [];
		for(var row in result){
			out.append(
				new DatasourceProcess(
					Id = row.pid,
					Sql = row.query
				)
			)
		}

		return out;
	}
}