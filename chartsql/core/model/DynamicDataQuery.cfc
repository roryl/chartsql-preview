/**

*/
component {

	static function evaluate(required query data){

		var data = arguments.data;
		var columns = data.columnArray();

		var previousResult;

		var increments = {
			row: 1,
			column: 1
		}

		for(increments.row = 1; increments.row <= data.recordCount; increments.row++){

			for(increments.column = 1; increments.column <= columns.len(); increments.column++){

				var column = columns[increments.column];
				var value = data[column][increments.row];

				if(isDDF(value)){

					var context = {
						rid = increments.row,
						cid = increments.column,
						field = column,
						data = data,
						prev = previousResult?:nullValue(),
						row = queryRowData(data, increments.row),
						func = value
					};

					var result = executeDDF(value, context);
					var previousResult = result?:nullValue();

					data[column][increments.row] = result?:nullValue();

					// do something with the value
				}

				// do something with the value

			}

			// do something with the record

		}
	}

	static function isDDF(required string value){
		var match = '=function(';

		if(left(removeSpaces(value), 10) == match){
			return true;
		} {
			return false;
		}
	}

	static function removeSpaces(required string value){
		return replace(value, ' ', '', "all");
	}

	static function executeDDF(required string value, required struct context){

		var fileUUID = "ddfScript" & replace(createUUID(),"-","","all");
		// var fileUUID = "ddfScript";

		var newValue = trim(value);
		var newValue = right(newValue, -1);
		var newValue = replace(newValue, "function(", "function theFunc(");

		savecontent variable="funcCall" {
			echo("
				component {
					#newValue#
				}
			")
		}

		// writeDump(funcCall);

		fileWrite("ddfscripts/#fileUUID#.cfc", funcCall);

		// include template="#fileUUID#";
		var com = createObject("component", "com.chartsql.core.model.ddfscripts.#fileUUID#");
		// include template="/com/chartsql/core/model/script.cfm";

		var result = com.theFunc(argumentCollection = context);

		fileDelete("ddfscripts/#fileUUID#.cfc");

		return result?:nullValue();

	}

}