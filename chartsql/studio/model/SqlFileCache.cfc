/**
 * Represents a SQL File Cache
*/
component accessors="true" {

	property name="SqlFile";
	property name="StudioDatasource";
	property name="LastExecutionRequest";
	property name="LastSuccessfulExecutionRequest";
	property name="LastRendering";

	public function init(
		required SqlFile SqlFile,
		required StudioDatasource StudioDatasource,
		required AsyncExecutionRequest LastExecutionRequest,
		AsyncExecutionRequest LastSuccessfulExecutionRequest,
		Rendering LastRendering
	){
		variables.StudioDatasource = arguments.StudioDatasource;
		variables.LastExecutionRequest = arguments.LastExecutionRequest;
		variables.LastSuccessfulExecutionRequest = arguments.LastSuccessfulExecutionRequest;
		variables.LastRendering = arguments.LastRendering;
		variables.SqlFile = arguments.SqlFile;

		variables.SqlFile.addSqlFileCache(this);
		return this;
	}

	public function getStudioDatasource(){
		return variables.StudioDatasource;
	}

	/**
	 * Returns the LastExecutioNRequest
	*/
	public AsyncExecutionRequest function getLastExecutionRequest(){
		return variables.LastExecutionRequest;
	}

	public function getLastSuccessfulExecutionRequest(){
		return new Optional(variables.LastSuccessfulExecutionRequest?:nullValue());
	}

	public function getLastRendering(){
		return new Optional(variables.LastRendering?:nullValue());
	}

	public function setLastRendering(Rendering LastRendering){
		variables.LastRendering = arguments.LastRendering;
	}
	
	public function setLastExecutionRequest(
		required AsyncExecutionRequest LastExecutionRequest
	){
		variables.LastExecutionRequest = arguments.LastExecutionRequest;
	}

	public function setLastSuccessfulExecutionRequest(
		required AsyncExecutionRequest LastSuccessfulExecutionRequest
	){
		variables.LastSuccessfulExecutionRequest = arguments.LastSuccessfulExecutionRequest;
	}
}