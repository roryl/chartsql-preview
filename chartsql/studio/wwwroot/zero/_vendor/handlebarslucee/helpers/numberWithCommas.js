/*
Example
Implement a dateFormat helper method following the CFML dateFormat method
{{dateFormat [date] [mask]}}

date - Must be a valid date string that can be parsed by Javascript
mask - Must be a valid mask

 */
Handlebars.registerHelper('numberWithCommas', function(n, options) {

	var commafy = function(str){
		/* more code from Steve Levithan (http://blog.stevenlevithan.com/).
		* again slightly modified because Steve made this an extension of
		* the string object. Brilliant Steve, thanks! :o)
		*/
		return str.replace(/(\D?)(\d{4,})/g, function($0, $1, $2) {
			return (/[.\w]/).test($1) ? $0 : $1 + $2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g, '$&,');
		});
	}
	if(n == null){
		return "";
	}
	// //Pull dollarFormat function from cfjs https://github.com/toferj/cfjs/blob/master/jquery.cfjs.js
	var _n;
	_n = n.toString().replace(/\$|\,/g,'');
	_n = _n.toString().replace('(','-');
	_n = _n.toString().replace(')','');
	if(isNaN(_n)){
		_n = 0;
	}
	_n = commafy(_n);
	return (_n);
});
