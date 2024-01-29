/**
*/
component implements="data"{
	public function init(required query data){
		variables.data = arguments.data;
		return this;
	}

	public numeric function count(){
		return variables.data.recordCount;
	}

	public array function list(required string max, required string offset){
		var max = ((arguments.max > variables.data.recordCount)? variables.data.recordCount: arguments.max);

		if(variables.data.recordCount == 0){
			return [];
		} else {
			var out = [];
			for(var row in variables.data){
				out.append(row);
			}
		}

		return out.slice(1,local.max);
	}

	public void function search(required string searchString){
		// throw("not implemented");
	}

	public function sort(required string column, required string direction){
		return variables.data;
	}

	public void function filter(required string column, required string value){

	}
}