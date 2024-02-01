/**
* Represents a cleaned directive name stripped of any special characters.
*/
component {
	public function init(required string directive){
		variables.value = directive.replace("@", "", "one").replace(":", "", "one").replace("//", "", "one").trim();
		return this;
	}

	public function toString(){
		return variables.value
	}
}