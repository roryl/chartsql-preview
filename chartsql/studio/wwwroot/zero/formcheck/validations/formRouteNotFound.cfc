/**
*/
component implements="validation,formElement,routesFunc,routes" {
	public function init(required routesFunc, required formElement, required array routes){

		new missingFormMethod(formElement);

		var action = formElement.attr("action");
		var action = listFirst(action, "?");
		var method = ucase(formElement.attr("method"));

		result = routesFunc(action, routes, method);
		if(result.matched){

		} else {
			throw("Could not find the route for form action: #action#, method: #method#", "formRouteNotFound");
		}
		return this;
	}
}