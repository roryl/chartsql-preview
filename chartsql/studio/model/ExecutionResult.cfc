/**
 * Tracks an execution of a SqlFile and the final result so that we can
 * display these to the user
*/
component accessors="true" {

	property name="EditorSession";
	property name="Name";
	property name="SqlFullName";
	property name="PackageFullName";
	property name="ExecutionTime";
	property name="Data";
	property name="RecordCount";
	property name="ErrorStruct";
	property name="ErrorMessage";
	property name="IsError" type="boolean" default="false";
	property name="IsSuccess" type="boolean" default="false";
	property name="IsDone" type="boolean" default="false";
	property name="IsStarted" type="boolean" default="false";
	property name="CompletedAt";

	public function init(
		required EditorSession EditorSession,
		required string Name
		required string SqlFullName,
		required string PackageFullName,
		required numeric ExecutionTime,
		query data,
		numeric RecordCount,
		struct ErrorStruct = {},
	){
		variables.EditorSession = EditorSession;
		variables.Name = Name;
		variables.SqlFullName = SqlFullName;
		variables.PackageFullName = PackageFullName;
		variables.ExecutionTime = ExecutionTime;
		variables.Data = arguments.data?:nullValue();
		variables.RecordCount = arguments.RecordCount?:nullValue();
		variables.ErrorStruct = ErrorStruct;
		variables.CompletedAt = now();

		if(variables.ErrorStruct.keyExists("message")){
			variables.ErrorMessage = variables.ErrorStruct.message;
			variables.IsError = true;
			variables.IsSuccess = false;
		}
		else{
			variables.ErrorMessage = "";
			variables.IsError = false;
			variables.IsSuccess = true;
		}

		EditorSession.getExecutionResults().append(this);
		return this;
	}
}