component {

	public function init(data){

		variables.data = arguments.data;

		var allCookies = expandFlattenedData(duplicate(arguments.data));
		if(structKeyExists(allCookies,"client")){
			var clientCookies = allCookies.client;
			variables.originalClient = duplicate(clientCookies);
			variables.values = duplicate(clientCookies);
		} else {
			variables.originalClient = {};
			variables.values = {};
		}

		return this;
	}

	public function clear(){
		structClear(variables.values);
	}

	public function getCompressedValues(required struct values){
		var values = arguments.values;
		var out = {};
		var compressedKeys = new compressedKeys();
		for(var key in values){
			var newKey = compressedKeys.compress(key);
			out[newKey] = values[key];
		}
		return out;
	}

	public function getValues(){
		return variables.values;
	}

	public function getOriginalValues(){
		return variables.originalClient;
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

		var originalKeys = getOriginalValuesFlattened();
		var currentKeys = getValuesFlattened();
		var out = {};

		for(var currentKey in currentKeys){
			if(!structKeyExists(originalKeys, currentKey)){
				out.insert(currentKey, currentKeys[currentKey]);
			}
		}
		return out;
	}

	public function getRemovedValues(){
		var originalKeys = getOriginalValuesFlattened();
		var currentKeys = getValuesFlattened();
		var out = {};

		for(var originalKey in originalKeys){
			if(!structKeyExists(currentKeys, originalKey)){
				out.insert(originalKey, originalKeys[originalKey]);
			}
		}
		return out;
	}

	public function getOriginalValuesFlattened(){

		if(variables.keyExists("originalFlattened")){
			return variables.originalFlattened;
		} else {
			variables.originalFlattened = flattenDataStructureForCookies(data=duplicate(variables.originalClient), prefix="client", ignore=[]);
			return variables.originalFlattened;
		}
	}

	public function getValuesFlattened(){

		if(variables.keyExists("valuesFlattened")){
			return variables.valuesFlattened;
		} else {
			variables.valuesFlattened = flattenDataStructureForCookies(data=duplicate(variables.values), prefix="client", ignore=[]);
			return variables.valuesFlattened;
		}
	}

	public function getChangedValues(){

		var originalKeys = getOriginalValuesFlattened();
		var currentKeys = getValuesFlattened();
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

	public function persist(){

		if(!request.keyExists("zeroClientPersisted")){

			var removedValues = getRemovedValues();
			for(var key in removedValues){
				structDelete(variables.data, key);
				// header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
			}

			var newValues = getNewValues();
			for(var key in newValues){
				variables.data[key] = newValues[key];
			}


			var changedValues = getChangedValues();

			for(var key in changedValues){
				variables.data[key] = changedValues[key];
			}
			request.zeroClientPersisted = true;
		}
	}

	public function expandFlattenedData(data){
    	var out = duplicate(arguments.data);

    	// abort;
    	structKeyTranslate(out, true, false);

    	var recurseStructs = function(str){
    		var str = arguments.str;
    		// writeDump(str);
    		if(isArray(str)){
    			for(var item in str){
    				recurseStructs(item);
    			}
			} else if(isStruct(str)){
				for(var key in str){
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

	public function flattenDataStructureForCookies(required any data, prefix="", ignore=[]){
    	var prefix = arguments.prefix;
		var pile = {};
		var ignore = arguments.ignore;

    	var recurseData = function(data, currentPath="", pile){
    		if(isArray(arguments.data)){
    			var index = -1;

    			for(var item in arguments.data){
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

			} else if(isStruct(arguments.data)) {

				if(structIsEmpty(arguments.data)){
					pile.insert(currentPath, "{}");
				} else {
					loopStruct: for(var key in arguments.data){
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

						if(isStruct(arguments.data[key]) or isArray(arguments.data[key])){
							recurseData(data = arguments.data[key], currentPath=path, pile=pile)
						} else {

							/*Lucee will not return cookies with zero length strings. As such we need to encode an empty string*/
							if(len(trim(arguments.data[key])) == 0 or arguments.data[key] == ""){
								arguments.data[key] = '""';
							}

							pile.insert(path, arguments.data[key], true);
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
	    		if(isBoolean(str[key])){
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