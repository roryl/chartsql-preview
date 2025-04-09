//From http://stackoverflow.com/questions/13046401/how-to-set-selected-select-option-in-handlebars-template
//Update to work with Rhino which could not take a regex, or use jquery unlike many of the examples
Handlebars.registerHelper('repeat', function(string, count) {
    var result = '';
	for (var i = 0; i < count; i++) {
		result += string;
	}
	return result;
});
