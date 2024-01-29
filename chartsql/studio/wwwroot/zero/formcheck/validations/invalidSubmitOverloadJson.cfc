/**
*/
component implements="validation,inputElement" {
	public function init(inputElement){
		var name = inputElement.attr('name');
		if(lcase(name) == "submit_overload"){
			var value = inputElement.attr('value');

			if(!isJson(value)){
				throw("The value for a submit_overload must be valid json", "invalidSubmitOverloadJson");
			}
		}
		return this;
	}
}