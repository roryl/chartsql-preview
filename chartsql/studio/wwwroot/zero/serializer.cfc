/**
*
* @file  /C/websites/portal.itr8group.com/auth/controllers/serializer.cfc
* @author
* @description test
*
*/

component output="false" displayname=""  {

	public function init(doCamelToUnderscore=true){
		// writeDump(callStackGet());
		// abort;
		variables.doCamelToUnderscore = arguments.doCamelToUnderscore;
		variables.mode.includesAll = true;
	}

	/**
	* Takes a fprm structure and deserializes it back to keys for an entity (removes underscores)
	*/
	public function deserializeFormForEntity(required struct keys){

		var keys = arguments.keys;
		keysOut = {};
		for(var key IN keys){
			if(key IS "fieldnames"){
				continue;
			}
			var newKey = replace(key,"_","","all");
			keysOut[newKey] = trim(keys[key]);
		}
		return keysOut;
	}

	public boolean function isStruct(value){
		return isStruct(arguments.value)
	}

	public boolean function isSimpleValue(value){
		return isSimpleValue(arguments.value)
	}

	public boolean function isArray(value){
		return isArray(arguments.value)
	}

	public boolean function structKeyExists(struct, value){
		return structKeyExists(arguments.struct, arguments.value);
	}

	// public boolean function isNull(value){
	// 	return isNull(arguments.value)
	// }

	private boolean function excludesKey(key) {

		if(variables.mode.includesAll == false){
			if(variables.inclusions.keyExists(arguments.key)){
				return false; //Return false because we are flipping the bit of excludesKey (doesn't exclude because its included!)
			} else {
				return true;
			}
		} else {
			if(variables.exclusions.keyExists(arguments.key)){
				return true;
			} else {
				return false;
			}
		}
	}

	public function serializeEntity(required entity, includes={}){

		var entity = arguments.entity;
		var includes = arguments.includes;

		if(isSimpleValue(includes)){
			var includesArray = listToArray(includes);
			var includes = {};
			var include = "";
			for(include IN includesArray){
				includes[include] = {};
			}
			// writeDump(includes);
		} else {
			var includes = arguments.includes;
		}

		//Build exclusion keys. This allows a particular invocation
		//of the serializer to exclude certain keys which may need to be
		//ignored for performance or security reasons.
		variables.exclusions = {};
		if(includes.keyExists("@exclude")){
			var exclusionFields = includes["@exclude"];
			var exclusion = "";
			for(exclusion in exclusionFields){
				if(exclusionFields.keyExists(exclusion)){
					variables.exclusions[exclusion] = true;
				}
			}
		}

		/*
		Build inclusion keys. When @include is present, it switches
		the serialize from an includeAll by default, to a excludeAll
		by default, except those items specifically included
		 */
		variables.inclusions = {};
		if(includes.keyExists("@include")){
			variables.mode.includesAll = false;
			var inclusionFields = arguments.includes["@include"];

			for(var include in inclusionFields){
				if(!isStruct(inclusionFields[include])){
					throw("the key #include# must be a structure");
				}

				variables.inclusions[include] = true;
				includes[include] = inclusionFields[include];

			}
		}

		/*
		Allows for serializing idential recursive objects. This is handy
		when an object can recursively have children or parents
		 */
		if(includes.keyExists("@recurse")){
			for(var key in includes["@recurse"]){
				variables.inclusions[key] = true;
				includes[key] = {
					"@recurse":includes["@recurse"]
				}
			}
		}

		if(isSimpleValue(arguments.entity)){
			return arguments.entity;
		}

		if(isNull(arguments.entity)){
			return this.convertNullToEmptyString(arguments.entity);
		}

		if(isArray(arguments.entity)){

			if(isStruct(arguments.entity)){
				local.out = {};
				//writeDump(entity);abort;
				if(!structIsEmpty(entity)){
					for(key IN entity){

						if(this.excludesKey(key)){
							continue;
						}

						//writeDump(entity[key]);abort;
						if(isNull(entity[key])){
							out[this.camelToUnderscore(key)] = this.convertNullToEmptyString(entity[key]);
						}
						else {

							out[this.camelToUnderscore(key)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(entity[key], includes[key]?:{});
						}

					};
				}
			} else {
				local.out = [];
				for(ent IN entity){
					if(isNull(ent)){
						// out.append(this.convertNullToEmptyString(ent?:nullValue()));
					} else {
						// writeDump(includes);
						out.append(this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(ent, includes));
					}
				};
			}

		}
		else if(isStruct(arguments.entity) AND NOT isObject(arguments.entity)){
			local.out = {};
			// writeDump(entity);
			if(!structIsEmpty(entity)){
				for(key IN entity){
					if(this.excludesKey(key)){
						continue;
					}

					if(isNull(entity[key])){
						out[this.camelToUnderscore(key)] = this.convertNullToEmptyString(entity[key]?:nullValue());
						// out[this.camelToUnderscore(key)] = "";
					} else {
						out[this.camelToUnderscore(key)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(entity[key], includes[key]?:{});
					}
				};
			}
		}
		else if(isClosure(arguments.entity)){
			//Do nothing with closures right now
			return;
		}
		else{

			if(this.valueIsInstanceOf(arguments.entity, "valueObject")){
				if(structIsEmpty(includes)){
					try{
						return arguments.entity.toString();
					}catch(any e){
						throw(e);
						// writeDump(arguments.entity);
						// abort;
					}
				}
			}

			if(this.valueIsInstanceOf(arguments.entity, "Optional")){
				if(arguments.entity.exists()){
					local.entity = arguments.entity.get();
				} else {
					throw "The entity via an Optional object did not exist so we cannot use it";
				}
			} else {
				local.entity = arguments.entity;
				// writeDump(local.entity);
			}


			local.props = this.getAllProperties(local.entity);
			local.out = {};


			for(var prop in local.props){
			// local.props.each(function(prop){
				// var prop = arguments.prop;


				if(this.excludesKey(local.prop.name)){
					continue; //Moveon to the next property
					// return; //Moveon to the next property
				}
				// var this.camelToUnderscore(local.prop.name) = this.camelToUnderscore(local.prop.name);


				if(structKeyExists(prop,"cfc")){



					if(includes.keyExists(local.prop.name))
					{

						try{

							local.getRelation = entity['get#prop.name#']();


							/*Check for nulls on the relation. If it is null, then we need to determine if the
							data type of the relation would normally be a struct or an array

							one-to-one & many-to-one are always structs
							many-to-many & one-to-many can be an array (default) or a struct if defined in the mapping
							*/
							if(isNull(local.getRelation) OR (this.valueIsInstanceOf(local.getRelation,"Optional") AND !local.getRelation.Exists()))
							{

								if(prop.keyExists("fieldType")){
									if(prop.fieldType IS "one-to-one" OR prop.fieldType IS "many-to-one")
									{
										out[this.camelToUnderscore(local.prop.name)] = nullValue();
									} else if(prop.fieldType IS "many-to-many" OR prop.fieldType IS "one-to-many"){

										if(structKeyExists(prop,"type") AND prop.type IS "struct")
										{
											out[this.camelToUnderscore(local.prop.name)] = {};
										}
										else
										{
											out[this.camelToUnderscore(local.prop.name)] = [];
										}

									}
								} else {
									out[this.camelToUnderscore(local.prop.name)] = {};
								}


							}
							else
							{
								if(this.valueIsInstanceOf(local.getRelation,"Optional")){
									local.getRelation = local.getRelation.get();
								}
								// writeDump(local.prop.name);
								if(includes.keyExists(local.prop.name)){
									// writeDump(includes[prop.name]);
									out[this.camelToUnderscore(local.prop.name)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getRelation, includes[prop.name]);
								} else {

									out[this.camelToUnderscore(local.prop.name)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getRelation, {});
								}

								// writeDump(includes);
								// abort;
							}


						}catch (any e){
							// writeDump(entity['get#prop.name#']());
							throw(e)
							// writeDump(e);
							// abort;
						}

					}

				} else {


					if(!structKeyExists(prop,"serializeJson") OR (structKeyExists(prop,"serializeJson") AND prop.serializeJson IS NOT false)){

						try {
							local.getValue = entity['get#prop.name#']();
						} catch(any e){
							writeDump(prop.name);
							writeDump(e.message);
							writeDump(entity);
							writeDump(e);
							abort;
							throw(e);
							// writeDump(local.prop.name);
							// writeDump(e);
						}


						if(isNull(local.getValue)){
							out[this.camelToUnderscore(local.prop.name)] = this.convertNullToEmptyString(entity['get#prop.name#']());
						} else if(isSimpleValue(local.getValue)){
							out[this.camelToUnderscore(local.prop.name)] = local.getValue;
						} else if(this.valueIsInstanceOf(local.getValue,"Optional")){
							if(local.getValue.exists()){
								// if(local.prop.name == "tripType"){
								// 	writeDump(local.getValue);
								// 	writeDump(now());
								// 	abort;
								// }
								if(includes.keyExists(local.prop.name)){
									var finalValue = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getValue.get(), includes[prop.name]);
								} else {
									var finalValue = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getValue.get());
								}
								out[this.camelToUnderscore(local.prop.name)] = this.convertNullToEmptyString(finalValue);
							} else {
								out[this.camelToUnderscore(local.prop.name)] = this.convertNullToEmptyString(Javacast("null",""));
							}

							// if(includes.keyExists(local.prop.name)){
							// 	out[this.camelToUnderscore(local.prop.name)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(out[this.camelToUnderscore(local.prop.name)], includes[prop.name]);
							// }

						} else if(this.valueIsInstanceOf(local.getValue,"valueObject")){
							if(structIsEmpty(includes) or ! includes.keyExists(prop.name)){
								out[this.camelToUnderscore(local.prop.name)] = local.getValue.toString();
							} else {
								out[this.camelToUnderscore(local.prop.name)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getValue, includes[prop.name]);
							}
						}
						else if(this.valueIsInstanceOf(local.getValue, "component")){
							if(includes.keyExists(local.prop.name)){
								out[this.camelToUnderscore(local.prop.name)] = this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(local.getValue, includes[prop.name]);
							}
						}
						else if(isArray(local.getValue)){

							if(includes.keyExists(local.prop.name)){
								out[this.camelToUnderscore(local.prop.name)] = [];
								for(var item in local.getValue){

									out[this.camelToUnderscore(local.prop.name)].append(this.getNewSerializer(variables.doCamelToUnderscore).serializeEntity(item, includes[prop.name]));
								}
							}

						}
						else {
							out[this.camelToUnderscore(local.prop.name)] = local.getValue;
						}

					}

				}
			}
			// });

		}

		return local.out;
	}
	/**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	public function camelToUnderscore(str) {
		// return arguments.str;
		if(!variables.doCamelToUnderscore){
			return arguments.str;
		}
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }

	    if(left(rtnStr, 1) == "_"){
	    	rtnStr = right(rtnStr, -1);
	    }

		return trim(rtnStr);
	}

	public function serializeEntities(){

	}

	public function convertNullToEmptyString(value){
		if(isNull(arguments.value)){
			return nullValue();
		} else {
			return arguments.value;
		}
	}

	public function getEvaluateValue(entity, string){
		var entity = arguments.entity;

		if(!request.keyExists("evaluateTimes")){
			request.evaluateTimes = [];
		}
		var start = getTickCount();
		var result = entity[arguments.string]();
		// var result = evaluate('entity.' & arguments.string & '()');
		var end = getTickCount();
		// var out = {
		// 	call: arguments.string,
		// 	start: start,
		// 	end: end,
		// 	ms: (end - start),
		// 	sec: (end - start) / 1000
		// }
		// writeLog(file="serializertimes", text=serializeJson(out));
		// if(out.ms > 1){
		// }
		// request.evaluateTimes.append(out);
		return result?:nullValue();
	}

	public function getNewSerializer(doCamelToUnderscore=true){
		return new serializer(arguments.doCamelToUnderscore);
	}

	public function getIsBuiltInType(required string type){

		cfmltypes = [
			"any",
			"array",
			"binary",
			"boolean",
			"date",
			"guid",
			"numeric",
			"query",
			"string",
			"struct",
			"uuid",
			"variableName",
			"void",
		];

		var find = cfmlTypes.findNoCase(arguments.type);
		if(find > 0){
			return true;
		} else {
			return false;
		}
	}

	/*
	Override the isInstanceOf object to check first for simple values. This
	is because using isInstanceOf to check for simple values is a lot slower
	than checking if it is a simple value first (and therefore ensureing
	that only objects are checked with isInstanceOf)
	 */
	public function valueIsInstanceOf(obj, type){
		// return isInstanceOf(obj, type);
		if(isSimpleValue(obj)){
			return false;
		} else {
			var out = isInstanceOf(obj, type);
			return out;
		}
	}

	public array function getAllProperties(required component entity){

		var meta = getMetaData(arguments.entity);
		// writeDump(meta);
		// abort;
		// return meta.properties;
		// writeLog(file="serializer", text=meta.name);
		// abort;
		var cacheName = hash(meta.path);
		param name="application._zero.serializerMetaDataCache" default="#{}#";
		if(application._zero.serializerMetaDataCache.keyExists(cacheName)){
			return application._zero.serializerMetaDataCache[cacheName];
		} else {
			writeLog(file="serializer", text="Start properties for #meta.name#");
			// writeDump(meta);
			// abort;
			// var allProperties = meta.properties;
			var loops = 0;
			var propStack = [];
			var recurseGetProperties = function(doMeta){
				var localMeta = arguments.doMeta;
				// writeDump(localMeta.name);
				// writeDump(localMeta.properties);
				loops++
				// if(loops == 4){
				// 	writeDump(propStack);
				// 	// writeDump(doMeta);
				// 	abort;
				// }

				var props = duplicate(localMeta.properties);
				for(var prop in props){
					propStack.append(prop);
				}

				if(doMeta.keyExists("extends") and meta.extends.name != "lucee.Component"){
					// writeDump(meta.extends.properties);
					// abort;
					recurseGetProperties(localMeta.extends);
				}
				return propStack;
			}
			// writeDump(meta);
			// abort;
			var allProperties = recurseGetProperties(meta);
			// writeDump(allProperties);
			// abort;

			// if(structKeyExists(meta,"extends")){
			// 	if(meta.extends.name != "lucee.Component"){
			// 		try {

			// 			if(meta.persistent == true){
			// 				//Try the entity both by its fully qualified name
			// 				//and its root name. This is because the extension
			// 				//can used both paths and this may impact where the
			// 				//entity can be loaded from
			// 				try {
			// 					var entity = createObject(meta.extends.fullName);
			// 				}catch(any e){

			// 					if(e.message contains "can't find component"){
			// 						var entityName = listLast(meta.extends.fullName, ".");
			// 						try {
			// 							var entity = createObject(entityName);
			// 						} catch(any e){
			// 							if(e.message contains "can't find component"){
			// 								var entity = entityNew(entityName);
			// 							} else {
			// 								writeDump(meta.extends);
			// 								writeDump(e);
			// 								abort;
			// 							}
			// 						}
			// 					} else {
			// 						// writeDump(entity);
			// 						// writeDump(entityNew("users"));
			// 						writeDump(meta.extends.fullName);
			// 						writeDump(entityName);
			// 						writeDump(e);
			// 						abort;
			// 					}
			// 				}
			// 				var parent.meta = getMetaData(entity);
			// 			} else {

			// 				var parent.meta = getComponentMetaData(meta.extends.fullName);
			// 			}
			// 		} catch(any e){
			// 			throw(e);
			// 			// writeDump(e);
			// 			// writeDump(meta.extends.fullName);
			// 			// writeDump(meta);
			// 			// abort;
			// 		}

			// 		writeDump(parent.meta);
			// 		// abort;
			// 		if(structKeyExists(parent.meta,"persistent") AND parent.meta.persistent IS true){
			// 			allProperties = allProperties.merge(parent.meta.properties);
			// 		}
			// 	} else {

			// 	}
			// }
			application._zero.serializerMetaDataCache[cacheName] = allProperties;
			return allProperties;
		}
	}

}