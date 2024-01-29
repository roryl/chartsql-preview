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

			// variables.task = runAsync(function(){
				var data = "";
				try {

					var data = me.getDatasource().execute(me.getSqlScript());
					// query name="data" datasource="#me.getDatasource()#" {
					// 	echo(me.getContent())
					// }
					// I remember that you can't simply kill the thread, you have to check with a sleep
					// to see if the thread was cancelled and if it is then this will throw "sleep interrupted"
					// This does not kill the thread being issued to the database. We will need to enhance this
					// later to kill the particular database thread directly.
					sleep(1);
					me.setEndedTick(getTickCount());
					me.setIsSuccess(true);
					me.setData(data);
					me.setRecordCount(data.recordCount);

					// We store that we were successful so that the view can display the results
					// from the most recently successful execution.
					me.getSqlFile().setLastSuccessfulExecutionRequest(me);

				}catch(any e){
					me.setEndedTick(getTickCount());
					if(e.message == "sleep interrupted"){
						me.setIsCancelled(true);
					} else {
						me.setIsError(true);
						me.setErrorMessage(e.message);
						me.setErrorStruct(e);
					}
				}

				me.setExecutionTime(me.getEndedTick() - me.getStartedTick());
				me.setIsRunning(false);
				me.setIsDone(true);
				me.setCompletedAt(now());
			// });
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
		threadTerminate(variables.ThreadName);
		// variables.Task.cancel();
		variables.IsCancelled = true;
		variables.IsRunning = false;
		variables.IsDone = true;
		variables.CompletedAt = now();
		variables.EndedTick = getTickCount();
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