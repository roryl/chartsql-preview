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
		if(!arguments.keyExists("FriendlyName")){
			throw(variables.fw.createError("Missing required field 'Friendly Name'", "FriendlyName"));
		}
		var Package = ChartSQLStudio.createPackageFromFile(
			friendlyName = arguments.FriendlyName,
			path = arguments.FolderPath
		);

		if(arguments.keyExists("DefaultStudioDatasource") && !isEmpty(arguments.DefaultStudioDatasource)){
			var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.DefaultStudioDatasource).elseThrow("Could not find that datasource");
			Package.setDefaultStudioDatasource(StudioDatasource);
		}

		var out = {
			"success":true,
			"Package":variables.fw.serializeFast(Package, {
				UniqueId:{}
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
		string DefaultStudioDatasource,
		boolean setAsDefaultPackage = false,
		string DashId,
		string PublisherKey
	) {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByUniqueId(arguments.id).elseThrow("Could not find that package");

		if(arguments.keyExists("FriendlyName") && !isEmpty(arguments.FriendlyName)){
			Package.setFriendlyName(arguments.FriendlyName);
		}

		if(arguments.keyExists("DefaultStudioDatasource") && !isEmpty(arguments.DefaultStudioDatasource)){
			var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.DefaultStudioDatasource).elseThrow("Could not find that datasource");
			Package.setDefaultStudioDatasource(StudioDatasource);
		}

		if (arguments.keyExists("setAsDefaultPackage") && arguments.setAsDefaultPackage == true) {
			ChartSQLStudio.setDefaultPackage(Package);
		}

		if (arguments.keyExists("DashId") && !isEmpty(arguments.DashId)) {
			Package.setDashId(DashId);
		}

		if (arguments.keyExists("PublisherKey") && !isEmpty(arguments.PublisherKey)) {
			Package.setPublisherKey(PublisherKey);
		}

		var out = {
			"success":true,
			"Package":variables.fw.serializeFast(Package, {
				UniqueId:{}
			})
		}
		return out;
	}

	public struct function delete( required id ) {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByUniqueId(arguments.id).elseThrow("Could not find that package");
		ChartSQLStudio.deletePackage(Package);

		var out = {
			"success":true
		}
		return out;
	}

	public struct function verifyPublisherKey( required id ) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByUniqueId(arguments.id).elseThrow("Could not find that package");
		var PackagePublisher = Package.getPackagePublisher();

		PublishingResult = PackagePublisher.verify();

		// writeDump(PublishingRequest);
		// abort;

		if(PublishingResult.getIsSuccess()){
			var out = {
				"success": true,
				"message": "Publisher key verified",
			}
		} else {
			var out = {
				"success": false,
				"message": PublishingResult.getResultMessage()
			}
		}

		// out.data = {
		// 	"PublishingResult": variables.fw.serializeFast(PublishingResult, {
		// 		// ResultMessage:{}
		// 	})
		// }

		// writeDump(out);
		// abort;

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
