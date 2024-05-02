/**
 * Implements the the component interface for browser panel views (file browser, datasource browser, etc).
 * Extensions can add additional views to the browser panel by adding more components
*/
component accessors="true" {

	property name="ChartSQLStudio" type="ChartSQLStudio";
	property name="Name";
	property name="Tooltip";
	property name="Link" setter="false";
	property name="IconClass";
	property name="Content";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required String Name,
		required String IconClass,
		String Tooltip = '',
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Name = arguments.Name;
		variables.IconClass = arguments.IconClass;
		variables.Tooltip = arguments.Tooltip;
		variables.Content = "Foo";
		variables.ChartSQLStudio.addFileBrowserView(this);
	}

	public function getLink(){
		var qs = variables.ChartSQLStudio.getEditorQueryString();
		qs.setValue("FileBrowserView", variables.Name);
		return qs.get();
	}

}