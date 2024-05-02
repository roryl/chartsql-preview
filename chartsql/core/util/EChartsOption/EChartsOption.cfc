/**
* Given a query and directives, returns an options struct to use with echarts
*/
import app.util.*;
component {
	processingdirective preserveCase="true";
	public function init(
		required query data,
		required struct directives,
		boolean animation = false,
		boolean renderInline = false
	){
		variables.data = arguments.data;
		variables.directives = arguments.directives;
		variables.QueryUtil = new core.util.QueryUtil(arguments.data);
		variables.metaData = variables.QueryUtil.getMetaData();
		variables.animation = arguments.animation;
		variables.renderInline = arguments.renderInline;

		if(variables.directives.keyExists("fail-rendering")){
			throw("Fail rendering directive specified");
		}

		return this;
	}

	/**
	* Renders to the page. For testing purposes only
	*/
	public function render(
		width = "100%",
		height = "100%",
		struct option
	){

		if(!arguments.keyExists("option")){
			var option = this.getOption();
		} else {
			var option = arguments.option;
		}

		var context = {
			Width: arguments.width,
			Height: arguments.height,
			ContainerId: "chart_#replace(createUUID(), "-", "", "all")#",
			option: serializeJson(option)
		};

		```
		<cf_handlebars context="#context#">
			<cfoutput>
				<div style="{{##if Width}}width:{{Width}};{{/if}} {{##if Height}}height:{{Height}};{{/if}}">
					<div id="{{ContainerId}}" style="width:100%; height:100%;"></div>
				</div>
			</cfoutput>
		</cf_handlebars>
		<cfsavecontent variable="script">
			<cf_handlebars context="#context#">
				<script src="/assets/vendor/apache-echarts/echarts.min.js"></script>
				<script id="chart-data-{{ContainerId}}" type="application/json"><cfoutput>{{{option}}}</cfoutput></script>
				<script>

					var chartFunc{{ContainerId}} = function(){

						var content = document.getElementById('chart-data-{{ContainerId}}').innerHTML;
						var option = JSON.parse(content);

						// We need to look into the option yAxis label formatters, if it exists
						// then we need to eval it and add it to each of the series labels
						// this code below is in javascript not Lucee

						if(typeof option.tooltip != "undefined" && typeof option.tooltip.formatter != "undefined"){
							eval(option.tooltip.formatter);
							option.tooltip.formatter = func;
						}
						
						if(
							typeof option.tooltip != "undefined"
							&& typeof option.tooltip.axisPointer != "undefined"
							&& typeof option.tooltip.axisPointer.label != "undefined"
							&& typeof option.tooltip.axisPointer.label.formatter != "undefined"
						){
							eval(option.tooltip.axisPointer.label.formatter);
							option.tooltip.axisPointer.label.formatter = func;
						}

						//Only execute if our option has a yAxis
						if(typeof option.yAxis != "undefined"){
							//Loop over each of the yAxis
							for(let ii=0; ii < option.yAxis.length; ii++){

								//If the yAxis has a formatter, we need to eval it
								if(typeof option.yAxis[ii].axisLabel != "undefined"){
									if(typeof option.yAxis[ii].axisLabel.formatter != "undefined"){
										eval(option.yAxis[ii].axisLabel.formatter);
										option.yAxis[ii].axisLabel.formatter = func;
									}
								}

							}
						}

						// Evaluate xAxis label formatter
						if(typeof option.xAxis != "undefined"){
							//Loop over each of the yAxis
							for(let ii=0; ii < option.xAxis.length; ii++){

								//If the yAxis has a formatter, we need to eval it
								if(typeof option.xAxis[ii].axisLabel != "undefined"){
									if(typeof option.xAxis[ii].axisLabel.formatter != "undefined"){
										eval(option.xAxis[ii].axisLabel.formatter);
										option.xAxis[ii].axisLabel.formatter = func;
									}
								}

							}
						}

						// Look into series label formatters, if it exists then we need to eval it and add it to each of the series labels
						// this code below is in javascript not Lucee

						//Only execute if our option has a series
						if(typeof option.series != "undefined"){
							//Loop over each of the series
							for(let ii=0; ii < option.series.length; ii++){

								//If the series has a formatter, we need to eval it
								if(typeof option.series[ii].label != "undefined"){
									if(typeof option.series[ii].label.formatter != "undefined"){
										eval(option.series[ii].label.formatter);
										option.series[ii].label.formatter = func;
									}
								}

							}
						}

						// for(let ii=0; ii < option.yAxis.length; ii++){

						// 	//If the yAxis has a formatter, we need to eval it
						// 	if(typeof option.yAxis[ii].axisLabel != "undefined"){
						// 		if(typeof option.yAxis[ii].axisLabel.formatter != "undefined"){
						// 			eval(option.yAxis[ii].axisLabel.formatter);
						// 			option.yAxis[ii].axisLabel.formatter = func;
						// 		}
						// 	}

						// }

						var chartDom = document.getElementById('{{ContainerId}}');
						var myChart{{ContainerId}} = echarts.init(chartDom, 'dark');

						//If the option contains _scatterSize, we need to eval it and add it to each of the series
						// this code below is in javascript not Lucee

						//Check if the option contains _scatterSize
						if(option._scatterSize){
							var scatterFunc = eval(option._scatterSize);
							// console.log(scatterFunc);
							for(var ii=0; ii<option.series.length; ii++){
								// console.log(option.series[ii]);
								option.series[ii].symbolSize = scatterFunc;
							}
						}

						// Add window resize event listener
						window.addEventListener('resize', function() {
							myChart{{ContainerId}}.resize();
						});

						window.chartHandle = myChart{{ContainerId}};

						// var funcTest{{ContainerId}} = function(){
						// 	console.log("test");
						// }
						// funcTest{{ContainerId}}();

						option && myChart{{ContainerId}}.setOption(option);
					}
					chartFunc{{ContainerId}}();
				</script>
			</cf_handlebars>
		</cfsavecontent>
		<cfif variables.renderInline>
			<cfoutput>#script#</cfoutput>
		<cfelse>
			<cfhtmlbody action="append"><cfoutput>#script#</cfoutput></cfhtmlbody>
		</cfif>
		```
	}

	public function getOption(){

		var option = this.getCoreOption();
		if(!isNull(option)){
			this.decorateWithGlobals(option);
		}

		if(variables.directives.keyExists("formats")){
			this.decorateAxisWithFormats(option, variables.directives.formats);
		}

		if (!option.keyExists('tooltip')) {
			option.tooltip = {
				trigger: 'axis',
				axisPointer: {
					type: 'cross',
					label: {
						backgroundColor: '##6a7985'
					}
				}
			}

			if (
				isDefined("variables.directives.formats") 
				&& !isNull(variables.directives.formats) 
				&& isArray(variables.directives.formats)
				&& variables.directives.formats.len() > 0
				&& option.keyExists('series')
			) {
				var mainAxisDimension = "x";
				// if (variables.directives.chart == 'bar' || variables.directives.chart == 'combo') {
				// 	mainAxisDimension = "x";
				// }

				option.tooltip.axisPointer.label.formatter = "var func = function(params) {
					try {
						var formats = #serializeJSON(variables.directives.formats)#;
						var mainAxisDimension = '#mainAxisDimension#';
						var format = 'decimal';
						if (formats.length > params.axisIndex) {
							format = formats[params.axisIndex];
						}

						// If params.value is a date, then use params.value[1] as the value
						if (Array.isArray(params.value)) {
							params.value = params.value[1];
						}

						if (params.axisDimension == 'x' && params.seriesData != undefined && params.seriesData.length > 0 && 'componentType' in params.seriesData[params.axisIndex] && params.seriesData[params.axisIndex].componentType == 'series') {
							return new Date(params.value).toLocaleDateString();
						}

						if (params.value != null && !isNaN(params.value)) {
							if (format == 'currency') {
								return `$${params.value.toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`;
							} else if (format == 'percent') {
								return `${Math.round(params.value)}%`;
							} else if (format == 'integer') {
								return `${Math.round(params.value)}`;
							} else if (format == 'decimal') {
								return `${params.value.toFixed(2)}`;
							} else {
								return params.value;	
							}
						} else {
							return params.value;
						}
					} catch (error) {
						console.log('Error in tooltip formatter');
						console.log({error});
						if (Array.isArray(params.value)) {
							params.value = params.value[1];
						}
						return params.value;
					}
				}";

				option.tooltip.formatter = "var func = function(params) {
					try {
						var result = '';
						if (params.length > 0 && params[0].name != undefined && params[0].name != null && params[0].name != '') { 
							result = params[0].name + '<br>';
						}
						var formats = #serializeJSON(variables.directives.formats)#;
						var format = 'decimal';
						for (var i = 0; i < params.length; i++) {
							if (formats.length > i) {
								format = formats[i];
							}

							// If params.value is a date, then do nothing
							if (Array.isArray(params[i].value)) {
								params[i].value = params[i].value[1];
							}

							if (params[i].axisDimension == 'x' && params[i].seriesData != undefined && params[i].seriesData.length > 0 && 'componentType' in params[i].seriesData[params[i].axisIndex] && params[i].seriesData[params[i].axisIndex].componentType == 'series') {
								return new Date(params[i].value).toLocaleDateString();
							}

							if (format == 'currency') {
								result += `${params[i].marker} <b>${params[i].seriesName}</b>: $${params[i].value.toLocaleString()}<br>`;
							} else if (format == 'percent') {
								result += `${params[i].marker} <b>${params[i].seriesName}</b>: ${params[i].value.toLocaleString()}%<br>`;
							} else if (format == 'integer') {
								result += `${params[i].marker} <b>${params[i].seriesName}</b>: ${Math.round(params[i].value)}<br>`;
							} else if (format == 'decimal') {
								result += `${params[i].marker} <b>${params[i].seriesName}</b>: ${params[i].value.toFixed(2)}<br>`;
							} else {
								result += `${params[i].marker} <b>${params[i].seriesName}</b>: ${params[i].value.toLocaleString()}<br>`;
							}
					   }
						return result;
					} catch (error) {
						console.log('Error in tooltip formatter');
						console.log({error});
						var result = params[0].name + '<br>';
						for (var i = 0; i < params.length; i++) {
							 result += `${params[i].marker} <b>${params[i].seriesName}</b>: ${params[i].value.toLocaleString()}<br>`;
						}
					}
				}";
			}
		}

		if (option.keyExists('series')) {
			for (i = 1; i < (option.series.len() + 1); i++) {
				if (option.series[i].keyExists('name') && isInstanceOf(option.series[i].name, "string")) {
					option.series[i].name = this.cleanName(option.series[i].name);
				}
			}
		}

		if (option.keyExists('xAxis')) {
			if (isArray(option.xAxis)) {
				for (i = 1; i < (option.xAxis.len() + 1); i++) {
					if (option.xAxis[i].keyExists("type") && option.xAxis[i].type == "category") {
						for (j = 1; j < (option.xAxis[i].data.len() + 1); j++) {
							if (isInstanceOf(option.xAxis[i].data[j], "string")) {
								option.xAxis[i].data[j] = this.cleanName(option.xAxis[i].data[j]);
							}
						}
					}
				}
			} else {
				if (option.xAxis.keyExists("type") && option.xAxis.type == "category") {
					for (j = 1; j < (option.xAxis.data.len() + 1); j++) {
						if (isInstanceOf(option.xAxis.data[j], "string")) {
							option.xAxis.data[j] = this.cleanName(option.xAxis.data[j]);
						}
					}
				}
			}
		}



		// ---------------------------------
		// RESHAPE DATA FOR STACKIG AND TIME
		// ---------------------------------
		// When we have stacking and/or we have time component, the data needs to be
		// reshaped to fit the format that echarts expects. Stacking we need to calculate
		// the totals for each category and then add that to the series data. This stacking
		// must be done before stitching the time series together.
		if(variables.directives.keyExists("stacking-mode") and variables.directives["stacking-mode"] == "percent"){
			this.normalizeValueFieldsToPercent(option.series);
			option.yAxis[1].max = 100;
			option.yAxis[1].axisLabel.formatter = "var func = function(value) {
				return value.toLocaleString() + '%';
			}";
		}

		// When we have a time component, we need to stitch the date and the value together in the
		// series data as eCharts expects time series to be in the format [[date,value],[date,value]]
		if(isDefined('option.xAxis[1].type')){
			if(option.xAxis[1].type == "time"){
				for(var seriesItem in option.series){
					var dataOut = this.stitchDateSeries(
						categoryData = option.xAxis[1].data,
						seriesData = seriesItem.data
					);
					seriesItem.data = dataOut;
				}
			}
		}

		if(variables.directives.keyExists("baselines")){

			for(var ii = 1; ii <= variables.directives.baselines.len(); ii++){

				var baselineSeriesName = variables.directives.baselines[ii];
				var allSeries = this.getAllSeriesDirectivesValues();
				var seriesPosition = allSeries.findNoCase(baselineSeriesName);

				if(variables.directives.keyExists("baseline-types")){
					var baselineType = this.matchOrdinalPosition(
						pos = ii,
						target = variables.directives["baseline-types"]
					);
				} else {
					var baselineType = "average";
				}

				if(!option.series[seriesPosition].keyExists("markLine")){
					option.series[seriesPosition].markLine = {
						symbol: 'none',
						silent: true, // Disable interaction
						label: {
							position: 'insideEndTop',
							formatter: '{b}' // Custom label, optional
						},
						data: [
						],
					}
				}

				option.series[seriesPosition].markLine.data.append({
					type: '#baselineType#',
					name: '#properCase(baselineType)# #option.series[seriesPosition].name#',
					lineStyle: {
						type: 'solid', // Optional styling
						width:'3',
						color: option.color[option.series.len() + ii]
					}
				});
			}
		}

		// ---------------------------------
		// SERIES LABELS
		// ---------------------------------
		// Data labels that go above, below or around each series item
		if(variables.directives.keyExists("series-labels")){

			for(var ii = 1 ; ii <= option.series.len(); ii++){
				var labelItem = this.matchOrdinalPosition(
					pos = ii,
					target = variables.directives["series-labels"]
				);

				if(labelItem == "false"){ continue; }
				if(labelItem == "true"){ labelItem = "inside"; }

				option.series[ii].label = {
					show: true,
					position: labelItem
				}

				if(variables.directives.keyExists("formats")){

					var format = this.matchOrdinalPosition(
						pos = ii,
						target = variables.directives["formats"]
					);

					switch(format){

						case "none":
							// Do nothing with the formatter
						break;

						case "currency":
							option.series[ii].label.formatter = "var func = function(obj) {
								// check if is array
								if(Array.isArray(obj.value)){
									var value = obj.value[1];
								} else {
									var value = obj.value;
								}
								return '$' + value.toLocaleString();
							}";
						break;

						case "percent":
							option.series[ii].label.formatter = "var func = function(obj) {
								// check if is array
								if(Array.isArray(obj.value)){
									var value = obj.value[1];
								} else {
									var value = obj.value;
								}
								return value.toLocaleString() + '%';
							}";
						break;

						case "integer":
							option.series[ii].label.formatter = "var func = function(obj) {
								// check if is array
								if(Array.isArray(obj.value)){
									var value = obj.value[1];
								} else {
									var value = obj.value;
								}
								return Math.round(value);
							}";
						break;

						case "decimal":
							option.series[ii].label.formatter = "var func = function(obj) {
								// check if is array
								if(Array.isArray(obj.value)){
									var value = obj.value[1];
								} else {
									var value = obj.value;
								}
								return value.toFixed(2);
							}";
						break;
					}
				}
			}
		}

		// ---------------------------------
		// OVERLAY SERIES
		// ---------------------------------
		// Overlay series are series that are adjusted to overlay one on top of the other
		if(variables.directives.keyExists("overlay-series")){

			var overlaySeries = variables.directives["overlay-series"];

			for(var ii = 1; ii <= overlaySeries.len(); ii++){

				var overlaySeriesName = overlaySeries[ii];
				var allSeries = this.getAllSeriesDirectivesValues();
				var seriesPosition = allSeries.findNoCase(overlaySeriesName);
				option.series[seriesPosition].barWidth = "80%";
				// option.series[seriesPosition].barGap = "0%";
				// option.series[seriesPosition].barGap = "-100%";

			}

			for(var ii = 2; ii <= overlaySeries.len(); ii++){

				var overlaySeriesName = overlaySeries[ii];
				var allSeries = this.getAllSeriesDirectivesValues();
				var seriesPosition = allSeries.findNoCase(overlaySeriesName);
				// option.series[seriesPosition].barWidth = "80%";
				option.series[seriesPosition].barGap = "-80%";
				option.series[seriesPosition].barWidth = "50%";

			}
		}

		return option?:nullValue();
	}

	/**
	* Capitalizes the first letter in each word.
	* Made udf use strlen, rkc 3/12/02
	* v2 by Sean Corfield.
	* v3 by Chris Jordan
	*
	* @param string      String to be modified. (Required)
	* @return Returns a string.
	* @author Raymond Camden (ray@camdenfamily.com)
	* @version 3, March 9, 2007
	**/
	public string function properCase(str){
		var local = {};

		local.newstr = '';
		local.word = '';
		local.separator = '';
		local.str = lcase(arguments.str);

		for(local.i = 1; local.i <= listlen(local.str,' '); local.i++){
			local.word = listgetat(local.str,local.i,' ');
			if(refind("^mc+",local.word) || refind("^o'+",local.word)){
				local.newstr &= local.separator & ucase(left(local.word,1)) & mid(local.word,2,1) & ucase(mid(local.word,3,1));
				if(len(local.word) > 3){
					local.newstr &= right(local.word,len(local.word)-3);
				}
			}
			else{
				//just a regular word...
				local.newstr &= local.separator & ucase(left(local.word,1));
				if(len(local.word) > 1){
					local.newstr &= right(local.word,len(local.word)-1);
				}
			}

			local.separator = ' ';
		}

		return local.newstr;
	}

	/**
	 * Utility method to get the same matching ordinal position item from an array given
	 * the source array and the item to match on. If the source array is larger than the
	 * target array, then we will return the last item in the target array. This supports
	 * the "fall through" of the last item in the target array being used for all remaining
	 * items in the source array for directives.
	 */
	public function matchOrdinalPosition(
		required numeric pos,
		required array target
	){
		if(arguments.pos > arrayLen(arguments.target)){
			return arguments.target[arrayLen(arguments.target)];
		} else {
			return arguments.target[arguments.pos];
		}
	}

	public function decorateAxisWithFormats(
		required struct option,
		required array formats
	){

		var yAxis = option.yAxis;
		var xAxis = option.xAxis;

		// Check whether the yAxis or the xAxis has the series,

		var format1 = formats[1];

		var doFormat = function(AxisItem, pos, formats){

			var format = this.matchOrdinalPosition(
				pos = arguments.pos,
				target = arguments.formats
			);

			switch(format){

				case "none":
					// Do nothing with the formatter
				break;

				case "currency":
					arguments.AxisItem.axisLabel.formatter = "var func = function(value) {
						return '$' + value.toLocaleString();
					}";
				break;

				case "percent":
					arguments.AxisItem.axisLabel.formatter = "var func = function(value) {
						return value.toLocaleString() + '%';
					}";
				break;

				case "integer":
					arguments.AxisItem.axisLabel.formatter = "var func = function(value) {
						return Math.round(value);
					}";
				break;

				case "decimal":
					arguments.AxisItem.axisLabel.formatter = "var func = function(value) {
						return value.toFixed(2);
					}";
				break;
			}

		}

		for(var ii = 1; ii <= arrayLen(yAxis); ii++){

			var yAxisItem = yAxis[ii];

			if(yAxisItem.type != "value"){
				continue;
			} else {
				doFormat(yAxisItem, ii, formats);
			}
		}

		for(var ii = 1; ii <= arrayLen(xAxis); ii++){

			var xAxisItem = xAxis[ii];

			if(xAxisItem.type != "value"){
				continue;
			} else {
				doFormat(xAxisItem, ii, formats);
			}
		}
	}

	/**
	 * Decorates the option struct with global options are are supported
	 */
	public function decorateWithGlobals(
		required struct option
	){
		var option = arguments.option;
		option.animation = variables.animation;
		// option.backgroundColor = "transparent";
		option.backgroundColor = "##182433";
		// option.color = [
		// 	"##4263eb",
		// 	// "##003f5c",
		// 	"##374c80",
		// 	"##7a5195",
		// 	"##bc5090",
		// 	"##ef5675",
		// 	"##ff764a",
		// 	"##ffa600"
		// ]
		option.color = [
			"##4263eb",
			"##ffa600",
			"##af50d8",
			"##ff8038",
			"##ec3bb6",
			"##ff5861",
			"##ff3a8c",
		]

		// Palette
		// option.color = [
		// 	"##4263eb",
		// 	"##a454dc",
		// 	"##dd41c1",
		// 	"##ff369f",
		// 	"##ff457a",
		// 	"##ff6355",
		// 	"##ff8532",
		// 	"##ffa600"
		// ]

		// //Hue
		// option.color = [
		// 	"##0054a6",
		// 	"##3e66b1",
		// 	"##5f79bc",
		// 	"##7a8dc6",
		// 	"##95a2d1",
		// 	"##aeb7dc"
		// ]

		// option.color = [
		// 	"##0054a6",
		// 	"##0f4990",
		// 	"##153f7a",
		// 	"##183565",
		// 	"##182b50",
		// 	"##16223d",
		// 	"##13192a",
		// 	"##0d0f19",
		// 	"##000000",
		// ]
		return option;
	}

	public function getCoreOption(){

		/**
		 * DETECTION MODES:
		 * There will be 3 modes that we build charts under, Auto, Semi-Auto and Manual.
		 * AUTO: If there are no directives, we will attempt to build a chart based on the data by inspecting the number of columns of different types
		 * SEMI-AUTO: If there is only one @chart directive, we will attempt to build a chart based on the data in left-to-right order
		 * MANUAL: Otheriwse user must specify the chart type and the data to use
		 */
		var mode = {
			auto: false,
			assist: false
		}

		var plottingDirectives = {
			chart: true,
			category: true,
			series: true
		}

		//var count the plotting directives found
		var plottingDirectivesFound = 0;
		for(var key in plottingDirectives){
			if(variables.directives.keyExists(key)){
				plottingDirectivesFound++;
			}
		}

		if(plottingDirectivesFound == 0){
			mode.auto = true
		} else if(variables.directives.keyExists("chart")) {
			mode.assist = true;
		}

		if(variables.directives.keyExists("groups")){
			for (group in variables.directives.groups) {
				if (!variables.metaData.columnArray.containsNoCase(group)) {
					throw(type="ColumnNotFoundError", message="Column '#group#' on @groups value not found (available columns: #variables.metaData.columnArray.toList(', ')#)");
				}
			}
		}

		if(mode.auto) {

			var detectedType = variables.QueryUtil.detectChartType();

			if(variables.data.recordCount == 0){
				return;
			}

			switch(detectedType){
				case "column":
					var primaryCategoryField = variables.metaData.types.string.columnsArray[1];
					var categoryName = primaryCategoryField.name;
					var categoryData = variables.data.columnData(categoryName);
					var valuesFields = variables.metaData.types.numeric.columnsArray;

					var option = this.getColumnOption(
						primaryCategoryField = primaryCategoryField,
						categoryData = categoryData,
						valuesFields = valuesFields
					);
				break;

				case "grouped-column":

					var primaryCategoryField = variables.metaData.types.string.columnsArray[1]
					var categoryName = primaryCategoryField.name;
					var categoryData = variables.data.columnData(categoryName);

					var valuesFields = variables.metaData.types.numeric.columnsArray;

					var option = this.getColumnOption(
						primaryCategoryField = primaryCategoryField,
						categoryData = categoryData,
						valuesFields = valuesFields
					);

				break;

				case "line":

					// var categoryName = variables.metaData.types.string.columnsArray[1].name;
					var categoryData = variables.metaData.types.string.columnsArray[1].data;
					var series = variables.metaData.types.numeric.columnsArray;
					// var valueName = variables.metaData.types.numeric.columnsArray[1].name;
					// var valueData = variables.data.columnData(valueName);

					var option = this.getLineOption(
						categoryData = categoryData,
						series = series
					);

				break;

				case "timeline":

					var primaryCategoryField = variables.metaData.types.datetime.columnsArray[1];

					var categoryData = primaryCategoryField.data;
					var valuesFields = variables.metaData.types.numeric.columnsArray;

					var option = this.getLineOption(
						primaryCategoryField = primaryCategoryField,
						categoryData = categoryData,
						valuesFields = valuesFields
					);
				break;

				case "dateline":

					var primaryCategoryField = variables.metaData.types.date.columnsArray[1];
					var categoryData = primaryCategoryField.data;
					var valuesFields = variables.metaData.types.numeric.columnsArray;

					var option = getLineOption(
						primaryCategoryField = primaryCategoryField,
						categoryData = categoryData,
						valuesFields = valuesFields
					);

				break;

				case "scatter":

					var xData = variables.metaData.types.numeric.columnsArray[1].data;
					var yData = variables.metaData.types.numeric.columnsArray[2].data;

					var scatterData = [];

					for(var ii=1; ii<=arrayLen(xData); ii++){
						scatterData.append([xData[ii], yData[ii]]);
					}

					var option = this.getScatterOption(
						scatterData = scatterData
					)
					return option;
				break;

				case "bubble":

					var xData = variables.metaData.types.numeric.columnsArray[1].data;
					var yData = variables.metaData.types.numeric.columnsArray[2].data;
					var sizeData = variables.metaData.types.numeric.columnsArray[3].data;

					var scatterData = [];

					for(var ii=1; ii<=arrayLen(xData); ii++){
						scatterData.append([xData[ii], yData[ii], sizeData[ii]]);
					}

					var option = this.getScatterOption(
						scatterData = scatterData
					)

					// writeDump(option);

					return option;

				break;

				case "heatmap":
					var option = this.getHeatmapOption(
						xField = variables.metaData.types.string.columnsArray[1],
						yField = variables.metaData.types.string.columnsArray[2],
						valueField = variables.metaData.types.numeric.columnsArray[1]
					);
					return option;

				break;

				case "indeterminate":
					// writeDump(variables.metaData);
					// abort;
					throw("Coult not determine the type of chart and no @chart was specified.");
				break;
				default:
					throw("Auto chart for '#detectedType#' not yet complete");
			}
		} else {
			//Handle when we have groups directives
			if(variables.directives.keyExists("groups")){
				// One of the feature is we want the data to plot in the order it is received.
				// So we are going to add a _sortId column to the data to ensure our group by
				// is in the order it is received
				if(!variables.data.columnExists("_sortId")){
					variables.data.addColumn("_sortId");
					for(var ii=1; ii<=variables.data.recordCount; ii++){
						variables.data._sortId[ii] = ii;
					}
				}

				// writeDump(variables.directives);
				var categoryName = variables.directives.groups[1];
				var primaryCategoryField = variables.metaData.columns[categoryName];

				// writeDump(variables.directives["groups"]);

				var atGroupBy = variables.directives["groups"];
				// writeDump(variables.metaData.types.numeric.columnsArray[1].name);
				// abort;
				var seriesValues = [];
				if (variables.directives.keyExists("series") && !isNull(variables.directives.series) && !isEmpty(variables.directives.series)) {
					seriesValues = variables.directives.series;
				} else {
					// Assistive Mode should select the left most numeric column in this case for the series.
					if (variables.metaData.types.numeric.columnsArray.len() > 0) {
						seriesValues = [variables.metaData.types.numeric.columnsArray[1].name];
					} else {
						seriesValues = [];
					}
				}

				if(variables.directives.keyExists("secondary-series")){
					var secondarySeriesValues = variables.directives["secondary-series"];
				} else {
					var secondarySeriesValues = [];
				}

				var allSeriesValues = arrayMerge(seriesValues, secondarySeriesValues);

				if(atGroupBy.len() eq 1){

					var workingField = atGroupBy[1];
					if(workingField == categoryName){

						//We are going to regroup the result set by this field name
						//and that will be our category and values
						query name="groupByData" dbtype="query" {
							echo("
							SELECT *
							FROM variables.data
							GROUP BY #workingField#
							ORDER BY _sortId ASC
							")
						}

						var categoryData = groupByData.columnData(workingField);

						var valuesFields = [];

						for(var atValueName in seriesValues){
							valuesFields.append({
								groupField: workingField,
								name: atValueName,
								data: groupByData.columnData(atValueName)
							});
						}

					} else {
						writeDump(workingField);
						writeDump(categoryName);
						throw("The first groups field must be the category field");
					}

				} else if(atGroupBy.len() eq 2){

					var groupBy1 = atGroupBy[1];
					var groupBy2 = atGroupBy[2];

					if(groupBy1 != categoryName){
						throw("The first groups field must be the category field");
					}

					// First we are going to get the distinct values for groupBy1
					// these will be our category values
					query name="groupByData" dbtype="query" {
						echo("
						SELECT *
						FROM variables.data
						GROUP BY #groupBy1#
						ORDER BY _sortId ASC
						")
					}

					var categoryData = groupByData.columnData(groupBy1);

					//Now get all of the distinct values for groupBy2
					query name="groupByData2" dbtype="query" {
						echo("
						SELECT *
						FROM variables.data
						GROUP BY #groupBy2#
						ORDER BY _sortId ASC
						")
					}

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

						if(atValue contains "stack("){
							isStacking = true;
							//extract atVlue of of the stack(atValue)
							var atValue = atValue.replace("stack(", "");
							var atValue = atValue.replace(")", "");
						}

						if(atValue contains "avg("){
							isAggregating = true;
							//extract atVlue of of the stack(atValue)
							var atValue = atValue.replace("avg(", "");
							var atValue = atValue.replace(")", "");
							var aggFunc = "avg";
						}

						if(isAggregating){

							var valuesOut = [];

							for(var groupBy1Name in categoryData){

								var params = {
									groupBy1Value: {type=variables.metaData.columns[groupBy1].finalType, value = groupBy1Name},
								};

								// writeDump(params);
								// abort;

								var sql = "
								SELECT #aggFunc#([#atValue#]) as #atValue#
								FROM variables.data
								WHERE #groupBy1# = :groupBy1Value
								-- We need to group by here in case there are further categories
								-- that we are not charting on but are in the data
								GROUP BY #groupBy1#
								ORDER BY #groupBy1# ASC
								"

								// writeDump(sql);
								// abort;

								query name="groupByData3" dbtype="query" params=params {
									echo(sql)
								}

								// writeDump(groupByData3);

								valuesOut.append(groupByData3[atValue][1]);
							}

							if(arrayContains(secondarySeriesValues, originalAtValue)){
								var isSecondarySeries = true;
							} else {
								var isSecondarySeries = false;
							}

							var field = {
								groupField: groupBy1,
								name: atValue,
								data: valuesOut,
								stack: false,
								isSecondarySeries: isSecondarySeries
							}

							if(variables.directives.keyExists("series-types")){
								if(valuesCount > arrayLen(variables.directives["series-types"])){
									var seriesType = variables.directives["series-types"].last();
								} else {
									var seriesType = variables.directives["series-types"][valuesCount];
								}
								field.type = seriesType;
							}

							valuesFields.append(field);

						} else {

							for(var row in groupByData2){

								// abort;
								var valuesOut = [];
								// Now we need to get the original values for groupBy2 matching
								// the same order as in groupBy1
								for(var groupBy1Name in categoryData){



									var params = {
										groupBy1Value: {type=variables.metaData.columns[groupBy1].finalType, value = groupBy1Name},
										groupBy2Value: {type=variables.metaData.columns[groupBy2].finalType, value= row[groupBy2]},
									};

									var sql = "
										SELECT #atValue# as #atValue#
										FROM variables.data
										WHERE #groupBy1# = :groupBy1Value
										AND #groupBy2# = :groupBy2Value
										-- We need to group by here in case there are further categories
										-- that we are not charting on but are in the data
										GROUP BY #groupBy2#
										ORDER BY #groupBy2# ASC
									"

									query name="groupByData3" dbtype="query" params=params {
										echo(sql)
									}

									valuesOut.append(groupByData3[atValue][1]);

								}

								if(arrayLen(seriesValues) > 1){
									var name = "#row[groupBy2]# #atValue#";
								} else {
									var name = "#row[groupBy2]#";
								}

								if(arrayContains(secondarySeriesValues, atValue)){
									var isSecondarySeries = true;
								} else {
									var isSecondarySeries = false;
								}

								var field = {
									groupField: groupBy2,
									name: name,
									data: valuesOut,
									stack: ((isStacking)?atValue:nullValue()),
									isSecondarySeries: isSecondarySeries
								}

								if(variables.directives.keyExists("series-types")){
									if(valuesCount > arrayLen(variables.directives["series-types"])){
										var seriesType = variables.directives["series-types"].last();
									} else {
										var seriesType = variables.directives["series-types"][valuesCount];
									}
									field.type = seriesType;
								}

								valuesFields.append(field);
							}
						}
					}

					// writeDump(valuesFields);

					//Now for each row in the data set we are going to create a series
					//and add it to the series array
					// writeDump(groupByData);
					// writeDump(groupByData2);
					// writeDump(option);

				} else {
					throw("Not yet handled more than 2 group by");
				}

				// for(var ii=1; ii <= atGroupBy.len(); ii++){

				// 	var workingField = atGroupBy[ii];

				// 	if(ii eq 1){


				// 	} else {
				// 		throw("Not yet handled more than 1 group by");
				// 	}
				// }



			} else {
				// var categoryName = variables.QueryUtil.find

				if(directives.keyExists("category")){
					var categoryName = directives.category;
					var primaryCategoryField = variables.metaData.columns[categoryName];
					var categoryData = variables.data.columnData(categoryName);
				} else {
					var primaryCategoryField = variables.QueryUtil.firstOfTypes(["string", "date", "datetime", "numeric"]).elseThrow("Unable to find a category column");
					var categoryData = primaryCategoryField.data;
					var categoryName = primaryCategoryField.name;
				}

				// var columnNames = variables.metaData.columns.map(function(item){
				// 	return item.name;
				// });

				if(variables.directives.keyExists("series")){
					for (serie in variables.directives.series) {
						if (!variables.metaData.columnArray.containsNoCase(serie)) {
							throw(type="ColumnNotFoundError", message="Column '#serie#' on @series value not found (available columns: #variables.metaData.columnArray.toList(', ')#)");
						}
					}
					var valuesFields = variables.QueryUtil.getNumericFieldsMatching(variables.directives.series);
				} else {
					var valuesFields = variables.metaData.types.numeric.columnsArray;
				}

				//set isSecondarySeries to false for valuesFields
				for(var ii=1; ii<=arrayLen(valuesFields); ii++){
					valuesFields[ii].isSecondarySeries = false;
				}

				if(variables.directives.keyExists("secondary-series")){
					var secondaryValuesFields = variables.QueryUtil.getNumericFieldsMatching(variables.directives["secondary-series"]);
					for(var ii=1; ii<=arrayLen(secondaryValuesFields); ii++){
						secondaryValuesFields[ii].isSecondarySeries = true;
					}
				}

				var valuesFields = arrayMerge(valuesFields, secondaryValuesFields?:[]);

				if(variables.directives.keyExists("series-types")){
					for(var ii=1; ii<=arrayLen(valuesFields); ii++){

						if(ii > arrayLen(variables.directives["series-types"])){
							valuesFields[ii].type = variables.directives["series-types"].last();
						} else {
							valuesFields[ii].type = variables.directives["series-types"][ii];
						}
					}
				}

				// var option = this["get#variables.directives.chart#Option"](
				// 	primaryCategoryField = primaryCategoryField,
				// 	categoryData = categoryData,
				// 	valuesFields = valuesFields
				// );
			}

			var option = this["get#variables.directives.chart#Option"](
				primaryCategoryField = primaryCategoryField,
				categoryData = categoryData,
				valuesFields = valuesFields
			);

			if(!isDefined("primaryCategoryField")){
				throw("A primary category column should have been defined or chosed");
			}
		}

		if(isNull(option)){
			writeDump(mode);
			writeDump(variables.directives);
			throw("Unable to determine chart type")
		}
		return option;
	}

	/**
	 * Returns the @series and @secondary-series as one array when we want to look
	 * through any of the series in order
	 */
	public function getAllSeriesDirectivesValues(){
		var seriesValues = variables.directives.series;
		var secondarySeriesValues = variables.directives["secondary-series"]?:[];
		var allSeriesValues = arrayMerge(seriesValues, secondarySeriesValues);
		return allSeriesValues;
	}

	public function getDefaultColumnOption(
		required array categoryData,
		required string valueName,
		required array valueData
	){
		option = {
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			xAxis: [
				{
					data: arguments.categoryData,
				}
			],
			yAxis:[
				{
					type:'value'
				}
			],
			series: [
				{
					name: arguments.valueName,
					data: arguments.valueData,
					type: 'bar',
				}
			]
		};
	}

	public function getPieOption(
		required struct primaryCategoryField,
		required array categoryData,
		required array valuesFields
	){

		var pieData = [];

		if(arguments.valuesFields.len() == 0){
			throw("Pie charts require at least one numeric column", "invalidChartDefinition");
		}

		var valueData = valuesFields[1].data;

		for(var ii = 1; ii <= arrayLen(categoryData); ii++){
			pieData.append({
				name: categoryData[ii],
				value: valueData[ii]
			});
		}

		var option = {
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			series: [
			  {
				type: 'pie',
				data: pieData,
				label:{
					fontSize: 16,  // Set the font size
				}
			  }
			]
		};
		return option;
	}

	/**
	 * Stitches together a series of date series together with the category
	 * for the time format that eCharts requires, which is to have the date
	 * in series:[[date,value],[date,value]] form on the series. The
	 * xAxis needs to be time and the yAxis is a value. The series
	 * defines the chart type.
	 */
	public array function stitchDateSeries(categoryData, seriesData){
		var dataOut = [];
		for(var ii=1; ii<=arrayLen(arguments.seriesData); ii++){
			var dateFormat = "yyyy-mm-dd";
			var date = dateFormat(arguments.categoryData[ii], "yyyy-mm-dd");
			dataOut.append([date, arguments.seriesData[ii]]);
		}
		try {

		}catch(any e){
			// writeDump(arguments);
			// abort;
		}
		return dataOut;
	}

	public function getComboOption(
		required struct primaryCategoryField,
		required array categoryData,
		required array valuesFields
	){

		var series = [];
		var secondarySeries = [];
		var yAxis = [];

		yAxis.append({
			type:'value'
		})

		//If any series are isSecondarySeries then we need to add a secondary yAxis
		for(var seriesItem in arguments.valuesFields){
			if(seriesItem.isSecondarySeries?:false){
				yAxis.append({
					type:'value'
				})
				break;
			}
		}

		for(var seriesItem in arguments.valuesFields){
			if(!seriesItem.keyExists("type")){
				throw("Combo charts require a type for each series using the @series-types directive", "invalidChartDefinition")
			}

			if(seriesItem.type == "column"){
				//We rewrite column to bar
				var typeName = "bar"
				seriesItem.itemStyle = {
					"normal": {
					  "opacity": 0.1 // Set the opacity here
					}
				}
			} else {
				var typeName = seriesItem.type;
			}

			if(seriesItem.isSecondarySeries?:false){
				var yAxisIndex = 1;
			} else {
				var yAxisIndex = 0;
			}

			var itemOut = {
				name: seriesItem.name,
				type: typeName,
				yAxisIndex: yAxisIndex,
				data: seriesItem.data,
				stack: seriesItem.stack?:false
			}

			// Increase the line style on combo charts as it is a bit too
			// thin when overlaying on top of columns
			if(seriesItem.type == "line"){
				itemOut.lineStyle.normal.width = 3;
			}

			series.append(itemOut);
		}

		var option = {
			legend: {},
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			xAxis: [
				{
					type: 'category',
					data: arguments.categoryData,
				}
			],
			yAxis:yAxis,
			series: series
		};

		if(arguments.valuesFields[1].type == "bar"){
			//Swap the x and y axis
			option.xAxis = yAxis;
			option.yAxis = [
				{
					type: 'category',
					data: arguments.categoryData,
					// 2024-01-23: We set the inverse so that the default sort of bars appears as top to bottom
					// I think echarts sorts from 0,0 coordinate, but this is unintuitive for bar charts
					inverse: true
				}
			]
		}

		if(primaryCategoryField.finalType == "date" or primaryCategoryField.finalType == "datetime"){
			option.xAxis[1].type = "time";
		}
		return option;
	}

	public function getColumnOption(
		required struct primaryCategoryField,
		required array categoryData,
		required array valuesFields
	){

		var series = [];
		var yAxis = [];

		yAxis.append({
			type:'value'
		})

		//If any series are isSecondarySeries then we need to add a secondary yAxis
		for(var seriesItem in arguments.valuesFields){
			if(seriesItem.isSecondarySeries?:false){
				yAxis.append({
					type:'value'
				})
				break;
			}
		}

		for(var seriesItem in arguments.valuesFields){

			if(variables.directives.keyExists("stacks")){
				for(var stackItem in variables.directives.stacks){
					if(stackItem == seriesItem.groupField)
					seriesItem.stack = seriesItem.groupField;
				}
			}

			if(seriesItem.isSecondarySeries?:false){
				var yAxisIndex = 1;
			} else {
				var yAxisIndex = 0;
			}

			series.append({
				name: seriesItem.name,
				type: 'bar',
				yAxisIndex: yAxisIndex,
				data: seriesItem.data,
				stack: seriesItem.stack?:false
			});
		}

		var option = {
			legend: {},
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			xAxis: [
				{
					type: 'category',
					data: arguments.categoryData,
				}
			],
			yAxis:yAxis,
			series: series
		};

		if(primaryCategoryField.finalType == "date" or primaryCategoryField.finalType == "datetime"){
			option.xAxis[1].type = "time";
		}
		return option;
	}

	public function getBarOption(
		required array categoryData,
		required array valuesFields
	){
		var series = [];
		for(var seriesItem in arguments.valuesFields){
			if(variables.directives.keyExists("stacks")){
				for(var stackItem in variables.directives.stacks){
					if(stackItem == seriesItem.groupField)
					seriesItem.stack = seriesItem.groupField;
				}
			}

			if(seriesItem.isSecondarySeries?:false){
				var xAxisIndex = 1;
			} else {
				var xAxisIndex = 0;
			}

			series.append({
				name: seriesItem.name,
				type: 'bar',
				data: seriesItem.data,
				xAxisIndex: xAxisIndex,
				stack: seriesItem.stack?:false
			});
		}

		var option = {
			legend: {},
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				top: '10%',
				containLabel: true
			},
			yAxis: [
				{
					type: 'category',
					data: arguments.categoryData,
					inverse:true
				}
			],
			xAxis:[
				{
					type:'value'
				}
			],
			series: series
		};
		return option;
	}

	public function getLineOption(
		required struct primaryCategoryField,
		required array categoryData,
		required array valuesFields
	){

		// var series = [];
		// for(var seriesItem in arguments.valuesFields){

		// 	var stack = false;
		// 	if(variables.directives.keyExists("stacks")){
		// 		for(var stackItem in variables.directives.stacks){
		// 			if(stackItem == seriesItem.groupField)
		// 			stack = seriesItem.groupField;
		// 		}
		// 	}

		// 	series.append({
		// 		name: seriesItem.name,
		// 		type: 'line',
		// 		data: seriesItem.data,
		// 		stack: stack
		// 	});
		// }

		var series = [];
		var yAxis = [];

		yAxis.append({
			type:'value'
		})

		//If any series are isSecondarySeries then we need to add a secondary yAxis
		for(var seriesItem in arguments.valuesFields){
			if(seriesItem.isSecondarySeries?:false){
				yAxis.append({
					type:'value'
				})
				break;
			}
		}

		for(var seriesItem in arguments.valuesFields){

			if(variables.directives.keyExists("stacks")){
				for(var stackItem in variables.directives.stacks){
					if(stackItem == seriesItem.groupField)
					seriesItem.stack = seriesItem.groupField;
				}
			}

			if(seriesItem.isSecondarySeries?:false){
				var yAxisIndex = 1;
			} else {
				var yAxisIndex = 0;
			}

			series.append({
				name: seriesItem.name,
				type: 'line',
				yAxisIndex: yAxisIndex,
				data: seriesItem.data,
				stack: seriesItem.stack?:false
			});
		}

		var option = {
			legend: {},
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			xAxis: [
				{
					type: 'category',
					data: arguments.categoryData,
				}
			],
			yAxis:yAxis,
			series: series
		};

		if(primaryCategoryField.finalType == "date" or primaryCategoryField.finalType == "datetime"){
			option.xAxis[1].type = "time";
		}

		return option;
	}

	public function getDateLineOption(
		required array categoryData,
		required array series
	){

		var series = [];

		for(var seriesItem in arguments.series){

			var dataOut = [];
			for(var ii=1; ii<=arrayLen(seriesItem.data); ii++){
				var dateFormat = "yyyy-mm-dd";
				var date = dateFormat(arguments.categoryData[ii], "yyyy-mm-dd");
				dataOut.append([date, seriesItem.data[ii]]);
			}

			series.append({
				type: 'line',
				name: seriesItem.name,
				data: dataOut
			});
		}

		option = {
			xAxis: {
			  type: 'time',
			},
			yAxis: {
			  type: 'value',
			},
			series: series
		};
		return option;
	}

	public function getDateAreaOption(
		required array categoryData,
		required array valuesFields
	){

		var series = [];
		var legendData = [];

		for(var seriesItem in arguments.valuesFields){

			var dataOut = [];
			for(var ii=1; ii<=arrayLen(seriesItem.data); ii++){
				var dateFormat = "yyyy-mm-dd";
				var date = dateFormat(arguments.categoryData[ii], "yyyy-mm-dd");
				dataOut.append([date, seriesItem.data[ii]]);
			}

			series.append({
				type: 'line',
				name: seriesItem.name,
				stack: 'Total',
				areaStyle: {},
				emphasis: {
					focus: 'series'
				},
				data: dataOut
			});

			legendData.append(seriesItem.name);
		}

		// name: seriesItem.name,
		// 		type: 'line',
		// 		stack: 'Total',
		// 		areaStyle: {},
		// 		emphasis: {
		// 			focus: 'series'
		// 		},
		// 		data: seriesItem.data
		// 	});
		// }

		// option = {
		// 	legend: {
		// 		data: legendData
		// 	},

		option = {
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			legend: {
				data: legendData
			},
			xAxis: {
			  type: 'time',
			},
			yAxis: {
			  type: 'value',
			},
			series: series
		};
		return option;
	}

	public function getScatterOption(
		required array scatterData
	){

		var hasSize = false;
		if(scatterData[1].len() == 3){
			hasSize = true;
		}

		option = {
			xAxis: [{type:'value'}],
			yAxis: [{type:'value'}],
			series: [{
				symbolSize: 10,
				data: arguments.scatterData,
				type: 'scatter'
			}]
		};

		if(hasSize){
			option._scatterSize = "scatterFunc = function(data){ return data[2] / 4; }";
		}
		return option;
	}

	public function getHeatmapOption(
		required struct xField,
		required struct yField,
		required struct valueField
	){

		// var data = [
		// 	[0, 0, 10], // x=0, y=0, value=10
		// 	[0, 1, 20], // x=0, y=1, value=20
		// 	[1, 0, 30], // x=1, y=0, value=30
		// 	[1, 1, 40]  // x=1, y=1, value=40
		// ];

		//We need to get the distinct values for x and y
		var yStruct = structNew("ordered");
		var xStruct = structNew("ordered");
		var xData = [];
		var yData = [];

		for(var ii=1; ii<=arrayLen(xField.data); ii++){
			xStruct[xField.data[ii]] = true;
			yStruct[yField.data[ii]] = true;
		}

		for(var key in xStruct){
			xData.append(key);
		}

		for(var key in yStruct){
			yData.append(key);
		}


		var data = [];

		for(var ii=1; ii<=arrayLen(xField.data); ii++){
			//Map the xField, yField and valueField into the data structure
			data.append([
				xField.data[ii],
				yField.data[ii],
				valueField.data[ii]
			]);
		}

		var maxValue = arrayMax(valueField.data);

		var option = {
			tooltip: {
				position: 'top',
				trigger: 'axis',
				axisPointer: {
					type: 'cross',
					label: {
						backgroundColor: '##6a7985'
					}
				},
				formatter: "var func = function(columns) {
					let html = columns.map((data) => {
						return `${data.marker} ${data.value[1]}: <b>${data.value[2]}</b>`;
					}).join('<br>');
					return `<b>${columns[0].name}</b><br>${html}`;
				}"
			},
			grid: {
				height: '50%',
				y: '10%'
			},
			xAxis: {
				type: 'category',
				// data: ['X0', 'X1'] // Number of entries should correspond to distinct x indices
				data: xData,
			},
			yAxis: {
				type: 'category',
				// data: ['Y0', 'Y1'] // Number of entries should correspond to distinct y indices
				data: yData
			},
			visualMap: {
				min: 0,
				// max: 50,
				max: maxValue,
				calculable: true,
				orient: 'horizontal',
				left: 'center',
				bottom: '15%'
			},
			series: [{
				name: 'Heatmap',
				type: 'heatmap',
				data: data,
				label: {
					show: true
				},
				emphasis: {
					itemStyle: {
						shadowBlur: 10,
						shadowColor: 'rgba(0, 0, 0, 0.5)'
					}
				}
			}]
		};
		return option;
	}

	/**
	 * Normalizes the values fields to a percentage of the total
	 *
	 * @seriesFields
	 */
	public function normalizeValueFieldsToPercent(required array valuesFields){
		var numOfSeries = arrayLen(arguments.valuesFields);
		var numOfSeriesItems = arrayLen(arguments.valuesFields[1].data);
		var totals = [];
		for(var ii=1; ii<=numOfSeriesItems; ii++){
			totals[ii] = 0;
			for(var jj=1; jj<=numOfSeries; jj++){
				if(isNumeric(arguments.valuesFields[jj].data[ii])){
					totals[ii] += arguments.valuesFields[jj].data[ii];
				}
			}
		}

		for(var ii=1; ii<=numOfSeriesItems; ii++){
			for(var jj=1; jj<=numOfSeries; jj++){

				if(isNumeric(arguments.valuesFields[jj].data[ii])){
					if(totals[ii] gt 0){
						arguments.valuesFields[jj].data[ii] = (arguments.valuesFields[jj].data[ii] / totals[ii]) * 100;
					}
				} else {
					arguments.valuesFields[jj].data[ii] = 0;
				}
			}
		}
	}

	public function getAreaOption(
		required struct primaryCategoryField,
		required array categoryData,
		required array valuesFields
	){

		var series = [];
		for(var seriesItem in arguments.valuesFields){

			var stack = false;
			if(variables.directives.keyExists("stacks")){
				for(var stackItem in variables.directives.stacks){
					if(stackItem == seriesItem.groupField)
					stack = seriesItem.groupField;
				}
			} else {
				stack = 'Total';
			}

			series.append({
				name: seriesItem.name,
				type: 'line',
				areaStyle: {
				},
				emphasis: {
					focus: 'series'
				},
				data: seriesItem.data,
				stack: stack
			});
		}

		var option = {
			legend: {},
			grid: {
				left: '3%',
				right: '4%',
				bottom: '3%',
				containLabel: true
			},
			xAxis: [
				{
					type: 'category',
					data: arguments.categoryData,
				}
			],
			yAxis:[
				{
					type:'value'
				}
			],
			series: series
		};

		if(primaryCategoryField.finalType == "date" or primaryCategoryField.finalType == "datetime"){
			option.xAxis[1].type = "time";
		}

		return option;
	}

	// Substitutes underscores by space and separate words if their initials are in cap
	private function cleanName(
		required string name
	) {
		var cleanedName = name.toString().replace("_", " ", "all");
		// Remove empty space at the beginning of the string
		return cleanedName.trim();
	}
	// public function getAreaOption(
	// 	required array categoryData,
	// 	required array valuesFields
	// ){
	// 	var seriesOut = [];
	// 	var legendData = [];

	// 	for(var seriesItem in arguments.valuesFields){

	// 		legendData.append(seriesItem.name);
	// 		// var seriesData = duplicate(seriesItem.data);

	// 		seriesOut.append({
	// 			name: seriesItem.name,
	// 			type: 'line',
	// 			stack: variables.directives.stacking?:'Total',
	// 			smooth: variables.directives.smooth?:false,
	// 			areaStyle: {
	// 			},
	// 			emphasis: {
	// 				focus: 'series'
	// 			},
	// 			data: seriesItem.data
	// 		});
	// 	}

	// 	option = {
	// 		legend: {
	// 			data: legendData
	// 		},
	// 		grid: {
	// 			left: '3%',
	// 			right: '4%',
	// 			bottom: '3%',
	// 			containLabel: true
	// 		},
	// 		xAxis: [
	// 			{
	// 				type: 'category',
	// 				boundaryGap: false,
	// 				data: arguments.categoryData
	// 			}
	// 		],
	// 		yAxis: [
	// 			{
	// 				type: 'value',
	// 			}
	// 		],
	// 		series: seriesOut
	// 	};

	// }

}