var categoryName = this.directives.get("groups")[0];
var primaryCategoryField = this.data.getFieldByName(categoryName);
var atGroupBy = this.directives.get("groups");
var seriesValues = [];
if (this.directives.keyExists("series") && !(this.directives.get("series") == null) && !(this.directives.get("series") == [])) {
	seriesValues = this.directives.get("series");
} else {
	// Assistive Mode should select the left most numeric column in this case for the series.
	var firstNumericField = this.data.firstFieldOfTypes(["numeric"]);
	if (firstNumericField != null) {
		seriesValues = [firstNumericField.name];
	} else {
		seriesValues = [];
	}
}

if(this.directives.keyExists("secondary-series")){
	var secondarySeriesValues = this.directives.get("secondary-series");
} else {
	var secondarySeriesValues = [];
}

var allSeriesValues = [...seriesValues, ...secondarySeriesValues];

if(atGroupBy.length == 1){

	var workingField = atGroupBy[0];
	if(workingField == categoryName){
		// This is getting the DISTINCT values for the workingField
		// query name="groupByData" dbtype="query" {
		// 	echo("
		// 	SELECT *
		// 	FROM this.data
		// 	GROUP BY #workingField#
		// 	ORDER BY _sortId ASC
		// 	")
		// }
		var groupByData = this.data.selectDistinct([this.data.getFieldByName(workingField)]);

		var categoryData = groupByData.getFieldByName(workingField).columnData;

		var valuesFields = [];

		for(var atValueName in seriesValues){
			valuesFields.push({
				groupField: workingField,
				name: atValueName,
				data: groupByData.columnData(atValueName)
			});
		}

	} else {
		console.log({workingField});
		console.log({categoryName});
		throw("The first groups field must be the category field");
	}

} else if(atGroupBy.length == 2){

	var groupBy1 = atGroupBy[0];
	var groupBy2 = atGroupBy[1];

	if(groupBy1 != categoryName){
		throw("The first groups field must be the category field");
	}

	// First we are going to get the distinct values for groupBy1
	// these will be our category values

	// This is getting the DISTINCT values for the groupBy1
	// TO DO: Create a function called getDistinctData() that will return the distinct values
	// of the data for the given field
	// query name="groupByData" dbtype="query" {
	// 	echo("
	// 	SELECT *
	// 	FROM this.data
	// 	GROUP BY #groupBy1#
	// 	ORDER BY _sortId ASC
	// 	")
	// }

	var groupByData = this.data.selectDistinct([this.data.getFieldByName(groupBy1.trim())]);
	var categoryData = groupByData.getFieldByName(groupBy1).columnData;

	//Now get all of the distinct values for groupBy2
	// query name="groupByData2" dbtype="query" {
	// 	echo("
	// 	SELECT *
	// 	FROM this.data
	// 	GROUP BY #groupBy2#
	// 	ORDER BY _sortId ASC
	// 	")
	// }

	var groupByData2 = this.data.selectDistinct([this.data.getFieldByName(groupBy2.trim())]);

	//Create our series, one for each unique grouypBy2 value
	var valuesFields = [];
	var valuesCount = 0;
	for(var atValue in allSeriesValues){

		// Increment the values count that we will used to get the
		// type of the series if we are a combo chart
		valuesCount++;
		var originalAtValue = atValue;

		isStacking = false;
		isAggregating = false;

		if(atValue.contains("stack(")){
			isStacking = true;
			var atValue = atValue.replace("stack(", "");
			var atValue = atValue.replace(")", "");
		}

		if(atValue.contains("avg(")){
			isAggregating = true;
			var atValue = atValue.replace("avg(", "");
			var atValue = atValue.replace(")", "");
			var aggFunc = "avg";
		}

		if(isAggregating){

			var valuesOut = [];

			for(var groupBy1Name in categoryData){
				var params = {
					'groupBy1Value': {
						type: groupByData.getFieldByName(groupBy1).type, 
						value: groupBy1Name
					},
					// 'groupBy1Value': {type='timestamp', value = paramValue},
				};


				// var sql = "
				// SELECT #aggFunc#([#atValue#]) as #atValue#
				// FROM this.data
				// WHERE #groupBy1# = :groupBy1Value
				// -- We need to group by here in case there are further categories
				// -- that we are not charting on but are in the data
				// GROUP BY #groupBy1#
				// ORDER BY #groupBy1# ASC
				// "

				// query name="groupByData3" dbtype="query" params=params {
				// 	echo(sql)
				// }

				var groupByData3 = this.data.groupByFields(new ChartSQLjs.Aggfunc(
					aggFunc.toLowerCase(), groupByData.getFieldByName(atValue.trim())
				), [this.data.getFieldByName(groupBy1)]);

				valuesOut.push(this.data.getFieldByName(atValue.trim()).columnData[0]);
			}

			if(secondarySeriesValues.includes(originalAtValue)){
				var isSecondarySeries = true;
			} else {
				var isSecondarySeries = false;
			}
			
			// var field = {
			// 	groupField: groupBy1,
			// 	name: atValue,
			// 	data: valuesOut,
			// 	stack: false,
			// 	isSecondarySeries: isSecondarySeries
			// }

			var field = new ChartSQLjs.Field(
				'numeric',
				atValue,
				groupByData,
				isSecondarySeries,
				null,
				false
			);

			if(this.directives.keyExists("series-types")){
				var seriesTypesDirective = this.directives.get("series-types");
				if(valuesCount > seriesTypesDirective.length){
					var seriesType = seriesTypesDirective[seriesTypesDirective.length - 1];
				} else {
					var seriesType = seriesTypesDirective[valuesCount];
				}
				field.type = seriesType;
			}

			valuesFields.push(field);

		} else {

			for(var row in groupByData2){
				var valuesOut = [];
				// Now we need to get the original values for groupBy2 matching
				// the same order as in groupBy1
				for(var groupBy1Name in categoryData){
					var params = {
						groupBy1Value: {type:this.data.getFieldByName(groupBy1.trim()).type, value: groupBy1Name},
						groupBy2Value: {type:this.data.getFieldByName(groupBy2.trim()).type, value: row[groupBy2]},
					};

					// var sql = "
					// 	SELECT #atValue# as #atValue#
					// 	FROM this.data
					// 	WHERE #groupBy1# = :groupBy1Value
					// 	AND #groupBy2# = :groupBy2Value
					// 	-- We need to group by here in case there are further categories
					// 	-- that we are not charting on but are in the data
					// 	GROUP BY #groupBy2#
					// 	ORDER BY #groupBy2# ASC
					// "

					// query name="groupByData3" dbtype="query" params=params {
					// 	echo(sql)
					// }

					var groupByData3 = this.data.groupByFields(new ChartSQLjs.Aggfunc(
						"sum", this.data.getFieldByName(atValue.trim())
					), [this.data.getFieldByName(groupBy2)]);
					valuesOut.push(groupByData3[atValue][0]);
				}

				if(seriesValues.length > 1){
					var name = `${row[groupBy2]} ${atValue}`;
				} else {
					var name = `${row[groupBy2]}`;
				}

				if(secondarySeriesValues.includes(atValue)){
					var isSecondarySeries = true;
				} else {
					var isSecondarySeries = false;
				}

				// var field = {
				// 	groupField: groupBy2,
				// 	name: name,
				// 	data: valuesOut,
				// 	stack: ((isStacking)?atValue:nullValue()),
				// 	isSecondarySeries: isSecondarySeries
				// }

				var field = new ChartSQLjs.Field(
					'numeric',
					name,
					groupByData,
					isSecondarySeries,
					this.data.getFieldByName(groupBy2.trim()),
					isStacking ? atValue : null
				);

				if(this.directives.keyExists("series-types")){
					var seriesTypesDirective = this.directives.get("series-types");
					if(valuesCount > seriesTypesDirective.length){
						var seriesType = seriesTypesDirective[seriesTypesDirective.length - 1];
					} else {
						var seriesType = seriesTypesDirective[valuesCount];
					}
					field.type = seriesType;
				}

				valuesFields.push(field);
			}
		}
	}
} else {
	throw("Not yet handled more than 2 group by");
}