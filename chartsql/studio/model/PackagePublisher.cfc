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

	public PublishingResult function publishDashChart(SqlFile SqlFile) {
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

		var PublishingResult = parsePublishingRequest(PublishingRequest);

		if(PublishingResult.getResultType() == "API_SUCCESS"){
			var json = PublishingResult.getResultJson();
			SqlFile.addOrUpdateDirective("dash-id", json.data.Publishment.SqlChart.DashId);
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
			"dashId" = SqlFile.getParsedDirectives()["dash-id"]
		};

		var PublishingRequest = new PublishingRequest(
			ChartSQLStudio = variables.ChartSQLStudio,
			Uri = uri,
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
			Method = "POST",
			Headers = Headers
		);

		PublishingRequest.send();
		var PublishingResult = parsePublishingRequest(PublishingRequest);

		return PublishingResult;
	}

	private PublishingResult function parsePublishingRequest(required PublishingRequest PublishingRequest){

		var rawResult = PublishingRequest.getRawResult();
		var content = rawResult.filecontent;

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
					ResultJson = json
				);

			}

		} else {

			var PublishingResult = new PublishingResult(
				PublishingRequest = PublishingRequest,
				ResultType = "INVALID_JSON"
			);

		}
		return PublishingResult;

	}

}