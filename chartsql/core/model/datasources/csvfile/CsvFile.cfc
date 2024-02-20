import com.chartsql.core.util.QueryUtil;
import com.chartsql.core.model.datasources.sqlite.SQLite;
import com.chartsql.core.model.values.Datetimeish;
component
    accessors="true"
    extends="com.chartsql.core.model.JdbcDatasource"
	isStudioDatasource="true"
	displayName="CSV File"
	description="Local CSV File"
	iconClass="ti ti-file-type-csv"
{

	property name="FilePath" required="true" description="The local path to the CSV file";
	property name="Name" required="true" description="The name of the table to put the CSV data into";

	public function init(){

		super.init(argumentCollection=arguments);

		// Create a backing SQLite database to store the CSV data
		// we will use this to execute SQL queries against the CSV data
		var path = expandPath("/com/chartsql/userdata/db/csvfile/#variables.name#");
		// writeDump(path);
		if(!directoryExists(path)){
			directoryCreate(path, true);
		}

		variables.SQLite = new SQLite(
			FolderPath = path,
			Database = "data.sqlite"
		)
		return this;
	}

	public query function execute(SqlScript){
		return this.executeSql(arguments.SqlScript.stripDirectives());
	}

    /**
    * @sql A SQL statement to execute
    * @returns query
    */
    public query function executeSql(string sql) {

		var data = variables.SQLite.executeSql(arguments.sql);

        return data;
    }

    /**
    * Returns a lucee datasource struct
    */
    public struct function getConnectionInfo(){
		return variables.SQLite.getConnectionInfo();
	}

	/**
	 * Imports the CSV into the database
	 */
	public function importCSv() {

		var data = new cfcsv().parseCSV(file=variables.FilePath);
		var QueryUtil = new QueryUtil(data);
		var metaData = QueryUtil.getMetaData(includeData=false, inferTypes = true);

		query datasource="#this.getConnectionInfo()#" result="create" {
			echo("
				DROP TABLE IF EXISTS #variables.Name#;
			")
		}

		var createColumns = [];
		for(var columnName in metaData.columnArray){
			var column = metaData.columns[columnName];
			var cleanedColumnName = column.name.replace(" ", "_", "all");
			switch(column.finalType) {
				case "string":
					if(column.numberish){
						createColumns.append(cleanedColumnName & " INTEGER");
					} else {
						createColumns.append(cleanedColumnName & " VARCHAR(#column.inferredLength#)");
					}
					break;
				case "numeric":
					createColumns.append(cleanedColumnName & " INTEGER");
					break;
				case "date":
					createColumns.append(cleanedColumnName & " TEXT");
					break;
				default:
					createColumns.append(cleanedColumnName & " VARCHAR(50)");
			}
			// createColumns.append(column.name & " " & column.type);
		}

		// writeDump(createColumns);

		var sql = "
			CREATE TABLE #variables.Name# (
				#arrayToList(createColumns, ",")#
			);
		"

		query name="create" datasource="#this.getConnectionInfo()#" {
			echo(sql)
		}

		var rowOutput = [];
		var insertColumns = [];
		var insertValues = [];

		for(var columnName in metaData.columnArray){
			var column = metaData.columns[columnName];
			var cleanedColumnName = column.name.replace(" ", "_", "all");
			insertColumns.append(cleanedColumnName);
		}

		for(var row in data){

			var rowPlaceholders = [];

			column: for(var columnName in metaData.columnArray){
				var column = metaData.columns[columnName];
				rowPlaceholders.append("?");

				switch(column.finalType) {
					case "string":

						if(column.numberish){
							if(isNumeric(row[columnName])){
								// We dont need to do anything, we can use the value as is
							} else {

								// Simple remove commas and dollar signs and all simple values
								// that having removed the extraneous characters we can still
								// determine if the value is a number
								var value = row[columnName]
									.replace("$", "", "all")
									.replace(",", "", "all")
									.replace(" ", "", "all")
									.replace("€", "", "all")
									.replace("£", "", "all")
									.replace("¥", "", "all")
									.replace("₹", "", "all")
									.replace("₩", "", "all")
								if(isNumeric(value)){
									row[columnName] = value;
								} else {

									var scientificNotation = reReplaceNoCase(value, "([0-9]+)[\^]([0-9]+)", "\1", "all");
									var percentNotation = reReplaceNoCase(value, "([0-9]+)[%]", "\1", "all");
									var negativeParentheses = reReplaceNoCase(value, "[(]([0-9]+\.?[0-9]*)[)]", "-\1", "all");
									var thousandsNotation = reReplaceNoCase(value, "([0-9]+\.?[0-9]*)[kK]", "\1", "all");
									var millionsNotation = reReplaceNoCase(value, "([0-9]+\.?[0-9]*)[mM]", "\1", "all");
									var billionsNotation = reReplaceNoCase(value, "([0-9]+\.?[0-9]*)[bB]", "\1", "all");

									if(isNumeric(scientificNotation)){
										var left = reReplaceNoCase(value, "([0-9]+)[\^]([0-9]+)", "\1", "all");
										var right = reReplaceNoCase(value, "([0-9]+)[\^]([0-9]+)", "\2", "all");
										row[columnName] = left ^ right;
									} else if(isNumeric(percentNotation)){
										row[columnName] = percentNotation / 100;
									} else if(isNumeric(negativeParentheses)){
										row[columnName] = negativeParentheses;
									} else if(isNumeric(thousandsNotation)){
										row[columnName] = thousandsNotation * 1000;
									} else if(isNumeric(millionsNotation)){
										row[columnName] = millionsNotation * 1000000;
									} else if(isNumeric(billionsNotation)){
										row[columnName] = billionsNotation * 1000000000;
									} else {
										row[columnName] = left(row[columnName], column.inferredLength);
									}
								}
							}
						} else if(column.datetimeish){

							row[columnName] = new Datetimeish(row[columnName]).datetimeFormat("yyyy-mm-dd HH:nn:SS");

						} else {
							row[columnName] = left(row[columnName], column.inferredLength);
						}
						break;
					case "numeric":
						row[columnName] = row[columnName]
							.replace("$", "", "all")
							.replace(",", "", "all")
							.replace(" ", "", "all");

						//If the nuber contains ( or ) then it is a negative number
						if(find("(", row[columnName])){
							row[columnName] = "-" & replace(row[columnName], "(", "", "all");
							row[columnName] = replace(row[columnName], ")", "", "all");
						}

						break;
					case "date":
						row[columnName] = dateTimeFormat(row[columnName], "yyyy-mm-dd HH:nn:SS");
						break;
				}

				insertValues.append(row[columnName]);
			}

			rowOutput.append("(#arrayToList(rowPlaceholders, ',')#)");
		}

		var insertSql = "
			INSERT INTO #variables.Name# (#arrayToList(insertColumns, ",")#)
			VALUES #arrayToList(rowOutput, ",")#
		";

		query name="insert" datasource="#this.getConnectionInfo()#" params="#insertValues#" {
			echo(insertSql);
		}

	}

    /**
    * Throws an error if the datasource connection cannot
    * be verified otherwise we assume it is successfull
    */
    public void function verify(numeric timeout=5){
		// We are just going to check that we can reach the CSV file and parse it
		var csv = new cfcsv().parseCSV(file=variables.FilePath);
    }

    /**
    * Returns an array of TableInfo for ChartSQL to show
    * available table in the schema browser
    */
    public TableInfo[] function getTableInfos(){
		return variables.SQLite.getTableInfos();
    }

    /**
    * Returns an array of FieldInfo for ChartSQL to show
    * available fields/columns in the schema browser
    * @tableName A name of a table in the database
    */
    public FieldInfo[] function getFieldInfos(required string tableName){
        return variables.SQLite.getFieldInfos(arguments.tableName);
    }

}