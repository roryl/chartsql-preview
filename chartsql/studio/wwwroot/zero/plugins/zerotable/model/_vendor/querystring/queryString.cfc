/*
Author: Rory Laitila
Purpose: Object to build and maintain query strings
*/
component accessors="true" output="true"
{
	property name="queryString" hint="the entire query string passed in";
	property name="queryStringStruct" hint="New structure to hold the query string values by key and value. This will be used to replaceQueryStringArray";
	property name="urlOut" hint="The URL that we will be generating";
	property name="masks" type="array" hint="The various masks that apply to these variables";
	property name="maskID";
	property name="defaultDelete" default="" hint="sets the default items to delete from every URL. Overwrites the defaults set in init";
	property name="domain" type="string" hint="If set, this will be included in the URL out";
	property name="protocol" default="" type="string" hint="sets the protocol to use in the URL (http, https)" ;
	property name="basePath" hint="A url base path with which to append the querystring to";
	property name="dump" default="false";
	property name="logid" default="";
	property name="enablelogging" default="false";
	property name="displayValues" default="" hint="A structure containing display values for a query string variable. They may or may not exist. Useful for breadcrumbs";
	property name="maskArray";

	public function init(string queryString="", struct populate)
	{

		if(structKeyExists(arguments,"querystring"))
		{

			var queryString = arguments.queryString;

			if(left(queryString, 1) == "?"){
				queryString = right(queryString, len(queryString) - 1);
			}
			setQueryString(trim(queryString));

			//Save the query string
			//Put the query string into a structure where the variable names are the keys, and the values are the elements
			var qsArray = listToArray(getQueryString(),"&");
			var qsStruct = [];
			for(var i=1; i LTE arrayLen(qsArray); i=i+1)
			{
				var workingStruct = {};
				var variable = listFirst(qsArray[i],"=");
				//If there is no value after the equals then set it to am empty string
				if(right(qsArray[i], 1) == "="){
					value = [""];
				} else {
					var value = [listLast(qsArray[i],"=")];
				}
				// writeDump(qsArray[i]);
				// writeDump(value);

				if(value[1] CONTAINS ".")
				{
					value = listToArray(value[1],".");
				}

				workingStruct[variable] = value;
				arrayAppend(qsStruct,workingStruct);
			}
			setQueryStringStruct(qsStruct);

			//Set set a default mask because if the user passes no other masks in, then we want URLs to work. If they pass a mask, then the masks theypass are explicit
			setMasks([""]);
			variables.maskID = 0;
			//Default QueryString variables that we want to delete.
			variables.defaultDelete = "cfid,cftoken,jsessionid,fieldnames,submit";
			variables.displayValues = {};
		}
		if(structKeyExists(arguments,"populate"))
		{
			this.populate(arguments.populate);
		}
		return this;
	}

	public function getVariablesListArray()
	{
		var list = [];
		for(i=1; i LTE arrayLen(variables.queryStringStruct); i=i+1)
		{
			for(var name in variables.QueryStringStruct[i])
			{
				arrayAppend(list,name);
			}
		}
		return list;
	}

	public function clear()
		hint="clears the query string and the querystring array and struct"
	{
		variables.queryString = "";
		variables.queryStringStruct = [];
		return this;
	}

	public function addMask(required string mask)
	{
		if(variables.masks[1] IS "")//If the first mask was set to the default of no mask, then delete it before we append our new masks to it. This makes the user responsible for setting a no mask option if they have supplied specific masks --->
		{
			ArrayDeleteAt(variables.masks,1);
		}
		ArrayAppend(variables.masks,arguments.mask);
		return this;
	}

	public function populate(struct)
	{

		for(item in arguments.struct)
		{
			if(isSimpleValue(arguments.struct[item]))
			{
				this.setValue(item,arguments.struct[item]);
			}

		}
		return this;
	}

	/**
	* @position Where to place the new variable. It can be at the 'start', 'end', 'before' or 'after' an existing variable
	* @currentVariable If the current is set, then we need the current Variable to know where to put it
	*/
	public function add(required NewVariable,value="",position="end",currentVariable)
	{
		var variable = arguments.NewVariable;
		var value = arguments.value;

		if(isSimpleValue(value))
		{
			value = listToArray(value,".");
		}



		switch (arguments.position)
		{
			case "start":
				ArrayPrepend(variables.queryStringStruct,{"#variable#"=local.value});
			break;

			case "end":
				ArrayAppend(variables.queryStringStruct,{"#variable#"=local.value});
			break;

			case "before":
				for(var i=1; i LTE arrayLen(variables.queryStringStruct); i=i+1)
				{
					if(structKeyExists(variables.queryStringStruct[i],arguments.currentVariable))
					{
						ArrayInsertAt(variables.queryStringStruct,i,{"#variable#"=local.value});
						break;
					}
				}
			break;

			case "after":
				if(ArrayLen(variables.queryStringStruct) IS "1")
				{
					ArrayAppend(queryStringArray,{"#variable#"=local.value});
					//Railo can't have a cfbreak nested inside a cfcase that is inside a loop, the loop must be a partent it seems to cfbreak
				}
				else
				{
					for(var i=1; i LTE arrayLen(variables.queryStringStruct); i=i+1)
					{
						if(structKeyExists(variables.queryStringStruct[i],arguments.currentVariable))
						{
							ArrayInsertAt(variables.queryStringStruct,i+1,{"#variable#"=local.value});
							break;
						}
					}
				}
			break;
		}

		return this;
	}


	public function delete(string variable, string position, string value)
	{
		//User can pass in a single variable to delete, or a list of variables. We'll make this an array
		var deleteVar = listToArray(arguments.variable,",");

		//Loop through the array of variables to delete to check them
		for(var i=1; i LTE arrayLen(deleteVar); i = i+1)
		{
			//Loop through each of the elements in our query string structure
			for(var i2=1; i2 LTE arrayLen(variables.queryStringStruct); i2=i2+1)
			{
				//If the variable we are deleting is within the structure
				if(structKeyExists(variables.queryStringStruct[i2],deleteVar[i]))
				{
					/*Three types of deletions:

						1. The Position has been passed in, so we want to delete the variable element at the specific position
						2. A variable and a value was passed in, so we want to delete the element if it matches the value
						3. Just a variable was passed in, so we will delete this variable

					*/


					//1. Delete the positional element passed in
					if(structKeyExists(arguments,"position") AND NOT isNull(arguments.position))
					{
						if(arguments.position LTE arrayLen(variables.queryStringStruct[i2][deleteVar[i]]))
						{
							try{

								arrayDeleteAt(variables.queryStringStruct[i2][deleteVar[i]],position);
							}
							catch(any e)
							{
								writeDump(arguments);
								abort;
							}
						}
					}

					//2. Delete the value matching the element
					else if(structKeyExists(arguments,"value"))
					{
						//Loop through each sub elements in the URL variable
						for(var i3=1; i3 LTE arrayLen(variables.queryStringStruct[i2][deleteVar[i]]); i3 = i3+1)
						{
							//If the sub element is the value passed in, then we will delete it
							if(variables.queryStringStruct[i2][deleteVar[i]][i3] IS arguments.value)
							{
								arrayDeleteAt(variables.queryStringStruct[i2][deleteVar[i]],i3);
							}
						}
						//Check if no more sub elements exist, if so, we want to delete the variable
						if(arrayLen(variables.queryStringStruct[i2][deleteVar[i]]) IS 0)
						{
							arrayDeleteAt(variables.queryStringStruct,i2);
						}
					}

					//3. Delete the entire variable
					else
					{
						arrayDeleteAt(variables.queryStringStruct,i2);
					}
				}

			}
		}
		return this;
	}

	public function getValue(required string variable)
	{
		//For each query string element
		for(var i = 1; i LTE arrayLen(variables.queryStringStruct); i =i+1)
		{
			//If the element name is the variable we are getting
			if(structKeyExists(variables.queryStringStruct[i],arguments.variable))
			{
				//Check if the variable is a struct. If it is, then this is a named variable.
				if(isStruct(variables.queryStringStruct[i][arguments.variable]))
				{
					for(var name in variables.queryStringStruct[i][arguments.variable])
					{
						return variables.queryStringStruct[i][arguments.variable][local.name];
					}

				}
				else //Must be an array of one or more value, so we will return them in the order they appear
				{
					//logs("something: #serializeJson(variables.queryStringStruct[i][variable])#");
					return arrayToList(variables.queryStringStruct[i][arguments.variable],".");
				}
			}
		}
	}

	public function getValuesCount(required string variable)
	{
		return listLen(getValue(arguments.variable),".");
	}

	public boolean function has(required string variable){
		return variableExists(arguments.variable);
	}

	public function variableExists(required string variable)
		hint="The variable that we want to retrieve out of the query string"
	{
		var exists = false;
		for(var i =1; i LTE arrayLen(variables.queryStringStruct); i=i+1)
		{
			if(structKeyExists(variables.queryStringStruct[i],arguments.variable))
			{
				local.exists = true;
			}
		}
		return local.exists;
	}

	public function getDisplayValue(required variableName)
	{
		if(structKeyExists(variables.displayValues,arguments.variableName))
		{
			return variables.displayValues[arguments.variableName];
		}
		else
		{
			return "";
		}
	}

	public function setDisplayValue(required variableName,required displayValue)
	{
		variables.displayValues[arguments.variableName] = arguments.displayValue;

		return this;
	}

	/*
	* @hint Takes a structure of keys and values and calls setValue on each of them
	*/
	public function setValues(required struct values)
	{
		local.values = arguments.values;

		for(local.key in local.values)
		{
			setValue(local.key,local.values[local.key]);
		}
		return this;
	}

	public function setValue(required string variable,required value, boolean append, string displayValue)
	{
		/* setValue will server two purposes:
			1. Check if an element exists, and if it does, update it (unless we force an append)
				a. The query element will either be an Array of values or it will be a Structure of values
			2. If the element doesn't exist, call for it to be added

		[
			{variable = [value1,value2,value3]},

			{variable = {name1=value1,name2=value2,name3=value3}}
		]




		*/
		var exists = false;
		//logs("variable: #arguments.variable#, value: #serializeJson(arguments.value)#");
		for(var i=1; i LTE arrayLen(variables.queryStringStruct); i =i+1)
		{
			//logs("variables.querystringStruct: #serializeJson(variables.queryStringStruct[i])#");
			if(structKeyExists(variables.queryStringStruct[i],arguments.variable))
			{
					if( structKeyExists(arguments,"append") AND arguments.append)
					{
						for(var i2=1; i2 LTE listLen(arguments.value,"."); i2=i2+1)
						{
							if(NOT variables.queryStringStruct[i][variable].contains(listGetAt(arguments.value,i2,".")))
							{
								arrayAppend(variables.queryStringStruct[i][variable],listGetAt(arguments.value,i2,"."));
							}
						}

					}
					else
					{

						var tempArray = [];
						for(var i2=1; i2 LTE listLen(arguments.value,"."); i2=i2+1)
						{
							arrayAppend(tempArray,listGetAt(arguments.value,i2,"."));
						}
						variables.queryStringStruct[i][arguments.variable] = local.tempArray;
					}
					local.exists = true;
			}
		}

		if(local.exists IS false)
		{
			this.add(arguments.variable,arguments.value);
		}

		if(structKeyExists(arguments,"displayValue"))
		{
			setDisplayValue(arguments.variable,arguments.displayValue);
		}

		return this;
	}

	public function getPosition(required string variable)
	{
		for(var i=1; i LTE arrayLen(queryStringStruct); i=i+1)
		{
			if(structKeyExists(queryStringStruct[i],variable))
			{
				return i;
			}
		}
	}

	private function checkMasks()
		hint="checks the given masks and determines if the variables passed in match"
	{

		//writeLog(file="affiliatespublic",text="#variables.maskid#");
		//Loop through all of the supplied masks
		for(var i=1;i LTE arrayLen(variables.masks); i=i+1)
		{
			//Get an array of the variables in the mask
			var maskArray = getMaskAsArray(variables.masks[i]);

			//We'll start by assuming this mask is valid and set back to 0 if it is invalidated below
			variables.maskId = i;
			//writeLog(file="affiliatespublic",text="working #i#");
			//Then look through the mask and check that the variables exist in the query string, if any do not, then the mask cannot be valid
			for(var i2=1; i2 LTE arrayLen(maskArray); i2=i2+1)
			{
				//logs("MaskArray: #maskarray[i2]#");
				/*
				In the masks feature, variables in the URL mask (as defined by in between {}) can be made up of three elemets

				For example: local.queryString.addMask("/{filter.value.1}/{filter.value.2}/{keyphrase.value}/id/{compositeId.value}/");

				The mask is: /{filter.value.1}/{filter.value.2}/{keyphrase.value}/id/{compositeId.value}/

				A variable with three elements might therefore be like: {filter.value.1}

				Whereas Filter is the URL variable
				Whereas Value is the value of the URL variable
				And Whereas '1' or '2' is the element within the list of the value, like filter=element1.element2

				Variables can also have associate arrays like so for when we want to pass in a struct of possible values identified by a name:

				/{filter[namedValue1]}/{filter[namedValue2]}/

				*/
				if(maskArray[i2] CONTAINS "[")
				{
					var variable = listToArray(maskArray[i2],"["); //The variable from the mask put into an array. ""filter.value.1" becomes [filter,value,1]
				}
				else if(maskArray[i2] CONTAINS ".")
				{
					var variable = listToArray(maskArray[i2],"."); //The variable from the mask put into an array. ""filter.value.1" becomes [filter,value,1]
				}
				else
				{
					var variable = listToArray(maskArray[i2],",");
				}

				//First check if the variable exists at all. If the variable from the mask is not in the query string then we don't need to go farther adn we break out of the loop
				if(NOT this.variableExists(variable[1])) //If "filter" is not within within the query string at all
				{
					//This mask is not valid because it does not contain the variable, break and set maskID back to 0
					//writeLog(file="affiliatespublic",text="mask #i# not valid");
					variables.maskId = 0;
					break;
				}

				//The variable at least exists so now we need to determine if it matches the match supplied
				if(arrayLen(variable) IS 3)
				{
					//Get the value of the variable
					var value = this.getValue(variable[1]);
					//logs("Variable Value: #value#");
					//If the number of elements in the actual value is less than the expected number of elements based on the mask then it must not be valid
					if(listLen(value,".") LT variable[3])
					{
						//logs("mask not valid");
						maskId = 0;
						break;
					}
				}
			}

			//If the mask was not invalidated, then we have a valid mask, break the loop
			if(variables.maskId IS NOT 0)
			{
				//logs(text="valid mask, get urlOut and #variables.maskid#");
				variables.maskArray = getMaskAsArray(variables.masks[variables.maskid]);
				//writeDump(variables.maskArray);abort;
				break;
			}
		}
		return this;
	}

	public function get(useMask=true)
		output="false"
	{
		//get() will build the URL appending the remaining query string variables after the mask.


			//Delete all of the default delete variables
			this.delete(variables.defaultDelete);


			//Save the instances queryString variable so that we
			local.savedQueryString = duplicate(variables.queryStringStruct);


			//First we need to determine which of the possible masks are valid. We will do this by looping over the supplied masks,
			//and checking which mask matches the variables in the query string
			if(variables.maskid IS 0)
			{
				checkMasks();
			}


			//Check if mask is still zero we throw an error
			if(variables.maskID IS 0)
			{
				throw("Variables passed in do not match a valid mask");
			}

			//We start with the Mask and we will be replacing values to build the URL
			local.urlOut = variables.masks[variables.maskid];
			logs("urlOut: #urlOut#");
			local.maskArray = variables.maskArray;
			logs("using Mask:#serializeJson(local.maskArray)#");

			//Loop through each variable in the mask Array and we'll replace this variable with its action in the urlOut
			for(var i=1;i LTE arrayLen(local.maskArray); i=i+1)
			{

				logs("working on mask: #maskarray[i]#");
				logs(serializeJson(variables.queryStringStruct));
				//Each item in the mask array will be a variable. The variable may have multiple elements separated by a ".". Extract those into an array
				if(local.maskArray[i] CONTAINS ".")
				{
					var UrlVariable = listToArray(local.maskArray[i],".");
				}
				else
				{
					var UrlVariable = listToArray(local.maskArray[i],",");
				}


				//Check if the query string contains this variable. If it doesn't, then we can't replace it
				if(NOT this.variableExists(Urlvariable[1]))
				{
					//writeLog(file="affiliatespublic",text="skip, variable does not exist");
					continue;
				}

				/*Check what the variable is. Currently three options:
					1) Just the name of the URL variable ex. "action". In this case this would designate that we get the value of action
					2) The name plus an attribute, like "action.name" or "action.value". This is more explicit, and allows us to dynamically get
						the variable name or the variables value back into our URL
					3) The name, plus the value, plus the index: "action.value.1" - This allows us to use URL variables whose values might be a period "." delimited list
					4) If the variable contains a "/" then it means that we want to expand all values to the variable into a list separated by "/"
				*/

				//If there is only one element, then we must be getting the value for the variable
				if(ArrayLen(Urlvariable) IS 1)
				{
					//writeLog(file="affiliatespublic",text="one element in this array");
					local.urlOut = ReplaceNoCase(local.urlOut,"{" & local.maskArray[i] & "}",this.getValue(Urlvariable[1]));

				}

				//If there are two elements, then check what we want to return
				if(ArrayLen(Urlvariable) IS 2)
				{

					//writeLog(file="affiliatespublic",text="two element in this array");
					//Check if we return value
					if(Urlvariable[2] IS "value")
					{
						local.urlOut = ReplaceNoCase(local.urlOut,"{" & local.maskArray[i] & "}",this.getValue(Urlvariable[1]));
						logs(local.urlOut);
					}

					//Check if we return the name
					if(Urlvariable[2] IS "name")
					{
						local.urlOut = ReplaceNoCase(local.urlOut,"{" & local.maskArray[i] & "}",Urlvariable[1]);
					}

					//Get all values of the variable and append them to the list, replacing the "." with the delimiter "/"
					if(Urlvariable[2] IS "/")
					{
						local.urlOut = ReplaceNoCase(local.urlOut,"{" & local.maskArray[i] & "}",replace(this.getValue(Urlvariable[1]),".","/","all"));
					}

				}

				//If there are three elements, then it must be the value, and the last item is the index
				if(ArrayLen(Urlvariable) IS 3)
				{
					//writeLog(file="affiliatespublic",text="three element in this array");
					var position = Urlvariable[3];
					value = listGetAt(this.getValue(Urlvariable[1]),position,".");

					local.urlOut = ReplaceNoCase(local.urlOut,"{" & local.maskArray[i] & "}",value);

				}


			}

			//Now we need to delete the mask variables from the query string so that we can append what is left to the URL out
			for(i=1;i LTE ArrayLen(local.maskArray);i=i+1)
			{
				this.delete(listFirst(local.maskArray[i],"."));
			}

			if(arraylen(variables.queryStringStruct) GT 0)
			{
				local.urlOut = local.urlOut & "?" & serializeQueryStringStruct();
			}

			if(structKeyExists(variables,"basePath") AND len(variables.basePath) GT 0){
				local.urlOut = variables.basePath & local.UrlOut;
			}

			//Prepend the domain name if exists
			if(structKeyExists(variables,"domain") AND len(variables.domain) GT 0)
			{
				local.urlOut = variables.domain & local.UrlOut;
			}

			//Prepend the protocol if exists
			if(structKeyExists(variables,"protocol") AND len(variables.protocol) GT 0)
			{
				local.urlOut = variables.protocol & local.UrlOut;
			}

			//replace variables.queryString with saved value so it can be used again
			variables.queryStringStruct = local.savedQueryString;
			return trim(local.urlOut);
	}

	private function serializeQueryStringStruct()
	{

		var out = "";
		for(var i=1; i LTE arrayLen(variables.queryStringStruct); i = i+1)
		{
			for(var item in variables.queryStringStruct[i])
			{
				if(NOT isStruct(variables.queryStringStruct[i][item]))
				{
					logs(serializeJson(variables.queryStringStruct));
					try{
						out = out & item &"=" & arrayToList(variables.queryStringStruct[i][item],".") & "&";
					}
					catch(any e){
						writeDump(this);
						abort;
					}

				}
				else
				{
					for(var name in variables.queryStringStruct[i][item])
					{
						out = out & item &"=" & variables.queryStringStruct[i][item][name] & "&";
					}

				}
			}
		}
		//Delete the training & if it exists
		if(right(out,1) IS "&")
		{
			out = left(out,len(out) -1);
		}
		return out;
	}

	public function getMaskAsArray(required mask)
	{
		var maskArray = REMatchNoCase("\{[A-Za-z0-9\.\,\/]*\}",arguments.mask);
		for(var i=1;i LTE ArrayLen(maskArray);i=i+1)
		{
			maskArray[i] = ReplaceNoCase(maskArray[i],"{","");
			maskArray[i] = ReplaceNoCase(maskArray[i],"}","");
		}
		return maskArray;
	}

	public function getNew()
	{
		return duplicate(this);
	}

	public function resetMask()
		hint="The last mask that was valid is cached, we can reset it manually if we need to"
	{
		variables.maskid = 0;
		return this;

	}

	public function setLogID(required logid)
	{
		variables.logid = arguments.logid;
		return this;
	}

	public function logs(required string text)
	{
		if(variables.enablelogging)
		{
			writeLog(file="querystring",text="Logid:#variables.logid# #arguments.text#");
		}
	}

}