/**
 * Returns a fully qualified path name that we can use to uniquely look
 * up the file
*/
component {
	public function init(required string name){
		variables.name = lcase(arguments.name);

        // Replace spaces with underscores
        variables.name = reReplace(variables.name, " ", "_", "all");
        // Remove any non alphanumeric characters except underscores
        variables.name = reReplace(variables.name, "[^a-zA-Z0-9_]", "", "all");
		return this;
	}

	public function toString(){
		return variables.Name;
	}
}