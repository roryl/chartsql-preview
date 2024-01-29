/**
 * Reads and writes a config file in HJson format
*/
component accessors="true" {

	property name="Path" type="string" hint="The path to the config file" required="true";
	property name="Json";

	public function init(
		string path
	){

		if(arguments.keyExists("path")){
			variables.path = arguments.path;
		}

		variables.Json = {};

		// variables.Stringify = createObject("java", "org.hjson.Stringify", "/studio/vendor/hjson/hjson-3.1.0.jar");
		// variables.JsonValue = createObject("java", "org.hjson.JsonValue", "/studio/vendor/hjson/hjson-3.1.0.jar");
		// variables.json5 = createObject("java", "de.marhali.json5.Json5", "/studio/vendor/json5/json5-java-2.0.0.jar");
	}

	static function fromFile(required string path){
		var ConfigFile = new ConfigFile();
		ConfigFile.parse(fileRead(arguments.path));
		return ConfigFile;
	}

	static function fromString(required string configString){
		var ConfigFile = new ConfigFile();
		ConfigFile.parse(arguments.configString);
		return ConfigFile;
	}

	static function fromStruct(required struct config){
		var ConfigFile = new ConfigFile();
		ConfigFile.setJson(arguments.config);
		return ConfigFile;
	}

	public function parse(required string configString){
		variables.Json = deserializeJson(configString);
	}

	public function getGson(){
		var out = {
			Gson: createObject("java", "com.google.gson.GsonBuilder", "/studio/vendor/gson/gson-2.10.1.jar").init().setPrettyPrinting().create(),
			GsonParaser: createObject("java", "com.google.gson.JsonParser", "/studio/vendor/gson/gson-2.10.1.jar").init()
		}
		return out;
	}

	public function textarea(){
		// var hjsonString = variables.JsonObject.toString(variables.Stringify.HJSON);
		var Gson = this.getGson();
		var GsonObject = Gson.GsonParaser.parse(serializeJson(variables.Json));
		var gsonString = Gson.Gson.toJson(GsonObject);
		echo('<textarea style="width:400px; height:600px;">#gsonString#</textarea>');
	}

	public function write(required struct config=this.getJson()){
		var Gson = this.getGson();
		var GsonObject = Gson.GsonParaser.parse(serializeJson(arguments.config));
		var gsonString = Gson.Gson.toJson(GsonObject);
		if(isNull(variables.path)){
			throw("ConfigFile: Path is required");
		}
		fileWrite(variables.path, gsonString);
	}

	/**
	 * Adds the key and value to the config object
	 */
	public function put(string key, any value){

		//If value is not a simpleValue, then we are going to convert it to JSON
		//and then parse it with HJSON so that we can set the value as a complex object
		if (isSimpleValue(arguments.value)){
			var parsedValue = arguments.value;
		} else {
			var serializedValue = serializeJson(arguments.value);
			var parsedValue = variables.JsonValue.readHjson(serializedValue);
		}
		variables.JsonObject.set(arguments.key, parsedValue);
	}
}