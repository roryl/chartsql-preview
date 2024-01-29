/**
 * Represents an individual page
*/
component accessors="true" {

	property name="id" setter="false";
	property name="link" setter="false";
	property name="startIndex" setter="false";
	property name="endIndex" setter="false";
	property name="isCurrentPage";
	property name="offset";

	public function init(required numeric id, required string link, required numeric startIndex, required numeric endIndex, required boolean isCurrentPage, numeric offset){
		variables.id = arguments.id;
		variables.link = arguments.link;
		variables.startIndex = arguments.startIndex;
		variables.endIndex = arguments.endIndex;
		variables.isCurrentPage = arguments.isCurrentPage;
		variables.offset = arguments.offset;
		return this;
	}

	public function equals(required page page){
		if(variables.id == arguments.page.getId()){
			return true;
		} else {
			return false;
		}
	}

	public function toJson(){
		var out = {
			"end_index":this.getEndIndex(),
			"id":this.getId(),
			"is_current_page":this.getIsCurrentPage(),
			"link"=this.getLink(),
			"start_index":this.getStartIndex(),
		}
		return out;
	}
}