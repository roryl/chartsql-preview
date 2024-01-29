/**
*/
component implements="data"{
	public function init(required array data){
		variables.data = arguments.data;
		return this;
	}


	public numeric function count(){
		return arrayLen(variables.data);
	}

	public array function list(required string max, required string offset){
		var max = ((arguments.max > arrayLen(variables.data))? arrayLen(variables.data): arguments.max);

		if(arrayLen(variables.data) == 0){
			return [];
		} else {
			if(local.max > arrayLen(variables.data)){
				local.max = arrayLen(variables.data);
			}
		}

		var out = variables.data.slice(1,local.max);
		var final = [];
		var doFilter = variables.keyExists("whereMatchIds")
		for(var item in out){
			if(doFilter){
				for(var filterId in variables.whereMatchIds){
					if(item.id == filterId){
						final.append(item);
					}
				}
			} else {
				final.append(item);
			}
		}
		if(variables.keyExists("orMatchIds")){
			for(var item in out){
				for(var orId in variables.orMatchIds){
					if(item.id == orId){
						var found = false;
						for(var finalItem in final){
							if(finalItem.id == orId){
								found = true;
								break;
							}
						}
						if(!found){
							final.append(item);
						}
					}
				}
			}
		}
		return final;
	}

	public void function search(required string searchString){
		// throw("not implemented");
	}

	public function sort(required string column, required string direction){
		return variables.data;
	}

	public void function filter(required string column, required any value){

	}

	public void function whereIdsMatch(array ids){
		variables.whereMatchIds = arguments.ids;
	}

	public void function orSearchIdsMatch(array ids){
		variables.orMatchIds = arguments.ids;
	}

}