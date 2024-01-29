/**
* Utility class for working with Query Recordset objects
*/
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
	 */
	public function getMetaData(){
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
				data: queryColumnData(variables.data, column.name),
				finalType: variables.typeMappings[column.typeName]
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
}