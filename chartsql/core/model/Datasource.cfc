/**
 * Base class for datasoucre components
*/
abstract component accessors="true" {

	variables.RemoteMethods = [];

	public function init(){

		var metaData = getMetaData(this);

		//Setup the remote method when we are created
		this.getRemoteMethods();
		// writeDump(metaData);
		// writeDump(getAllProperties());

		var name = listLast(metaData.name,".");
		var allProperties = getAllProperties();
		for(var prop in allProperties){

			if(prop.keyExists("required") and prop.required){
				if(!arguments.keyExists(prop.name)){
					throw("Required property '#prop.name#' is required in order to use #name#")
				}
			}

			if(prop.keyExists("default") and !arguments.keyExists(prop.name)){
				this["set#prop.name#"](prop.default);
			} else if (arguments.keyExists(prop.name)){
				this["set#prop.name#"](arguments[prop.name]);
			}
		}
		return this;
	}

	/**
	 * The addRemoteMethod function will take a DatasourceRemoteMethod and add it to the
	 * list of remote methods for this datasource.
	 *
	 * @DatasourceRemoteMethod
	 */
	public function addRemoteMethod(required DatasourceRemoteMethod RemoteMethod){

		if(!this.findRemoteMethodByName(RemoteMethod.getName()).exists()){
			variables.RemoteMethods.append(arguments.RemoteMethod);
		}

	}

	/**
	 * The execute function will take a SqlScript, run it against the datasource
	 * and return a query object.
	 *
	 * @SqlScript
	 */
	public query function execute(SqlScript){
		throw("You must implement execute method in your datasource component")
	}

	/**
	 * Returns an instance of the DatasourceRemoteMethod if it exists
	 *
	 * @name The string name of the remote method we wish to find
	 */
	public optional function findRemoteMethodByName(required string name){
		for(var remoteMethod in variables.RemoteMethods){
			if(remoteMethod.getName() == arguments.name){
				return new optional(remoteMethod);
			}
		}
		return new optional(nullValue());
	}

	/**
	 * Should throw an error if the datasource is not configured correctly
	 */
	public query function verify(){
		throw("You must implement verify method in your datasource component")
	}

	function getAllProperties(){
		var meta = getMetaData(this);
		var allProperties = meta.properties;
		var foundProps = {};
		for(var prop in allProperties){
			foundProps[prop.name] = true;
		}

		var recurseMeta = function(meta, properties){
			if(structKeyExists(meta,"extends")){
				try {
				var parent.meta = getComponentMetaData(meta.extends.fullName);

				}catch(any e){
					writeDump(meta);
					abort;
				}

				// if(structKeyExists(parent.meta,"persistent") AND parent.meta.persistent IS true){

				var out = [];
				for(var Prop in parent.meta.properties){
					if(!foundProps.keyExists(prop.name)){
						var working = {};
						for(var key in Prop){
							working[key] = Prop[key];
						}
						working.isExtended = true;
						working.extendedFrom = meta.extends.fullName;
						out.append(working);
					}
				}

				allProperties = allProperties.merge(out);

				allProperties = recurseMeta(parent.meta, allProperties);
				// }
			}
			return allProperties;
		}

		var allProperties = recurseMeta(meta, allProperties);
		return allProperties;
	}

	public function getRemoteMethods(){

		var meta = getMetaData(this);
		var funcsOut = [];
		var out = [];

		var recurseFuncs = function(meta, funcsOut){
			var meta = arguments.meta;
			var funcsOut = arguments.funcsOut;
			if(meta.fullname != "lucee.Component"){
				for(var func in meta.functions?:[]){
					funcsOut.append(func);
				}
			}

			if(meta.keyExists("extends")){
				recurseFuncs(meta.extends, funcsOut);
			}
		}
		recurseFuncs(meta, funcsOut);

		for(var func in funcsOut){
			if(func.access == "remote"){
				new DatasourceRemoteMethod(
					Datasource = this,
					name = func.name,
					description = func.description?:nullValue(),
					arguments = func.arguments?:nullValue(),
					returnType = func.returnType?:nullValue()
				);
			}
		}
		return variables.RemoteMethods;
	}

	public function getStudioConfigTemplate(){
		var allProperties = getAllProperties();
		var out = [];
		for(var prop in allProperties){

			out.append({
				name = prop.name,
				required = (prop.required?:false)?true:false,
				default = prop.default?:nullValue(),
				description: prop.description?:nullValue(),
				placeholder: prop.placeholder?:nullValue(),
				order: prop.order?:0
			})
		}

		arraySort(out, function(a,b){
			return a.order - b.order;
		});

		return out;
	}

	public function getDatasourceInfo(){
		var DatasourceInfo = new DatasourceInfo(
			Datasource = this
		)

		var TableInfos = this.getTableInfos();
		for(var TableInfo in TableInfos){
			TableInfo.setDatasourceInfo(this);
			DatasourceInfo.addTable(TableInfo);

			var FieldInfos = this.getFieldInfos(
				tableName = TableInfo.getName()
			);

			for(var FieldInfo in FieldInfos){
				FieldInfo.setTableInfo(TableInfo);
				TableInfo.addField(FieldInfo);
			}
		}

		return DatasourceInfo;
	}

	/**
	 * Empty method to list Datasource Processes. By default this will return an empty array
	 * but each datasource can override this method to return an array of DatasourceProcess
	 */
	public DatasourceProcess[] function getProcesses(){
		return [];
	}

	/**
	 * Takes a struct of data and inserts it into the specified table.
	 *
	 * @table The name of the table to insert the data into
	 * @data A struct of data to insert into the table
	 */
	public function insertRow(required string table, required struct data){

		var columns = [];
		var params = [];
		var paramValues = [];

		for(var key in data){
			columns.append(key);
			params.append("?");
			paramValues.append(data[key]);
		}

		var sql = "
			INSERT INTO #table# (#arrayToList(columns, ",")#)
			VALUES (#arrayToList(params, ",")#)
		";

		query name="result" datasource="#this.getConnectionInfo()#" params="#paramValues#" result="insert" {
			echo(sql);
		}
		return insert;
	}

	/**
	 * Empty method to kill a Datasource Process. By default this will do nothing
	 * but each datasource can override this method to kill a DatasourceProcess if
	 * that type of database supports it
	 */
	public function killProcess(required DatasourceProcess DatasourceProcess){
	}

	public function getTableInfos(){
		throw("You must implement getTableInfos method in your datasource component")
	}

}