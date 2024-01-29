/**

*/
component
	extends="JdbcDatasource"
	accessors="true"
	isStudioDatasource="true"
	displayName="MySQL Database"
	description="MySQL Database connnector or MySQL wire protocol"
	iconClass="ti ti-brand-mysql"
{
	property name="Class" default="com.mysql.jdbc.Driver" description="The class name of the JDBC driver to use";
	property name="Port" default="3306" description="The port number of the MySQL server";
	property name="Host" required="true" description="The host name of the database server";
	property name="Database" required="true" description="The name of the database to connect to";
	property name="Username" required="true" description="The username to use when connecting to the database";
	property name="Password" required="true" description="The password to use when connecting to the database";
}