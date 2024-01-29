//https://stackoverflow.com/questions/34252817/handlebarsjs-check-if-a-string-is-equal-to-a-value
//https://stackoverflow.com/questions/48542688/handlebar-if-condition-not-workin
Handlebars.registerHelper('neq', function(a, b, options) {
	// if (arguments.length === 2) {
	//   options = b;
	//   b = options.hash.compare;
	// }
	if(a != b){
		return true;
	} else {
		/*
		Handlebars is expecting a 'falsy' value which according to Stackoverflow is false, undefined, null, "", 0, or [],
		However, if we return false, this gets converted to 'fasle' which returns true to the if helper. However if we return
		an empty string, then this is evaluated as false
		*/
		return '';
	}
  });