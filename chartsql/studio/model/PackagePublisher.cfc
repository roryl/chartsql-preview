/**
 * Represents a configured plublishing account at DashSQL. Allows the user
 * to publish packages to the account.
*/
component accessors="true" {

	property name="Key" hint="The API key for the package Publisher account";
	property name="ChartSQLStudio" hint="The ChartSQLStudio instance to use for publishing";
	property name="PublishingRequests" hint="Array of PublishingRequests";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string key
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Key = arguments.key;
		variables.ChartSQLStudio.addPackagePublisher(this);
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

	public struct function publishOrUpdateDashChart(required SqlFile SqlFile){

		var SqlFile = arguments.SqlFile;
		var directives = SqlFile.getParsedDirectives();

		if(!isDefined("directives['dash-id']")){
			var result = publishDashChart(SqlFile);
		} else {
			var result = updateDashChart(SqlFile);
		}
		return result;
	}

	public PublishingRequest function publishDashChart(SqlFile SqlFile) {
		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/publishDashChart.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var FormFields = {
			"sql" = SqlFile.getContent()
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			Method = "POST",
			Headers = Headers,
			FormFields = formFields
		);

		PublishingRequest.send();

		if(!PublishingRequest.getIsHttpError()){

			var rawResult = PublishingRequest.getRawResult();
			var content = rawResult.filecontent;

			if(isJson(content)){

				var json = deserializeJson(content);

				PublishingRequest.setDataResult(json);

				if(isDefined("json.data.Publishment.SqlChart.DashId")){
					SqlFile.addOrUpdateDirective("dash-id", json.data.Publishment.SqlChart.DashId);
					// SqlFile.save();
				}

				return PublishingRequest;

			} else {

				echo(content);

				PublishingRequest.setIsError(true);
				PublishingRequest.setErrorMessage("Invalid JSON response from server.");
				PublishingRequest.setRawContent(content);

			}
		}

		return PublishingRequest;

	}

	public PublishingRequest function updateDashChart(SqlFile SqlFile){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/updateDashChart.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var FormFields = {
			"sql" = SqlFile.getContent(),
			"dash-id" = SqlFile.getParsedDirectives()["dash-id"]
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			Method = "POST",
			Headers = Headers,
			FormFields = formFields
		);

		PublishingRequest.send();

		var rawResult = PublishingRequest.getRawResult();

		if(!PublishingRequest.getIsHttpError()){

			var content = rawResult.filecontent;

			if(isJson(content)){

				var json = deserializeJson(content);
				if(json.keyExists("error")){
					PublishingRequest.setIsError(true);
					PublishingRequest.setErrorMessage(json.error.message);
				} else {
					PublishingRequest.setIsError(false);
					PublishingRequest.setIsSuccess(true);
				}

				PublishingRequest.setDataResult(json);

			} else {
				PublishingRequest.setIsError(true);
				PublishingRequest.setErrorMessage("Invalid JSON response from server.");
				PublishingRequest.setRawContent(content);
			}
		}

		return PublishingRequest;

		// if(isJson(result.filecontent)){

		// 	var json = deserializeJson(result.filecontent);
		// 	return json;

		// } else {
		// 	// writeDump(result);
		// 	throw(type="DashSQLPublishError", message="Error updating chart: #result.filecontent#")
		// }
	}

	/**
	 * Verifys the account is valid and has the correct permissions. If the account is not valid
	 * an error is thrown.
	 */
	public PublishingRequest function verify(){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/stats.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			Method = "POST",
			Headers = Headers
		);

		PublishingRequest.send();


		if(!PublishingRequest.getIsHttpError()){

			var rawResult = PublishingRequest.getRawResult();

			var content = rawResult.filecontent;

			if(isJson(content)){

				var json = deserializeJson(content);
				if(json.keyExists("error")){
					PublishingRequest.setIsError(true);
					PublishingRequest.setErrorMessage(json.error.message);
				} else {
					PublishingRequest.setIsError(false);
					PublishingRequest.setIsSuccess(true);
				}

			} else {
				PublishingRequest.setIsError(true);
				PublishingRequest.setErrorMessage("Invalid JSON response from server.");
				PublishingRequest.setRawContent(content);
			}
		}
		return PublishingRequest;
	}

}