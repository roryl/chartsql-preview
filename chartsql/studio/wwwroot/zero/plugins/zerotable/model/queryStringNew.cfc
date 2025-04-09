/**
* A helper to build and interract with cgi.query_string
*/
component accessors="true" {

	property name="originalQueryString";
	property name="fields";
	property name="protocol";
	property name="basePath";
	property name="domain";

	/**
	 * Initiates a new Querystring. You must pass in the querystring, typically from
	 * cgi.query_string
	 *
	 * @queryString
	 */
	public function init(required string queryString=""){

		var workingString = arguments.queryString;
		if(left(workingString, 1) == "?"){
			workingString = right(workingString, len(workingString) - 1);
		}
		variables.queryString = workingString;
		variables.fields = [];
		variables.protocol = "";
		variables.domain = "";
		variables.basePath = "";

		var workingFields = listToArray(workingString, "&");
		for(var field in workingFields){
			var workingStruct = {};
			if(right(field,1) == "="){
				workingStruct.key = listFirst(field, "=");
				workingStruct.value = "";
			} else {
				workingStruct.key = listFirst(field, "=");
				workingStruct.value = listLast(field, "=");
			}
			variables.fields.append(workingStruct);
		}
		return this;
	}

	/**
	 * Deletes a key out of the query string
	 *
	 * @key The key to delete out of the query string
	 */
	public function delete(required string key){
		for(var i=1; i <= arrayLen(variables.fields); i++){
			var field = variables.fields[i];
			if(field.key == arguments.key){
				variables.fields.deleteAt(i);
				i--;
			}
		}
		return this;
	}

	/**
	 * Clones the QueryString object so that you can continue making changes while preserving the previous version. Being replaced by clone() method
	 */
	public function getNew(){
		return duplicate(this);
	}

	/**
	 * Clones the QueryString object so that you can continue making changes while preserving the previous version. Replaces getNew()
	 */
	public function clone(){
		return duplicate(this);
	}

	/**
	 * Gets the value of the key out of the QueryString
	 *
	 * @key
	 */
	public function getValue(required string key){
		var out = [];
		for(var field in variables.fields){
			if(field.key == arguments.key){
				out.append(field.value)
			}
		}
		return out.toList();
	}

	/**
	 * Sets or overwrites the key:value passed in. If ‘append’ is true, always appends the value even if it already exists in the query string
	 *
	 * @key
	 * @value
	 * @append
	 */
	public function setValue(required string key, required string value, append=false){
		var found = false;

		if(arguments.append){
			this.appendValue(arguments.key, arguments.value);
			return this;
		}

		for(var field in variables.fields){
			if(field.key == arguments.key){
				var found = true;
				field.value = arguments.value;
			}
		}
		if(!found){
			this.appendValue(arguments.key, arguments.value);
		}
		return this;
	}

	/**
	 * Takes a structure of key:value pairs and sets all of them into the QueryString
	 */
	public function setValues(required struct values){
		for(var key in arguments.values){
			this.setValue(key, arguments.values[key]);
		}
		return this;
	}

	public function appendValue(required string key, required string value){
		variables.fields.append({
			key:arguments.key,
			value:arguments.value
		})
		return this;
	}

	/**
	 * Returns a string of the compiled QueryString. Use this to get the final query string for output
	 */
	public string function get(){
		var out = [];

		for(var field in variables.fields){
			out.append("#field.key#=#field.value#")
		}
		return "#variables.protocol##variables.domain##variables.basePath#?#arrayToList(out,"&")#";
	}

	public string function getQs(){
		return "?#listLast(this.get(), "?")#";
	}

	public boolean function has(required string key){
		for(var field in variables.fields){
			if(field.key == arguments.key){
				return true;
			}
		}
		return false;
	}

	public boolean function matches(required QueryStringNew Qs){
		var myFields = this.getFields();
		var theirFields = arguments.Qs.getFields();
		// writeDump(myFields);
		// writeDump(theirFields);
		// abort;
		if(arrayLen(myFields) != arrayLen(theirFields)){
			return false;
		}
		for(var myField in myFields){
			var matches = true;
			for(var theirField in theirFields){
				if(myField.key == theirField.key and this.getValue(myField.key) != arguments.Qs.getValue(myField.key)){
					matches = false;
					break;
				}
			}
			if(!matches){
				return false;
			}
		}

		for(var theirField in theirFields){
			var matches = true;
			for(var myField in myFields){
				if(myField.key == theirField.key and this.getValue(myField.key) != arguments.Qs.getValue(myField.key)){
					matches = false;
					break;
				}
			}
			if(!matches){
				return false;
			}
		}

		return true;
	}
}