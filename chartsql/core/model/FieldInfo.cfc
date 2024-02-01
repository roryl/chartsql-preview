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
		TableInfo TableInfo
	){
		variables.Name = arguments.Name;
		if(arguments.keyExists("TableInfo")){
			setTableInfo( arguments.TableInfo );
			arguments.TableInfo.addField( this );
		}
		variables.Type = arguments.Type;
	}
}