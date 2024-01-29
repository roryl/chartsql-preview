/**
* Allows for evaluating true/false from a handlebars lookup subexpression ie {{#if (lookup somevalue)}}
* Subexpressions return strings, which to handlebars are "truthy". As such this ifLookup helper checks
* if the string would normally be a true or false value
*/
Handlebars.registerHelper('ifLookup', function(a, opts) {
    if(a == "true" || a == true)
        return opts.fn(this);
    else
        return opts.inverse(this);
});