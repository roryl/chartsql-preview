/**
*/
component implements="validation,formElement,cfc,cfcMethod"  {
	public function init(required formElement, required component cfc, required string cfcMethod){

		var metaData = getMetaData(cfc);
		var cfcMethod = arguments.cfcMethod;



		var functions = getAllExtendedFunctions(metaData);

		var foundFunc = functions.find(function(_func){
			if(_func.name == cfcMethod){
				// return _func;
				return true;
			} else {
				return false;
			}
		});

		if(foundFunc == 0){
			throw("Could not find the method #cfcMethod# in controller #metaData.fullName#", "missingControllerMethod");
		}
		return this;
	}

	private function getAllExtendedFunctions(required struct metaData){
		var getFunctions = function(metaData){
			return arguments.metaData.functions?:[];
		}

		var recurseGetFunctions = function(metaData){

			var functions = [];
			if(metaData.keyExists("extends")){
				var functions = functions.merge(recurseGetFunctions(arguments.metaData.extends));
			}
			functions = functions.merge(getFunctions(arguments.metaData));
			return functions;
		}
		return recurseGetFunctions(arguments.metaData);
	}
}