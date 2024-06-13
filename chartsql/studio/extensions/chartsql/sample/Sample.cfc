/**
*/
component accessors="true" {

	property name="ChartSQLStudio";

	public function Sample(
	){

	}

	function onInstall(){

	}

	function onUninstall(){

	}

	function onRequestStart(){

	}

	function onRequest(required struct context){

	}

	function onResult(
		required struct requestContext,
		required struct result
	){

	}

	function onRender(
		required struct requestContext,
		required struct result,
		required object doc
	){

	}

	function onRequestEnd(){

	}

	function onError(){

	}

	function onFailure(){

	}

	remote struct function echo(){
		return arguments;
	}

}