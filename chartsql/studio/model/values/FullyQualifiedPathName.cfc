/**
 * Returns a fully qualified path name that we can use to uniquely look
 * up the file
*/
component {
	public function init(required string name){
		variables.name = lcase(arguments.name);
		if(left(variables.name, 1) eq "/" || left(variables.name, 1) eq "\"){
            variables.Name = right(variables.name, -1);
        }
		
		variables.Name = replaceNoCase(variables.name, "/", ".", "all");
		variables.Name = replaceNoCase(variables.Name, "c:\", "", "all");
		variables.Name = replaceNoCase(variables.Name, "\", ".", "all");
		variables.Name = replaceNoCase(variables.Name, "\\", ".", "all");
		variables.Name = replaceNoCase(variables.Name, " ", "_", "all");
		return this;
	}

	public function toString(){
		return variables.Name;
	}
}