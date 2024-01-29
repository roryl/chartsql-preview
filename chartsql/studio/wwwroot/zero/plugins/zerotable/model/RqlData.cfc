/**
*/
component implements="data"{
	public function init(required component Provider, required struct Rql){
		variables.Provider = arguments.Provider;
		variables.Rql = arguments.Rql;
		return this;
	}

	public numeric function count(){
		return arrayLen(variables.Provider);
	}

	public array function list(required string max, required string offset){
		var out = [];

		timer type="debug" label="App" {
			// variables.Provider.load("App");
		}

		timer type="debug" label="RqlAsJson" {
			timer type="debug" label="" {
				var result = variables.Provider.rqlAsJson(variables.Rql);
			}
			timer type="debug" label="" {
				var out = evaluate(result);
			}
		}
		return out;
	}

	public void function search(required string searchString){
		// throw("not implemented");
	}

	public function sort(required string column, required string direction){
		return variables.Provider;
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