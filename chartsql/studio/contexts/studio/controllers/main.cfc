component accessors="true" {
	processingdirective preservecase="true";
	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	/**
	 * Main entry point for the ChartSQLStudio application. This sets up the
	 * primary view that is used to edit and preview the sql files in the editor
	 *
	 * @PackageName The package to open
	 * @OpenFiles The list of files curently open
	 * @ActiveFile The currently active file
	 * @maximizePanel Whether to maximize the editor or renderer panel
	 * @InfoPanelView Which info panel to show
	 * @RenderPanelView Which render panel to show
	 * @EditorPanelView Which editor panel to show
	 * @FileBrowserView Which file browser panel to show
	 * @Filter A filter to apply to the file list
	 * @SchemaFilter A filter to apply to the schema list
	 * @RenderOnLoad Whether to run a preview when the file is opened
	 * @PresentationMode Whether to show the editor or the presentation mode
	 * @SliceDatetime A datetime to slice the data on
	 * @StudioDatasource The datasource to use
	 */
	public struct function list(
		string PackageName,
		string WorkspaceName,
		string OpenFiles,
		string ActiveFile,
		string maximizePanel,
		string InfoPanelView = "resultset",
		string RenderPanelView = "chart",
		string EditorPanelView = "sql",
		string FileBrowserView = "files",
		string Filter = "",
		string SchemaFilter = "",
		string ChangingFileName = "",
		boolean RenderOnLoad = false,
		boolean PresentationMode = false,
		boolean ChangeActiveFileName = false,
		string SliceDatetime,
		string StudioDatasource
	){
		// -----------------------
		// MAIN STUDIO EDITOR VIEW
		// -----------------------
		// This is the main view that is used to edit and preview the sql files
		// in the ChartSQLStudio. It is the main entry point for the application
		//
		// It is broadly split up into the following area:
		//	1. SETUP
		//	2. CurrentSqlFile: The currently active sql file
		//	3. ChartSQLStudio: The ChartSQLStudio and all files
		//	4. CurrentPackage: The currently active package
		//	5. EditorSession: The current editor session
		//	6. CurrentStudioDatasource: The currently selected datasource
		//	7. View State: The state of the view, which panels are open, etc

		// -----------------------
		// 1. SETUP AREA
		// -----------------------
		// Create a reference to arguments so that it can be used within the
		// closures in the serializeFast method below
		var args = arguments;

		var startTick = getTickCount();

		var EditorSession = variables.fw.getEditorSession();

		// Setup our empty output struct
		var out = {
			"success":true,
			"data":{}
		}

		// try {
			// Read our open files and put them into an array, create
			// an ordered struct and save them so that we can use them by
			// key but keep them in the same order as they were opened
			var openFileNames = listToArray(arguments.OpenFiles);
			var openFileKeys = structNew("ordered");
			for(var name in openFileNames){
				openFileKeys[name] = true;
			}

			var ChartSQLStudio = variables.fw.getChartSQLStudio();

			// We are going to dynamically create a query string object for the users state
			var qs = ChartSQLStudio.getEditorQueryString();

			qs.delete("ChangingFileName");
			qs.delete("ChangeActiveFileName");

			// We delete it because we only want links that open files to set this value, rather than all links
			// within the application so that it does not infinitely loop
			qs.delete("RenderOnLoad");

			// Set default qs values that should always exist
			qs.setValue("InfoPanelView", InfoPanelView);

			out.data.HasOpenedPackageOrWorkspace = false;

			// Select our current StudioDatasource that we are working with
			if(arguments.keyExists("StudioDatasource")){
				var CurrentStudioDatasource = ChartSQLStudio.findStudioDatasourceByName(arguments.StudioDatasource).elseThrow("Could not locate that StudioDatasource: #arguments.StudioDatasource#");
				//Set the current Datasource so that saveFile() can use it
				EditorSession.setCurrentStudioDatasource(CurrentStudioDatasource);
			} else {
				var CurrentStudioDatasource = EditorSession.getCurrentStudioDatasource();
			}

			if(arguments.keyExists("PackageName")){
				var CurrentPackageOptional = ChartSQLStudio.findPackageByUniqueId(arguments.PackageName);
				if(CurrentPackageOptional.exists()){
					var CurrentPackage = CurrentPackageOptional.get();
					CurrentPackage.loadSqlFiles();
					out.data.HasOpenedPackage = true;
					out.data.HasOpenedPackageOrWorkspace = true;
				} else {
					variables.fw.doLocation("/studio/main");
				}
			} else if (!arguments.keyExists("PackageName") and !arguments.keyExists("WorkspaceName")) {
				if (isDefined("server.ShouldLoadDefaultPackage") && server.ShouldLoadDefaultPackage == true) {
					// Redirect to the url with the default package if there is a default package and the
					// app is starting for the first time
					var DefaultPackage = ChartSQLStudio.getDefaultPackage();
					if (!isNull(DefaultPackage)) {
						server.ShouldLoadDefaultPackage = false;
						var qs = ChartSQLStudio.getEditorQueryString();
						var DefaultPackageName = DefaultPackage.getUniqueId();
						qs.setValue("PackageName", DefaultPackageName);

						var StudioDatasourceOptional = DefaultPackage.getDefaultStudioDatasource();
						if(StudioDatasourceOptional.exists()){
							var StudioDatasource = StudioDatasourceOptional.get();
							qs.setValue("StudioDatasource", StudioDatasource.getName());
						}

						server.ShouldLoadDefaultPackage = false;
						variables.fw.doLocation(qs.get());
						return out;
					}
				}

				out.data.HasOpenedPackage = false;
			}

			out.data.HasOpenedWorkspace = false;
			if(arguments.keyExists("WorkspaceName")){
				var CurrentWorkspaceOptional = ChartSQLStudio.findWorkspaceByUniqueId(arguments.WorkspaceName);
				if(CurrentWorkspaceOptional.exists()){
					var CurrentWorkspace = CurrentWorkspaceOptional.get();
					CurrentWorkspace.loadPackagesSqlFiles();
					out.data.HasOpenedWorkspace = true;
					out.data.HasOpenedPackageOrWorkspace = true;
				} else {
					variables.fw.doLocation("/studio/main");
				}
			}

			var endTick = getTickCount();
			request.timerData.initialize = endTick - startTick;

			// --------------------------------------
			// 2. CurrentSqlFile: The currently active sql file
			// --------------------------------------
			var lastRenderOnLoadCalled = false;
			var startTick = getTickCount();


			try {
				if (isDefined('arguments.ActiveFile') && !isNull(arguments.ActiveFile)) {
					var SqlFileOptional = ChartSQLStudio.findSqlFileByFullName(arguments.ActiveFile);
					if (SqlFileOptional.exists()) {
						var SqlFile = SqlFileOptional.get();
					} else {
						arguments.delete("ActiveFile");
					}
				}
			}catch(any e){
				writeDump(e);
				abort;
				// later on we will handle this more correctly
				writeDump(ChartSQLStudio);
				abort;
			}

			if(isDefined('SqlFile') && !isNull(SqlFile)){
				var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
					CurrentStudioDatasource.getName()
				);
				var ShouldRefreshExecution = false;

				if (LastExecutionRequestOptional.exists()) {
					var LastExecutionRequest = LastExecutionRequestOptional.get();
					if (LastExecutionRequest.getIsRunning()) {
						ShouldRefreshExecution = true;
					}
				} else {
					ShouldRefreshExecution = true;
				}
				out.data.ShouldRefreshExecution = ShouldRefreshExecution;

				// If RednerOnLoad was passed in when opening the file, we are going to
				// run an execution unless we alreayd have one. This is so that we can
				// render the preview of the report without having to call the render
				// the 'RenderOnLoad' variable is only passed in the open links and is
				// deleted from the other links so that we don't run an execution in an
				// infinite loop.

				if(arguments.RenderOnLoad){
					var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
						CurrentStudioDatasource.getName()
					);
					if(!LastExecutionRequestOptional.exists()){

						// Set this to true so that we can force LastExecutionRequest.getIsRunning()
						// to true when we have called the render on load. This is to ensure that
						// the UI refreshes at least once so that the user knows that the preview
						// is being loaded
						var lastRenderOnLoadCalled = true;

						// writeDump("We are going to render this file"
						var EditorSession = variables.fw.getEditorSession();
						var ExecutionRequest = EditorSession.createExecutionRequest(
							SqlFile = SqlFile,
							StudioDatasource = CurrentStudioDatasource
						);

						// Sleep for 50ms to give fast running queries a chance to finish
						// before we render the preview. If it isn't completed, then the
						// page will be automatically refreshed.

						// 2023-12-24: This is kind of a hack, but it works for now. The disconnect of the
						// execution from the rendering that happens next is a bit of a problem,
						// the rendering should be fired after the execution is complete, but
						// we don't have a way to do that right now.
						// sleep(50);
					}
				}

				var startTick = getTickCount();
				var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
					CurrentStudioDatasource.getName()
				);
				var lastRenderOnLoadComplete = false;

				if(!SqlFile.getHasDirectiveErrors() and LastExecutionRequestOptional.exists()){
					var LastExecutionRequest = LastExecutionRequestOptional.get();
					if(LastExecutionRequest.getIsDone() and !LastExecutionRequest.getIsCancelled()){
						if(LastExecutionRequest.getIsSuccess()){
							// var LastRenderOptional = SqlFile.getLastRendering();
							// if(!LastRenderOptional.exists()){
							var data = LastExecutionRequest.getData();

							if(arguments.keyExists("SliceDatetime")){
								var Slicer = new studio.model.Slicers(
									Datetime = new studio.model.DatetimeSlicer(arguments.SliceDatetime)
								);
								var data = Slicer.slice(data, SqlFile.getParsedDirectives());
							}

							var Rendering = new studio.model.Rendering(SqlFile, LastExecutionRequest);
							Rendering.render(data, LastExecutionRequest);

							// Set this to true so that we can force LastExecutionRequest.getIsRunning()
							// to false when we have called the render on load, since we know that the
							// rendering is complete
							var lastRenderOnLoadComplete = true;

						}
					}
				}
				var endTick = getTickCount();
				request.timerData.Rendering = endTick - startTick;

				//Empty string for our data preview if it gets generated
				var data = "";

				// Create a tempalte for the Directive output which will be used
				// multiple times for all of the NamedDirectives that we want to serialize
				var directiveStruct = {
					Name:{},
					CoreName:{},
					ValueRaw:{},
					PrettyPrint:{},
					IsUserNamed:{},
					UserName:{},
					IsValid:{},
					CleanedName: {},
					HasErrors:{},
					Parsed:{},
					HasValue:{},
					IsSupported:{},
					IsCommentedOut:{},
					Errors:{
						directive:{},
						errorClass:{},
						message:{},
						title:{},
						type:{}
					},
					SelectListSelectedValue:{},
					AvailableFields: function(Directive){
						var out = [];

						var multiFieldDirectives = ["series", "stacks", "groups", "baselines"];

						if(lcase(Directive.getName()) eq "baseline-types"){
							out = ["average", "max", "min", "median"];
							return out;
						}

						if(lcase(Directive.getName()) eq "baselines"){
							// Get the 'series' directive so that we can get the available fields
							var Directives = SqlFile.getDirectives();
							var index = Directives.find(function(Directive){
								return Directive.getName() == "series";
							});


							if (index == 0){
								return [];
							}

							var SeriesDirective = Directives[index];
							var DirectiveParsedValues = Directives[index].getParsed();

							if (isNull(DirectiveParsedValues)) {
								return [];
							}

							return DirectiveParsedValues;
						}

						if(arrayContainsNoCase(multiFieldDirectives, Directive.getName())){
							var out = [];
							if(Directive.getHasValue()){
								var parsedColumns = Directive.getParsed();
							} else {
								var parsedColumns = [];
							}
							var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
								CurrentStudioDatasource.getName()
							);
							if(LastExecutionRequestOptional.exists()){
								var LastExecutionRequest = LastExecutionRequestOptional.get();

								if(LastExecutionRequest.getIsSuccess()){
									var data = LastExecutionRequest.getData();
									var columns = data.getColumns();

									for(var column in columns){
										if(!parsedColumns.contains(column)){
											out.append(column);
										}
									}
								}
							}

						}

						//If we are a category directive then we can return all available fields
						if(Directive.getName() == "category"){
							var out = [];
							var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
								CurrentStudioDatasource.getName()
							);
							if(LastExecutionRequestOptional.exists()){
								var LastExecutionRequest = LastExecutionRequestOptional.get();

								if(LastExecutionRequest.getIsSuccess()){
									var data = LastExecutionRequest.getData();
									var columns = data.getColumns();

									for(var column in columns){
										out.append(column);
									}
								}
							}
						}

						return out;
					}
				}

				// Serialize the SqlFile into a struct that we can use in the view. This is the
				// active file that the user is currently viewing
				out.data.CurrentSqlFile = variables.fw.serializeFast(SqlFile, {
					Id:{},
					ShareableContent:{},
					Content:{},
					FullName:{},
					Name:{},
					IsAnySelectListSelected:{},
					IsDirty:{},
					ShouldLoadMongoDbEditor: function (SqlFile) {
						var NamedDirectives = SqlFile.getNamedDirectives();
						if (NamedDirectives.keyExists("mongodb-query")
							&& !isNull(NamedDirectives["mongodb-query"])
							&& !isEmpty(NamedDirectives["mongodb-query"].getValueRaw())
						) {
							return true;
						}
						if (!isNull(CurrentStudioDatasource) && CurrentStudioDatasource.getType() == "MongoDB") {
							return true;
						}
						return false;
					},
					IsRenamingFile: function(SqlFile){
						if(
							(
								args.keyExists("ChangeActiveFileName")
								and args.ChangeActiveFileName
								and args.keyExists("ActiveFile")
								and args.ActiveFile == SqlFile.getFullName()
							) || (
								args.keyExists("ChangingFileName")
								and args.ChangingFileName == SqlFile.getFullName()
							)
						){
							return true;
						} else {
							return false;
						}
					},
					CloseAllOtherFilesLink: function(SqlFile){
						var out = qs.clone()
							.setValue("OpenFiles", SqlFile.getFullName())
							.setValue("ActiveFile", SqlFile.getFullName())
							.delete("ChangeActiveFileName")
							.get();
						return out;
					},
					RenameFileLink: function(SqlFile){
						var keys = duplicate(openFileKeys);
						var out = qs.clone()
							.setValue("OpenFiles", keys.keyList())
							.setValue("ChangingFileName", SqlFile.getFullName())
							.get();
						return out;
					},
					IsMissingFile:{},
					EditorContent:{},
					DetectionMode:{},
					HasDirectiveErrors:{},
					Subpath: {},
					Package:{
						Path:{}
					},
					// Used in the openfilelist to show an active file but is not
					// within the open list. It works like a file preview, like
					// when you click on a file in the file list and it shows you
					// the file in the open file list, but isn't fully open. Just like vscode.
					IsActiveButNotOpen: function(SqlFile){
						if(args.keyExists("ActiveFile") and args.ActiveFile == SqlFile.getFullName()){
							if(!openFileKeys.keyExists(SqlFile.getFullName())){
								return true;
							}
						}
						return false;
					},
					// Whether this currently open file is the active file. Of course it is,
					// but the openfiles code is expecting this flag to be here
					IsActive: function(SqlFile){
						if(args.keyExists("ActiveFile") and args.ActiveFile == SqlFile.getFullName()){
							return true;
						} else {
							return false;
						}
					},
					OpenUrlParams: function(SqlFile){
						var keys = duplicate(openFileKeys);
						if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
							keys[ActiveFile] = true;
						}
						keys[SqlFile.getFullName()] = true;
						keys[SqlFile.getFullName()] = true;
						var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFile.getFullName()).setValue("RenderOnLoad", "true").getFields();
						return out;
					},
					CloseUrlParams: function(SqlFile){
						// When we are just previewing and are not yet open, when we
						// close this file we want to go back to the package last open
						// file
						var keys = duplicate(openFileKeys);
						if (keys.keyExists(SqlFile.getFullName())) {
							keys.delete(SqlFile.getFullName());
						}
						var qs = qs.clone();
						qs.setValue("OpenFiles", keys.keyList());

						if(keys.len() > 0){
							qs.setValue("ActiveFile", keys.keyArray().last());
						} else {
							qs.delete("ActiveFile");
						}
						var out = qs.getFields();
						return out;
					},
					PreviewCloseLink: function(SqlFile){
						// When we are just previewing and are not yet open, when we
						// close this file we want to go back to the package last open
						// file
						var keys = duplicate(openFileKeys);
						var qs = qs.clone();
						if(keys.len() > 0){
							qs.setValue("ActiveFile", keys.keyArray().last());
						} else {
							qs.delete("ActiveFile");
						}
						return qs.get();
					},
					// Return all of the found and supported directives as struct
					// names so that we can work with these on the directives panel
					NamedDirectives:{
						Title:directiveStruct,
						Subtitle:directiveStruct,
						Description:directiveStruct,
						Chart:directiveStruct,
						Category:directiveStruct,
						Series:directiveStruct,
						Groups:directiveStruct,
						Stacks:directiveStruct,
						Baselines:directiveStruct,
						"Baseline-Types":directiveStruct,
						"Stacking-Mode":directiveStruct,
						"Tags":directiveStruct,
						Formats:directiveStruct,
						"mongodb-query":directiveStruct
					},
					SelectListDirectives: directiveStruct,
					ParsedDirectives: {
						"mongodb-query": directiveStruct
					},
					LastExecutionRequest:{
						Id:{},
						Name:{},
						ExecutionTime:{},
						ErrorMessage:{},
						ErrorContent:{},
						IsSuccess:{},
						IsError:{},
						IsRunning:{},
						IsDone:{},
						IsCancelled:{}
					},
					LastRendering:{
						Content:{},
						Option: function(Rendering){
							// Manually return the Option because the
							// serializer by defualt doesn't return what you havent
							// specified
							var out = "";
							if(args.RenderPanelView == "option"){
								var option = Rendering.getOption()?:{};
								if(isStruct(option)){
									var out = formatJSON(serializeJson(option));
								}
							}
							return out;
						},
						IsSuccess:{},
						IsError:{},
						ErrorMessage:{},
						ErrorContent:{}
					},
					ResultSet: function(){
						// We serialize and deserialize to get the data in a regular JSON struct
						// instead of a query object
						var out = {};
						var startTick = getTickCount();
						var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
							CurrentStudioDatasource.getName()
						);
						if(LastExecutionRequestOptional.exists()){
							var LastExecutionRequest = LastExecutionRequestOptional.get();
							if(LastExecutionRequest.getIsDone() and !LastExecutionRequest.getIsCancelled()){
								if(LastExecutionRequest.getIsSuccess()){
									var data = LastExecutionRequest.getData();

									// Selete the _sortid column as it was just temporary for the
									// backend
									if(data.columnExists("_sortid")){
										data.deleteColumn("_sortid");
									}

									var out = deserializeJson(serializeJson(data));

									// Only return the first 100 rows
									try {
										if(out.Data.len() > 0){
											out.Data = out.Data.slice(1, len(out.Data) > 100 ? 100 : len(out.Data) - 1);
										}
									}catch(any e){
										writeDump(out);
										abort;
									}
									// Sort by the first column DESC
									out.Data = out.Data.sort(
										function(a, b) {
											if (a[1] > b[1]) {
												return  -1;
											} else if (a[1] < b[1]) {
												return 1;
											} else {
												return 0;
											}
										}
									);
									out.ExecutionTime = LastExecutionRequest.getExecutionTime();


									var columnOut = [];

									// We are going to decorate the colums with meta data about chart
									// directives so that we can display visual elements in the datalist
									// about how the columns are used
									for(var column in out.columns){

										var working = {
											name: column,
											isValueField: false,
											isCategoryField: false,
											isStackingField: false,
											isUsedAnywhere: false,
										};
										var directives = SqlFile.getParsedDirectives();
										var atValues = directives.series?:[];
										var atCategory = directives.category?:"";
										var atGroups = directives.groups?:[];
										var atStacks = directives.stacks?:[];

										if(atCategory == column){
											working.isCategoryField = true;
											working.isUsedAnywhere = true;
										}

										if(atValues.containsNoCase(column)){
											working.isValueField = true;
											working.isUsedAnywhere = true;
										}

										if(atCategory contains column or atGroups.containsNoCase(column)){
											working.isCategoryField = true;
											working.isUsedAnywhere = true;
										}

										if(atGroups.containsNoCase(column)){
											working.IsGroupingField = true;
											working.isUsedAnywhere = true;
										}

										if(atStacks.containsNoCase(column)){
											working.isStackingField = true;
											working.isUsedAnywhere = true;
										}

										if(directives.keyExists("stacking-mode") and directives["stacking-mode"] == "percent"){
											if(atValues.containsNoCase(column)){
												working.IsStackingModePercentField = true;
												working.isUsedAnywhere = true;
											}
										}

										columnOut.append(working);
									}

									out.columns = columnOut;
									// writeDump(out);
									// abort;
								}
							}
						}
						var endTick = getTickCount();
						request.timerData.CurrentSqlFileResultSet = endTick - startTick;

						return out;
					},
				})

				var SqlFileCacheOptional = SqlFile.getSqlFileCacheFromStudioDatasourceName(
					CurrentStudioDatasource.getName()
				);

				if (SqlFileCacheOptional.exists()) {
					var SqlFileCache = SqlFileCacheOptional.get();
					out.data.CurrentSqlFile.CurrentDatasourceSqlFileCache = variables.fw.serializeFast(SqlFileCache, {
						StudioDatasource: {
							Name: {}
						},
						LastExecutionRequest: {
							Id:{},
							Name:{},
							ExecutionTime:{},
							ErrorMessage:{},
							ErrorContent:{},
							IsSuccess:{},
							IsError:{},
							IsRunning:{},
							IsDone:{},
							IsCancelled:{}
						},
						LastSuccessfulExecutionRequest: {
							Id:{},
							Name:{},
							ExecutionTime:{},
							ErrorMessage:{},
							ErrorContent:{},
							IsSuccess:{},
							IsError:{},
							IsRunning:{},
							IsDone:{},
							IsCancelled:{}
						},
						LastRendering:{
							Content:{},
							Option: function(Rendering){
								// Manually return the Option because the
								// serializer by defualt doesn't return what you havent
								// specified
								var out = "";
								if(args.RenderPanelView == "option"){
									var option = Rendering.getOption()?:{};
									if(isStruct(option)){
										var out = formatJSON(serializeJson(option));
									}
								}
								return out;
							},
							IsSuccess:{},
							IsError:{},
							ErrorMessage:{},
							ErrorContent:{}
						}
					});
				}


				var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
					CurrentStudioDatasource.getName()
				);

				if (LastExecutionRequestOptional.exists()) {
					var CurrentDatasourceLastExecutionRequest = LastExecutionRequestOptional.get();
					out.data.CurrentSqlFile.CurrentDatasourceLastExecutionRequest = variables.fw.serializeFast(CurrentDatasourceLastExecutionRequest, {
						Id:{},
						Name:{},
						ExecutionTime:{},
						ErrorMessage:{},
						ErrorContent:{},
						IsSuccess:{},
						IsError:{},
						IsRunning:{},
						IsDone:{},
						IsCancelled:{}
					});
				}
			}
			var endTick = getTickCount();
			request.timerData.CurrentSqlFile = endTick - startTick;

			var startTick = getTickCount();
			// --------------------------------------
			// ChartSQLStudio Details
			// --------------------------------------
			// Broadly the overall details about ChartSQL packages and files
			// so that we can show the files and packages lists in the menus
			out.data.ChartSQLStudio = variables.fw.serializeFast(ChartSQLStudio, {
				FileBrowserViews:{
					Name:{},
					Content:{},
					IconClass:{},
					Link:{},
					Tooltip:{},
					IsActive: function(Self){
						if(args.keyExists("FileBrowserView") and args.FileBrowserView == arguments.Self.getName()){
							return true;
						} else {
							return false;
						}
					}
				},
				InfoPanelViews:{
					Name:{},
					Title:{},
					Content:{},
					IconClass:{},
					Link:{},
					IsActive: function(Self){
						if(args.keyExists("InfoPanelView") and args.InfoPanelView == arguments.Self.getName()){
							return true;
						} else {
							return false;
						}
					}
				},
				Packages:{
					UniqueId:{},
					FriendlyName:{},
					IsReadOnly:{},
					SqlFiles:{
						IsMissingFile: {},
						NamedDirectives:{
							Title:{
								ValueRaw:{}
							}
						}
					},
					OpenPackageParams: function(Package){
						var qs = qs.clone();
						qs.setValue("PackageName", Package.getUniqueId())
						.delete("SchemaFilter")
						.delete("Filter");

						var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
						if(StudioDatasourceOptional.exists()){
							var StudioDatasource = StudioDatasourceOptional.get();
							qs.setValue("StudioDatasource", StudioDatasource.getName());
						}

						return qs.getFields();
					},
					OpenPackageLink: function(Package){
						var qs = qs.clone();
						qs.setValue("PackageName", Package.getUniqueId())
						.delete("SchemaFilter")
						.delete("Filter");

						var StudioDatasourceOptional = Package.getDefaultStudioDatasource();
						if(StudioDatasourceOptional.exists()){
							var StudioDatasource = StudioDatasourceOptional.get();
							qs.setValue("StudioDatasource", StudioDatasource.getName());
						}

						return qs.get();
					},
				},
				StudioDatasources:{
					Name:{},
					IsSelected: function(StudioDatasource){
						if(args.keyExists("StudioDatasource") and args.StudioDatasource == StudioDatasource.getName()){
							return true;
						} else {
							return false;
						}
					},
					SelectLink: function(StudioDatasource){
						return qs.clone().setValue("StudioDatasource", StudioDatasource.getName()).setValue("RenderOnLoad", true).get();
					}
				},
				SqlFiles:{
					Id:{},
					Name:{},
					FullName:{},
					IsDirty:{},
					IsMissingFile:{},
					NamedDirectives:{
						Title: {
							ValueRaw:{},
							IsValid:{}
						},
						Chart:{
							ValueRaw:{},
							IsValid:{}
						}
					},
					IsRenamingFile: function(SqlFile){
						if(
							(
								args.keyExists("ChangeActiveFileName")
								and args.ChangeActiveFileName
								and args.keyExists("ActiveFile")
								and args.ActiveFile == SqlFile.getFullName()
							) || (
								args.keyExists("ChangingFileName")
								and args.ChangingFileName == SqlFile.getFullName()
							)
						){
							return true;
						} else {
							return false;
						}
					},
					CloseAllOtherFilesLink: function(SqlFile){
						var out = qs.clone()
							.setValue("OpenFiles", SqlFile.getFullName())
							.setValue("ActiveFile", SqlFile.getFullName())
							.delete("ChangeActiveFileName")
							.get();
						return out;
					},
					RenameFileLink: function(SqlFile){
						var keys = duplicate(openFileKeys);
						var out = qs.clone()
							.setValue("OpenFiles", keys.keyList())
							.setValue("ChangingFileName", SqlFile.getFullName())
							.get();
						return out;
					},
					OpenUrlParams: function(SqlFile){
						var keys = duplicate(openFileKeys);
						if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
							keys[ActiveFile] = true;
						}
						keys[SqlFile.getFullName()] = true;
						var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFile.getFullName()).setValue("RenderOnLoad", "true").getFields();
						return out;
					},
					CloseUrlParams: function(SqlFile){
						// When we are just previewing and are not yet open, when we
						// close this file we want to go back to the package last open
						// file
						var keys = duplicate(openFileKeys);
						if (keys.keyExists(SqlFile.getFullName())) {
							keys.delete(SqlFile.getFullName());
						}
						var qs = qs.clone();
						qs.setValue("OpenFiles", keys.keyList());

						if(keys.len() > 0){
							qs.setValue("ActiveFile", keys.keyArray().last());
						} else {
							qs.delete("ActiveFile");
						}
						var out = qs.getFields();
						return out;
					},
					UrlLink: function(SqlFile){
						// var keys = duplicate(openFileKeys);
						if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
							OpenFilesArray = [];
						} else {
							var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
						}
						var SqlFileFullName = SqlFile.getFullName();
						// keys[SqlFileFullName] = true;
						var out = qs.clone().setValue("OpenFiles", OpenFilesArray.toList(',')).setValue("ActiveFile", SqlFileFullName).setValue('RenderOnLoad', 'true').get();
						return out;
					},
					// A link to open the file
					OpenLink: function(SqlFile){
						var keys = duplicate(openFileKeys);
						if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
							keys[ActiveFile] = true;
						}
						keys[SqlFile.getFullName()] = true;
						var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFile.getFullName()).setValue("RenderOnLoad", "true").get();
						return out;
					},
					CloseLink: function(SqlFile){
						var keys = duplicate(openFileKeys);
						keys.delete(SqlFile.getFullName());
						var qs = qs.clone();
						qs.setValue("OpenFiles", keys.keyList());
						if(keys.count() ==0 ){
							qs.delete("ActiveFile");
						}
						return qs.get();
					},
					IsOpen: function(SqlFile){
						return openFileKeys.keyExists(SqlFile.getFullName());
					},
					IsScratch: function(SqlFile){
						if(SqlFile.getName() == "scratch.sql"){
							return true;
						} else {
							return false;
						}
					},
					IsActive: function(SqlFile){
						if(args.keyExists("ActiveFile") and args.ActiveFile == SqlFile.getFullName()){
							return true;
						} else {
							return false;
						}
					},
					LastExecutionRequest: {
						IsError:{}
					}
				}
			})
			var endTick = getTickCount();
			request.timerData.ChartSQLStudio = endTick - startTick;

			// Order the out.data.CurrentPackage.SqlFiles by their order on OpenFiles
			if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
				OpenFilesArray = [];
			} else {
				var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
			}

			// Create a lookup map for faster containment checks
			var openFilesMap = {};
			if (!isDefined("OpenFiles") || isNull(OpenFiles)) {
				var OpenFilesArray = [];
			} else {
				var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
				// Build index map for O(1) lookups
				for (var i = 1; i <= OpenFilesArray.len(); i++) {
					openFilesMap[OpenFilesArray[i]] = i;
				}
			}

			// --------------------------------------
			// CURRENT WORKSPACE
			// --------------------------------------
			// The currently open package
			if (arguments.keyExists("WorkspaceName")) {
				out.data.CurrentWorkspace = variables.fw.serializeFast(CurrentWorkspace, {
					UniqueId: {},
					FriendlyName:{},
					OpenWorkspaceLink: function(Workspace){
						var qs = qs.clone();
						qs.setValue("WorkspaceName", Workspace.getUniqueId())
						.delete("PackageName")
						.delete("EditWorkspace")
						.delete("EditPackage")
						.delete("Filter")
						.delete("SchemaFilter");
						return qs.get();
					},
					WorkspacePackages: {
						Package: {
							UniqueId: {},
							FriendlyName: {},
							SqlFiles:{
								ShareableContent:{},
								Id:{},
								Content:{},
								FullName:{},
								Name:{},
								IsMissingFile:{},
								NamedDirectives:{
									Title:{
										ValueRaw:{},
										IsValid:{}
									},
									Subtitle:{
										ValueRaw:{},
										IsValid:{}
									},
									Description:{
										ValueRaw:{},
										IsValid:{}
									},
									Chart:{
										ValueRaw:{},
										IsValid:{}
									},
								},
								IsMatchingFilter: function(SqlFile){

									var out = true;
									var trace = "";

									if(args.Filter == ""){
										return true;
									}

									var filter = Filter.toLowerCase();
									var name = SqlFile.getName().toLowerCase();
									var content = SqlFile.getContent().toLowerCase();

									var SqlFileNamedDirectives = SqlFile.getNamedDirectives();
									if(SqlFileNamedDirectives.keyExists("title")){
										var title = SqlFileNamedDirectives.title.getValueRaw()?:"".toLowerCase();
									} else {
										var title = "";
									}

									if(SqlFileNamedDirectives.keyExists("tags")){
										var tags = SqlFileNamedDirectives.tags.getValueRaw()?:"".toLowerCase();
									} else {
										var tags = "";
									}

									// 2024-07-09: Needed to switch from string.contains() to contains operator
									// because .contains() is case sensitive
									if(name contains filter or title contains filter or tags contains filter){
										return true;
									} else {
										return false;
									}
								},
								// Used to show an indicator if this is our active file
								IsActive: function(SqlFiles){
									if(args.keyExists("ActiveFile") and args.ActiveFile == SqlFiles.getFullName()){
										return true;
									} else {
										return false;
									}
								},
								// Used to show a border if this file is open
								IsOpen: function(SqlFiles){
									return openFileKeys.keyExists(SqlFiles.getFullName());
								},
								UrlLink: function(SqlFiles){
									// var keys = duplicate(openFileKeys);
									if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
										OpenFilesArray = [];
									} else {
										var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
									}
									var SqlFileFullName = SqlFiles.getFullName();
									// keys[SqlFileFullName] = true;

									var WorkspacePackage = CurrentWorkspace.findWorkspacePackageByUniqueId(
										SqlFiles.getPackage().getUniqueId()
									).get();
									var out = qs.clone().setValue("OpenFiles", OpenFilesArray.toList(',')).setValue("ActiveFile", SqlFileFullName).setValue('RenderOnLoad', 'true');

									var DefaultStudioDatasourceOptional = WorkspacePackage.getDefaultStudioDatasource();
									if (DefaultStudioDatasourceOptional.exists()) {
										var DefaultStudioDatasource = DefaultStudioDatasourceOptional.get();
										out.setValue("StudioDatasource", DefaultStudioDatasource.getName());
									}

									out = out.get();
									return out;
								},
								// A link to open the file
								OpenLink: function(SqlFiles){
									var keys = duplicate(openFileKeys);
									if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
										keys[ActiveFile] = true;
									}
									keys[SqlFiles.getFullName()] = true;

									var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFiles.getFullName()).setValue("RenderOnLoad", "true");

									var WorkspacePackage = CurrentWorkspace.findWorkspacePackageByUniqueId(
										SqlFiles.getPackage().getUniqueId()
									).get();

									var DefaultStudioDatasourceOptional = WorkspacePackage.getDefaultStudioDatasource();
									if (DefaultStudioDatasourceOptional.exists()) {
										var DefaultStudioDatasource = DefaultStudioDatasourceOptional.get();
										out.setValue("StudioDatasource", DefaultStudioDatasource.getName());
									}

									out = out.get();
									return out;
								},
								UrlParams: function(SqlFiles){
									// var keys = duplicate(openFileKeys);
									if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
										OpenFilesArray = [];
									} else {
										var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
									}
									var SqlFileFullName = SqlFiles.getFullName();
									// keys[SqlFileFullName] = true;

									var WorkspacePackage = CurrentWorkspace.findWorkspacePackageByUniqueId(
										SqlFiles.getPackage().getUniqueId()
									).get();
									var out = qs.clone().setValue("OpenFiles", OpenFilesArray.toList(',')).setValue("ActiveFile", SqlFileFullName).setValue('RenderOnLoad', 'true');

									var DefaultStudioDatasourceOptional = WorkspacePackage.getDefaultStudioDatasource();
									if (DefaultStudioDatasourceOptional.exists()) {
										var DefaultStudioDatasource = DefaultStudioDatasourceOptional.get();
										out.setValue("StudioDatasource", DefaultStudioDatasource.getName());
									}

									out = out.getFields();
									return out;
								},
								OpenUrlParams: function(SqlFiles){
									var keys = duplicate(openFileKeys);
									if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
										keys[ActiveFile] = true;
									}
									keys[SqlFiles.getFullName()] = true;

									var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFiles.getFullName()).setValue("RenderOnLoad", "true");

									var WorkspacePackage = CurrentWorkspace.findWorkspacePackageByUniqueId(
										SqlFiles.getPackage().getUniqueId()
									).get();

									var DefaultStudioDatasourceOptional = WorkspacePackage.getDefaultStudioDatasource();
									if (DefaultStudioDatasourceOptional.exists()) {
										var DefaultStudioDatasource = DefaultStudioDatasourceOptional.get();
										out.setValue("StudioDatasource", DefaultStudioDatasource.getName());
									}

									out = out.getFields();
									return out;
								}
							}
						}
					}
				})
			}


			// --------------------------------------
			// CURRENT PACKAGE
			// --------------------------------------
			// The currently open package
			var startTick = getTickCount();
			if(arguments.keyExists("PackageName")){
				if (arguments.keyExists("WorkspaceName")) {
					var CurrentPackageIndex = out.data.CurrentWorkspace.WorkspacePackages.find(function(wp) {
						return wp.Package.UniqueId == PackageName;
					});
					if (CurrentPackageIndex != 0) {
						out.data.CurrentPackage = out.data.CurrentWorkspace.WorkspacePackages[CurrentPackageIndex].Package;
					}
				} else {
					out.data.CurrentPackage = variables.fw.serializeFast(CurrentPackage, {
						UniqueId: {},
						FriendlyName:{},
						IsReadOnly: {},
						SqlFiles:{
							Id:{},
							FullName:{},
							Name:{},
							IsMissingFile:{},
							NamedDirectives:{
								Title:{
									ValueRaw:{},
									IsValid:{}
								},
								Subtitle:{
									ValueRaw:{},
									IsValid:{}
								},
								Description:{
									ValueRaw:{},
									IsValid:{}
								},
								Chart:{
									ValueRaw:{},
									IsValid:{}
								},
							},
							// Used to rerender the package file list if it has been filtered
							IsMatchingFilter: function(SqlFile){

								var out = true;
								var trace = "";

								if(args.Filter == ""){
									return true;
								}

								var filter = Filter.toLowerCase();
								var name = SqlFile.getName().toLowerCase();
								var content = SqlFile.getContent().toLowerCase();
								var SqlFileNamedDirectives = SqlFile.getNamedDirectives();

								if(SqlFileNamedDirectives.keyExists("title")){
									var title = SqlFileNamedDirectives.title.getValueRaw()?:"".toLowerCase();
								} else {
									var title = "";
								}

								if(SqlFileNamedDirectives.keyExists("tags")){
									var tags = SqlFileNamedDirectives.tags.getValueRaw()?:"".toLowerCase();
								} else {
									var tags = "";
								}

								// 2024-07-09: Needed to switch from string.contains() to contains operator
								// because .contains() is case sensitive
								if(name contains filter or title contains filter or tags contains filter){
									return true;
								} else {
									return false;
								}
							},
							// Used to show an indicator if this is our active file
							IsActive: function(SqlFile){
								if(args.keyExists("ActiveFile") and args.ActiveFile == SqlFile.getFullName()){
									return true;
								} else {
									return false;
								}
							},
							// Used to show a border if this file is open
							IsOpen: function(SqlFile){
								return openFileKeys.keyExists(SqlFile.getFullName());
							},
							UrlLink: function(SqlFile){
								// var keys = duplicate(openFileKeys);
								if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
									OpenFilesArray = [];
								} else {
									var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
								}
								var SqlFileFullName = SqlFile.getFullName();
								// keys[SqlFileFullName] = true;
								var out = qs.clone().setValue("OpenFiles", OpenFilesArray.toList(',')).setValue("ActiveFile", SqlFileFullName).setValue('RenderOnLoad', 'true').get();
								return out;
							},
							// A link to open the file
							OpenLink: function(SqlFile){
								var keys = duplicate(openFileKeys);
								if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
									keys[ActiveFile] = true;
								}
								keys[SqlFile.getFullName()] = true;
								var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFile.getFullName()).setValue("RenderOnLoad", "true").get();
								return out;
							},
							// OpenedOrder: function(SqlFile){
							// 	if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
							// 		OpenFilesArray = [];
							// 	} else {
							// 		var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
							// 	}

							// 	return OpenFilesArray.contains(SqlFile.getFullName());
							// },
							// A structure of URL parameters so we can make the open link a form GET which improves
							// the browser respnsiveness
							UrlParams: function(SqlFile){
								// var keys = duplicate(openFileKeys);
								if (!isDefined("OpenFiles") or isNull(OpenFiles)) {
									OpenFilesArray = [];
								} else {
									var OpenFilesArray = this.arrayRemoveDuplicates(OpenFiles.listToArray(','));
								}
								var SqlFileFullName = SqlFile.getFullName();
								// keys[SqlFileFullName] = true;
								var out = qs.clone().setValue("OpenFiles", OpenFilesArray.toList(',')).setValue("ActiveFile", SqlFileFullName).setValue('RenderOnLoad', 'true').getFields();
								return out;
							},
							OpenUrlParams: function(SqlFile){
								var keys = duplicate(openFileKeys);
								if (!isNull(ActiveFile) and !isEmpty(ActiveFile != "")) {
									keys[ActiveFile] = true;
								}
								keys[SqlFile.getFullName()] = true;
								var out = qs.clone().setValue("OpenFiles", keys.keyList()).setValue("ActiveFile", SqlFile.getFullName()).setValue("RenderOnLoad", "true").getFields();
								return out;
							}
						}
					});
				}
			}

			var endTick = getTickCount();
			request.timerData.CurrentPackage = endTick - startTick;

			if (arguments.keyExists("PackageName") and !arguments.keyExists("WorkspaceName")) {
				out.data.SqlFiles = out.data.CurrentPackage.SqlFiles;
			} else if (arguments.keyExists("WorkspaceName")) {
				// Merge all the WorkspacePackages.Package.SqlFiles into one list
				out.data.SqlFiles = [];

				// if we have a PackageName in arguments, we want to show the files only for that package
				if (arguments.keyExists("PackageName")) {
					out.data.SqlFiles = out.data.CurrentPackage.SqlFiles;
				} else {
					// More efficient array concatenation using arrayConcat()
					var allPackageFiles = out.data.CurrentWorkspace.WorkspacePackages.map(function(wp) {
						return wp.Package.SqlFiles;
					});
					out.data.SqlFiles = arrayConcat(allPackageFiles);
				}
			} else {
				out.data.SqlFiles = [];
			}

			var startTick = getTickCount();
			// --------------------------------------
			// EDITOR SESSION
			// --------------------------------------
			// Overall details about the editing session like the LastExecutionRequest
			// and all of the ExecutionRequests not sepcific to the particular SqlFile
			out.data.EditorSession = variables.fw.serializeFast(EditorSession, {
				ExecutionRequests:{
					Name:{},
					ExecutionTime:{},
					SqlFullName:{},
					PackageFullName:{},
					IsError:{},
					IsSuccess:{},
					IsCancelled:{},
					IsRunning:{},
					ErrorMessage:{},
					ErrorContent:{},
					RecordCount:{},
					CompletedAt:{}
				},
				LastExecutionRequest:{
					Id:{},
					Name:{},
					ExecutionTime:{},
					ErrorMessage:{},
					IsSuccess:{},
					IsError:{},
					IsRunning: function(ExecutionRequest){
						// We override this method because we want to show that the
						// execution is running if we have called the render on load
						// and the execution is not yet complete. This is so that the
						// UI refreshes at least once so that the user knows that the
						// preview is being loaded
						if(lastRenderOnLoadCalled){
							if(lastRenderOnLoadComplete){
								return false;
							} else {
								return true;
							}
						} else {
							return ExecutionRequest.getIsRunning();
						}
					},
					IsDone:{},
					IsCancelled:{},
					SqlFile:{
						Name:{}
					}
				}
			});
			var endTick = getTickCount();
			request.timerData.EditorSession = endTick - startTick;

			var startTick = getTickCount();
			// --------------------------------------
			// CURRENT STUDIO DATASOURCE
			// --------------------------------------
			// The currently selected datasource
			out.data.CurrentStudioDatasource = variables.fw.serializeFast(CurrentStudioDatasource, {
				Name:{},
				Type: {},
				IsSelected: function(StudioDatasource){
					if(args.keyExists("StudioDatasource") and args.StudioDatasource == StudioDatasource.getName()){
						return true;
					} else {
						return false;
					}
				}
			});
			var endTick = getTickCount();
			request.timerData.CurrentStudioDatasource = endTick - startTick;

			out.data.InfoPanelView = arguments.InfoPanelView;

			var startTick = getTickCount();
			// --------------------------------------
			// SERVER PERFORMANCE
			// --------------------------------------
			// Render details about server performance if this tab is open
			if(arguments.InfoPanelView == "server"){
				var serverPerformanceData = variables.fw.getPerformanceData();
				if(!isNull(serverPerformanceData)){
					// // writeDump(directives);
					var EChartsOption = new core.util.EChartsOption.EChartsOption(
						data = serverPerformanceData,
						directives = {
							chart: "area"
						},
						renderInLine = true
					)

					var serverDataContent = "";
					savecontent variable="serverDataContent" {
						EchartsOption.render(
							width: "400px",
							height: "300px"
						);
					}

					out.data.ServerPerformanceData = {
						Content: serverDataContent
					}
				}
			}
			var endTick = getTickCount();
			request.timerData.ServerPerformance = endTick - startTick;

			var startTick = getTickCount();

			// --------------------------------------
			// BROWSER SCHEMA PANEL DATA
			// --------------------------------------
			if(arguments.FileBrowserView == "schema"){
				var Datasource = CurrentStudioDatasource.getDatasource();
				if(structKeyExists(Datasource, "getDatasourceInfo")){
					CurrentDatasourceInfo = Datasource.getDatasourceInfo();
					out.data.CurrentDatasourceInfo = variables.fw.serializeFast(CurrentDatasourceInfo, {
						Tables:{
							Name:{},
							Fields:{
								Name:{},
								Type:{},
								// Used to rerender the schema list if it has been filtered
								IsFiltered: function(Field){
									if(SchemaFilter == ""){
										return false;
									}

									var SchemaFilter = SchemaFilter.toLowerCase();
									var name = Field.getName().toLowerCase();

									if(name.contains(SchemaFilter)){
										return false;
									} else {
										return true;
									}
								},
							}
						}
					})
				}
			}

			// --------------------------------------
			// VIEW STATE
			// --------------------------------------
			//Setup which editor panel view to show
			var editorPanelViews = ["sql", "directives", "mongodb-query"];
			if(!arrayContains(editorPanelViews, arguments.EditorPanelView)){
				arguments.EditorPanelView = "sql";
			}
			out.view_state.editor_panel.active_view = arguments.EditorPanelView;

			//Setup url qs links to the other editor panels
			for(var view in editorPanelViews){
				out.view_state.editor_panel[view].link = qs.clone().setValue("EditorPanelView", view).get();
			}

			//Setup render panel views
			var renderPanelViews = ["chart", "option"];
			if(!arrayContains(renderPanelViews, arguments.RenderPanelView)){
				arguments.RenderPanelView = "chart";
			}
			out.view_state.render_panel.active_view = arguments.RenderPanelView;

			//Setup url qs links to the other render panels
			for(var view in renderPanelViews){
				out.view_state.render_panel[view].link = qs.clone().setValue("RenderPanelView", view).get();
			}

			//Setup browser panel views
			// var FileBrowserViews = ["files", "schema", "stories"];
			// if(!arrayContains(FileBrowserViews, arguments.FileBrowserView)){
			// 	arguments.FileBrowserView = "files";
			// }
			out.view_state.browser_panel.active_view = arguments.FileBrowserView;

			//Setup url qs links to the other browser panels
			// for(var view in FileBrowserViews){
			// 	out.view_state.browser_panel[view].link = qs.clone().setValue("FileBrowserView", view).get();
			// }

			out.view_state.opened_dropdown_menu_items = request.context.client_state?.opened_dropdown_menu_items?:"";

			// Here we load the widths and heights of the panels from the client state (cookies)
			// and if they are not set we use the defaults. The client state values are going to
			// be set by the javascript in the view in the Split.js onDragEnd event.
			out.view_state.top_panel_height = toString(round(toNumeric(request.context.client_state?.top_panel_height?:"60"),2));
			out.view_state.bottom_panel_height = toString(round(toNumeric(request.context.client_state?.bottom_panel_height?:"40"),2));
			out.view_state.editor_width = toString(round(toNumeric(request.context.client_state?.editor_width?:"50"),2));
			out.view_state.renderer_width = toString(round(toNumeric(request.context.client_state?.renderer_width?:"50"),2));
			out.view_state.file_list_width = toString(round(toNumeric(request.context.client_state?.file_list_width?:"20"),2));
			out.view_state.main_container_width = toString(round(toNumeric(request.context.client_state?.main_container_width?:"80"),2));

			// Rendering panel can be maximized in which case we will force the heights
			// and widths of the panels to account.
			if(arguments.keyExists("maximizePanel")){
				if(arguments.maximizePanel == "renderer"){
					out.view_state.top_panel_height = "100";
					out.view_state.bottom_panel_height = "0";
					out.view_state.editor_width = "0";
					out.view_state.renderer_width = "100";
					out.view_state.renderer_is_maximized = true;
				} else {
					out.view_state.renderer_is_maximized = false;
				}

				if(arguments.maximizePanel == "editor"){
					out.view_state.top_panel_height = "100";
					out.view_state.bottom_panel_height = "0";
					out.view_state.editor_width = "100";
					out.view_state.renderer_width = "0";
					out.view_state.editor_is_maximized = true;
				} else {
					out.view_state.editor_is_maximized = false;
				}

				out.view_state.has_maximized_panel = true;
			} else {
				out.view_state.has_maximized_panel = false;
			}

			if(arguments.keyExists("PackageName") or arguments.keyExists("WorkspaceName")){
				out.view_state.is_home_screen = false;
			} else {
				out.view_state.is_home_screen = true;
			}

			if(arguments.keyExists("Filter")){
				out.view_state.filter = arguments.Filter;
			}

			if(arguments.keyExists("SchemaFilter")){
				out.view_state.SchemaFilter = arguments.SchemaFilter;
			}

			out.view_state.params = qs.getFields();
			out.view_state.maximizeRendererLink = qs.clone().setValue('maximizePanel', 'renderer').get();
			out.view_state.maximizeEditorLink = qs.clone().setValue('maximizePanel', 'editor').get();
			out.view_state.minimizeLink = qs.clone().delete('maximizePanel').get();
			out.view_state.openSqlEditorLink = qs.clone().setValue('EditorPanelView', 'sql').get();
			out.view_state.openDirectivesEditorLink = qs.clone().setValue('EditorPanelView', 'directives').get();
			out.view_state.openMongoDBQueryEditorLink = qs.clone().setValue('EditorPanelView', 'mongodb-query').get();


			// // The editor link should remove the PresentationMode variable from the URL
			// // to get back to the same file as we were in preview mode
			// out.view_state.editor_link = qs.clone().delete("PresentationMode").get()

			out.view_state.current_url = qs.get();
			out.view_state.new_file_link = qs.clone().delete("ActiveFile").get();
			out.view_state.preview_in_card_on_link = qs.clone().setValue("PreviewInCard", "true").get();
			out.view_state.preview_in_card_off_link = qs.clone().setValue("PreviewInCard", "false").get();
			out.view_state.close_all_link = qs.clone().delete("OpenFiles").delete("ActiveFile").get();
			out.view_state.clear_filter_link = qs.clone().delete("Filter").get();
			out.view_state.clear_schema_filter_link = qs.clone().delete("SchemaFilter").get();
			out.view_state.change_file_name_link = qs.clone().delete("ChangingFileName").setValue("ChangeActiveFileName", "true").get();
			out.view_state.stop_change_file_name_link = qs.clone().delete("ChangingFileName").delete("ChangeActiveFileName").get();
			out.view_state.rename_file_go_to = qs.clone().delete("ChangeActiveFileName").setValue("ActiveFile", "${data.FullName}").get();

			// If the current active file is not in the openFileKeys then we are going to add it
			// for the saveFile URL such that if the file is saved it will get opened
			if(arguments.keyExists("ActiveFile") && !openFileKeys.keyExists(arguments.ActiveFile)){
				var newOpenKeys = duplicate(openFileKeys);
				newOpenKeys[arguments.ActiveFile] = true;
			} else {
				var newOpenKeys = openFileKeys;
			}
			out.view_state.save_or_update_file_redirect = qs.clone().setValue("OpenFiles", newOpenKeys.keyList()).get();

			// The main target objects that we want to replace within the view on form posts
			out.view_state.main_zero_targets = "##renderer-card-header,##renderContainer,##editorTabs,##infoPanelInner,##openFilesList,##fileList,##openFilePath,##file-browswer-view-links,##editorBody,##aside,##directivesEditorColumnHeaders,##header,##globalSearchModal,##new-file-dropdown,##modalErrorContainer";
			out.view_state.directives_editor_targets = "##editorTabs,##openFilesList,##sqlSourceCode,##editorBody,##saveButton,##rendererPanel,##editorProgressContainer,##fileList,.directiveErrorAlert,.directiveEditorTitle,##modalErrorContainer";

			// This was taking about 100ms to run and so we are not going to run it on every
			// request. The application key will be reset by this.keyPerformanceInfo() function
			// which the user can turn on in the UI.
			if(!application.keyExists("lastKeyPerformanceInfo")){
				application.lastKeyPerformanceInfo = this.keyPerformanceInfo().data.keyPerformanceInfo;
			}
			out.data.keyPerformanceInfo = application.lastKeyPerformanceInfo;
			out.data.ChangeActiveFileName = arguments.ChangeActiveFileName;
			out.data.ChangingFileName = arguments.ChangingFileName;
			if (arguments.keyExists('ActiveFile') && !isNull(arguments.ActiveFile)) {
				out.data.ActiveFile = arguments.ActiveFile;
			} else {
				out.data.ActiveFile = "";
			}

			if (arguments.keyExists('PackageName') && !arguments.keyExists('StudioDatasource')) {
				// throw("Package didn't have a default datasource, you must select one before opening the package. <br><a href='/studio/settings/packages?EditPackage=#arguments.PackageName#'>Go to '#arguments.PackageName#' package settings</a>", "StudioDatasourceRequired");
				if (!isDefined('out.view_state.error')) {
					out.view_state.missing_studio_datasource = {
						code: "missing_studio_datasource",
						message: "Package didn't have a default datasource, you must select one to execute the query. <br /><br />You can setup a default datasource in settings <br><a href='/studio/settings/packages?EditPackage=#arguments.PackageName#'>Go to '#arguments.PackageName#' package settings</a>"
					};
				}
			}


			var endTick = getTickCount();
			request.timerData.ViewState = endTick - startTick;

			// writeDump(request.timerData);
			// abort;

			// writeDump(out.data.CurrentSqlFile.NamedDirectives["mongodb-query"]);
			// abort;
			request.startTick = getTickCount();
			return out;
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// 	return out;
		// }
	}

	public function keyPerformanceInfo() method="POST" {
		if (server.system.properties["os.name"].find("Mac") > 0) {
			var out = {
				"success":true,
				"data":{
					keyPerformanceInfo: {
						cpuLoad: 0,
						memoryUsage: 0,
						maxMemory: 0,
						memoryPercent: 0,
						maxMemoryUseEver: 0
					}
				}
			}
			return out;
		}

		var memoryUsage = getMemoryUsage();
		var totalMemoryUse = (memoryUsage.used[4] + memoryUsage.used[5] + memoryUsage.used[6]) / 1024 / 1024;
		var maxMemory = (memoryUsage.max[4] + memoryUsage.max[5] + memoryUsage.max[6]) / 1024 / 1024;


		if(!application.keyExists("maxMemoryUseEver")){
			application.maxMemoryUseEver = 0;
		}
		// if the current memory use is great than the ever used, increase ever to the current.
		// This is because we don't want to show the actual memory used on every request, it looks
		// like more than typical
		if(totalMemoryUse > application.maxMemoryUseEver){
			application.maxMemoryUseEver = totalMemoryUse;
		}

		var memoryPercent = (application.maxMemoryUseEver / maxMemory) * 100;

		var ManagementFactory = createObject("java", "java.lang.management.ManagementFactory");
		// Get the OperatingSystemMXBean instance using getPlatformMXBean
		var osBean = ManagementFactory.getPlatformMXBean(createObject("java", "java.lang.management.OperatingSystemMXBean").getClass());

		// Access the getProcessCpuLoad method using the osBean instance
		// (Will require casting to com.sun.management.OperatingSystemMXBean)
		// writeDump(server);
		// abort;
		var processCpuLoad = osBean.getProcessCpuLoad();

		// Output the CPU usage for the Java process
		// writeOutput("CPU load (per process): " & (processCpuLoad * 100) & "%");

		var out = {
			"success":true,
			"data":{
				keyPerformanceInfo: {
					cpuLoad: round(processCpuLoad * 100 * 100) / 100,
					memoryUsage: round(totalMemoryUse * 100) / 100,
					maxMemory: round(maxMemory * 100) / 100,
					memoryPercent: round(memoryPercent * 100) / 100,
					maxMemoryUseEver: round(application.maxMemoryUseEver * 100) / 100
				}
			}
		}

		application.lastKeyPerformanceInfo = out.data.keyPerformanceInfo;

		// writeDump(out);
		// abort;
		return out;
	}

	/**
	 * Reads the mascot logo from the file system and returns a cfcontent with the image
	 */
	public function mascot() method="GET" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var image = ChartSQLStudio.getMascotBinary();
		content variable="#image#" type="image/png";
		abort;
	}

	/**
	 * Reads the mascot logo from the file system and returns a cfcontent with the image
	 */
	public function logo() method="GET" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var image = ChartSQLStudio.getLogoBinary();
		content variable="#image#" type="image/png";
		abort;
	}

	/**
	 * Formats a JSON string with indents &amp; new lines.
	 * v1.0 by Ben Koshy
	 *
	 * @param str      JSON string (Required)
	 * @return Returns a string of indent-formated JSON
	 * @author Ben Koshy (cf@animex.com)
	 * @version 0, September 16, 2012
	 */
	// formatJSON() :: formats and indents JSON string
	// based on blog post @ http://ketanjetty.com/coldfusion/javascript/format-json/
	// modified for CFScript By Ben Koshy @animexcom
	// usage: result = formatJSON('STRING TO BE FORMATTED') OR result = formatJSON(StringVariableToFormat);

	public string function formatJSON(str) {
		var fjson = '';
		var pos = 1;
		var strLen = len(arguments.str);
		var indentStr = chr(9); // Adjust Indent Token If you Like
		var newLine = chr(10); // Adjust New Line Token If you Like <BR>

		for (var i=1; i<=strLen; i++) {
			var char = mid(arguments.str,i,1);

			if (char == '}' || char == ']') {
				fjson &= newLine;
				pos = pos - 1;

				for (var j=1; j<pos; j++) {
					fjson &= indentStr;
				}
			}

			fjson &= char;

			if (char == '{' || char == '[' || char == ',') {
				fjson &= newLine;

				if (char == '{' || char == '[') {
					pos = pos + 1;
				}

				for (var k=1; k<pos; k++) {
					fjson &= indentStr;
				}
			}
		}

		return fjson;
	}

	public function clearEditorSession() method="POST" {
		var sessStruct = variables.fw.getSessionStruct();
		sessStruct.delete("EditorSession");
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		sessStruct.EditorSession = new studio.model.EditorSession(
			ChartSQLStudio = ChartSQLStudio
		);
		var out = {
			"success":true,
			"message":"The editor session has been cleared"
		}
		return out;
	}

	public function changeFileName(
		required string SqlFileFullName,
		required string fileName
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.SqlFileFullName).elseThrow("Could not locate that SqlFile: #arguments.SqlFileFullName#");
		var CurrentFullName = SqlFile.getFullName();
		var CurrentName = SqlFile.getName();
		var openFileNames = [];

		SqlFile.changeFileName(
			newName = arguments.fileName
		);

		if (isDefined("request.context.OpenFiles")) {
			openFileNames = listToArray(request.context.OpenFiles);
		}

		var openFileKeys = structNew("ordered");
		for(var name in openFileNames){
			openFileKeys[name] = true;
		}

		var NewFullName = SqlFile.getFullName();
		if (openFileKeys.keyExists(CurrentFullName)) {
			openFileKeys.delete(CurrentFullName);
			openFileKeys[NewFullName] = true;
		}

		if (isDefined("request.context.ActiveFile")) {
			if (request.context.ActiveFile == CurrentFullName) {
				ActiveFile = NewFullName;
			} else {
				ActiveFile = request.context.ActiveFile;
			}
		}

		var qs = ChartSQLStudio.getEditorQueryString();
		var redirectTo = qs.clone()
			.setValue("OpenFiles", openFileKeys.keyList())
			.delete("ChangeActiveFileName");

		if (isDefined("ActiveFile") && !isEmpty(ActiveFile)) {
			redirectTo = redirectTo.setValue("ActiveFile", ActiveFile);
		}

		for (var field in request.newform.keyList()) {
			if (
				field == "ID"
				|| field == "CFID"
				|| field == "CFTOKEN"
				|| field == "fieldnames"
				|| field == "OpenFiles"
				|| field == "ActiveFile"
				|| field == "SqlFileFullName"
				|| field == "fileName"
				|| field == "ChangeActiveFileName"
			) {
				continue;
			}
			redirectTo.setValue(field, request.newform[field]);
		}

		var redirectTo = redirectTo.get();
		variables.fw.doLocation(redirectTo);

		var out = {
			"success":true,
			"data": {
				"FullName": SqlFile.getFullName()
			}
		}
		return out;
	}

	function deleteFile(
		required string FullName
	) method="POST" {
		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not locate that SqlFile: #arguments.FullName#");
		SqlFile.delete();
		var out = {
			"success":true,
		}
		return out;
	}

	public function saveFile(
		required string FullName,
		required string Sql
	) method="POST" {
		// try {
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not locate that SqlFile: #arguments.FullName#");
			if (!isDefined('arguments.Sql') || arguments.Sql == nullValue()) {
				arguments.Sql = "";
			}
			SqlFile.writeContent(arguments.Sql);

			var EditorSession = variables.fw.getEditorSession();
			var ExecutionRequest = EditorSession.createExecutionRequest(
				SqlFile = SqlFile
			);

			var out = {
				"success":true,
			}
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// }
		return out;
	}

	public function storeEditorContent(
		required string FullName,
		required string Sql
	) method="POST" {
		// try {
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not locate that SqlFile: #arguments.FullName#");
			SqlFile.setEditorContent(arguments.Sql);
			var out = {
				"success":true,
			}
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// }

		return out;
	}

	public function createSqlFile(
		required string PackageName,
		required string FileName,
		string OpenFileAt
	) method="POST" {
		// try {
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var Package = ChartSQLStudio.findPackageByUniqueId(arguments.PackageName).elseThrow("Could not locate that Package: #arguments.PackageName#");
			var PreexistingSqlFileOptional = Package.findSqlFileByName(arguments.FileName);
			if (PreexistingSqlFileOptional.exists() ) {
				throw("A file with the name #arguments.FileName# already exists in the package #arguments.PackageName#", "FileAlreadyExists");
			}
			var SqlFile = Package.createNewSqlFile(
				name = arguments.FileName
			);

			if(arguments.keyExists("OpenFileAt")){
				var qs = new zero.plugins.zerotable.model.queryStringNew(arguments.OpenFileAt);
				qs.setBasePath("/studio/main");

				// It appears that the URL can be encoded sometimes and I am not quite sure why or where it happens
				// so we decode it here to be sure
				var openFiles = urlDecode(qs.getValue("OpenFiles")) & "," & SqlFile.getFullName();
				// var openFiles = qs.getValue("OpenFiles") & "," & SqlFile.getFullName();

				qs.setValue("PackageName", arguments.PackageName);
				qs.setValue("ActiveFile", SqlFile.getFullName());
				qs.setValue("OpenFiles", openFiles);
				variables.fw.doLocation(qs.get());
			}

			var out = {
				"success":true,
				"data":{
					SqlFile: variables.fw.serializeFast(SqlFile, {
						FullName:{}
					})
				}
			}
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// }
		return out;
	}

	public function toggleSQLFileDirective (
		required string FullName,
		required string Directive
	) method="POST" {
		// try {
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not locate that SqlFile: #arguments.FullName#");
			SqlFile.toggleDirective(
				name = arguments.Directive
			);
			var out = {
				"success":true,
			}
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// }
		return out;
	}

	/**
	 * Updates or replaces the text for a directive. This is used by the directives
	 * editor
	 */
	public function addOrUpdateDirective(
		required string FullName,
		required string Directive,
		required string Value
	) method="POST" {
		// try {
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.FullName).elseThrow("Could not locate that SqlFile: #arguments.FullName#");
			SqlFile.addOrUpdateDirective(
				name = arguments.Directive,
				value = arguments.Value
			);
			var out = {
				"success":true,
			}
		// } catch (any e) {
		// 	var out = {
		// 		"success":true,
		// 		"view_state": {
		// 			"error": {
		// 				"message": e.message,
		// 				"type": e.type,
		// 				"detail": e.detail
		// 			}
		// 		}
		// 	}
		// }
		return out;
	}

	public function cancelExecution(
		string Id
	) method="POST"{
		var EditorSession = variables.fw.getEditorSession();
		var ExecutionRequest = EditorSession.findExecutionRequestById(arguments.Id).elseThrow("Could not locate that ExecutionRequest: #arguments.Id#");
		ExecutionRequest.cancel();
		// sleep(5000);
		// writeDump(ExecutionRequest.getStatus());
		// var Task = ExecutionRequest.getTask();
		// writeDump(Task);
		// writeDump(Task.isCancelled());
		// writeDump(Task.isDone());
		// writeDump(Task.error());
		// abort;
		var out = {
			"success":true,
		}
		return out;
	}

	public function checkExecution(
		string Id
	) method="POST"{
		var EditorSession = variables.fw.getEditorSession();
		var ExecutionRequest = EditorSession.findExecutionRequestById(arguments.Id).elseThrow("Could not locate that ExecutionRequest: #arguments.Id#");
		if(ExecutionRequest.getIsSuccess()){
			var SqlFile = ExecutionRequest.getSqlFile();
			var data = ExecutionRequest.getData();
			var Rendering = new studio.model.Rendering(SqlFile, ExecutionRequest);
			Rendering.render(data);
		}
		// sleep(5000);
		// writeDump(ExecutionRequest.getStatus());
		// var Task = ExecutionRequest.getTask();
		// writeDump(Task);
		// writeDump(Task.isCancelled());
		// writeDump(Task.isDone());
		// writeDump(Task.error());
		// abort;
		var out = {
			"success":true,
			"data":{
				"status":ExecutionRequest.getStatus()
			}
		}
		return out;
	}

	function resetSelectListSelections(
		required string SqlFileFullName
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.SqlFileFullName).elseThrow("Could not locate that SqlFile: #arguments.SqlFileFullName#");

		SqlFile.resetSelectListSelections();

		var EditorSession = variables.fw.getEditorSession();
		var ExecutionRequest = EditorSession.createExecutionRequest(
			SqlFile = SqlFile
		);

		var out = {
			"success":true,
			"message": "The select list has been reset"
		}

		return out;
	}

	function updateSelectListSelection(
		required string SqlFileFullName,
		required string SelectListUserName,
		required string SelectListSelectedValue
	) method="POST" {

		var ChartSQLStudio = variables.fw.getChartSQLStudio();
		var SqlFile = ChartSQLStudio.findSqlFileByFullName(arguments.SqlFileFullName).elseThrow("Could not locate that SqlFile: #arguments.SqlFileFullName#");

		SqlFile.updateSelectListSelection(
			SelectListUserName = arguments.SelectListUserName,
			SelectListSelectedValue = arguments.SelectListSelectedValue
		);

		var EditorSession = variables.fw.getEditorSession();
		var ExecutionRequest = EditorSession.createExecutionRequest(
			SqlFile = SqlFile
		);

		var out = {
			"success":true,
			"message": "The select list has been updated"
		}

		return out;
	}

	function getLastExecutionRequestData(
		required string SqlFileFullName,
		numeric start = 1
	) method="GET" {
		// We serialize and deserialize to get the data in a regular JSON struct
		// instead of a query object
		out = {
			"success": true,
			"data": {
				"datatable": {
					"data": [],
					"columns": [],
					"recordsTotal": 0,
					"recordsFiltered": 0
				}
			}
		}

		// try {
			var pageLength = 100;
			var ChartSQLStudio = variables.fw.getChartSQLStudio();
			var EditorSession = variables.fw.getEditorSession();
			var SqlFileOptional = ChartSQLStudio.findSqlFileByFullName(arguments.SqlFileFullName);

			if (!SqlFileOptional.exists()) {
				throw("Could not locate that SqlFile: #arguments.SqlFileFullName#", "SqlFileNotFound");
			}

			var SqlFile = SqlFileOptional.get();

			var LastExecutionRequestOptional = SqlFile.getLastExecutionRequestFromStudioDatasourceName(
				StudioDatasourceName = EditorSession.getCurrentStudioDatasource().getName()
			);


			if(LastExecutionRequestOptional.exists()){
				var LastExecutionRequest = LastExecutionRequestOptional.get();

				if(LastExecutionRequest.getIsDone() and !LastExecutionRequest.getIsCancelled()){
					if(LastExecutionRequest.getIsSuccess()){
						var data = LastExecutionRequest.getData();

						// Selete the _sortid column as it was just temporary for the
						// backend
						if(data.columnExists("_sortid")){
							data.deleteColumn("_sortid");
						}

						out.data.datatable = deserializeJson(serializeJson(data));

						var search = request.context["search[value]"];

						if (isDefined('search') && !isNull(search) && !isEmpty(search)) {
							// Check every row for the value in search
							out.data.datatable.data = out.data.datatable.data.filter(function (row) {
								for (var column in row) {
									if (column.toString() contains search) {
										return true;
									}
								}
								return false;
							})
						}


						if (request.context.keyExists('order[0][column]')) {
							var sortColumnIndex = request.context.keyExists('order[0][column]') + 1;
							var sortDirection = request.context.keyExists('order[0][dir]');

							out.data.datatable.data = out.data.datatable.data.sort(
								function(a, b) {
									if (a[sortColumnIndex] > b[sortColumnIndex]) {
										return (sortDirection == 'asc') ? 1 : -1;
									} else if (a[sortColumnIndex] < b[sortColumnIndex]) {
										return (sortDirection == 'asc') ? -1 : 1;
									} else {
										return 0;
									}
								}
							);
						}

						var recordsTotal = len(out.data.dataTable.data);

						// Show the out.data.datatable.data depending on the start value and pageLength
						if (arguments.start + pageLength > len(out.data.datatable.data)) {
							out.data.datatable.data = out.data.datatable.data.slice(arguments.start + 1, recordsTotal - arguments.start);
						} else {
							out.data.datatable.data = out.data.datatable.data.slice(arguments.start + 1, pageLength);
						}

						out.data.datatable.ExecutionTime = LastExecutionRequest.getExecutionTime();

						var columnOut = [];

						// We are going to decorate the colums with meta data about chart
						// directives so that we can display visual elements in the datalist
						// about how the columns are used
						for(var column in out.data.datatable.columns){

							var working = {
								name: column,
								isValueField: false,
								isCategoryField: false,
								isStackingField: false,
								isUsedAnywhere: false,
							};
							var directives = SqlFile.getParsedDirectives();
							var atValues = directives.series?:[];
							var atCategory = directives.category?:"";
							var atGroups = directives.groups?:[];
							var atStacks = directives.stacks?:[];

							if(atCategory == column){
								working.isCategoryField = true;
								working.isUsedAnywhere = true;
							}

							if(atValues.containsNoCase(column)){
								working.isValueField = true;
								working.isUsedAnywhere = true;
							}

							if(atCategory contains column or atGroups.containsNoCase(column)){
								working.isCategoryField = true;
								working.isUsedAnywhere = true;
							}

							if(atGroups.containsNoCase(column)){
								working.IsGroupingField = true;
								working.isUsedAnywhere = true;
							}

							if(atStacks.containsNoCase(column)){
								working.isStackingField = true;
								working.isUsedAnywhere = true;
							}

							if(directives.keyExists("stacking-mode") and directives["stacking-mode"] == "percent"){
								if(atValues.containsNoCase(column)){
									working.IsStackingModePercentField = true;
									working.isUsedAnywhere = true;
								}
							}

							columnOut.append(working);
						}

						out.data.datatable["columns"] = columnOut;
						// writeDump(out);
						// abort;
						var data = out.data.datatable.data;
						out.data.datatable.delete("data");
						out.data.datatable["data"] = data;
						out.data.datatable["recordsTotal"] = recordsTotal;
						out.data.datatable["recordsFiltered"] = recordsTotal;
					}
				}
			}
		// } catch (any e) {
		// 	out = {
		// 		"success": false,
		// 		"data": {
		// 			"datatable": {
		// 				"data": [],
		// 				"columns": [],
		// 				"recordsTotal": 0,
		// 				"recordsFiltered": 0
		// 			}
		// 		}
		// 	}
		// }
		return out;
	}

	public struct function create(){
		return {};
	}

	public struct function read( required id ) {
		return {};
	}

	public struct function update( required id ) {
		return {};
	}

	public struct function delete( required id ) {
		return {};
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
		return controllerResult;
	}

	private function arrayRemoveDuplicates(array){
		return array.reduce(function(deduped, el){
			return deduped.find(el) ? deduped : deduped.append(el);
		}, []);
	}

	/**
	 * Helper function to efficiently concatenate multiple arrays
	 */
	private array function arrayConcat(required array arrayOfArrays) {
		return arrayOfArrays.reduce(function(result, currentArray) {
			return result.append(currentArray, true);
		}, []);
	}

}
