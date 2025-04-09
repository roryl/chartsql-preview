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
	property name="StudioDatasource";
	property name="PackageFullName";
	property name="ExecutionTime";
	property name="Data";
	property name="ShareableContent";
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
		required StudioDatasource StudioDatasource,
		required SqlFile SqlFile
	){

		variables.SqlFile = arguments.SqlFile;
		variables.content = arguments.SqlFile.getContent();
		variables.EditorSession = EditorSession;
		variables.Name = SqlFile.getName();
		variables.SqlFullName = SqlFile.getFullName();
		variables.PackageFullName = SqlFile.getPackage().getUniqueId();
		variables.SqlFile.setLastExecutionRequest(this);
		// Create a SqlFileCache object to store the last successful execution request
		new SqlFileCache(
			SqlFile = variables.SqlFile,
			StudioDatasource=arguments.StudioDatasource,
			LastExecutionRequest=this
		);
		variables.IsRunning = false;
		variables.IsDone = false;
		variables.IsCancelled = false;
		variables.IsError = false;
		variables.IsSuccess = false;
		variables.ChartSQLStudio = EditorSession.getChartSQLStudio();
		variables.ErrorContent = "";

		//Setup the SqlScript that we will later pass to the Datasource to execute
		var ChartSQL = new ChartSQL();
		variables.SqlScript = ChartSQL.createSqlScript(variables.content);

		// Setup the handlebars context with data that can be dynamically inserted into the SQL
		var context = {};
		var SelectListDirectives = variables.SqlFile.getSelectListDirectives();
		for (var SelectListDirective in SelectListDirectives) {
			context[SelectListDirective.getName()] = {
				'selected': SelectListDirective.getSelectListSelectedValueOrDefault(),
				'values': SelectListDirective.getParsed()
			}
		}
		variables.SqlScript.setHandlebarsContext(context);

		variables.scriptExecutionId = variables.SqlScript.tagWithExecutionId();
		variables.StudioDatasource = arguments.StudioDatasource?:throw("StudioDatasource must be provided or defined in the script");
		variables.Datasource = variables.StudioDatasource.getDatasource();

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

				var directives = me.getSqlScript().getParsedDirectives();

				if(directives.keyExists("ddf") and directives.ddf){
					com.chartsql.core.model.DynamicDataQuery::evaluate( data );
				}

				sleep(1);

				if(!me.getIsCancelled()){
					me.setEndedTick(getTickCount());
					me.setIsSuccess(true);
					me.setData(data);
					me.setRecordCount(data.recordCount);
					var StudioDatasource = me.getStudioDatasource();

					// We store that we were successful so that the view can display the results
					// from the most recently successful execution.
					var SqlFileCacheOptional = me.getSqlFile().getSqlFileCacheFromStudioDatasourceName(me.getName());
					if(SqlFileCacheOptional.exists()){
						var SqlFileCache = SqlFileCacheOptional.get();
						SqlFileCache.setLastSuccessfulExecutionRequest(me);
					} else {
						// Create SqlFileCache for this StudioDatasource
						new SqlFileCache(
							SqlFile=me.getSqlFile(),
							StudioDatasource=StudioDatasource,
							LastExecutionRequest=me,
							LastSuccessfulExecutionRequest=me
						);
					}
					me.getSqlFile().setLastSuccessfulExecutionRequest(me);

					// We store a hard coded SQL string that can be used to recreate the data and directives
					// so that the chart can be shared with other instances of ChartSQL
					var SqlFileParsedDirectives = SqlFile.getParsedDirectives();

					var SqlFileDirectivesContent = "";
					for (directiveName in SqlFileParsedDirectives) {
						if (isArray(SqlFileParsedDirectives[directiveName])) {
							SqlFileDirectivesContent &= "-- @#directiveName#: #SqlFileParsedDirectives[directiveName].toList(',')##chr(13)##chr(10)#";
						} else {
							SqlFileDirectivesContent &= "-- @#directiveName#: #SqlFileParsedDirectives[directiveName].toString()##chr(13)##chr(10)#";
						}
					}

					me.getSqlFile().setShareableContent(
						SqlFileDirectivesContent & me.generateShareableSQLFromData()
					);
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

				var errorContentString = "";
				savecontent variable="errorContentString" {
					writeDump(e);
				}

				me.setErrorContent(errorContentString);
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

	public function getErrorMessage() {
		if (!isDefined('variables.ErrorMessage') || variables.ErrorMessage == nullValue()) {
			return;
		}

		if (variables.ErrorMessage.contains("call for table")) {
			return variables.ErrorMessage = variables.ErrorMessage.split("call for table")[2].split("operator")[1].trim();
		} else {
			return variables.ErrorMessage;
		}
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

	public function generateShareableSQLFromData() {
		var queryTable = variables.data;
		// Initialize an array to store each SELECT statement
		var selectStatements = [];

		// Loop through the query table rows
		for (var i = 1; i <= queryTable.recordCount; i++) {
			// Start building the SELECT statement for the current row
			var selectStatement = "SELECT ";

			// Loop through the columns of the query table
			for (var col = 1; col <= listLen(queryTable.columnList); col++) {
				var columnName = listGetAt(list=queryTable.columnList, position=col);
				var columnValue = queryTable[columnName][i];

				// Check if the column value is a string and needs to be enclosed in quotes
				if (isNumeric(columnValue)) {
					selectStatement &= "#columnValue#";
				} else {
					selectStatement &= "'#columnValue#'";
				}

				// Add the column name as alias if it's the first row
				if (i == 1) {
					selectStatement &= " AS #columnName#";
				}

				// Add a comma and space after each column value except the last one
				if (col < listLen(queryTable.columnList)) {
					selectStatement &= ", ";
				}
			}

			// Add the completed SELECT statement to the array
			arrayAppend(selectStatements, "#selectStatement##chr(13)##chr(10)#");
		}

		// Join all SELECT statements with UNION ALL
		var sqlString = arrayToList(selectStatements, " UNION ALL ");
		return sqlString;
	}

	// public function getErrorContent(){
	// 	var errorContent = "";
	// 	if(variables.IsError){
	// 		savecontent variable="errorContent" {
	// 			if (variables.keyExists("ErrorStruct")) {
	// 				writeDump(variables.ErrorStruct);
	// 			} else {
	// 				writeDump({});
	// 			}
	// 		}
	// 	}
	// 	return errorContent;
	// }

}