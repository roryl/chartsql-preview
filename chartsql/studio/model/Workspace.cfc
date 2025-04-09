/**
 * A collection of packages/folders
*/
component accessors="true" {

	processingdirective preservecase="true";

	property name="WorkspacePackages";
	property name="UniqueId";
	property name="ChartSQLStudio";
	property name="FriendlyName";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string FriendlyName
	){
		variables.WorkspacePackages = [];
		variables.FriendlyName = arguments.FriendlyName;
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.UniqueId = variables.ChartSQLStudio.generateUniqueIdForWorkspace(arguments.FriendlyName)

		variables.ChartSQLStudio.addWorkspace(this);
		return this;
	}

	public function addPackage(required Package Package){
		if(!this.findPackageByUniqueId(Package.getUniqueId()).exists()){
			WorkspacePackage = new WorkspacePackage(
				Package = Package,
				ChartSQLStudio = variables.ChartSQLStudio,
				Workspace = this
			);
			variables.WorkspacePackages.append(WorkspacePackage);
		} else {
			WorkspacePackage = this.findWorkspacePackageByUniqueId(Package.getUniqueId()).get();
		}
		variables.ChartSQLStudio.saveConfig();
		return WorkspacePackage;
	}

	public function removeAllPackages() {
		variables.WorkspacePackages = [];
		variables.ChartSQLStudio.saveConfig();
	}

	public optional function findPackageByUniqueId(
		required string UniqueId
	) {
		for (var WorkspacePackage in variables.WorkspacePackages){
			var Package = WorkspacePackage.getPackage();
			if (Package.getUniqueId() == arguments.UniqueId){
				return new optional(Package);
			}
		}
		return new optional(nullValue());
	}
	
	public optional function findWorkspacePackageByUniqueId(
		required string UniqueId
	) {
		for (var WorkspacePackage in variables.WorkspacePackages){
			var Package = WorkspacePackage.getPackage();
			if (Package.getUniqueId() == arguments.UniqueId){
				return new optional(WorkspacePackage);
			}
		}
		return new optional(nullValue());
	}

	/**
	 * Removes the package from the collection by creating a new collection
	 * of stories without the one to be removed
	 */
	public function removePackage(required Package Package){
		var newWorkspacePackages = [];
		for(var WorkspacePackage in variables.WorkspacePackages){
			if(WorkspacePackage.getPackage().getUniqueId() != arguments.Package.getUniqueId()){
				arrayAppend(newWorkspacePackages, WorkspacePackage);
			}
		}

		variables.WorkspacePackages = newWorkspacePackages;
		variables.ChartSQLStudio.saveConfig();
	}
	
	public function setUniqueId(required string UniqueId){
		variables.UniqueID = arguments.UniqueId;
	}

	public function setFriendlyName(required string FriendlyName){
		variables.FriendlyName = arguments.FriendlyName;
		variables.UniqueId = variables.ChartSQLStudio.generateUniqueIdForWorkspace(arguments.FriendlyName);
		variables.ChartSQLStudio.saveConfig();
	}

	function loadPackagesSqlFiles (){
		for (var WorkspacePackage in variables.WorkspacePackages){
			WorkspacePackage.getPackage().loadSqlFiles();
		}
	}

	public function saveConfig(){
        // Implement this
	}
}