component extends="zero.zero" {

	//Define a default name for this app, you might change this to reflect your product.
	this.name = "chartsqlstudio";

	//Define our basic mapping for our app which is to the root folder above this Application.cfc
	this.mappings[ "/app"] = "../";

	//Define our default values folder that will be the base location of generated Context value objects
	this.mappings[ "/values"] = "../model/values";
	this.mappings[ "/core"] = "../../core";
	this.mappings[ "/studio"] = "../../studio";
	this.mappings[ "/com/chartsql"] = "../../";

	// USER DATA MAPPINGS:
	// Sets up the users home directory as a mapping. Put into a separate include
	// so that we can re-use this in other Application.cfcs
	// this.mappings[ "/com/chartsql/userdata"]
	include template="userdata_mapping.cfm";

	//Maintain key case of default serializer implementation.
	variables.zero.serializeToSnakeCase = false;

	//Set the Timezone of the datasource, we always want to use UTC
	this.timezone = "UTC";

	//Enable compression (GZip) for the Lucee Response stream for text-based responses when supported by the client (Web Browser)
	this.compression = true;

	processingdirective preserveCase="true";

	variables.zero.devmode = fileRead("devmode.txt");
	variables.zero.checkReloadOrm = false;
	variables.zero.maintainScrollPosition = cgi.path_info.contains("/studio/settings");
	variables.zero.scrollPositionBackgroundColor = "##151f2c;";
	variables.framework.defaultSubsystem = "studio";

	if (!isDefined("server.ShouldLoadDefaultPackage")) {
		server.ShouldLoadDefaultPackage = true;
	}

	/**
	 * Used to manipulate request variables before they are passed to controllers.
	 * @param  {struct} rc All of the URL and FORM variable put into one structure. RC is a reference to request.context
	 * @return {Struct}    The result of the RC is then passed onto the controller for this call
	 */
	public struct function request( rc ){

		request.timerData = {}

		var ChartSQLStudio = this.getChartSQLStudio();
		ChartSQLStudio.executeExtensions("onRequest", {context: arguments.rc});

		var memoryUsage = getMemoryUsage();

		request.performanceDataStart = {
			requestTime: now(),
			startTick: getTickCount(),
			memoryUsage: (memoryUsage.used[4] + memoryUsage.used[5] + memoryUsage.used[6]) / 1024 / 1024
		};

		// Copy the request context so that we can use it later in the extensions
		// because by default the context is replaced by the controller output in fw/1
		request.extensionsContext = duplicate(rc);

		return rc;
	}

	/**
	 * Called after controller execution and before the view. Here you
	 * can make any additional changes if necessary to inject more values
	 * for the view.
	 *
	 * @rc  {struct} rc the request of the request context and
	 * @result  {any} the result of the call to the controller
	 * @return {any}    The modified result to be used by the view
	 */
	public any function result( controllerResult ){

		arguments.controllerResult.subsystem = this.getSubsystem();
		arguments.controllerResult.section = this.getSection();
		arguments.controllerResult.item = this.getItem();
		arguments.controllerResult.method = cgi.REQUEST_METHOD;
		arguments.controllerResult.action = "#this.getSubsystem()#:#this.getSection()#.#this.getItem()#";

		var ChartSQLStudio = this.getChartSQLStudio();

		var openedDropdownMenuItems = request.context.client_state?.opened_dropdown_menu_items ?: "";

		arguments.controllerResult.MenuItems = this.serializeFast(ChartSQLStudio.getMenuItems(), {
			Name:{},
			Link:{},
			OpenNewTab:{},
			IconClass:{},
			Location:{},
			IsActive: function(MenuItem){
				var pathInfo = cgi.path_info;
				var pathLength = len(MenuItem.getLink());
				if(pathInfo contains MenuItem.getLink()){
					return true;
				} else {
					return false;
				}
			},
			HasChildren:{},
			Children:{
				Name:{},
				Link:{},
				IconClass:{}
			},
			Tooltip:{},
			IsOpen: function (MenuItem) {
				if (openedDropdownMenuItems.contains(MenuItem.getName())) {
					return true;
				} else {
					return false;
				}
			}
		})

		ChartSQLStudio.executeExtensions("onResult", {
			requestContext: request.extensionsContext,
			result: arguments.controllerResult
		});

		request.timerData.controllerResult = getTickCount() - (request.startTick?:getTickCount());
		request.startTick = getTickCount();

		var controllerResult = arguments.controllerResult;

		var ChartSQLStudio = this.getChartSQLStudio();
		var qs = ChartSQLStudio.getEditorQueryString();

		arguments.controllerResult.data.GlobalChartSQLStudio = this.serializeFast(ChartSQLStudio, {
			isPackagesDropdownOpened: function (GlobalChartSQLStudio) {
				if (openedDropdownMenuItems.contains("packages-menu-item")) {
					return true;
				} else {
					return false;
				}
			},
			Packages:{
				FullName:{},
				FriendlyName:{},
				IsReadOnly:{},
				OpenPackageParams: function(Package){
					var qs = qs.clone();
					qs.setValue("PackageName", Package.getFullName())
					.delete("Filter")
					.delete("SchemaFilter");

					var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
					if(StudioDatasourceOptional.exists()){
						var StudioDatasource = StudioDatasourceOptional.get();
						qs.setValue("StudioDatasource", StudioDatasource.getName());
					}

					return qs.getFields();
				},
				OpenPackageLink: function(Package){
					var qs = qs.clone();
					qs.setValue("PackageName", Package.getFullName())
					.delete("Filter")
					.delete("SchemaFilter");

					var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
					if(StudioDatasourceOptional.exists()){
						var StudioDatasource = StudioDatasourceOptional.get();
						qs.setValue("StudioDatasource", StudioDatasource.getName());
					}

					return qs.get();
				},
			}
		});

		if(this.getSubsystem() == "studio" and this.getSection() == "main"){
			var qs = new zero.plugins.zerotable.model.queryStringNew(this.getQueryString());
			qs.setBasePath("/studio/main");
			ChartSQLStudio.setLastPresentationUrl(qs.clone().setValue("PresentationMode", "true").setValue("RenderPanelView", "chart").get());
			ChartSQLStudio.setLastEditorUrl(qs.clone().delete("PresentationMode").get());
		}

		if(this.getCgiRequestMethod() == "GET"){

			controllerResult.data.isGlobalSearching = false;
			controllerResult.view_state.globalSearchQuery = nullValue();

			// Get param globalSearchQuery from request
			if (isDefined("request.context.globalSearchQuery")) {
				controllerResult.data.isGlobalSearching = true;
				var globalSearchQuery = request.context.globalSearchQuery;
				controllerResult.view_state.globalSearchQuery = globalSearchQuery;
				if (!isNull(globalSearchQuery) && !isEmpty(globalSearchQuery)) {
					var searchResults = ChartSQLStudio.globalSearch(globalSearchQuery);
					controllerResult.data.globalSearchResults = searchResults;
				} else {
					controllerResult.data.globalSearchResults = ChartSQLStudio.globalSearch();
				}
			} else {
				controllerResult.data.globalSearchResults = ChartSQLStudio.globalSearch();
			}

			controllerResult.view_state.section = this.getSection();
			// The editor link should remove the PresentationMode variable from the URL
			// to get back to the same file as we were in preview mode
			controllerResult.view_state.editor_link = ChartSQLStudio.getLastEditorUrl();

		}

		return arguments.controllerResult;
	}

	/**
	 * Receives the final respons that is going to be returned to the client. This is the HTML
	 * or text encoded JSON that will be returned. This function can be used to
	 * manipulate optionally manipulate the final text response
	 *
	 *
	 * @param  {string} string response  the final output to be returned.
	 * @return {string} Must return a string for the response to complete;
	 */
	public string function response( string response){
		request.timerData.htmlRendering = getTickCount() - request.startTick;

		var startTick = getTickCount();
		var performanceData = this.getPerformanceData();
		var memoryUsage = getMemoryUsage();
		var performanceDataInsert = {
			id: application.requestCounter++,
			requestDuration: getTickCount() - request.performanceDataStart.startTick,
			memoryUsage: (memoryUsage.used[4] + memoryUsage.used[5] + memoryUsage.used[6]) / 1024 / 1024,
			memoryUsageDelta: ((memoryUsage.used[4] + memoryUsage.used[5] + memoryUsage.used[6]) / 1024 / 1024) - request.performanceDataStart.memoryUsage,
			memoryMax: (memoryUsage.max[4] + memoryUsage.max[5] + memoryUsage.max[6]) / 1024 / 1024
		};

		if(performanceData.recordCount >= 100){
			queryDeleteRow(performanceData, 1);
		}
		queryAddRow(performanceData, performanceDataInsert);
		request.timerData.performanceDataInsert = getTickCount() - startTick;

		// We are going to create a new JSOUP document from the response that will be
		// passed to the extensions for manipulation
		var extensionsRenderStartTick = getTickCount();
		if(this.getContentType() == "html" ){
			var jsoup = this.getJsoup();
			var doc = jsoup.parse(response);

			var ChartSQLStudio = this.getChartSQLStudio();
			if(this.getSubsystem() == "studio" and this.getItem() != "keyPerformanceInfo"){
				var extensionsTimes = {}
				for(var Extension in ChartSQLStudio.getExtensions()){
					var startTick = getTickCount();
					try {
						var response = Extension.onRender(
							requestContext = request.extensionsContext,
							result = request.context,
							doc = doc
						);

					}catch(any e){
						// writeDump(Extension);
						writeDump(e);
						abort;

					}
					extensionsTimes[Extension.getName()] = getTickCount() - startTick;
				}
				request.timerData.extensionsOnRenderTimes = extensionsTimes;
			}

			var response = doc.toString();
		}
		request.timerData.extensionsOnRender = getTickCount() - extensionsRenderStartTick;

		// writeDump(request.timerData);
		// abort;
		// writeDump(application.performanceData);
		return response;
	}

	function onError(error, template){
		// writeDump(error);
		// abort;
		writeLog(file="onError", text=error.message);
		if(variables.zero.devmode > 0){
			if(isDefined('arguments[1].cause.SQLException')){
				writeDump(arguments[1].cause.SqlException.getMessage());
				writeDump(arguments);
			} else {
				writeDump(arguments);
			}
			abort;
		} else {
			// writeDump(arguments.error);
			// abort;
			// this.logPageView(Error=arguments.error);

			if(this.getContentType() == "json"){
				echo(serializeJson({
					error: {
						message: arguments.error.message,
						type: arguments.error.type,
						detail: arguments.error.detail
					}
				}));
				abort;
			} else {
				//Include the default error handler template
				writeDump(error);
				abort;
				// include template="500.cfm";
				// abort;
			}
		}
	}

	function onFailure(error){
		// writeDump(error);
		// abort;



		writeLog(file="onFailure", text=error.message);
		if(arguments.error.type == "auth.resourceNotAuthorized"){
			header statuscode="400" statustext="Method Not Allowed";
			echo("Your account is not authorized for #request.action#. <a href=""javascript:history.back()"">Go back</a>");
			abort;
		} else {
			if(
				   error.type == "application"
				or error.type == "expression"
				or error.type contains "org.hibernate"
			){
				//Will throw to the onError and be caught there
				this.onError(arguments.error);
			}
		}
	}

	/**
	 * Allows us to redirect to a new location and override in test
	 *
	 * @urlPath {string} The path to redirect to
	 */
	public function doLocation(string urlPath){
		location url="#arguments.urlPath#" addToken="false";
	}

	public function getChartSQLStudio(){

		if(url.keyExists("reloadStudio")){
			application.delete("ChartSQLStudio");
			session.delete("EditorSession");
			server.ShouldLoadDefaultPackage = true;
		}

		// Check if the .hash.text file for the model code has changed and if so
		// then we need to reload the ChartSQLStudio by deleting it from the
		// application scope
		var studioModelHash = fileRead(expandPath("/com/chartsql/studio/model/.hash.txt"));
		if(application.keyExists("ChartSQLStudio")){
			if(studioModelHash != application.ChartSQLStudio.getStudioModelHash()){
				application.delete("ChartSQLStudio");
				session.delete("EditorSession");
				server.delete("ShouldLoadDefaultPackage");
			}
		}

		// We are going to create a name that uniquely identifies where this ChartSQL
		// installation is located so that we can have multiple installations. This
		// can be used for testing or where the user wants to run multiple versions.
		var installLocation = getDirectoryFromPath(getCurrentTemplatePath())
			.replace(server.separator.file, "_", "all")
			.replace(":", "_", "all")
			.replace(".", "_", "all")

		var dirPath = homeDirectory & server.separator.file & "ChartSQL" & server.separator.file & installLocation;

		if(!directoryExists(dirPath)){
			directoryCreate(dirPath, true);
			application.delete("ChartSQLStudio");
			session.delete("EditorSession");
			server.delete("ShouldLoadDefaultPackage");
		}

		var startTick = getTickCount();
		if(!application.keyExists("ChartSQLStudio")){

			if (server.system.properties.keyExists("user.home")) {
				homeDirectory = server.system.properties["user.home"];
			} else {
				homeDirectory = server.system.environment.appdata;
			}

			var configPath = dirPath & server.separator.file & "ChartSQLStudio.config.json";
			var dbBasePath = dirPath & server.separator.file & "db";
			var defaultScriptsPath = dirPath & server.separator.file & "sql_scripts";

			if(!directoryExists(dbBasePath)){
				directoryCreate(dbBasePath, true);
			}

			if(!directoryExists(defaultScriptsPath)){
				directoryCreate(defaultScriptsPath, true);
			}

			var gettingStartedPath = defaultScriptsPath & server.separator.file & "getting_started.sql";

			if(!fileExists(gettingStartedPath)){
				fileWrite(gettingStartedPath, fileRead("getting_started.sql"));
			}

			application.ChartSQLStudio = new studio.model.ChartSQLStudio(configPath);

			// Set the model hash so that we can detect when the model code has changed
			application.ChartSQLStudio.setStudioModelHash(studioModelHash);

			// Copy the examples database to the user's home directory
			var sourceDbDir = expandPath("/com/chartsql/studio/db/examples");
			var destinationDbDir = dbBasePath & server.separator.file & "examples";
			if(!directoryExists(destinationDbDir)){
				directoryCopy(sourceDbDir, destinationDbDir);
			}

			if(!application.ChartSQLStudio.findStudioDatasourceByName("Examples").exists()){
				var StudioDatasource = application.ChartSQLStudio.createStudioDatasource(
					Name = "Examples",
					type = "HSQLDB",
					config = {
						Database = "examples",
						FolderPath = destinationDbDir,
						Username = "root",
						Password = "root"
					}
				)
			}

			// We setup the Examples package for every installatgion
			var ExamplesPackageOptional = application.ChartSQLStudio.findPackageByFriendlyName("Examples");
			if(!ExamplesPackageOptional.exists()){
				var ExamplesPackage = application.ChartSQLStudio.createPackageFromFile(expandPath("/com/chartsql/studio/extensions/chartsql/examples/sql"));
				ExamplesPackage.setFriendlyName("Examples");
			} else {
				var ExamplesPackage = ExamplesPackageOptional.get();
				var StudioDatasource = application.ChartSQLStudio.findStudioDatasourceByName("Examples").get();
				ExamplesPackage.setDefaultStudioDatasource(StudioDatasource);
			}

			ExamplesPackage.setIsReadOnly(true);

			//Setup a default package to the user's home directory sql_scripts folder
			var DefaultPackageOptional = application.ChartSQLStudio.findPackageByFriendlyName("Scratchpad");
			if(!DefaultPackageOptional.exists()){
				var DefaultPackage = application.ChartSQLStudio.createPackageFromFile(defaultScriptsPath);
				DefaultPackage.setFriendlyName("Scratchpad");
			} else {
				var DefaultPackage = DefaultPackageOptional.get();
			}

			var StudioDatasource = application.ChartSQLStudio.findStudioDatasourceByName("Examples").get();
			DefaultPackage.setDefaultStudioDatasource(StudioDatasource);

			//If there is no default package set then we set it to the scratchpad
			if(isNull(application.ChartSQLStudio.getDefaultPackage())){
				application.ChartSQLStudio.setDefaultPackage(DefaultPackage);
			}

		}

		application.ChartSQLStudio.clearExtensions();

		var PresentExtension = new studio.model.Extension(
			Name = "chartsql.present.Present",
			ChartSQLStudio = application.ChartSQLStudio
		)

		var SchemaBrowserExtension = new studio.model.Extension(
			Name = "chartsql.schemabrowser.SchemaBrowser",
			ChartSQLStudio = application.ChartSQLStudio
		)

		var storyExtension = new studio.model.Extension(
			Name = "chartsql.story.Story",
			ChartSQLStudio = application.ChartSQLStudio
		)

		var ExamplesExtension = new studio.model.Extension(
			Name = "chartsql.examples.Examples",
			ChartSQLStudio = application.ChartSQLStudio
		)

		if(variables.zero.devmode > 0){
			var PublishExtension = new studio.model.Extension(
				Name = "chartsql.publish.Publish",
				ChartSQLStudio = application.ChartSQLStudio
			)
		}

		// If the samples code exists then we are in dev and we
		// should setup the samples package if it does not exist
		var samplesPath = expandPath("/core/sample");
		if(directoryExists(samplesPath)){
			var SamplesPackageOptional = application.ChartSQLStudio.findPackageByFriendlyName("Sample Charts");
			if(!SamplesPackageOptional.exists()){
				var Package = application.ChartSQLStudio.createPackageFromFile(expandPath("/core/sample"));
				Package.setFriendlyName("Sample Charts");
			}
		}

		application.ChartSQLStudio.setPublishingHost("http://127.0.0.1:54060");

		request.timerData.getChartSQLStudio = getTickCount() - startTick;

		return application.ChartSQLStudio;
	}

	public function getEditorSession(){
		var sessStruct = this.getSessionStruct();
		var ChartSQLStudio = this.getChartSQLStudio();
		if(!structKeyExists(sessStruct, "EditorSession")){
			sessStruct.EditorSession = new studio.model.EditorSession(
				ChartSQLStudio = ChartSQLStudio
			);
		}

		if(isNull(sessStruct.EditorSession.getCurrentStudioDatasource())){
		var StudioDatasources = ChartSQLStudio.getStudioDatasources();
			if(StudioDatasources.len() > 0){
				sessStruct.EditorSession.setCurrentStudioDatasource(StudioDatasources[1]);
			}
		}
		return sessStruct.EditorSession;
	}

	public function getSessionStruct(){
		return session;
	}

	public function getQueryString(){
		return cgi.query_string;
	}

	/**
	 * Override one.cfc parseViewOrLayoutPath so that we can detect handlebars
	 * files that we can use as layout and view paths
	 */
	private string function parseViewOrLayoutPath( string path, string type ) {
        var folder = type;
        switch ( folder ) {
        case 'layout':
            folder = variables.layoutFolder;
            break;
        case 'view':
            folder = variables.viewFolder;
            break;
        // else leave it alone?
        }
        var pathInfo = { };
        var subsystem = getSubsystem( getSubsystemSectionAndItem( path ) );

        // allow for :section/action to simplify logic in setupRequestWrapper():
        pathInfo.path = segmentLast( path, variables.framework.subsystemDelimiter );
        pathInfo.base = request.base;
        pathInfo.subsystem = subsystem;
        if ( usingSubsystems() || len( subsystem ) ) {
            pathInfo.base = pathInfo.base & getSubsystemDirPrefix( subsystem );
        }
        var defaultPath = pathInfo.base & folder & 's/' & pathInfo.path & '.cfm';
		if ( !cachedFileExists( defaultPath ) )
            defaultPath = pathInfo.base & folder & 's/' & pathInfo.path & '.cfm.hbs';
        if ( !cachedFileExists( defaultPath ) )
            defaultPath = pathInfo.base & folder & 's/' & pathInfo.path & '.lucee';
        if ( !cachedFileExists( defaultPath ) )
            defaultPath = pathInfo.base & folder & 's/' & pathInfo.path & '.lc';
        if ( !cachedFileExists( defaultPath ) )
            // can't find it so assume .cfm default value
            defaultPath = pathInfo.base & folder & 's/' & pathInfo.path & '.cfm';
        return customizeViewOrLayoutPath( pathInfo, type, defaultPath );
    }

	public function getPerformanceData(){
		if(!structKeyExists(application,"performanceData") or url.keyExists("clearPerformanceData")){
			application.requestCounter = 0;
			application.performanceData = queryNew(
				"id,requestDuration,memoryUsage,memoryUsageDelta,memoryMax",
				"string,numeric,numeric,numeric,numeric"
			);
		}
		return application.performanceData;
	}

}
