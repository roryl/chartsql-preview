/**
*/
component implements="validation,formElement" {

	public function init(formElement){
		if(!formElement.hasAttr("method")){
			throw("The form did not have a method attribute. method='GET' or method='POST' is required", "missingFormMethod");
		}
		return this;
	}
}