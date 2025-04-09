/**
 * The entry point for a zeroTable
 * @type {String}
 */
import _vendor.queryString.queryString;
component accessors="true" {

	property name="rows" setter="false";
	property name="columns" setter="false";
	property name="columnCount" setter="false";
	property name="primaryColumn" setter="false";
	property name="pagination" setter="false";
	property name="filters" setter="false";
	property name="max";
	property name="offset";
	property name="sort";
	property name="direction";
	property name="currentPageId";
	property name="search" setter="false";
	property name="showMoreLink" setter="false";
	property name="showRowFilterButtons" setter="false";
	property name="show_columns" setter="false";
	property name="more" setter="false";
	property name="nextMore" setter="false";
	property name="currentLink" setter="false";
	property name="currentParams" setter="false";
	property name="currentParamsAsString" setter="false";
	property name="clearSearchLink" setter="false";
	property name="clearEditLink" setter="false";
	property name="basePath" setter="false";
	property name="inverseSortLink" setter="false";
	property name="isSortDesc";
	property name="isSortAsc";
	property name="useZeroAjax" setter="false";
	property name="ajaxTarget" setter="false";
	property name="persistFields" setter="false";
	property name="tableName" setter="false";
	property name="tableNamePrefix" setter="false";
	property name="rowEditPanelColumn" setter="false";
	property name="rowEditPanelId" setter="false";
	property name="rowEditPanelContent" setter="false";
	property name="style" type="struct" setter="false";
	property name="rowOnClick" type="any" setter="false";
	property name="rowGroup" type="any" setter="false";
	property name="hasFilterableColumns" setter="false";
	property name="defaultSort" setter="false";
	property name="useFastSerializer" setter="false";
	property name="layout" setter="false";

	/**
	 * Initialize a ZeroTable
	 * @rows A component implementedin the Data interface to work with row data
	 * @max  The maxiumum number of rows to return.
	 * @offset The starting position of the first row to return.
	 * @showMaxPages The total number of pages to display at one time
	 * @basePath The URL path that the table is accessed from.
	 * @more Adds an additional number of records to the display equal to 'more'
	 * @useZeroAjax Whether to enable ajax loading of the zerotable state changes.
	 * @ajaxTarget The HTML element ID to target when when 'useZeroAjax=true'
	 * @serializerIncludes A struct of keys to include in the serialization of ORM entities. See the Zero Serializer feature on including
	 * @persistFields A struct of additional key:value pairs of data to persist between clicks of the zero table. These fields allow you to main other URL and state values with each click of the zerotable
	 * @tableName A name given to the zero table to differentiate two different tables on the same page
	 * @defaultSort The default order of the primary key column of the table
	 * @style A Struct containing key:value styles to use for the table. (ie `style={striped:true}`) Available styles are *striped*, *hover*,*bordered*, and *condensed*
	 * @toolbar Settings to control additional features available through the toolbar. (ie `toolbar={show:true, tools={copy:false}}`)
	 * @rowGroup Settings to group related rows together when displaying (ie rowGroup={columnName:"foo"})
	 * @layout Whether the table is in a card or table layout, default is table
	 * @return
	 */
	public zeroTable function init(required data Rows,
						 required numeric max=10,
						 required numeric offset=0,
						 required showMaxPages=5,
						 required string basePath="",
						 required numeric more=0,
						 required useZeroAjax=true,
						 ajaxTarget,
						 required serializerIncludes={},
						 struct persistFields={},
						 boolean persistUrl=false,
						 tableName,
						 defaultSort="asc",
						 rowEditPanelColumn,
						 rowEditPanelContent,
						 boolean serializeRowsToSnakeCase,
						 style = {
						 	table:{
						 		striped:false,
						 		hover:true,
						 		bordered:true,
						 		condensed:false,
						 	}

						 },
						 struct rowGroup,
						 struct toolbar = {
						  	show:true,
						  	tools:{
							  	copy:true,
							  	history:true,
							  	share:true,
							  	download:true,
							  	customize:true,
						  	}
						  },
						 boolean useFastSerializer=false,
						 boolean showRowFilterButtons=true,
						 string layout="table"

						 ){

		variables.Rows = arguments.Rows;
		variables.max = arguments.max;
		variables.offset = arguments.offset;
		variables.columns = [];
		variables.showMaxPages = arguments.showMaxPages;
		variables.currentPageId = 1;
		variables.isSortedById = false;
		variables.basePath = arguments.basePath;
		variables.convertCamelCaseToUnderscore = false;
		variables.useZeroAjax = arguments.useZeroAjax;
		variables.serializerIncludes = arguments.serializerIncludes;
		variables.persistFields = arguments.persistFields;
		variables.siblingTables = [];
		variables.style = arguments.style;
		variables.hasFilterableColumns = false;
		variables.defaultSort = arguments.defaultSort;
		variables.direction = arguments.defaultSort;
		variables.serializeRowsToSnakeCase = arguments.serializeRowsToSnakeCase?:true;
		variables.useFastSerializer = arguments.useFastSerializer;
		variables.showRowFilterButtons = arguments.showRowFilterButtons;
		variables.layout = arguments.layout;

		variables.validLayouts = ["table", "card"];


		if(variables.direction == "asc"){
			variables.isSortAsc = true;
			variables.isSortDesc = false;
		} else {
			variables.isSortAsc = false;
			variables.isSortDesc = true;
		}

		if(arguments.keyExists("rowGroup")){
			variables.rowGroup = arguments.rowGroup;
			if(!variables.rowGroup.keyExists("show")){variables.rowGroup.show = true}
			if(!variables.rowGroup.keyExists("columnName")){throw("When defining a rowGroup, you must provide a 'columnName' for which column to use for the grouping key")}
		}

		if(arguments.keyExists("rowEditPanelColumn")){
			variables.hasRowEditPanel = true;
			variables.rowEditPanelColumn = arguments.rowEditPanelColumn;
		} else {
			variables.hasRowEditPanel = false;
		}

		if(arguments.keyExists("rowEditPanelContent")){
			variables.rowEditPanelContent = arguments.rowEditPanelContent;
		}

		if(arguments.keyExists("tableName")){
			variables.tableName = arguments.tableName;
		} else {
			variables.tableName = "";
		}

		if(arguments.keyExists("ajaxTarget")){
			variables.ajaxTarget = arguments.ajaxTarget;
		} else {
			variables.ajaxTarget = "##zero-grid#variables.tableName#";
		}
		// variables.searchString = "";
		variables.customColumns = [];


		if(arguments.keyExists("rowOnClick")){
			variables.rowOnClick = arguments.rowOnClick;
		}

		if(arguments.keyExists("toolbar")){
			variables.toolbar = arguments.toolbar;
		}

		variables.qs = new queryStringNew(cgi.query_string);
		variables.qs.delete(getFieldNameWithTablePrefix("search"))
					.delete(getFieldNameWithTablePrefix("sort"))
					.delete(getFieldNameWithTablePrefix("submit"))
					.delete(getFieldNameWithTablePrefix("max"))
					.delete(getFieldNameWithTablePrefix("offset"))
					.delete(getFieldNameWithTablePrefix("more"))
					//Not sure why jquery ajax is submitting an undefined variable, but delete it anyway
					.delete(getFieldNameWithTablePrefix("undefined"))
					.delete(getFieldNameWithTablePrefix("layout"));

		setMore(arguments.more);
		setMax(arguments.max);
		setOffset(arguments.offset);
		setLayout(arguments.layout);

		if(arguments.persistUrl){
			var primaryParams = this.getPrimaryParamsAsStruct();
			// writeDump(primaryParams);
			// writeDump(variables.persistFields);
			for(var key in url){
				if(
					key == variables.tableName or

					//We do not want to persist filters as it messes with the existing filter items
					key contains getFieldNameWithTablePrefix("filters") or

					//show_columns comes in as a comma separated list but we do not want to persist the individual
					//fields, as such we want to remove these from the persist fields
					key == this.getFieldNameWithTablePrefix("show_columns")
				){
					continue;
				}
				if(!primaryParams.keyExists(key)){
					//08-25-2021: We found a situation where sometimes keys in the URL could be empty
					//I am not sure why this is, it may be when reloading keys after a goto_fail but we need to
					//ensure that we do not add any empty keys to the persisted fields
					var keyName = trim(key);
					if(len(keyName) > 0){
						variables.persistFields[keyName] = url[key];
					}
				}
			}
			// writeDump(variables.persistFields);
			// writeDump(url);
			// abort;
		}

		//Set all of the persist fields into the query string
		for(var field in variables.persistFields){

			if(isNull(variables.persistFields[field]) or trim(field) == ""){
				//Field is not set so we will not persist it
			} else {
				if(isInstanceOf(variables.persistFields[field], "component")){
					variables.qs.setValue(field, encodeForUrl(variables.persistFields[field].toString()));
				} else if(isStruct(variables.persistFields[field])){
					// writeDump(variables.persistFields);
					var flatfields = new zero.zeroStructure(variables.persistFields[field]).flattenDataStructureForCookies(prefix=field);
					for(var flatfield in flatfields){
						variables.qs.setValue(flatfield, encodeForUrl(flatfields[flatfield]));
					}
					// writeDump(fields);
					// abort;
				} else {
					variables.qs.setValue(field, encodeForUrl(variables.persistFields[field]));
				}
			}
		}

		//Set the name for the table into the querystring if it exists
		if(variables.keyExists("tableName")){
			variables.qs.setValue(getFieldNameWithTablePrefix("table_name"), variables.tableName);
		}

		// variables.qs.setValues({
		// 	"max":variables.max,
		// 	"offset":variables.offset,
		// 	"more":variables.more
		// });

		variables.qs.setBasePath(arguments.basePath);
		if(variables.useZeroAjax){
			requiredAjaxFiles();
		}
		return this;
	}

	/*
	Adds additional persisted fields to the table that the table should include in
	its posts and gets. This is primarily used by other zerotables to pass
	themselves through so that each table on a page maintains its state
	 */
	public function addPersistFields(required struct fields){
		for(var field in arguments.fields){
			variables.persistFields.insert(field, arguments.fields[field], true);
			variables.qs.setValue(field, variables.persistFields[field], true);
		}
	}

	public function addColumn(required column column){
		var column = arguments.column;

		if(variables.convertCamelCaseToUnderscore){
			column.setColumnName(camelToUnderscore(column.getColumnName()));
		}

		var found = variables.columns.some(function(check){
			if(check.equals(column)){
				return true;
			} else {
				return false;
			}
		});
		if(!found){


			if(column.getIsPrimary()){
				variables.primaryColumn = new optional(Column);
			}

			variables.columns.append(column);
			column.setZeroTable(this);
			// column.setSortAscLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"asc"}).get());
			// column.setSortDescLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"desc"}).get());

		} else {
			throw("column already exists");
		}

		if(column.getFilterable()){
			variables.hasFilterableColumns = true;
		}
	}

	public function addSiblingTable(required zeroTable table){
		variables.siblingTables.append(arguments.table);
	}

	/**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	function camelToUnderscore(str) {
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }
		return trim(rtnStr);
	}

	private void function decorateRowsWithCustomColumns(required array rows){
		var columns = getCustomColumns();
		var rows = arguments.rows;
		for(var column in columns){
			var name = column.getColumnName();
			for(var row in rows){
				if(row.keyExists("zerotable_group")){
					//Rows which are zerotable groups do not get custom columns
					continue;
				}

				var output = column.getCustomOutput(row, this);
				if(!row.keyExists(name)){
					row[name] = output;
				}
				row["zerotable_custom_output"][name] = output;
			}
		}
	}

	private void function decorateRowsWithWrapColumns(required array rows){
		var columns = getWrapColumns();
		var rows = arguments.rows;
		for(var column in columns){
			var name = column.getColumnName();
			for(var row in rows){
				if(row.keyExists("zerotable_group")){
					//Rows which are zerotable groups do not get custom columns
					continue;
				}

				if(isStruct(row[name])){

					var value = evaluate('row.#column.getColumnRowDataPath()#');
					if(!isSimpleValue(value)){
						throw("Could not wrap the output from the field '#column.getColumnRowDataPath()#'. Ensure that the value is a string or use columnRowDataPath to specify the nested path to the value");
					}
					evaluate('row.wrap.#column.getColumnRowDataPath()# = column.getWrapOutput(value)');
				} else {
					row["wrap"][name] = column.getWrapOutput(evaluate("row.#column.getColumnRowDataPath()#"));
				}
			}
		}
	}

	private void function decorateRowsWithRowEditPanel(required array rows){
		var rows = arguments.rows;
		if(getHasRowEditPanel()){

			for(var row in rows){
				row["open_row_edit_panel_link"] = this.getCurrentQueryString().getNew().setValue(getFieldNameWithTablePrefix("row_edit_panel"), row[getRowEditPanelColumn()]).get();
			}

			if(getHasRowEditPanelId()){
				for(var row in rows){
					if(row[getRowEditPanelColumn()] == getRowEditPanelId()){
						row["show_row_edit_panel"] = true;
						row["close_row_edit_panel_link"] = this.getCurrentQueryString().getNew().delete("#variables.tableName#.row_edit_panel").get();

						if(getHasRowEditPanelContent()){
							var rowEditPanelContent = getRowEditPanelContent();
							if(isClosure(rowEditPanelContent)){
								var out = rowEditPanelContent(row, this);
							} else {
								var out = rowEditPanelContent;
							}
							row["row_edit_panel_content"] = out;
						}
					}
				}
			}
		}
	}

	private void function decorateRowsWithRowOnClick(required array rows){
		var rows = arguments.rows;
		if(getHasRowOnClick()){

			for(var row in rows){
				if(isClosure(getRowOnClick())){
					var onClick = getRowOnClick();
					row["row_on_click"] = evaluate('onClick(row)');
				} else {
					row["row_on_click"] = getRowOnClick();
				}
			}
		}
	}

	public function getCSVData(){
		var rows = getAllRows();
		var lines = [];
		var headers = rows[1].keyList();

		for(row in rows){
			var lineOut = [];
			for(header in headers){
				var cell = row[header];
				var cell = replace(cell, '"', '\"', "all");
				lineOut.append('"#cell#"');
			}
			lines.append(lineOut.toList())
		}

		var quotedHeaders = listToArray(headers).map(function(element){
			return '"#element#"';
		});

		lines.prepend(quotedHeaders.toList());
		var final = lines.toList(chr(10));
		return final;
	}

	/*
	Will generate a CSV file and direct the browser to download it
	 */
	public function downloadCSVData(){
		var CSVData = getCSVData();
		var base64 = toBase64(CSVData);
		var binary = toBinary(base64);
		header name="Content-Disposition" value="attachment;filename=""data.csv""";
		content type="text/csv" variable="binary";
	}

	public function edit(required string columnName, required string rowId, string errorMessage){


		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #columnName#");
		column.setEdit(true);

		if(arguments.keyExists("errorMessage")){
			column.setErrorMessage(arguments.errorMessage);
		}

		var primaryColumn = getPrimaryColumn().elseThrow("Can only edit tables which have a primary column. Add a primary column");
		variables.qs.setValues({"#getFieldNameWithTablePrefix("edit_col")#":primaryColumn.getColumnName(), "edit_id":rowId});
		for(var row in getRows()){
			var name = primaryColumn.getColumnName();
			if(row[name] == arguments.rowId){
				row.edit = true;

				if(arguments.keyExists("errorMessage")){
					row.error_message = arguments.errorMessage;
				}

			} else {
				row.edit = false;
			}
		}
	}

	/*
	Takes a column to filter, updates the column class and updates
	the data class to perform the filtering
	 */
	public function filter(required string columnName, required any value){
		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #arguments.columnName#");
		column.setFilteredValue(arguments.value);
		variables.qs.setValue(getFieldNameWithTablePrefix("filters.#arguments.columnName#"), arguments.value);
		variables.rows.filter(column.getDataName(), arguments.value);
	}

	public Optional function findColumnByName(required string columnName){
		var columnName = arguments.columnName;
		var found = variables.columns.find(function(column){
			if(lcase(column.getColumnName()) == columnName){
				return true;
			} else {
				return false;
			}
		});
		if(!found){
			return new optional();
		} else {
			return new optional(getColumns()[found]);
		}
	}

	public string function getClearEditLink(){
		return variables.qs.getNew().delete(getFieldNameWithTablePrefix("edit_col")).delete(getFieldNameWithTablePrefix("edit_id")).get();
	}

	public string function getClearFiltersLink(){
		var qsNew = variables.qs.getNew();
		for(var Column in this.getColumns()){
			qsNew.delete(this.getFieldNameWithTablePrefix("filters.#Column.getColumnName()#"));
		}
		return qsNew.get();
	}

	public string function getClearSearchLink(){
		// writeDump(variables.qs.get());
		return variables.qs.getNew().setBasePath("#variables.basePath#")
									.delete(getFieldNameWithTablePrefix("search"))
									.delete(getFieldNameWithTablePrefix("edit_col"))
									.delete(getFieldNameWithTablePrefix("edit_id")).get();
	}

	public string function getCSVDownloadLink(){
		return variables.qs.getNew().setBasePath("#variables.basePath#").setValue(getFieldNameWithTablePrefix("download_csv"),'true').get();
	}

	public string function getCurrentLink(){
		return variables.qs.getNew().setBasePath("#variables.basePath#").get();
	}

	public queryStringNew function getCurrentQueryString(){
		return variables.qs.getNew().setBasePath("#variables.basePath#");
	}

	public function getFieldNameWithTablePrefix(required string field){
		if(variables.keyExists("tableName") and variables.tableName != ""){
			return "#variables.tableName#.#arguments.field#";
		} else {
			return arguments.field;
		}
	}

	public function getColumnCount(){
		return arrayLen(variables.columns);
	}

	public array function getColumnNames(){
		var out = [];
		for(var Column in this.getColumns()){
			out.append(Column.getColumnName())
		}
		return out;
	}

	/*
	* Used for testing
	*/
	public function getHiddenColumnCount(){
		var count = 0;
		for(var column in columns){
			if(Column.getHidden()){
				count++;
			}
		}
		return count;
	}

	/*
	* Used for testing
	*/
	public function getVisibleColumnCount(){
		var count = 0;
		for(var column in columns){
			if(!Column.getHidden()){
				count++;
			}
		}
		return count;
	}

	public column[] function getCustomColumns(){
		var out = [];
		for(var column in variables.columns){
			if(column.getColumnType().keyExists("custom")){
				out.append(column);
			}
		}
		return out;
	}

	public function getHasFilters(){
		return variables.keyExists("filters") and !variables.filters.isEmpty();
	}

	public function getHasRowEditPanel(){
		return variables.hasRowEditPanel;
	}

	public boolean function getHasRowEditPanelId(){
		return variables.keyExists("rowEditPanelId");
	}

	public string function getInverseSortLink(){
		var qs = this.getQueryString().getNew();
		if(variables.direction == "asc"){
			qs.setValue(this.getFieldNameWithTablePrefix('direction'), 'desc');
		} else {
			qs.setValue(this.getFieldNameWithTablePrefix('direction'), 'asc');
		}
		return qs.get();
	}

	public boolean function getHasRowEditPanelContent(){
		return variables.keyExists("rowEditPanelContent");
	}

	public boolean function getHasRowOnClick(){
		return variables.keyExists("rowOnClick");
	}

	public string function getShowMoreLink(){
		return variables.qs.getNew().setValues({"#getFieldNameWithTablePrefix("offset")#":variables.offset, "#getFieldNameWithTablePrefix("more")#": variables.more + variables.max}).get();
	}

	public column[] function getWrapColumns(){
		var out = [];
		for(var column in variables.columns){
			if(column.getHasWrap()){
				out.append(column);
			}
		}
		return out;
	}

	public pagination function getPagination(){

		return new pagination(data=variables.Rows,
							  max=variables.max + variables.more,
							  offset=variables.offset,
							  showMaxPages=variables.showMaxPages,
							  zeroTable=this);
	}

	public array function getPrimaryParams(){
		var params = ["offset", "max", "search", "sort", "direction", "more", "show_columns"];
		var out = [];


		for(var param in params){

			var value = evaluate("this.get#param#()");

			if(isNull(value)){
				//Do nothing with the paramter
				// writeDump(param);
				// abort;
			} else {

				// if(isObject(value) and isInstanceOf(value,"optional")){
				// 	if(!value.exists()){
				// 		continue;
				// 	}
				// }

				if(!isObject(value) and !isSimpleValue(value) and isStruct(value)){
					var is_struct = true;
				} else {
					var is_struct = false;
				}

				if(!isNull(value)){
					out.append({
						"name":getFieldNameWithTablePrefix(param),
						"value":value,
						"is_#param#":true,
						"is_struct":is_struct,
						"column":{
							"rack_rate":false,
							"name":false
						}
					});
				}
			}
		}

		if(getHasFilters()){

			var filters = getFilters();
			for(var filter in filters){

				var data = {
					"name":getFieldNameWithTablePrefix("filters.#filter#"),
					"value":filters[filter],
					"is_filter":true,
					"column":{
						"#filter#":true,
						"column_name":filter
					}
				}
				out.append(data);
			}
		}
		// writeDump(out);
		// abort;

		if(getHasRowEditPanel()){
			if(getHasRowEditPanelId()){
				out.append({
					"name":getFieldNameWithTablePrefix("row_edit_panel"),
					"value":getRowEditPanelId(),
					"is_row_edit_panel":true
				})
			}
		}

		//Add a table name if it exists to the out, this allows the user
		//to support multiple zerotables
		if(variables.keyExists("tableName")){
			out.append({
				"name":getFieldNameWithTablePrefix("table_name"),
				"value":variables.tableName,
				"is_table_name":true,
				"is_#variables.tableName#":true,
				"column":{
					"rack_rate":false,
					"name":false
				}
			})
		}

		return out;
	}

	public struct function getPrimaryParamsAsStruct(){
		var params = getPrimaryParams();
		var out = {};
		for(var param in params){
			out.insert(param.name, param, true);
		}
		return out;
	}

	public struct function getPrimaryParamsAsKeyValue(){

		var params = getPrimaryParamsAsStruct();
		var paramsOut = {};
		for(var param in params){

			if(isObject(params[param].value) and isInstanceOf(params[param].value, "optional")){
				if(params[param].value.exists()){
					paramsOut.insert(param, params[param].value.get(), true);
				}
			} else {
				paramsOut.insert(param, params[param].value, true);
			}
		}
		return paramsOut;
	}

	public array function getCurrentParams(){

		var out = getPrimaryParams();

		//Add the persistFields to the currentParams out
		for(var key in variables.persistFields){
			if(!isNull(variables.persistFields[key])){
				out.append({
					"name":key,
					"value":persistFields[key],
					"is_#key#":true,
					"column":{
						"rack_rate":false,
						"name":false
					},
					"clear_url":this.getCurrentParamsAsQueryString().delete(key).get(),
					"set_false_url":this.getCurrentParamsAsQueryString().setValue(key, false).get(),
					"set_true_url":this.getCurrentParamsAsQueryString().setValue(key, true).get(),
				});
			}
		}
		return out;
	}

	public struct function getCurrentParamsAsStruct(){
		var params = getCurrentParams();
		var out = {};
		for(var param in params){
			out.insert(param.name, param, true);
		}
		return out;
	}

	public struct function getCurrentParamsAsKeyValue(){

		var params = getCurrentParamsAsStruct();
		var paramsOut = {};
		for(var param in params){

			if(isObject(params[param].value) and isInstanceOf(params[param].value, "optional")){
				if(params[param].value.exists()){
					paramsOut.insert(param, params[param].value.get(), true);
				}
			} else {
				paramsOut.insert(param, params[param].value, true);
			}
		}
		return paramsOut;
	}

	public string function getCurrentParamsAsString(){
		return variables.qs.getNew().setBasePath("").get();
	}

	public function getCurrentParamsAsQueryString(){
		return variables.qs.getNew();
	}

	public optional function getPrimaryColumn(){
		return variables.primaryColumn?: new optional();
	}

	public function getQueryString(){
		return variables.qs;
	}

	public string function getResetMoreLink(){
		var qsNew = variables.qs.getNew();
		for(var Column in this.getColumns()){
			qsNew.setValue(this.getFieldNameWithTablePrefix("more"), 0);
		}
		return qsNew.get();
	}

	public function getRows(){

		if(!variables.isSortedById){
			var primaryColumn = getPrimaryColumn();
			if(primaryColumn.exists()){
				variables.Rows.sort(primaryColumn.get().getDataName(), variables.defaultSort);
			}
		}

		if(isNull(variables.serializedRows)){
			var rows = variables.Rows.list(max=variables.max + variables.more, offset=variables.offset);
			/*
			An optimization to check if the user has passed in serializerIncludes, if they have
			then we need to use the generic serializer. If they haven't then we can just return the
			rows as they are from the data.
			 */
			if(variables.useFastSerializer){
				var rows = new zero.serializerFast(rows, variables.serializerIncludes);
			} else {
				var rows = new zero.serializer(variables.serializeRowsToSnakeCase).serializeEntity(rows, variables.serializerIncludes);
			}
			variables.serializedRows = rows;
		}

		if(variables.keyExists("rowGroup") and variables.rowGroup.show){
			var groups = structNew("linked");
			var ColumnName = this.findColumnByName(variables.rowGroup.columnName).elseThrow("Could not locate the column '#variables.rowGroup.columnName#' for rowGroup").getColumnName();

			for(var row in variables.serializedRows){

				if(variables.rowGroup.keyExists("key") and isClosure(variables.rowGroup.key)){
					var key = variables.rowGroup.key(row[columnName]);
				} else {
					if(!isSimpleValue(row[columnName])){
						throw("The rowGroup columnName does not resolve to a simple value. Use the option key:function(data){} to define your own key function");

					} else {
						var key = row[columnName];
					}
				}

				if(isNull(key)){
					var key = "zerotable_null"
				}

				if(!groups.keyExists(key)){
					groups[key] = [];
				}
				groups[key].append(row);
			}

			var out = [];
			for(var key in groups){

				if(variables.rowGroup.keyExists("content")){
					if(isClosure(variables.rowGroup.content)){
						var content = variables.rowGroup.content(groups[key]);
					} else {
						var content = variables.rowGroup.content;
					}
				} else {
					content = "#arrayLen(groups[key])# records for '#key#'";
				}

				out.append({
					zerotable_group:true,
					group_key:key,
					number_of_records:arrayLen(groups[key]),
					is:{
						"#key#":true
					},
					colspan:this.getColumnCount(),
					content:content
				})



				for(var item in groups[key]){
					out.append(item);
				}
			}
			return out;
		} else {
			return variables.serializedRows;
		}
	}

	/*
	Gets all rows for the given query. Used for downloading CSV files or any purpose
	which should not paginate rows. This can potentially use a lot of RAM if there
	are many records.
	 */
	public function getAllRows(){

		if(!variables.isSortedById){
			var primaryColumn = getPrimaryColumn();
			if(primaryColumn.exists()){
				variables.Rows.sort(primaryColumn.get().getDataName(), "asc");
			}
		}
		var totalRows = variables.Rows.count();
		var rows = variables.Rows.list(max=totalRows, offset=0);
		if(variables.useFastSerializer){
			var rows = new zero.serializerFast(rows, variables.serializerIncludes);
		} else {
			var rows = new zero.serializer(false).serializeEntity(rows, variables.serializerIncludes);
		}
		return rows;
	}

	public Optional function getsearch(){
		if(isNull(variables.searchString)){
			return new Optional();
		} else {
			return new Optional(variables.searchString);
		}
	}

	public function getSort(){
		// if(isNull(variables.sortString)){
		// 	return new Optional();
		// } else {
		// 	return new Optional(variables.sortString);
		// }
		return variables.sortString?:"";
	}

	private function requiredAjaxFiles(){
		include template="/zero/plugins/zerotable/model/require_js.cfm";
	}

	public void function pageTo(required numeric id){
		variables.currentPageId = arguments.id;
	}

	public void function persistSiblingTable(required zeroTable table){

		addPersistFields(arguments.table.getPrimaryParamsAsKeyValue());
		arguments.table.addPersistFields(this.getPrimaryParamsAsKeyValue());
		// this.addSiblingTable(arguments.table);
		// arguments.table.addSiblingTable(this);
	}

	public void function search(required string search){
		variables.searchString = arguments.search;
		variables.qs.setValues({"#getFieldNameWithTablePrefix("search")#":variables.searchString});
		variables.Rows.search(arguments.search);
	}

	public function setLayout(required string layout) {
		if(!arrayContainsNoCase(variables.validLayouts, arguments.layout)){
			throw("Invalid layout type. Valid layouts are: #variables.validLayouts.toList(", ")#");
		}
		variables.layout = arguments.layout;
		variables.qs.setValue(getFieldNameWithTablePrefix("layout"), arguments.layout);
	}

	public function setMore(required numeric more){
		variables.more = arguments.more;
		variables.nextMore = variables.more + variables.max;
		variables.qs.setValue(getFieldNameWithTablePrefix("more"), arguments.more);
	}

	private function setMax(required numeric max){
		variables.max = arguments.max;
		variables.qs.setValue(getFieldNameWithTablePrefix("max"), arguments.max);
	}

	private function setOffset(required numeric offset){
		variables.offset = arguments.offset;
		variables.qs.setValue(getFieldNameWithTablePrefix("offset"), arguments.offset);
	}

	public void function sort(required string column, required string direction){

		var column = findColumnByName(arguments.column).elseThrow("The column name #arguments.column# was not a valid name");

		variables.Rows.sort(column=column.getDataName(), direction=arguments.direction);

		if(column.getIsPrimary()){
			variables.isSortedById = true;
		}

		variables.sortString = column.getColumnName();
		variables.direction = arguments.direction;

		variables.qs.setValues({"#getFieldNameWithTablePrefix("sort")#":column.getColumnName(), "#getFieldNameWithTablePrefix("direction")#":arguments.direction});

		// for(var updateColumn in variables.columns){
		// 	updateColumn.setQueryString(variables.qs.getNew());
		// }

		column.setIsSorted(true);
		if(direction == "asc"){
			variables.isSortAsc = true;
			variables.isSortDesc = false;
			column.setIsSortedAsc(true);
		} else {
			variables.isSortAsc = false;
			variables.isSortDesc = true;
			column.setIsSortedDesc(true);
		}

	};

	public struct function toJson(){

		var pagination = this.getPagination();

		var zeroOut = {};
		zeroTableOut["ajax_target"] = this.getAjaxTarget();
		zeroTableOut["base_path"] = this.getbasePath();
		zeroTableOut["clear_edit_link"] = this.getclearEditLink();
		zeroTableOut["clear_filters_link"] = this.getclearFiltersLink();
		zeroTableOut["clear_search_link"] = this.getclearSearchLink();
		zeroTableOut["column_count"] = this.getColumnCount();
		zeroTableOut["csv_download_link"] = this.getCSVDownloadLink();
		zeroTableOut["current_link"] = this.getcurrentLink();
		zeroTableOut["current_page_id"] = this.getcurrentPageId();
		zeroTableOut["current_params_as_string"] = this.getcurrentParamsAsString();
		zeroTableOut["direction"] = this.getdirection();
		zeroTableOut["has_filterable_columns"] = this.getHasFilterableColumns();
		zeroTableOut["has_filters"] = this.getHasFilters();
		zeroTableOut["inverse_sort_link"] = this.getInverseSortLink();
		zeroTableOut["is_sort_asc"] = this.getIsSortAsc();
		zeroTableOut["is_sort_desc"] = this.getIsSortDesc();
		zeroTableOut["max"] = this.getmax();
		zeroTableOut["more"] = this.getmore();
		zeroTableOut["next_more"] = this.getnextMore();
		zeroTableOut["offset"] = this.getoffset();
		zeroTableOut["persist_fields"] = this.getPersistFields();
		zeroTableOut["reset_more_link"] = this.getResetMoreLink();
		zeroTableOut["search"] = this.getsearch().else("");
		zeroTableOut["show_more_link"] = this.getshowMoreLink();
		zeroTableOut["show_row_filter_buttons"] = this.getshowRowFilterButtons();
		zeroTableOut["sort"] = this.getSort();
		zeroTableOut["style"] = this.getStyle();
		zeroTableOut["toolbar"] = variables.toolbar?:{};
		zeroTableOut["use_zero_ajax"] = this.getuseZeroAjax();
		zeroTableOut["layout"] = this.getLayout();

		for(var layout in variables.validLayouts){
			zeroTableOut["layout_#layout#_link"] = this.getCurrentQueryString().setValue(getFieldNameWithTablePrefix("layout"), "#layout#").get();
			zeroTableOut["is_layout_#layout#"] = variables.layout == layout;
		}

		if(variables.keyExists("tableName") and len(trim(variables.tableName)) gt 0){
			zeroTableOut["table_name"] = variables.tableName;
			zeroTableOut["table_name_prefix"] = "#variables.tableName#."
		} else {
			zeroTableOut["table_name_prefix"] = "";
		}

		zeroTableOut["rows"] = this.getRows();

		zeroTableOut["pagination"] = this.getPagination().toJson();
		zeroTableOut["columns"] = [];
		for(var column in this.getColumns()){
			zeroTableOut["columns"].append(column.toJson())
		}

		//2022-11-21: Add columns as struct for designs which are hardcoded
		//columns this is easier to access
		zeroTableOut["columns_as_struct"] = {};
		for(var column in zeroTableOut["columns"]){
			zeroTableOut["columns_as_struct"][column.column_name] = column;
		}

		zeroTableOut["primary_column"] = this.getPrimaryColumn().elseThrow("Table must have one primary column").toJson();
		zeroTableOut["current_params"] = this.getCurrentParams();
		zeroTableOut["current_params_as_struct"] = this.getCurrentParamsAsStruct();

		for(var param in zeroTableOut["current_params"]){
			if(isObject(param.value) and isInstanceOf(param.value, "optional")){
				param.value = param.value.else("");
			}
		}

		for(var key in zeroTableOut["current_params_as_struct"]){
			if(isObject(zeroTableOut["current_params_as_struct"][key].value) and isInstanceOf(zeroTableOut["current_params_as_struct"][key].value, "optional")){
				zeroTableOut["current_params_as_struct"][key].value = zeroTableOut["current_params_as_struct"][key].value.else("");
			}
		}


		// for(var siblingTable in variables.siblingTables){
		// 	var siblingParams = siblingTable.getCurrentParams();
		// 	arrayMerge(zeroTableOut["current_params"], siblingParams);
		// }

		decorateRowsWithRowEditPanel(zeroTableOut.rows);
		decorateRowsWithCustomColumns(zeroTableOut.rows);
		decorateRowsWithWrapColumns(zeroTableOut.rows);
		decorateRowsWithRowOnClick(zeroTableOut.rows);

		return zeroTableOut;
	}

	public function update( numeric max=10,
							numeric more,
							numeric offset=0,
							sort,
							direction,
							goto_page,
							search,
							edit_col,
							edit_id,
							row_edit_panel,
							edit_message,
							filters,
							download_csv,
							string show_columns,
							string layout

	){

		// writeDump(callStackGet());
		if(arguments.keyExists("max") and trim(arguments.max) != ""){
			setMax(arguments.max);
		}
		if(arguments.keyExists("more") and trim(arguments.more) != "" and more > 0){ setMore(arguments.more)}
		if(arguments.keyExists("offset") and trim(arguments.offset) != ""){ setOffset(arguments.offset)}

		//SORTING
		if(arguments.keyExists("sort") and trim(arguments.sort) != ""){
			var dir = "asc";
			if(arguments.keyExists("direction") and trim(arguments.direction) != ""){dir = arguments.direction}
			this.sort(arguments.sort, dir);
		}

		//FILTERING
		if(arguments.keyExists("filters")){
			variables.filters = arguments.filters;
			for(var filter in filters){
				this.filter(columnName=filter, value=filters[filter]);
			}
		}


		//SEARCHING
		if(arguments.keyExists("search") and trim(arguments.search) != ""){
			this.search(arguments.search);
		}

		//LAYOUT
		if(arguments.keyExists("layout") and trim(arguments.layout) != ""){
			this.setLayout(arguments.layout);
		}

		//DOWNLOAD CSV
		// After all of the sorting, filterting and searching has been applied, check
		// if the download_csv flag is set. If so, then we will call downloadCSVData which
		// calls cfcontent and will essentially abort the code below
		if(arguments.keyExists("download_csv") and arguments.download_csv == true){
			this.downloadCSVData();
		}

		//EDITING
		if(
			(arguments.keyExists("edit_col") and trim(arguments.edit_col) != "") and
			(arguments.keyExists("edit_id") and trim(arguments.edit_id) != "")
		){

			if(arguments.keyExists("edit_message") and trim(arguments.edit_message) != ""){
				this.edit(arguments.edit_col, arguments.edit_id, arguments.edit_message);
			} else {
				this.edit(arguments.edit_col, arguments.edit_id);
			}
		}

		if(arguments.keyExists("show_columns")){
			variables.show_columns = arguments.show_columns;
			var toShow = listToArray(variables.show_columns);
			var Columns = this.getColumns();
			//First set all of the columns to hidden because we
			//are only going to unhide the columns which are
			//passed in
			for(var Column in Columns){
				Column.setHidden(true);
			}

			for(var showColumn in toShow){
				for(var Column in Columns){
					if(Column.getColumnName() == showColumn){
						Column.setHidden(false);
					}
				}
			}

			//Sort the columns by the passed in columns string. This allows
			//the user to reoder the columns in the table

			//1. First add the passed in columns
			var sortOut = [];
			for(var showColumn in toShow){
				for(var Column in Columns){
					if(Column.getColumnName() == showColumn){
						sortOut.append(Column);
					}
				}
			}

			//2. Then add all the other columns. Hidden columns will be in their original order
			for(var Column in Columns){
				var found = false;
				for(var SortColumn in sortOut){
					if(Column.getColumnName() == SortColumn.getColumnName()){
						found = true;
					}
				}
				if(!found){
					sortOut.append(Column);
				}
			}
			variables.columns = sortOut;

		} else {
			//If the show columns was removed then we are going to show all
			for(var Column in Columns){
				Column.setHidden(false);
			}
		}

		if(arguments.keyExists("row_edit_panel") and trim(arguments.row_edit_panel) != ""){
			variables.rowEditPanelId = arguments.row_edit_panel;
		}

		//JUMP TO PAGE. Needs to be last so that other values are updated first
		if(arguments.keyExists("goto_page") and trim(arguments.goto_page) != ""){
			var pagination = getPagination();
			var page = pagination.findPageById(arguments.goto_page).elseThrow("That is not a valid page to go to");
			location url="#page.getLink()#" addtoken="false";
		}

	}

	public function updateWithZeroTableFields(zeroTableFields zeroTableFields){
		update(argumentCollection=arguments.zeroTableFields.toStruct());
	}

	/**
	 * Filters the return rows to only the Id values that match the given input.
	 * This can use used to globally filter the result set from outside any of the
	 * filters, search or other clauses.
	 *
	 * @values A string list of Ids to filter the result set
	 */
	public function whereIdsMatch(array ids){
		variables.Rows.whereIdsMatch(arguments.ids);
	}

	/**
	 * Returns additional rows matching the Ids provided. Can be useful
	 * for globally returning additional rows from the data provider based
	 * on another search not included in the typical search
	 *
	 * @values A string list of Ids to include in the result set
	 */
	public function orSearchIdsMatch(array ids){
		variables.Rows.orSearchIdsMatch(arguments.ids);
	}

}