/*
Example
Implement a dateFormat helper method following the CFML dateFormat method
{{dateFormat [date] [mask]}}

date - Must be a valid date string that can be parsed by Javascript
mask - Must be a valid mask

 */
Handlebars.registerHelper('dollarFormat', function(n, options) {

	var commafy = function(str){
		/* more code from Steve Levithan (http://blog.stevenlevithan.com/).
		* again slightly modified because Steve made this an extension of
		* the string object. Brilliant Steve, thanks! :o)
		*/
		return str.replace(/(\D?)(\d{4,})/g, function($0, $1, $2) {
			return (/[.\w]/).test($1) ? $0 : $1 + $2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g, '$&,');
		});
	}

	// //Pull dollarFormat function from cfjs https://github.com/toferj/cfjs/blob/master/jquery.cfjs.js
	var _n,sign,cents;
	_n = n.toString().replace(/\$|\,/g,'');
	_n = _n.toString().replace('(','-');
	_n = _n.toString().replace(')','');
	if(isNaN(_n)){
		_n = 0;
	}
	sign = (_n == (_n = Math.abs(n)));
		_n = Math.floor(_n*100+0.50000000001);
	cents = _n%100;
		_n = Math.floor(_n/100).toString();
	if(cents < 10){
		cents = "0" + cents;
	}
	_n += "." + cents;
	_n = commafy(_n);
	return (((sign)?'':'(') + '$' + _n + ((sign)?'':')'));
	// return _n;
	// return "foo";
});
