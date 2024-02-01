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
				IconClass: "ti ti-border-all",
				Filter: ""
			},
			{
				Name:"Area Charts",
				IconClass: "ti ti-chart-area",
				Filter: "area"
			},
			{
				Name:"Bar Charts",
				IconClass: "ti ti-chart-bar",
				Filter: "bar"
			},
			{
				Name:"Column Charts",
				IconClass: "ti ti-chart-arrows-vertical",
				Filter: "column"
			},
			{
				Name:"Combo Charts",
				IconClass: "ti ti-stack-back",
				Filter: "combo"
			},
			{
				Name:"Heatmap Charts",
				IconClass: "ti ti-chart-grid-dots-filled",
				Filter: "heatmap"
			},
			{
				Name:"Line Charts",
				IconClass: "ti ti-chart-line",
				Filter: "line"
			},
			{
				Name:"Pie Charts",
				IconClass: "ti ti-chart-pie",
				Filter: "pie"
			},
			{
				Name:"Scatter Charts",
				IconClass: "ti ti-chart-scatter",
				Filter: "scatter"
			}
		]

		// /studio/main/?PackageName=websites.chartsql.editor.extensions.chartsql.examples.sql&StudioDatasource=Examples&ActiveFile=websites.chartsql.editor.extensions.chartsql.examples.sql.column.column_sales_by_month.sql&RenderOnLoad=true&=

		var PackageFullName = "websites.chartsql.editor.extensions.chartsql.examples.sql";
		var StudioDatasourceName = "Examples";
		var ExamplesPackageOptional = variables.ChartSQLStudio.findPackageByFriendlyName("Examples");

		if(ExamplesPackageOptional.exists()){
			var Package = ExamplesPackageOptional.get();
			PackageFullName = Package.getFullName();
			
			var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
			if(StudioDatasourceOptional.exists()){
				var StudioDatasource = StudioDatasourceOptional.get();
				StudioDatasourceName = StudioDatasource.getName();
			}
		}

		for(var example in examples){
			var Link = variables.ChartSQLStudio.getEditorQueryString().clone()
				.delete("OpenFiles")
				.delete("ActiveFile")
				.delete("EditorPanelView")
				.setValue("PackageName", PackageFullName)
				.setValue("StudioDatasource", StudioDatasourceName)

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