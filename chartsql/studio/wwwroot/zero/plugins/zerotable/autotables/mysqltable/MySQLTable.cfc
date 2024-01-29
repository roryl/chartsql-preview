/**
* Implements a Zerotable for any arbitrary MySQL database table
*/
import zero.plugins.zerotable.model.zerotable;
import zero.plugins.zerotable.model.column;
component accessors="true" {

	property name="datasource" hint="The datasource that zerotable will operate on";
	property name="tableName" setter="false" hint="The table name to build the columns from";
	property name="zerotable" setter="false" hint="The underlying instantiated zerotable.cfc class. Use this if you need to manipulate zerotable directly";
	property name="tableData" setter="false" hint="The underlying implemented Data.cfc class. Use this if you need to manipulate the data access directly";
	property name="hasIncludeColumns" setter="false" hint="Whether or not this instance has requested specific columns be included";
	property name="hasExcludeColumns" setter="false" hint="Whether or not this instance has requested specific columns be excluded";

	/**
	* Implements a Zerotable for a generic MySQL table
	* @datasource the datasource to use to connect to the MySQL table
	* @tableName the table name to build the zerotable from
	* @includeColumns a List or Array, if specified, only the columns matching the supplied names will be used
	* @excludeColumns a List or Array, if specified, all columns will be used except those specified
	*/
	public function init(
		  required string datasource
		, required string tableName
		, any includeColumns
		, any excludeColumns
	){

		variables.datasource = arguments.datasource;
		variables.tableName = arguments.tableName;
		variables.sourceSQLColumns = this.getSQLColumns();
		variables.tableData = new MySQLTableData(MySQLTable=this);

		if(arguments.keyExists("includeColumns") and arguments.keyExists("excludeColumns")){
			throw("Cannot use includeColumns and excludeColumns together, use only one or another");
		}

		/*
		User can specity only certain columns to include
		*/
		if(arguments.keyExists("includeColumns")){
			variables.hasIncludeColumns = true;
			if(isArray(arguments.includeColumns)){
				variables.includeColumns = arguments.includeColumns;
			} else {
				variables.includeColumns = listToArray(arguments.includeColumns);
			}
		} else {
			variables.hasIncludeColumns = false;
		}

		if(arguments.keyExists("excludeColumns")){
			variables.hasExcludeColumns = true;
			if(isArray(arguments.excludeColumns)){
				variables.excludeColumns = arguments.excludeColumns;
			} else {
				variables.excludeColumns = listToArray(arguments.excludeColumns);
			}
		} else {
			variables.hasExcludeColumns = false;
			variables.hasExcludeColumns = false;
		}

		//Instantiate an instance of zerotable and pass in the rowData
		//into the zero table
		variables.zeroTable = new zero.plugins.zerotable.model.ZeroTable(
		  	  rows=tableData
		  	, tableName = arguments.tableName
			, toolbar={
				show:false
			}
		);

		for(var column in variables.sourceSQLColumns){

			if(this.getHasIncludeColumns()){
				var found = false;
				for(var includeColumn in variables.includeColumns){
					if(lcase(includeColumn) == lcase(column.getName())){
						found = true;
						break;
					}
				}
				if(!found){
					continue;
				}
			}

			if(this.getHasExcludeColumns()){
				var found = false;
				for(var excludeColumn in variables.excludeColumns){
					if(lcase(excludeColumn) == lcase(column.getName())){
						found = true;
						break;
					}
				}
				if(found){
					continue;
				}
			}

			variables.zeroTable.addColumn(
				new column(
					  columnName=column.getName()
					, isPrimary=column.getIsPrimary()
				)
			)
		}
		return this;
	}

	/**
	* Execute the data selection and serialize the zerotable output to a structure for rendering.
	*/
	public function toJson(){
		return variables.zeroTable.toJson();
	}

	/**
	* Takes an instance of zeroTableFileds and updates the zeroTable with the provided options.
	*/
	public function update(required zeroTableFields fields){
		return variables.zeroTable.updateWithZeroTableFields(arguments.fields);
	}

	package void function executeDDL(required string ddl){
		var data = "";
		query name="data" datasource="#variables.datasource#"{
			echo(arguments.sql);
		}
	}

	package query function executeSQL(required string sql, params={}){
		var data = "";
		query name="data" datasource="#variables.datasource#" params="#arguments.params#"{
			echo(arguments.sql);
		}
		return data;
	}

	/*
	* Return the recordset from the database that describes
	* the columns available in this source table
	*/
	package query function getColumns(){
		var result = this.executeSQL("DESCRIBE #variables.tableName#");
		return result;
	}

	/*
	* Get an array of sqlColumn.cfc which are
	* data transfer objects
	*/
	package sqlColumn[] function getSqlColumns(){
		var result = getColumns();
		var out = [];
		for(var column in result){
			out.append(new sqlColumn(
				name:column.Field,
				type:column.Type,
				allowNull:((column.Null == "YES")?true:false),
				key:column.key,
				default:column.default,
				extra:column.extra
			))
		}
		return out;
	}

	/**
	* Renders a HTML zerotable directly to the output stream. Use this when you do not want to manually include the zerotable template in your views
	*/
	public function render(){
		var out = "";
		savecontent variable="out"{
			module name="handlebars" context="#this.getZeroTable().toJson()#" {
				include template="/zero/plugins/zerotable/views/main/table.hbs";
			}
		}
		echo(out);
	}

}