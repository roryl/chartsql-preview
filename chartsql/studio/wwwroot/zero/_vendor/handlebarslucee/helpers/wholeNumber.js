/*
 */
Handlebars.registerHelper('wholeNumber', function(context, options) {
	return parseInt(context).toString();
});
