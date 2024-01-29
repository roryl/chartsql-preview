/**
*/
component {
	public function init(object, includes){
		var out = {};
		var timers = {};

		var doSerialize = function(object, struct includes={}, struct timers, trackTime=false){
			var object = arguments.object;
			var includes = arguments.includes;
			var timers = arguments.timers;
			var trackTime = arguments.trackTime;
			var out = "";

			if(includes.keyExists("@include")){
				var includes = includes["@include"];
			}

			/*
			Allows for serializing idential recursive objects. This is handy
			when an object can recursively have children or parents
			 */
			if(includes.keyExists("@recurse")){
				for(var key in includes["@recurse"]){
					includes[key] = {
						"@recurse":includes["@recurse"]
					}
					for(var subKey in includes["@recurse"][key]){
						includes[subkey] = includes["@recurse"][key][subkey];
					}
				}

				structDelete(includes, "@recurse");
			}

			if(isNull(object)){
				var out = "";
				return out;
			}

			if(isSimpleValue(object)){
				var out = object;
				return out;
			}

			if(isArray(object)){
				var out = [];
				for(var item in object){
					if(!isNull(item)){
						out.append(doSerialize(item, includes, timers, trackTime));
					}
				}
				return out;
			}

			if(isStruct(object) and !isObject(object)){
				var out = {};
				for(var key in includes){
					if(object.keyExists(key)){
						out[key] = doSerialize(object[key], includes[key], timers, trackTime);
					}
				}
				// writeDump(out);
				return out;
			}

			if(isInstanceOf(object, "valueObject")){
				if(structIsEmpty(includes)){
					out = object.toString();
					return out;
				} else {
					//Do the isInstanceOf(Object below)
					// var out = doSerialize(object, includes[key], timers, trackTime);
				}
			}

			if(isInstanceOf(object, "optional")){
				if(object.exists()){
					var out = doSerialize(object.get(), includes, timers, trackTime);
				} else {
					out = "";
				}
				return out;
			}

			if(isInstanceOf(object, "component")){
				var out = {}
				var localIncludes = duplicate(includes);
				if(localIncludes.keyExists("@isInstanceOf")){
					for(var type in localIncludes["@isInstanceOf"]){
						if(isInstanceOf(object, type)){
							for(var key in localIncludes["@isInstanceOf"][type]){

								localIncludes[key] = localIncludes["@isInstanceOf"][type];
							}
						}
					}
					structDelete(localIncludes, "@isInstanceOf");
				}

				for(var key in localIncludes){

					if(isClosure(localIncludes[key])){
						var tryObject = localIncludes[key](object);
						out[key] = tryObject;
					} else {

						if(trackTime){
							var start = getTickCount();
							try {
								var tryObject = object["get#key#"]();
							}catch(any e){
							writeDump(e);
							writeDump(localIncludes);
							writeDump(callStackGet());
							abort;
							}
							var end = getTickCount();
							timers[key] = end - start;
						} else {
							var tryObject = object["get#key#"]();
						}
						if(isNull(tryObject)){
							out["#key#"] = "";
						} else {
							out["#key#"] = doSerialize(tryObject, localIncludes[key], timers, trackTime);
						}
					}

				}
				return out;
			}
		}
		// abort;
		var out = doSerialize(arguments.object, arguments.includes, timers, true);
		// writeDump(timers);
		return out;
	}


}