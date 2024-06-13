/**
 * Pases a PublishingRequest into a PublishingResult which can be used by
 * the application to determine the status of the publishing request. We
 * separate PublishingRequest and PublishingResult because the request can
 * fail for reasons that are not the fault of the application or intended API.
*/
component accessors="true" {

	property name="PublishingRequest" setter="false";
	property name="ResultType" setter="false";
	property name="ResultMessage" setter="false";
	property name="ResultJson" type="struct";
	property name="IsSuccess" type="boolean" setter="false";

	public function init(
		required PublishingRequest PublishingRequest,
		required string ResultType,
		struct ResultJson,
		string ResultMessage
	){
		variables.PublishingRequest = arguments.PublishingRequest;
		variables.ResultJson = arguments.ResultJson?:{};

		var ChartSQLStudio = variables.PublishingRequest.getChartSQLStudio();
		ChartSQLStudio.addPublishingResult(this);

		var resultTypes = {
			"HTTP_ERROR":{
				"Name": "HTTP_ERROR",
				"Description": "An error occurred while trying to publish the request. The server returned an HTTP error code.",
				"Success": false,
			},
			"API_SUCCESS": {
				"Name": "API_SUCCESS",
				"Description": "The request was successfully published to the API.",
				"Success": true,
			},
			"INVALID_JSON": {
				"Name": "INVALID_JSON",
				"Description": "Did not receive a valid JSON response from the server.",
				"Success": false,
			},
			"API_ERROR":{
				"Name": "API_ERROR",
				"Description": "The API returned an error response.",
				"Success": false,
			},
		}

		if( !structKeyExists( resultTypes, arguments.ResultType ) ){
			throw( type="InvalidArgument", message="Invalid ResultType: #arguments.ResultType#. Valid types are: #structKeyList(resultTypes)#" );
		}

		variables.ResultType = resultTypes[ arguments.ResultType ].Name;
		variables.IsSuccess = resultTypes[ arguments.ResultType ].Success;

		if( arguments.ResultType == "API_ERROR" ){

			if( !structKeyExists( arguments, "ResultMessage" ) ){
				throw( type="InvalidArgument", message="ResultMessage is required when ResultType is API_ERROR." );
			}
			variables.ResultMessage = arguments.ResultMessage;

		}

	}

}