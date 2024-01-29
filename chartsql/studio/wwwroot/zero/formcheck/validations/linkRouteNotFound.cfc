/**
*/
component implements="validation,linkElement,routesFunc,routes" {
	public function init(required routesFunc, required linkElement, required array routes){

		var href = linkElement.attr("href");
		var href = listFirst(href, "?");

		if(href == "" or href == "/" or href == "##" or left(href, 1) == "##"){
			return;
		}

		/*
		If the domain name is not the domain name we are working on, then this
		is a link to an
		 */
		// var URI = createObject("java", "java.net.URI").init(cgi.server_name);
		var netURI = createObject("java", "java.net.URI").init(href);
		hrefDomain = netURI.getHost()?:"";
		var path = netURI.getPath();

		if(path == "" or path == "/" or path == "##" or left(path, 1) == "##"){
			return;
		}

		var isExternalDomain = hrefDomain != "" and lcase(hrefDomain) != lcase(cgi.server_name);
		if(isExternalDomain){
			return;
		}

		result = routesFunc(href, routes, "GET");
		if(result.matched){

		} else {
			throw("Could not find the route for the a link: #href#", "linkRouteNotFound");
		}
		return this;
	}
}