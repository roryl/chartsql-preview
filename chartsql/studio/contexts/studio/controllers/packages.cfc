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
		required string FolderPath,
		string FriendlyName,
		string DefaultStudioDatasource
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.createPackageFromFile(
			path = arguments.FolderPath
		);

		if(arguments.keyExists("FriendlyName")){
			Package.setFriendlyName(arguments.FriendlyName);
		}

		if(arguments.keyExists("DefaultStudioDatasource")){
			var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.DefaultStudioDatasource).elseThrow("Could not find that datasource");
			Package.setDefaultStudioDatasource(StudioDatasource);
		}

		var out = {
			"success":true,
			"Package":variables.fw.serializeFast(Package, {
				FullName:{}
			})
		}
		return out;
	}

	public struct function read( required id ) {
		return {};
	}

	public struct function update(
		required id,
		string FriendlyName,
		string DefaultStudioDatasource
	) {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByFullName(arguments.id).elseThrow("Could not find that package");

		if(arguments.keyExists("FriendlyName")){
			Package.setFriendlyName(arguments.FriendlyName);
		}

		if(arguments.keyExists("DefaultStudioDatasource")){
			var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.DefaultStudioDatasource).elseThrow("Could not find that datasource");
			Package.setDefaultStudioDatasource(StudioDatasource);
		}

		var out = {
			"success":true,
			"Package":variables.fw.serializeFast(Package, {
				FullName:{}
			})
		}
		return out;
	}

	public struct function delete( required id ) {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByFullName(arguments.id).elseThrow("Could not find that package");
		ChartSQLStudio.deletePackage(Package);

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
