/**
 * Represents info about a database table
*/
component accessors="true" {

	property name="Name";
	property name="DatasourceInfo";
	property name="Fields" type="array";

	public function init(
		required string Name,
		DatasourceInfo DatasourceInfo
	){
		variables.Name = arguments.Name;
		if(arguments.keyExists("DatasourceInfo")){
			setDatasourceInfo( arguments.DatasourceInfo );
			arguments.DatasourceInfo.addTable( this );
		}
		variables.Fields = [];
	}

	public function addField(required FieldInfo Field){
		if( !this.findFieldByName( Field.getName() ).exists() ){
			arrayAppend( variables.Fields, Field );
		}
	}

	public optional function findFieldByName(
		required string name
	) {
		for (var Field in variables.Fields){
			if (Field.getName() == name){
				return new optional(Field);
			}
		}
		return new optional(nullValue());
	}

}