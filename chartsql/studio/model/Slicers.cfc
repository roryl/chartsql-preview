/**

*/
component {
	public function init(
		DatetimeSlicer Datetime
	){

		if(arguments.keyExists("Datetime")){
			variables.Datetime = arguments.Datetime;
		}

		return this;
	}

	public function slice(
		required query data,
		required struct directives
	){

		// writeDump(data);
		var out = arguments.data;
		var directives = arguments.directives;

		if(variables.keyExists("Datetime")){

			if(directives.keyExists("category")){
				var categoryField = directives.category;
			} else if(directives.keyExists("groups")){
				var categoryField = directives.groups[1];
			}

			if(isDefined('categoryField')){
				var meta = new core.util.QueryUtil(data).getMetaData();
				// writeDump(meta.columns[categoryField]);
				// abort;
				if(
					meta.columns[categoryField].finalType == "date" or meta.columns[categoryField].finalType == "datetime"
				){
					var params = {
						start: {type:"date", value:variables.Datetime.getStart()},
						end: {type:"date", value:variables.Datetime.getEnd()}
					};

					query name="out" dbtype="query" params="#params#" {
						echo("
							SELECT *
							FROM out
							WHERE #categoryField# >= :start AND #categoryField# <= :end
						")
					}
				}
			}

		}

		return out;
	}

}