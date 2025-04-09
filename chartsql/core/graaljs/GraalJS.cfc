/**
 * Utility class for working with GraalJS. Allows us to have a similar workflow to working with JavaScript in Lucee.
 * and dump objects and capture the console.
*/
component {

	public function init(){

		variables.ContextClass = createObject("java", "org.graalvm.polyglot.Context");
		var ByteArrayOutputStream = createObject("java", "java.io.ByteArrayOutputStream");
		var OutputStreamWriter = createObject("java", "java.io.OutputStreamWriter").init(ByteArrayOutputStream);
		var contextBuilder = ContextClass.newBuilder(["js"]);

		variables.context = contextBuilder
				.allowAllAccess(true)
				.out(ByteArrayOutputStream)
				.build();
		variables.bindings = context.getBindings("js");

		this.clearConsole();
		context.eval("js", "console.log = function(msg){ _consolelog.push(JSON.stringify(msg)); _consolejson = JSON.stringify(_consolelog); return msg;}");
		context.eval("js", "console.dump = function(obj){
			_luceedump.push(JSON.stringify(obj));
			_luceedumpout = JSON.stringify(_luceedump);
		}");

		return this;
	}

	public function foo(){
		return 'bar';
	}

	public function eval(required string js){

		// Every time we eval, we clear the dump array so we can capture new dumps
		context.eval("js", "_luceedump = [];");
		context.eval("js", "_luceedumpout = '';");

		try {
			context.eval("js", arguments.js);
		}catch(any e){
			this.dumpJsDumpsToLucee();
			throw(e);
			return ;
		}
		this.dumpJsDumpsToLucee();
	}

	public function dumpJsDumpsToLucee(){
		var dumps = deserializeJson(bindings.getMember("_luceedumpout").toString());
		// writeDump(dumps);
		for(var dump in dumps){
			if(isJson(dump)){
				dump = deserializeJson(dump);
			}
			writeDump(dump);
		}
	}

	public function dumpLog(){
		var console = this.getConsole();
		writeDump(console);
	}

	public function evalFiles(required array filePaths){

		for(var filePath in arguments.filePaths){

			if(!fileExists(filePath)){
				//try expanded path
				filePath = expandPath(filePath);
			}

			var jscode = fileRead(filePath);
			context.eval("js", jscode);
		}

	}

	/**
	 * Gets the console as a Lucee array of log messages
	 */
	public function getConsole(){

		var console = bindings.getMember("_consolejson");
		var consoleData = deserializeJson(console.toString());
		var consoleData = consoleData.map(function(item){
			if(isJson(item)){
				return deserializeJson(item);
			}
		});

		return consoleData;
	}

	public function clearConsole(){
		context.eval("js", "_consolelog = [];");
		context.eval("js", "_consolejson = '';");
	}

	public function getMember(member){
		return bindings.getMember(arguments.member);
	}

	/**
	 * Get a member from the GraalJS context and return it as a Lucee object by
	 * first converting it to a JSON string in javascript and then deserializing it in Lucee.
	 */
	public function get(required string member){
		this.eval("_getout = JSON.stringify(" & arguments.member & ");");
		var memberObj = bindings.getMember("_getout");
		var string = memberObj.toString();
		// writeDump(string);
		var out = deserializeJson(memberObj.toString());
		return out;
	}

	/**
	 * Invoked during the start of the custom tag
	 * @param  {struct} required struct        attributes The attributes passed to the custom tag
	 * @param  {struct} required struct        caller     A reference to the variables scope from the location that calls the custom tag
	 * @return {boolean}          To control whether to execute the body of the custom tag
	 */
	public boolean function onStartTag(required struct attributes, required struct caller){
		caller.GraalJS = this;

		if(structKeyExists(attributes, "scripts")){
			this.evalFiles(attributes.scripts);
		}

		return true;
	}

	/**
	 * Invoked after the completion of the closing tag
	 * @param  {struct} required struct        attributes The attributes passed to the custom tag
	 * @param  {struct} required struct        caller     A reference to the variables scope from the location that calls the custom tag
	 * @param  {string} string        generatedContent     The output generated between the start and end tags at the caller
	 * @return {boolean}          To control whether to execute the body of the custom tag
	 */
	public boolean function onEndTag(required struct attributes, required struct caller, string generatedContent){
		this.eval(generatedContent);
		return false;
	}

}