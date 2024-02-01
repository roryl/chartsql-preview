/**
 * Represents a datasource schema which will contain multiple tables
*/
component accessors="true" {

	processingdirective preservecase="true";

	property name="Datasource";
	property name="Tables" type="array";

	public function init(
		required Datasource Datasource
	){
		this.setDatasource( Datasource );
		variables.Tables = [];
		variables.Fields = [];
	}

	public function serializeJson(){
		var out = new zero.serializerFast(this, {
			Tables:{
				Name:{},
				Fields:{
					Name:{},
					Type:{}
				}
			},
		})
		return out;
	}

	public function addTable(required TableInfo Table){
		if( !this.findTableByName( Table.getName() ).exists() ){
			arrayAppend( variables.Tables, Table );
		}
	}

	public optional function findTableByName(
		required string name
	) {
		for (var Table in variables.Tables){
			if (Table.getName() == name){
				return new optional(Table);
			}
		}
		return new optional(nullValue());
	}

}