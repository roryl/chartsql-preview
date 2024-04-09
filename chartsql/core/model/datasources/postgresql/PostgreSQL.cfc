/**

*/
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

		var out = {
			class: "#this.getClass()#",
			bundleName: "org.postgresql.jdbc",
			bundleVersion: "42.6.0",
			connectionString: 'jdbc:postgresql://#this.getHost()#:#this.getPort()#/#this.getDatabase()#?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&allowMultiQueries=true&useLegacyDatetimeCode=false&serverTimezone=UTC',
			username: '#this.getUsername()#',
			password: '#this.getPassword()#',
			timezone:'UTC'
		};
		return out;
	}
}