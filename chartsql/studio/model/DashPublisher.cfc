/**
 * Represents a configured plublishing account at DashSQL. Allows the user
 * to publish packages to the account.
*/
component accessors="true" {

	property name="Key" hint="The API key for the publishing account";
	property name="ChartSQLStudio" hint="The ChartSQLStudio instance to use for publishing";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string key
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Key = arguments.key;
		variables.ChartSQLStudio.addDashPublisher(this);
		return this;
	}

	public function listDashCharts(){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/listDashCharts.json";
		// writeDump(uri);
		http url="#uri#" method="POST" result="result" {

		}
		// writeDump(result);
		// echo(result.filecontent);

	}

	public function publishDashChart(required SqlFile SqlFile){
		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/publishDashChart.json";
		http url="#uri#" method="POST" result="result" {
			httpparam type="formField" name="sql" value="#SqlFile.getContent()#";
		}
		if(isJson(result.filecontent)){
			return deserializeJson(result.filecontent);
		} else {
			// writeDump(result);
			throw(type="DashSQLPublishError", message="Error publishing chart: #result.filecontent#")
		}
	}


}