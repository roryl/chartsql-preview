/**
 * Represents an installed extension into the ChartSQLStudio system
*/
component accessors="true" {

	property name="ChartSQLStudio";
	property name="Name";

	public function init(
		required ChartSQLStudio ChartSQLStudio,
		required string Name
	){
		variables.ChartSQLStudio = arguments.ChartSQLStudio;
		variables.Name = arguments.Name;
		variables.ChartSQLStudio.addExtension(this);
	}

	public function getExtensionImpl(){
		var ExtensionImpl = createObject("studio.extensions.#variables.Name#");
		ExtensionImpl.setChartSQLStudio(variables.ChartSQLStudio);
		var nameLast = listLast(variables.Name, ".");
		if(structKeyExists(ExtensionImpl, nameLast)){
			ExtensionImpl[nameLast]();
		}
		return ExtensionImpl;
	}

	function onInstall(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onInstall")){
			ExtensionImpl.onInstall();
		}
	}

	function onUninstall(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onUninstall")){
			ExtensionImpl.onUninstall();
		}
	}

	function onRequestStart(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onRequestStart")){
			ExtensionImpl.onRequestStart();
		}
	}

	function onRequest(required struct context){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onRequest")){
			ExtensionImpl.onRequest(arguments.context);
		}
	}

	function onResult(
		required struct requestContext,
		required struct result
	){

		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onResult")){
			ExtensionImpl.onResult(
				requestContext = arguments.requestContext,
				result = arguments.result
			);
		}
	}

	function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onRender")){
			return ExtensionImpl.onRender(
				requestContext = arguments.requestContext,
				result = arguments.result,
				doc = arguments.doc
			);
		} else {
			return arguments.doc;
		}
	}

	function onRequestEnd(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onRequestEnd")){
			ExtensionImpl.onRequestEnd();
		}
	}

	function onError(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onError")){
			ExtensionImpl.onError();
		}
	}

	function onFailure(){
		var ExtensionImpl = getExtensionImpl();
		if(structKeyExists(ExtensionImpl, "onFailure")){
			ExtensionImpl.onFailure();
		}
	}

	public function	getJsoup(){
		var jsoup = application._zero.jsoup = application._zero.jsoup?:createObject("java", "org.jsoup.Jsoup", "formcheck/jsoup-1.13.1.jar");
		return jsoup;
	}
}