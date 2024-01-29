/*
Example
Implement a dateFormat helper method following the CFML dateFormat method
{{dateFormat [date] [mask]}}

date - Must be a valid date string that can be parsed by Javascript
mask - Must be a valid mask

 */

Handlebars.registerHelper('dateFormat', function(context, options) {

	//Pull date function from cfjs https://github.com/toferj/cfjs/blob/master/jquery.cfjs.js
	if (context == null || context === '' || context === undefined) {
		return '';
	}

	var d = new Date(context.time).toString();
    mask = options;
	var m,zeroize;

	// we're expecting d to be a javascript date object, but if it's not then we'll assume it's a string
	// representation of a date and attempt to convert that string into a date object
	if(!(d instanceof Date)){
		d = new Date(d);
	}

	if(d.toString() === 'Invalid Date') {
		return '';
	}

	// If preferred, zeroise() can be moved out of the format() method for performance and reuse purposes
	zeroize = function (value, length) {
		var i;
		if(!length){length = 2;}
		value = String(value);
		for(i = 0, zeros = ''; i < (length - value.length); i++){
			zeros += '0';
		}
		return zeros + value;
	};

	return mask.replace(/"[^"]*"|'[^']*'|\b(?:d{1,4}|m{1,4}|yy(?:yy)?|([hHMstT])\1?|[lLZ])\b/g, function($0) {
		switch($0) {
			case 'd':		return d.getDate();
			case 'dd':		return zeroize(d.getDate());
			case 'ddd':		return ['Sun','Mon','Tue','Wed','Thr','Fri','Sat'][d.getDay()];
			case 'dddd':	return ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][d.getDay()];
			case 'm':		return d.getMonth() + 1;
			case 'mm':		return zeroize(d.getMonth() + 1);
			case 'mmm':		return ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.getMonth()];
			case 'mmmm':	return ['January','February','March','April','May','June','July','August','September','October','November','December'][d.getMonth()];
			case 'yy':		return String(d.getFullYear()).substr(2);
			case 'yyyy':	return d.getFullYear();
			case 'h':		return d.getHours() % 12 || 12;
			case 'hh':		return zeroize(d.getHours() % 12 || 12);
			case 'H':		return d.getHours();
			case 'HH':		return zeroize(d.getHours());
			case 'M':		return d.getMinutes();
			case 'MM':		return zeroize(d.getMinutes());
			case 's':		return d.getSeconds();
			case 'ss':		return zeroize(d.getSeconds());
			case 'l':		return zeroize(d.getMilliseconds(), 3);
			case 'L':		m = d.getMilliseconds();
							if(m > 99){m = Math.round(m / 10);}
							return zeroize(m);
			case 'tt':		return d.getHours() < 12 ? 'am' : 'pm';
			case 't':		return d.getHours() < 12 ? 'a' : 'p';
			case 'TT':		return d.getHours() < 12 ? 'AM' : 'PM';
			case 'T':		return d.getHours() < 12 ? 'A' : 'P';
			case 'Z':		return d.toUTCString().match(/[A-Z]+$/);
			// Return quoted strings with the surrounding quotes removed
			default:		return $0.substr(1, $0.length - 2);
		}
	});

});
