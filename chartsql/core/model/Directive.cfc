/**
 * Represents a Directive found within a SqlScript. It can either be valid
 * or not valid, but we list them all. This will be used by the Editor to
 * provide intellisense and validation.
*/
component accessors="true" {

	property name="SqlScript" type="SqlScript";
	property name="Name" type="string";
	property name="CleanedName" type="string";
	property name="Parsed" type="any";
	property name="HasErrors" type="boolean" default="true";
	property name="DecodedBase64" type="string";
	property name="ValueRaw" type="string";
	property name="Validations";
	property name="IsValid";
	property name="IsSupported";
	property name="Errors";
	property name="HasValue";
	property name="IsCommentedOut";

	public function init(
		required SqlScript SqlScript,
		required string name,
		any Parsed,
		string ValueRaw,
		required struct Validations,
		required boolean IsSupported,
		required boolean IsCommentedOut
	){

		variables.HasErrors = false;
		variables.name = arguments.name;
		variables.CleanedName = replace(arguments.name, "-", "", "all").trim();
		variables.Parsed = arguments.Parsed;
		variables.ValueRaw = arguments.ValueRaw;
		variables.Validations = arguments.Validations;
		variables.IsValid = true;
		variables.IsSupported = arguments.IsSupported;
		variables.IsCommentedOut = arguments.IsCommentedOut;

		if(arguments.keyExists("Parsed")){
			variables.HasValue = true;
		} else {
			variables.HasValue = false;
		}

		// writeDump(validations);

		if(variables.validations.keyExists("Errors") and variables.Validations.Errors.len() > 0){
			variables.HasErrors = true;
			variables.Errors = variables.Validations.Errors;
		} else {
			variables.Errors = [];
		}

		lowerCaseTypes = {
			"chart":true
		}

		//Lower case the values where the names match the types
		if (lowerCaseTypes.keyExists(arguments.name)){
			variables.ValueRaw = lCase(arguments.ValueRaw);
		}

		return this;
	}

	// public function getValue(){
	// 	if(variables.name == "mongodb-query"){
	// 		if(isJson(variables.ValueRaw)){
	// 			var Gson = new core.model.Gson(variables.valueRaw);
	// 			var out = {
	// 				original: variables.value,
	// 				pretty: Gson.toString()
	// 			}
	// 			return out;
	// 		} else {
	// 			var out = {
	// 				original: variables.value,
	// 			}

	// 			//Attempt to pretty it up by adding line breaks after commas and indenting
	// 			var pretty = variables.value;
	// 			pretty = replace(pretty, ",", ",#server.separator.line##chr(9)#", "all");
	// 			pretty = replace(pretty, "}", "#server.separator.line#}", "all");
	// 			pretty = replace(pretty, "{", "{#server.separator.line##chr(9)#", "all");
	// 			pretty = replace(pretty, "]", "#server.separator.line#]", "all");
	// 			pretty = replace(pretty, "[", "[#server.separator.line##chr(9)#", "all");
	// 			out.pretty = pretty;

	// 			return out;
	// 		}
	// 	} else {
	// 		return variables.ValueRaw?:"";
	// 	}
	// }

	public function getPrettyPrint(){
		if (!isDefined('variables.ValueRaw') || isNull(variables.ValueRaw) || isEmpty(variables.ValueRaw)){
			return "";
		}

		if(variables.name == "mongodb-query"){
			if(isJson(variables.ValueRaw)){
				return formatJSON(variables.ValueRaw);
				// var Gson = new core.model.Gson(variables.valueRaw);
				// return Gson.toString();
			} else {
				return toString(toBinary(variables.ValueRaw));
			}
		} else {
			return variables.ValueRaw?:"";
		}
	}

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
}