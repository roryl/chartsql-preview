<!---
Author: Rory Laitila
A quick utility to insert a CF Query recordset into a table. The column names of the CFquery must be the same names as the actual table
--->
<cfcomponent>
	<cffunction name="init">
		<cfargument name="query" type="query" required="true" hint="The CF query that you want to insert. The Column names must match that of the table they are being inserted into">
		<cfargument name="table" type="string" required="true" hint="The table name that we will insert into">
		<cfargument name="batchSize" type="numeric" default="2000">
		<cfargument name="insertIgnore" default="false">
		<cfargument name="upsert" default="false">
		<cfargument name="datasource" default="">
		<cfargument name="uniqueFields" default="">
		<cfargument name="returnLastInsertID" default="false">
		<cfargument name="dropCreate" default="false">
		<cfargument name="dbcreate" default="false">
		<cfargument name="cleanColumnNames" default="true">

		<cfset variables.cleanColumnNames = arguments.cleanColumnNames>

		<cfif arguments.insertIgnore == true AND arguments.upsert == true>
			<throw message="You can't insert ignore and upsert at the same time, pick one or another"/>
		</cfif>

        <cfset local.columnList = arguments.query.columnList()>
        <cfset local.columnArray = arguments.query.columnArray()>

		<cfset local.uncleancolumnList = arguments.query.columnArray()>
		<cfset local.cleanColumnArray = arrayMap(local.uncleancolumnList, function(item){return this.getCleanColumnName(item)})>

        <cfset local.cleanColumnList = arrayToList(cleanColumnArray)>

		<cfset columnCount = listLen(columnList)>
		<cfset local.batches = getBatchCount(arguments.query.recordCount,arguments.batchSize)>
		<cfscript>
			// writeDump(arguments.query.columnList());
				// query name="variables.ddl" datasource="#arguments.datasource#"
				// {
				// 	echo('SHOW COLUMNS FROM #arguments.table#;');
				// }

				if(arguments.dropcreate){
					executeQuery(sql='DROP TABLE IF EXISTS #arguments.table#;', datasource=arguments.datasource);
				}

				if(arguments.dbcreate){
					createTableIFNotExists(table=arguments.table, datasource=arguments.datasource);
					createMissingColumns(columns=local.columnArray, table=arguments.table, datasource=arguments.datasource, uniqueFields=arguments.uniqueFields);
				}

				variables.ddl = executeQuery('SHOW COLUMNS FROM #arguments.table#;',arguments.datasource, []);

				for(i1 = 1 ; i1 LTE local.batches; i1++)
				{
					local.start = getStartRecord(i1, arguments.batchSize, arguments.query.recordCount);
					local.end = getEndRecord(i1, arguments.batchSize, arguments.query.recordCount);
					local.params = [];
					// writeDump(local.columnArray);
					savecontent variable="local.sql" {
						echo("INSERT #((insertIgnore)?'IGNORE':'')# into #arguments.table# (#local.cleanColumnList#) VALUES");

						// local.columnArray = listToArray(local.columnList);
						loop from="#local.start#" to="#local.end#" index="i2"
						{
							echo("(");
							loop array="#local.columnArray#" item="column" index="i3"
							{
								local.paramType = getParamType(column);

								// if(local.paramType IS "date" AND arguments.query[column][i2] IS '')
								// {
								// 	arguments.query[column][i2] = '0000-00-00'
								// }

								// if(local.paramType IS "time" AND arguments.query[column][i2] IS '')
								// {
								// 	arguments.query[column][i2] = '0000-00-00'
								// }

								// if(local.paramType IS "timestamp" AND arguments.query[column][i2] IS '')
								// {
								// 	arguments.query[column][i2] = '0000-00-00'
								// }

								// if(local.paramType IS "int" AND arguments.query[column][i2] IS '')
								// {
								// 	arguments.query[column][i2] = '0'
								// }

								if(trim(arguments.query[column][i2]) IS '' OR trim(arguments.query[column][i2]) IS 'null')
								{
									echo('NULL');
									//queryparam value="NULL";
								}
								else
								{
									/*
									Couldn't get this to insert without singleing out the dates for queryparam, and everything else as a straight echo. This
									could be an issue with data types in the database. Could look at this again later to see what is the issue.
									*/
									if(isDate(arguments.query[column][i2]))
									{
										try{
											echo(' ? ');
											//local.params.append({value:arguments.query[column][i2]});
											local.params.append({value:arguments.query[column][i2], sqltype:getParamType(column)});
											//queryparam cfsqltype="#getParamType(column)#" value="#arguments.query[column][i2]#";
										} catch (any e)
										{
											writeDump(column);
											abort;
										}
									}
									else
									{
										//Clean any text which could look like a Railo parameter
										local.cleaned = arguments.query[column][i2];
										local.cleaned = rereplacenocase(local.cleaned,":([A-Za-z|0-9]*) +","(\1)","all");
										//echo("'#escapeSingleQuotes(local.cleaned)#'");
										echo(' ? ');
										local.params.append({value:left(arguments.query[column][i2],256), sqltype:getParamType(column)});
									}

									//echo("'#escapeSingleQuotes(arguments.query[column][i2])#'");
								}

								// if(isDate(arguments.query[column][i2]))
								// {

								// 	//echo("'#escapeSingleQuotes(arguments.query[column][i2])#'");
								// }
								// else
								// {
									//echo("'#escapeSingleQuotes(arguments.query[column][i2])#'");
								// }

								if(i3 LT local.columnArray.len())
								{
									echo(",")
								}

							}

							echo(") ")

							if(i2 LT local.end)
							{
								echo(",")
							}

						}

						if(arguments.upsert)
						{
							echo('ON DUPLICATE KEY UPDATE ');
							loop array="#local.cleanColumnArray#" item="local.column" index="idx"
							{
								echo("#local.column# = VALUES(#local.column#)")

								if(idx LT local.columnArray.len())
								{
									echo(', ')
								}

							}
						}

					}
					writeLog(file="insertcfquery",text="Executing batch of #local.end - local.start# records");
					// writeDump(local.sql);
					executeQuery(local.sql, arguments.datasource, local.params);
					writeLog(file="insertcfquery",text="Ending batch of #local.end - local.start# records");
				}
		</cfscript>
		<cfif returnLastInsertID>
			<cfquery datasource="#arguments.datasource#" name="result">
				SELECT LAST_INSERT_ID() AS newID
			</cfquery>
			<cfreturn result.newID>
		</cfif>
	</cffunction>

	<cffunction name="executeQuery" access="public">
		<cfargument name="sql" required="true">
		<cfargument name="datasource">
		<cfargument name="params" default="#{}#">
		<cfif structKeyExists(arguments,"datasource") AND (isStruct(arguments.datasource) or arguments.datasource IS NOT "")>
			<cftry>
				<cftransaction>
					<cfquery  name="local.sqlresult" psq="true" datasource="#arguments.datasource#" params="#arguments.params#">
						#arguments.sql#
					</cfquery>
				</cftransaction>
				<cfcatch type="any">
					<!--- <cfdump var="#params#" /> --->
					<cfdump var="#arguments.sql#" />
					<cfdump var="#cfcatch#" />
					<cfabort>
				</cfcatch>
			</cftry>
		<cfelse>

			<cfquery  name="local.sqlresult" psq="true" params="#arguments.params#">
				#arguments.sql#
			</cfquery>
		</cfif>
		<cfif structKeyExists(local,"sqlresult")>
			<cfreturn local.sqlresult>
		</cfif>
	</cffunction>

	<cfscript>

    private function getCleanColumnName(column){

		var cleaned = trim(arguments.column);
		cleaned = replaceNoCase(cleaned, '+',"","all");
		cleaned = replaceNoCase(cleaned, " ","_","all");
		cleaned = replaceNoCase(cleaned, ",","_","all");
		cleaned = replaceNoCase(cleaned, "-","_","all");
		cleaned = replaceNoCase(cleaned, "(","_","all");
		cleaned = replaceNoCase(cleaned, ")","_","all");
		cleaned = replaceNoCase(cleaned, "/","_","all");
		cleaned = replaceNoCase(cleaned, "\","","all");
		cleaned = replaceNoCase(cleaned, '"',"","all");
		cleaned = replaceNoCase(cleaned, '##',"","all");

		return cleaned;
    }

	private function getParamType(columnName) cachedWithin="request" {

		try {
			query name="local.type" dbtype="query"
			{
				echo("select Type from variables.ddl WHERE field = '#this.getCleanColumnName(arguments.columnName)#'");
			}

		} catch(any e)
		{
			writeDump("Error in executing getParamType");
			writeDump(variables.ddl);
			abort;
		}

		local.typeValue = listFirst(local.type.type,"(");

        if(local.typeValue == ""){
            writeDump(local.type);
            writeDump(now());
			writeDump(callStackGet());
            abort;
        }

		if(local.typeValue IS "datetime")
		{
			return "timestamp"
		}

		if(local.typeValue IS "text")
		{
			return "longvarchar";
		}
		else
		{
			return local.typeValue;
		}

	}


	private function getStartRecord(required currentBatchId, batchSize, totalRecordCount)
	{
		if(currentBatchId IS 1)
		{
			return 1;
		}
		else if(((currentBatchId - 1) * batchSize) LTE totalRecordCount)
		{
			return ((currentBatchId - 1) * batchSize) + 1;
		}
	}

	private function getEndRecord(required currentBatchId, batchSize, totalRecordCount)
	{
		if(currentBatchID IS 1)
		{
			if(batchSize GT totalRecordCount)
			{
				return totalRecordCount;
			}
			else
			{
				return batchSize;
			}
		}
		else if(currentBatchID * batchSize GTE totalRecordCount)
		{
			return totalRecordCount;
		}
		else
		{
			return currentBatchID * batchSize;
		}
	}

	private function getBatchCount(required numeric size, required numeric batchSize){

		batches = arguments.size / arguments.batchSize;
		remainder = batches - round(batches);
		if(remainder GT 0){
			batches = round(batches) + 1;
		}
		else{
			batches = round(batches);
		}
		return batches;
	}

	public function createTableIfNotExists(required string table, required any datasource=""){
		local.tables = executeQuery(sql='show tables', datasource=arguments.datasource);

		for(local.row in local.tables){
			for(local.key in local.row){
				if(local.row[local.key] IS "#arguments.table#")
				{
					return false;
				}
			}
		}

        // writeDump(arguments.table);
		local.update = executeQuery(sql='create table if not exists `#arguments.table#` (`autoid` int NOT NULL AUTO_INCREMENT PRIMARY KEY)', datasource=arguments.datasource);
		local.tables = executeQuery(sql='show tables', datasource=arguments.datasource);
		return true;
	}

	private function createMissingColumns(required array columns, required string table, required any datasource="", uniqueFields=""){

		local.ddl = getDDL(table=arguments.table, datasource=arguments.datasource);
        // writeDump(ddl);
		local.allColumns = arguments.columns.map(function(column){
			return this.getCleanColumnName(column);
		});
		local.existingColumns = listToArray(valueList(local.ddl.field));
		// writeDump(existingColumns);
		local.allColumns.removeAll(local.existingColumns);
		// writeDump(local.allColumns);
		// abort;

		var columnAlters = arrayMap(local.allColumns, function(item){
			return "ADD `#getCleanColumnName(item)#` varchar(256)";
		})

		executeQuery(sql='alter table `#arguments.table#` #arrayToList(columnAlters)#', datasource=arguments.datasource);

		for(column IN local.allColumns){
			if(listContains(arguments.uniqueFields, column)){
				executeQuery(sql='ALTER TABLE `#arguments.table#` ADD UNIQUE `idx_#getCleanColumnName(column)#` (#getCleanColumnName(column)#);', datasource=arguments.datasource);
			}
		}

		if(local.allColumns.len() GT 0){
			return true;
		} else {
			return false;
		}
	}

	private function getDDL(required string table, any datasource=""){
		return executeQuery(sql='SHOW COLUMNS FROM #arguments.table#;',datasource=arguments.datasource, params=[]);
	}

	public function escapeSingleQuotes(required string text)
	{
		return replaceNoCase(arguments.text,"'","\'","all");
	}
	</cfscript>

</cfcomponent>