/**
 * An instance of the Studio Application
*/
component accessors="true" {

	processingdirective preservecase="true";
	property name="Packages";
	property name="Workspaces";
	property name="SqlFiles";
	property name="PackagePublishers";
	property name="PublishingHost" type="string";
	property name="UserDirectory";
	property name="ConfigPath";
	property name="Config";
	property name="LastEditorUrl";
	property name="LastPresentationUrl";
	property name="StudioDatasources";
	property name="DefaultPackage" type="Package" hint="The default package";
	property name="AvailableDatasourceTypes";
	property name="Extensions";
	property name="Storys";
	property name="CurrentQueryString" setter="false";
	property name="FileBrowserViews";
	property name="InfoPanelViews" type="array";
	property name="MenuItems" setter="false";
	property name="MascotBinary" type="binary";
	property name="LogoBinary" type="binary";
	property name="StudioModelHash" type="string" hint="Stored in Application to detect when source code has changed and needs to be reloaded";
	property name="PublishingAppId" type="numeric";
	property name="PublishingDevMode" type="numeric";
	property name="PublishingRequests" type="array";
	property name="PublishingResults" type="array";

	public function init(
		string UserDirectory
	){
		variables.Packages = [];
		variables.Workspaces = [];
		variables.SqlFiles = [];
		variables.PackagePublishers = [];
		variables.StudioDatasources = [];
		variables.Storys = [];
		variables.Extensions = [];
		variables.FileBrowserViews = [];
		variables.InfoPanelViews = [];
		variables.MenuItems = [];
		variables.StudioModelHash = "";
		variables.DefaultPackage = nullValue();
		variables.PublishingRequests = [];
		variables.PublishingResults = [];

		variables.LastEditorUrl = "/studio/main";
		variables.LastPresentationUrl = "/studio/main?PresentationMode=true&RenderPanelView=chart";

		if(arguments.keyExists("UserDirectory")){
			variables.UserDirectory = arguments.UserDirectory;
			variables.ConfigPath = "#arguments.UserDirectory#ChartSQLStudio.config.json";
			if(fileExists(variables.ConfigPath)){
				this.loadConfig();
			} else {
				saveConfig(); //Creates the empty config file
			}
		}

		//Setup default FileBrowserViews. Extensions can add additional FileBrowserViews to the editor
		var FileBrowserViews = [
			{name: "files", iconClass: "ti ti-file-type-sql", tooltip: "Show SQL Files"},
			{name: "schema", iconClass: "ti ti-database-search", tooltip: "Show Database Schemas"},
			// {name: "stories", iconClass: "ti ti-slideshow"}
		]
		for(var FileBrowserView in FileBrowserViews){
			var FileBrowserView = new FileBrowserView(
				ChartSQLStudio = this,
				Name = FileBrowserView.name,
				IconClass = FileBrowserView.iconClass,
				Tooltip = FileBrowserView.tooltip
			);
		}

		// Setup default InfoPanelViews. Extensions can add additional InfoPanelViews to the editor
		var InfoPanelViews = [
			{name: "resultset", iconClass: "ti ti-table", title: "Data"},
			{name: "executions", iconClass: "ti ti-sql", title: "Executions"},
			{name: "server", iconClass: "ti ti-bolt", title: "Editor Perf"},
		]

		for(var InfoPanelView in InfoPanelViews){
			var InfoPanelView = new InfoPanelView(
				ChartSQLStudio = this,
				Name = InfoPanelView.name,
				Title = InfoPanelView.title,
				IconClass = InfoPanelView.iconClass
			);
		}

		this.setupDefaultMenuItems();

		return this;
	}

	public function addFileBrowserView(FileBrowserView){
		if(!findFileBrowserViewByName(FileBrowserView.getName()).exists()){
			variables.FileBrowserViews.append(FileBrowserView);
		}
	}

	public function addInfoPanelView(InfoPanelView){
		if(!findInfoPanelViewByName(InfoPanelView.getName()).exists()){
			variables.InfoPanelViews.append(InfoPanelView);
		}
	}

	public function addPackagePublisher(PackagePublisher){
		variables.PackagePublishers.append(PackagePublisher);
	}

	public function addExtension(Extension){
		if(!findExtensionByName(Extension.getName()).exists()){
			variables.Extensions.append(Extension);
		}
	}

	public function addMenuItem(required MenuItem MenuItem){
		if(!this.findMenuItemByName(MenuItem.getName()).exists()){
			variables.MenuItems.append(MenuItem);
		}
	}

	public function addStory(required Story Story){
		if(!findStoryById(Story.getId()).exists()){
			variables.Storys.append(Story);
		}
	}

	public function addStudioDatasource(StudioDatasource){

		if(this.findStudioDatasourceByName(StudioDatasource.getName()).exists()){
			throw("A datasource with the name '#arguments.StudioDatasource.getName()#' already exists", "StudioDatasourceExists");
		}

		variables.StudioDatasources.append(StudioDatasource);
		this.saveConfig();
	}

	public function addPublishingRequest(PublishingRequest){
		variables.PublishingRequests.append(PublishingRequest);
	}

	public function addPublishingResult(PublishingResult){
		variables.PublishingResults.append(PublishingResult);
	}

	public function clearExtensions(){
		variables.Extensions = [];
	}

	/**
	 * Utility function to count the number of items in a collection from this instance
	 *
	 * @collection
	 */
	public function count(required string collection){
		return variables[collection].len();
	}

	public function createExtension(
		required string Name
	){
		var Extension = new Extension(
			ChartSQLStudio = this,
			Name = arguments.Name
		);
		return Extension;
	}

	public function createPackageFromFile(
		required string path,
		required string FriendlyName,
		string DashId,
		string PublisherKey
	){

		var Package = Package::fromFile(
			directory=path,
			ChartSQLStudio=this,
			FriendlyName=arguments.FriendlyName
		);

		if(arguments.keyExists("DashId")){
			Package.setDashId(arguments.DashId);
		}

		if(arguments.keyExists("PublisherKey")){
			Package.setPublisherKey(arguments.PublisherKey);
		}

		this.saveConfig();
		return Package;
	}

	public function createWorkspace(
		string FriendlyName
	) {
		var Workspace = new Workspace(
			FriendlyName = FriendlyName,
			ChartSQLStudio = this
		);
		this.saveConfig();
		return Workspace;
	}

	/**
	 * Creates a StudioDatasource instance which holds a reference to the Datasource
	 * object that will be queried against
	 *
	 * @Name A friendly name for the datasource
	 * @Type The type of datasource to create
	 * @config A struct of configuration options for the datasource
	 */
	public function createStudioDatasource(
		required string Name,
		required string Type,
		required struct config
	){
		// var ImpDatasource = createObject("core.model.datsources.#arguments.Type#").init(argumentCollection=arguments.config);
		var StudioDatasource = new StudioDatasource(
			Name = arguments.Name,
			Type = arguments.Type,
			Config = arguments.config,
			ChartSQLStudio = this
		);
		this.saveConfig();
		return StudioDatasource;
	}

	/**
	 * Deletes the package from the instance
	 *
	 * @Package
	 */
	public void function deletePackage(required Package Package){
		var newPackages = [];
		if (!isNull(variables.DefaultPackage) and Package.getUniqueId() == variables.DefaultPackage.getUniqueId()){
			variables.DefaultPackage = nullValue();
		}
		for(var Package in variables.Packages){
			if(Package.getUniqueId() != arguments.Package.getUniqueId()){
				arrayAppend(newPackages, Package);
			}
		}
		variables.Packages = newPackages;
		this.saveConfig();
	}

	/**
	 * Deletes the Workspace from the instance
	 *
	 * @Package
	 */
	public void function deleteWorkspace(required Workspace Workspace){
		var newWorkspaces = [];
		for(var Workspace in variables.Workspaces){
			if(Workspace.getUniqueId() != arguments.Workspace.getUniqueId()){
				arrayAppend(newWorkspaces, Workspace);
			}
		}
		variables.Workspaces = newWorkspaces;
		this.saveConfig();
	}

	/**
	 * Deletes the StudioDatasource from the instance
	 *
	 * @StudioDatasource
	 */
	public function deleteStudioDatasource(StudioDatasource){
		var newStudioDatasources = [];
		for(var StudioDatasource in variables.StudioDatasources){
			if(StudioDatasource.getName() != arguments.StudioDatasource.getName()){
				arrayAppend(newStudioDatasources, StudioDatasource);
			}
		}
		variables.StudioDatasources = newStudioDatasources;
		this.saveConfig();
	}

	public function executeExtensions(
		required string funcName,
		required struct args
	){
		for(var Extension in variables.Extensions){
			Extension[funcName](argumentCollection=args);
		}
	}

	public optional function findFileBrowserViewByName(
		required string name
	){
		for(var FileBrowserView in variables.FileBrowserViews){
			if(FileBrowserView.getName() == arguments.name){
				return new optional(FileBrowserView);
			}
		}
		return new optional(nullValue());
	}

	public optional function findInfoPanelViewByName(
		required string name
	){
		for(var InfoPanelView in variables.InfoPanelViews){
			if(InfoPanelView.getName() == arguments.name){
				return new optional(InfoPanelView);
			}
		}
		return new optional(nullValue());
	}

	public optional function findMenuItemByName(
		required string name
	){
		for(var MenuItem in variables.MenuItems){
			if(MenuItem.getName() == arguments.name){
				return new optional(MenuItem);
			}
		}
		return new optional(nullValue());
	}

	public optional function findPackageByFriendlyName(
		required string name
	){
		for (var Package in variables.Packages){
			if (Package.getFriendlyName() == arguments.name){
				return new optional(Package);
			}
		}
		return new optional(nullValue());
	}

	public optional function findPackageByUniqueId(
		required string UniqueId
	) {
		for (var Package in variables.Packages){
			if (Package.getUniqueId() == arguments.UniqueId){
				return new optional(Package);
			}
		}
		return new optional(nullValue());
	}

	public optional function findWorkspaceByUniqueId(
		required string UniqueId
	) {
		for (var Workspace in variables.Workspaces){
			if (Workspace.getUniqueId() == arguments.UniqueId){
				return new optional(Workspace);
			}
		}
		return new optional(nullValue());
	}

	public optional function findStoryById(
		required string id
	) {
		for (var Story in variables.Storys){
			if (Story.getId() == id){
				return new optional(Story);
			}
		}
		return new optional(nullValue());
	}

	public optional function findStudioDatasourceByName(
		required string name
	){
		for(var StudioDatasource in variables.StudioDatasources){
			if(StudioDatasource.getName() == arguments.name){
				return new optional(StudioDatasource);
			}
		}
		return new optional(nullValue());
	}

	public optional function findExtensionByName(
		required string name
	){
		for(var Extension in variables.Extensions){
			if(Extension.getName() == arguments.name){
				return new optional(Extension);
			}
		}
		return new optional(nullValue());
	}

	public optional function findSqlFileByFullName(required string name){
		for(var sqlFile in variables.SqlFiles){
			if(sqlFile.getFullName() == arguments.name){
				return new optional(sqlFile);
			}
		}
		return new optional(nullValue());
	}

	/**
	 * returns an array of info about available datasource types that the user can configure
	 *
	 */
	public array function getAvailableDatasourceTypes(){

		var out = [];
		var datasourcePath = expandPath("/core/model/datasources");
		var datasourceFiles = directoryList(datasourcePath, true, "query", "*.cfc", "", "file");
		for(var file in datasourceFiles){
			// writeDump(file);
			// writeDump(datasourcePath);
			var cfcPath = file.directory.replace(datasourcePath, "")
			var name = file.name.replace(".cfc", "");
			cfcPath = "/core/model/datasources" & cfcPath & "/" & name;
			cfcPath = replace(cfcPath, "/", ".", "all").replace("\", ".", "all");
			if(left(cfcPath, 1) == "."){
				cfcPath = right(cfcPath, len(cfcPath)-1);
			}
			// writeDump(cfcPath);
			var className = replace(file.name, ".cfc", "");

			var metaData = getComponentMetaData(cfcpath)
			if(metaData.keyExists("isStudioDatasource") and metaData.isStudioDatasource){
				out.append({
					Name = metaData.displayName?:className,
					Description = metaData.description?:"#className# Connector",
					Type = className,
					IconClass = metaData.iconClass?:"ti ti-database"
				});
			}

			// writeDump(datasource);
		}
		// writeDump(datasourceFiles);
		return out;
	}

	/**
	 * Globablly define the base publishing url for the ChartSQL Studio which takes a key
	 * that is the ID of the publisher that the user is publishing to.
	 *
	 * @key
	 */
	public function getBasePublishingUrl(
		required string key
	){
		return "#this.getPublishingHost()#/PublisherKey/#arguments.key#/main";
	}

	public function getDatasourceTemplate(
		required string Type
	){
		var datasource = createObject("core.model.datasources.#arguments.Type#.#arguments.Type#");
		return datasource.getStudioConfigTemplate();
	}

	/**
	 * Returns the binary image of the Mascot that we are going to load dynamically into the
	 * editor. This allows us to change the mascot dynamically so that we can support
	 * white labeling the ChartSQL editor
	 */
	public function getMascotBinary(){
		if(isNull(variables.MascotBinary)){
			var image = fileReadBinary(expandPath("/com/chartsql/studio/wwwroot/assets/img/mascot1.fw.png"));
		} else {
			var image = variables.MascotBinary;
		}
		return image;
	}

	/**
	 * Returns the binary image of the Mascot that we are going to load dynamically into the
	 * editor. This allows us to change the mascot dynamically so that we can support
	 * white labeling the ChartSQL editor
	 */
	public function getLogoBinary(){
		if(isNull(variables.LogoBinary)){
			var image = fileReadBinary(expandPath("/com/chartsql/studio/wwwroot/assets/img/logo.fw.png"));
		} else {
			var image = variables.LogoBinary;
		}
		return image;
	}

	/**
	 * Override getPublishingHost to throw an error if not set so that we can
	 * alert the develper in testing to set the host
	 */
	public function getPublishingHost(){
		if(isNull(variables.PublishingHost)){
			throw("PublishingHost is not set.");
		} else {
			return variables.PublishingHost;
		}
	}

	/**
	 * Adds the SQL file if it does not already exist
	 *
	 * @SqlFile
	 */
	public function addSqlFile(SqlFile){
		if(!findSqlFileByFullName(SqlFile.getFullName()).exists()){
			variables.SqlFiles.append(SqlFile);
		}
	}

	public function removeSqlFile(SqlFile) {
		var newSqlFiles = [];
		for(var sqlFile in variables.SqlFiles){
			if(sqlFile.getFullName() != arguments.SqlFile.getFullName()){
				arrayAppend(newSqlFiles, sqlFile);
			}
		}
		variables.SqlFiles = newSqlFiles;
	}

	/**
	 * Adds the package to the instance if it does not already exist
	 *
	 * @Package
	 */
	public function addPackage(required Package Package){
		if(!this.findPackageByPath(Package.getPath()).exists()){
			variables.Packages.append(Package);
		}
		this.saveConfig();
	}

	/**
	 * Adds the Workspace to the instance if it does not already exist
	 */
	public function addWorkspace(required Workspace Workspace){
		// Check if a Workspace with the same UniqueId already exists
		if (!this.findWorkspaceByUniqueId(Workspace.getUniqueId()).exists()) {
			variables.Workspaces.append(Workspace);
		}
		this.saveConfig();
	}

	public function findPackageByPath(required string path){
		for(var Package in variables.Packages){
			if(Package.getPath() == arguments.path){
				return new optional(Package);
			}
		}
		return new optional(nullValue());
	}

	public function setDefaultPackage(required Package Package){

		for(var Package in variables.Packages){
			Package.setIsDefaultPackage(false);
		}

		arguments.Package.setIsDefaultPackage(true);
		variables.DefaultPackage = arguments.Package;

		this.saveConfig();
	}

	public function getSqlFiles(){
		var out = [];
		for(var sqlFile in variables.SqlFiles){
			arrayAppend(out, sqlFile);
		}
		return out;
	}

	/**
	 * Removes the story from the collection by creating a new collection
	 * of stories without the one to be removed
	 */
	public function removeStory(required Story Story){
		var newStorys = [];
		for(var story in variables.Storys){
			if(story.getId() != arguments.Story.getId()){
				arrayAppend(newStorys, story);
			}
		}
		variables.Storys = newStorys;
	}

	public function saveConfig(){
		if(variables.keyExists("ConfigPath")){
			var out = new zero.serializerFast(this, {
				Packages:{
					UniqueId: {},
					FriendlyName: {},
					Path:{},
					IsReadOnly:{},
					DashId:{},
					PublisherKey:{},
					DefaultStudioDatasource:{
						Name:{}
					},
					Storys:{
						Name:{},
						Id:{},
						Slides:{
							FullName:{},
							Title:{},
							Id:{}
						}
					}
				},
				Workspaces: {
					FriendlyName: {},
					UniqueId: {},
					WorkspacePackages: {
						DefaultStudioDatasource: {
							Name: {}
						},
						Package: {
							UniqueId: {}
						}
					}
				},
				DefaultPackage: {
					UniqueId:{}
				},
				StudioDatasources:{
					Name:{},
					Type:{},
					Config: function(StudioDatasource){
						return StudioDatasource.getConfig();
					}
				}
			})
			// variables.config = out;
			var ConfigFile = ConfigFile::fromStruct(out);
			ConfigFile.setPath(variables.ConfigPath);
			ConfigFile.write();
		}
	}

	public function setupDefaultMenuItems(){

		var MenuItem = new MenuItem(
			ChartSQLStudio = this,
			StepOrder = 1,
			Name = "Docs",
			IconClass = "ti ti-book",
			Link = "https://docs.chartsql.com/",
			Tooltip = "Open Docs",
			Location = "bottom",
			OpenNewTab = true
		);

		var MenuItem = new MenuItem(
			ChartSQLStudio = this,
			Name = "Settings",
			StepOrder = 4,
			IconClass = "ti ti-settings",
			Link = "/studio/settings",
			Tooltip = "Editor Settings",
			Location = "bottom",
			OpenNewTab = false
		);
	}

	public function getMenuItems() {
		// Sort the menu items by StepOrder then return
		return variables.MenuItems.sort(function(a, b){
			return a.getStepOrder() - b.getStepOrder();
		});
	}

	public function loadConfig(){
		variables.Config = deserializeJson(fileRead(variables.ConfigPath));

		var fileName = 'expanded_logo.png';
		var filePath = this.getUserDirectory() & server.separator.file & fileName;
		if (fileExists(filePath)) {
			var imageBinary = fileReadBinary(filePath);
			variables.LogoBinary = imageBinary;
		}

		var fileName = 'small-logo.png';
		var filePath = this.getUserDirectory() & server.separator.file & fileName;
		if (fileExists(filePath)) {
			var imageBinary = fileReadBinary(filePath);
			variables.MascotBinary = imageBinary;
		}

		//Load the StudioDatasources
		if(variables.Config.keyExists("StudioDatasources") and isArray(variables.Config.StudioDatasources)){
			variables.StudioDatasources = [];
			for(var StudioDatasource in variables.Config.StudioDatasources){
				var NewStudioDatasource = new StudioDatasource(
					Name = StudioDatasource.Name,
					Type = StudioDatasource.Type,
					Config = StudioDatasource.Config,
					ChartSQLStudio = this
				);
			}
		}

		//Load the packages
		if(variables.Config.keyExists("Packages") and isArray(variables.Config.Packages)){
			variables.Packages = [];
			for(var Package in variables.Config.Packages){

				if (isDefined('Package.UniqueId')) {
					var UniqueId = Package.UniqueId;
				} else {
					// Otherwise generate a new one
					UniqueId = this.generateUniqueIdForPackage(
						Package.FriendlyName
					);
				}

				var NewPackage = new Package(
					path = Package.Path,
					ChartSQLStudio = this,
					FriendlyName = Package.FriendlyName?:"New Package",
					UniqueId = UniqueId,
					PublisherKey = Package.PublisherKey?:nullValue(),
					DashId = Package.DashId?:nullValue()
				);

				if (
					isDefined('variables.Config.DefaultPackage.UniqueId')
					and variables.Config.DefaultPackage.UniqueId
					== Package.UniqueId
				) {
					this.setDefaultPackage(NewPackage);
					NewPackage.setIsDefaultPackage(true);
				}

				if(isDefined("package.DefaultStudioDatasource.Name")){
					var StudioDatasourceOptional = this.findStudioDatasourceByName(Package.DefaultStudioDatasource.Name);
					if(StudioDatasourceOptional.exists()){
						var StudioDatasource = StudioDatasourceOptional.get();
						NewPackage.setDefaultStudioDatasource(StudioDatasource);
					}
				}

				//Restore the stories
				if(Package.keyExists("Storys") and isArray(Package.Storys)){
					for(var Story in Package.Storys){

						var NewStory = NewPackage.createStory(
							Name = Story.Name,
							Id = Story.Id
						);

						for(var slideConfig in Story.Slides){
							var Slide = NewStory.createSlide(
								Title = slideConfig.Title,
								FullName = slideConfig.FullName,
								Id = slideConfig.Id
							);
						}

					}
				}

			}
		}

		// Load Workspaces
		if(variables.Config.keyExists("Workspaces") and isArray(variables.Config.Workspaces)){
			variables.Workspaces = [];
			for(var Workspace in variables.Config.Workspaces){
				var newWorkspace = new Workspace(
					FriendlyName = Workspace.FriendlyName,
					UniqueId = Workspace.UniqueId,
					ChartSQLStudio = this
				);

				// Add all the packages to the Workspace that are in the Workspace.Packages array
				for(var WorkspacePackage in Workspace.WorkspacePackages){
					var PackageOptional = this.findPackageByUniqueId(WorkspacePackage.Package.UniqueId);
					if (PackageOptional.exists()) {
						var Package = PackageOptional.get();
						var newWorkspacePackage = newWorkspace.addPackage(Package);
						if (isDefined('WorkspacePackage.DefaultStudioDatasource')
							and !isNull('WorkspacePackage.DefaultStudioDatasource')
							and !isEmpty(WorkspacePackage.DefaultStudioDatasource)
						) {
							var StudioDatasourceOptional = this.findStudioDatasourceByName(WorkspacePackage.DefaultStudioDatasource.Name);
							if (StudioDatasourceOptional.exists()) {
								var StudioDatasource = StudioDatasourceOptional.get();
								newWorkspacePackage.setDefaultStudioDatasource(StudioDatasource);
							}
						}
					}
				}
			}
		}
		this.saveConfig();
	}

	public function generateUniqueIdForPackage(required string PackageFriendlyName) {
		var i = 1;
		var newUniqueId = new values.PackageUniqueId(arguments.PackageFriendlyName).toString();
		while(this.findPackageByUniqueId(newUniqueId).exists()){
			newUniqueId = new values.PackageUniqueId(arguments.PackageFriendlyName & "_#i#").toString();
			i++;
		}
		return newUniqueId;
	}

	public function generateUniqueIdForWorkspace(required string WorkspaceFriendlyname) {
		var i = 1;
		var newUniqueId = new values.WorkspaceUniqueId(arguments.WorkspaceFriendlyname).toString();
		while(this.findWorkspaceByUniqueId(newUniqueId).exists()){
			newUniqueId = new values.WorkspaceUniqueId(arguments.WorkspaceFriendlyname & "_#i#").toString();
			i++;
		}
		return newUniqueId;
	}

	/**
	 * Searches the Packages, DataSources, and SqlFiles for the search string
	 * in that order
	 *
	 * @search
	 */
	public function globalSearch(string search) {
		// We are going to dynamically create a query string object for the users state
		var qs = this.getEditorQueryString();

		if (isNull(arguments.search) || isEmpty(arguments.search)) {
			// Get all open files
			var openFiles = [];
			if (request.context.keyExists("OpenFiles"))  {
				var openFiles = listToArray(request.context.OpenFiles, ",");
			}

			// Loop through open files
			var results = [];

			for (fileName in openFiles) {
				var SqlFileOptional = this.findSqlFileByFullName(fileName);
				if (!SqlFileOptional.exists()) {
					continue;
				}

				var SqlFile = SqlFileOptional.get();
				if (!isNull(SqlFile)) {
					var SqlFileNamedDirectives = SqlFile.getNamedDirectives();
					var PackageName = SqlFile.getPackage().getFriendlyName();
					var name = "#SqlFile.getName()# (#PackageName#)";

					if (
						SqlFileNamedDirectives.keyExists("Title")
						&& !isNull(SqlFileNamedDirectives.Title)
						&& !isNull(SqlFileNamedDirectives.Title.getValueRaw())
						&& !isEmpty(SqlFileNamedDirectives.Title.getValueRaw())
					) {
						name = "#SqlFileNamedDirectives.Title.getValueRaw()# (#PackageName#)";
					}

					results.append({
						"name": name,
						"entityType": "SqlFile",
						"priority": 3,
						"subpriority": 1,
						"metadata": new zero.serializerFast(SqlFile, {
							IsOpen: function (SqlFile) {
								return true;
							},
							OpenLink: function(SqlFiles){
								if (!isDefined("request.context.OpenFiles") || isNull(request.context.OpenFiles)) {
									request.context.OpenFiles = "";
								}
								var openFileNames = listToArray(request.context.OpenFiles);
								var openFileKeys = structNew("ordered");
								for(var name in openFileNames){
									openFileKeys[name] = true;
								}
								var keys = duplicate(openFileKeys);
								keys[SqlFiles.getFullName()] = true;
								var clonedQs = qs.clone();
								// if (isDefined("request.context.WorkspaceName") && !isNull(request.context.WorkspaceName) && !isEmpty(request.context.WorkspaceName)) {
								// 	clonedQs.setValue("WorkspaceName", request.context.WorkspaceName);
								// }
								// if (isDefined("request.context.PackageName") && !isNull(request.context.PackageName) && !isEmpty(request.context.PackageName)) {
								// 	clonedQs.setValue("PackageName", request.context.PackageName);
								// } else if (!isDefined("request.context.WorkspaceName")) {
								// 	clonedQs.setValue("PackageName", SqlFiles.getPackage().getUniqueId());
								// }
								return clonedQs.setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFiles.getFullName()).get();
							},
						})
					});
				}
			}

			// Get all files from the current packagee
			var currentPackage = this.getDefaultPackage();

			if (isDefined("request.context.PackageName")) {
				currentPackageOptional = this.findPackageByUniqueId(request.context.PackageName);
				if (currentPackageOptional.exists()) {
					currentPackage = currentPackageOptional.get();
				}
			} else {
				var Packages = this.getPackages();
				if (Packages.len() > 0) {
					currentPackage = Packages[1];
				}
			}

			if (!isNull(currentPackage)) {
				for (var SqlFile in currentPackage.getSqlFiles()) {
					var SqlFileNamedDirectives = SqlFile.getNamedDirectives();
					var PackageName = SqlFile.getPackage().getFriendlyName();
					var name = "#SqlFile.getName()# (#PackageName#)";

					if (
						SqlFileNamedDirectives.keyExists("Title")
						&& !isNull(SqlFileNamedDirectives.Title)
						&& !isNull(SqlFileNamedDirectives.Title.getValueRaw())
						&& !isEmpty(SqlFileNamedDirectives.Title.getValueRaw())
					) {
						name = "#SqlFileNamedDirectives.Title.getValueRaw()# (#PackageName#)";
					}

					results.append({
						"name": name,
						"entityType": "SqlFile",
						"priority": 3,
						"subpriority": 2,
						"metadata": new zero.serializerFast(SqlFile, {
							OpenLink: function(SqlFiles){
								if (!isDefined("request.context.OpenFiles") || isNull(request.context.OpenFiles)) {
									request.context.OpenFiles = "";
								}
								var openFileNames = listToArray(request.context.OpenFiles);
								var openFileKeys = structNew("ordered");
								for(var name in openFileNames){
									openFileKeys[name] = true;
								}
								var keys = duplicate(openFileKeys);
								keys[SqlFiles.getFullName()] = true;
								var clonedQs = qs.clone();
								// if (isDefined("request.context.WorkspaceName") && !isNull(request.context.WorkspaceName) && !isEmpty(request.context.WorkspaceName)) {
								// 	clonedQs.setValue("WorkspaceName", request.context.WorkspaceName);
								// }
								// if (isDefined("request.context.PackageName") && !isNull(request.context.PackageName) && !isEmpty(request.context.PackageName)) {
								// 	clonedQs.setValue("PackageName", request.context.PackageName);
								// } else if (!isDefined("request.context.WorkspaceName")) {
								// 	clonedQs.setValue("PackageName", SqlFiles.getPackage().getUniqueId());
								// }
								return clonedQs.setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFiles.getFullName()).get();
							},
						})
					});
				}
			}

			// Sort by subpriority
			results = results.sort(function(a, b){
				return a.subpriority - b.subpriority;
			});

			return {
				results: results,
				resultsByType: {
					"packages": [],
					"datasources": [],
					"sqlfiles": results
				}
			};
		}

		var out = [];
		var resultsByType = {
			"packages": [],
			"datasources": [],
			"sqlfiles": []
		};

		for(var Package in variables.Packages){
			if(customFind(arguments.search, Package.getFriendlyName())){
				result = {
					"name": Package.getFriendlyName(),
					"entityType": "package",
					"priority": 1,
					"subpriority": 1,
					"metadata": new zero.serializerFast(Package, {
						UniqueId:{},
						OpenPackageLink: function(Package){
							var clonedQs = qs.clone();
							clonedQs.setValue("PackageName", Package.getUniqueId())
							.delete("SchemaFilter")
							.delete("Filter");

							var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
							if(StudioDatasourceOptional.exists()){
								var StudioDatasource = StudioDatasourceOptional.get();
								clonedQs.setValue("StudioDatasource", StudioDatasource.getName());
							}

							return clonedQs.get();
						}
					})
				};
				out.append(result);
				resultsByType.packages.append(result);
			}
		}

		for(var StudioDatasource in variables.StudioDatasources){
			if(customFind(arguments.search, StudioDatasource.getName())){
				result = {
					"name": StudioDatasource.getName(),
					"entityType": "datasource",
					"priority": 2,
					"subpriority": 1,
					"metadata": new zero.serializerFast(StudioDatasource, {
						Name:{},
						SelectLink: function(StudioDatasource){
							return qs.clone().setValue("StudioDatasource", StudioDatasource.getName()).get();
						}
					})
				};
				out.append(result);
				resultsByType.datasources.append(result);
			}
		}

		for(var SqlFile in variables.SqlFiles){
			var SqlFileNamedDirectives = SqlFile.getNamedDirectives();
			var matchedSearchQuery = false;
			var subpriority = 1;
			var hasTitle = false;
			var SqlFileName = SqlFile.getName();

			if (customFind(arguments.search, SqlFile.getName())) {
				matchedSearchQuery = true;
				subpriority = 1;
			} else if (
				SqlFileNamedDirectives.keyExists("Title")
				&& !isNull(SqlFileNamedDirectives.Title)
				&& !isNull(SqlFileNamedDirectives.Title.getValueRaw())
				&& !isEmpty(SqlFileNamedDirectives.Title.getValueRaw())
				&& customFind(arguments.search, SqlFileNamedDirectives.Title.getValueRaw())
			) {
				matchedSearchQuery = true;
				subpriority = 2;
				hasTitle = true;
			} else if (
				SqlFileNamedDirectives.keyExists("Description")
				&& !isNull(SqlFileNamedDirectives.Description)
				&& !isNull(SqlFileNamedDirectives.Description.getValueRaw())
				&& !isEmpty(SqlFileNamedDirectives.Description.getValueRaw())
				&& customFind(arguments.search, SqlFileNamedDirectives.Description.getValueRaw())
			) {
				matchedSearchQuery = true;
				subpriority = 3;
			} else if (
				customFind(arguments.search, SqlFile.getContent())
			) {
				matchedSearchQuery = true;
				subpriority = 4;
			} else {
				continue;
			}

			var Package = SqlFile.getPackage();
			var name = SqlFileName;
			if (hasTitle) {
				name = SqlFileNamedDirectives.Title.getValueRaw();
			}

			result = {
				"name": "#name# (#Package.getFriendlyName()#)",
				"entityType": "sqlfile",
				"priority": 3,
				"subpriority": subpriority,
				"metadata": new zero.serializerFast(SqlFile, {
					OpenLink: function(SqlFiles){
						if (!isDefined("request.context.OpenFiles") || isNull(request.context.OpenFiles)) {
							request.context.OpenFiles = "";
						}
						var openFileNames = listToArray(request.context.OpenFiles);
						var openFileKeys = structNew("ordered");
						for(var name in openFileNames){
							openFileKeys[name] = true;
						}
						var keys = duplicate(openFileKeys);
						keys[SqlFiles.getFullName()] = true;
						var clonedQs = qs.clone();
						if (isDefined("request.context.WorkspaceName") && !isNull(request.context.WorkspaceName) && !isEmpty(request.context.WorkspaceName)) {
							clonedQs.setValue("WorkspaceName", request.context.WorkspaceName);
						}
						if (isDefined("request.context.PackageName") && !isNull(request.context.PackageName) && !isEmpty(request.context.PackageName)) {
							clonedQs.setValue("PackageName", request.context.PackageName);
						} else if (!isDefined("request.context.WorkspaceName")) {
							clonedQs.setValue("PackageName", SqlFiles.getPackage().getUniqueId());
						}
						return clonedQs.setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFiles.getFullName()).get();
					},
				})
			};

			out.append(result);
			resultsByType.sqlfiles.append(result);
		}

		// Sort resultsByType.sqlfiles by subpriority
		resultsByType.sqlfiles = resultsByType.sqlfiles.sort(function(a, b){
			return a.subpriority - b.subpriority;
		});

		return {
			results: out,
			resultsByType: resultsByType
		};
	}

	public function newQueryString(){
		return new zero.plugins.zerotable.model.queryStringNew("");
	}

	public function getCurrentQueryString(){
		return new zero.plugins.zerotable.model.queryStringNew(urlDecode(cgi.query_string));
	}

	public function getEditorQueryString(){
		var qs = this.getCurrentQueryString();
		qs.setBasePath("/studio/main");
		return qs;
	}

	private function customFind(needle, haystack) {

		rawNeedle = lcase(reReplace(arguments.needle, "_", " ", "all"));
		rawHaystack = lcase(reReplace(arguments.haystack, "_", " ", "all"));
		// Remove all spaces from needle and haystack
		needle = lcase(reReplace(arguments.needle, "\s", "", "all"));
		haystack = lcase(reReplace(arguments.haystack, "\s", "", "all"));

		// If the needle is empty, return true
		if (len(needle) == 0) {
			return false;
		}

		// If the needle is longer than the haystack, return false
		if (len(needle) > len(haystack)) {
			return false;
		}

		// Check if all the characters on any order on needle are in haystack

		var charactersRegex = "";
		// Loopp through needle characters
		for (var i = 1; i <= len(needle); i++) {
			var char = mid(needle, i, 1);
			charactersRegex &= "^(?=.*#char#)";
		}

		regex = "^#charactersRegex#[#needle#]{#len(needle)#,}$";

		if (reFind(regex, rawHaystack)) {
			return true;
		}

		if (haystack.findNoCase(needle) > 0) {
			return true;
		} else {
			return false;
		}
	}
}