/**
* Utility class for working with Query Recordset objects
*/
import com.chartsql.core.model.values.Datetimeish;
component {
	public function init(required query data){

		variables.data = arguments.data;

		// Map different SQL engine and query types to the types that we wish to
		// detect for charting purposes
		variables.typeMappings = {
			"DATE": "date",
			"NUMERIC": "numeric",
			"BIGINT": "numeric",
			"TIMESTAMP": "datetime",
			"VARCHAR": "string",
			"INTEGER": "numeric",
			"DOUBLE": "numeric",
			"DECIMAL": "numeric",
			"LONGVARCHAR": "string"
		}

		variables.types = {
			"date":{
				count:0,
				columns:structNew("ordered"),
				columnsArray:[]
			},
			"numeric":{
				count:0,
				columns:structNew("ordered"),
				columnsArray:[]
			},
			"datetime":{
				count:0,
				columns:structNew("ordered"),
				columnsArray:[]
			},
			"string":{
				count:0,
				columns:structNew("ordered"),
				columnsArray:[]
			}
		}

		variables.chartTypes = {
			"column":{
				"string":{
					comparison: "EQ",
					digit:1
				},
				"numeric":{
					comparison: "EQ",
					digit:1
				},
			},
			"grouped-column":{
				"string":{
					comparison: "EQ",
					digit:1
				},
				"numeric":{
					comparison: "EQ",
					digit:2
				},
			},
			// "line":{
			// 	"string":{
			// 		comparison: "EQ",
			// 		digit:1
			// 	},
			// 	"numeric":{
			// 		comparison: "GTE",
			// 		digit:2
			// 	},
			// },
			"dateline":{
				"date":{
					comparison: "EQ",
					digit:1
				},
				"numeric":{
					comparison: "GTE",
					digit:1
				},
			},
			"timeline":{
				"datetime":{
					comparison: "EQ",
					digit:1
				},
				"numeric":{
					comparison: "GTE",
					digit:1
				},
			},
			"scatter":{
				"numeric":{
					comparison: "EQ",
					digit:2
				},
			},
			"bubble":{
				"numeric":{
					comparison: "EQ",
					digit:3
				},
			},
			"heatmap": {
				"string":{
					comparison: "EQ",
					digit:2
				},
				"numeric":{
					comparison: "EQ",
					digit:1
				},
			},
		}

		return this;
	}

	/**
	 * Checks through the types and returns the first column that matches
	 * the type otherwise return an Optional
	 */
	public Optional function firstOfTypes(required array types){

		var meta = this.getMetaData();

		for(var type in arguments.types){
			if(meta.types[type].count > 0){
				return new Optional(meta.types[type].columnsArray[1]);
			}
		}

		return new Optional();

	}

	/**
	 * Constructs meta data that we will be to detect how to handle the query
	 * returns for charting purposes
	 * @includeData - whether or not to include the actual data in the meta data
	 * @inferTypes - whether or not to infer the types of the columns by insepcting the data
	 */
	public function getMetaData(
		includeData=true,
		inferTypes=false
	){
		var meta = {};
		meta.columnArray = queryColumnArray(variables.data);
		var columnMeta = getMetaData(variables.data);

		meta.columns = {};
		meta.sourceMeta = columnMeta;
		meta.types = duplicate(variables.types);

		for(var column in columnMeta){
			var colOut = {
				sourcetype: column.typeName,
				name: column.name,
				finalType: variables.typeMappings[column.typeName]
			}

			if(arguments.includeData){
				colOut.data = queryColumnData(variables.data, column.name);
			}

			if(arguments.inferTypes){
				// Infer the type of the column by inspecting the data
				// and then update the finalType
				colOut.sourceType = colOut.finalType;
				var inferredType = this.inferType(queryColumnData(variables.data, column.name))
				colOut.finalType = inferredType.type;
				colOut.inferredLength = inferredType.length;
				colOut.numberish = inferredType.numberish?:false;
				colOut.datetimeish = inferredType.datetimeish?:false;
			}

			meta.columns[column.name] = colOut;

			try {
				var typeMapping = variables.typeMappings[column.typeName];
			}catch(any e){
				writeDump(meta.sourceMeta);
				throw("QueryUtil: No type mapping found for column type: " & column.typeName);
			}

			meta.types[typeMapping].count++;
			meta.types[typeMapping].columns[column.name] = colOut;
			meta.types[typeMapping].columnsArray.append(colOut);
		}
		return meta;
	}

	public string function detectChartType(){
		var meta = this.getMetaData();
		// Loop through all of the chart types that we have defined
		// and try to find a match given the meta data types that we found
		// within the query. Return the first match that we find.
		for(var chartTypeKey in variables.chartTypes){

			var chartType = variables.chartTypes[chartTypeKey];

			//Start out as true, if any are false then it will be false
			var isFound = true;
			for(var typeKey in chartType){

				var type = chartType[typeKey];

				if(!meta.types.keyExists(typeKey)){
					isFound = false;
					// Move onto the next chart type
					break;
				}

				//Now we can evaluate the count of the columnns
				isFound = evaluate("#meta.types[typeKey].count# #type.comparison# #type.digit#");

				if(!isFound){
					break;
				}
			}

			if(isFound){
				return chartTypeKey;
			}
		}
		return "indeterminate";
	}

	public function findFirstFieldNot(required string field){
		var meta = this.getMetaData();
		for(var column in meta.columnArray){
			if(column != arguments.field){
				return column;
			}
		}
		return;
	}

	public function getOtherFieldsMatchingType(required string type, required notField){
		var meta = this.getMetaData();
		var fields = [];
		for(var key in meta.columns){
			var column = meta.columns[key];
			if(column.finalType == arguments.type && column.name != arguments.notField){
				fields.append(column);
			}
		}
		return fields;
	}

	public function getNumericFieldsMatching(required array fieldNames){
		var meta = this.getMetaData();
		// writeDump(meta);
		var fields = [];
		for(var fieldName in arguments.fieldNames){
			if(!meta.types.numeric.columns.keyExists(fieldName)){
				throw("QueryUtil: Column not found: " & fieldName);
			}
			fields.append(meta.types.numeric.columns[fieldName]);
		}
		return fields;
	}

	/**
	 * Infer the type of a column by inspecting the data
	 */
	public struct function inferType(required array data){
		var type = "string";
		var maxLength = 0;

		// Loop through all rows, if all rows match a certain type then we can
		// infer that the column is of that type
		var isDate = true;
		for(var item in arguments.data){
			var maxLength = max(maxLength, len(item));
			if(!isDate(item)){
				isDate = false;
				break;
			}
		}

		if(isDate){
			return {
				type: "date",
				length: maxLength
			};
		}

		var isNumeric = true;
		for(var item in arguments.data){
			var maxLength = max(maxLength, len(item));
			if(!isNumeric(item)){
				isNumeric = false;
				break;
			}
		}

		if(isNumeric){
			return {
				type: "numeric",
				length: maxLength
			};
		}

		var isNumberish = true;
		for(var item in arguments.data){
			// writeDump(item);
			var maxLength = max(maxLength, len(item));
			var numberish = item
				.replace("$", "", "all")
				.replace(",", "", "all")
				.replace("%", "", "all")
				.replace(" ", "", "all")
				.replace("(", "", "all")
				.replace(")", "", "all")
				.replace("€", "", "all")
				.replace("£", "", "all")
				.replace("¥", "", "all")
				.replace("₹", "", "all")
				.replace("₩", "", "all")
				.reReplaceNoCase("([0-9]+)([a-kA-Z]+)", "\1", "all") // Matches 7k, 123m, 1b, etc
				.reReplaceNoCase("([0-9]+[\.][0-9]+)([a-kA-Z]+)", "\1", "all") // Matches 7.5M
				.reReplaceNoCase("([0-9]+)[\^]([0-9]+)", "\1", "all") // 10^2
				;
			if(!isNumeric(numberish)){
				isNumberish = false;
				break;
			}
		}

		if(isNumberish){
			return {
				type: "string",
				length: maxLength,
				numberish: true
			};
		}

		var isDatetimeish = true;
		for(var item in arguments.data){

			//If the record is a valid date then we can skip it
			if(isDate(item)){
				continue;
			}

			var maxLength = max(maxLength, len(item));

			if(Datetimeish::isDate(item)){
				continue;
			} else {
				// new Datetimeish(item);
				isDatetimeish = false;
				break;
			}


			// // We try to convert and replace many types of dates into a format that isDate
			// // can understand. This won't perfectly parse the dates into proper objects, but it will
			// // quickly check if the date is in a format that we could parse later
			// var trials = {
			// 	"MM/DD/YYYY": reReplaceNoCase(item, "([0-9]{2})/([0-9]{2})/([0-9]{4})", "\3-\1-\2", "all"),
			// 	"YYYY-MM-DD": reReplaceNoCase(item, "([0-9]{4})-([0-9]{2})-([0-9]{2})", "\1-\2-\3", "all"),
			// 	"Month D, YYYY": reReplaceNoCase(item, "([a-zA-Z]+) ([0-9]{1,2}), ([0-9]{4})", "\3-\1-\2", "all"),
			// 	"Dth of Month YYYY": reReplaceNoCase(item, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4})", "\2 \1, \3", "all"),
			// 	"HH:MM, DD Month YYYY": reReplaceNoCase(item, "([0-9]{2}):([0-9]{2}), ([0-9]{1,2}) ([a-zA-Z]+) ([0-9]{4})", "\4 \3, \5 \1:\2", "all"),
			// 	"DDth of Month YYYY HH:MM TZ": reReplaceNoCase(item, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\2 \1, \3 \4:\5:00 \6", "all"),
			// 	"YYYY-Month-DD HH:MM:SS TZ+1": reReplaceNoCase(item, "([0-9]{4})-([a-zA-Z]+)-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\1-\2-\3 \4:\5:\6", "all"),
			// 	"MM/DD/YY HH:MM TZ": reReplaceNoCase(item, "([0-9]{2})/([0-9]{2})/([0-9]{2}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\1/\2/19\3 \4:\5:00 \6", "all"),
			// 	"DDst Month YYYY HH:MM TZ": reReplaceNoCase(item, "([0-9]{1,2})st ([a-zA-Z]+) ([0-9]{4}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\2 \1, \3 \4:\5:00 \6", "all"),
			// }

			// // writeDump(parseDateTime("Jun-2021"));

			// var anyKeyIsDate = false;
			// for(var key in trials){
			// 	if(isDate(trials[key])){
			// 		anyKeyIsDate = true;
			// 		break;
			// 	}
			// }

			// if(!anyKeyIsDate){
			// 	isDatetimeish = false;
			// 	break;
			// }
		}

		if(isDatetimeish){
			return {
				type: "string",
				length: maxLength,
				datetimeish: true
			};
		}

		for(var item in arguments.data){
			var maxLength = max(maxLength, len(item));
		}

		// If we haven't found a type yet then we can assume that it is a string
		return {
			type: "string",
			length: maxLength
		};
	}

}