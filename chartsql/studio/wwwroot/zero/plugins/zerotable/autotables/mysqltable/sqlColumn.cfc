/**
* Data Transfer Object representing the actual table column
* in a source or audit table
*/
component accessors="true"{

	property name="name" setter="false";
	property name="type" setter="false";
	property name="allowNull" setter="false";
	property name="key" setter="false";
	property name="default" setter="false";
	property name="extra" setter="false";

	public function init(
		required string name,
		required string type,
		required boolean allowNull,
		required string key,
		required string default,
		required string extra
	){

		variables.name = arguments.name;
		variables.type = arguments.type;
		variables.allowNull = arguments.allowNull;
		variables.key = arguments.key;
		variables.default = arguments.default;
		variables.extra = arguments.extra;
		return this;
	}

	public function equals(required component column){
		if(
			this.getName() == column.getName() AND
			this.getType() == column.getType() AND
			this.getAllowNull() == column.getAllowNull() AND
			this.getKey() == column.getKey() AND
			this.getDefault() == column.getDefault() AND
			this.getExtra() == column.getExtra()
		) {
			return true;
		} else {
			return false;
		}
	}

	public boolean function getIsPrimary(){
		return this.getKey() == "PRI";
	}
}