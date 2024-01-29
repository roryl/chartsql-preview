/**
 * Represents a pagination
*/
component accessors="true" {

	property name="currentPage"; //
	property name="dir" setter="false";
	property name="firstPage" setter="false"; //
	property name="hasNextPage" setter="false"; //
	property name="hasPreviousPage" setter="false"; //
	property name="isFirstPage" setter="false"; //
	property name="isLastPage" setter="false"; //
	property name="lastPage" setter="false"; //
	property name="max" setter="false"; //
	property name="nextPage" setter="false"; //
	property name="offset" setter="false";
	property name="pages" setter="false"; //
	property name="previousPage" setter="false"; //
	property name="search" setter="false";
	property name="sort" setter="false";
	property name="summaryPages" setter="false";
	property name="totalItems" setter="false"; //
	property name="totalPages" setter="false"; //


	public function init(required data data, required numeric max=10, required numeric offset, required numeric showMaxPages, required zeroTable zeroTable){
		variables.data = arguments.data;
		if(arguments.max == 0){
			variables.max = getTotalItems();
		} else {
			variables.max = arguments.max;
		}
		variables.offset = arguments.offset;
		variables.zeroTable = arguments.zeroTable;
		variables.showMaxPages = arguments.showMaxPages;

		return this;
	}

	public optional function findPageById(required numeric id){
		if(arguments.id > getTotalPages()){
			return new Optional();
		} else {
			return new optional(getPage(arguments.id));
		}
	}

	public page function getFirstPage(){
		return getPage(1);
	}

	public page function getCurrentPage(offset=variables.offset,
										max=variables.max){

		if(offset <= 0){
			var pageId = 1;
		}

		if(offset > getTotalItems()){
			var pageId = getTotalPages();
		}

		var pageId = (variables.offset + variables.max) / variables.max;
		if(pageId < 1){
			pageId = 1
		} else {
			pageId = int(pageId);
		}
		return getPage(pageId);

	}

	public function getHasLastPage(){return hasLastPage();}
	public function getHasNextPage(){return hasNextPage();}
	public function getHasPreviousPage(){return hasPreviousPage();}
	public function getIsLastPage(){return isLastPage();}
	public function getIsFirstPage(){return isFirstPage();}

	public page function getLastPage(){
		return getPage(getTotalPages());
	}

	public void function setCurrentPage(required page page){
		// abort;
		variables.offset = arguments.page.getOffset();
	}

	// public function setCurrentPage(){
	// 	return "foo";
	// }

	public optional function getNextPage(){

		if(getCurrentPage().equals(getLastPage())){
			return new optional();
		} else {
			return new optional(getPage(getCurrentPage().getId() + 1));
		}
	}

	public page[] function getPages(totalPages=this.getTotalPages(),
									totalItems=this.getTotalItems(),
									offset=variables.offset,
									max=variables.max) {
		/**
		 * Building the pages takes a long time, so we cache this value so that subsequent
		 * requests to getPages returns the existing array
		 */
		if(structKeyExists(variables,"zeroCachePages")){
			return variables.zeroCachePages;
		} else {

			var out = [];

			var startIndex = 1;
			var endIndex = max;

			var isCurrentPage = false;

			for(var i=0; i LT arguments.totalPages; i++){

				pageOffset = i * max;
				startIndex = (i * max) + 1;
				endIndex = (i + 1) * max;

				if(offset >= pageOffset and offset < endIndex){
					isCurrentPage = true;
				} else {
					isCurrentPage = false;
				}

				out.append(new page(id=i+1,
									link=getCleanedPaginationQueryString().getNew().setValues({"#zeroTable.getFieldNameWithTablePrefix("offset")#":pageOffset}).get(),
									startIndex=startIndex,
									endIndex=endIndex,
									isCurrentPage=isCurrentPage,
									offset=pageOffset)
				);
			}
			// writeDump(out);
			variables.zeroCachePages = out;
			return out;
		}
	}

	private Page function getPage(pageId,
								  max=variables.max,
								  offset=variables.offset
								  ){

		if(pageId == 1){
			var pageOffset = 0;
		} else {
			var pageOffset = (pageId - 1) * max;
		}


		if(pageId == 1){
			var startIndex = 1;
		} else {
			var startIndex = ((pageId - 1) * max) + 1
		}

		var endIndex = pageId * max;

		if(offset >= pageOffset and offset < pageOffset + max){
			isCurrentPage = true;
		} else {
			isCurrentPage = false;
		}

		/*
		If the total showing amount is greater than the total items,
		then we want the endindex to match the total items, this is
		so that "showing from 1 to 4 of 4 items" appears correctly instead of
		"showing 1 to 4 of 10 time" like in the past
		*/
		var totalItems = this.getTotalItems();
		if(endIndex > totalItems){
			endIndex = totalItems;
		}

		var page = new page(id=arguments.pageId,
									link=getCleanedPaginationQueryString().getNew().setValues({"#zeroTable.getFieldNameWithTablePrefix("offset")#":pageOffset}).get(),
									startIndex=startIndex,
									endIndex=endIndex,
									isCurrentPage=isCurrentPage,
									offset=pageOffset);

		return page;
	}

	/*
	Removes variables from the query string which are never used in pagination
	 */
	private queryStringNew function getCleanedPaginationQueryString(){
		var qs = variables.zeroTable.getQueryString().getNew().delete(zeroTable.getFieldNameWithTablePrefix("edit_col"))
							 .delete(zeroTable.getFieldNameWithTablePrefix("edit_id"));

		return qs;
	}

	/**
	 * Returns a subset of the pages to display in the view which is more user friendly
	 * when there are a lot of pages to return
	 * @return {[type]} [description]
	 */
	public page[] function getSummaryPages(){
		// var pages = getPages();
		var out = [];
		if(variables.showMaxPages > 0){
			var half = int(variables.showMaxPages / 2);
			// writeDump(half);
			var min = getCurrentPage().getId() - half;
			// writeDump(min);
			// abort;
			var diff = 1;
			if(min <= 0){
				diff = abs(half - min) - 1;
				min = 1;
			}

			// writeDump(min);
			var max = getCurrentPage().getId() + half + diff;
			// writeDump(max);
			if(max > getTotalPages()){
				var diff = abs(max - getTotalPages());
				max = getTotalPages();


				min = min - half;
				if(min <= 0){
					min = 1;
				}
			}

			try {

				var out = [];
				for(var i=min; i LTE max; i++){
					if(out.len() == variables.showMaxPages){
						break;
					}
					out.append(getPage(i));
				}

			}catch(any e){

				writeDump(min);
				writeDump(max);
				writeDump(getTotalPages());
				writeDump(pages);
				writeDump(e);
				abort;
			}
		}
		return out;
	}

	public optional function getPreviousPage(){

		if(getCurrentPage().equals(getFirstPage())){
			return new optional();
		} else {
			return new optional(getPage(getCurrentPage().getId() - 1));
		}
	}

	public function getTotalItems(){
		return variables.data.count();
	}

	public numeric function getTotalPages(totalItems=this.getTotalItems(), max=variables.max) {
		var ceiling = ceiling(arguments.totalItems / arguments.max);
		if(ceiling == 0){
			ceiling = 1;
		}
		return ceiling;
	}

	public boolean function hasNextPage(){
		return getNextPage().exists();
	}

	public boolean function hasPreviousPage(){
		return getPreviousPage().exists();
	}

	public boolean function isFirstPage(){
		return getCurrentPage().equals(getFirstPage());
	}

	public boolean function isLastPage(){
		return getCurrentPage().equals(getLastPage());
	}

	/**
	 * Moves the pagination forward to the next page, or the last
	 * page if it is already there
	 * @return {Function} [description]
	 */
	public void function next(){
		if(getNextPage().exists()){
			setCurrentPage(getNextPage().get());
		}
	}

	public void function previous(){
		if(getPreviousPage().exists()){
			setCurrentPage(getPreviousPage().get());
		}
	}

	public function toJson(){

		var out = {
			"current_page":pageToJson(getcurrentPage()),
			// "dir":getdir(),2021-08-12: Removed as I don't think this does anything
			"first_page":pageToJson(getfirstPage()),
			"has_next_page":gethasNextPage(),
			"has_previous_page":gethasPreviousPage(),
			"is_first_page":getisFirstPage(),
			"is_last_page":getisLastPage(),
			"last_page":pageToJson(getlastPage()),
			"max":getmax(),
			"next_page":pageToJson(getnextPage()),
			"offset":getoffset(),
			"previous_page":pageToJson(getpreviousPage()),
			"search":getsearch(),
			"sort":getsort(),
			"summary_pages":pagesToJson(getsummaryPages()),
			"total_items":gettotalItems(),
			"total_pages":gettotalPages(),
			// "pages":pagesToJson(getpages()),
		}

		return out;
	}

	private function pageToJson(required any page){
		if(isInstanceOf(arguments.page, "optional")){
			if(page.exists()){
				var page = page.get();
			} else {
				return "";
			}
		}
		return page.toJson();
	}

	private array function pagesToJson(required array pages){
		var out = [];
		for(var page in pages){
			out.append(page.toJson())
		}
		return out;
	}

}