/*
Example
Implement a dateFormat helper method following the CFML dateFormat method
{{dateFormat [date] [mask]}}

date - Must be a valid date string that can be parsed by Javascript
mask - Must be a valid mask

 */
Handlebars.registerHelper('numberFormat', function(context, options) {
	return context.toString();
});
