/**

*/
component {

	public function init(required any json){

		if(isStruct(arguments.json)){
			variables.json = serializeJson(arguments.json);
		} else if(isJSON(arguments.json)){
			variables.json = arguments.json;
		} else {
			throw("Invalid JSON");
		}

		var GsonParser = createObject("java", "com.google.gson.JsonParser", "/studio/vendor/gson/gson-2.10.1.jar").init()
		variables.GsonObject = GsonParser.parse(variables.json);
	}

	public function toString(){
		var Gson = createObject("java", "com.google.gson.GsonBuilder", "/studio/vendor/gson/gson-2.10.1.jar").init().setPrettyPrinting().create();
		return Gson.toJson(variables.GsonObject);
	}

}