/**
* My xUnit Test
*/
component extends="testbox.system.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all test cases
	function beforeTests(){
		//Becuase custom tag classes seem to be cached, restart the Lucee instance
		admin action="restart" type="server" password="123456";	
	}

	// executes after all test cases
	function afterTests(){
	}

	// executes before every test case
	function setup( currentMethod ){				
		Handlebars = new Handlebars();
		Handlebars.cacheClear();
	}

	// executes after every test case
	function teardown( currentMethod ){
	}

/*********************************** TEST CASES BELOW ***********************************/
	
	// Remember that test cases MUST start or end with the keyword 'test'
	function isInstalledTest(){
		
		expect(Handlebars.isInstalled()).toBe(true);
		// writeDump(expandPath("{lucee-server}"));

	}

	function servletContainerPathTest(){

		// makePublic(Handlebars, "getServletContainerPath", "getServletContainerPath");
		// var path = Handlebars.getServletContainerPath();
		// writeDump(path);
	}

	function installTest(){
		Handlebars.install();
		// throw()
	}

	function getHandlebarsTest(){
		makePublic(Handlebars,"getJava","getJava");
		var java = Handlebars.getJava();
		expect(java.getClass().getName() contains "com.github.jknack.handlebars.Handlebars").toBeTrue();
	}
	
	function compileInLineTest(){

		var data = "Hello";
		myTemplate = Handlebars.compileInLine("{{this}}!");
		expect(myTemplate("Hello")).toBe("Hello!");

	}

	function compileTest(){
		myTemplate = Handlebars.compile(expandPath("templates/helloWorld.hbs"));		
		expect(myTemplate("world")).toBe("Hello world!");
	}

	function compileUseTwiceTest(){
		myTemplate = Handlebars.compile(expandPath("templates/helloWorld.hbs"));		
		expect(myTemplate("world")).toBe("Hello world!");
		expect(myTemplate("jim")).toBe("Hello jim!");		
	}
	

	function compileFileNotFoundTest(){
		expect(function(){Handlebars.compile(expandPath("templates/helloWorld1.hbs")); }).toThrow();
		// myTemplate = 	
	}

	function customTagTest(){

		savecontent variable="myOutput" {
			module template="handlebars.cfc" context="world" {
				echo("Hello {{this}}!");
			}			
		}
		// writeDump(myOutput);

	}
}
