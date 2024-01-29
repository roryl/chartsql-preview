/**
*/
component implements="validation,htmlDoc,formElement" {

	public function init(htmlDoc, formElement){

		if(formElement.hasAttr('zero-target')){

			var target = formElement.attr('zero-target');
			var find = htmlDoc.select(target);
			if(arrayLen(find) == 0){
				throw("Could not find the expected element '#target#' for zero-target", "missingZeroTarget")
			}
		}
		return this;
	}
}