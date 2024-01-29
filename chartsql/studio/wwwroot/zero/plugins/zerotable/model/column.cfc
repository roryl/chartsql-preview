/**
 * Represents a configuration for a particular column
*/
component accessors="true"{

	property name="columnName" setter="false";
	property name="dataName" setter="false";
	property name="errorMessage";
	property name="friendlyName";
	property name="hidden";
	property name="hasWrap" setter="false";
	property name="isFiltered" type="boolean";
	property name="isSorted" type="boolean";
	property name="isSortedDesc" type="boolean";
	property name="isSortedAsc" type="boolean";
	property name="sortAscLink";
	property name="sortDescLink";
	property name="clearFilterLink";
	property name="edit" type="boolean";
	property name="editable" type="boolean";
	property name="sortable" type="boolean" default="true";
	property name="columnType" type="struct" setter="false";
	property name="isPrimary" type="boolean" setter="false";
	property name="filter" type="array" setter="false";
	property name="filterable" type="boolean" setter="false";
	property name="width" type="string" setter="false";
	property name="textAlign" type="string" setter="false";
	property name="icon" type="string";
	property name="columnRowDataPath" type="string" hint="The json path to the column data from the row" setter="false";
	property name="showRowFilterButton" type="boolean";

	public function init(required string columnName,
						 string friendlyName,
						 string columnRowDataPath,
						 boolean editable=false,
						 struct columnType,
						 boolean isPrimary=false,
						 struct filter,
						 string icon="",
						 hidden = false,
						 sortable = true,
						 width="",
						 textAlign="left",
						 boolean showRowFilterButton=true
						 ){
		variables.columnName = arguments.columnName;

		if(arguments.keyExists("columnType")){
			variables.columnType = arguments.columnType;
		} else {
			variables.columnType = {"text":true}
		}

		if(arguments.keyExists("friendlyName")){
			variables.friendlyName = arguments.friendlyName;
		} else {
			variables.friendlyName = arguments.columnName;
		}

		if(arguments.keyExists("dataName")){
			variables.dataName = arguments.dataName;
		} else {
			variables.dataName = arguments.columnName;
		}

		if(arguments.keyExists("filter")){
			variables.filter = arguments.filter;
			variables.filterable = true;
			if(arguments.filter.keyExists("value")){
				setFilteredValue(arguments.filter.value);
			}

		} else {
			variables.filterable = false;
			variables.filter = {};
		}

		if(arguments.keyExists("Wrap")){
			variables.Wrap = arguments.Wrap;
			variables.hasWrap = true;
		} else {
			variables.hasWrap = false;
			variables.Wrap = "{{value}}";
		}

		if(arguments.keyExists("columnRowDataPath")){
			variables.columnRowDataPath = arguments.columnRowDataPath;
		} else {
			variables.columnRowDataPath = arguments.columnName;
		}

		variables.textAlign = arguments.textAlign;
		variables.width = arguments.width;

		variables.customOutput = "";

		variables.isPrimary = arguments.isPrimary;
		variables.editable = arguments.editable;
		variables.sortable = arguments.sortable;
		variables.isSorted = false;
		variables.isSortedDesc = false;
		variables.isSortedAsc = false;
		variables.hidden = arguments.hidden;
		variables.icon = arguments.icon;
		variables.showRowFilterButton = arguments.showRowFilterButton;
		// variables.queryString = arguments.queryString;
		return this;
	}

	public function equals(required column){
		if(arguments.column.getColumnName() == variables.columnName){
			// writeDump(variables.columnName);
			// writeDump(arguments.column.getColumnName());
			return true
		} else {
			return false;
		}
	}

	public function getColumnType(){

		if(variables.columnType.keyExists("custom")){
			var out = duplicate(variables.columnType);
			if(isClosure(out.output)){
				out.output = "function call";
			}
			return out;
		}

		return variables.columnType;

	}

	public function getCustomOutput(required struct row, zeroTable zeroTable){

		var out = "";
		if(variables.columnType.keyExists("custom") and variables.columnType.custom){
			if(isSimpleValue(variables.columnType.output)){
				out = variables.columnType.output;
			} else if(isClosure(variables.columnType.output)){
				if(variables.keyExists("zeroTable")){
					out = evaluate("variables.columnType.output(arguments.row, variables.zeroTable)");
				} else {
					out = evaluate("variables.columnType.output(arguments.row)");
				}
			}
			else {
				out = variables.customOutput;
			}
		}

		if(isNull(out)){
			throw("Custom output for column '#variables.columnName#' did not return a value. It must return at least an empty string");
		}

		out = replaceNoCase(out, "{{current_params_as_string}}", variables.zeroTable.getCurrentParamsAsString(), "all");

		return out;
	}

	public function getFilter(){
		var out = variables.filter;
		if(out.keyExists("data")){
			for(var item in out.data){
				var qs = variables.zeroTable.getQueryString().getNew();
				var value = trim(qs.getValue(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#")));
				var listKeys = structNew("ordered");

				//Get all of the keys except this one
				var exceptKeys = structNew("ordered");
				for(var exceptItem in out.data){
					if(exceptItem.id != item.id){
						exceptKeys[exceptItem.Id] = true;
					}
				}

				if(len(value)){
					var listData = listToArray(value);

					for(var listItem in listData){
						listKeys[listItem] = true;
					}
					if(listKeys.keyExists(item.id)){
						item["is_filtered"] = true;
					} else {
						item["is_filtered"] = false;
					}
				} else {
					item["is_filtered"] = false;
				}

				var addStruct = duplicate(listKeys);
				addStruct[item.id] = true;
				var addList = structKeyList(addStruct);
				item["add_link"] = qs.setValue(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#"),addList).get();

				var removeStruct = duplicate(listKeys);
				structDelete(removeStruct, item.id);
				var removeList = structKeyList(removeStruct);
				if(structCount(removeStruct) == 0){
					item["remove_link"] = qs.delete(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#")).get();
				} else {
					item["remove_link"] = qs.setValue(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#"),removeList).get();
				}

				item["only_link"] = qs.setValue(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#"),item.id).get();
				item["except_link"] = qs.setValue(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#"),structKeyList(exceptKeys)).get();
			}
		}
		return out;
	}

	public function getInputName(){
		return zeroTable.getFieldNameWithTablePrefix(this.getColumnName());
	}

	public function getWrapOutput(required string value){
		var out = replaceNoCase(variables.Wrap, "{{value}}", arguments.value, "all");
		return out;
	}

	public function getClearFilterLink(){
		return variables.zeroTable.getQueryString().getNew().delete(variables.zeroTable.getFieldNameWithTablePrefix("filters.#getColumnName()#")).get();
	}

	public function getSortAscLink(){
		return variables.zeroTable.getQueryString().getNew().delete(variables.zeroTable.getFieldNameWithTablePrefix("direction")).setValues({"#variables.zeroTable.getFieldNameWithTablePrefix("sort")#":getColumnName(), "#variables.zeroTable.getFieldNameWithTablePrefix("direction")#":"asc"}).get();
	}

	public function getSortDescLink(){
		return variables.zeroTable.getQueryString().getNew().delete(variables.zeroTable.getFieldNameWithTablePrefix("direction")).setValues({"#variables.zeroTable.getFieldNameWithTablePrefix("sort")#":getColumnName(), "#variables.zeroTable.getFieldNameWithTablePrefix("direction")#":"desc"}).get();
	}

	public function setFilteredValue(required any value){
		variables.filter.value = arguments.value;
		variables.isFiltered = true;
	}

	public function setIsSortedAsc(){
		variables.isSortedAsc = true;
		variables.isSortedDesc = false;
	}

	public function setIsSortedDesc(){
		variables.isSortedAsc = false;
		variables.isSortedDesc = true;
	}

	public function setZeroTable(required zeroTable zeroTable){
		variables.zeroTable = arguments.zeroTable;
	}

	/**
	 * Make setColumnName package available so that zerotable can change it to underscores if desired
	 */
	package function setColumnName(string columnName){
		variables.columnName = arguments.columnName;
	}

	public function toJson(){
		var out = {
			"clear_filter_link":this.getClearFilterLink(),
			"column_name":this.getcolumnName(),
			"column_row_data_path":this.getColumnRowDataPath(),
			"column_type":this.getcolumnType(),
			"data_name":this.getdataName(),
			"edit":this.getedit(),
			"editable":this.geteditable(),
			"error_message":this.geterrorMessage(),
			"filter":this.getfilter(),
			"filterable":this.getfilterable(),
			"friendly_name":this.getfriendlyName(),
			"has_wrap":this.gethasWrap(),
			"hidden":this.gethidden(),
			"icon":this.getIcon(),
			"input_name":this.getInputName(),
			"is_filtered":this.getIsFiltered(),
			"is_primary":this.getisPrimary(),
			"is_sorted_asc":this.getisSortedAsc(),
			"is_sorted_desc":this.getisSortedDesc(),
			"is_sorted":this.getisSorted(),
			"show_row_filter_button":this.getShowRowFilterButton(),
			"sort_asc_link":this.getsortAscLink(),
			"sort_desc_link":this.getsortDescLink(),
			"sortable":this.getSortable(),
			"text_align":this.getTextAlign(),
			"width":this.getWidth(),
		}
		return out;
	}

}