/**
 * Data validator for a field name and type that will be use to construct
 * a sql table
*/
component accessors="true" {

	property name="Name";
	property name="Type";
	property name="IsPrimary";
	property name="IsAutoIncrement";
	property name="IsNotNull";
	property name="IsUnique";
	property name="IsUnsigned";
	property name="IsZeroFill";
	property name="DefaultValue";
	property name="Comment";


	public function init(
		required string name,
		required string type,
		boolean isPrimary = false,
		boolean isAutoIncrement = false,
		boolean isNotNull = false,
		boolean isUnique = false,
		boolean isUnsigned = false,
		boolean isZeroFill = false,
		string defaultValue = "",
		string comment = ""
	){
		this.setName( arguments.name );
		this.setType( arguments.type );
		this.setIsPrimary( arguments.isPrimary );
		this.setIsAutoIncrement( arguments.isAutoIncrement );
		this.setIsNotNull( arguments.isNotNull );
		this.setIsUnique( arguments.isUnique );
		this.setIsUnsigned( arguments.isUnsigned );
		this.setIsZeroFill( arguments.isZeroFill );
		this.setDefaultValue( arguments.defaultValue );
		this.setComment( arguments.comment );
		return this;
	}
}