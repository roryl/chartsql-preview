/**
 * Represents info about a database table
*/
component accessors="true" {

	property name="Name";
	property name="DatasourceInfo";
	property name="Fields" type="array";

	public function init(
		required string Name,
		required DatasourceInfo DatasourceInfo
	){
		setName( arguments.Name );
		setDatasourceInfo( arguments.DatasourceInfo );
		arguments.DatasourceInfo.addTable( this );
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

	public function getFields(){

		var Datasource = getDatasourceInfo().getDatasource();
		var fieldInformationSchema = Datasource.getTableFieldInformationSchema(
			tableName = this.getName()
		)

		for (var field in fieldInformationSchema){
			var Field = new FieldInfo(
				TableInfo = this,
				Name = field.column_name,
				Type = field.column_type?:field.data_type
			);
			this.addField( Field );
		}
		return variables.Fields;
	}



}