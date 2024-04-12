/**
 * Implements Publishing features within the UI of ChartSQL Studio
*/
component accessors="true" {

	property name="ChartSQLStudio";

	public function Publish(
	){

	}

	function onRequest(required struct context){

	}

	function onResult(
		required struct requestContext,
		required struct result
	){

		var InfoPanelView = this.getInfoPanelView();

		var PublishingRequests = variables.ChartSQLStudio.getPublishingRequests();

		var context = {};
		context.data.PublishingRequests = new zero.serializerFast(PublishingRequests, {
			Uri:{}
		})

		savecontent variable="html" {
			```
			<cfinclude template="publishing_requests.cfm.hbs">
			```
		}
		InfoPanelView.setContent(html);

	}

	function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){

	}

	function getInfoPanelView(){

		var InfoPanelViewOptional = variables.ChartSQLStudio.findInfoPanelViewByName("chartsql.publish");
		if(InfoPanelViewOptional.exists()){
			var InfoPanelView = InfoPanelViewOptional.get();
		} else {
			var InfoPanelView = new studio.model.InfoPanelView(
				ChartSQLStudio = variables.ChartSQLStudio,
				Name = "chartsql.publish",
				Title = "Publishing",
				IconClass = "ti ti-package-export"
			);
		}
		return InfoPanelView;
	}

}