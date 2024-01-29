<cfscript>
spec = {
	class:"queryString",
	mockObjects:[],
	factory:function(){
		return createObject("queryString");
	},
	tests:{
		init:{
			"Should create the internal structure for the query string":{
				given:{
					queryString:"action=test.name&other=test"
				},
				then:{
					returns:"isObject",
					assert:[
						{
							message:"The query string struct did not match the values passed in as a query string",
							value:function(result){
								local.queryString = result.getQueryStringStruct();
								if(isArray(local.queryString) AND local.queryString.len() IS 2)
								{
									return true;
								}
								else
								{
									return false;
								}
							}
						}
					]
				}

			}
		},
		getValuesCount:{
			"Should return the proper count":{
				before:function(test){
					test.init();					
					test.setValue("brand","testBrand").setValue("category","testCategory").setValue("category","test2",true);
				},
				given:{
					variable:"category"
				},
				then:{
					returns:"isNumeric",
					assert:[{
							message:"getValuesCount did not return the correct count",
							value:function(result){
								return result IS 2;
							}
						}]
				}
			}
		},
		checkMasks:{
			"Given a standard variable and value masks it finds the mask":{
				before:function(test){
					test.init();
					test.addMask("/{brand.value}/{category.value}/{merchant.value}/");	
					test.addMask("/{brand.value}/{category.value}/");					
					test.addMask("/");
					test.setValue("brand","testBrand").setValue("category","testCategory").setValue("category","test2",true);
				},
				then:{
					returns:"isObject",
					assert:[
						{
							message:"Mask ID that we found was not 0",
							value:function(result){
								return result.getMaskID() IS 2;
							}
						}
					]
				}
			},
			"Given a unlimited variable and value masks it finds the mask":{
				before:function(test){
					test.init();
					test.addMask("/{brand.value}/{category,/}/{merchant.value}/");	
					test.addMask("/{brand.value}/{category,/}/");					
					test.addMask("/");
					test.setValue("brand","testBrand").setValue("category","testCategory").setValue("category","test2",true);
				},
				then:{
					returns:"isObject",
					assert:[
						{
							message:"Mask ID that we found was not 0",
							value:function(result){
								return result.getMaskID() IS 2;
							}
						}
					]
				}
			}

		},
		getMaskAsArray:{
			"Returns the correct mask when using normal variable values":{				
				given:{
					mask:"/{brand.value}/{category.value}/{merchant.value}/"
				},
				then:{
					returns:"isArray",
					assert:[
						{
							message:"",
							value:function(result){
								return result[1] IS "brand.value" 
								   AND result[2] IS "category.value" 
								   AND result[3] IS "merchant.value";								
							}
						}
					]
				}
			},
			"Returns the correct mask when using multi variable values":{
				given:{
					mask:"/{brand.value.1}/{brand.value.2}/{category.value}/{merchant.value}/"
				},
				then:{
					returns:"isArray",
					assert:[{
							message:"Did not return 4 array values with the correct values",
							value:function(result){
								return result[1] IS "brand.value.1" 
								   AND result[2] IS "brand.value.2"
								   AND result[3] IS "category.value"
								   AND result[4] IS "merchant.value";
							}
						}]
				}
			},
			"Returns the correct mask when using unlimited variable values":{
				given:{
					mask:"/{brand.value.1}/{brand.value.2}/{category,/}/{merchant.value}/"
				},
				then:{
					returns:"isArray",
					assert:[{
							message:"",
							value:function(result){
								return result[1] IS "brand.value.1" 
								   AND result[2] IS "brand.value.2"
								   AND result[3] IS "category,/"
								   AND result[4] IS "merchant.value";
							}
						}]
				}
			}
		},
		get:{
			"Using normal variable values in the mask it returns the query string":{
				before:function(test){
					test.init("brand=testBrand&category=testCategory");
					test.addMask("/{brand.value}/{category.value}/");
					test.addMask("/");
				},
				then:{
					returns:"isString",
					assert:[{
							message:"The query string returned was not correct",
							value:function(result){
								return result IS "/testBrand/testCategory/"
							}
						}]
				}
			},
			"Using unlimited variable values in the mask the query string contains them":{
				before:function(test){
					test.init("");
					test.addMask("/{brand.value}/{category,/}/{merchant.value}/");
					test.addMask("/");
					test.setValue("brand","testBrand");
					test.setValue("category","testCategory");
					test.setValue("category","testCategory1",true);
					test.setValue("category","testCategory2",true);
					test.setValue("merchant","testMerchant");
				},
				then:{
					returns:"isString",
					assert:[{
							message:"The query string returned was not correct",
							value:function(result){
								return result IS "/testBrand/testCategory/testCategory1/testCategory2/testMerchant/"
							}
						}]
				}
			}
		}
	}
}
</cfscript>