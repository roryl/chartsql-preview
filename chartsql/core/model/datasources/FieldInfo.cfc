/**
 * Represents information about a Table Field
*/
component accessors="true" {

	property name="TableInfo";
	property name="Name";
	property name="Type";

	public function init(
		required string Name,
		required string Type,
		required TableInfo TableInfo
	){
		setName( arguments.Name );
		setTableInfo( arguments.TableInfo );
		setType( arguments.Type );
		arguments.TableInfo.addField( this );
	}
}