/**
 * Loads the examples and displays them in the menu for the user to select
*/
component accessors="true" {

	property name="ChartSQLStudio";

	function onRequest(required struct context){

		var ParentMenuItemOptional = variables.ChartSQLStudio.findMenuItemByName("Examples");

		if(ParentMenuItemOptional.exists()){
			var ParentMenuItem = ParentMenuItemOptional.get();
		} else {
			ParentMenuItem = new studio.model.MenuItem(
				ChartSQLStudio = variables.ChartSQLStudio,
				Name = "Examples",
				IconClass = "ti ti-chart-infographic",
				Tooltip = "Example Charts"
			)
		}

		var examples = [
			{
				Name:"All Charts",
				IconClass: "ti ti-chart-line",
				Filter: ""
			},
			{
				Name:"Column Charts",
				IconClass: "ti ti-chart-arrows-vertical",
				Filter: "column"
			}
		]

		// /studio/main/?PackageName=websites.chartsql.editor.extensions.chartsql.examples.sql&StudioDatasource=Examples&ActiveFile=websites.chartsql.editor.extensions.chartsql.examples.sql.column.column_sales_by_month.sql&RenderOnLoad=true&=

		for(var example in examples){
			var Link = ChartSQLStudio.getEditorQueryString().clone()
				.setValue("PackageName", "websites.chartsql.editor.extensions.chartsql.examples.sql")
				.setValue("StudioDatasource", "Examples")

			if(len(example.Filter) > 0){
				Link.setValue("Filter", example.Filter)
			}

			var ChildMenuItem = new studio.model.MenuItem(
				Parent = ParentMenuItem,
				Name = example.Name,
				IconClass = example.IconClass,
				Link: Link.get()
			)
		}

	}

	function onResult(
		required struct result
	){

	}

	function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){

	}

}