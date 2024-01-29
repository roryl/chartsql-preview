/**
* Implements the data interface for the provided MySQLTable zerotable implementation
*/
component implements="zero.plugins.zerotable.model.data"{
	public function init(required MySQLTable MySQLTable){
		variables.MySQLTable = arguments.MySQLTable;
		variables.sorts = [];
		variables.filters = [];
		return this;
	}

	public numeric function count(){

		var sql = buildQuery(count=true);
		var total = variables.MySQLTable.executeSQL(sql, variables.params).total;
		return total;
	}

	public array function list(required string max, required string offset){

		var sql = buildQuery(count=false, max=arguments.max, offset=arguments.offset);
		// writeDump(sql);
		// writeDump(params);
		variables.data = variables.MySQLTable.executeSQL(sql, variables.params);

		if(variables.data.recordCount == 0){
			return [];
		} else {
			var out = [];
			for(var row in variables.data){
				out.append(row);
			}
		}

		return out;
	}

	public function buildQuery(count=false, required numeric max=10, required numeric offset=0){

		var sql = "";
		var columns = variables.MySQLTable.getZeroTable().getColumns();
		variables.params = {};

		if(arguments.count){
			sql &= "SELECT count(*) as total ";
		} else {
			sql &= "SELECT ";

			var columnNames = arrayMap(columns, function(column){
				return Column.getDataName();
			});
			sql &= "#arrayToList(columnNames)# ";
		}

		sql &= "FROM #variables.MySQLTable.getTableName()# ";
		sql &= "WHERE 1 = 1 ";

		if(!isNull(variables.searchString)){

			sql &= "AND ( "
			sql &= columns.map(function(column){
				return "#column.getDataName()# like #param('search#column.getDataName()#', '%#variables.searchString#%')# "
			}).toList(" or ");
			sql &= ") ";
		}

		for(var filter in variables.filters){
			for(var column in columns){
				if(filter.column == column.getDataName()){

					SQL &= "AND (#filter.column# = #param('filter#filter.column#','#filter.value#')# ";
					SQL &= "OR CAST(#filter.column# as CHAR) LIKE #param('filter2#filter.column#','%#filter.value#%')#) ";
				}
			}
		}

		if(!arguments.count){
			if(variables.sorts.len() GT 0){
				if(!arguments.count){
					sql &= "order by ";
					var i = 1;
					for(var sort in variables.sorts){
						// sql &= "#param(name:"sort_#i#", value:sort.column)# #param(name:"direction_#i#", value:sort.direction)#")
						if(i>1)
						sql &= ", ";
						sql &= "#sort.column# #sort.direction# ";
						i++
					}
				}
			}
			sql &= "LIMIT #int(arguments.offset)#, #arguments.max# ";
		}
		return sql;
	}

	public void function search(required string searchString){
		variables.searchString = arguments.searchString;
	}

	public function sort(required string column, required string direction){
		variables.sorts.append({column:arguments.column, direction:arguments.direction});
	};

	public void function filter(required string column, required any value){
		variables.filters.append({column:arguments.column, value:arguments.value})
	}

	public void function whereIdsMatch(array ids){

	}

	public void function orSearchIdsMatch(array ids){

	}

	private function param(required name, required value){
		variables.params.insert(arguments.name, arguments.value);
		return ":#arguments.name#"
	}
}