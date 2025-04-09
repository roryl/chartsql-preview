/**
 * Tracks a rendering attempt of a particular SqlFile and its content or errors
*/
component accessors="true" {

	property name="SqlFile" type="SqlFile";
	property name="Content";
	property name="Option";
	property name="IsSuccess";
	property name="IsError";
	property name="ErrorMessage";
	property name="ErrorStruct";
	property name="AsyncExecutionRequest";

	public function init(
		required SqlFile SqlFile,
		AsyncExecutionRequest AsyncExecutionRequest
	){
		variables.SqlFile = arguments.SqlFile;
		variables.AsyncExecutionRequest = arguments.AsyncExecutionRequest?:nullValue();
		return this;
	}

	public function render(
		required query data,
		width: "100%",
		height: "100%"
	){
		if (!isNull(variables.AsyncExecutionRequest)) {
			// Get datasource from AsyncExecutionRequest
			var StudioDatasource = variables.AsyncExecutionRequest.getStudioDatasource();
			var SqlFileCacheOptional = variables.SqlFile.getSqlFileCacheFromStudioDatasourceName(StudioDatasource.getName());
			// Set last rendering to the cache if is not null
			if (SqlFileCacheOptional.exists()) {
				var SqlFileCache = SqlFileCacheOptional.get();
				SqlFileCache.setLastRendering(this);
			} else {
				// Create a new cache if it does not exist
				// TO DO: Delete this
				// var SqlFileCache = new SqlFileCache(
				// 	StudioDatasource = StudioDatasource,
				// 	LastExecutionRequest = variables.AsyncExecutionRequest,
				// 	LastSuccessfulExecutionRequest = null,
				// 	LastRendering = this
				// );
				// variables.SqlFile.addSqlFileCache(SqlFileCache);
			}
		}
		variables.SqlFile.setLastRendering(this);
		try{
			var data = arguments.data;
			var directives = SqlFile.getParsedDirectives();

			// if(variables.keyExists("AsyncExecutionRequest")){
			// 	var EChartsOption = variables.AsyncExecutionRequest.newEChartsOption(
			// 		data = data,
			// 		directives = directives,
			// 		renderInLine = true
			// 	)
			// } else {
			// }
			var EChartsOption = new core.util.EChartsOption.EChartsOption(
				data = data,
				directives = directives,
				renderInLine = true
			)

			variables.Option = EChartsOption.getOption();
			var previewContent = "";
			savecontent variable="previewContent" {
				EchartsOption.render(
					width = arguments.width,
					height = arguments.height,
					option = variables.option
				);
			}
			variables.Content = previewContent;
			variables.IsSuccess = true;
			variables.IsError = false;
		}
		catch(any e){
			// throw(e);
			variables.IsSuccess = false;
			variables.IsError = true;
			variables.ErrorMessage = e.message;
			variables.ErrorStruct = e;
		}
		return this;
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