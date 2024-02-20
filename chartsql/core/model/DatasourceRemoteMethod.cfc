/**
* Tracks and manages a RemoteMethod on a datasource that can be called from the client.
*/
component accessors="true" {

	property name="Datasource";
	property name="Name";

	public function init(
		required Datasource Datasource,
		required string Name
	){
		variables.Datasource = Datasource;
		variables.Name = Name;
		variables.Datasource.addRemoteMethod( this );
		return this;
	}

	public function execute(){
		return variables.Datasource[ variables.Name ]();
	}

}