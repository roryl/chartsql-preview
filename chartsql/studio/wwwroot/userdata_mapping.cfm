<cfscript>
	// -----------------------------------
	// HOME DIRECTORY
	// -----------------------------------
	// Different OS have different home directories
	if (server.system.properties.keyExists("user.home")) {
		// MacOS and Linux
		homeDirectory = server.system.properties["user.home"];
	} else {
		// Windows
		homeDirectory = server.system.environment.appdata;
	}

	// -----------------------------------
	// INSTALL LOCATION
	// -----------------------------------
	// We are going to create a name that uniquely identifies where this ChartSQL
	// installation is located so that we can have multiple installations. This
	// can be used for testing or where the user wants to run multiple versions.
	installLocation = getDirectoryFromPath(getCurrentTemplatePath())
		.replace(server.separator.file, "_", "all")
		.replace(":", "_", "all")
		.replace(".", "_", "all")
	dirPath = homeDirectory & server.separator.file & "ChartSQL" & server.separator.file & installLocation;

	if(!directoryExists(dirPath)){
		directoryCreate(dirPath);
	}

	// -----------------------------------
	// USER DATA DIRECTORY
	// -----------------------------------
	// This mapping is used to store user data such as user settings, user data, and user
	// generated files. This is a good place to store user data because it is not in the
	// application directory.
	this.mappings[ "/com/chartsql/userdata"] = dirPath;
</cfscript>