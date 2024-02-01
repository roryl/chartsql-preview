/**
 * Represents a full directive like @directive: or //@directive:
*/
component {
	public function init(required string directive){
		// Directive must look like @directive: or //@directive:
		var matches = reMatchNoCase("((\/{2})?@[A-Za-z-]+:)", arguments.directive);
		if (arrayLen(matches) != 1){
			throw("Invalid directive: " & arguments.directive);
		}
		variables.value = directive;
		return this;
	}

	public function toString(){
		return variables.value;
	}
}