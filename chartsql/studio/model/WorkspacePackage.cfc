/**
 * Represents a join relationship between a Package and a Workspace
*/
component accessors="true" {
	property name="ChartSQLStudio" hint="A ChartSQLStudio instance";
	property name="Package" hint="The Package";
	property name="Workspace" hint="The Workspace that the Package belongs to";
    property name="DefaultStudioDatasource";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required Package Package,
        required Workspace Workspace,
        StudioDatasource DefaultStudioDatasource
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Package = arguments.Package;
		variables.Workspace = arguments.Workspace;
        if (isDefined('arguments.DefaultStudioDatasource')) {
            variables.DefaultStudioDatasource = arguments.DefaultStudioDatasource;
        }
		return this;
	}

    public function getPackage() {
        return variables.Package;
    }
    
    public function getWorkspace() {
        return variables.Workspace;
    }

    public function setDefaultStudioDatasource(StudioDatasource StudioDatasource){
		variables.DefaultStudioDatasource = arguments.StudioDatasource;
		//Sets the value into the config
		this.saveConfig();
	}

	public optional function getDefaultStudioDatasource(){
		if(variables.keyExists("DefaultStudioDatasource")){
			return new optional(variables.DefaultStudioDatasource);
		} else {
			return new optional(nullValue());
		}
	}

	public void function saveConfig(){
		variables.ChartSQLStudio.saveConfig();
	}
}