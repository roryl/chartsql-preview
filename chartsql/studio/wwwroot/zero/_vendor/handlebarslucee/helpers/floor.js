//From http://stackoverflow.com/questions/13046401/how-to-set-selected-select-option-in-handlebars-template
//Update to work with Rhino which could not take a regex, or use jquery unlike many of the examples
Handlebars.registerHelper('floor', function(context) {
    return Math.floor(context).toString();
});
