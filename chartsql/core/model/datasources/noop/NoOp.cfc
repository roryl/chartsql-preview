/**

*/
component extends="com.chartsql.core.model.Datasource" {

	remote function testRemote() {

	}

	remote function executeWithReturnValue() {
		return 1;
	}

	remote function functionWithArguments(
		required string foo,
		string bar = ""
	) {
		return trim(foo  & " " & bar);
	}

}