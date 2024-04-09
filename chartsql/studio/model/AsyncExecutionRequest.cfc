/**
 * Tracks an execution of a SqlFile and the final result so that we can
 * display these to the user
*/
import core.model.*;
component accessors="true" {

	property name="EditorSession";
	property name="Name";
	property name="SqlFile";
	property name="SqlFullName";
	property name="PackageFullName";
	property name="ExecutionTime";
	property name="Data";
	property name="RecordCount";
	property name="ErrorStruct";
	property name="ErrorContent";
	property name="ErrorStackTrace";
	property name="ErrorMessage";
	property name="IsError" type="boolean";
	property name="IsSuccess" type="boolean";
	property name="IsDone" type="boolean";
	property name="IsRunning" type="boolean";
	property name="IsCancelled" type="boolean";
	property name="CompletedAt";
	property name="StartedAt";
	property name="StartedTick";
	property name="EndedTick";
	property name="Task";
	property name="Datasource";
	property name="Content";
	property name="Id";
	property name="SqlScript";
	property name="ThreadName";

	public function init(
		required EditorSession EditorSession,
		StudioDatasource StudioDatasource,
		required SqlFile SqlFile
	){

		variables.SqlFile = arguments.SqlFile;
		variables.content = arguments.SqlFile.getContent();
		variables.EditorSession = EditorSession;
		variables.Name = SqlFile.getName();
		variables.SqlFullName = SqlFile.getFullName();
		variables.PackageFullName = SqlFile.getPackage().getFullName();
		variables.SqlFile.setLastExecutionRequest(this);
		variables.IsRunning = false;
		variables.IsDone = false;
		variables.IsCancelled = false;
		variables.IsError = false;
		variables.IsSuccess = false;
		variables.ChartSQLStudio = EditorSession.getChartSQLStudio();

		//Setup the SqlScript that we will later pass to the Datasource to execute
		var ChartSQL = new ChartSQL();
		variables.SqlScript = ChartSQL.createSqlScript(variables.content);

		variables.scriptExecutionId = variables.SqlScript.tagWithExecutionId();

		var directives = variables.SqlScript.getParsedDirectives();
		if(directives.keyExists("datasource")){
			var StudioDatasource = variables.ChartSQLStudio.findStudioDatasourceByName(directives.datasource).elseThrow("Script specified a specific datasource '#directives.datasource#' but it was not found");
			variables.StudioDatasource = StudioDatasource;
			variables.Datasource = StudioDatasource.getDatasource();
		} else {
			variables.StudioDatasource = arguments.StudioDatasource?:throw("StudioDatasource must be provided or defined in the script");
			variables.Datasource = variables.StudioDatasource.getDatasource();
		}

		variables.EditorSession.getExecutionRequests().append(this);
		variables.Id = createUUID();
		return this;
	}

	public function start(){

		variables.StartedAt = now();
		variables.IsRunning = true;
		variables.StartedTick = getTickCount();
		variables.ThreadName = createGUID();

		var me = this;

		thread name="#variables.ThreadName#" me="#me#" {
			writeLog(file="async", text="Starting thread");
			// variables.task = runAsync(function(){
			var data = "";

			try {
				sleep(1);
				data = me.getDatasource().execute(me.getSqlScript());
				sleep(1);

				if(!me.getIsCancelled()){
					me.setEndedTick(getTickCount());
					me.setIsSuccess(true);
					me.setData(data);
					me.setRecordCount(data.recordCount);

					// We store that we were successful so that the view can display the results
					// from the most recently successful execution.
					me.getSqlFile().setLastSuccessfulExecutionRequest(me);
				}

			} catch(any e) {

				if(me.getIsCancelled()){
					me.setErrorMessage("Task was cancelled");
					me.setErrorStruct(e); //Store the original error so that we can debug it later if needed
				} else if(e.message == "sleep interrupted"){
					me.setErrorMessage(e.message);
				} else if(trim(e.message == "")){
					// When threads are killed, the database connection also appears to be killed
					// but it returns an error with no message.
					// On MySQL it returns SqlState: S1000 which appears to be related to a connection
					me.setErrorMessage("General error or thread inerruption");
					// me.setIsError(true);
				} else {
					me.setIsError(true);
					me.setErrorMessage(e.message);
				}

				me.setErrorStruct(e);
			}

			me.setExecutionTime(me.getEndedTick() - me.getStartedTick());
			me.setIsRunning(false);
			me.setIsDone(true);
			me.setCompletedAt(now());
			// });
			writeLog(file="async", text="ending thread");
		}
		return this;
	}

	/**
	 * When we are currently running, then we will calculate the time
	 */
	public function getExecutionTime(){
		if(this.getIsRunning()){
			return getTickCount() - this.getStartedTick();
		}
		return (variables.EndedTick?:getTickCount()) - (variables.StartedTick?:getTickCount());
	}

	public function cancel(){

		// 2024-02-24: THREADING UPDATES:
		// We discovered that killing the thread causes unexpected behavior regarding database connections.
		// We are now using the Datasource to kill the process instead of killing the thread.

		variables.IsCancelled = true;
		variables.IsRunning = false;
		variables.IsDone = true;
		variables.IsSuccess = false; //We need to set this because it is possible for the query to complete after we have cancelled it
		variables.CompletedAt = now();
		variables.EndedTick = getTickCount();

		var datasource = this.getDatasource();

		if(structKeyExists(datasource, "kill")){

			var DatasourceProcesses = datasource.getProcesses();
			for(DatasourceProcess in DatasourceProcesses){
				if(DatasourceProcess.hasExecutionID(variables.scriptExecutionId)){
					datasource.killProcess(DatasourceProcess);
				}
			}
		}

		return this;
	}

	public function getData(){

		if(this.getIsCancelled()){
			throw("Task was cancelled, cannot get the result. Check first if the task was a Success")
		}

		if(this.getIsError()){
			throw("Task errored, cannot get the result. Check first if the task was a Success")
		}

		return variables.Data;
	}

	public function get(){
		threadJoin(variables.ThreadName);
		return "completed";
		// return variables.Task.get();
	}

	public function getStatus(){
		var out = {}
		out.IsRunning = this.getIsRunning();
		out.IsDone = this.getIsDone();
		out.IsCancelled = this.getIsCancelled();
		out.IsError = this.getIsError();
		out.IsSuccess = this.getIsSuccess();
		out.StartedAt = this.getStartedAt();
		out.CompletedAt = this.getCompletedAt();
		out.ExecutionTime = this.getExecutionTime();
		out.RecordCount = this.getRecordCount();
		out.ErrorMessage = this.getErrorMessage();
		out.ErrorStruct = this.getErrorStruct();
		return out;
	}

	public function getErrorContent(){
		var errorContent = "";
		if(variables.IsError){
			savecontent variable="errorContent" {
				writeDump(variables.ErrorStruct);
			}
		}
		return errorContent;
	}

}