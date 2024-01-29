/**
 * Holds reference to session information for the current user Editor that cannot
 * fit in the URL or the client variables.
*/
component accessors="true" {

	property name="Id";
	property name="ChartSQLStudio";
	property name="ExecutionResults";
	property name="LastExecutionResult" type="optional";
	property name="LastSuccessExecutionResult" type="optional";
	property name="ExecutionRequests";
	property name="LastExecutionRequest" type="optional";
	property name="LastSuccessExecutionRequest" type="optional";
	property name="CurrentDatasource" type="Datasource";
	property name="CurrentStudioDatasource" type="StudioDatasource";

	public function init(
		required ChartSQLStudio ChartSQLStudio
	){
		variables.OpenSqlFiles = [];
		variables.ChartSQLStudio = ChartSQLStudio;
		variables.ExecutionResults = [];
		variables.ExecutionRequests = [];
		variables.Id = createUUID();
		return this;
	}

	public function getCurrentDatasource(){
		if(isNull(variables.CurrentDatasource)){
			variables.CurrentDatasource = variables.ChartSQLStudio.getStudioDatasources().first().getDatasource();
		}
		return variables.CurrentDatasource?:nullValue();
	}

	// public function createExecutionResult(
	// 	required SqlFile,
	// 	required numeric executionTime,
	// 	errorStruct = {},
	// 	query data,
	// ){

	// 	if(!errorStruct.keyExists("message") and !arguments.keyExists("data")){
	// 		throw("If the errorStruct does not contain a message, then the data argument must be provided.")
	// 	}

	// 	var ExecutionResult = new ExecutionResult(
	// 		EditorSession = this,
	// 		name = SqlFile.getName(),
	// 		sqlFullName = SqlFile.getFullName(),
	// 		packageFullName = SqlFile.getPackage().getFullName(),
	// 		ExecutionTime = executionTime,
	// 		data = data?:nullValue(),
	// 		recordCount = data?.recordCount?:nullValue(),
	// 		errorStruct = arguments.errorStruct
	// 	);
	// 	variables.LastExecutionResult = ExecutionResult;

	// 	SqlFile.setLastExecutionResult(ExecutionResult);

	// 	if(ExecutionResult.getIsSuccess()){
	// 		variables.LastSuccessExecutionResult = ExecutionResult;
	// 	}
	// 	return ExecutionResult;
	// }

	public AsyncExecutionRequest function createExecutionRequest(
		required SqlFile SqlFile,
		StudioDatasource StudioDatasource = this.getCurrentStudioDatasource()
	){
		var ExecutionRequest = new AsyncExecutionRequest(
			EditorSession = this,
			StudioDatasource = arguments.StudioDatasource,
			SqlFile = SqlFile
		);
		ExecutionRequest.start();
		variables.LastExecutionRequest = ExecutionRequest;
		return ExecutionRequest;
	}

	public optional function findExecutionRequestById(
		required string Id
	){

		for(var ExecutionRequest in variables.ExecutionRequests){
			if(ExecutionRequest.getId() == Id){
				return new Optional(ExecutionRequest);
			}
		}

		return new Optional(nullValue());
	}

	// public function getLastExecutionResult(){
	// 	return new Optional(variables.LastExecutionResult?:nullValue());
	// }

	// public function getLastSuccessExecutionResult(){
	// 	return new Optional(variables.LastExecutionResult?:nullValue());
	// }

	public function getLastExecutionRequest(){
		return new Optional(variables.LastExecutionRequest?:nullValue());
	}

	public function getLastSuccessExecutionRequest(){
		return new Optional(variables.LastExecutionRequest?:nullValue());
	}

}