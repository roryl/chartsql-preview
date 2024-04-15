component accessors="true" {
	processingdirective preservecase="true";
	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public struct function list(
	){
		var out = {
			"success":true,
			"data":{}
		}
		return out;
	}

	public struct function datasources(
		boolean ShowCreate = false,
		string EditStudioDatasource = "",
		string ConfigureDatasourceType,
		struct Config = {},
		string Name
	)
		method="GET"
	{
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var qs = new zero.plugins.zerotable.model.queryStringNew(variables.fw.getQueryString());
		qs.setBasePath("/studio/settings/datasources");
		var args = arguments;
		var out = {
			"success":true,
			"data":{
				ChartSQLStudio = variables.fw.serializeFast(ChartSQLStudio, {
					StudioDatasources:{
						Name:{},
						Type:{},
						MetaData: function(StudioDatasource){
							return arguments.StudioDatasource.getMetaData();
						},
						Config: function(StudioDatasource){
							return arguments.StudioDatasource.getConfig()
						},
						IsEditing: function(StudioDatasource){
							if (StudioDatasource.getName() == args.EditStudioDatasource){
								return true;
							} else {
								return false;
							}
						},
						EditLink: function(StudioDatasource){
							return qs.clone().setValue("EditStudioDatasource", StudioDatasource.getName()).get();
						},
						CloseEditLink: function(){
							return qs.clone().delete("EditStudioDatasource").get();
						}
					},
					AvailableDatasourceTypes: function(ChartSQLStudio){
						var out = ChartSQLStudio.getAvailableDatasourceTypes();
						for(var item in out){
							item.ConfigureLink = qs.clone().setValue("ConfigureDatasourceType", item.type).get();
						}
						return out;
					},
					ConfigureDatasourceTemplate: function(ChartSQLStudio){
						var out = {}
						if(args.keyExists("ConfigureDatasourceType")){
							out = {
								Type: args.ConfigureDatasourceType,
								Fields: ChartSQLStudio.getDatasourceTemplate(args.ConfigureDatasourceType)
							}
						}
						return out;
					}
				}),
			},
			"view_state":{
				"show_create":ShowCreate,
				"is_configuring":args.keyExists("ConfigureDatasourceType"),
				"links":{
					"open_create":qs.clone().setValue("ShowCreate",true).get(),
					"close_create":qs.clone().delete("ConfigureDatasourceType").get(),
					"goto_configure":qs.clone().setValue("ConfigureDatasourceType", args.ConfigureDatasourceType?:"").get(),
				},
				Config: arguments.Config,
				Name: arguments.Name?:""
			}
		}
		// writeDump(out);
		// abort;
		return out;
	}

	public struct function packages(
		boolean ShowCreate = false,
		string EditPackage = ""
	) method="GET" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var qs = new zero.plugins.zerotable.model.queryStringNew(variables.fw.getQueryString());
		qs.setBasePath("/studio/settings/packages");
		var args = arguments;
		var out = {
			"success":true,
			"data":{
				ChartSQLStudio = variables.fw.serializeFast(ChartSQLStudio, {
					StudioDatasources:{
						Name:{}
					},
					Packages:{
						FriendlyName:{},
						FullName:{},
						IsReadOnly:{},
						Path:{},
						DefaultStudioDatasource:{
							Name:{}
						},
						IsDefaultPackage: {},
						DashId:{},
						PublisherKey:{},
						IsEditing: function(Package){
							if (Package.getFullName() == args.EditPackage){
								return true;
							} else {
								return false;
							}
						},
						EditLink: function(Package){
							return qs.clone().setValue("EditPackage", Package.getFullName()).get();
						},
						CloseEditLink: function(){
							return qs.clone().delete("EditPackage").get();
						}
					}
				})
			},
			"view_state":{
				"show_create":ShowCreate,
				"links":{
					"open_create":qs. clone().setValue("ShowCreate",true).get(),
					"close_create":qs. clone().delete("ShowCreate").get(),
				}
			}
		}

		// writeDump(out);
		// abort;

		return out;
	}

	/**
	 * Deletes the ChartSQLStudio object from the application scope which will
	 * force it to be reloaded on the next request
	 */
	public function reload() method="POST" {
		application.delete("ChartSQLStudio");
		session.delete("EditorSession");
		server.delete("ShouldLoadDefaultPackage");
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		return {
			success:true
		};
	}

	public struct function create(){
		return {};
	}

	public struct function read( required id ) {
		return {};
	}

	public struct function update( required id ) {
		return {};
	}

	public struct function delete( required id ) {
		return {};
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
