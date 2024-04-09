/**
 * Implements the instance of an InfoPanelView that shows up as a tab in the ChartSQL Studio
 * editor info area. Extensions can use this class to add additional InfoPanelViews.
*/
component accessors="true" {

	property name="ChartSQLStudio" type="ChartSQLStudio";
	property name="Name";
	property name="Link" setter="false";
	property name="IconClass";
	property name="Content";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string Name,
		required string IconClass,
		string content = ""
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Name = arguments.Name;
		variables.IconClass = arguments.IconClass;
		variables.Content = arguments.content;
		variables.ChartSQLStudio.addFileBrowserView(this);
	}

	public function getLink(){
		var qs = variables.ChartSQLStudio.getEditorQueryString();
		qs.setValue("FileBrowserView", variables.Name);
		return qs.get();
	}

}