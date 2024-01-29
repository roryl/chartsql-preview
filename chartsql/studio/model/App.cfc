/**
* App.cfc
*/
component
	persistent="true"
	accessors="true"
	extends="zeromodel.RecordType"
	context="App"
{
	property name="Id" fieldtype="id" generator="native";
	property name="CreatedAt" constructor="false" type="datetime" sqltype="timestamp" dbdefault="CURRENT_TIMESTAMP" insert="false" setter="false";

}
