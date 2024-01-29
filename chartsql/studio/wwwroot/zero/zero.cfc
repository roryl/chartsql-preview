import serializer;
import plugins.zeroadmin.model.*;
component extends="one" {
	request.trace = new RequestTrace();
	this.customTagPaths = ["framework-zero/zero/_vendor/handlebarslucee","zero/_vendor/handlebarslucee"];
	this.mappings["/contexts"] = "../contexts";
	this.mappings["/zeroauth"] = "./zero/plugins/auth2";
	this.mappings["/testbox"] = "../vendor/testbox";
	this.mappings["/tests"] = "../tests";
	this.mappings["/zeromodel"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "zeromodel";
	this.mappings["/zerotable"] = "./zero/plugins/zerotable";
	this.mappings["/zerointegrate"] = "./zero/plugins/integrate";
	this.mappings["/zeromigrate"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "migrate";
	this.mappings["/zeroevent"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "event";
	this.mappings["/zerotask"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "task";
	this.mappings["/zeroaudit"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "audit";
	this.mappings["/zeroadmin"] = getDirectoryFromPath(getCurrentTemplatePath()) & "plugins" & server.separator.file & "zeroadmin";
	// this.mappings["/zero"] = "./zero";

	// writeDump(getDirectoryFromPath(getCurrentTemplatePath()));
	// writeDump(expandPath("/framework-zero/zero/_vendor/handlebarslucee"));
	// writeDump(expandPath("/zero/_vendor/handlebarslucee"));
	// this.customTagPaths = [expandPath("/zero/_vendor/handlebarslucee")];

	copyCGI = duplicate(CGI);



	/*
	Global framework rewrite of the request scope. Allows mimicing HTML 5
	nested form feature, which is not currently supported by Internet Explorer.
	Will introspect the form data and override the copied CGI information
	with the route in the form so what fw/1 routes pick the intended controller
	 */
	if(structKeyExists(form,"zero_form")){
		zeroForms = listToArray(form.zero_form);
		for(zeroFormName in zeroForms){
			if(structKeyExists(form,zeroFormName)){
				formgroup = duplicate(form[zeroFormName]);
				if(structKeyExists(formgroup,"submit")){
					actionPathInfo = replaceNoCase(formgroup.action, copyCGI.SCRIPT_NAME, "");
					copyCGI.path_info = actionPathInfo;
					copyCGI.request_method = formgroup.method;

					originalForm = duplicate(form);
					structClear(form);
					structAppend(form,formgroup.data);
					if(formgroup.preserveParentInputs){
						structAppend(form, originalForm);
					}
				}
			}
		}
	}

	//In order to support Zero's more advanced FORM
	//deserialization, we remove all of Lucee's struct
	//and array form items from the form. This is so that
	//we do not get any conflicts when we later work with the
	//form keys
	request.newForm = {}
	for(item in form){

		if(isStruct(form[item]) OR isArray(form[item])){

		} else {
			request.newForm[item] = form[item];
		}
	}

	structClear(form);
	for(item in request.newForm){
		form[item] = request.newForm[item];
	}

     request._fw1 = {
        cgiScriptName = replaceNoCase(copyCGI.SCRIPT_NAME,".json",""),
        cgiPathInfo = replaceNoCase(copyCGI.PATH_INFO,".json",""),
        cgiRequestMethod = copyCGI.REQUEST_METHOD,
        controllers = [ ],
        requestDefaultsInitialized = false,
        routeMethodsMatched = { },
        doTrace = false,
        trace = [ ]
    };


    request._zero.PathInfo = copyCGI.path_Info;
	request._zero.ContentType = listLast(request._zero.PathInfo,".");
	request._zero.errorLog = [];

	switch(lcase(request._zero.ContentType)){
		case "json":
			request._zero.contentType = "json";
		break;

		default:
			request._zero.contentType = "html";
		break;
	}

	this.clientManagement = true;
	this.clientStorage = "cookie";
	this.scriptProtect = "all";

	/*
		This is provided for illustration only - YOU SHOULD NOT USE THIS IN
		A REAL PROGRAM! ONLY SPECIFY THE DEFAULTS YOU NEED TO CHANGE!
	variables.framework = {
		// the name of the URL variable:
		action = 'action',
		// whether or not to use subsystems:
		usingSubsystems = false,
		// default subsystem name (if usingSubsystems == true):
		defaultSubsystem = 'home',
		// default section name:
		defaultSection = 'main',
		// default item name:
		defaultItem = 'default',
		// if using subsystems, the delimiter between the subsystem and the action:
		subsystemDelimiter = ':',
		// if using subsystems, the name of the subsystem containing the global layouts:
		siteWideLayoutSubsystem = 'common',
		// the default when no action is specified:
		home = defaultSubsystem & ':' & defaultSection & '.' & defaultItem,
		-- or --
		home = defaultSection & '.' & defaultItem,
		// the default error action when an exception is thrown:
		error = defaultSubsystem & ':' & defaultSection & '.error',
		-- or --
		error = defaultSection & '.error',
		// the URL variable to reload the controller/service cache:
		reload = 'reload',
		// the value of the reload variable that authorizes the reload:
		password = 'true',
		// debugging flag to force reload of cache on each request:
		reloadApplicationOnEveryRequest = false,
		// whether to force generation of SES URLs:
		generateSES = false,
		// whether to omit /index.cfm in SES URLs:
		SESOmitIndex = false,
		// location used to find layouts / views:
		base = ... relative path from Application.cfc to application files ...
		// either CGI.SCRIPT_NAME or a specified base URL path:
		baseURL = 'useCgiScriptName',
		// location used to find controllers / services:
		// cfcbase = essentially base with / replaced by .
		// list of file extensions that FW/1 should not handle:
		unhandledExtensions = 'cfc',
		// list of (partial) paths that FW/1 should not handle:
		unhandledPaths = '/flex2gateway',
		// flash scope magic key and how many concurrent requests are supported:
		preserveKeyURLKey = 'fw1pk',
		maxNumContextsPreserved = 10,
		// set this to true to cache the results of fileExists for performance:
		cacheFileExists = false,
		// change this if you need multiple FW/1 applications in a single CFML application:
		applicationKey = 'framework.one',
        // change this if you want a different dependency injection engine:
        diEngine = 'di1',
        // change this if you want different locations to be scanned by the D/I engine:
        diLocations = 'model,controllers',
        // optional configuration for your dependency injection engine:
        diConfig = { },
        // routes (for fancier SES URLs) - see the documentation for details:
        routes = [ ],
        routesCaseSensitive = true
	};
	*/
	variables.framework = {
		reloadApplicationOnEveryRequest = true,
		defaultItem = "list",
		usingSubsystems:false,
		SESOmitIndex = true,
		generateSES = true,
		//Enable subsystems for framework-zero
		usingSubsystems = true,

		//Set the base location to /contexts
		base = "/contexts",
		//Set the default subsystem to home
		defaultSubsystem = variables.zero.defaultSubsystem?:"home"
	}

	variables.zero.argumentModelValueObjectPath = "model";
	variables.zero.throwOnFirstArgumentError = variables.zero.throwOnFirstArgumentError ?: false;

	variables.framework.resourceRouteTemplates = [
	  { method = 'validate', httpMethods = [ '$POST' ], routeSuffix = '/validate' },

	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'list', httpMethods = [ '$POST' ], routeSuffix = '/list' },
	  { method = 'list', httpMethods = [ '$GET' ], routeSuffix = '/list' },

	  { method = 'new', httpMethods = [ '$POST' ], routeSuffix = '/new' },
	  { method = 'new', httpMethods = [ '$GET' ], routeSuffix = '/new' },

	  { method = 'edit', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/edit' },
	  { method = 'edit', httpMethods = [ '$GET' ], includeId = true, routeSuffix = '/edit' },

	  { method = 'create', httpMethods = [ '$POST' ], routeSuffix = '/create' },
	  { method = 'create', httpMethods = [ '$POST' ] },

	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true , routeSuffix = '/read'},
	  { method = 'read', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/read' },

	  { method = 'update', httpMethods = [ '$PUT','$POST' ], includeId = true },
	  { method = 'update', httpMethods = [ '$PUT','$POST' ], includeId = true, routeSuffix = '/update' },

	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/delete' },

	];

	/*
	Disable CFC remoting. This is not necessary for a zero application
	 */
	public void function onCFCRequest(string cfcName, string methodName, struct args) {
		echo('<html><body></body></html>');
	}

	public function collectValues(required struct args){
		out = {};
		for(var arg in args){

			if(!isNull(args[arg])){
				if(isInstanceOf(args[arg], "valueObject")){
					out[arg] = args[arg].toString();
				} else {
					out[arg] = args[arg];
				}
			}
		}
		return out;
	}

	public function after( rc, headers, controllerResult ){
		writeLog(file="zero_trace", text="start after()");
		// writeDump(request._zero.controllerResult);
		if(isNull(request._zero.controllerResult)){
			if(variables.zero.throwOnNullControllerResult){
				throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
			}
		}

		logRequest();

		//If the user's Application CFC has the request method, then we call it
		if(structKeyExists(this,"result")){
			request._zero.controllerResult = result( controllerResult );
		}

		if(isComponentOrArrayOfComponents(request._zero.controllerResult)){
			try {
				request._zero.controllerResult = entityToJson(request._zero.controllerResult)
			}catch(any e){
				writeDump(request._zero.controllerResult);
				writeDump(e);
				abort;
			}
		}

		/*
		Transfers data from a view to another view. In the default use, this bypasses
		having to send data through a controller. The controller can also return a view_state
		variable which takes precedence over the view_state passed from a view
		 */
		if(form.keyExists("view_state")){
			if(request._zero.controllerResult.keyExists("view_state")){
				var newStruct = duplicate(form.view_state);
				structAppend(newStruct, request._zero.controllerResult.view_state, true);
				request._zero.controllerResult.view_state = newStruct;
			} else {
				request._zero.controllerResult.view_state = form.view_state;
			}

			//View state should only persist for the life
			//of one request (or redirect). IF the user refreshes
			//their browser then the view_state is lost (as it represents
			//the state for one 'view').
			if(getCGIRequestMethod() == "GET"){
				if(request._zero.keyExists("zeroFormState")){
					var stateData = request._zero.zeroFormState.getFormData();
					structDelete(stateData,"view_state");
					request._zero.zeroFormState.setFormData(stateData);
				}
				structDelete(form,"view_state");
			}
		}


		try {
			if(variables.zero.serializeControllerOutput){
				request._zero.controllerResult = this.serialize(request._zero.controllerResult);
			}
		}catch(any e){
			writeDump(request._zero.controllerResult);
			writeDump(e);
			abort;
		}

		var recurseAndLowerCaseTheKeys = function(struct){
			for(var key in arguments.struct){
				// arguments.struct["#lcase(key)#"] = arguments.struct[key];

				if(isNull(arguments.struct[key])){
					var temp = nullValue();
				} else {
					var temp = duplicate(arguments.struct[key]);
				}

				// if(!isNull(temp) and isComponentOrArrayOfComponents(temp)){
				// 	temp = this.serialize(temp);
				// 	// throw("Could not continue because the controller result is a component and not a simple array or struct. This could be an error in the data returned from the controller, or Zero was not able to serialize your result properly.");
				// }

				arguments.struct.delete(key);
				arguments.struct.insert("#lcase(camelToUnderscore(key))#", temp?:nullValue(), true);

				if(!isNull(arguments.struct[key]) AND isStruct(arguments.struct[key])){
					recurseAndLowerCaseTheKeys(arguments.struct[key]);
				}
			}
			return struct;
		}

		// recurseAndLowerCaseTheKeys(request._zero.controllerResult);
		structAppend(rc, client);
		// writeDump(rc);
		// abort;

		switch(request._zero.contentType){
			case "json":
				//If we are allowing null data, then we're going to putput an empty object
				if(isNull(request._zero.controllerResult)){
					renderData("json", {} );
				} else {
					renderData("json", request._zero.controllerResult);
				}
			break;

			default:
				if(request._zero.keyExists("zeroFormState")){
					if(CGI.request_method contains "POST"){

						if(request._zero.argumentErrors.isEmpty()){

							if(!request._zero.controllerResult.keyExists("success") OR (request._zero.controllerResult.keyExists("success") AND request._zero.controllerResult.success == true)){

								if(rc.keyExists("start_over")){
									request._zero.zeroFormState.start();
								} else if(rc.keyExists("first_step")){
									request._zero.zeroFormState.first();
								} else if(rc.keyExists("move_forward")){
									request._zero.zeroFormState.moveForward();
								} else if(rc.keyExists("move_backward")){
									if(rc.keyExists("clear_step_data")){
										request._zero.zeroFormState.moveBackward(clearStepData=true);
									} else {
										request._zero.zeroFormState.moveBackward();
									}
								} else if(rc.keyExists("clear_step_data")){
									request._zero.zeroFormState.clearStepData();
								} else if(rc.keyExists("start")){
									request._zero.zeroFormState.start();
								} else if(rc.keyExists("resume")){
									request._zero.zeroFormState.resume();
								} else if(rc.keyExists("complete_form")){
									request._zero.zeroFormState.completeForm();
								} else if(rc.keyExists("complete_step")){
									request._zero.zeroFormState.completeStep(rc.complete_step);
								}

								if(rc.keyExists("form_state_clear_form")){
									request._zero.zeroFormState.clearFormData();
								}
							}

						} else {

							if(rc.keyExists("on_failure")){
								if(rc.on_failure contains "clear_step_data"){
									request._zero.zeroFormState.clearStepData();
									// writeDump(request._zero.zeroFormState);
									// abort;
								}
							}
						}
					}
				}

				if(rc.keyExists("goto_fail")){
					if(request._zero.controllerResult.keyExists("success") and request._zero.controllerResult.success == false){
						rc.goto = rc.goto_fail;
						if(!form.keyExists("preserve_response")){
							form.preserve_response = true;
						}

						if(!request._zero.keyExists("zeroFormState")){
							form.preserve_request = true;
						}

						/*
						* 6/10/2020 : Not sure why this was commented out. It stops the preserve_form from working
						*/
						if(form.keyExists("preserve_form")){
							structDelete(form,"preserve_form");
						}
					}
				}

				/**
				 * If the result of the request was successful then we are not going to preserve form or
				 * display input values, which only apply when the form is unsuccessful
				 */
				if(
					cgi.request_method == "POST"
					and request._zero.controllerResult.keyExists("success")
					and request._zero.controllerResult.success
				){
					structDelete(form, "display_input_errors");
					structDelete(form, "preserve_form");
					structDelete(rc, "display_input_errors");
					structDelete(form, "display_input_values");
					structDelete(rc, "display_input_values");
					structDelete(rc, "preserve_form");
				}

				//Setup an alias to goto
				if(rc.keyExists("goto_after")){
					rc.goto = rc.goto_after;
				}

				if(rc.keyExists("goto")){

					if(structKeyExists(form,"map_response")){
						var maps = deserializeJson(form.map_response);
						for(var map in maps){
							for(var key in map){
								var result = evaluate("request._zero.controllerResult.#key#");
								var value = map[key];
								request._zero.controllerResult[value] = result;
							}
						}
					}

					if(structKeyExists(form,"preserve_response")){

						if(isJson(form.preserve_response)){
							form.preserve_response = deserializeJson(form.preserve_response);
						}

						if(isBoolean(form.preserve_response)){
							var prefix = "preserve_response";
						} else if(isSimpleValue(form.preserve_response) AND trim(form.preserve_response) == ""){
							var prefix = "preserve_response";
						} else if(isStruct(form.preserve_response)){
							var actions = form.preserve_response;
							/*
							User can specify the prefix used for the preserve_response
							 */
							if(actions.keyExists("prefix")){
								var prefix = "preserve_response.#actions.prefix#";
							} else {
								var prefix = "preserve_response";
							}

							/*
							User can specify that they only want specific
							keys out of the response returned to the view
							 */
							if(actions.keyExists("include_keys")){
								var newData = {};
								if(!isArray(actions.include_keys)){
									throw("Error processing request, the form submitted did not have the correct format for preserve response");
								}

								for(var key in actions.include_keys){
									if(request._zero.controllerResult.keyExists(key)){
										newData[key] = request._zero.controllerResult[key];
									}
								}
								request._zero.controllerResult = newData;
							}

							for(var action in actions){

								if(action == "map"){
									var newResult = {}
									var maps = actions[action];
									for(var map in maps){
										for(var key in map){
											var result = evaluate("request._zero.controllerResult.#key#");
											var value = map[key];
											newResult[value] = result;
										}
									}
									request._zero.controllerResult = newResult;
									var prefix = "preserve_response";
								}
							}
						}
						else {
							var prefix = "preserve_response.#form.preserve_response#";
						}
						// writeDump(prefix);

						var formKeys = createObject("zeroStructure").flattenDataStructureForCookies(data=request._zero.controllerResult, prefix=prefix, ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response");
						variables.zero.flashStorage.append(formKeys);

					}


					if(form.keyExists("preserve_form")){

						if(trim(form.preserve_form) == ""){
							form.preserve_form = true;
						}

						if(!isBoolean(form.preserve_form)){
							throw("preserve_form must either be true or false");
						}

						if(form.preserve_form){
							var formKeys = createObject("zeroStructure").flattenDataStructureForCookies(data=form, prefix="preserve_form", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response");
							variables.zero.flashStorage.append(formKeys);
						}
					}


					if(form.keyExists("preserve_request")){
						var formKeys = createObject("zeroStructure").flattenDataStructureForCookies(data=form, prefix="preserve_request.form", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
						variables.zero.flashStorage.append(formKeys);

						var formKeys = createObject("zeroStructure").flattenDataStructureForCookies(data=url, prefix="preserve_request.url", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
						variables.zero.flashStorage.append(formKeys);
					}

					var goto = rc.goto;
					rc = {}
					if(!isNull(request._zero.controllerResult)){
						for(var key in request._zero.controllerResult){
							rc[key] = request._zero.controllerResult[key];
						}
					}

					if(variables.zero.useAdvancedGotoVariable){

						if(goto contains "${"){
							//We are going to use the advanced variable replacement which is necessary for URLs which may contains
							//colons for other purposes
							var variable = this.extractAdvancedGotoVariable(goto);

							if(!isDefined("rc.#variable#")){
								// writeDump(goto);
								// writeDump(variable);
								// abort;
								throw("Goto value #variable# not found in result");
							} else {
								value = getVariable("rc.#variable#");
								goto = replaceNoCase(goto, "${#variable#}", value);
							}
						}

					} else if(goto contains ":"){
						// variable = reReplaceNoCase(goto, "(.*):([A-Zaz\.]*)", "\2");
						//2019-06-07: Update to allow characters after the variable string we are looking for

						var variable = this.extractGotoVariable(goto);

						if(!isDefined("rc.#variable#")){
							throw("Goto value #variable# not found in result");
						} else {
							value = getVariable("rc.#variable#");
							goto = replaceNoCase(goto, ":#variable#", value);
						}
					}

					// if(structKeyExists(client,"goto")){
					// 	structDelete(client,"goto");//Remove the goto so that it is not an infinite redirect
					// }

					// header name="Cache-Control" value="max-age=120";
					doTrace(rc, "RC after() redirect");
					doTrace(FORM, "FORM after() redirect");
					doTrace(cookie, "COOKIE after() redirect");
					writeLog(file="zero_trace", text="do after() redirect");

					// writeDump(now());
					// abort;
					request._zero.zeroClient.persist();
			        checkHeaderSize();
			        if(structKeyExists(this,"onGoto")){
			        	this.onGoto(goto);
			        }
					location url="#goto#" addtoken="false" statuscode="303";
				}

				/*
				To protect against XSS attacks in HTML output, we escape all strings that are the result from the controller
				 */
				if(variables.zero.encodeResultForHTML ){
					request._zero.controllerResult = encodeResultFor("HTML", request._zero.controllerResult);
				}
				// writeDump(request._zero.controllerResult);
				// abort;

				//Clear out the RC scope because only the result from the controller will be passed
				//to the view
				rc = {}
				if(!isNull(request._zero.controllerResult)){
					for(var key in request._zero.controllerResult){
						rc[key] = request._zero.controllerResult[key];
					}
				}

				// rc.client = client;
				if(request._zero.zeroClient.getValues().keyExists("client_state")){
					rc.client_state = request._zero.zeroClient.getValues().client_state;
				} else {
					rc.client_state = {};
				}

				if(request._zero.keyExists("zeroFormState")){
					// rc.form_state = recurseAndLowerCaseTheKeys(request._zero.zeroFormState.getFormCache());
					if(request._zero.zeroFormState.matchesUrl(cgi.path_info)){
						rc.form_state = this.serialize(request._zero.zeroFormState);
					}
				}

				if(!request._zero.argumentErrors.isEmpty()){
					rc.errors = request._zero.argumentErrors;
				}
				request.context = rc;
				request._zero.zeroClient.persist();
			break;
		}
		writeLog(file="zero_trace", text="end zero.after()");
		return controllerResult;
	}

	public function checkHeaderSize(){

		var basicHeaders = "Connection:Keep-Alive
							Content-Length:144
							Content-Type:text/html;charset=UTF-8
							Date:Wed, 13 Sep 2017 16:37:49 GMT
							Keep-Alive:timeout=5, max=100
							location:/secure/13DDC4FC06CB4A
							Server:Apache-Coyote/1.1";

		var Response = getPageContext().getResponse();
        var names = Response.getHeaderNames();

        var sizeOfBasicHeaders = sizeOf(basicHeaders);
        var sizeOfNames = sizeOf(names);
        var sizeOfHeaderValues = 0;
        var namesProcessed = [];

        //On some systems (commandBox Lucee) this appears to come as a hash
        //set. Convert this to an array before using
        if(isInstanceOf(names,"java.util.HashSet")){
        	var names = names.toArray();
        }
        for(var name in names){
        	if(arrayContainsNoCase(namesProcessed, name)){
        		continue;
        	}
            var headers = Response.getHeaders(name);
            sizeOfHeaderValues += sizeOf(headers);
            namesProcessed.append(name);
        }
        var totalSize = sizeOfBasicHeaders + sizeOfNames + sizeOfHeaderValues;
	}

	public function before( rc ){

		writeLog(file="zero_trace", text="start before()");
		doTrace(rc, "RC before()");

		request._zero.argumentErrors = {};
		request._zero.errorLog = [];

		request._zero.originalFormData = duplicate(form);
		request._zero.originalUrlData = duplicate(url);
		request._zero.originalCookieData = duplicate(cookie);

		if(variables.zero.logRequests == true and url.keyExists("showlog")){
			var data = new plugins.zerotable.model.arrayData(getRequestLog().reverse());
			var table = new plugins.zerotable.model.zerotable(rows=data);

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"time",
				isPrimary:true
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"method",
				columnType:{
					custom:true,
					output:function(row){
						return row.cgi.request_method
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"path",
				columnType:{
					custom:true,
					output:function(row){
						return row.cgi.request_url
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"error messages",
				columnType:{
					custom:true,
					output:function(row){
						var out = "";
						for(var error in row.errors){
							out = out & error._message & "<br />";
						}
						return out;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"error details",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.errors, expand=false);
						}
						return rowOut;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"rc",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.rc, expand=false);
						}
						return rowOut;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"result",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.result, expand=false);
						}
						return rowOut;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"FORM",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.form, expand=false);
						}
						return rowOut;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"URL",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.url, expand=false);
						}
						return rowOut;
					}
				}
			));

			table.addColumn(new plugins.zerotable.model.column(
				columnName:"CGI",
				columnType:{
					custom:true,
					output:function(row){

						savecontent variable="rowOut"{
							writeDump(var=row.cgi, expand=false);
						}
						return rowOut;
					}
				}
			));

			var tableData = table.toJson();
			// writeDump(tableDAta);
			// abort;

			savecontent variable="zerotableout" {
				module name="handlebars" context="#tableData#" {
					include template="/zero/plugins/zerotable/views/main/table.hbs";
				}
			}
			echo(zerotableout);
			abort;
		}

		// if(CGI.request_method == "POST"){
		// 	if(cookie.keyExists("CSRF_TOKEN")){
		// 		if(!form.keyExists("CSRF_TOKEN")){
		// 			throw("Unauthorized Request", 401);
		// 		} else {
		// 			if(form.csrf_token != cookie.csrf_token){
		// 				throw("Unauthorized Request", 401);
		// 			} else {
		// 			}
		// 		}
		// 		structDelete(cookie,"CSRF_TOKEN");
		// 	}
		// } else {
		// 	structDelete(cookie,"CSRF_TOKEN");
		// }

		/*
		**************************************
		**** PREVIOUS REQUEST SECTION ********
		**************************************
		This section of code restores values from the previous request
		before any redirects. This setups up our current request with any
		values which were supposed to be maintained between the redirects
		 */

		/*
		Cookie structures are saved as individual keys, so need to use
		the zeroStructure class to expand the cookies back into
		a regular structure and array
		 */

		var cookies = createObject("zeroStructure").init(duplicate(variables.zero.flashStorage)).getValues();
		/*
		User can reset the scroll position arbitraily. This might be used when
		the page position has not
		 */
		if(rc.keyExists("reset_scroll")){
			cookies.current_scroll = 0;
			cookies.current_height = 0;
			structDelete(rc,"reset_scroll");
			structDelete(url,"reset_scroll");
			structDelete(form,"reset_scroll");
		}

		/*
		Load any preserved from values from the prior request
		 */
		if(cookies.keyExists("preserve_form")){
			form.append(cookies.preserve_form);
			rc.Append(cookies.preserve_form);
			var deleteCookies = createObject("zeroStructure").flattenDataStructureForCookies(data=cookies.preserve_form, prefix="preserve_form", ignore=[]);
			for(var cook in deleteCookies){
				structDelete(variables.zero.flashStorage, cook)
				header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
			}
		}

		/*
		Load any preservered request values from the prior request.
		 */
		if(cookies.keyExists("preserve_request")){

			/*
			Load form values from the prior request
			 */
			if(cookies.preserve_request.keyExists("form")){
				form.append(cookies.preserve_request.form);
				rc.Append(cookies.preserve_request.form);
				var deleteCookies = createObject("zeroStructure").flattenDataStructureForCookies(data=cookies.preserve_request.form, prefix="preserve_request.form", ignore=[]);
				for(var cook in deleteCookies){
					header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
					structDelete(cookie,cook);
					structDelete(variables.zero.flashStorage, cook)
				}
			}

			/*
			Load URL values from the prior request
			 */
			if(cookies.preserve_request.keyExists("url")){
				url.append(cookies.preserve_request.url);
				rc.Append(cookies.preserve_request.url);
				var deleteCookies = createObject("zeroStructure").flattenDataStructureForCookies(data=cookies.preserve_request.url, prefix="preserve_request.url", ignore=[]);
				for(var cook in deleteCookies){
					header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
					structDelete(cookie,cook);
					structDelete(variables.zero.flashStorage, cook)
				}
			}
		}

		/*
		Load the preserve_response from the prior request.
		 */
		if(cookies.keyExists("preserve_response")){

			//Loop through each key in the preserve response and add it
			//to the form
			for(var key in cookies.preserve_response){

				if(isStruct(cookies.preserve_response[key])){
					if(!form.keyExists(key)){
						form[key] = {}
					}
					form[key].append(cookies.preserve_response[key]);

					if(!rc.keyExists(key)){
						rc[key] = {}
					}
					rc[key].append(cookies.preserve_response[key]);
				} else {
					form[key] = cookies.preserve_response[key];
					rc[key] =  cookies.preserve_response[key];
				}
			}

			var deleteCookies = createObject("zeroStructure").flattenDataStructureForCookies(data=cookies.preserve_response, prefix="preserve_response", ignore=[]);
			for(var cook in deleteCookies){
				// structDelete(cookie,cook);
				header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
				structDelete(cookie,cook);
				structDelete(variables.zero.flashStorage, cook)
			}
		}

		/*
		**************************************
		**** CURRENT REQUEST SECTION ********
		**************************************
		Now that the previous request persisted values have been loaded,
		we can begin handling the current request
		 */


		/*
		Checks if a button was ovarloading form values
		 */
		if(rc.keyExists("submit_overload")){
			if(!isJson(rc.submit_overload)){
				throw("The data in a form submit_overload must be json", "submitOverloadInvalidJson");
			}
			var json = deserializeJson(rc.submit_overload);
			for(var key in json){
				form[key] = json[key];
				rc[key] = json[key];
			}
		}

		if(rc.keyExists("form_state") and rc.keyExists("preserve_form")){
			throw("Do not use form_state and preserve_form together. Preserve form is for simple single step forms. Form state is for complex multi step forms.", "invalidFormStateCombination");
		}


		// for(var item in form.getRaw()){
		// 	writeDump({name:item.getName(), value:item.getValue()});
		// }
		// abort;
		// writeDump(form.getRaw()[1].getName());
		// writeDump(form.getRaw()[1].getValue());
		// abort;
		/*
		Checks if a form was intending to delete fields which are empty. This
		is important for arguments which should be optional AND NOT EMPTY. This
		is necessary because HTML forms will submit empty values.
		 */
		if(form.keyExists("delete_empty_fields")){

			if(isBoolean(form.delete_empty_fields)){

				for(var field in form){
					if(isDefined("form['#field#']") and isSimpleValue(form[field]) and getVariable("form['#field#']") == ""){
						form.delete(listFirst(field,"."));
						rc.delete(listFirst(field,"."));
						form.delete(listFirst(field));
						rc.delete(listFirst(field));
					}
				}
			} else {
				var fields = listToArray(form.delete_empty_fields);
				for(var field in fields){
					if(isDefined("form['#field#']") and isSimpleValue(form[field]) and getVariable("form['#field#']") == ""){
						writeDump(field);
						form.delete(listFirst(field,"."));
						rc.delete(listFirst(field,"."));
						form.delete(listFirst(field));
						rc.delete(listFirst(field));
					}
				}
			}
		}
		// writeDump(form);
		// abort;

		if(rc.keyExists("delete_key")){

			if(!isArray(rc.delete_key)){
				rc.delete_key = [rc.delete_key];
			}

			for(var key in rc.delete_key){
				structDelete(form, key);
				structDelete(rc, key);
				structDelete(client, key);
			}
		}

		if(rc.keyExists("delete_path")){

			var path = rc.delete_path;
			var pathsForm = createObject("zeroStructure").flattenDataStructureForCookies(duplicate(form));
			var pathsRc = createObject("zeroStructure").flattenDataStructureForCookies(duplicate(rc));
			for(var item in pathsForm){
				if(findNoCase(path, item) > 0){
					pathsForm.delete(item);
				}
			}

			for(var item in pathsRc){
				if(findNoCase(path, item) > 0){
					pathsRc.delete(item);
				}
			}

			var formValues = new zeroStructure(pathsForm).getValues();
			structClear(form); //Clear the form because setting it to new values does not appear to work
			for(var key in formValues){
				form[key] = formValues[key];
			}

			var rcValues = new zeroStructure(pathsRc).getValues();
			structClear(rc); //Clear the form because setting it to new values does not appear to work
			for(var key in rcValues){
				rc[key] = rcValues[key];
			}
		}

		/*
		Expand FORM parameters
			Uses the zeroStructure class to expand flattened
			form parameters into the full data structure.
		 */
		var formValues = new zeroStructure(form).getValues();
		structClear(form); //Clear the form because setting it to new values does not appear to work
		for(var key in formValues){
			form[key] = formValues[key];
		}

		//Expand the rc scope in case anything has been compressed
		rc = new zeroStructure(rc).getValues();

		//Set the new rc scope back into the request context which will be used elsewhere in the request
		request.context = rc;

		//Append anything in the client scope to the RC scope as this is also to be used for controller arguments
		for(key in client){
			if(!rc.keyExists(key)){
				if(!isNull(client[key])){
					rc[key] = client[key];
				}
			}
		}

		/*
		Load a zeroClient management class. The current behavior is to
		set client state into a cookie. Client state can be set by the
		view by using the client_state form field.
		 */
		request._zero.zeroClient = new zeroClient(cookie);

		/*
		User can flush the client_state
		 */
		if(rc.keyExists("clear_client")){
			request._zero.zeroClient.clear();
			request._zero.zeroClient.persist();
		}

		/*
		Add new client variables passed into the form scope into the client
		*/
		if(rc.keyExists("client_state")){
			var values = request._zero.zeroClient.getValues();
			if(!values.keyExists("client_state")){
				values.client_state = {};
			}

			for(var key in rc.client_state){
				if(trim(rc.client_state[key]) == ""){
					values.client_state.delete(key);
				} else {
					values.client_state.insert(key, rc.client_state[key], true);
				}
			}
			request._zero.zeroClient.persist();
		}

		//Copy any client variables into the RC scope
		var clientValues = duplicate(request._zero.zeroClient.getValues());
		for(var key in clientValues){
			if(!rc.keyExists(key)){
				if(!isNull(clientValues[key])){
					rc[key] = clientValues[key];
				}
			}
		}

		//Copy any client variables with client_state directly into the RC scope
		var clientValues = duplicate(request._zero.zeroClient.getValues());
		if(clientValues.keyExists("client_state")){
			for(var key in clientValues.client_state){
				if(!rc.keyExists(key)){
					if(!isNull(clientValues.client_state[key])){
						rc[key] = clientValues.client_state[key];
					}
				}
			}
		}


		/*
		When the request is a GET or a POST, and a form_state is requested,
		we need to load the form_state from the variables.zero.formStateStorage
		variable.

		When the request is a POST, we will also update the form_state with the
		posted form data
		 */
		if(rc.keyExists("form_state_name") and !rc.keyExists("form_state")){
			throw("Must provide a form_state contianing the steps along with a form_state_name");
		}

		if(cgi.request_method == "GET" OR cgi.request_method == "POST"){
			if(rc.keyExists("form_state")){
				var args = {
					steps:rc.form_state,
					// clientStorage:request._zero.zeroClient.getValues(),
					clientStorage:variables.zero.formStateStorage,
				}

				if(rc.keyExists("form_state_name")){
					args.name = rc.form_state_name;
				}

				request._zero.zeroFormState = new zeroFormState(argumentCollection=args);

				if(cgi.request_method == "POST"){
					request._zero.zeroFormState.setFormData(form);

					if(rc.keyExists("form_state_url")){
						// request.log.setUrl = true;
						request._zero.zeroFormState.setFormStateUrl(rc.form_state_url);
					}

				}

			} else {
				// request.log.loadFromStorage = true;
				if(variables.zero.formStateStorage.keyExists("form_state")){
					var args = {
						steps:variables.zero.formStateStorage.form_state,
						clientStorage:variables.zero.formStateStorage
					}

					if(variables.zero.formStateStorage.keyExists("form_state_name")){
						args.name = variables.zero.formStateStorage.form_state_name;
					}

					request._zero.zeroFormState = new zeroFormState(argumentCollection=args);
				}
			}
		}

		// request.log.stateStorage = variables.zero.formStateStorage;

		/*
		On GET requests, we want to rehydrate the rc and form scopes with the values
		from our form_state
		 */
		if(request._zero.keyExists("zeroFormState") and cgi.request_method == "GET"){
			var formData = request._zero.zeroFormState.getFormData();
			for(var key in formData){
				//Hack to deal with fw1 IDs in URL which can be
				//screwed up, so we don't want to overwrite this
				if(key == "id" and rc.keyExists("id")){
					continue;
				}
				form[key] = formData[key];
				rc[key] = formData[key];
			}
		}


		//Setup an alias for redirect, redirect was used by
		//prior versions of Zero
		if(rc.keyExists("goto_before")){
			rc.redirect = rc.goto_before;
		}

		if(rc.keyExists("redirect")){

			if(request._zero.keyExists("zeroFormState")){
				if(CGI.request_method contains "POST"){

					request._zero.zeroFormState.setFormData(form);

					if(rc.keyExists("start_over")){
						request._zero.zeroFormState.start();
					} else if(rc.keyExists("first_step")){
						request._zero.zeroFormState.first();
					} else if(rc.keyExists("move_forward")){
						request._zero.zeroFormState.moveForward();
					} else if(rc.keyExists("move_backward")){
						if(rc.keyExists("clear_step_data")){
							request._zero.zeroFormState.moveBackward(clearStepData=true);
						} else {
							request._zero.zeroFormState.moveBackward();
						}
					} else if(rc.keyExists("clear_step_data")){
						request._zero.zeroFormState.clearStepData();
					} else if(rc.keyExists("start")){
						request._zero.zeroFormState.start();
					} else if(rc.keyExists("resume")){
						request._zero.zeroFormState.resume();
						// abort;
					} else if(rc.keyExists("complete_form")){
						request._zero.zeroFormState.completeForm();
					} else if(rc.keyExists("complete_step")){
						request._zero.zeroFormState.completeStep(rc.complete_step);
					}

					if(rc.keyExists("form_state_clear_form")){
						request._zero.zeroFormState.clearFormData();
					}
				}
			}

			if(rc.keyExists("anchor")){
				rc.redirect = rc.redirect & "##" & rc.anchor;
			}

			if(rc.keyExists("preserve_key")){
				if(!isArray(rc.preserve_key)){
					rc.preserve_key = [rc.preserve_key];
				}
				for(var value in rc.preserve_key){
					cookie["preserve_#value#"] = rc[value];
				}
			}

			if(rc.keyExists("preserve_form")){
				var formKeys = createObject("zeroStructure").flattenDataStructureForCookies(data=form, prefix="preserve_form", ignore="delete_key,preserve_redirect,redirect,preserve_map,preserve_response,preserve_form,goto_before,goto,submit_overload");
				variables.zero.flashStorage.append(formKeys);
			}

			doTrace(rc, "RC before() redirect");
			doTrace(FORM, "FORM before() redirect");
			doTrace(cookie, "COOKIE before() redirect");
			writeLog(file="zero_trace", text="do before() redirect");
			request._zero.zeroClient.persist();
			if(structKeyExists(this,"onGoto")){
	        	this.onGoto(rc.redirect);
	        }
			location url="#rc.redirect#" addtoken="false" statuscode="303";
		}

		//If the user's Application CFC has the request method, then we call it
		if(structKeyExists(this,"request")){
			try {
				request( rc );
			} catch(any e){
				if(structKeyExists(this,"onFailure")){
					//logRequest();
					this.onFailure(e, "Application.cfc:request()");
				} else {
					rethrow;
				}
			}
		}

	}

	public function buildURL(value="."){
		var value = super.buildURL(value);
		value = replaceNoCase(value,":","/");
		return value;
	}

	 /**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	function camelToUnderscore(str) {
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }
		return trim(rtnStr);
	}

	/*
	Empties the error log that zero uses to collect
	request errors
	 */
	public void function clearRequestLog(){
		fileWrite("zero_requests.json", "[]");
	}

	/*
	Implements the Zero Scroll maintainer feature. This feature will maintain
	the users scroll position as long as the URL they return to is the same as when it
	was last set. This keeps their position on the screen identical between redirects

	2021-02-07: Had to update all .append() items to work off the inner array element
	presumable because this interferres with Lucee 5 array.append() method
	 */
	public string function decorateOutputWithScrollPosition(required string output){
		var getBaseResourcePath = function(path){
			var resourcePath = path;
			//Remove /show because it is is not a path worth tracking
			resourcePath = replaceNoCase(resourcePath,"/show", "");

			if(right(resourcePath, 1) == "/" and len(resourcePath) > 1){
				resourcePath = left(resourcePath, len(resourcePath) - 1);
			}
			return resourcePath;
		}

		var jsoup = getJsoup();
		var htmlDoc = jsoup.parse(arguments.output);

		var head = htmlDoc.select("head");

		var pathInfo = CGI.path_info;
		var pathInfo = replaceNoCase(pathInfo, "/read","");
		var pathInfo = replaceNoCase(pathInfo, "/list","");
		var pathInfo = replaceNoCase(pathInfo, "/show","");

		if(cookie.keyExists("LAST_SCROLL_LOCATION") and cookie.LAST_SCROLL_LOCATION == "/"){
			var lastLocation = "";
		} else {
			var lastLocation = cookie.LAST_SCROLL_LOCATION?:0;
		}

		if(cookie.keyExists("current_height") AND getBaseResourcePath(pathInfo) == lastLocation or getBaseResourcePath(pathInfo) & "/" == lastLocation){
			var html = htmlDoc.select("html");
			html.attr('style', 'min-height:#cookie.current_height#px; background-color:#variables.zero.scrollPositionBackgroundColor?:'white'#;');
			head[1].append('<script type="text/javascript">
					window.scrollTo({top:"#cookie.current_scroll?:0#", behavior: "instant"});
				</script>');
		}

		var body = htmlDoc.select("body");
		body[1].append('<script type="text/javascript">
			window.addEventListener("scroll", function(){

				document.cookie = "CURRENT_SCROLL=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
				document.cookie = "CURRENT_HEIGHT=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
				document.cookie = "LAST_SCROLL_LOCATION=" + window.location.pathname.replace("/show", "").replace("/read", "").replace("/list","") + "; expires=Thu, 01 Jan 1970 00:00:00 UTC";

				setTimeout(function(){
					document.cookie = "CURRENT_HEIGHT=" + Math.max($(document).height(), $(window).height()) + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/; domain=#cgi.server_name#";
					document.cookie = "CURRENT_SCROLL=" + $(window).scrollTop() + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/; domain=#cgi.server_name#";
					document.cookie = "LAST_SCROLL_LOCATION=" + window.location.pathname.replace("/show", "").replace("/read", "").replace("/list","") + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/; domain=#cgi.server_name#";
				}, 50);
			});
		</script>');
		return htmlDoc.toString();
	}

	public function extractGotoVariable(required string goto){
		var variable = reReplaceNoCase(arguments.goto, "(.*):([A-Zaz\._]*)([\/ ])?(.*)", "\2");
		return variable;
	}

	public function extractAdvancedGotoVariable(required string goto){
		var variable = reReplaceNoCase(arguments.goto, "(.*)\${([A-Zaz\._]*)}([\/ ])?(.*)", "\2");
		return variable;
	}

	public function decorateFormWithErrors(required string output, required string formId, required struct response){
		var jsoup = getJsoup();
		var htmlDoc = jsoup.parse(arguments.output);
		var formDoc = htmlDoc.select("form[id=#arguments.formId#]");

		/*
		The default form error decorator, which is designed to work with Bootstrap 3
		form groups. This can be overriden by the user by specifying a new
		decorator function
		 */
		request.formErrorDecorator = request.formErrorDecorator?:function(input, formDoc, htmlDoc, error){
			var formGroup = input.parent();
			formGroup.addClass('has-error');
			var labelSelector = 'label[for=#input.attr('name')#]';
			var label = formGroup.select(labelSelector);
			if(arrayLen(label) > 0){
				if(error.keyExists("message")){
					label[1].append(' - <span class="text-danger">#error.message#</span>');
				}
			}
		}

		var inputs = formDoc.select("input,select");

		for(var input in inputs){
			var inputName = listFirst(input.attr('name'),".");
			if(input.attr('type') != 'hidden'){
				if(response.keyExists("errors") and arguments.response.errors.errors.keyExists(inputName)){
					request.formErrorDecorator(input, formDoc, htmlDoc, response.errors.errors[inputName]);
				}
			}
		}
		return htmlDoc.toString();
	}

	/**
	 * Decorates HTML routes (links and forms) with the permissions that the user has available
	 *
	 * @response The HTML string we will decorate
	 * @User The Auth user with permissions that we will check
	 */
	public function decorateNotPermittedHtmlRoutes(
		required string response,
		required User User,
		required Account Account,
		function decorateFormButton,
		function decorateLink,
		function decorateAuthorize
	){

		var response = arguments.response;
		var User = arguments.User;
		var Account = arguments.Account;
		var jsoup = this.getJsoup();
		var htmlDoc = jsoup.parse(response);

		var timezone = User.getTimezone();
		var locale = User.getLocale();

		//USERTIME - Convert times in the application to users local time
		var userTimes = htmlDoc.select('usertime');
		for(var userTime in userTimes){
			var time = userTime.html();
			if(isDate(time)){
			// dateTimeFormat(dateTime)
				var date = createDateTime(year(time), month(time), day(time), hour(time), minute(time), second(time));
				userTime.html(lsDateTimeFormat(date, "mm/dd/yyyy HH:nn TT zz", locale.toString(), timezone.toString()));
			}
		}

		// Get the subsystems that are allowed for the application
		// We will use these to bypass removing links and buttons that
		// are not part of the authentication mechanism. This was added
		// 2023-11-6 because one of the applications had routes created for
		// a subsystem that was not part of the authentication mechanism (home).
		// Prior to we assumed that those resources would have never been added
		var AuthBootrap = this.getAuthBootstrap();
		var allowedSubsystems = AuthBootrap.getSubsystems();

		//TODO
		// - Handle hrefs that are javascript or anchors
		// - Handle buttons formAction and formMethod

		//DISABLE LINKS & BUTTONS
		// var links = htmlDoc.select('a');
		var forms = htmlDoc.select('form:has(button)');

		formLoop: for(var htmlForm in forms){

			var action = htmlForm.attr('action');
			var method = htmlForm.attr('method');
			var resourcePath = this.getResourcePath(action, method);
			var resource = lcase(resourcePath.action);

			// Check if the resource is an allowed subsystem and if so, skip it
			for(var subsystem in allowedSubsystems){
				var subsystemName = listFirst(resource, ":");
				if(compareNoCase(subsystemName, subsystem) == 0){
					continue "formLoop";
					// var resource = replaceNoCase(resource, subsystemName, allowedSubsystems[subsystem]);
				}
			}

			// When the application does not have the resource, we skip it because
			// it is not a resource that is part of the authentication mechanism
			if(!applicationHasResources(resource)){
				continue "formLoop";
			}

			// writeDump(action);
			// writeDump(pathAction);
			var buttons = htmlForm.select('button,input[type=submit]');
			for(var button in buttons){
				var formAction = button.attr('formAction');
				if(formAction != ""){
					var resource = lcase(this.getResourcePath(formAction, method).action);
				} else {
					var resource = lcase(this.getResourcePath(action, method).action);
				}
				// abort;
				// writeDump(this.serialize(User.getResources()));
				// abort;
				if(!applicationHasResources(resource) OR resource == "auth:logins.delete"){
					continue;
				}

				if(resource contains "bulkcreate"){

				}

				if(!User.getIsSuperUser() and !User.hasPermission(lcase("#Account.getId()#::#resource#"))){

					if(arguments.keyExists("decorateFormButton")){
						arguments.decorateFormButton(
							button = button,
							resource = resource
						)
					} else {
						// button.remove();
						// button.addClass('hidden');
						button.attr('disabled', true);
						button.attr('data-toggle','tooltip');
						button.attr('data-placement','left');
						button.attr('title','You must be an organization admin for this feature');
					}
				}
			}
			// writeDump(User.hasPermission(lcase("#this.getAgency().getZeroAuthAccount().getId()#::#resource#")));
		}

		var links = htmlDoc.select('a');
		linkLoop: for(var link in links){
			var action = link.attr('href');
			// reReplaceNoCase(String, reg_expression, substring)
			var method = "get";
			var resourcePath = this.getResourcePath(action, method);
			var resource = lcase(resourcePath.action);

			// Check if the resource is an allowed subsystem and if so, skip it
			for(var subsystem in allowedSubsystems){
				var subsystemName = listFirst(resource, ":");
				if(compareNoCase(subsystemName, subsystem) == 0){
					continue "linkLoop";
					// var resource = replaceNoCase(resource, subsystemName, allowedSubsystems[subsystem]);
				}
			}
			// if(action == "/auth/logout"){
			// 	writeDump(this.getResourcePath(action, method));
			// 	var routeMatch = processRoutes( action, variables.framework.routes, method );
			// 	writeDump(routeMatch);
			// 	writeDump(resource);
			// 	writeDump(action);
			// 	writeDump(variables.framework.routes);
			// 	abort;
			// }

			// When the application does not have the resource, we skip it because
			// it is not a resource that is part of the authentication mechanism
			if(!applicationHasResources(resource) OR resource == "auth:logins.delete"){
				// writeDump(resource);
				// writeDump(action);
				continue "linkLoop";
			}

			if(!User.getIsSuperUser() and !User.hasPermission(lcase("#Account.getId()#::#resource#"))){
				if(arguments.keyExists("decorateLink")){
					arguments.decorateLink(
						link = link,
						resource = resource
					)
				} else {
					// link.remove();
					link.addClass('hidden text-muted');
					// link.attr('style','pointer-events:none;');
					link.attr('href','##');
					link.attr('data-toggle','tooltip');
					link.attr('data-placement','top');
					link.attr('title','You must be an admin for this feature');
				}
			}
		}

		var permissionElements = htmlDoc.select('[authorize]');
		// writeDump(authorize);
		for(var element in permissionElements){

			var resource = element.attr('authorize');

			if(!applicationHasResources(resource) OR resource == "auth:logins.delete"){
				continue;
			}

			if(!User.getIsSuperUser() and !User.hasPermission(lcase("#Account.getId()#::#resource#"))){
				if(arguments.keyExists("decorateAuthorize")){
					arguments.decorateAuthorize(
						authorize = element
					)
				} else {
					element.addClass('hidden');
					element.attr('style','display:none;');
				}
			}
		}
		response = htmlDoc.toString();
		return response;
	}

	/**
	 * Takes a href or form action path route and http method and determines
	 * which zero PathAction matches that route. These lookups are cached
	 * for subsequent requests. This is a kind of index to map URLs in the HTML
	 * to the action (like home:main.list) so that we can later check if that
	 * URL is permitted.
	 *
	 *
	 * @path A URL path that we want to check find the route for
	 * @method the HTTP method for the URL
	 */
	public function getResourcePath(path, method){
		if(url.keyExists("clearResourcePaths") and !request.keyExists("isClearingResourcePaths")){
			request.isClearingResourcePaths = true;
			application.resourcePaths = {};
		}
		application.resourcePaths = application.resourcePaths?:{};

		// abort;
		/*
		2020-02-18 - Fix performance issues with checking URL routes.
			I discovered while testing that looking up this function takes about 15ms for each route lookup
			that is unique. The uniqueness was coming from the query string and from different IDs passed into the
			URL. However, the controllers are not resolved via query strings and we do not need to resolve the route
			for each ID, but just the general route. As such we remove the query string and we rewrite all ids
			to '1'. Then when we look up the route, a lot few unique lookups are required. This shaves off about
			300ms per request and should also reduce memory usage of this function by 90%
		*/

		//Remove the query string after the path because it has no impact on the authentication
		var path = listFirst(path,"?");
		//Replace all instances /route/xxxx with 1 so that all lookups to various
		//ids more quickly resolve to the correct route
		var path = reReplaceNoCase(path, "/[0-9]*$", "/1");
		var path = reReplaceNoCase(path, "/[0-9]*/", "/1/");

		var key = "$#arguments.method##path#";
		// writeDump(arguments);
		// writeDump(key);
		// writeDump(application.resourcePaths);
		// abort;
		if(application.resourcePaths.keyExists(key)){
			return application.resourcePaths[key];
		} else {
			application.resourcePaths[key] = this.getPathAction(pathInfo=arguments.path, cgiRequestMethod=arguments.method);
			return application.resourcePaths[key];
		}
	}

	/**
	 * Utility function to check if this application has the provided
	 * Auth Resource name. They are cached in the application scope
	 * so that the lookup is faster after they have been loaded
	 *
	 * @resource The resource string to lookup, like home:main.list
	 */
	public boolean function applicationHasResources(required string resource){
		if(!isArray(arguments.resource)){
			var resourceTests = listToArray(arguments.resource);
		} else {
			var resourceTests = arguments.resource;
		}

		if(!isDefined("application.resourceNames") or (url.keyExists("clearResourceNames") and !request.keyExists("isCleaingResourceNames")) ){
			lock scope="application" type="exclusive" timeout="20" {
				request.isCleaingResourceNames = true;
				application.resourceNames = {}
				var resources = this.getZeroAuth().getResources();
				for(var resource in resources){
					application.resourceNames[resource.getName()] = true;
				}
			}
		}


		for(var res in resourceTests){
			// if(res == "appuser:appuser.update"){
			// 	writeDump(res);
			// 	writeDump(application.resourceNames.keyExists(res));
			// 	writeDump(application.resourceNames);
			// 	abort;
			// }
			if(!application.resourceNames.keyExists(res)){
				return false;
			}
		}
		return true;
	}

	/*
	Takes a component metadata object and recurses through the extends
	attribute and collects all of the base object functions together. This is
	needed by code which wants to inspect controller functions which have
	extended other controllers. (like the auth bootstrap)
	 */
	public function getAllExtendedFunctions(required struct metaData){
		var getFunctions = function(metaData){
			return arguments.metaData.functions?:[];
		}

		var recurseGetFunctions = function(metaData){
			var functions = getFunctions(arguments.metaData);
			if(metaData.keyExists("extends")){

				var parentFuncs = recurseGetFunctions(arguments.metaData.extends);
				for(var parent in parentFuncs){

					var parentMatches = false;
					for(var func in functions){

						if(func.name == parent.name){
							parentMatches = true;
							break;
						}
					}

					if(!parentMatches){
						functions.append(parent);
					}
				}
			}
			return functions;
		}
		return recurseGetFunctions(arguments.metaData);
	}

	public function IsZeroAdminEnabled(){
		return variables.zero.IsZeroAdminEnabled;
	}

	public zeroClient function getZeroClient(){
		return request._zero.zeroClient;
	}

	private boolean function controllerHasFunction(cfc, funcName){

		var meta = getMetaData(cfc);
		var functions = getAllExtendedFunctions(meta);
		for(var func in functions){
			if(func.name == funcName){
				return true;
			}
		}

		return false;
	}

	public function appendRoute(required struct route){
		variables.framework.routes.append(arguments.route);
	}

	public function createFormState(required string steps, name, clientStorage={}){
		request._zero.zeroFormState = new zeroFormState(argumentCollection=arguments);
		return request._zero.zeroFormState;
	}

	public function deserializeObject(){

	}

	function recurseFindCFCArguments(any data, component cfc, method="init", errors={}, forceArgumentCollection=false, path={}){

		var out = {}
		var args = getMetaDataFunctionArguments(cfc, method);
		var cfcName = getMetaData(cfc).name.listLast(".");
		structInsert(arguments.path, cfcName, {});
		var data = data;
		var cfc = arguments.cfc;

		cfmltypes = [
			"any",
			"array",
			"binary",
			"boolean",
			"component",
			"date",
			"datetime",
			"guid",
			"numeric",
			"query",
			"string",
			"struct",
			"uuid",
			"variableName",
			"void",
		];

		var isArrayType = function(string type){
			return right(type, 2) == "[]";
		}

		var getArrayType = function(string type){
			return left(type, len(type) - 2);
		}

		var addError = function(name, value, subErrors, originalError){

			if(variables.zero.throwOnFirstArgumentError){

				writeDump("Zero encountered an error in trying to popluate the values");
				writeDump(arguments);
				writeDump(arguments.originalError);
				// writeDump(arguments.error);
				// writeDump(componentPath);
				writeDump(cfcName);
				writeDump(args);
				writeDump(data);
				writeDump(callStackGet());
				abort;
			} else {

				if(structKeyExists(this,"onFailure")){

					if(!isDefined("originalError")){
						writeDump(callStackGet());
						abort;
					}

					logRequest();
					this.onFailure(originalError, "controllerArgument");
				}

				request._zero.errorLog.append(arguments.originalError);

				errors.insert("action_string", request.action, true);
				var actionOut = {"#getSubsystem()#":{
						"#getSection()#":{
							"#getItem()#":true
						}
					}
				}
				errors.insert("action", actionOut, true);
				if(arguments.keyExists("subErrors")){
					arguments.value.sub_errors = arguments.subErrors;
					arguments.value.append(arguments.subErrors);
				}

				//Put the actual errors into a sub structure for backwards compatability
				//with code which expected errors in the top level, and code which is going
				//to need to use the action structure
				if(!errors.keyExists("errors")){
					errors.errors = {};
				}
				errors.errors.insert(arguments.name, arguments.value);
				var expand = new zeroStructure({"#originalError.type#":true}).getValues();
				// try {
				// }catch(any e){
				// 	writeDump(e);
				// 	abort;
				// }
				// writeDump(expand);
				// errors.errors[arguments.name]
				errors.errors[arguments.name].append(expand);
				errors.errors[arguments.name]["type"] = originalError.type;

				errors.insert(arguments.name, errors.errors[arguments.name]);
				// if(variables.zero.useLegacyErrorsStruct){
				// }
				// writeDump(errors);
				// abort;
			}

		}

		var isCFMLType = function(type){
			var find = cfmlTypes.findNoCase(type);
			if(find > 0){
				return true;
			} else {
				return false;
			}
		}

		var isEntityType = function(required string type){
			// 2023-11-12: Update this for Ortus Hibernate 5 and Lucee 5.4
			// On version 5, how we detect the meta data classes is different
			var version = createObject("java", "org.hibernate.Version").getVersionString();
			var versionMajor = listFirst(version, ".");
			if(versionMajor == 5){
				var Factory = ORMGetSession().getSessionFactory();
				var EntityNames = Factory.getMetaModel().getAllEntityNames();
				var found = false;
				for(var name in EntityNames){
					if(lcase(name) == lcase(arguments.type)){
						found = true;
						break;
					}
				}
				return found;
			} else {
				var ORMSession = ORMGetSessionFactory();
				var meta = ORMSession.getAllClassMetaData();
				var keysOut = {}
				for(var key in meta){
					keysOut[lcase(key)] = true;
				}
				return structKeyExists(keysOut,lcase(arguments.type));
			}
			// try {


			// 	// writeDump(version.getVersionString());
			// 	// writeDump(server);



			// } catch(any e){
			// 	writeDump(e);
			// 	abort;
			// 	try {
			// 		try {
			// 			entityNew(arguments.type)
			// 		} catch(any e){
			// 			if(e.message == "ORM is not enabled"){
			// 				return false;
			// 			} else {
			// 				throw(e);
			// 			}
			// 		}
			// 		return true;
			// 	}catch(any e){
			// 		if(e.message contains "No entity (persitent component) with name"){
			// 			return false;
			// 		} else {
			// 			writeDump(e);
			// 			abort;
			// 		}
			// 	}
			// }
		}

		var tryComplexObject = function(name, type, data){

			if(structKeyExists(cfc, "createPackageObject")){
				try {
					var newCfc = cfc.createPackageObject(arguments.type);

					var subErrors = {};
					var newArgs = recurseFindCFCArguments(data=arguments.data, cfc=newCfc, errors=subErrors, path={});

					if(!subErrors.isEmpty()){

						try {
							throw("Found error while trying to instantiate #componentPath#", "controllerArgument");
						}catch(any e){
							addError(arguments.name, {message:"Enountered errors while trying to populate #arguments.name#", original_value:arguments.data}, subErrors, e);
							return;
						}
					}

					if(isNull(newArgs)){
						return;
					} else {
						var newCfc = newCfc.init(argumentCollection=newArgs);
						if(isNull(newCfc)){
							throw("Zero encountered an error while initializing an argument object 'componentPath'. The init() function did not return an instance of itself.");
						}
						return newCfc;
					}

				} catch(any e){
					addError(arguments.name, {message:e.message, original_value:arguments.data}, subErrors?:{}, e);
					return;
				}
			}

			var filePaths = [
				{
					file:expandPath("/zero/validations/#arguments.type#.cfc"),
					com:"zero.validations.#arguments.type#"
				},
				{
					file:expandPath("/#variables.zero.argumentModelValueObjectPath#/#arguments.type#.cfc"),
					com:"#variables.zero.argumentModelValueObjectPath#.#arguments.type#"
				},
				{
					file:expandPath("/validations/#arguments.type#.cfc"),
					com:"validations.#arguments.type#"
				},
				{
					file:expandPath("/zeroauth/model/#arguments.type#.cfc"),
					com:"zeroauth.model.#arguments.type#"
				},
				{
					file:expandPath("/zeroadmin/model/#arguments.type#.cfc"),
					com:"zeroadmin.model.#arguments.type#"
				},
				{
					file:expandPath("/zerotask/model/#arguments.type#.cfc"),
					com:"zerotask.model.#arguments.type#"
				},
				{
					file:expandPath("/#replaceNoCase(arguments.type, ".", "/", "all")#.cfc"),
					com:"#arguments.type#"
				},
			];


			// writeDump(filePaths);
			if(variables.zero.keyExists("validationPaths")){
				for(var path in duplicate(variables.zero.validationPaths)){
					path.file = path.file.replaceNoCase("*", arguments.type);
					path.com = path.com.replaceNoCase("*", arguments.type);
					filePaths.append(path);
				}
			}

			// writeDump(variables.zero.validationPaths);
			// abort;

			var componentPath = nullValue();
			for(var path in filePaths){
				try {

					//Guard assertion to load the meta data for the component. If the component
					//doesn't exist (or can't be parsed) this will fail. If it succeeds it will
					//set componentPath which is used later and break out of the loop
					// writeDump(path.com);
					getComponentMetaData(path.com);
					componentPath = path.com;
					break;
				} catch(any e){
					if(e.message contains "invalid component definition, can't find component"){
						continue;
					} else {

					}
				}
			}
			// abort;

			if(isNull(componentPath)){
				throw("No component with the name #arguments.type# was found.");
			} else {

				try {
					var newCfc = createObject(componentPath);

					var subErrors = {};
					var newArgs = recurseFindCFCArguments(data=arguments.data, cfc=newCfc, errors=subErrors, path=path);

					if(!subErrors.isEmpty()){

						try {
							throw("Found error while trying to instantiate #componentPath#", "controllerArgument");
						}catch(any e){
							addError(arguments.name, {message:"Enountered errors while trying to populate #arguments.name#", original_value:arguments.data}, subErrors, e);
							return;
						}
					}

					if(isNull(newArgs)){
						return;
					} else {
						var newCfc = newCfc.init(argumentCollection=newArgs);
						if(isNull(newCfc)){
							throw("Zero encountered an error while initializing an argument object 'componentPath'. The init() function did not return an instance of itself.");
						}
						return newCfc;
					}

				} catch(any e){
					addError(arguments.name, {message:e.message, original_value:arguments.data}, subErrors?:{}, e);
					return;
				}
			}

		}

		var getArgumentValues = function(name, type, isRequired, data){

			var name = arguments.name;
			var type = arguments.type;
			var isRequired = arguments.isRequired;
			var data = arguments.data;
			var out = {};

			if(isCFMLType(type)){

				if(type == "boolean"){
					if(data == "on"){
						out.insert(name, true);
						return out;
					}
				}

				if(!isValid(type, data)){
					try {
						throw("The value for the form element '#name#' was not of the correct type '#type#'", "invalid_#lcase(type)#");
					}catch(any e){
						// writeDump(form);
						// writeDump(type);
						// writeDump(data);
						// abort;
						addError(name, {message:e.message, original_value:data},{},e);
					}
					return out;
				} else {
					out.insert(name, data);
					return out;
				}

			} else if(isArrayType(type)){
				// writeDump(local);abort;

				if(!isArray(data)){
					try {
						throw("The type was an arrayTyped of #type#, thus expected the data to be an array", "controllerArgument");
					}catch(any e){
						addError(name, {message:e.message, original_value:data}, {}, e);
					}
					return out;
				}

				var arrayType = getArrayType(type);

				if(isCFMLType(arrayType)){
					for(var item in data){
						if(!isValid(arrayType, item)){
							try {
								throw("One of the values in the array was not of the correct type #arrayType#", "controllerArgument");
							}catch(any e){
								addError(
									name,
									{
										message:e.message,
										original_value:data
									},{},
									e)
							}
							return out;
						}
					}
					out.insert(name, data);
					return out;

				} else {


					var arrayOut = [];
					for(var item in data){

						var newCfc = tryComplexObject(name, arrayType, item);
						if(isNull(newCfc)){
							return out;
						} else {
							arrayOut.append(newCfc);
						}

					}

					out.insert(name, arrayOut);
					return out;
				}

			} else if(isEntityType(type)){
				try{
					var entity = loadEntity(cfc, type, data);
					var out.insert(name, entity);
				}catch(any e){
					addError(name, {message:e.message, original_value:data},{},e);
				}
				return out;
			} else {
				var newCfc = tryComplexObject(name, type, data);
				if(isNull(newCfc)){
					return out;
				} else {
					out.insert(name, newCfc);
					return out;
				}
			}

		}

		if(arrayLen(args) == 1 and args[1].name == "rc"){
			out.rc = request.context;
			return out;
		}

		if(arrayLen(args) == 1 and !forceArgumentCollection){

			var name = args[1].name;
			var type = args[1].type;
			var required = args[1].required;

			return getArgumentValues(name=name, type=type, isRequired=required, data=data);

		} else {
			if(isStruct(data)){
				for(var arg in args){
					if(arg.type == "zeroFormState"){

						if(arg.keyExists("required") and arg.required){
							if(!request._zero.keyExists("zeroFormState")){
								throw("Could not load the form state but it was marked as required. Ensure that a form state is created before calling this controller function");
							}
							out.insert(arg.name, request._zero.zeroFormState);
							continue;
						} else {
							if(request._zero.keyExists("zeroFormState")){
								out.insert(arg.name, request._zero.zeroFormState);
							}
						}
					}

					if(arg.type == "zeroClient"){

						if(arg.keyExists("required") and arg.required){
							if(!request._zero.keyExists("zeroClient")){
								throw("Could not load the form state but it was marked as required. Ensure that a form state is created before calling this controller function");
							}
							out.insert(arg.name, request._zero.zeroClient);
							continue;
						} else {
							if(request._zero.keyExists("zeroClient")){
								out.insert(arg.name, request._zero.zeroClient);
							}
						}
					}


					if(data.keyExists(arg.name)){
						var populatedArg = getArgumentValues(name=arg.name, type=arg.type, isRequired=true, data=data[arg.name]);
						try {
							out.append(populatedArg);
						}catch(any e){
							writeDump(data);
							writeDump(arg);
							writeDump(local);
							// writeDump(e);
							abort;
						}
					} else {
						if(arg.keyExists("required") AND arg.required){

							try {
								throw("The argument #arg.name# was required but was not passed in", "missingRequiredArgument");
							}catch(any e){
								addError(arg.name,{message:e.message, original_value:nullValue()}, {}, e);
							}
						}
					}
				}
				// abort;
				return out;

			} else {
				//Add the value as simply the first argument for the value object. This allows the additional
				//arguments for the value object to be optional
				out.insert(args[1].name, data);
				// addError(cfcName, {message:"The object #cfcName# has multiple arguments but the value passed is not a structure. This value should be passed as a struct", original_value:data});
				return out;
			}
		}

	}

	public function getZeroIntegrate(){
		var logDirectory = new plugins.integrate.model.directory(expandPath("integration_request_log"));
		logDirectory.create();
		var specsDirectory = new plugins.integrate.model.directory(expandPath(variables.zero.integrationsPath));
		specsDirectory.create();
		var Integrate = new plugins.integrate.model.integrate(specsDirectory=specsDirectory, logDirectory=logDirectory);
		return Integrate;
	}

	/*
	* Loads a default instance of ZeroMigrate for the application
	*/
	public function getZeroMigrate(){
		if(!structKeyExists(this,"datasource")){
			throw("Must configure this.datasource to use ZeroMigrate");
		}
		var datasourceName = this.datasource;
		var datasourceConfig = this.datasources[this.datasource];
		var migration = new zeromigrate.model.migration(expandPath("/releases"), datasourceName);
		return migration;
	}

	/*
	* Loads a default instance of ZeroEvent for the application
	*/
	public function getZeroEvent(){
		var tryZeroEvent = entityLoad("zeroEvent");
		if(arrayIsEmpty(tryZeroEvent)){
			transaction {
			var ZeroEvent = entityNew("zeroEvent");
			entitySave(ZeroEvent);
			ORMFlush();
			transaction action="commit";
		}
		} else {
			var ZeroEvent = tryZeroEvent[1];
		}
		return ZeroEvent;
	}

	/*
	* Loads a default instance of ZeroAudit for the application
	*/
	public ZeroAudit function getZeroAudit(){
		var ZeroAudit = entityLoad("ZeroAudit");
		if(arrayLen(ZeroAudit) == 0){
			transaction {
				var ZeroTask = entityNew("ZeroAudit");
				entitySave(ZeroTask);
				ORMFlush();
				transaction action="commit";
			}
			return ZeroAudit;
		} else {
			return ZeroAudit[1];
		}
	}

	/*
	* Loads a default instance of ZeroTask for the application
	*/
	public ZeroTask function getZeroTask(){
		var zeroTask = entityLoad("zeroTask");
		if(arrayLen(zeroTask) == 0){
			transaction {
				var ZeroTask = entityNew("zeroTask");
				entitySave(ZeroTask);
				ORMFlush();
				transaction action="commit";
			}
			return ZeroTask;
		} else {
			return zeroTask[1];
		}
	}

	function getArgumentsToPass(cfc, method){
    	var args = getMetaDataFunctionArguments(cfc, method);
		argsToPass = {};

		//Add headers to the request context as something that can be populated into controller arguments
		request.context.headers = request._fw1.headers?:{};

		//Add each cookie to the request context so that they can be populated into controller arguments
		for(var cook in cookie){
			request.context[cook] = cookie[cook];
		}

		/*
		Zero will allow controller arguments to be snake_case or camelCase. If Zero encounters
		a snake_case argument, it will convert it to camelCase also assuming that both arguments
		are intended to be the same value, but snake_case is used for API and HTML presentation. We
		achieve this by simply copying the values from the snake_case to a camelCase version
		 */
		var recurseToUnderscore = function(data){
			for(var key in arguments.data){
				var keyNoUnderscore = replaceNoCase(key,"_","","all");
				if(!arguments.data.keyExists(keyNoUnderscore)){
					arguments.data[keyNoUnderscore] = arguments.data[key];
					if(isStruct(arguments.data[keyNoUnderscore])){
						recurseToUnderscore(arguments.data[keyNoUnderscore]);
					}

					if(isArray(arguments.data[keyNoUnderscore])){
						for(var item in arguments.data[keyNoUnderscore]){
							if(isStruct(item)){
								recurseToUnderscore(item);
							}
						}
					}
				}
			}
		}
		recurseToUnderscore(request.context);

		// writeDump(request.context);
		// abort;

		argsToPass = recurseFindCFCArguments(data=request.context, cfc=cfc, method=method, errors=request._zero.argumentErrors?:{}, forceArgumentCollection=true);
		return argsToPass;
    }

    public array function getRequestLog(){
    	if(fileExists("zero_requests.json")){
			var rawData = fileRead("zero_requests.json");
			if(isJson(rawData)){
				var requestData = deserializeJson(rawData);
			} else {
				requestData = [];
			}
		} else {
			var requestData = [];
		}
		return requestData;
    }

	private void function doController( struct tuple, string method, string lifecycle ) {
        var cfc = tuple.controller;
        writeLog(file="zero_trace", text="start doController for cfc:#getMetaData(cfc).name#, method:#method#, lifecycle:#lifecycle#");

        if ( structKeyExists( cfc, method ) ) {
            try {
                internalFrameworkTrace( 'calling #lifecycle# controller', tuple.subsystem, tuple.section, method );
                // request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
                //

                if(arguments.lifecycle == "item"){
                	if(controllerHasFunction(cfc, "request")){
                		evaluate( 'cfc.request( rc = request.context, headers = request._fw1.headers)' );
                	}

                	if(variables.zero.argumentCheckedControllers){

                		var argsToPass = getArgumentsToPass(cfc, method);

                		// var argsToPass = recurseFindCFCArguments(any data, cfc, method, errors=request._zero.argumentErrors)
                		if(!request._zero.argumentErrors.isEmpty()){
                			request._zero.controllerResult = this.serialize({
                				"success":false,
                				"errors":request._zero.argumentErrors,
                				"message":"There was an error processing your request. Please try again. Please check the Errors data for more info"
                			})

                			for(var arg in request._zero.argumentErrors.errors){
                				var type = request._zero.argumentErrors.errors[arg].type;
                				var message = request._zero.argumentErrors.errors[arg].message;
                				if(type == "application" or type == "expression" or type == "template"){
                					throw(message, type);
                				}
                			}

                			if(this.getContentType() == "html" and !request.context.keyExists("goto_fail")){
                				throw("Zero encountered an error while trying to populate controller arguments and did not find a goto_fail to handle the error", "controllerArgumentErrors");
                			}
                			// throw("Zero encountered an error while trying to populate controller arguments", "controllerArgumentErrors");

            			} else {
	                		// request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );
	                		try {
	                			request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );
            				} catch(any e){

            					if(!e.errorCode == "0"){
									var errorcode = e.errorCode
								} else {
									var errorcode = "500";
								}

								request._zero.errorLog.append(e);

								if(structKeyExists(this,"onFailure")){
									logRequest();
									this.onFailure(e, "doController");
								}

            					request._zero.controllerResult = this.serialize({
	                				"success":false,
	                				"errors":{
	                					"#e.type#":{
	                						"message":e.message,
	                					},
	                					"action_string":request.action,
		                				"action":{
		                					"#getSubsystem()#":{
												"#getSection()#":{
													"#getItem()#":true
												}
											}
										},
										"errors":{
											"#e.type#":{
												"message":e.message,
											}
										}
	                				},
	                				"status_code":errorCode
	                			})

	                			if(e.type == "application" or e.type == "expression" or e.type == "template"){
                					throw(e);
                				}

	                			if(!request.context.keyExists("goto_fail")){
									throw(e);
	                			}
            				}
            			}

                	} else {
                		try {
                		for(var key in request.context){
							var keyNoUnderscore = replaceNoCase(key,"_","","all");
							if(!request.context.keyExists(keyNoUnderscore)){
								request.context[keyNoUnderscore] = request.context[key];
							}
						}
	                	request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = request.context)' );

                		}catch(any e){
                			writeDump(request.context);
                			writeDump(e);
                			abort;
                		}
                		// request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
                	}

                	if(controllerHasFunction(cfc, "result")){
                		if(isNull(request._zero.controllerResult)){
							if(variables.zero.throwOnNullControllerResult){
								throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
							}
						} else {
                			request._zero.controllerResult = evaluate( 'cfc.result( request._zero.controllerResult )' );
						}
                	}

            	} else {

            		/* Zero overrides what happens with after methods to pass in the result of the controller call as
            		an additional parameter
            		*/
            		if(method == "after"){
            			if(isNull(request._zero.controllerResult)){
            				if(variables.zero.throwOnNullControllerResult){
								throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
							}
            			} else {
            				request._zero.controllerLifecycleResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers, controllerResult = 	request._zero.controllerResult)' );
            			}

            			if(isNull(request._zero.controllerLifecycleResult)){
							if(variables.zero.throwOnNullControllerResult){
								throw("The controller #request.action# #request.item# after() did not have a return value but it expected one for a json request")
							}
						} else {
            				request._zero.controllerResult = request._zero.controllerLifecycleResult
						}
            		} else {
            			request._zero.controllerLifecycleResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
            		}
            	}
            } catch ( any e ) {
                setCfcMethodFailureInfo( cfc, method );
                rethrow;
            }
        } else if ( structKeyExists( cfc, 'onMissingMethod' ) ) {
            try {
                internalFrameworkTrace( 'calling #lifecycle# controller (via onMissingMethod)', tuple.subsystem, tuple.section, method );
                request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, method = lifecycle, headers = request._fw1.headers )' );
            } catch ( any e ) {
                setCfcMethodFailureInfo( cfc, method );
                rethrow;
            }
        } else {
            internalFrameworkTrace( 'no #lifecycle# controller to call', tuple.subsystem, tuple.section, method );
        }
    }

    public function encodeResultFor(type="HTML", required any str){

    	if(!isNull(str)){
	    	if(isArray(str)){
	    		loop array=str index="i" item="value" {

	    			if(!isNull(value)){
		    			if(isArray(value) or isStruct(value)){
		    				encodeResultFor(type, value);
		    			} else {
		    				str[i] = esapiEncode(type, value);
		    			}
	    			}
	    		}
	    	} else if(isStruct(str)){
	    		for(var key in str){
	    			if(!isNull(str[key])){
		    			if(isArray(str[key]) or isStruct(str[key])){
		    				encodeResultFor(type, str[key]);
		    			} else {
		    				str[key] = esapiEncode(type, str[key]);
		    			}
	    			}
	    		}
	    	}
    	}
    	return str;
    }

    public function entityToJson(required any arrayOrComponent, nest={}){
    	if(isArray(arrayOrComponent)){
    		var entityName = request.section;
    	} else {
    		//Try to get the name from the actual entity because we assume that it is singular
	    	try {
	    		var entityName = getEntityName(arrayOrComponent);
	    	} catch("zeroCantInferEntityName"){
	    		var entityName = request.section;
	    	}
    	}
    	var out = {
    		"#entityName#":new serializer().serializeEntity(arrayOrComponent, nest)
    	}
    	return out;
    }

    public boolean function hasZeroFormState(){
    	return request._zero.keyExists("zeroFormState");
    }

    public zeroFormState function getZeroFormState(){
    	if(request._zero.keyExists("zeroFormState")){
    		return request._zero.zeroFormState;
    	} else {
    		throw("No zeroFormState was defined. Be sure there is a form state created before calling this function");
    	}
    }

    public string function getContentType(){
    	return request._zero.contentType?:"html";
    }

    public function getCSRFToken(){
    	if(!request.keyExists("CSRF_TOKEN")){
    		request.CSRF_TOKEN = createUUID();
    		cookie.CSRF_TOKEN = request.CSRF_TOKEN;
    	}
    	return cookie.CSRF_TOKEN;
    }

    public function	getJsoup(){
		var jsoup = application._zero.jsoup = application._zero.jsoup?:createObject("java", "org.jsoup.Jsoup", "formcheck/jsoup-1.13.1.jar");
		return jsoup;
	}

	public string function handlebars(required string template, required struct context){
		var out = "";
		savecontent variable="out" {
			module name="handlebars" context="#arguments.context#" {
				echo(template);
			}
		}
		return out;
	}

    public boolean function hasEntityLoader(entityName){
    	if(structKeyExists(this, "get#entityName#byId") or structKeyExists(variables, "get#entityName#byId")){
    		return true;
    	} else {
    		return false;
    	}
    }

    private function installCustomFunctions(){

    	var webInfPath = expandPath("{lucee-web}");
    	var sourcePath = getDirectoryFromPath(getCurrentTemplatePath());
    	var paths = [
    		{
    			source:sourcePath&"/lib/print.cfc",
    			destination:webInfPath&"/library/function/print.cfc"
    		},
    		{
    			source:sourcePath&"/lib/print.cfm",
    			destination:webInfPath&"/library/function/print.cfm"
    		},
    	];

    	var didCopy = false;
    	for(var path in paths){
    		if(!fileExists(path.destination)){
    			fileCopy(path.source, path.destination);
    			didCopy = true;
    		}
    	}

    	if(didCopy){
    		throw("Zero installed custom functions to Lucee, please restart Lucee to continue");
    	}
    }

    public boolean function structIsReallyArray(required struct str){
    	var success = true;
    	for(var key in str){
    		if(!isNumeric(key)){
    			success = false;
    		}
    	}
    	return success;
    }

    public function convertStructArrayToArray(required struct str){
    	var out = [];
    	var keys = str.keyArray().sort("numeric");

    	for(var key in keys){
    		out.append(str[key]);
    	}
    	return out;
    }

    private string function getEntityName(arrayOrComponent){
		if(isArray(arrayOrComponent)){
			if(arrayLen(arrayOrComponent) == 0){
				throw("Could not infer the entity name from an empty array. use the entityToJson() method manually", "zeroCantInferEntityName");
			} else {
				var entity = arrayOrComponent[1];
			}
		} else {
			var entity = arrayOrComponent;
		}

		var meta = getMetaData(entity);
		var name = meta.name;
		return listLast(name,".");
	}

	private function getMetaDataFunctionArguments(required cfc, required method){
    	var cfc = arguments.cfc;
    	var method = arguments.method;
    	var metaData = getMetaData(cfc);
    	var functions = getAllExtendedFunctions(metaData);

    	for(var func in functions){
    		if(func.name == method){
    			return func.parameters;
    		}
    	}

    	throw("Did not expect to get to this point, controller method #method# does not exist. framework zero");
    }

    public boolean function isComponentOrArrayOfComponents(required arrayOrComponent){
    	if(isStruct(arrayOrComponent) and !isObject(arrayOrComponent)){
    		return false;
    	}

    	if(isArray(arrayOrComponent)){
    		if(arrayLen(arrayOrComponent) > 0){

    			if(isNull(arrayOrComponent[1])){
    				/*
    				Handles the case where Lucee generates an ordered
    				array for arguments that has null values. They still
    				evaluate to an object for some reason
    				 */
    				return false;
    			} else {
	    			if(isObject(arrayOrComponent[1])){
	    				return true;
	    			} else {
	    				return false;
	    			}
    			}
    		} else {
    			return false;
    		}
    	} else if(isObject(arrayOrComponent)){
    		return true;
    	} else {
    		return false;
    	}
    }

    public function injectCSRFIntoForms(string output){

    	var pos = 0;
    	var len = 0;
    	do {
    		var result =  reFindNoCase("<form\b[^>]*>", output, pos + len + 1, true);
    		// writeDump(result);
    		pos = result.pos[1];
    		len = result.len[1];

    		if(pos > 0){
    			var csrf = '<input type="hidden" name="csrf_token" value="#getCSRFToken()#" />';
    			var output = insert(csrf, output, pos + len - 1);
    		}

    	} while(pos);

    	return output;
    }

    /*
    Returns the component meta data for all of the configured subsystems, sections (controllers) and
    items (methods). This can be used by any code which needs to automate based on the structure
    of the subsystems.
     */
    public function getSubsystemData(){
    	var out = {};
    	if(variables.framework.usingSubsystems){
    		// variables.framework.routes = [];
			var subsystems = directoryList(path=expandPath(variables.framework.base));

			for(var subsystem in subsystems){

				var subsystemName = listLast(subsystem, server.separator.file);

				var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");

				for(var controller in controllers){
					var file = getFileFromPath(controller);
					var name = listFirst(file, ".");
					var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");
					out[subsystemName][name] = meta;
				}
			}
    	}
    	return out;
    }

	/**
	 * Createa a default RESTful route for each controller present. loadAvailableControllers() must be called within onRequestStart() because
	 * it depends on the setting usingSubsystems which can be set by the inheriting Application.cfc
	 * in the controllers folder
	 * @return {array} The routes created by this function
	 */
	private array function loadAvailableControllers(){
		writeLog(file="zero_trace", text="Load controllers");
		if(!isNull(request.alreadyLoadedControllers)){
			return [];
		}

		if(isNull(variables.framework.routes)){
			variables.framework.routes = [];
		}

		if(variables.framework.usingSubsystems){
			// timer type="outline" label="" {
				this.loadSubsystemControllers();
			// }
		} else {
			loadControllers(expandPath("controllers"));
		}

		if(!isNull(this.setupRoutes)){
			this.setupRoutes(variables.framework.routes);
		}
		// writeDump(variables.framework.routes)
		// abort;
		//Add routes for zeroauth plugin
		variables.framework.routes.prepend({'$POST/auth/users/:id/send_login*' = '/auth:users/send_login/id/:id' });
		variables.framework.routes.prepend({'$GET/auth/logout' = '/auth:logins.delete' });
		variables.framework.routes.prepend({'$POST/auth/logout' = '/auth:logins.delete' });

		//Add routes for zeromigrate plugin
		variables.framework.routes.prepend({'$GET/migrate/releases/:id/export*' = '/migrate:releases/export/id/:id' });
		variables.framework.routes.prepend({'$POST/migrate/main/revert' = '/migrate:main/revert' });
		variables.framework.routes.prepend({'$POST/migrate/main/migrate' = '/migrate:main/migrate' });

		//Add routes for zeroevent plugin
		variables.framework.routes.prepend({'$POST/events/streams/:id/next*' = '/events:streams/next/id/:id' });
		variables.framework.routes.prepend({'$POST/events/streams/:id/run_all*' = '/events:streams/run_all/id/:id' });

		request.alreadyLoadedControllers = true;
		//Add as the last item a universal route for the default subsystem to route anything
		//to it back to the subsystem
		// writeDump(variables.framework.routes);
		// abort;
		return variables.framework.routes;
	}

	private array function loadControllers(required path){

		var controllers = directoryList(path=arguments.path, filter="*.cfc");
		for(var controller in controllers){
			file = getFileFromPath(controller);
			name = listFirst(file, ".");

			var meta = getComponentMetaData("controllers.#name#");
			var nested = listToArray(meta.nested?:"");
			for(var nest in nested){
				//Add nesting

				//Add route for linking resource
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/link*' = '/#nest#/link/#name#_id/:#nest#_id/id/:id' });

				//Add route for unlinking resource
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/unlink*' = '/#nest#/unlink/#name#_id/:#nest#_id/id/:id' });
			}

			if(arrayLen(nested)){
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#"} });
			} else {
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = name} })
			}


		}
		return variables.framework.routes;
	}

	public function loadEntity(cfc, string name, string id){

		if(structKeyExists(arguments.cfc, "loadEntity") and isCustomFunction(cfc.loadEntity)){
			var Entity = cfc.loadEntity(arguments.name, arguments.id, true);
		} else {
			var Entity = entityLoad(arguments.name, arguments.id, true);
		}

		if(isNull(Entity)){
			throw("Could not load the request resource item #arguments.name#", "resourceNotFound", 404);
		}
		return Entity;
	}

	/*
	Logs an error thrown by Zero when processing a controller or request for future
	inspection. To be used during development to check the requests responses
	 */
	public void function logRequest(){
		if(variables.zero.logRequests){
			var requestData = getRequestLog();
			var data = {
				cgi:CGI,
				time:now(),
				form:form,
				url:url,
				rc:request.context,
				result:request._zero.controllerResult?:{},
				errors:request._zero.errorLog?:[]
			};

			if(request._zero.keyExists("currentRequestLogIndex")){
				requestData[request._zero.currentRequestLogIndex] = data;
			} else {
				requestData.append(data);
			}
			request._zero.currentRequestLogIndex = arrayLen(requestData);
			fileWrite("zero_requests.json", serializeJson(requestData));

		}
		// abort;
	}

	public void function saveRequest(){

		var ignore = "bmp,css,gif,htc,html,ico,jpeg,js,pdf,png,swf,txt,xml,woff2,ttf,woff";
		var extension = listLast(cgi.path_info,".");

		if(listContainsNoCase(ignore, extension)){
			return;
		}

		if(variables.zero.enableIntegrationTests and getSubsystem() != "integrate"){

			var logDirectory = new plugins.integrate.model.directory(expandPath("integration_request_log"));
			logDirectory.create();

			var specsDirectory = new plugins.integrate.model.directory(expandPath(variables.zero.integrationsPath));
			specsDirectory.create();

			var Integrate = new plugins.integrate.model.integrate(specsDirectory, logDirectory);
			var SavedRequest = Integrate.createSavedRequest(
				  formData = new plugins.integrate.model.formData(request._zero.originalFormData)
				, urlData = new plugins.integrate.model.urlData(request._zero.originalUrlData)
				, cgiData = new plugins.integrate.model.cgiData(cgi)
				, headerData = new plugins.integrate.model.headerData(getHTTPRequestData())
				, cookieData = new plugins.integrate.model.cookieData(request._zero.originalCookieData)
				, controllerResultData = new plugins.integrate.model.controllerResultData(this.serialize(request._zero.controllerResult?:{}))
				, htmlOut = new plugins.integrate.model.htmlOut(request._zero.htmlOut)
			);

			var fileName = "#lcase(getTickCount())#.lucee";
			var outFile = logDirectory.appendFile(fileName);
			outFile.write(serialize(SavedRequest));
		}
	}

	/*
	Returns a lot of information about the request, useful for troubleshooting
	or logging information about the request.
	 */
	public struct function getRequestData(){
		var out = {
			  zeroRequestId = getRequestId()
			, formData = request._zero.originalFormData?:{}
			, urlData = request._zero.originalUrlData?:{}
			, cgiData = cgi
			, headerData = getHTTPRequestData()
			, cookieData = request._zero.originalCookieData?:{}
			, controllerResultData = request._zero.controllerResult?:{}
			, htmlOut = request._zero.htmlOut?:""
		}
		// var out = {}
		return out;
	}

	/*
	Generates a unique ID for the request for logging purposes so that
	logging functionality can track the request
	 */
	private function getRequestId(){
		request.zeroRequestId = request.zeroRequestId?:createUUID();
		return request.zeroRequestId;
	}

	private array function loadSubsystemControllers(){
		// variables.framework.routes = [];

		var universalRoutes = [];
		var defaultSubsystemRoutes = [];
		var defaultSubsystemLinkRoutes = [];

		var subsystems = directoryList(path=expandPath(variables.framework.base));

		for(var subsystem in subsystems){

			var subsystemName = listLast(subsystem, server.separator.file);

			/**
			 * Routes for the default subsystem must be defined without the
			 * subsystem in the route in order for them work. This is
			 */
			if(variables.framework.defaultSubsystem == subsystemName){

				var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");
				for(var controller in controllers){
					var file = getFileFromPath(controller);
					var name = listFirst(file, ".");
					//Runscrit Routes
					// writeDump(name);
					var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");

					var nested = listToArray(meta.nested?:"");
					for(var nest in nested){

						nestedBy[nest][name] = true;

						//Add nesting

						//Add route for linking resource
						defaultSubsystemLinkRoutes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/link*' = '/#nest#/link/#name#_id/:#name#_id/id/:id' });

						//Add route for unlinking resource
						defaultSubsystemLinkRoutes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/unlink*' = '/#nest#/unlink/#name#_id/:#name#_id/id/:id' });
					}


					if(arrayLen(nested)){
						//nested resource routes always need to be prepended because they must come before non nested routes
						//for Framework One to work correctly
						defaultSubsystemRoutes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#"} });
					} else {
						defaultSubsystemRoutes.append({ "$RESOURCES" = { resources = name } })
					}

					//Allow update to be called without an Id so that the Id can be passed as a form variable
					// variables.framework.routes.prepend({'$#uCase(method)#/#name#/update*':'/#name#/update'});

					//Look for methods specifying custom route methods
					var funcs = this.getAllExtendedFunctions(meta);
					for(var func in funcs){
						if(func.keyExists("method")){
							var methods = listToArray(func.method);
							for(var method in methods){

								var hasRequiredId = false;
								var hasId = false;
								for(var param in func.parameters){
									if(param.name == "id"){
										hasId = true;
										if(param.required == true){
											hasRequiredId = true;
										}
										break;
									}
								}

								if(hasId){
									if(hasRequiredId){
										variables.framework.routes.prepend({'$#uCase(method)#/#name#/:id/#func.name#*':'/#name#/#func.name#/id/:id'});
									} else {
										variables.framework.routes.prepend({'$#uCase(method)#/#name#/:id/#func.name#*':'/#name#/#func.name#/id/:id'});
										variables.framework.routes.prepend({'$#uCase(method)#/#name#/#func.name#*':'/#name#/#func.name#'});
									}

								} else {
									variables.framework.routes.prepend({'$#uCase(method)#/#name#/#func.name#*':'/#name#/#func.name#'});
								}
							}
							// writeDump(func);abort;
						}
					}
				}

			}

			var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");
			for(var controller in controllers){
				var file = getFileFromPath(controller);
				var name = listFirst(file, ".");
				try {
					var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");
				}catch(any e){
					e.additional.fw0 = "Coud not load the controller: #variables.framework.base#.#subsystemName#.controllers.#name#. Check if the file was exists found or it is corrupted"
					throw(e);
				}

				/**
				 * 09/15/2021: When the controller has the metadata attribute "includeContextIdInRoute" defined
				 * then this controller will have an Id for the context (subsystem) in the URL route. The developer
				 * can specify this metadata manually for controllers they write, and it also can be specified in a
				 * RecordType that is a context
				 */
				var includeContextIdInRoute = meta.includeContextIdInRoute?:false;

				var nested = listToArray(meta.nested?:"");
				for(var nest in nested){
					nestedBy[nest][name] = true;
					//Add route for linking resource
					variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/link*' = '/#subsystemName#:#nest#/link/#name#_id/:#name#_id/id/:id' });

					//Add route for unlinking resource
					variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/unlink*' = '/#subsystemName#:#nest#/unlink/#name#_id/:#name#_id/id/:id' });
				}
				if(arrayLen(nested)){
					//nested resource routes always need to be prepended because they must come before non nested routes
					//for Framework One to work correctly
					variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#", subsystem = subsystemName} });
				} else {
					variables.framework.routes.append({ "$RESOURCES" = { resources = name, subsystem = subsystemName } })
				}


				if(includeContextIdInRoute){
					/**
					 * First we are going to add the routes in order below so that we can more easily understand them and then they will get
					 * prepended to the routes in reverse order.
					 */
					var ContextIdRoutes = [];

					//GET list() with suffix
					// must come before read otherwise read will match as '/list' being the Id
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/#name#/list*':'/#subsystemName#:#name#/list/#subsystemName#_id/:#subsystemName#_id'}
					);

					//GET new()
					// must come before read otherwise read will match as '/new' being the Id
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/#name#/new*':'/#subsystemName#:#name#/new/#subsystemName#_id/:#subsystemName#_id'}
					);

					//POST new()
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/new*':'/#subsystemName#:#name#/new/#subsystemName#_id/:#subsystemName#_id'}
					);

					//GET edit() by id
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/#name#/:id/edit*':'/#subsystemName#:#name#/edit/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//POST edit() by id
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/:id/edit*':'/#subsystemName#:#name#/edit/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//GET read() by id
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/#name#/:id':'/#subsystemName#:#name#/read/id/:id/#subsystemName#_id/:#subsystemName#_id/'}
					);

					//POST read() by id with suffix
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/:id/read*':'/#subsystemName#:#name#/read/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//DELETE to delete() with id
					ContextIdRoutes.append(
						{'$DELETE/#subsystemName#/:#subsystemName#_id/#name#/:id':'/#subsystemName#:#name#/delete/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//POST to delete() with delete suffix
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/:id/delete*':'/#subsystemName#:#name#/delete/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);


					//GET list()
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/#name#*':'/#subsystemName#:#name#/list/#subsystemName#_id/:#subsystemName#_id'}
					);

					//POST list() with suffix
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/list*':'/#subsystemName#:#name#/list/#subsystemName#_id/:#subsystemName#_id'}
					);


					//POST update() without id
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/update*':'/#subsystemName#:#name#/update/#subsystemName#_id/:#subsystemName#_id'}
					);

					//POST to update() with id
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#/:id':'/#subsystemName#:#name#/update/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//PUT to update() without id
					ContextIdRoutes.append(
						{'$PUT/#subsystemName#/:#subsystemName#_id/#name#/update':'/#subsystemName#:#name#/update/#subsystemName#_id/:#subsystemName#_id'}
					);

					//PUT to update() with id
					ContextIdRoutes.append(
						{'$PUT/#subsystemName#/:#subsystemName#_id/#name#/:id':'/#subsystemName#:#name#/update/id/:id/#subsystemName#_id/:#subsystemName#_id'}
					);

					//create
					ContextIdRoutes.append(
						{'$POST/#subsystemName#/:#subsystemName#_id/#name#':'/#subsystemName#:#name#/create/#subsystemName#_id/:#subsystemName#_id'}
					);

					// Context main.list()
					//Lastly add a route when just the ID is passed we are going to load the main list function
					ContextIdRoutes.append(
						{'$GET/#subsystemName#/:#subsystemName#_id/main':'/#subsystemName#:main/list/#subsystemName#_id/:#subsystemName#_id'}
					);

					for(var item in ContextIdRoutes.reverse()){
						variables.framework.routes.prepend(item);
					}
				}



				//Look for methods specifying custom route methods
				var funcs = getAllExtendedFunctions(meta);
				for(var func in funcs){

					if(func.keyExists("method")){
						var methods = listToArray(func.method);
						for(var method in methods){

							var hasRequiredId = false;
							var hasId = false;
							for(var param in func.parameters){
								if(param.name == "id"){
									hasId = true;
									if(param.required == true){
										hasRequiredId = true;
									}
									break;
								}
							}

							if(hasId){
								if(hasRequiredId){
									variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/#name#/:id/#func.name#*':'/#subsystemName#:#name#/#func.name#/id/:id'});

									if(includeContextIdInRoute){
										//Add a Context Id for the subsystem
										variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/:#subsystemName#_id/#name#/:id/#func.name#*':'/#subsystemName#:#name#/#func.name#/id/:id/#subsystemName#_id/:#subsystemName#_id'});
									}

								} else {
									variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/#name#/:id/#func.name#*':'/#subsystemName#:#name#/#func.name#/id/:id'});

									if(includeContextIdInRoute){
										//Add a Context Id for the subsystem
										variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/:#subsystemName#_id/#name#/:id/#func.name#*':'/#subsystemName#:#name#/#func.name#/id/:id/#subsystemName#_id/:#subsystemName#_id'});
									}

									variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/#name#/#func.name#*':'/#subsystemName#:#name#/#func.name#'});

									if(includeContextIdInRoute){
										//Add a Context Id for the subsystem
										variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/:#subsystemName#_id/#name#/#func.name#*':'/#subsystemName#:#name#/#func.name#/#subsystemName#_id/:#subsystemName#_id'});
									}
								}

							} else {
								variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/#name#/#func.name#*':'/#subsystemName#:#name#/#func.name#'});

								if(includeContextIdInRoute){
									//Add a Context Id for the subsystem
									variables.framework.routes.prepend({'$#uCase(method)#/#subsystemName#/:#subsystemName#_id/#name#/#func.name#*':'/#subsystemName#:#name#/#func.name#/#subsystemName#_id/:#subsystemName#_id'});
								}
							}
						}
					}
				}

				//Create a universal route for the subsystem to the subsystem name for SES urls
				universalRoutes.append({'/#subsystemName#*' = '/#subsystemName#:\1'});
			}
		}

		for(var route in defaultSubsystemRoutes){
			variables.framework.routes.append(route);
		}

		for(var route in universalRoutes){
			variables.framework.routes.append(route);
		}

		for(var route in defaultSubsystemLinkRoutes){
			variables.framework.routes.prepend(route);
		}
		// writeDump(variables.framework.routes);
		// abort;
		return variables.framework.routes;
	}

	public function onError(error, event){
		//Check if there is an error handler for this specific subsystem. If there is then
		//we are going to use that instead
		if(request.keyExists("subsystem") and fileExists(expandPath("/subsystems/#request.subsystem#/views/#request.section#/error.cfm"))){
			variables.framework.error = "#request.subsystem#:#request.section#.error";
		} else {
			variables.framework.error = "home:main.error";
		}


		switch(request._zero.contentType){
			case "json":

				if(!error.errorCode == "0"){
					var errorcode = error.errorCode
				} else {
					var errorcode = "500";
				}


				if(errorCode ==""){
					errorCode = "500";
				}

				if(error.type != "expression" and error.type != "application" and error.type != "template"){
					var out = request._zero.controllerResult?:{
        				"success":false,
        				"errors":{
        					"#error.type#":{
        						"message":error.message,
        					},
        					"action_string":request.action,
            				"action":{
            					"#getSubsystem()#":{
									"#getSection()#":{
										"#getItem()#":true
									}
								}
							},
							"errors":{
								"#error.type#":{
									"message":error.message,
								}
							}
        				},
        				"status_code":errorCode
        			};
					out["status_code"] = errorCode;
					out["message"] = "There was an error processing your request. Please try again. Please check the Errors data for more info"
				} else {
					if(variables.zero.outputNonControllerErrors){
						var out = {
							"success":false,
							"message":error.message,
							"status_code":errorCode,
							"details":error
						}
					} else {
						var out = {
							"success":false,
							"message":"There was an error processing your request. Please try again.",
						}
					}
				}

				var out = this.serialize(out);
				header statuscode="#errorCode#";
				header name="Content-Type" value="application/json";
				writeOutput(serializeJson(out));
				abort;
			break;

			case "html":
				super.onError(error, event);
			break;
		}
	}

	public function doTrace(required data, label=""){
		if(variables.zero.traceRequests){
			var out = "";
			// writeDump(label);
			savecontent variable="out"{
				writeDump(var=data, label=label);
			}
			request.zeroTrace = request.zeroTrace & out;
		}
	}

	public function getZeroContext(){
		if(!server.keyExists("ZeroContext#this.name#") or url.keyExists("clearzerocontext")){
			server["ZeroContext#this.name#"] = new zeromodel.model.context.ZeroContext();
			for(var path in this.ormsettings.cfclocation){
				server["ZeroContext#this.name#"].createSearchPath(new zeromodel.model.context.SearchPath(path));
			}
		}
		return server["ZeroContext#this.name#"];
	}

	function getOrmValidator(){
		if(!server.keyExists("OrmValidator") or url.keyExists("reloadorm")){
			//Create an instance of the validator
			server.OrmValidator = new zeromodel.model.ormvalidator.OrmValidator(this);
			/* Register all of the default validations which are in
			*  zero/plugins/zeromodel/model/ormvalidator/validations
			*  You can override or remove validations that you do not want. See
			*  The documation
			*/
			server.OrmValidator.registerDefaultValidations();

		}

		server.OrmValidator.setAutoRebuildContexts(variables.zero.autoRebuildContexts);

		return server.OrmValidator;
	}

	function onRequest(){
		// 2022-01-08: If the application is in production and we need to reload
		// the orm, we can call ?reloadorm. This is used for produciton deployments
		// where the orm needs to be reloaded at boot
		if(variables.zero.devmode == 0 and url.keyExists("reloadorm")){
			var OrmValidator = this.getOrmValidator();
			OrmValidator.scan();
			OrmValidator.CheckReloadORM();
		}

		/*
		* If Z-zero-preload header is specified then
		* we add the Cache-control for 10 seconds for the time
		* that the user clicks on the link
		*/
		if(zeroPreloadRequested()){
			header name="Cache-control" value="max-age=#getZeroPreloadTime()#";
		}

		if(!request.keyexists("zeroTrace")){
			request.zeroTrace = "";
		}

		if(variables.zero.traceRequests){

			if(url.keyExists("clearTrace")){
				if(directoryExists("./trace")){
					directoryDelete("./trace", true);
				}
			}

			if(!directoryExists("./trace")){
				directoryCreate("./trace");
			}
		}

		doTrace(form,"FORM in onRequest()");
		var finalOutput = "";
		savecontent variable="finalOutput" {
			super.onRequest();
		}
		request._zero.htmlOut = finalOutput;


		if(cookie.keyExists('zeropreload')){
			if(application.preloadCache.keyExists(cookie.zeropreload)){
				application.preloadCache[cookie.zeropreload].complete = true;
				application.preloadCache[cookie.zeropreload].output = finalOutput;
				writeLog(file="zero", text="saved output to cache and aborted #cookie.zeropreload#");
				structDelete(cookie,"zeropreload");
				client = {};
				structClear(client);
				abort;
			}
		}


		finalOutput = response(finalOutput);
		if(variables.zero.csrfProtect){
			if(request._zero.contentType == "html"){
				finalOutput = injectCSRFIntoForms(finalOutput);
			}
		}

		if((variables.zero.maintainScrollPosition and request._zero.contentType == "html")){
			finalOutput = decorateOutputWithScrollPosition(finalOutput);
		}

		if(form.keyExists("display_input_errors")){

			var jsoup = getJsoup();
			var htmlDoc = jsoup.parse(finalOutput);
			var formDoc = htmlDoc.select('form[id=#form.display_input_errors#]');
			var preserveInput = formDoc.select('input[name=preserve_response]');
			var preserveName = preserveInput.attr('value');

			if(len(preserveName) > 0){
				try {
					errorData = getVariable("request._zero.controllerResult.#preserveName#");
				}catch(any e){
					throw(e);
				}

				finalOutput = decorateFormWithErrors(finalOutput, form.display_input_errors, errorData);
			}

		}

		if(form.keyExists("display_input_values")){
			// abort;
			var jsoup = getJsoup();
			var htmlDoc = jsoup.parse(finalOutput);
			var formDoc = htmlDoc.select('form[id=#form.display_input_values#]');

			var inputs = formDoc.select("input,select");
			var formData = new zeroStructure(form).flattenDataStructureForCookies();
			// writeDump(formData);
			for(var input in inputs){

				var inputName = input.attr('name');
				var zeroReservedWords = new zeroReservedWords();
				if(!zeroReservedWords.has(inputName)){
					if(formData.keyExists(inputName)){

						var value = formData[inputName];
						if(value == '""'){
							value = "";
						}

						// writeDump(inputName);
						if(input.attr('zero-preserve') != "false"){

							if(input.tagName() == "select"){
								var options = input.select('option');
								for(var option in options){
									var values = listToArray(value);
									for(item in values){
										if(option.attr('value') == item){
											option.attr('selected', true);
										}
									}
								}
							} else {
								input.attr('value', value);
							}

						}
					}
				}
			}

			finalOutput = htmlDoc.toString();
		}

		if(variables.zero.validateHTMLOutput){

			// setupFrameworkDefaults();

			jsoup = createObject("java", "org.jsoup.Jsoup", "formcheck/jsoup-1.10.2.jar");
			var htmlDoc = jsoup.parse(finalOutput);
			var links = htmlDoc.select("a");
			var forms = htmlDoc.select("form");

			/*
			Forms can have buttons with formAction attributes set. This
			effectively makes it appear as another form that needs to be
			validated because the endpoint for the form is different. What
			we do here is generate a new form based on the old one, but
			set the action attribute so that the validation code can look
			at this button
			 */
			formActions = [];
			for(var formItem in forms){

				//find buttons with a formaction
				var actions = formItem.select('button[formAction]');
				for(var action in actions){
					var actionAttr = action.attr('formAction');
					var inputName = action.attr('name');
					var newForm = formItem.clone();

					/*
					If our input is a submit_overload, then we are going
					to add these inputs as hidden elements to our form since
					that is the effect of a submit_overload
					 */
					if(inputName == "submit_overload"){
						var value = action.attr('value');
						var json = deserializeJson(value);
						for(var key in json){
							var element = newForm.prependElement('input');
							element.attr('type', 'hidden');
							element.attr('name', "#key#");
							element.attr('value', "#serializeJson(json[key])#");
						}
					}

					newForm.attr('action', actionAttr);
					formActions.append(newForm);
				}
			}

			for(var newItem in formActions){
				arrayAppend(forms, newItem);
			}
			var totalTime = 0;

			var foundRoutes = {};

			var routesFunc = function(link, routes, method){
				var start = getTickCount();

				application.routeMatches = application.routeMatches?:{};
				/*
				2021-08-05 - Fix performance issues with checking URL routes. Copied from Itinerayry Stream..

					I discovered while testing that looking up this function takes about 15ms for each route lookup
					that is unique. The uniqueness was coming from the query string and from different IDs passed into the
					URL. However, the controllers are not resolved via query strings and we do not need to resolve the route
					for each ID, but just the general route. As such we remove the query string and we rewrite all ids
					to '1'. Then when we look up the route, a lot few unique lookups are required. This shaves off about
					300ms per request and should also reduce memory usage of this function by 90%
				*/

				//Remove the query string after the path because it has no impact on the authentication
				var path = listFirst(arguments.link,"?");
				//Replace all instances /route/xxxx with 1 so that all lookups to various
				//ids more quickly resolve to the correct route
				var path = reReplaceNoCase(path, "/[0-9]*$", "/1");
				var path = reReplaceNoCase(path, "/[0-9]*/", "/1/");

				var key = "$#arguments.method##path#";

				// writeDump(this.getPathAction(pathInfo=path, cgiRequestMethod=arguments.method));
				// writeDump(this.processRoutes(path, arguments.routes, arguments.method));
				// abort;

				if(application.routeMatches.keyExists(key)){
					var result = application.routeMatches[key];
				} else {
					// application.routeMatches[key] = this.getPathAction(pathInfo=arguments.path, cgiRequestMethod=arguments.method);
					var result = this.processRoutes(arguments.link, arguments.routes, arguments.method);
					if(result.matched){
						application.routeMatches[key] = result;
					}
				}

				// var result = this.processRoutes(arguments.link, arguments.routes, arguments.method);
				// writeDump(result);
				// abort;
				totalTime += getTickCount() - start;
				return result
			}

			var routes = variables.framework.routes;
			var interfaces = [
				"cfc",
				"cfcMethod",
				"formElement",
				"linkElement",
				"routes",
				"routesFunc",
				"htmlDoc",
				"validation",
				"urlArguments",
				"inputElement"
			]

			var implements = function(cfc, type){

				var metaData = getMetaData(cfc);
				if(metaData.keyExists("implements")){
					if(metaData.implements.keyExists(arguments.type)){
						return true;
					} else {
						writeDump(metaData);
						abort;
						return false;
					}

				} else {
					return false;
				}
			}
			// writeDump(links);
			var linkErrors = [];

			var validations = directoryList("formcheck/validations");

			for(var linkElement in links){

				for(var validation in validations){
					var file = listFirst(getFileFromPath(validation), ".");

					if(arrayFindNoCase(interfaces, file) == 0){
						var validator = createObject("formcheck.validations.#file#");

						if(isInstanceOf(validator, "validation") and isInstanceOf(validator,"linkElement")){
							var args = {};
							if(isInstanceOf(validator, "linkElement")){args.linkElement = linkElement}
							if(isInstanceOf(validator, "htmlDoc")){args.htmlDoc = htmlDoc}
							if(isInstanceOf(validator, "routes")){args.routes = routes}
							if(isInstanceOf(validator, "routesFunc")){args.routesFunc = routesFunc}

							try {

								validator.init(argumentCollection=args);
							} catch(any e){
								linkErrors.append({type:e.type, message:e.message, original:linkElement.toString()});
							}
						}
					}
				}
			}

			var formErrors = [];
			loopForm: for(var formElement in forms){

				for(var validation in validations){
					var file = listFirst(getFileFromPath(validation), ".");

					if(arrayFindNoCase(interfaces, file) == 0){

						var validator = createObject("formcheck.validations.#file#");

						if(isInstanceOf(validator, "validation") and isInstanceOf(validator, "formElement")){

							var args = {};
							if(isInstanceOf(validator, "formElement")){args.formElement = formElement}
							if(isInstanceOf(validator, "htmlDoc")){args.htmlDoc = htmlDoc}
							if(isInstanceOf(validator, "routes")){args.routes = routes}
							if(isInstanceOf(validator, "routesFunc")){args.routesFunc = routesFunc}

							if(isInstanceOf(validator, "cfc") or isInstanceOf(validator, "cfcMethod")){
								try {
									// new formCheck.validations.formRouteNotFound(routesFunc, formElement, routes);
									// new formCheck.validations.missingFormMethod(argumentCollection=args);

									if(formElement.hasAttr('action')){
										var action = formElement.attr('action');
										var action = listFirst(action,"?");
										var method = uCase(formElement.attr('method'));
										var newContext = getPathAction(pathInfo=action, cgiRequestMethod=method);
										// writeDump(newContext);
										// abort;
										var action = newContext.action;
										if(action contains ":"){
											var subsystem = listFirst(action, ":");
										} else {
											var subsystem = variables.framework.defaultSubsystem;
										}
										var subAction = listLast(action, ":");
										var controller = listFirst(subAction, ".");
										var cfcMethod = listLast(subAction, ".");
										// writeDump(action);
										var cfc = getCachedController(subsystem, controller);

										if(isNull(cfc)){
											writeDump("Could not locate the controller, this was unexpected. Check the values below");
											writeDump(subsystem);
											writeDump(controller);
											writeDump(newContext);
											abort;
										}

										if(isInstanceOf(validator, "cfc")){args.cfc = cfc}
										if(isInstanceOf(validator, "cfcMethod")){args.cfcMethod = cfcMethod}
										if(isInstanceOf(validator, "urlArguments")){
											// var urlArgs = {};
											// if(newContext.keyExists("id")){
											// 	urlArgs.id = newContext.id;
											// }
											args.urlArguments = newContext;
										}

										try {
											validator.init(argumentCollection=args);

										} catch(expression e){
											writeDump(args);
												writeDump(validator);
												writeDump(isInstanceOf(validator,""));
												writeDump(e);
												abort;
										} catch(any e){
											formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
											continue loopForm;
										}

										//Check for additional formactions within the form
										// var formActions = formElement.select('button[formaction]');
										// for(var formAction in formActions){

										// 	try {
										// 		new formRouteNotFound()
										// 	}

										// }


									} else {
										formErrors.append({type:"missingFormAction", message:"Forms must have an action attribute", original:formElement.toString()});
										continue loopForm;
									}


								} catch(expression e){
									writeDump(validator);
									writeDump(isInstanceOf(validator,""));
									writeDump(e);
									abort;
								} catch(any e){
									formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
									continue loopForm;
								}


							} else {

								try {
									validator.init(argumentCollection=args);
								} catch(expression e){
										writeDump(validator);
										writeDump(isInstanceOf(validator,""));
										writeDump(e);
										abort;
								} catch(any e){
									formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
									continue loopForm;
								}
							}

						}
					}
				}
			}

			if(linkErrors.len()){
				request._zero.linkErrors = linkErrors;
				writeDump(var=linkErrors, label="Zero detected the following bad links");
			}

			if(formErrors.len()){
				request._zero.formErrors = formErrors;
				writeDump(var=formErrors, label="Zero detected the following incorect forms");
			}
			// writeDump(totalTime);
			// abort;
		}

		this.saveRequest();
		writeOutput(trim(finalOutput));

		if(variables.zero.traceRequests){

			var traces = directoryList(path="./trace", listInfo="name");
			var ids = [];
			for(var traceid in traces){
				ids.append(listFirst(traceid,"."));
			}

			if(arrayLen(ids) == 0){
				nextId = 1;
			} else {
				nextId = arrayLen(ids) + 1
			}

			fileWrite("./trace/#nextId#.html", request.zeroTrace);
		}

		writeLog(file="zero_trace", text="end zero.onRequest()");

		//Clear out the client at the end of the request
		// client = {};
		// structClear(client);
	}

	/* Duplicate and localize setupRequestDefaults() from one.cfc
	* so that we can pass in our own path info and get an action back
	* to manually check the controller
	*/
	private struct function getPathAction(pathInfo=request._fw1.cgiPathInfo,
                                    base=variables.framework.base,
                                    cfcbase=variables.framework.cfcbase,
                                    cgiScriptName=request._fw1.cgiScriptName,
                                    routes=variables.framework.routes,
                                    cgiRequestMethod=request._fw1.cgiRequestMethod) {

        var pathInfo = arguments.pathInfo;
        var base = arguments.base;
        var cfcbase = arguments.cfcbase;
        var cgiScriptName = arguments.cgiScriptName;
        var routes = arguments.routes;
        var cgiRequestMethod = arguments.cgiRequestMethod;

        if ( !structKeyExists(local, 'context') ) {
            local.context = { };
        }
        // SES URLs by popular request :)
        if ( len( pathInfo ) > len( cgiScriptName ) && left( pathInfo, len( cgiScriptName ) ) == cgiScriptName ) {
            // canonicalize for IIS:
            pathInfo = right( pathInfo, len( pathInfo ) - len( cgiScriptName ) );
        } else if ( len( pathInfo ) > 0 && pathInfo == left( cgiScriptName, len( pathInfo ) ) ) {
            // pathInfo is bogus so ignore it:
            pathInfo = '';
        }

        if ( arrayLen( routes ) ) {
            var routeMatch = processRoutes( pathInfo, routes, cgiRequestMethod );
            if ( routeMatch.matched ) {
                if ( variables.framework.routesCaseSensitive ) {
                    pathInfo = rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target );
                } else {
                    pathInfo = rereplacenocase( routeMatch.path, routeMatch.pattern, routeMatch.target );
                }
                if ( routeMatch.redirect ) {
                    location( pathInfo, false, routeMatch.statusCode );
                } else {
                    local.route = routeMatch.route;
                }
            }
        } else if ( variables.framework.preflightOptions && local.cgiRequestMethod == "OPTIONS" ) {
            // non-route matching but we have OPTIONS support enabled
            local.routeMethodsMatched.get = true;
            local.routeMethodsMatched.post = true;
        }

        try {
            // we use .split() to handle empty items in pathInfo - we fallback to listToArray() on
            // any system that doesn't support .split() just in case (empty items won't work there!)
            if ( len( pathInfo ) > 1 ) {
                // Strip leading "/" if present.
                if ( left( pathInfo, 1 ) EQ '/' ) {
                    pathInfo = right( pathInfo, len( pathInfo ) - 1 );
                }
                pathInfo = pathInfo.split( '/' );
            } else {
                pathInfo = arrayNew( 1 );
            }
        } catch ( any exception ) {
            pathInfo = listToArray( pathInfo, '/' );
        }
        var sesN = arrayLen( pathInfo );
        if ( ( sesN > 0 || variables.framework.generateSES ) && getBaseURL() != 'useRequestURI' ) {
            local.generateSES = true;
        }
        for ( var sesIx = 1; sesIx <= sesN; sesIx = sesIx + 1 ) {
            if ( sesIx == 1 ) {
                local.context["action"] = pathInfo[sesIx];
            } else if ( sesIx == 2 ) {
                local.context["action"] = pathInfo[sesIx-1] & '.' & pathInfo[sesIx];
            } else if ( sesIx mod 2 == 1 ) {
                local.context[ pathInfo[sesIx] ] = '';
            } else {
                local.context[ pathInfo[sesIx-1] ] = pathInfo[sesIx];
            }
        }
        // certain remote calls do not have URL or form scope:
        if ( isDefined( 'URL'  ) ) structAppend( local.context, URL );
        if ( isDefined( 'form' ) ) structAppend( local.context, form );
        var httpData = getHttpRequestData();
        if ( variables.framework.enableJSONPOST ) {
            // thanks to Adam Tuttle and by proxy Jason Dean and Ray Camden for the
            // seed of this code, inspired by Taffy's basic deserialization
            var body = httpData.content;
            if ( isBinary( body ) ) body = charSetEncode( body, "utf-8" );
            if ( len( body ) ) {
                switch ( listFirst( CGI.CONTENT_TYPE, ';' ) ) {
                case "application/json":
                case "text/json":
                    try {
                        var bodyStruct = deserializeJSON( body );
                        structAppend( local.context, bodyStruct );
                    } catch ( any e ) {
                        throw( type = "FW1.JSONPOST",
                               message = "Content-Type implies JSON but could not deserialize body: " & e.message );
                    }
                    break;
                default:
                    // ignore -- either built-in (form handling) or unsupported
                    break;
                }
            }
        }
        local.headers = httpData.headers;
        // figure out the request action before restoring flash context:
        if ( !structKeyExists( local.context, "action" ) ) {
            local.context[ "action" ] = getFullyQualifiedAction( variables.framework.home );
        } else {
            local.context[ "action" ] = getFullyQualifiedAction( local.context[ "action" ] );
        }
        if ( variables.framework.noLowerCase ) {
            local.action = validateAction( local.context[ "action" ] );
        } else {
            local.action = validateAction( lCase(local.context[ "action" ]) );
        }
        local.requestDefaultsInitialized = true;
        return local.context;
    }

	/**
	* We have to define our own onSessionStart because fw/1 builds resources rotes before initializing the session. This causes
	* views to be lost for some reason (an issue internal to FW/1). By defining our own onSessionStart and calling
	* loadAvailableControllers() when a new session is created, the routes are generated properly
	*
	*/
	public void function onSessionStart(rc) {

		writeLog(file="zero_trace", text="start onSessionStart()");
		if(isDefined('application.zero.routes')){
			variables.framework.routes = application.zero.routes;
		} else {
			loadAvailableControllers();
		}
		super.onSessionStart();
	}

	/**
	 * Wraps the print object and outputs the result	 *
	 */
	public function print(required any value=""){
		return new lib.print(arguments.value);
	}

	/*
	Will reload the serializer meta data cache. The serializerMetaDataCache
	holds copies of the CFC meta data objects which have been serialized. Loading
	and parsing the meta data is expensive (can be as much as seconds for a complex
	graph).
	 */
	function serializerReload(){
		application._zero.serializerMetaDataCache = {};
	}

	function setupZeroDefaults(){
		variables.zero.serializeControllerOutput = variables.zero.serializeControllerOutput?:false;
		variables.zero.logRequests = variables.zero.logRequests?: false;
		variables.zero.devmode = variables.zero.devmode?: 0;
		variables.zero.throwOnNullControllerResult = variables.zero.throwOnNullControllerResult?: true;
		variables.zero.reloadSerializer = variables.zero.reloadSerializer?: true;
		variables.zero.validateHTMLOutput = variables.zero.validateHTMLOutput?: false;
		variables.zero.argumentCheckedControllers = variables.zero.argumentCheckedControllers?: true;
		variables.zero.equalizeSnakeAndCamelCase = variables.zero.equalizeSnakeAndCamelCase?: true;
		variables.zero.serializeToSnakeCase = variables.zero.serializeToSnakeCase?: true;
		variables.zero.outputNonControllerErrors = variables.zero.outputNonControllerErrors?: false;
		variables.zero.argumentModelValueObjectPath = variables.zero.argumentModelValueObjectPath?: "model";
		variables.zero.argumentValidationsValueObjectPath = variables.zero.argumentValidationsValueObjectPath?: "validations";
		variables.zero.csrfProtect = variables.zero.csrfProtect?: false;
		variables.zero.encodeResultForHTML = variables.zero.encodeResultForHTML ?: false;
		variables.zero.traceRequests = variables.zero.traceRequests ?: false;
		variables.zero.cacheControllers = variables.zero.cacheControllers ?: false;
		variables.zero.cacheRoutes = variables.zero.cacheRoutes ?: false;
		variables.zero.throwOnFirstArgumentError = variables.zero.throwOnFirstArgumentError ?: false;
		variables.zero.throwOnControllerError = variables.zero.throwOnControllerError ?: false;
		variables.zero.checkReloadOrm = variables.zero.checkReloadOrm?:false;
		variables.zero.usingHibernateMigration = variables.zero.usingHibernateMigration?:false;
		variables.zero.rebuildContexts = variables.zero.rebuildContexts?:false;
		variables.zero.useAdvancedGotoVariable = variables.zero.useAdvancedGotoVariable?:true;
		variables.zero.IsZeroAdminEnabled = variables.zero.IsZeroAdminEnabled?:false;
		variables.zero.autoRebuildContexts = variables.zero.autoRebuildContexts?:true;
		if(!structKeyExists(session,"flashStorage")){
			session.flashStorage = {}
		}
		if(isNull(variables.zero.flashStorage)){
			variables.zero.flashStorage = session.flashStorage;
		}
		variables.zero.formStateStorage = variables.zero.formStateStorage ?: session;
		variables.zero.preserveFormStorage = variables.zero.formStateStorage ?: session;
		variables.zero.preserveResponseStorage = variables.zero.formStateStorage ?: session;
		variables.zero.enableIntegrationTests = variables.zero.enableIntegrationTests ?: false;
		variables.zero.integrationsPath = variables.zero.integrationsPath ?: expandPath("integrations");
		variables.zero.useLegacyErrorsStruct = variables.zero.useLegacyErrorsStruct?: false;
		variables.zero.maintainScrollPosition = variables.zero.maintainScrollPosition?: true;

		if(variables.zero.devmode == 0){
			variables.framework.reloadApplicationOnEveryRequest = false;
			variables.zero.cacheRoutes = true;
			variables.zero.cacheControllers = true;
			variables.zero.throwOnControllerError = true;
			variables.zero.throwOnFirstArgumentError = false;
			variables.zero.logRequests = false;
			variables.zero.reloadSerializer = false;
			variables.zero.checkReloadOrm = false;
			variables.zero.rebuildContexts = false;
		}

		if(variables.zero.devmode > 0){
			// var RecordTypeCache = new zero.plugins.zeromodel.Cache();
			// RecordTypeCache.clear();
		}

		if(variables.zero.devmode == 1){
			variables.framework.reloadApplicationOnEveryRequest = true;
			variables.zero.cacheRoutes = false;
			variables.zero.cacheControllers = false;
			variables.zero.throwOnControllerError = false;
			variables.zero.throwOnFirstArgumentError = false;
			variables.zero.reloadSerializer = true;
			variables.zero.checkReloadOrm = true;
			variables.zero.rebuildContexts = false;
		}

		if(variables.zero.devmode == 2){
			variables.framework.reloadApplicationOnEveryRequest = true;
			variables.zero.cacheRoutes = false;
			variables.zero.cacheControllers = false;
			variables.zero.throwOnControllerError = true;
			variables.zero.throwOnFirstArgumentError = true;
			variables.zero.logRequests = true;
			variables.zero.reloadSerializer = true;
			variables.zero.checkReloadOrm = true;
			variables.zero.rebuildContexts = false;
		}

		if(variables.zero.devmode == 3){
			variables.framework.reloadApplicationOnEveryRequest = true;
			variables.zero.cacheRoutes = false;
			variables.zero.cacheControllers = false;
			variables.zero.throwOnControllerError = true;
			variables.zero.throwOnFirstArgumentError = true;
			variables.zero.logRequests = true;
			variables.zero.reloadSerializer = true;
			variables.zero.checkReloadOrm = true;
			variables.zero.rebuildContexts = true;
		}
	}

	/*
     * return the configured routes.
     * 2020-04-19 - Override this from One.cfc so we can load the available controllers if they have not been loaded before
     */
    public array function getRoutes() {
        if(!isDefined('application.zero.routes')){
            loadAvailableControllers();
        }
        return variables.framework.routes;
    }

	function onRequestStart(){

		this.setupZeroDefaults();


		if(variables.zero.reloadSerializer){
			serializerReload();
		}

		/*
		* ZeroContext Admin builder
		* 	This will scan for Contexts and rebuild them
		*/
		if(url.keyExists("rebuild") or variables.zero.rebuildContexts){

			var RecordTypeCache = new zero.plugins.zeromodel.Cache();
			RecordTypeCache.clear();

			ZeroContext = this.getZeroContext();
			// timer type="outline" label="scanForContexts"{
			ZeroContext.scanForContexts();
			// }
			// timer type="outline" label="buildAll" {
			ZeroContext.buildAll(url.clear?:false);
		}

		// if(true) {
		// 	variables.framework.reloadApplicationOnEveryRequest = true;
		// 	variables.zero.cacheRoutes = false;
		// 	variables.zero.cacheControllers = false;
		// 	variables.zero.throwOnControllerError = true;
		// 	variables.zero.throwOnFirstArgumentError = true;
		// 	variables.zero.logRequests = true;
		// 	variables.zero.reloadSerializer = true;
		// 	variables.zero.checkReloadOrm = true;
		// } else {

		// }


		/*
		Have zero change the location of the subsystem path dynamically based on the URL.
		This allows us to have subsystems which are not in the default application's
		subsystems.
		 */
		// if(cgi.path_info contains "/auth/"){
		// 	if(!getSubsystemData().keyExists("auth")){
		// 		variables.framework.base = "/zero/plugins";
		// 	}
		// }

		/*
		Global framework rewrite of the request scope. Allows mimicing HTML 5
		nested form feature, which is not currently supported by Internet Explorer.
		Will introspect the form data and override the copied CGI information
		with the route in the form so what fw/1 routes pick the intended controller
		 */
		if(structKeyExists(form,"zero_form")){
			zeroForms = listToArray(form.zero_form);
			for(zeroFormName in zeroForms){
				if(structKeyExists(form,zeroFormName)){
					formgroup = duplicate(form[zeroFormName]);
					if(structKeyExists(formgroup,"submit")){
						actionPathInfo = replaceNoCase(formgroup.action, copyCGI.SCRIPT_NAME, "");
						copyCGI.path_info = actionPathInfo;
						copyCGI.request_method = formgroup.method;

						originalForm = duplicate(form);
						structClear(form);
						structAppend(form,formgroup.data);
						if(formgroup.preserveParentInputs){
							structAppend(form, originalForm);
						}
					}
				}
			}
		}


		writeLog(file="zero_trace", text="start onRequestStart()");

		if(isNull(application.zero)){application.zero = {}};

		if(
			    application.zero.keyExists("routes") 		//The application key exists
			and variables.zero.cacheRoutes					//And caching is enabled
			and len(application.zero.routes) > 0 			//And we at least have some routes
			and !url.keyExists("refreshApplicationRoutes") 	//And the user is not manually refreshing
		){
			variables.framework.routes = application.zero.routes;
		} else {
			//09-14-2021: Clear out the application rotues and the variables routes
			//as this seems to get duplicated when running unit tests (routesTest.cfc and contextIdText.cfc)
			//against zero from the same server
			// structDelete(application.zero,"routes");
			// structDelete(application.zero,"routes");
			// application.zero.routes = [];
			// variables.framework.routes = [];
			this.loadAvailableControllers();
			application.zero.routes = variables.framework.routes;
		}

		if(!application.keyExists('preloadCache')){
			application.preloadCache = {};
		}

		if(cookie.keyExists('zeropreload')){
			if(application.preloadCache.keyExists(cookie.zeropreload)){

				while(!application.preloadCache[cookie.zeropreload].complete){
					sleep(10);
				}
				// sleep(500);
				writeLog(file="zero", text="output from cache and aborted #cookie.zeropreload#");
				writeOutput(application.preloadCache[cookie.zeropreload].output);
				structDelete(application.preloadCache,cookie.zeropreload);
				structDelete(cookie,"zeropreload");
				structDelete(client,"zeropreload");
				abort;

			} else {
				application.preloadCache[cookie.zeropreload] = {
					complete:false,
					output:""
				}
			}
		}

		super.onRequestStart(argumentCollection=arguments);
	}

	public function serialize(required any value, struct nest={}){
		return new serializer(variables.zero.serializeToSnakeCase).serializeEntity(value, nest);
	}

	/**
	* Experimental method for serializing structures more quickly
	*/
	public function serializeFast(required any value, struct nest={}){
		return new serializerfast(value, nest);
	}

	/*
	Override setupApplicationWrapper() to remove dependency injection which is not needed
	 */
	 private void function setupApplicationWrapper() {

        if ( structKeyExists( request._fw1, "appWrapped" ) ) return;
        request._fw1.appWrapped = true;
        variables.fw1App = {
            cache = {
                lastReload = now(),
                fileExists = { },
                controllers = { },
                routes = { regex = { }, resources = { } }
            },
            subsystems = { },
            subsystemFactories = { }
        };

        /* FRAMEWORK ZERO
         * Comment out IOC and DI code which is not used by framework zero
         *
         */
        // switch ( variables.framework.diEngine ) {
        // case "aop1":
        // case "di1":
        //     var ioc = new "#variables.framework.diComponent#"(
        //         variables.framework.diLocations,
        //         variables.framework.diConfig
        //     );
        //     ioc.addBean( "fw", this ); // alias for controller constructor compatibility
        //     setBeanFactory( ioc );
        //     break;
        // case "wirebox":
        //     if ( isSimpleValue( variables.framework.diConfig ) ) {
        //         // per #363 assume name of binder CFC
        //         var wb1 = new "#variables.framework.diComponent#"(
        //             variables.framework.diConfig, // binder path
        //             variables.framework // properties struct
        //         );
        //         // we do not provide fw alias for controller constructor here!
        //         setBeanFactory( wb1 );
        //     } else {
        //         // legacy configuration
        //         var wb2 = new "#variables.framework.diComponent#"(
        //             properties = variables.framework.diConfig
        //         );
        //         wb2.getBinder().scanLocations( variables.framework.diLocations );
        //         // we do not provide fw alias for controller constructor here!
        //         setBeanFactory( wb2 );
        //     }
        //     break;
        // case "custom":
        //     var ioc = new "#variables.framework.diComponent#"(
        //         variables.framework.diLocations,
        //         variables.framework.diConfig
        //     );
        //     setBeanFactory( ioc );
        //     break;
        // }

		/*
		* ORM Validator
		* 	This OrmValidator is a utility to help validate our models before calling ORM reload.
		* 	It provides a number of validations and information about the ORM models. See the
		*	documentation about turning off specific validations if required. Also see
		* 	'Getting Ready for Production' section.
		*/
		this.setupZeroDefaults();
		// if(variables.zero.checkReloadOrm and ! variables.zero.usingHibernateMigration){
		// 	var OrmValidator = this.getOrmValidator();
		// 	OrmValidator.scan();
		// 	OrmValidator.CheckReloadORM();
		// }

        // this will recreate the main bean factory on a reload:
        internalFrameworkTrace( 'setupApplication() called' );
        setupApplication();
		application[variables.framework.applicationKey] = variables.fw1App;

	}



     private void function setupSubsystemWrapper( string subsystem ) {
        if ( !len( subsystem ) ) return;
        lock name="fw1_#application.applicationName#_#variables.framework.applicationKey#_subsysteminit_#subsystem#" type="exclusive" timeout="30" {
            if ( !isSubsystemInitialized( subsystem ) ) {
                getFw1App().subsystems[ subsystem ] = now();
                // Application.cfc does not get a subsystem bean factory!
                if ( subsystem != variables.magicApplicationSubsystem ) {
                    var subsystemConfig = getSubsystemConfig( subsystem );
                    var diEngine = structKeyExists( subsystemConfig, 'diEngine' ) ? subsystemConfig.diEngine : variables.framework.diEngine;
                    if ( diEngine == "di1" || diEngine == "aop1" ) {
                        // we can only reliably automate D/I engine setup for DI/1 / AOP/1
                        var diLocations = structKeyExists( subsystemConfig, 'diLocations' ) ? subsystemConfig.diLocations : variables.framework.diLocations;
                        var locations = isSimpleValue( diLocations ) ? listToArray( diLocations ) : diLocations;
                        var subLocations = "";
                        for ( var loc in locations ) {
                            var relLoc = trim( loc );
                            // make a relative location:
                            if ( len( relLoc ) > 2 && left( relLoc, 2 ) == "./" ) {
                                relLoc = right( relLoc, len( relLoc ) - 2 );
                            } else if ( len( relLoc ) > 1 && left( relLoc, 1 ) == "/" ) {
                                relLoc = right( relLoc, len( relLoc ) - 1 );
                            }
                            if ( usingSubsystems() ) {
                                subLocations = listAppend( subLocations, variables.framework.base & subsystem & "/" & relLoc );
                            } else {
                                subLocations = listAppend( subLocations, variables.framework.base & variables.framework.subsystemsFolder & "/" & subsystem & "/" & relLoc );
                            }
                        }
                        if ( len( sublocations ) ) {
                            // var diComponent = structKeyExists( subsystemConfig, 'diComponent' ) ? subsystemConfig : variables.framework.diComponent;
                            // var cfg = structKeyExists( subsystemConfig, 'diConfig' ) ?
                            //     subsystemConfig.diConfig : structCopy( variables.framework.diConfig );
                            // cfg.noClojure = true;
                            // var ioc = new "#diComponent#"( subLocations, cfg );
                            // ioc.setParent( getDefaultBeanFactory() );
                            // setSubsystemBeanFactory( subsystem, ioc );
                        }
                    }
                }

                internalFrameworkTrace( 'setupSubsystem() called', subsystem );
                setupSubsystem( subsystem );
            }
        }
    }

    /*
    Override Framework One's controller caching which is very annyoing when doing
    development because full application reloads take a long time.
    Use varabies.zero.cacheControllers to turn on/off controller caching. Default
    is off.
     */
    private any function getCachedController( string subsystem, string section ) {

        setupSubsystemWrapper( subsystem );
        var cache = getFw1App().cache;
        var cfc = 0;
        var subsystemDir = getSubsystemDirPrefix( subsystem );
        var subsystemDot = replace( subsystemDir, '/', '.', 'all' );
        var subsystemUnderscore = replace( subsystemDir, '/', '_', 'all' );
        var componentKey = subsystemUnderscore & section;
        var beanName = section & variables.controllerFolder;
        var controllersSlash = variables.framework.controllersFolder & '/';
        var controllersDot = variables.framework.controllersFolder & '.';

        if(variables.zero.cacheControllers == false){
	        if(structKeyExists(cache.controllers, componentKey)){
	            cache.controllers.delete(componentKey);
	        }
        }

        // per #310 we no longer cache the Application controller since it is new on each request
        if ( !structKeyExists( cache.controllers, componentKey ) || section == variables.magicApplicationController ) {
            lock name="fw1_#application.applicationName#_#variables.framework.applicationKey#_#componentKey#" type="exclusive" timeout="30" {
                if ( !structKeyExists( cache.controllers, componentKey ) || section == variables.magicApplicationController ) {
                    if ( hasSubsystemBeanFactory( subsystem ) && getSubsystemBeanFactory( subsystem ).containsBean( beanName ) ) {
                        cfc = getSubsystemBeanFactory( subsystem ).getBean( beanName );
                    } else if ( !usingSubsystems() && hasDefaultBeanFactory() && getDefaultBeanFactory().containsBean( beanName ) ) {
                        cfc = getDefaultBeanFactory().getBean( beanName );
                    } else {
                        if ( section == variables.magicApplicationController ) {
                            // treat this (Application.cfc) as a controller:
                            cfc = this;
                        } else if ( cachedFileExists( cfcFilePath( request.cfcbase ) & subsystemDir & controllersSlash & section & '.cfc' ) ) {
                            // we call createObject() rather than new so we can control initialization:
                            if ( request.cfcbase == '' ) {
                                cfc = createObject( 'component', subsystemDot & controllersDot & section );
                            } else {
                                cfc = createObject( 'component', request.cfcbase & '.' & subsystemDot & controllersDot & section );
                            }
                            if ( structKeyExists( cfc, 'init' ) ) {
                                cfc.init( this );
                            }
                        } else if ( cachedFileExists( cfcFilePath( request.cfcbase ) & subsystemDir & controllersSlash & section & '.lc' ) ) {
                            // we call createObject() rather than new so we can control initialization:
                            if ( request.cfcbase == '' ) {
                                cfc = createObject( 'component', subsystemDot & controllersDot & section );
                            } else {
                                cfc = createObject( 'component', request.cfcbase & '.' & subsystemDot & controllersDot & section );
                            }
                            if ( structKeyExists( cfc, 'init' ) ) {
                                cfc.init( this );
                            }
                        } else if ( cachedFileExists( cfcFilePath( request.cfcbase ) & subsystemDir & controllersSlash & section & '.lucee' ) ) {
                            // we call createObject() rather than new so we can control initialization:
                            if ( request.cfcbase == '' ) {
                                cfc = createObject( 'component', subsystemDot & controllersDot & section );
                            } else {
                                cfc = createObject( 'component', request.cfcbase & '.' & subsystemDot & controllersDot & section );
                            }
                            if ( structKeyExists( cfc, 'init' ) ) {
                                cfc.init( this );
                            }
                        }
                        if ( isObject( cfc ) && ( hasDefaultBeanFactory() || hasSubsystemBeanFactory( subsystem ) ) ) {
                            autowire( cfc, getBeanFactory( subsystem ) );
                        }
                    }
                    if ( isObject( cfc ) ) {
                        injectFramework( cfc );
                        cache.controllers[ componentKey ] = cfc;
                    }
                }
            }
        }

        if ( structKeyExists( cache.controllers, componentKey ) ) {
            return cache.controllers[ componentKey ];
        }
        // else "return null" effectively
    }

    public function unescapeHTML(required string){
    	//Lucee does not have a function to unescape HTML characters, but we can use the built in
    	//Apache commons library
    	//http://stackoverflow.com/questions/1646839/decode-numeric-html-entities-in-coldfusion
    	var StrEscUtils = createObject("java", "org.apache.commons.lang.StringEscapeUtils");
		var Character = StrEscUtils.unescapeHTML(arguments.string);
		return Character;
    }

    public function zeroPreloadRequested(){
	    var headers = getRequestData().headerdata.headers;
		if(headers.keyExists("x-zero-preload")){
			return true;
		} else {
			return false;
		}
    }

    public function getZeroPreloadTime(){
    	var headers = getRequestData().headerdata.headers;
		if(headers.keyExists("x-zero-preload")){
			return headers["x-zero-preload"];
		} else {
			60;
		}
    }

}