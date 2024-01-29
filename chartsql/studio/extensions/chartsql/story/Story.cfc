/**

*/
component accessors="true" {

	property name="ChartSQLStudio";

	public function onRequest(required struct context){
		var context = arguments.context;
		var FileBrowserViewOptional = variables.ChartSQLStudio.findFileBrowserViewByName("stories");
		if(FileBrowserViewOptional.exists()){
			var FileBrowserView = FileBrowserViewOptional.get();
		} else {
			var FileBrowserView = new studio.model.FileBrowserView(
				ChartSQLStudio = variables.ChartSQLStudio,
				Name = "stories",
				IconClass = "ti ti-slideshow"
			);
		}

		if(context.keyExists("FileBrowserView") and context.FileBrowserView == "stories"){
			if(context.keyExists("PackageName")){
				var Package = ChartSQLStudio.findPackageByFullName(context.PackageName).elseThrow("Package not found");
			}

			arguments.context.data.Storys = new zero.serializerFast(Package.getStorys().reverse(), {
				Id:{},
				Name:{},
				Slides:{
					Id:{},
					FullName:{},
					Title:{},
					Order:{},
					Story:{
						Id:{},
						PlayLink: function(Story){
							var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
							qs.setValue('PlayStory', arguments.Story.getName())
							var firstSlide = Story.getSlides().first();
							qs.setValue('ActiveFile', firstSlide.getFullName())
							qs.setValue('PresentationMode', true);
							return qs.get();
						}
					},
					Link: function(Slide){
						var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
						qs.setValue('ActiveFile', arguments.Slide.getFullName())
						qs.setValue('RenderOnLoad', true);
						// writeDump(qs.get());
						// writeDump(qs.getFields());
						// abort;
						// var out = encodeForURL(qs.get());
						return qs.get();
					},
					LinkParams: function(Slide){
						var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
						qs.setValue('ActiveFile', arguments.Slide.getFullName())
						qs.setValue('RenderOnLoad', true);
						return qs.getFields();
					},
				}
			})

			arguments.context.view_state.current_url = variables.ChartSQLStudio.getEditorQueryString().get();

			// writeDump(context);
			// abort;

			savecontent variable="html" {
				```
				<cfinclude template="storylist.cfm.hbs">
				```
			}
			FileBrowserView.setContent(html);
		}
	}

	public function onResult(
		required struct requestContext,
		required struct result
	){

		if(result.method == "GET" and result.keyExists("section") and result.section == "main"){
			var PackageFullName = result.data.CurrentPackage.FullName;
			var Package = ChartSQLStudio.findPackageByFullName(PackageFullName).elseThrow("Package not found");

			var LatestStoryOptional = Package.getLatestStory();
			if(LatestStoryOptional.exists()){
				var LatestStory = LatestStoryOptional.get();
				result.data.LatestStory = new zero.serializerFast(LatestStory, {
					Id:{},
					Name:{},
					Slides:{
						FullName:{},
						Title:{},
						Order:{}
					}
				})
			}
		}
	}

	public function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){

		if(result.keyExists("section") and result.section == "main"){
			savecontent variable="addstory" {
				// <li class="nav-item">
				// 	<a class="nav-link link-with-form" role="link" tabindex="0">
				// 		<i class="ti ti-slideshow" style="font-size:1.2rem; font-weight:100; margin-top:1px;"></i>
				// 	</a>
				// </li>
				```
				<cfinclude template="addstory.cfm.hbs">
				```
			}


			if(requestContext.keyExists("PlayStory")){

				var Package = ChartSQLStudio.findPackageByFullName(requestContext.PackageName).elseThrow("Package not found");
				var Story = Package.findStoryByName(requestContext.PlayStory).elseThrow("Story not found");
				var Slide = Story.findSlideByFullName(requestContext.ActiveFile).elseThrow("Slide not found");

				result.data.Story = new zero.serializerFast(Story, {
					Id:{},
					Name:{},
					Slides:{
						Id:{},
						Title:{},
						FullName:{},
						Link: function(Story){
							var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
							qs.setValue('ActiveFile', arguments.Story.getFullName())
							qs.setValue('RenderOnLoad', true);
							return qs.get();
						},
					},
					NextSlideLink: function(Story){
						if(Slide.getNextSlide().exists()){
							var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
							qs.setValue('ActiveFile', Slide.getNextSlide().get().getFullName())
							return qs.get();
						} else {
							return "";
						}
					},
					PreviousSlideLink: function(Story){
						if(Slide.getPreviousSlide().exists()){
							var qs = variables.ChartSQLStudio.getEditorQueryString().clone();
							qs.setValue('ActiveFile', Slide.getPreviousSlide().get().getFullName())
							return qs.get();
						} else {
							return "";
						}
					}
				})

				result.view_state.exit_story_link = variables.ChartSQLStudio.getEditorQueryString().clone().delete('PlayStory').get();
				savecontent variable="mainMenu" {
					```
					<cfinclude template="main_menu.cfm.hbs">
					```
				}

				savecontent variable="slideSelector" {
					```
					<cfinclude template="slide_selector.cfm.hbs">
					```
				}

				doc.select('body')[1].addClass('storyMode');
				doc.select('##main-menu-nav-items')[1].html(mainMenu);
				doc.select('##renderingContainer')[1].prepend(slideSelector);
			}

			doc.select("##renderer-card-tabs")[1].append(addstory);

		}

	}

}