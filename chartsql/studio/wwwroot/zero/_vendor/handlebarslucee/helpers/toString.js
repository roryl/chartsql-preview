//From http://stackoverflow.com/questions/13046401/how-to-set-selected-select-option-in-handlebars-template
//Update to work with Rhino which could not take a regex, or use jquery unlike many of the examples
Handlebars.registerHelper('toString', function(context) {
	if(context === undefined || context === null){
		return "";
	}
    return context.toString();
});
