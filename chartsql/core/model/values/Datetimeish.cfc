/**
 * Takes a string and parses a datetime object from it. It can handle
 * many types of date formats we might encounter in real life.
*/
component {

	public function init(required string value){
		variables.value = this.parseDateTime(value);
		return this;
	}

	public function expectToBe(required date value){
		if(variables.value != arguments.value){
			throw("Expected date to be #arguments.value# but got #variables.value#");
		}
		return this;
	}

	public function datetimeFormat(required string format){
		return datetimeFormat(variables.value, arguments.format);
	}

	/**
	 * Checks if the date object has a time part that is not 0
	 */
	public boolean function isZeroTime(){
		var timePart = hour(variables.value) + minute(variables.value) + second(variables.value);
		if(timePart != 0){
			return false;
		} else {
			return true;
		}
	}

	static boolean function isDate(required string value){
		if(isDate(arguments.value)){
			return true;
		} else {
			try {
				Datetimeish::parseDateTime(arguments.value);
				return true;
			}catch(any e){
				return false;
			}
		}
	}

	static date function parseDateTime(required string value){
		if(isDate(arguments.value)){
			return parseDateTime(arguments.value);
		} else {
			var trials = [
				//rewrite "31st December 2035 11:59 pm EST" to "December 31, 2035 11:59 PM EST"
				reReplaceNoCase(arguments.value, "([0-9]{1,2})st ([a-zA-Z]+) ([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [pP][mM] ([a-zA-Z]+)", "\2 \1, \3 \4:\5 PM \6", "all"),
				//Dth of Month YYYY (e.g. 5th of May 2015)
				reReplaceNoCase(arguments.value, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4})", "\2 \1, \3", "all"),
				//HH:MM, DD Month YYYY (e.g. 12:00, 12 December 2031)
				reReplaceNoCase(arguments.value, "([0-9]{2}):([0-9]{2}), ([0-9]{1,2}) ([a-zA-Z]+) ([0-9]{4})", "\4 \3, \5 \1:\2", "all"),
				// "DDth of Month YYYY HH:MM TZ" (e.g. 13th of March 2032 13:00 UTC)
				reReplaceNoCase(arguments.value, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\2 \1, \3 \4:\5:00 \6", "all"),
				// YYYY-Month-DD HH:MM:SS TZ+1 (e.g. 2033-Apr-14 04:00:00 GMT+1)
				reReplaceNoCase(arguments.value, "([0-9]{4})-([a-zA-Z]+)-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\1-\2-\3 \4:\5:\6", "all"),
				//"MM/DD/YY HH:MM TZ" (e.g. 05/15/34 05:00 CEST)
				reReplaceNoCase(arguments.value, "([0-9]{2})/([0-9]{2})/([0-9]{2}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "20\3-\1-\2 \4:\5:00 \6", "all"),
				//DDst Month YYYY HH:MM TZ (e.g. 31st December 2035 23:59 EST)
				reReplaceNoCase(arguments.value, "([0-9]{1,2})st ([a-zA-Z]+) ([0-9]{4}) ([0-9]{2}):([0-9]{2}) ([a-zA-Z]+)", "\2 \1, \3 \4:\5:00 \6", "all"),
				//rewrite "April 5, 2023 5:00 p.m." to "April 5, 2023 5:00 PM"
				reReplaceNoCase(arguments.value, "([a-zA-Z]+) ([0-9]{1,2}), ([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) p.m.", "\1 \2, \3 \4:\5 PM", "all"),
				//rewrite "5 Apr 2024 12:01 A.M." to "Apr 5, 2024 12:01 AM"
				reReplaceNoCase(arguments.value, "([0-9]{1,2}) ([a-zA-Z]+) ([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [aApP].[mM].", "\2 \1, \3 \4:\5 AM", "all"),
				//rewrite "2027 July 8 1:00P.M." to "July 8, 2027 1:00 PM"
				reReplaceNoCase(arguments.value, "([0-9]{4}) ([a-zA-Z]+) ([0-9]{1,2}) ([0-9]{1,2}):([0-9]{2})[aApP].[mM].", "\2 \3, \1 \4:\5 PM", "all"),
				//rewrite 9th of August 2028 10:00a to "August 9, 2028 10:00 AM"
				reReplaceNoCase(arguments.value, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4}) ([0-9]{1,2}):([0-9]{2})[aA]", "\2 \1, \3 \4:\5 AM", "all"),
				//rewrite 11-11-2030 4:00 a.m. to "11-11-2030 4:00 AM"
				reReplaceNoCase(arguments.value, "([0-9]{2})-([0-9]{2})-([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [aA].[mM].", "\1-\2-\3 \4:\5 AM", "all"),
				reReplaceNoCase(arguments.value, "([0-9]{2})-([0-9]{2})-([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [pP].[mM].", "\1-\2-\3 \4:\5 PM", "all"),
				//rewrite "13th of March 2032 1:00 pm UTC" to "March 13, 2032 1:00 PM"
				reReplaceNoCase(arguments.value, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [aA][mM] UTC", "\2 \1, \3 \4:\5 AM", "all"),
				reReplaceNoCase(arguments.value, "([0-9]{1,2})th of ([a-zA-Z]+) ([0-9]{4}) ([0-9]{1,2}):([0-9]{2}) [pP][mM] UTC", "\2 \1, \3 \4:\5 PM", "all"),
				//rewrite "2033-Apr-14 4:00:00 am GMT+1" to "Apr 14, 2033 4:00:00 AM GMT+1:00"
				reReplace(arguments.value, "([0-9]{4})-([a-zA-Z]+)-([0-9]{2}) ([0-9]{1,2}):([0-9]{2}):([0-9]{2}) am ([a-zA-Z]+)\+([0-9]{1,2})", "\2 \3, \1 \4:\5:\6 AM \7+\8:00", "all"),
				//rewrite "15/05/34 5:00 pm CEST" to "05/15/34 5:00:00 PM CEST"
				reReplaceNoCase(arguments.value, "([0-9]{2})/([0-9]{2})/([0-9]{2}) ([0-9]{1,2}):([0-9]{2}) [pP][mM] ([a-zA-Z]+)", "\2/\1/\3 \4:\5:00 PM \6", "all"),
			]

			// writeDump(trials);

			for(var trial in trials){
				if(isDate(trial)){
					return parseDateTime(trial);
				}
			}

			// writeDump(trials);
			//If we get here, we couldn't parse the date
			throw("Could not parse date from string: #arguments.value#");
		}
	}

}