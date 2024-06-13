component accessors="true" {

	public any function init( fw ) {
		variables.fw = fw;
		return this;
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

	public function runRemote(
		required string id,
		required string method,
		required struct params = {}
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Extension = ChartSQLStudio.findExtensionByName( id ).elseThrow("Extension not found");
		var result = Extension.runRemote( method, params );

		var out = {
			success = true,
			data: result?:{}
		};

		return out;
	}

}
