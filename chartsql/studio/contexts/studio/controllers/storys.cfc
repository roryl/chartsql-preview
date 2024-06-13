component accessors="true" {

	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public struct function list(
	){
		var out = {
			"success":true,
			"data":{
			}
		}
		return out;
	}

	public struct function addSlide(
		required id,
		required string FullName,
		string Title = "New Slide"
	) method="POST"
	{
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Story = ChartSQLStudio.findStoryById(arguments.id).elseThrow("Could not find that Story");

		var Slide = Story.createSlide(
			FullName = arguments.FullName,
			Title = arguments.title
		);

		var out = {
			"success":true,
			"Story":variables.fw.serializeFast(Story, {
				Id:{},
				Name:{}
			})
		}
		return out;
	}

	public struct function create(
		required string PackageId,
		required string Name,
		string FullName,
		string Title = "New Slide"
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Package = ChartSQLStudio.findPackageByUniqueId(arguments.PackageId).elseThrow("Could not find that package");

		// When the FullName is provided, we are going to attempt to load it to ensure that it exists
		// in the ChartSQLStudio, otherwise we will error
		if(arguments.keyExists("FullName")){
			var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not find that SqlFile");
		}

		var Story = Package.createStory(
			Name = arguments.Name
		);

		if(arguments.keyExists("FullName")){
			var Slide = Story.createSlide(
				FullName = FullName,
				Title = arguments.title
			);
		}

		var out = {
			"success":true,
			"Package":variables.fw.serializeFast(Story, {
				Id:{},
				Name:{}
			})
		}
		return out;
	}

	public struct function read( required id ) {
		return {};
	}

	public struct function update(
		required id,
		string Name
	) {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Story = ChartSQLStudio.findStoryById(arguments.id).elseThrow("Could not find that Story");

		if(arguments.keyExists("Name")){ Story.setName(arguments.Name); }

		var out = {
			"success":true,
			"Story":variables.fw.serializeFast(Story, {
				Name:{}
			})
		}
		return out;
	}

	public struct function delete( required id ) {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Story = ChartSQLStudio.findStoryById(arguments.id).elseThrow("Could not find that Story");
		Story.delete();
		var out = {
			"success":true
		}
		return out;
	}

	public struct function deleteSlide(
		required Id,
		required SlideId
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var Story = ChartSQLStudio.findStoryById(arguments.Id).elseThrow("Could not find that Story");
		var Slide = Story.findSlideById(arguments.SlideId).elseThrow("Could not find that Slide");
		Slide.delete();
		var out = {
			"success":true
		}
		return out;

	}

	/**
	 * Function to override the request scope variables for this controller
	 * @param  {struct} rc The request context, the URL and FORM variables passed into the app
	 * @return {struct}    The update RC scope which will be used to find variables for the controllers
	 */
	public struct function request( required struct rc, required struct headers ){
		return rc;
	}

	/**
	 * A function to override all controller function responses, for example to decorate with extra information on every call
	 * @param  {struct} required struct        controllerResult Will receive the result of the controller method (list, create, read etc)
	 * @return {struct}          Should return the updated controller result
	 */
	public struct function result( required struct controllerResult ){

		controllerResult = arguments.controllerResult;
		controllerResult.view_state.current_page = variables.fw.getItem();
		return controllerResult;
	}

}
