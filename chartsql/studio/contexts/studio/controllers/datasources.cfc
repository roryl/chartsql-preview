component accessors="true" {

	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public struct function list(
	){
		var out = {
			"success":true,
			"data":{
			}
		}
		return out;
	}

	public struct function create(
		required string Name,
		required string Type,
		required struct Config
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var StudioDatasource = ChartSQLStudio.createStudioDatasource(
			arguments.Name,
			arguments.Type,
			arguments.Config
		);
		var out = {
			"success":true,
			"Datasource":variables.fw.serializeFast(StudioDatasource, {
				Name:{}
			})
		}
		return out;
	}

	public struct function read( required id ) {
		return {};
	}

	/**
	 * Executes a remote custom function on the datasource
	 *
	 */
	public struct function runRemote(
		required string id,
		required string method,
		struct args = {}
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.id).elseThrow("Could not find that StudioDatasource");
		var Datasource = StudioDatasource.getDatasource();
		var DatasourceRemoteMethod = Datasource.findRemoteMethodByName(arguments.method).elseThrow("Could not find that remote method '#arguments.method#' on datasource '#StudioDatasource.getName()#'");

		try {
			var result = DatasourceRemoteMethod.execute(argumentCollection = arguments.args);
			var out = {
				"success":true,
				"data": {
					"result": result?:nullValue()
				}
			}
		}catch(any e){
			var out = {
				"success":false,
				"message":e.message
			}
		}

		return out;
	}

	public struct function validate(
		required string Type,
		required struct Config,
		numeric timeout = 5
	) {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Datasource = createObject("component", "core.model.datasources.#arguments.Type#.#arguments.Type#").init(argumentCollection=arguments.config);
		try {
			Datasource.verify(arguments.timeout);
			var out = {
				"success":true
			}
		}catch(any e){
			var out = {
				"success":false,
				"message":e.message
			}
		}
		return out;
	}

	public struct function update(
		required id,
		string Name,
		struct Config
	) {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.id).elseThrow("Could not find that StudioDatasource");

		if(arguments.keyExists("Name")){
			StudioDatasource.setName(arguments.Name);
		}

		if(arguments.keyExists("Config")){
			StudioDatasource.updateConfig(arguments.Config);
		}

		var out = {
			"success":true,
			"StudioDatasource":variables.fw.serializeFast(StudioDatasource, {
				Name:{}
			})
		}
		return out;
	}

	public struct function delete( required id ) {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.id).elseThrow("Could not find that Datasource");
		ChartSQLStudio.deleteStudioDatasource(StudioDatasource);

		var out = {
			"success":true
		}
		return out;
	}

	/**
	 * Function to override the request scope variables for this controller
	 * @param  {struct} rc The request context, the URL and FORM variables passed into the app
	 * @return {struct}    The update RC scope which will be used to find variables for the controllers
	 */
	public struct function request( required struct rc, required struct headers ){
		return rc;
	}

	/**
	 * A function to override all controller function responses, for example to decorate with extra information on every call
	 * @param  {struct} required struct        controllerResult Will receive the result of the controller method (list, create, read etc)
	 * @return {struct}          Should return the updated controller result
	 */
	public struct function result( required struct controllerResult ){

		controllerResult = arguments.controllerResult;
		controllerResult.view_state.current_page = variables.fw.getItem();
		return controllerResult;
	}

}
