/**
 * Implements the instance of an InfoPanelView that shows up as a tab in the ChartSQL Studio
 * editor info area. Extensions can use this class to add additional InfoPanelViews.
*/
component accessors="true" {

	property name="ChartSQLStudio" type="ChartSQLStudio";
	property name="Name" type="string" hint="The unique name of the info panel view";
	property name="Link" setter="false" type="string" hint="The link to the info panel view. Is generated and not set by the user.";
	property name="IconClass" type="string" hint="The icon class to use for the tab";
	property name="Title" type="string" hint="The title of the info panel shown in the tab";
	property name="Content" type="string" hint="The HTML content to display in the info panel";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string Name,
		required string IconClass,
		required string Title,
		string content = ""
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Name = arguments.Name;
		variables.Title = arguments.Title;
		variables.IconClass = arguments.IconClass;
		variables.Content = arguments.content;
		variables.ChartSQLStudio.addInfoPanelView(this);
	}

	public function getLink(){
		var qs = variables.ChartSQLStudio.getEditorQueryString();
		qs.setValue("InfoPanelView", variables.Name);
		return qs.get();
	}

}