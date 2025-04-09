/**
 * Logs and tracks a request to the Publishing URL so that we can inspect the response
*/
component accessors="true" {

	property name="Uri" type="string";
	property name="Headers" type="struct";
	property name="FormFields" type="struct";
	property name="Method" type="string";
	property name="RawResult" type="struct";
	property name="DataResult" type="struct";
	property name="IsError" type="boolean";
	property name="IsHttpError" type="boolean";
	property name="IsSent" type="boolean";
	property name="ErrorMessage" type="string";
	property name="IsSuccess" type="boolean";
	property name="RawContent";
	property name="RequestType" type="string" setter="false";
	property name="PublishingResult" type="PublishingResult";
	property name="ChartSQLStudio" type="ChartSQLStudio" setter="false";
	property name="SqlFile" type="string" setter="false";

	public function init(
		required ChartSQLStudio ChartSQlStudio,
		required string Uri,
		required string RequestType,
		string SqlFile,
		struct Headers = {},
		struct FormFields = {},
		string Method = "POST"
	){
		variables.ChartSQLStudio = arguments.ChartSQlStudio;
		variables.ChartSQLStudio.addPublishingRequest(this);
		variables.Uri = arguments.Uri;
		variables.FormFields = arguments.FormFields;
		variables.Headers = arguments.Headers;
		variables.Method = arguments.Method;
		variables.IsSuccess = false;
		variables.IsHttpError = false;
		variables.ErrorMessage = "";

		if(structKeyExists(arguments, "SqlFile")){
			variables.SqlFile = arguments.SqlFile;
		}

		variables.requestTypes = {
			"VERIFY":{},
			"UPDATE_CHART":{},
			"PUBLISH_CHART":{},
			"GET_STATS":{},
			"MARK_MISSING_CHARTS_AS_TRASHED":{}
		}

		if (!structKeyExists(variables.requestTypes, arguments.requestType)){
			throw(message="Invalid request type: #arguments.requestType#");
		} else {
			variables.RequestType = arguments.requestType;
		}

		return this;
	}

	public function send(){

		var result = "";

		try {

			http url="#variables.Uri#" method="#variables.Method#" result="result" {
				// Set the headers
				for (var key in variables.Headers){
					httpparam type="header" name="#key#" value="#variables.Headers[key]#";
				}

				// Set the form fields
				if (structKeyExists(variables, "FormFields")){
					for (var key in variables.FormFields){
						httpparam type="formfield" name="#key#" value="#variables.FormFields[key]#";
					}
				}
			}

			variables.IsSent = true;
			variables.RawResult = result;

		}catch(any e){

			variables.IsSuccess = false;
			variables.IsHttpError = true;
			variables.IsError = true;
			variables.ErrorMessage = e.message;

		}

	}

}