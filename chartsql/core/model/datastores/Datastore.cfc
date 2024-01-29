/**
 * Base Datastore
*/
component {

	public function init(){
		var metaData = getMetaData(this);
		// writeDump(metaData);
		// writeDump(getAllProperties());

		var name = listLast(metaData.name,".");
		var allProperties = getAllProperties();
		for(var prop in allProperties){

			if(prop.keyExists("required") and prop.required){
				if(!arguments.keyExists(prop.name)){
					throw("Required property '#prop.name#' is required in order to use #name#")
				}
			}

			if(prop.keyExists("default") and !arguments.keyExists(prop.name)){
				this["set#prop.name#"](prop.default);
			} else if (arguments.keyExists(prop.name)){
				this["set#prop.name#"](arguments[prop.name]);
			}
		}
		return this;
	}

	function getAllProperties(){
		var meta = getMetaData(this);
		var allProperties = meta.properties;
		var foundProps = {};
		for(var prop in allProperties){
			foundProps[prop.name] = true;
		}

		var recurseMeta = function(meta, properties){
			if(structKeyExists(meta,"extends")){
				try {
				var parent.meta = getComponentMetaData(meta.extends.fullName);

				}catch(any e){
					writeDump(meta);
					abort;
				}

				// if(structKeyExists(parent.meta,"persistent") AND parent.meta.persistent IS true){

				var out = [];
				for(var Prop in parent.meta.properties){
					if(!foundProps.keyExists(prop.name)){
						var working = {};
						for(var key in Prop){
							working[key] = Prop[key];
						}
						working.isExtended = true;
						working.extendedFrom = meta.extends.fullName;
						out.append(working);
					}
				}

				allProperties = allProperties.merge(out);

				allProperties = recurseMeta(parent.meta, allProperties);
				// }
			}
			return allProperties;
		}

		var allProperties = recurseMeta(meta, allProperties);
		return allProperties;
	}

}