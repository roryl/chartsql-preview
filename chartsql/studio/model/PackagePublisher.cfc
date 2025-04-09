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

	public function publishAllCharts(required SqlFile[] SqlFiles){

		var results = [];
		for(var SqlFile in arguments.SqlFiles){
			var result = publishOrUpdateDashChart(SqlFile);
			arrayAppend(results, result);
		}
		return results;

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

	public PublishingResult function publishDashChart(SqlFile SqlFile) {
		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/publishDashChart.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var FormFields = {
			"sql" = SqlFile.getContent(),
			"fileName" = SqlFile.getName()
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			RequestType = "PUBLISH_CHART",
			Method = "POST",
			Headers = Headers,
			FormFields = formFields,
			SqlFile = SqlFile.getName()
		);

		PublishingRequest.send();

		var PublishingResult = parsePublishingRequest(PublishingRequest);

		if(PublishingResult.getResultType() == "API_SUCCESS"){
			var json = PublishingResult.getResultJson();
			SqlFile.addOrUpdateDirective("dash-id", json.data.Publishment.SqlChart.DashId);
			SqlFile.save();
		}

		return PublishingResult;

	}

	public PublishingResult function updateDashChart(SqlFile SqlFile){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/updateDashChart.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var FormFields = {
			"sql" = SqlFile.getContent(),
			"fileName" = SqlFile.getName(),
			"dashId" = SqlFile.getParsedDirectives()["dash-id"]
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			RequestType = "UPDATE_CHART",
			Method = "POST",
			Headers = Headers,
			FormFields = formFields,
			SqlFile = SqlFile.getName()
		);

		PublishingRequest.send();

		var PublishingResult = parsePublishingRequest(PublishingRequest);

		return PublishingResult;
	}

	public PublishingResult function markMissingChartsAsTrashed(required string[] DashIds){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/markMissingChartsAsTrashed.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		var FormFields = {
			"dashIds" = serializeJson(DashIds)
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			RequestType = "MARK_MISSING_CHARTS_AS_TRASHED",
			Method = "POST",
			Headers = Headers,
			FormFields = formFields
		);

		PublishingRequest.send();
		var PublishingResult = parsePublishingRequest(PublishingRequest);

		return PublishingResult;
	}

	/**
	 * Verifys the account is valid and has the correct permissions. If the account is not valid
	 * an error is thrown.
	 */
	public PublishingResult function verify(){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/stats.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		if(!isNull(variables.ChartSQLStudio.getPublishingDevMode())){
			Headers["x-dev-mode"] = variables.ChartSQLStudio.getPublishingDevMode();
		}

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			RequestType = "VERIFY",
			Method = "POST",
			Headers = Headers
		);

		// writeDump(PublishingRequest);

		PublishingRequest.send();
		var PublishingResult = parsePublishingRequest(PublishingRequest);

		return PublishingResult;
	}

	public PublishingResult function getStats(){

		var baseUrl = variables.ChartSQLStudio.getBasePublishingUrl(variables.key);
		var uri = "#baseUrl#/stats.json";

		var Headers = {}
		if(!isNull(variables.ChartSQLStudio.getPublishingAppId())){
			Headers["x-application-id"] = variables.ChartSQLStudio.getPublishingAppId();
		}

		if(!isNull(variables.ChartSQLStudio.getPublishingDevMode())){
			Headers["x-dev-mode"] = variables.ChartSQLStudio.getPublishingDevMode();
		}

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
			RequestType = "GET_STATS",
			Method = "POST",
			Headers = Headers
		);

		// writeDump(PublishingRequest);

		PublishingRequest.send();
		var PublishingResult = parsePublishingRequest(PublishingRequest);

		return PublishingResult;
	}

	private PublishingResult function parsePublishingRequest(required PublishingRequest PublishingRequest){

		var rawResult = PublishingRequest.getRawResult();
		var content = rawResult.filecontent;

		// echo(content);

		if(isJson(content)){

			var json = deserializeJson(content);
			if(json.keyExists("error")){

				var PublishingResult = new PublishingResult(
					PublishingRequest = PublishingRequest,
					ResultType = "API_ERROR",
					ResultMessage = json.error.message,
					ResultJson = json
				);

			} else {

				var PublishingResult = new PublishingResult(
					PublishingRequest = PublishingRequest,
					ResultType = "API_SUCCESS",
					ResultJson = json,
					ResultMessage = json.message?:"The request was successfully published to the API."
				);
			}

		} else {

			var PublishingResult = new PublishingResult(
				PublishingRequest = PublishingRequest,
				ResultType = "INVALID_JSON",
				ResultJson = {},
				ResultMessage = content
			);

		}

		PublishingRequest.setPublishingResult(PublishingResult);

		return PublishingResult;

	}

}