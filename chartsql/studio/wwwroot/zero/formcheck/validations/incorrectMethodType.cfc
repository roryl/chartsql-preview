/**
*/
component implements="validation,formElement" {

	public function init(formElement){

		new missingFormMethod(formElement);
		var method = formElement.attr('method');
		if(lcase(method) == "get" or lcase(method) == "post"){

		} else {
			throw("The form method attribute was incorrect. Must be method='GET' or method='POST'", "incorrectMethodType");

		}
		return this;
	}
}