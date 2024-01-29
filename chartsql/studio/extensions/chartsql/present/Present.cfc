/**

*/
component accessors="true" {

	property name="ChartSQLStudio";

	function onInstall(){

	}

	function onUninstall(){

	}

	function onRequestStart(){

	}

	function onRequest(required struct context){

		//When PresentationMode is true then we are going to maximize the renderer panel
		// and hide the editor panel
		if(arguments.context.keyExists("PresentationMode")){
			arguments.context.maximizePanel = "renderer";
		}

	}

	function onResult(
		required struct requestContext,
		required struct result
	){

		if(result.keyExists("method") and result.method == "GET"){

			arguments.result.view_state.presentation_mode = {
				is_active: url.keyExists("PresentationMode"),
				link: this.getChartSQLStudio().getLastPresentationUrl()
			}
			var qs = new zero.plugins.zerotable.model.queryStringNew(urlDecode(cgi.query_string));
			var SliceDateTime = qs.getValue("SliceDatetime") ?: nullvalue();
			arguments.result.view_state.datetime_slicer_links = new studio.model.DatetimeSlicer("1D").getLinks(qs, SliceDateTime);
		}
	}

	function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){

		savecontent variable="menuHtml" {
			```
			<cf_handlebars context="#arguments.result#">
			<li class="nav-item {{#if view_state.presentation_mode.is_active}}active{{/if}}">
				<a class="nav-link" href="{{view_state.presentation_mode.link}}">
					<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Present Charts"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-presentation" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 4l18 0" /><path d="M4 4v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-10" /><path d="M12 16l0 4" /><path d="M9 20l6 0" /><path d="M8 12l3 -3l2 2l3 -3" /></svg>
					</span>
					<span class="nav-link-title">
						Present
					</span>
				</a>
			</li>
			</cf_handlebars>
			```
		}

		savecontent variable="noOpenFile" {
			```
			<cf_handlebars context="#arguments.result#">
				{{#if view_state.presentation_mode.is_active}}
					<div class="empty">
						<div class="empty-img"><img src="/assets/vendor/tabler/static/illustrations/undraw_posting_photo_v65l.svg" height="128" alt="">
						</div>
						<p class="empty-title">Presenting <i>{{data.CurrentPackage.FriendlyName}}</i></p>
						<p class="empty-subtitle text-secondary">
							Sit tight, charts are on the way!
						</p>
						</div>
					{{else}}
						<span class="btn btn-outline-info text-muted" style="pointer-events:none; opacity:.4">
							No file open
						</span>
					{{/if}}
			</cf_handlebars>
			```
		}

		savecontent variable="dateslicerHtml" {
			```
			<cfinclude template="dateslicer_toolbar.cfm">
			```
		}

		savecontent variable="canvasScript" {
			```
			<cfinclude template="canvas_painter.cfm">
			```
		}

		savecontent variable="openFileName" {
			```
			<cf_handlebars context="#arguments.result#">
				{{#if data.CurrentSQLFile.NamedDirectives.Title.ValueRaw}}{{data.CurrentSQLFile.NamedDirectives.Title.ValueRaw}}{{else}}{{data.CurrentSQLFile.Name}}{{/if}}
			</cf_handlebars>
			```
		}

		// savecontent variable="dateslicer" {
		// 	include template="dateslicer_toolbar.cfm";
		// }

		// var htmlOut = this.handlebars(
		// 	template = menu,
		// 	context = context
		// );

		// writeDump(context);
		// abort;
		var editorMenuLink = doc.select("##editorMenuLink")[1];
		editorMenuLink.after(menuHtml);

		if(isDefined('arguments.result.view_state.presentation_mode') and arguments.result.view_state.presentation_mode.is_active){

			editorMenuLink.removeClass('active');
			doc.select("##openFilePath")[1].addClass('d-none');
			doc.select("##headerActions")[1].before(dateslicerHtml);
			doc.select("##headerActions")[1].addClass('d-none');
			doc.select("##renderer-card-header")[1].addClass('d-none');
			doc.select("##new-file-dropdown")[1].addClass('d-none');
			doc.select(".open-file-name").html(openFileName);

			doc.select("##header .page-pretitle").html('Presenting');

			var rendererNoOpenFile = doc.select("##renderer-no-open-file");
			if(rendererNoOpenFile.size() > 0){
				rendererNoOpenFile.html(noOpenFile);
			}
			doc.select("##renderer-card")[1].prepend('<canvas class="js-paint  paint-canvas" style="position:absolute; top:0; left:0; z-index:1; pointer-events:none;"></canvas>')
			doc.select("##header .avatar").html('<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-presentation" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 4l18 0" /><path d="M4 4v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-10" /><path d="M12 16l0 4" /><path d="M9 20l6 0" /><path d="M8 12l3 -3l2 2l3 -3" /></svg>')

			doc.select("##renderer-card")[1].after(canvasScript);
		}
		return doc;
	}

	function onRequestEnd(){

	}

	function onError(){

	}

	function onFailure(){

	}

	public function	getJsoup(){
		var jsoup = application._zero.jsoup = application._zero.jsoup?:createObject("java", "org.jsoup.Jsoup", "formcheck/jsoup-1.13.1.jar");
		return jsoup;
	}

	public string function handlebars(required string template, required struct context){
		var out = "";
		savecontent variable="out" {
			module name="handlebars" context="#arguments.result#" {
				echo(template);
			}
		}
		return out;
	}

}