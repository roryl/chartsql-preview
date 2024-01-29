![Lucee Handlebars Logo](https://raw.githubusercontent.com/https://github.com/roryl/handlebars.lucee/master/logo.fw.png)

# Handlebars.lucee
An implementation of the Handlebars.js templating language in [Lucee](http://lucee.org/). Handlebars is a logicless templating language and implements the language as defined by [Handlebars.js](http://handlebarsjs.com/)

This documentation will not go into specifics of the Handlebars syntax, for that see [Handlebars.js](http://handlebarsjs.com/)

Handlebars.lucee is a thin wrapper around [Handlebars.java](https://github.com/jknack/handlebars.java). For advanced usage and differences between Javascript Handlebars.js and Handlebars.java, read [their documentation](https://github.com/jknack/handlebars.java)

Handlebars.js is also mosly compatabile with Mustache templates, but there [are differences](https://github.com/wycats/handlebars.js#differences-between-handlebarsjs-and-mustache)

##Why Handlebars.lucee?
###Less Complex Templates
Handlebars is a logicless templaing philosophy meaning that it does not (without the use of helpers) contain expressions. It will only evaluate booleans and provide looping mechanisms. This keeps business logic from sneaking into view templates, but therefore requires that data passed to the template contains all of the output needed for rendering. It improves the separation and strictness of the view layer, at cost of the loss of templating flexibility. 

###Isomorphic Templates
By using Handlebars.lucee, an application can render output on the server using the same tempating library as in Javascript. This allows for quickly rendering on the server initial page loads, and then updating fragments from AJAX on the client.

###Easier for Designers
Because Handlebars templates don't contain any Lucee tags or functions, a designer doesn't need to know anything about Lucee to read the templates. The basic boolean logic is simple enough for anyone to understand.

##Usage
This documentation assumes familiarity with Handlebars or Mustache style templates and will not go into all of the uses. We recommend learning [Handlebars.js](http://handlebarsjs.com/) 

There are three ways to use Handlebars.lucee

1. Compiling Inline Templates
2. Compiling From Template Files
3. Lucee Custom Tag

###Compiling Inline Templates
The following example will output a hello world:
```coldfusion
<cfscript>
myTemplate = new Handlebars().compileInLine("Hello {{this}}!");
echo(myTemplate("world")); //outputs Hello world!
</cfscript>
```

The compileInLine function takes a text string that is a valid handlebars template and returns a Closure from which the compiled template can be used. Handlebars.lucee follows the Handlebars.js convention in that compiling a template creates a closure function which can be further called. This means that each template only needs to be compiled once for all invocations of that template in the request, and this compipled template can cached using any of the Lucee caching mechanisms.

This example below compiles once, but outputs three different words
```coldfusion
<cfscript>
myTemplate = new Handlebars().compileInLine("Hello {{this}}!");
echo(myTemplate("world")); //outputs Hello world!
echo(myTemplate("Jim")); //outputs Hello Jim!
echo(myTemplate("there")); //outputs Hello there!
</cfscript>
```

###Compiling From Template Files
Handlebars.lucee can read template files and compile them. Consider this template

helloworld.hbs
```handlebars
Hello {{this}}!
```

Then by passing the fully qualified path to the template to the handlebars.cfc compile() function, it acheives the same result as compileInLine()

```coldfusion
<cfscript>
myTemplate = new Handlebars().compile(expandPath("helloworld.hbs"));
echo(myTemplate("world")); //outputs Hello world!
echo(myTemplate("Jim")); //outputs Hello Jim!
echo(myTemplate("there")); //outputs Hello there!
</cfscript>
```

In the current implementation of Handlebars.lucee, you must provide the full path to the file.

The file extension of the handlebars template can be anything, but .hbs is the conventional extension.

###Lucee Custom Tag
The Handlebars.cfc file shipped with this repository is also a Lucee custom tag. Drop this repository into a customtag path that can find Handlebars.cfc to use it. With this usage method, the handlebars template is put into the tag body. The data for the output is passed via the context argument, and it can be a string, array or struct.

myTemplate.cfm
```coldfusion
<cf_handlebars context="world">
Hello {{this}}!
</cf_handlebars>
```

Use this method for replacing Lucee .cfm templates with handlebars templates and not interferring with any existing view framework that may be in use. Simply wrap the whole .cfm output in `<cf_handlebars></cf_handlebars>`

###Helpers
Handlebars.lucee can execute javascript helpers just like Handlebars.js. See the [Helpers documentation](http://handlebarsjs.com/block_helpers.html)

Handlebars.lucee takes care of registering the helper so that it is available for use in the template. Currently, it looks for helpers in the `helpers` folder of your Handlebars.lucee installation.

Because these helpers are executed with Rhino 1.7, they will not have the full capabilities of a modern Javascript browser (and particularly, no jquery support). Its recommended to keep the helpers simple, using vanilla JS.

The helpers are cached along with the Handlebars.java library, to flush the cache, call `Handlebars.cacheClear()`

###Advanced Usage
Handlebars.lucee is a simple wrapper around the Handlebars.java class. Get access to the instantiated handlebars.java class via the `Handlebars.getJava()` method and perform any actions possible. See the [Handlebars.java documentation](https://github.com/jknack/handlebars.java) for examples of advanced usage.

##Requirements
* Built for and tested with Lucee 4.5+
* Requires the presence of rhino-1.7R4.jar on the *Servlet Container class path* (NOT the Lucee Web Context or Server Conext lib folders, it will not work from there). Because of the way the underlying Handlebars.java class instantiates Rhino, Lucee cannot dynamically load this jar, and it cannot be in the Railo Server or Web Contexts.

##Installation
To use Handlebars.lucee, download this repository and place in a location where your application can path to Handlebars.cfc

This repository is also a CommandBox package, and can be installed using CommandBox

###For production use (will skip testobx)

box> `install https://github.com/roryl/handlebars.lucee/archive/master.zip --production`

###Contributing / Development
Download the repository and run it from a webroot. CommandBox will not install the unit test file, so you must download the repository. 

Execute the unit test by going `{your domain name}/handlebarsTest.cfc?method=runremote` or whatever webroot you have installed Handlebars.lucee into

###Automatic Jar Installation
The first time Handlebars.cfc is instantiated, it will try to install the Rhino jar files and will throw an error prompting to restart the Lucee instance to continue. This only needs to be done once. You must restart the servlet container (Tomcat, CommandBox) and not merely a Lucee Web Context.

####Supported Servlet Containers
The automatic installation has only been tested with the following Lucee installations
* via CommandBox on Windows
* via Lucee Tomcat Linux distribution

If one of these two installations is not found, an error will be thrown `Could not find a supported servlet container, try manually installing the Rhino rhino-1.7R4.jar as described in the documentation`

If automatic installation is failing or Lucee is not deployed on one of the above installations, try the [manual installation](#manual-jar-installation) described later in the readme. 

####Example for calling the automatic installation
```coldfusion
//With throw installed and needs restart, or was failed
Handlebars = new Handlebars();
```

To troubleshoot issues with the installation, do not call the default init constructor, and then the install methods can be tried:

```coldfusion
Handlebars = createObject("handlebars");
writeDump(Handlebars.isInstalled()); //returns true or false if it can find Rhino
Handlebars.install(); //attemptes the installation
```

###Manual Jar Installation
If Handlebars.lucee cannot finish the installation, or is returning the error "Rhino isn't on the classpath", copy the file java/rhino-1.7R4.jar from this repository to the servlet container jar library. The other jar files in the Handlebars.lucee java/ folder do not need to be copied, they are loaded dynamically by Lucee without issue.

####CommandBox Servlet Container Library Directory
On windows, put the rhino-1.7R4.jar file here:

`C:\Users\{your-user}\.CommandBox\lib`

####Lucee Linux Container Library Directory
Put the rhino-1.7R4.jar here: 

`/opt/lucee/lib`
