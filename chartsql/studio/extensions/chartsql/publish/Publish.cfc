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
			Uri:{},
			RequestType:{},
			PublishingResult:{
				IsSuccess:{},
				ResultMessage:{},
				ResultType:{},
				PublishingRequest:{
					SqlFile:{}
				}
			}
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

		if(isDefined("result.data.CurrentPackage.UniqueId")){

			var Package = variables.ChartSQLStudio.findPackageByUniqueId(result.data.CurrentPackage.UniqueId).elseThrow("Could not load that package");
			var context = arguments.result
			context.data.PublisherKey = Package.getPublisherKey();
			var qs = variables.ChartSQLStudio.newQueryString();
			qs.setBasePath("/studio/settings/packages");
			qs.setValue("EditPackage", Package.getUniqueId());
			context.view_state.configurePublisherLink = qs.get();
			// writeDump(context.view_state.configurePublisherLink);
			// abort;
			savecontent variable="publish_button" {
				```
				<cfinclude template="publish_button.cfm.hbs">
				```
			}
			// abort;
			var renderCardTabs = doc.select("##renderer-card-tabs");
			if (len(renderCardTabs) >= 1) {
				renderCardTabs[1].append(publish_button);
			}

		}

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

	remote function PublishChart(
		required string SqlFile
	) {

		var ChartSQLStudio = variables.ChartSQLStudio;
		var SqlFile = ChartSQLStudio.findSqlFileByFullName(SqlFile).elseThrow("Could not find that SQL file");
		var Package = SqlFile.getPackage();
		var PackagePublisher = Package.getPackagePublisher();
		var PublishingResult = PackagePublisher.publishOrUpdateDashChart(SqlFile);

		var out = {
			"PublishingResult": new zero.serializerFast(PublishingResult, {
				IsSuccess:{},
				ResultType:{},
				PublishingRequest:{
					RequestType:{}
				},
			})
		}

		return out;

	}

	remote function PublishAllCharts(
		required string PackageFullName
	) {

		var ChartSQLStudio = variables.ChartSQLStudio;
		var Package = ChartSQLStudio.findPackageByUniqueId(PackageFullName).elseThrow("Could not find that package");
		var SqlFiles = Package.getSqlFiles();
		var PackagePublisher = Package.getPackagePublisher();
		var PublishingResults = PackagePublisher.publishAllCharts(SqlFiles);

		var out = {
			"message": "Published all charts. Check publishing into panel for details",
		}

		return out;

	}

	/**
	 * Trashes all the dashids at the remote package that do not exist within the local package
	 *
	 * @PackageFullName
	 */
	remote function MarkMissingChartsAsTrashed(
		required string PackageFullName
	){
		var ChartSQLStudio = variables.ChartSQLStudio;
		var Package = ChartSQLStudio.findPackageByUniqueId(PackageFullName).elseThrow("Could not find that package");
		var PackagePublisher = Package.getPackagePublisher();
		var dashIds = Package.getAllDashIds();
		var result = PackagePublisher.markMissingChartsAsTrashed(dashIds);
		return result;
	}

}