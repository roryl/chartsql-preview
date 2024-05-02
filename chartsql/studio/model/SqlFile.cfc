/**
 * Represents a SQL file on the file system
*/
component accessors="true" {

	property name="Package";
	property name="Content";
	property name="Name";
	property name="FullName";
	property name="Directives";
	property name="NamedDirectives";
	property name="LastExecutionRequest";
	property name="LastSuccessfulExecutionRequest";
	property name="LastRendering";
	property name="IsDirty";
	property name="EditorContent";
	property name="Subpath";
	property name="Id";
	property name="Path";
	property name="DetectionMode";
	property name="IsMissing";
	property name="HasDirectiveErrors";
	property name="ParsedDirectives";
	property name="LastRenderContent";
	property name="LastOptionContent";
	property name="IsMissingFile";

	public function init(
		required Package Package,
		required string path,
		required string name
	){
		variables.path = arguments.path;
		if (!fileExists(variables.path)) {
			variables.IsMissingFile = true;
		} else {
			variables.IsMissingFile = false;
		}
		variables.FullName = new values.FullyQualifiedPathName(arguments.path).toString();
		// Check that there is not a file with the same name in the package
		// otherwise it should error
		var PreexistingSqlFile = arguments.Package.findSqlFileByFullName(variables.FullName);
		if (PreexistingSqlFile.exists() ) {
			throw("A file with the name #arguments.name# already exists in the package #arguments.Package.getName()#");
		}

		variables.Name = arguments.name;
		variables.Package = arguments.Package;
		variables.Package.addSqlFile(this);
		variables.Package.getChartSqlStudio().addSqlFile(this);
		variables.IsMissing = false;
		variables.IsDirty = false;
		variables.HasDirectiveErrors = false;
		variables.Subpath = this.generateSubpath();
		this.setEditorContent(this.getContent());
		this.loadDirectives();

		variables.Id = createUUID();
		return this;
	}

	public string function generateSubpath() {
		out = variables.path;

		// Remove everything after the last slash to remove the file name
		out = left(out, findLast(server.separator.file, out) - 1);

		SubfilePackagePath = variables.Package.getPath();

		if(SubfilePackagePath != ""){
			out = out.replace(SubfilePackagePath, "");
		}
		// Remove just the first ocurrence of a '/' from the string or '\' on windows
		if(left(out, 1) == server.separator.file){
			out = out.replace(server.separator.file, "", "once");
		}
		return out;
	}

	public function getContent(){
		if (!fileExists(variables.path)) {
			variables.IsMissingFile = true;
			return '';
		} else {
			variables.IsMissingFile = false;
		}
		var content = fileRead(variables.path)
		return content;
	}

	public function writeContent(string content){
		variables.content = arguments.content;
		this.setEditorContent(content);
		this.save();
		structDelete(variables, "LastRenderContent");
		structDelete(variables, "LastOptionContent");
	}

	/**
	 * Utility function for testing to show the directives
	 * that have a value set
	 */
	public function getHasValueDirectives(boolean asStruct = false){
		if(asStruct){
			var out = {};
			for(var directive in variables.directives){
				if(directive.getHasValue()){
					out[directive.getName()] = directive;
				}
			}
			return out;
		} else {
			var out = [];
			for(var directive in variables.directives){
				if(directive.getHasValue()){
					arrayAppend(out, directive);
				}
			}
			return out;
		}
		return out;
	}

	public optional function getLastRendering(){
		return new Optional(variables.LastRendering?:nullValue());
	}

	public optional function getLastRenderContent(){
		return new Optional(variables.LastRenderContent?:nullValue());
	}

	public optional function getLastOptionContent(){
		return new Optional(variables.LastOptionContent?:nullValue());
	}

	/**
	 * Gets the parsed directives from the SQL file
	 * @return array
	 */
	public function loadDirectives(){
		var ChartSql = new core.model.ChartSQL();
		var sql = this.getEditorContent();
		var SqlScript = new core.model.SqlScript(ChartSql, sql);
		variables.directives = SqlScript.getDirectives();
		variables.parsedDirectives = SqlScript.getParsedDirectives();		// return directives;
		variables.DetectionMode = SqlScript.getDetectionMode();

		//If any of the directives have errors, then we need to mark the file as having errors
		variables.HasDirectiveErrors = false;
		for(var directive in variables.directives){
			if(directive.getHasErrors()){
				variables.HasDirectiveErrors = true;
			}
		}

	}

	public function getNamedDirectives(){
		var directives = variables.directives
		var out = {};
		for(var directive in directives){
			out[directive.getName()] = directive;
		}
		return out;
	}

	public function getLastExecutionRequest(){
		return new Optional(variables.LastExecutionRequest?:nullValue());
	}

	/**
	 * Allows us to load the last successful execution so we can get useful data for rendering
	 * or displaying columns, even if there is currently a request or if the latest exection
	 * has errors
	 */
	public function getLastSuccessfulExecutionRequest(){
		return new Optional(variables.LastSuccessfulExecutionRequest?:nullValue());
	}

	/**
	 * Adds or updates the directive in the sql content with the new value
	 * and reloads the directives
	 *
	 * @name The name of the directive to add/update
	 * @value The value to update the directive to
	 */
	public function addOrUpdateDirective(required string name, required string value){
		var ChartSql = new core.model.ChartSQL();
		var sql = this.getContent();
		var SqlScript = new core.model.SqlScript(ChartSql, this.getEditorContent());
		var text = trim(arguments.value);
		if(text == ""){
			SqlScript.removeDirectiveLine(name);
		} else {
			SqlScript.addOrReplaceDirectiveText(name, value);
		}
		this.setEditorContent(SqlScript.getSql());
	}

	/**
	 * Rename the file and update the name in the package
	 *
	 * @name The name of the directive to add/update
	 */
	public function changeFileName(required string newName){
		var newPath = variables.path.replace(variables.Name, arguments.newName, "all");

		// Renames the file name to its new name
		fileMove(variables.path, newPath);

		variables.path = newPath;
		variables.FullName = new values.FullyQualifiedPathName(newPath).toString();
		variables.Name = arguments.newName;
		variables.Subpath = this.generateSubpath();
	}

	/**
	 * Gets updated changes from the users edtiro and stores them without
	 * saving. Marks the SqlFile as dirty so that we can display to the
	 * user that saving is necessary
	 *
	 * @content
	 */
	public function setEditorContent(required string content){

		variables.EditorContent = arguments.content;
		structDelete(variables, "LastRenderContent");
		structDelete(variables, "LastOptionContent");

		if(hash(trim(arguments.content)) != hash(trim(this.getContent()))){
			variables.IsDirty = true;
		} else{
			variables.IsDirty = false;
		}
		this.loadDirectives();
	}

	public function toggleDirective(required string name){
		var ChartSql = new core.model.ChartSQL();
		var sql = this.getContent();
		var SqlScript = new core.model.SqlScript(ChartSql, this.getEditorContent());
		SqlScript.toggleDirective(name);
		this.setEditorContent(SqlScript.getSql());
	}

	/**
	 * Writes the current content of the editor to the file system
	 */
	public function save(){
		variables.content = this.getEditorContent();
		fileWrite(variables.path, this.getEditorContent());
		variables.IsDirty = false;
	}

	/**
	 * Deletes the file from the file system and removes it from the package
	 */
	public function delete() {
		variables.Package.removeSqlFile(this);
		variables.Package.getChartSqlStudio().removeSqlFile(this);
		fileDelete(variables.path);
	}
}