/**
 * An instance of the Studio Application
*/
component accessors="true" {
	processingdirective preservecase="true";
	property name="Packages";
	property name="SqlFiles";
	property name="DashPublishers";
	property name="PublishingHost" type="string";
	property name="ConfigPath";
	property name="Config";
	property name="LastEditorUrl";
	property name="LastPresentationUrl";
	property name="StudioDatasources";
	property name="AvailableDatasourceTypes";
	property name="Extensions";
	property name="Storys";
	property name="CurrentQueryString" setter="false";
	property name="FileBrowserViews";
	property name="MenuItems" setter="false";
	property name="MascotBinary" setter="false" type="binary";
	property name="LogoBinary" setter="false" type="binary";
	property name="StudioModelHash" type="string" hint="Stored in Application to detect when source code has changed and needs to be reloaded";


	public function init(
		string ConfigPath
	){
		variables.Packages = [];
		variables.SqlFiles = [];
		variables.DashPublishers = [];
		variables.StudioDatasources = [];
		variables.Storys = [];
		variables.Extensions = [];
		variables.FileBrowserViews = [];
		variables.MenuItems = [];
		variables.StudioModelHash = "";

		variables.LastEditorUrl = "/studio/main";
		variables.LastPresentationUrl = "/studio/main?PresentationMode=true&RenderPanelView=chart";

		if(arguments.keyExists("ConfigPath")){
			variables.ConfigPath = arguments.ConfigPath;
			if(fileExists(variables.ConfigPath)){
				this.loadConfig();
			} else {
				saveConfig(); //Creates the empty config file
			}
		}

		//Setup default FileBrowserViews
		var FileBrowserViews = [
			{name: "files", iconClass: "ti ti-file-type-sql"},
			{name: "schema", iconClass: "ti ti-database-search"},
			// {name: "stories", iconClass: "ti ti-slideshow"}
		]
		for(var FileBrowserView in FileBrowserViews){
			var FileBrowserView = new FileBrowserView(
				ChartSQLStudio = this,
				Name = FileBrowserView.name,
				IconClass = FileBrowserView.iconClass
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

	public function addDashPublisher(DashPublisher){
		variables.DashPublishers.append(DashPublisher);
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
			throw("A datasource with the name '#arguments.StudioDatasource.getName()#' already exists");
		}

		variables.StudioDatasources.append(StudioDatasource);
		this.saveConfig();
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

	public function createPackageFromFile(path){
		var Package = Package::fromFile(path, this);
		this.saveConfig();
		return Package;
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
		for(var Package in variables.Packages){
			if(Package.getFullName() != arguments.Package.getFullName()){
				arrayAppend(newPackages, Package);
			}
		}
		variables.Packages = newPackages;
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

	public optional function findPackageByFullName(
		required string name
	) {
		for (var Package in variables.Packages){
			if (Package.getFullName() == name){
				return new optional(Package);
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

	public function getBasePublishingUrl(
		required string key
	){
		return "#this.getPublishingHost()#/Publisher/#arguments.key#/main";
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
			var image = fileReadBinary(expandPath("/com/chartsql/studio/wwwroot/assets/img/mascot.fw.png"));
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
		if(!findPackageByFullName(Package.getFullName()).exists()){
			variables.Packages.append(Package);
		}
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
					FullName:{},
					Path:{}
				},
				StudioDatasources:{
					Name:{},
					Type:{},
					Config: function(StudioDatasource){
						return StudioDatasource.getConfig();
					}
				}
			})
			var ConfigFile = ConfigFile::fromStruct(out);
			ConfigFile.setPath(variables.ConfigPath);
			ConfigFile.write();
		}
	}

	public function setupDefaultMenuItems(){

		var MenuItem = new MenuItem(
			ChartSQLStudio = this,
			Name = "Settings",
			IconClass = "ti ti-settings",
			Link = "/studio/settings",
			Tooltip = "Editor Settings",
			Location = "bottom",
			OpenNewTab = false
		);

		var MenuItem = new MenuItem(
			ChartSQLStudio = this,
			Name = "Docs",
			IconClass = "ti ti-book",
			Link = "https://itr8studios.gitbook.io/chartsql/QY9tx3OTrQdien8dGApA/basics/intro",
			Tooltip = "Open Docs",
			Location = "top",
			OpenNewTab = true
		);
	}

	public function loadConfig(){
		variables.Config = deserializeJson(fileRead(variables.ConfigPath));

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
				var NewPackage = new Package(
					path = Package.Path,
					ChartSQLStudio = this
				)
			}
		}

	}

	public function getCurrentQueryString(){
		return new zero.plugins.zerotable.model.queryStringNew(urlDecode(cgi.query_string));
	}

	public function getEditorQueryString(){
		var qs = this.getCurrentQueryString();
		qs.setBasePath("/studio/main");
		return qs;
	}
}