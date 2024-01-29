component {

	public function init(required struct data){

		/*
		If the user passed in a lucee FORM scope, that seems to cause a java concurrent
		modification exception. We can get around this by copying each key into
		a unique struct
		 */
		var newStruct = {};
		for(var key in arguments.data){
			newStruct.insert(key, duplicate(arguments.data[key]));
		}
		var expandedData = expandFlattenedData(newStruct);
		variables.originalClient = duplicate(expandedData);
		variables.values = duplicate(expandedData);
		return this;
	}

	public function clear(){
		structClear(variables.values);
	}

	public function getValues(){
		return variables.values;
	}

	public void function delete(required string key){
		if(has(key)){
			variables.values.delete(key);
		}
	}

	public void function put(required string key, required any value){
		variables.values.insert(key, value, true);
	}

	public any function get(required string key){
		if(variables.values.keyExists(key)){
			return variables.values[key];
		} else {
			throw("No value found for #key#. Use getOrNull() to return an empty value, or check has() first");
		}
	}

	public boolean function has(required string key){
		return structKeyExists(variables.values, key);
	}

	public function getNewValues(){

		var originalKeys = flattenDataStructureForCookies(data=duplicate(variables.originalClient), prefix="client", ignore=[]);
		var currentKeys = flattenDataStructureForCookies(data=duplicate(variables.values), prefix="client", ignore=[]);
		var out = {};

		for(var currentKey in currentKeys){
			if(!structKeyExists(originalKeys, currentKey)){
				out.insert(currentKey, currentKeys[currentKey]);
			}
		}
		return out;
	}

	public function getRemovedValues(){
		var originalKeys = flattenDataStructureForCookies(data=duplicate(variables.originalClient), prefix="client", ignore=[]);
		var currentKeys = flattenDataStructureForCookies(data=duplicate(variables.values), prefix="client", ignore=[]);
		var out = {};

		for(var originalKey in originalKeys){
			if(!structKeyExists(currentKeys, originalKey)){
				out.insert(originalKey, originalKeys[originalKey]);
			}
		}
		return out;
	}

	public function getChangedValues(){
		var originalKeys = flattenDataStructureForCookies(data=duplicate(variables.originalClient), prefix="client", ignore=[]);
		var currentKeys = flattenDataStructureForCookies(data=duplicate(variables.values), prefix="client", ignore=[]);
		var out = {}

		for(var currentKey in currentKeys){
			if(structKeyExists(originalKeys, currentKey)){
				if(currentKeys[currentKey] != originalKeys[currentKey]){
					out.insert(currentKey, currentKeys[currentKey]);
				}
			}
		}
		return out;
	}

	public function expandFlattenedData(data){
    	var out = duplicate(arguments.data);

    	// abort;
    	structKeyTranslate(out, true, false);

    	var recurseStructs = function(str){
    		// writeDump(str);
    		if(isArray(str)){
    			for(var item in str){
    				recurseStructs(item);
    			}
			} else if(isStruct(str)){
				for(var key in str){
					if(isNull(str[key])){
						return;
					}
					if(isStruct(str[key])){
						if(structIsReallyArray(str[key])){
							str[key] = convertStructArrayToArray(str[key]);
						}
						recurseStructs(str[key]);
					} else if(isArray(str[key])){
						recurseStructs(str[key]);
					} else {
						if(lcase(str[key]) == "true" or lcase(str[key]) == "false"){
							//Need to do an extra check on if the value is numeric.
							//Lucee will equiviate 1,0 or "1","0" to true/false
							if(!isNumeric(str[key])){
			    				if(str[key]){str[key] = true;} else {str[key] = false}
							}
			    		} else if(str[key] == "{}"){
			    			str[key] = {};
			    		} else if(str[key] == "[]"){
			    			str[key] = [];
			    		} else if(str[key] == '""') {
			    			str[key] = "";
			    			// writeDump(str);
			    		} else {
			    			str[key] = str[key];
			    		}
					}
				}

	    	} else {
	    		// writeDump(str);
	    		if(isBoolean(str) and !isNumeric(str)){
	    			if(str){str = true;} else {str = false}
	    		}
				//Do nothing, it is a simple value
			}
			// writeDump(str);
    	}
    	recurseStructs(out);
    	return out;
    }

	public function flattenDataStructureForCookies(required any data=getValues(), prefix="", ignore=[]){
    	var prefix = arguments.prefix;
		var pile = {};

    	var recurseData = function(data, currentPath="", pile){
    		if(isArray(data)){

    			var index = -1;
    			for(var item in data){
    				index++;
					if(currentPath == ""){
						var path = currentPath & "#index#";
					} else {
						var path = currentPath & "." & "#index#";
					}

    				if(isStruct(item) or isArray(item)){
    					recurseData(data=item, currentPath=path, pile=pile);
    				} else {
    					pile.insert(path, item);
    				}
    			}

			} else if(isStruct(data)) {

				if(structIsEmpty(data)){
					pile.insert(currentPath, "{}");
				} else {
					loopStruct: for(var key in data){
						// writeDump(key);
						// writeDump(data);
						for(var ignoreItem in ignore){
							if(lcase(key) == lcase(ignoreItem)){
								continue loopStruct;
							}
						}

						if(currentPath == ""){
							var path = currentPath & key;
						} else {
							var path = currentPath & "." & key;
						}

						if(!isNull(data[key]) and (isStruct(data[key]) or isArray(data[key]))){
							recurseData(data = data[key], currentPath=path, pile=pile)
						} else {
							if(!isNull(data[key])){
								/*Lucee will not return cookies with zero length strings. As such we need to encode an empty string*/
								if(len(trim(data[key])) == 0 or data[key] == ""){
									data[key] = '""';
								}

								pile.insert(path, data[key], true);
							}
						}
					}
				}


			} else {
				throw("json data was not an array or struct, cannot convert");
			}

    		return pile;
    	}
    	recurseData(data=arguments.data, pile=pile);

    	if(prefix != ""){
    		for(var key in pile){
    			pile["#prefix#.#key#"] = pile[key];
    			pile.delete(key);
    		}
    	}

    	return pile;
    }

    public boolean function structIsReallyArray(required struct str){
    	var success = true;
    	for(var key in str){
    		if(!isNumeric(key)){
    			success = false;
    		}
    	}
    	return success;
    }

    public function convertStructArrayToArray(required struct str){
    	var out = [];
    	var keys = str.keyArray().sort("numeric");

    	try{
    	for(var key in keys){

    		if(isSimpleValue(str[key])){
	    		if(isBoolean(str[key]) and !isNumeric(str[key])){
	    			if(str[key]){out.append(true);} else {out.append(false)}
	    		} else if(str[key] == "[]"){
	    			out.append([]);
	    		} else if(str[key] == "{}"){
	    			out.append({});
	    		} else if(str[key] == '""') {
	    			out.append("");
	    		} else {
	    			out.append(str[key]);
	    		}
    		} else {
    			out.append(str[key]);
    		}
    	}
    	}catch(any e){
    		writeDump(str);
    		abort;
    	}
    	return out;
    }

}