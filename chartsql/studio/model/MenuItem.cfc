/**
 * Tracks a menu item that can be added to the menu bar
*/
component accessors="true" {

	property name="ChartSQLStudio" type="ChartSQLStudio";
	property name="Name" type="String";
	property name="IconClass" type="String";
	property name="Link" type="String";
	property name="Location" type="String";
	property name="Parent" type="MenuItem";
	property name="Children" type="array";
	property name="HasChildren" type="boolean" setter="false";
	property name="Tooltip" type="string";

	public function init(
		required String Name,
		required String IconClass,
		ChartSQLStudio ChartSQLStudio,
		MenuItem Parent,
		string Link,
		string Tooltip,
		string Location = 'top'
	){

		if(!structKeyExists(arguments, "Parent") and !structKeyExists(arguments, "ChartSQLStudio")){
			throw("You must pass either a parent or ChartSQLStudio to the MenuItem constructor");
		}

		variables.Name = arguments.Name;
		variables.IconClass = arguments.IconClass;
		variables.Children = [];

		if (structKeyExists(arguments, "Link")){
			variables.Link = arguments.Link;
		}

		if (structKeyExists(arguments, "parent")){
			variables.parent = arguments.parent;
			arguments.parent.addChild(this);
		}

		if (structKeyExists(arguments, "ChartSQLStudio")){
			variables.ChartSQLStudio = arguments.ChartSQLStudio;
			variables.ChartSQLStudio.addMenuItem(this);
		}

		if (structKeyExists(arguments, "Tooltip")){
			variables.Tooltip = arguments.Tooltip;
		}

		if (!structKeyExists(arguments, "Location") || isNull(arguments.Location)){
			// Make 'top' location default if no Location is present
			variables.Location = 'top';
		}

		if(structKeyExists(arguments, "Location")){
			if (!["top", "bottom"].contains(arguments.Location)) {
				throw("MenuItem location should be either 'top' or 'bottom', instead got '#arguments.Location#'");
			}
			variables.Location = arguments.Location;
		}
		return this;
	}

	public function addChild(required MenuItem Child){
		if(!this.findChildMenuItemByName(Child.getName()).exists()){
			arrayAppend(variables.Children, Child);
		}
	}

	/**
	 * Utility function to count the number of items in a collection from this instance
	 *
	 * @collection
	 */
	public function count(required string collection){
		return variables[collection].len();
	}

	public optional function findChildMenuItemByName(
		required string name
	){
		for(var MenuItem in variables.Children){
			if(MenuItem.getName() == arguments.name){
				return new optional(MenuItem);
			}
		}
		return new optional(nullValue());
	}

	public function getHasChildren(){
		return variables.Children.len() > 0;
	}
}