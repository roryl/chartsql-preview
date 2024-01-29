/**
*/
component implements="validation,formElement,cfc,cfcMethod,urlArguments" {
	public function init(required formElement, required component cfc, required string cfcMethod, struct urlArguments){

		var metaData = getMetaData(cfc);
		var cfcMethod = arguments.cfcMethod;
		new missingControllerMethod(formElement, cfc, cfcMethod);

		var functions = getAllExtendedFunctions(metaData);

		var foundFunc = functions.find(function(_func){
			if(_func.name == cfcMethod){
				// return _func;
				return true;
			} else {
				return false;
			}
		});

		funcs = functions[foundFunc];

		// var inputs = formElement.select("input[name='#param.name#'],select[name='#param.name#']");
		var inputs = formElement.select("input,select,textarea");

		allInputNames = {};
		for(var input in inputs){
			var inputName = input.attr('name');
			/*
			Inputs can be complex flattened structures (ie inputname.some.sub.value) and
			therefore we want to only look at the first part of the name exists as this
			will get serialized by zero.
			 */
			inputName = listFirst(inputName,".");
			allInputNames.insert(inputName, true, true);
			var camelInputName = replaceNoCase(inputName, "_", "", "all");
			var camelInputName = listFirst(camelInputName,".");
			allInputNames.insert(camelInputName, true, true);
		}
		// writeDump(allInputNames);

		var allRequiredParams = {};
		for(var param in funcs.parameters){

			if(param.required){
				allRequiredParams.insert(param.name, true, true);
			}
		}

		for(var param in funcs.parameters){

			if(param.required){

				if(arguments.urlArguments.keyExists(param.name)){
					continue;
				}

				if(allInputNames.keyExists(param.name)){
					for(var input in inputs){

						var inputName = input.attr('name');
						var camelInputName = replaceNoCase(inputName, "_", "", "all");
						if(allRequiredParams.keyExists(inputName) or allRequiredParams.keyExists(camelInputName)){
							if(!input.hasAttr('value')){
								if(input.nodeName() == 'select'){
									selectOptions = input.select('option');
									if(arrayLen(selectOptions) == 0){
										throw("Required input #inputName# for #metaData.fullName#:#cfcMethod#() did not have any option values", "requiredInputMissingValue");
									}
								} else if(input.nodeName() == 'textarea'){
									return this;
								} else {
									throw("Required input '#inputName#' for #metaData.fullName#:#cfcMethod#() was missing a value attribute", "	requiredInputMissingValue");
								}

							}
						}
					}

				} else {

					/*
					Some controller values can be injected by zero and
					these should not be present in the forms
					 */
					var zeroInjectedInputs = [
						"zeroFormState"
					]

					for(var item in zeroInjectedInputs){
						if(lcase(item) == lcase(param.name)){
							return this;
						}
					}

					throw("Form was missing a required input #param.name#", "missingRequiredInputs");
				}
			}
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