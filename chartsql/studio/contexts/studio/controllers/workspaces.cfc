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
		string FriendlyName
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		if(!arguments.keyExists("FriendlyName")){
			throw(variables.fw.createError("Missing required field 'Friendly Name'", "FriendlyName"));
		}
		
		// Create new Workspace
		var Workspace = ChartSQLStudio.createWorkspace(
			friendlyName = arguments.FriendlyName
		);

		// Redirect to the new Workspace settings page
		var qs = new zero.plugins.zerotable.model.queryStringNew(variables.fw.getQueryString());
		qs.setBasePath("/studio/settings/workspaces");
		qs.setValue('EditWorkspace', Workspace.getUniqueId()).delete('ShowCreate');
		fw.doLocation(qs.get());

		var out = {
			"success":true,
			"Workspace":variables.fw.serializeFast(Workspace, {
				FriendlyName: {},
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
		string FriendlyName
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Workspace = ChartSQLStudio.findWorkspaceByUniqueId(arguments.id).elseThrow("Could not find that Workspace");

		if(arguments.keyExists("FriendlyName") && !isEmpty(arguments.FriendlyName) && arguments.FriendlyName != Workspace.getFriendlyName()) {
			Workspace.setFriendlyName(arguments.FriendlyName);
		}

		var out = {
			"success":true,
			"Workspace":variables.fw.serializeFast(Workspace, {
				UniqueId:{}
			})
		}
		return out;
	}
	
	public struct function addPackage(
		required id,
		string PackageId
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Workspace = ChartSQLStudio.findWorkspaceByUniqueId(arguments.id).elseThrow("Could not find that Workspace");
		var Package = ChartSQLStudio.findPackageByUniqueId(arguments.PackageId).elseThrow("Could not find that Package");
		
		var WorkspacePackage = Workspace.addPackage(Package);

		// Set the current DefaultStudioDatasource for the Package as the DefaultStudioDatasource for the WorkspacePackage
		var PackageDefaultStudioDatasourceOptional = Package.getDefaultStudioDatasource();
		if (PackageDefaultStudioDatasourceOptional.exists()) {
			WorkspacePackage.setDefaultStudioDatasource(PackageDefaultStudioDatasourceOptional.get());
		}

		var out = {
			"success":true,
			"Workspace":variables.fw.serializeFast(Workspace, {
				UniqueId:{}
			})
		}
		return out;
	}
	
	public struct function removePackage(
		required id,
		string PackageId
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Workspace = ChartSQLStudio.findWorkspaceByUniqueId(arguments.id).elseThrow("Could not find that Workspace");
		var Package = Workspace.findPackageByUniqueId(arguments.PackageId).elseThrow("Could not find that Package");
		
		Workspace.removePackage(Package);

		var out = {
			"success":true,
			"Workspace":variables.fw.serializeFast(Workspace, {
				UniqueId:{}
			})
		}
		return out;
	}

	public struct function updateWorkspacePackage(
		required id,
		string PackageId,
		string DefaultStudioDatasource
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Workspace = ChartSQLStudio.findWorkspaceByUniqueId(arguments.id).elseThrow("Could not find that Workspace");
		var WorkspacePackage = Workspace.findWorkspacePackageByUniqueId(arguments.PackageId).elseThrow("Could not find that Workspace Package");

		if(arguments.keyExists("DefaultStudioDatasource")) {
			var StudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.DefaultStudioDatasource).elseThrow("Could not find that datasource");
			WorkspacePackage.setDefaultStudioDatasource(StudioDatasource);
		}

		var out = {
			"success":true,
			"Workspace":variables.fw.serializeFast(Workspace, {
				UniqueId:{}
			})
		}
		return out;
	}

	public struct function delete( required id ) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Workspace = ChartSQLStudio.findWorkspaceByUniqueId(arguments.id).elseThrow("Could not find that Workspace");
		ChartSQLStudio.deleteWorkspace(Workspace);

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
