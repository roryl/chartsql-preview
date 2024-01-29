/**
 * Represents an HTML document output
*/
component accessors="true" {

	property name="links" setter="false";
	property name="forms" setter="false";

	public function init(required string document){
		var jsoup = createObject("java", "org.jsoup.Jsoup", "jsoup-1.10.2.jar");
		variables.doc = jsoup.parse(arguments.document);
		return this;
	}

	public Element[] function getLinks(){
		var out = [];
		var links = variables.doc.select("a");
		// for(var link in links){
		// 	out.append(new link(link));
		// }
		// // writeDump(links);
		// return out;
		return links;
	}
}