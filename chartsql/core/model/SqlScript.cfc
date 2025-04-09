/**
 * This is a class that represents a SQL script that can be used to generate
 * a chart.  It will parse the SQL and find all of the @directives that define
 * the chart
*/
import values.CleanedDirectiveName;
component accessors="true" {
	processingdirective preservecase="true";
	property name="ChartSql" type="ChartSql";
	property name="sql" type="string";
	property name="HandlebarsContext" type="struct" hint="The context from the editor session that was used to evaluate the script with handlebars";

	public function init(
		required ChartSql ChartSql,
		string sql
	){
		variables.ChartSql = ChartSql;
		variables.ChartSql.getSqlScripts().append(this);
		variables.sql = arguments.sql?:"";

		// 2024-10-31: The ExecutionContext will be set by AsyncExecutionRequest when it is settting up
		// the SqlScript. The context will carry details about the user environment that the script can use
		// to render handlebars code
		variables.HandlebarsContext = {};

		variables.supportedDirectives = {
			"chart": true,
			"category": true,
			"series": true,
			"groups": true,
			"formats": true,
			"stacks": true,
			"title": true,
			"subtitle": true,
			"description": true,
			"stacking": true,
			"stacking-mode": true,
			"series-types": true,
			"secondary-series": true,
			"baselines": true,
			"baseline-types": true,
			"series-labels":true,
			"overlay-series": true,
			"mongodb-query": true,
			"tags": true
		}

		// These are the directives that are user named and need to be prefixed with a '-'
		variables.userNamedDirectives = {
			"select-list": true
		}

		// These are the directives that are arrays and need to be converted to arrays
		variables.arrayDirectives = [
			"series",
			 "groups",
			 "formats",
			 "stacks",
			 "series-types",
			 "secondary-series",
			 "baselines",
			 "baseline-types",
			 "series-labels",
			 "overlay-series",
			 "tags",
			 "select-list",
			 "select-list-channel"
		];
		
		// Case sensitive directives
		variables.caseSensitiveDirectives = [
			"select-list",
			"select-list-channel"
		];

		variables.multilineDirectives = [
			"description"
		];

		variables.jsonTypes = {
			"mongodb-query":true
		}

		return this;
	}

	public function countLines(){
		return arrayLen(listToArray(this.getSql(), server.separator.line));
	}

	/**
	 * Returns all of the matches @directive in the SQL
	 */
	public array function matchAtDirectives(){
		// Originally I had (@[a-z:]+) which was incorrect when there
		// were no spaces between the directive and the colon
		// Update the regex from:
		// 		(@[a-zA-z]+:)
		// To:
		// 		((\/{2})?@[a-zA-z]+:)
		// This will allow for comments to be added to the directive. I could not get
		// it to work all from the regex so we have to post process the matches
		// to remove the comments. It seems that Lucee doesn't support not matching groups (?>)
		var out = [];
		var matches = reMatchNoCase("((\/{2})?@[a-zA-z-]+:)", this.getSql());
		for (var item in matches){
			out.append(item);
			// if(item contains "//"){
			// 	// writeDump(item);
			// } else {
			// 	// writeDump(item);
			// 	out.append(item);
			// }
		}
		// var out = reMatchNoCase("(@[a-zA-z]+:)", this.getSql());
		return out;
	}

	public Boolean function doesLineHasAnyDirective(string line) {
		if (line.reFind("--\s+@") > 0 || line.reFind("--\s+//@") > 0) {
			return true;
		}
		return false;
	}

	public boolean function isUserNamedDirective(required string directive){
		var match = this.matchUserNamedDirective(directive);
		return match != "";
	}

	public string function matchUserNamedDirective(required string directive){
		for(var userNamedDirective in variables.userNamedDirectives){
			if(left(directive, len(userNamedDirective)) == userNamedDirective){
				return userNamedDirective;
			}
		}
		return "";
	}

	public string function parseUserNameFromDirective(required string directive, required string userNamedDirective){
		if(userNamedDirective != ""){

			var out = replaceNoCase(directive, userNamedDirective, "", "all");

			if(left(out, 1) == "-"){
				out = trim(replace(out, "-", "", "one"));
			}
			return out;
		}
		return "";
	}

	public Boolean function isLineCommentedOut(string line) {
		if (line.reFind("--\s+//") > 0) {
			return true;
		}
		return false;
	}

	public Boolean function doesLineHasDoubleDashes(string line) {
		if (line.trim().contains("--")) {
			return true;
		}
		return false;
	}

	public string function uncommentLine(line) {
		line = replace(line, "//", "", "one").trim();
		return line;
	}

	public string function commentOutLine(line) {
		// Replace any '--' and any amount of following white space with '-- //'
		line = REReplace(line, "--\s+", "-- //", "one").trim();
		return line;
	}

	public string function cleanLine(line) {
		// Remove any word between '@' and ':' and any amount of following white space
		// line = REReplace(line, "@[a-zA-Z-]+:\s+", "", "one").trim();
		line = line.REReplace("\s+", " ", "all").trim();
		line = replace(line, "//", "", "one").trim();
		line = replace(line, "--", "", "one").trim();
		// Check if the first character is a '@'
		if (left(line, 1) == "@") {
			// Remove any word between '@' and ':' and any amount of following white space
			line = replace(line, "@", "", "one").trim();
		}
		return line;
	}

	public string function toggleDirective(
		required string directiveName
	) {
		var sql = this.getSql();
		var lines = listToArray(sql, server.separator.line);
		var newLines = [];
		var directiveIsAlreadyFound = false;
		var reachedDirectiveLastLine = false;
		var isMultilineDirective = false;

		if (variables.multilineDirectives.contains(directiveName)) {
			isMultilineDirective = true;
		}

		for(var line in lines){
			if (!isMultilineDirective && directiveIsAlreadyFound) {
				newLines.append(line.trim());
				continue;
			}

			if (reachedDirectiveLastLine) {
				newLines.append(line.trim());
				continue;
			}

			if (directiveIsAlreadyFound && (this.doesLineHasAnyDirective(line) || !this.doesLineHasDoubleDashes(line))) {
				reachedDirectiveLastLine = true;
				newLines.append(line.trim());
				continue;
			}

			if (directiveIsAlreadyFound && this.isLineCommentedOut(line)) {
				line = this.uncommentLine(line);
			} else if (directiveIsAlreadyFound && this.doesLineHasDoubleDashes(line)) {
				line = this.commentOutLine(line);
			}

			if(!directiveIsAlreadyFound && this.lineContainsMatchinDirective(line, new CleanedDirectiveName(directiveName))){
				directiveIsAlreadyFound = true;
				if(this.isLineCommentedOut(line)){
					line = this.uncommentLine(line);
				} else {
					line = this.commentOutLine(line);
				}
			}

			newLines.append(line.trim());
		}

		// //If the directive was not found, add it
		// if(!directiveFound){
		// 	// Get the Directive value
		// 	var directives = this.getDirectives();
		// 	abort;

		// 	// Append to the start of the script
		// 	var newSql = "-- @#arguments.directiveName#: \n#server.separator.line##sql#";
		// }

		var newSql = arrayToList(newLines, server.separator.line);
		this.setSql(newSql);
		return newSql;
	}

	/**
	 * Takes the given @directive string and gets the content after
	 * the : until the next line
	 */
	public string function getAtDirectiveContentRaw(required CleanedDirectiveName CleanedDirectiveName){
		//var cleanedName = directiveName.toString().replace("@", "", "one").replace(":", "", "one").replace("//", "", "one").trim();
		var sql = this.getSql();
		var lines = listToArray(sql, server.separator.line);
		var content = "";
		var directiveIsAlreadyFound = false;
		var isMultilineDirective = false;

		if (variables.multilineDirectives.contains(arguments.cleanedDirectiveName.toString())) {
			isMultilineDirective = true;
		}
		for(var line in lines){
			if (!isMultilineDirective && directiveIsAlreadyFound) {
				break;
			}

			if (directiveIsAlreadyFound && (this.doesLineHasAnyDirective(line) || !this.doesLineHasDoubleDashes(line))) {
				break;
			}

			// This will process any following lines for multilines directives
			if (directiveIsAlreadyFound) {
				content = "#content# #this.cleanLine(line)#";
				continue;
			}

			if(!directiveIsAlreadyFound && this.lineContainsMatchinDirective(line, arguments.CleanedDirectiveName)){
				directiveIsAlreadyFound = true;
				content &= this.cleanLine(line);
				continue;
			}
		}

		//Remove the original directive from the content
		content = replace(content, "#arguments.CleanedDirectiveName.toString()#:", "", "all").trim();
		return content;
	}

	/**
	 * Takes an array of the given @directive strings and gets the content after for each
	 *
	 * @directives An array of directive names and contents. The directives will be like:
	 * [
	 * 		"@chart:",
	 * 		"@category:",
	 * 		"//@series:",
	 * ]
	 */
	public struct function getAtDirectiveContents(array directives){

		var out = structNew("ordered");

		var finalArrayDirectives = duplicate(variables.arrayDirectives);

		for (var directive in arguments.directives){
			var finalName = replaceNoCase(directive, "@", "", "all");
			finalName = replaceNoCase(finalName, ":", "", "all");
			out[finalName] = trim(this.getAtDirectiveContentRaw(new CleanedDirectiveName(directive)));

			// If the directive is a user named directive, we need to add the
			// directive to the list of array directives if the core directive
			// is an array directive
			if(this.IsUserNamedDirective(finalName)){

				var userNamedDirective = this.matchUserNamedDirective(finalName);

				if(arrayContainsNoCase(variables.arrayDirectives, userNamedDirective)){
					if(!arrayContainsNoCase(finalArrayDirectives, finalName)){
						finalArrayDirectives.append(finalName);
					}
				}
			}

		}


		// 2024-01-29: out[finalName] will be either like 'chart' or '//chart'
		// for commented out directives. For the check of whether the directive
		// is an array, we also need to check for the commented out version. So
		// we add the commented out version to the arrayDirectives array
		variables.arrayDirectives.each(function(item){
			finalArrayDirectives.append("//#item#");
		});


		for(var arrayField in finalArrayDirectives){
			if(out.keyExists(arrayField)){
				out[arrayField]	= listToArray(
					out[arrayField],
					","
				).map(function(item){
					// Check if the item is in the case sensitive list of directives
					if(variables.caseSensitiveDirectives.contains(arrayField)){
						return trim(item);
					} else {
						return lcase(trim(item));
					}
				})
			}
		}

		var booleanFields = ["stacking"];
		for(var booleanField in booleanFields){
			if(out.keyExists(booleanField)){
				out[booleanField] = out[booleanField] == "true";
			}
		}

		// var base64Fields = ["mongodb-query"];
		// for(var base64Field in base64Fields){
		// 	if(out.keyExists(base64Field)){
		// 		if (!isJson(out[base64Field])) {
		// 			out[base64Field] = ToString(ToBinary(out[base64Field]));
		// 		}
		// 	}
		// }

		return out;
	}

	/**
	 * Returns an execution Id from the query if it was added to
	 * this sql script with tagExecutionId(). This can be used to
	 * identify the query running on the database server that was
	 * initiated from this script
	 */
	public string function getExecutionIdTag(){
		// Example of the tag:
		// -- Execution ID: 97F7340E1E8C40FBBF636D66A55B5ADF
		var matches = reMatchNoCase("-- Execution ID: ([A-Z0-9]+)", this.getSql());
		if(arrayLen(matches) > 0){
			var out = replaceNoCase(matches[1], "-- Execution ID: ", "", "all");
			return out;
		} else {
			return "";
		}
	}

	public struct function getParsedDirectives(){
		var matches = this.matchAtDirectives();
		var out = this.getAtDirectiveContents(matches);
		return out;
	}

	/**
	 * Validates the directives found within the script and returns a struct with an array of errors
	 * if there are any
	 * @forceThrow - If true, will throw an error if the directives are not valid. This is useful for debugging
	 */
	public struct function validateDirectives(required struct directives=this.getParsedDirectives(), forceThrow = false){

		var out = structNew("ordered");
		out.types = {}
		out.errors = [];
		out.errorcount = 0;
		out.types["chart"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["category"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["series"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["groups"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["formats"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["stacks"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["title"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["subtitle"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["description"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["stacking"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["stacking-mode"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["series-types"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["mongodb-query"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["secondary-series"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["baselines"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["baseline-types"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["series-labels"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["overlay-series"] = {name:{}, errors:[], isValid:true, allowEmpty: false};
		out.types["tags"] = {name:{}, errors:[], isValid:true, allowEmpty: false};

		var validChartTypes = {
			"bar": true,
			"column": true,
			"area": true,
			"line":true,
			"pie":true,
			"combo":true,
			"gauge":true,
			"radar": true
		}

		//General validations:
		//Validate @format directive
		var validFormatsTypes = {
			"none": true,
			"currency": true,
			"percent": true,
			"integer": true,
			"decimal": true
		}

		var stackingModeTypes = {
			"normal": true,
			"percent": true
		}

		var validComboTypes = {
			"bar": true,
			"column": true,
			"area": true,
			"line":true
		}

		var validBaselineTypes = {
			"average": true,
			"min": true,
			"max": true,
			"median": true
		}

		for(var nameableKey in directives){

			var userNamedDirective = this.matchUserNamedDirective(nameableKey);

			if(userNamedDirective != ""){

				out.types[nameableKey] = {name:{}, errors:[], isValid:true, allowEmpty: false};

				var name = replaceNoCase(nameableKey, userNamedDirective, "", "all");
				if(left(name, 1) == "-"){
					name = trim(replace(name, "-", "", "one"));
				} else {

					out.types[nameableKey].isValid = false;
					var error = {
						type: "error",
						directive: nameableKey,
						errorClass: "invalidSelectListName",
						title: "User Named Directive Must Be Prefixed",
						message: "The user named directive '#userNamedDirective#' must be prefixed with a '-' after select list like: 'select-list-name'"
					}

					out.types[nameableKey].errors.append(error);
					out.errors.append(error);
				}

				if(name == ""){
					out.types[nameableKey].isValid = false;
					var error = {
						type: "error",
						directive: nameableKey,
						errorClass: "emptySelectListName",
						title: "Empty select-list Name",
						message: "The select-list name must be provided"
					}
					out.types[nameableKey].errors.append(error);
					out.errors.append(error);
				}
			}

		}

		var allSeries = [];
		if(directives.keyExists("series")){
			allSeries = arrayMerge(allSeries, directives.series);
		}

		if(directives.keyExists("secondary-series")){
			allSeries = arrayMerge(allSeries, directives["secondary-series"]);
		}

		// CHART TYPES
		if(directives.keyExists("chart") and !validChartTypes.keyExists(directives.chart)){
			out.types["chart"].isValid = false;
			var error = {
				type: "error",
				directive: "chart",
				errorClass: "invalidChartType",
				title: "Invalid Chart Type",
				message: "'#directives.chart#' is not a valid chart type. Valid chart types are: #validChartTypes.keyList()#"
			}
			out.types["chart"].errors.append(error);
			out.errors.append(error);
		}

		//WHEN @chart IS NOT COMBO THEN @series-types SHOULD NOT EXIST
		if(directives.keyExists("chart") and directives.chart != "combo" and directives.keyExists("series-types")){
			out.types["series-types"].isValid = false;
			var error = {
				type: "error",
				directive: "series-types",
				errorClass: "seriesTypesRequiresComboChart",
				title: "Series Types Should Not Exist",
				message: "The @chart directive is not set to 'combo' so the @series-types directive should not exist"
			}
			out.types["series-types"].errors.append(error);
			out.errors.append(error);
		}

		//COMBO CHARTS MUST HAVE @category or @groups
		if(directives.keyExists("chart") and directives.chart == "combo" and !directives.keyExists("category") and !directives.keyExists("groups")){
			out.types["chart"].isValid = false;
			var error = {
				type: "error",
				directive: "chart",
				errorClass: "comboChartRequiresCategoryOrGroups",
				title: "Combo Chart Requires Category or Groups",
				message: "The @chart directive set to 'combo' requires the @category or @groups directive to be present"
			}
			out.types["chart"].errors.append(error);
			out.errors.append(error);
		}

		// COMBO CHARTS MUST HAVE SERIES
		if(directives.keyExists("chart") and directives.chart == "combo" and !directives.keyExists("series")){
			out.types["chart"].isValid = false;
			var error = {
				type: "error",
				directive: "chart",
				errorClass: "comboChartRequiresSeries",
				title: "Combo Chart Requires Series",
				message: "The @chart directive set to 'combo' requires the @series directive to be present"
			}
			out.types["chart"].errors.append(error);
			out.errors.append(error);
		}

		//COMBO CHARTS MUST HAVE @series-types
		if(directives.keyExists("chart") and directives.chart == "combo" and !directives.keyExists("series-types")){
			out.types["chart"].isValid = false;
			var error = {
				type: "error",
				directive: "chart",
				errorClass: "comboChartRequiresSeriesTypes",
				title: "Combo Chart Requires Series Types",
				message: "The @chart directive set to 'combo' requires the @series-types directive to be present"
			}
			out.types["chart"].errors.append(error);
			out.errors.append(error);
		}

		//COMBO CHARTS MUST HAVE VALID @series-types
		if(directives.keyExists("chart") and directives.chart == "combo" and directives.keyExists("series-types")){
			var seriesTypes = directives["series-types"];
			for(var seriesType in seriesTypes){
				if(!validComboTypes.keyExists(seriesType)){
					out.types["series-types"].isValid = false;
					var error = {
						type: "error",
						directive: "series-types",
						errorClass: "invalidComboChartSeriesType",
						title: "Invalid Combo Chart Type",
						message: "'#seriesType#' is not a valid combo chart type. Valid combo chart types are: #validComboTypes.keyList()#"
					}
					out.types["series-types"].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		// FORMAT TYPES
		if(directives.keyExists("formats")){
			var formats = directives.formats;
			for(var format in formats){
				if(!validFormatsTypes.keyExists(format)){
					out.types["formats"].isValid = false;
					var error = {
						type: "error",
						directive: "formats",
						errorClass: "invalidFormatsType",
						title: "Invalid Format Type",
						message: "'#format#' is not a valid format type. Valid format types are: #validFormatsTypes.keyList()#"
					}
					out.types["formats"].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		// // STACKING MODE TYPES
		// if(directives.keyExists("stacking")){
		// 	var stacking = directives.stacking;
		// 	if(!stackingModeTypes.keyExists(stacking)){
		// 		out.types["stacks"].isValid = false;
		// 		var error = {
		// 			directive: "stacks",
		// 			title: "Invalid Stacking Mode",
		// 			message: "'#stacking#' is not a valid stacking mode. Valid stacking modes are: #stackingModeTypes.keyList()#"
		// 		}
		// 		out.types["stacks"].errors.append(error);
		// 		out.errors.append(error);
		// 	}
		// }

		// IF STACKS EXISTS GROUPS MUST ALSO EXIST
		if(directives.keyExists("stacks") and !directives.keyExists("groups")){
			out.types["stacks"].isValid = false;
			var error = {
				type: "error",
				directive: "stacks",
				errorClass: "stacksRequiresGroups",
				title: "Stacks Directive Requires Groups Directive",
				message: "The @stacks directive requires the @groups directive to be present"
			}
			out.types["stacks"].errors.append(error);
			out.errors.append(error);
		}

		// STACKS FIELDS MUST EXIST IN GROUPS FIELDS
		if(directives.keyExists("stacks") and directives.keyExists("groups")){
			var stacks = directives.stacks;
			var groups = directives.groups;
			for(var stack in stacks){
				if(!groups.containsNoCase(stack)){
					out.types["stacks"].isValid = false;
					var error = {
						type: "error",
						directive: "stacks",
						errorClass: "stacksFieldNotInGroups",
						title: "Stacks Field Not In Groups",
						message: "The @stacks directive contains the field '#stack#' which is not in the @groups directive"
					}
					out.types["stacks"].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		// IF STACKING MODE IS PERCENT THEN STACKS MUST EXIST
		if(directives.keyExists("stacking-mode") and directives["stacking-mode"] == "percent" and !directives.keyExists("stacks")){
			out.types["stacking-mode"].isValid = false;
			var error = {
				type: "error",
				directive: "stackingMode",
				errorClass: "stackingModePercentRequiresStacks",
				title: "Stacking Mode Percent Requires Stacks",
				message: "The @stackingMode directive set to 'percent' requires the @stacks directive to be present"
			}
			out.types["stacking-mode"].errors.append(error);
			out.errors.append(error);
		}

		//CATEGORY AND GROUPS ARE MUTUALLY EXCLUSIVE
		if(directives.keyExists("category") and directives.keyExists("groups")){
			out.types["category"].isValid = false;
			var error = {
				type: "error",
				directive: "category",
				errorClass: "categoryAndGroupsAreMutuallyExclusive",
				title: "Category and Groups Are Mutually Exclusive",
				message: "The @category and @groups directives are mutually exclusive. You can only use one or the other"
			}
			out.types["category"].errors.append(error);
			out.errors.append(error);

			out.types["groups"].isValid = false;
			var error = {
				type: "error",
				directive: "groups",
				errorClass: "categoryAndGroupsAreMutuallyExclusive",
				title: "Category and Groups Are Mutually Exclusive",
				message: "The @category and @groups directives are mutually exclusive. You can only use one or the other"
			}
			out.types["groups"].errors.append(error);
			out.errors.append(error);
		}

		//If is not a valid base64 value add an InvalidBase64 error
		for(var jsonType in variables.jsonTypes){
			if(directives.keyExists(jsonType)){
				var regexToValidateBase64 = "^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$";
				if(reFind(regexToValidateBase64, directives[jsonType]) < 1){
					out.types[jsonType].isValid = false;
					var error = {
						type: "error",
						directive: jsonType,
						errorClass: "InvalidBase64",
						title: "Invalid Base64 Value",
						message: "The value provided for the #jsonType# directive is not a valid Base64 value."
					}
					out.types[jsonType].errors.append(error);
					out.errors.append(error);
				}

				if(!isJson(toString(toBinary(directives[jsonType])))){
					out.types[jsonType].isValid = false;
					var error = {
						type: "error",
						directive: jsonType,
						errorClass: "invalidJson",
						title: "Invalid JSON Value",
						message: "The value provided for the #jsonType# directive is not a valid JSON."
					}
					out.types[jsonType].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		//BASELINES MUST HAVE SERIES OR SECONDARY-SERIES
		if(directives.keyExists("baselines") and !directives.keyExists("series") and !directives.keyExists("secondary-series")){
			out.types["baselines"].isValid = false;
			var error = {
				type: "error",
				directive: "baselines",
				errorClass: "baselinesRequiresSeriesOrSecondarySeries",
				title: "Baselines Requires Series or Secondary Series",
				message: "The @baselines directive requires the @series or @secondary-series directive to be present"
			}
			out.types["baselines"].errors.append(error);
			out.errors.append(error);
		} else

		//BASELINES FIELD MUST EXIST IN SERIES OR SECONDARY-SERIES
		if(directives.keyExists("baselines") and (directives.keyExists("series") or directives.keyExists("secondary-series"))){
			for(var ii = 1; ii <= directives.baselines.len(); ii++){

				var baseline = directives.baselines[ii];
				var foundAt = allSeries.findNoCase(baseline);

				if(foundAt <= 0){
					out.types["baselines"].isValid = false;
					var error = {
						type: "error",
						directive: "baselines",
						errorClass: "baselinesFieldNotInSeriesOrSecondarySeries",
						title: "Baselines Field Not In Series or Secondary Series",
						message: "The @baselines directive contains the field '#baseline#' which is not in the @series or @secondary-series directive"
					}
					out.types["baselines"].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		//BASELINE TYPES MUST BE VALID
		if(directives.keyExists("baseline-types")){
			var baselineTypes = directives["baseline-types"];
			for(var baselineType in baselineTypes){
				if(!validBaselineTypes.keyExists(baselineType)){
					out.types["baseline-types"].isValid = false;
					var error = {
						type: "error",
						directive: "baseline-types",
						errorClass: "invalidBaselineType",
						title: "Invalid Baseline Type",
						message: "'#baselineType#' is not a valid baseline type. Valid baseline types are: #validBaselineTypes.keyList()#"
					}
					out.types["baseline-types"].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		for (directiveName in out.types.keyList()) {
			if (directives.keyExists(directiveName) && !out.types[directiveName].allowEmpty) {
				var directive = directives[directiveName]
				if (isEmpty(directive) || isNull(directive)) {
					out.types[directivename].isValid = false;
					var error = {
						type: "error",
						directive: directivename,
						errorClass: "CantBeEmpty",
						title: "Directive Can't Be Empty",
						message: "This directive is not allowed to be declared with an empty value"
					}
					out.types[directivename].errors.append(error);
					out.errors.append(error);
				}
			}
		}

		out.errorcount = arrayLen(out.errors);
		return out;
	}

	/**
	 * Returns a string that has been evaluated to be executable SQL. We execute any
	 * handlebars code and we strip out any directives
	 */
	public string function getExecutableSQL(){
		var sql = this.stripDirectives();

		var out = "";
		savecontent variable="out" {
			module name="handlebars" context="#variables.HandlebarsContext#" {
				echo(sql);
			}
		}
		return out;
	}

	/**
	 * Gets the directives but only returns the ones that are IsSupported
	 * @return array
	 */
	public Directive[] function getHasValueDirectives(){
		var out = [];
		var directives = this.getDirectives();
		for (var directive in directives){
			if(directive.getHasValue()){
				out.append(directive);
			}
		}
		return out;
	}

	/**
	 * Returns an array of Directive objects that represent all of the directives
	 * found within the script and all supported directives. These will be full value objects
	 * that can be used by the UI to represent the directives
	 */
	public Directive[] function getDirectives(){
		var directives = this.getParsedDirectives();
		var matches = this.matchAtDirectives();
		var rawContents = {};

		// writeDump(matches);

		for (var match in matches){
			var finalName = replaceNoCase(match, "@", "", "all");
			finalName = replaceNoCase(finalName, ":", "", "all");
			rawContents[finalName] = trim(this.getAtDirectiveContentRaw(new CleanedDirectiveName(match)));
		}

		// writeDump(contents);
		// writeDump(directives);

		var validations = this.validateDirectives(directives);

		var seenSupportedDirective = {
			"chart": false,
			"category": false,
			"series": false,
			"groups": false,
			"formats": false,
			"stacks": false,
			"title": false,
			"subtitle": false,
			"description": false,
			"stacking": false,
			"stacking-mode": false,
			"series-types": false,
			"secondary-series": false,
			"baselines": false,
			"baseline-types": false,
			"series-labels":false,
			"overlay-series": false,
			"mongodb-query": false,
			"tags": false
		}

		var out = [];
		for (var directive in directives){

			var IsCommentedOut = false;
			if(directive.contains("//")){
				IsCommentedOut = true;
				var directiveName = replace(directive, "//", "", "all");
			} else {
				var directiveName = directive;
			}

			var userNamedDirective = this.matchUserNamedDirective(directiveName);
			var isUserNamedDirective = userNamedDirective != "";
			var userName = this.parseUserNameFromDirective(directiveName, userNamedDirective);

			//If nots not supported we don't have validations for it
			if(variables.supportedDirectives.keyExists(directive)){
				validationOut = validations.types[directive];
			} else {

				if(isUserNamedDirective){
					validationOut = validations.types[directiveName];
					// writeDump(validationOut);
				} else {
					validationOut = {};
				}
			}

			// Mark if we have seen a supported directive. Use the cleaned up
			// directive without the comment slashes so that it doesn't get
			// duplicated and added to the list twice
			if(variables.supportedDirectives.keyExists(directiveName)){
				seenSupportedDirective[directiveName] = true;
			}

			var Directive = new Directive(
				SqlScript = this,
				Name = directiveName,
				Parsed = directives[directive],
				ValueRaw = rawContents[directive],
				validations = validationOut,
				IsSupported = variables.supportedDirectives.keyExists(directive),
				IsCommentedOut = IsCommentedOut,
				IsUserNamed = isUserNamedDirective,
				UserName = userName
			)
			out.append(Directive);
		}

		//Now we need to add all of the other supported directives that have not yet been seen
		for (var supportedDirective in variables.supportedDirectives){
			if(!seenSupportedDirective[supportedDirective]){
				var Directive = new Directive(
					SqlScript = this,
					Name = supportedDirective,
					validations = {},
					IsSupported = true,
					IsCommentedOut = false,
					IsUserNamed = false
				)
				out.append(Directive);
			}
		}

		return out;
	}

	public function getDetectionMode() {

		/**
		 * DETECTION MODES:
		 * There will be 3 modes that we build charts under, Auto, Semi-Auto and Manual.
		 * AUTO: If there are no directives, we will attempt to build a chart based on the data by inspecting the number of columns of different types
		 * SEMI-AUTO: If there is only one @chart directive, we will attempt to build a chart based on the data in left-to-right order
		 * MANUAL: Otheriwse user must specify the chart type and the data to use
		 */
		var mode = {
			auto: false,
			assist: false,
			manual: false
		}

		// var plottingDirectives = {
		// 	"chart": true,
		// 	"category": true,
		// 	"series": true,
		// 	"groups": true,
		// 	"secondary-series": true,
		// }

		var directives = this.getParsedDirectives();

		//var count the plotting directives found
		// var plottingDirectivesFound = 0;
		// for(var key in plottingDirectives){
		// 	if(directives.keyExists(key)){
		// 		plottingDirectivesFound++;
		// 	}
		// }

		if(directives.keyExists("chart")) {
		 	if (
				!(directives.keyExists("series") or directives.keyExists("secondary-series"))
				or !(directives.keyExists("category") or directives.keyExists("groups"))
			) {
				 return "assist";
			} else if(
				(directives.keyExists("series") or directives.keyExists("secondary-series"))
				and (directives.keyExists("category") or directives.keyExists("groups"))){
				return "manual";
			} else {
				return "assist";
			}
		} else {
			return "auto";
		}
	}

	public function replaceDirectiveText(
		required string directive,
		required string newText
	) {
		var sql = this.getSql();
		var newSql = ReReplaceNoCase(sql, "@#arguments.directive#:([^\n]+)", "@#arguments.directive#: #arguments.newText#", "all");
		this.setSql(newSql);
		return this;
	}

	/**
	 * Given the directive, it removes the whole line that the directive is on and sets the new sql
	 *
	 * @directive
	 */
	public function removeDirectiveLine(required string directive){
		var sql = this.getSql();
		var lines = listToArray(sql, server.separator.line);
		var newLines = [];
		for(var line in lines){
			if(!this.lineContainsMatchinDirective(line, new CleanedDirectiveName(arguments.directive))){
				newLines.append(line);
			}
		}
		variables.sql = arrayToList(newLines, server.separator.line);
		return this;
	}

	/**
	 * If the directive exists, it replaces it, otherwis adds it
	 */
	public function addOrReplaceDirectiveText(required string directive, required string newText){
		var sql = this.getSql();
		var lines = listToArray(sql, server.separator.line);

		// Replace all new lines and tabs to compact the text

		if(variables.jsonTypes.keyExists(directive)){
			newText = toBase64(newText);
		}

		// writeDump(lines);
		var newLines = [];
		var isAppended = false;
		var isFirstDirectiveFound = false;
		var firstDirectiveAt = 0;
		var lastDirectiveAt = 1;
		var hasAtLeastOneDirective = false;

		// We are going to get the line of the last directive after the first
		// directive is found for purposes of putting the new directive at the
		for(var ii=1; ii <= arrayLen(lines); ii++){
			var line = lines[ii];

			if(this.lineContainsMatchinDirective(line, new CleanedDirectiveName(directive))){
				hasAtLeastOneDirective = true;
				this.replaceDirectiveText(directive, newText);
				return;
			} else {
				if(this.lineContainsAnyDirective(line)){
					hasAtLeastOneDirective = true;
					lastDirectiveAt = ii;
				}
			}
		}

		//If we're at the first line, we don't want to add any whitespace
		if(lastDirectiveAt == 1){
			var whitespace = "";
		} else {
			// Otherwise get the whitespace of the preceeding line
			var whitespace = reMatchNoCase("^(\s+)", lines[ii-1]);
			if(arrayLen(whitespace) > 0){
				whitespace = whitespace[1];
			} else {
				whitespace = "";
			}
		}

		var textToInsert = "#whitespace#-- @#directive#: #newText#";
		if (hasAtLeastOneDirective) {
			arrayInsertAt(lines, lastDirectiveAt + 1, textToInsert);
		} else {
			arrayInsertAt(lines, 1, textToInsert);
		}
		variables.sql = arrayToList(lines, server.separator.line);
		return this;
	}

	/**
	 * Unitility function to determine if the given line contains a directive
	 *
	 * @line
	 */
	public boolean function lineContainsAnyDirective(required string line){
		var matches = reMatchNoCase("((\/{2})?@[a-zA-z-]+:)", line);
		return arrayLen(matches) > 0;
	}

	/**
	 * Unitility function to determine if the given line contains the given directive
	 *
	 * @line
	 * @directive
	 */
	public boolean function lineContainsMatchinDirective(required string line, required CleanedDirectiveName directive){
		// 2024-01-31: This doesn't work because we need to match directives
		// that contain hyphens. So we need to match any word character up to :
		// if (!line.contains(":")) {
		// 	return false;
		// }
		// line = line.split(":")[1];
		// @series: or @series-types:
		var matches = reMatchNoCase("((\/{2})?@#arguments.directive.toString()#:)", line);
		return arrayLen(matches) > 0;
	}

	/**
	 * Strips all directives from the SQL
	 */
	public string function stripDirectives(){

		var sql = this.getSql();
		var lines = listToArray(sql, server.separator.line);
		var newLines = [];
		for(var line in lines){
			if(!this.lineContainsAnyDirective(line)){
				newLines.append(line);
			}
		}
		return arrayToList(newLines, server.separator.line);

	}

	/**
	 * Adds a unique identifer to the query that we can use to track the execution
	 * and kill the database process if necessary. This is useful for long running
	 * queries that the user may need to kill from the UI.
	 *
	 * Can use getExecutionIdTag() to get the execution id from the query if one exists
	 */
	public string function tagWithExecutionId(){
		var sql = this.getSql();
		var executionId = replace(createUUID(), "-", "", "all");
		var newSql = "-- Execution ID: #executionId##chr(13)##chr(10)##sql#";
		this.setSql(newSql);
		return executionId;
	}

	/**
	 * Utility function to echo the script in a text area so that we can see it
	 * in the browser with proper formatting
	 */
	public function textarea(){

		echo("<textarea style='width: 800px; height: 600px;'>#this.getSql()#</textarea>");

	}

}