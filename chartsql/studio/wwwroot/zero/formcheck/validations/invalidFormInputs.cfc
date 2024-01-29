/**
*/
component implements="validation,formElement" {
	public function init(formElement){
		var inputs = formElement.select("input,button,textarea");

		for(var input in inputs){
			new invalidSubmitOverloadJson(input);
		}

		return this;
	}
}