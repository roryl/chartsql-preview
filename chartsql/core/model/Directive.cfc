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
	property name="IsSelectListDefaultValue" type="boolean" default="false" hint="If this is a select-list directive, is the default value selected";
	property name="Errors";
	property name="HasValue";
	property name="IsCommentedOut";
	property name="IsUserNamed" type="boolean" default="false";
	property name="UserName" type="string" default="";
	property name="CoreName" type="string" default="" hint="For user definable directives, this is the core name without the user defined part";
	property name="SelectListSelectedValue" type="string" default="" hint="For select-list directives, this is the selected value from the UI to be used in the SQL";

	public function init(
		required SqlScript SqlScript,
		required string name,
		any Parsed,
		string ValueRaw,
		required struct Validations,
		required boolean IsSupported,
		required boolean IsCommentedOut,
		required boolean IsUserNamed,
		required string UserName = ""
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
		variables.IsUserNamed = arguments.IsUserNamed;
		variables.UserName = arguments.UserName;
		variables.SelectListSelectedValue = "";
		variables.IsSelectListDefaultValue = false;

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

		// If the directive IsUserNamed then we are going to remove the user name
		// from the Name and set it as the core name so we know which real directive
		// it is
		if(variables.IsUserNamed){
			variables.CoreName = replace(variables.Name, variables.UserName, "", "all");
			//Remove trailing '-'
			variables.CoreName = left(variables.CoreName, - 1);
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
				return variables.ValueRaw;
			} else {
				return toString(toBinary(variables.ValueRaw));
			}
		} else {
			return variables.ValueRaw?:"";
		}
	}

	public function resetSelectListSelection(){
		this.setSelectListSelectedValue(variables.Parsed[1]);
	}

	public function setSelectListSelectedValue(string value){
		//Check that the provided value is in the array of options
		if(variables.Parsed.find(value) == 0){
			throw(message="The value '#arguments.value#' provided is not in the list of options for '#variables.name#'", type="InvalidSelectListValue");
		}
		variables.SelectListSelectedValue = arguments.value;

		// writeDump(variables.SelectListSelectedValue == variables.Parsed[1]);
		//If the value is the default value then we are going to set the flag
		if(variables.SelectListSelectedValue == variables.Parsed[1]){
			variables.IsSelectListDefaultValue = true;
		} else {
			variables.IsSelectListDefaultValue = false;
		}

	}

	/**
	 * Returns the Select List Selected Value or the default value if it is not set
	 */
	public function getSelectListSelectedValueOrDefault(){
		if(variables.SelectListSelectedValue == ""){
			return variables.Parsed[1];
		} else {
			return variables.SelectListSelectedValue;
		}
	}
}