/**
 * Represents a live browser for an entity
*/
import _vendor.cborm.models.BaseORMService;
component implements="data" {

	public function init(required string entityName){

		//BUILD QUERY/SORTING CRITERIA
		variables.ORM = new BaseORMService(useQueryCaching=false,
		eventHandling=false,
		useTransactions=true,
		defaultAsQuery=false);

		variables.entityName = arguments.entityName;
		variables.Criteria = ORM.newCriteria("product");
		variables.filters = [];

		//Cannot have order by's when calling count on a criteria, so
		//we keep a seperate critera to keep track of the count
		variables.CountCriteria = ORM.newCriteria("product");

		return this;
	}

	public function getCriteria(){
		return variables.Criteria;
	}

	public numeric function count(){

		if(!isNull(variables.countCache)){
			return variables.countCache;
		} else {
			variables.countCache = variables.CountCriteria.count();
			return variables.countCache;
		}
	}

	public void function filter(required string column, required any value){

		switch(arguments.column){
			case "rackRate":
				//eq seems to require a big decimal java class on this value, it does
				//not do the conversion itself
				if(len(arguments.value) gt 0){
					variables.CountCriteria.eq(arguments.column, javaCast("java.math.BigDecimal", arguments.value));
					variables.Criteria.eq(arguments.column, javaCast("java.math.BigDecimal", arguments.value));
				}
			break;

			case "name":
				if(len(arguments.value) gt 0){
					variables.CountCriteria.ilike(arguments.column, "%#arguments.value#%");
					variables.Criteria.ilike(arguments.column, "%#arguments.value#%");
				}
			break;

			case "category":
				if(len(arguments.value) gt 0){
					variables.CountCriteria.ilike(arguments.column, "%#arguments.value#%");
					variables.Criteria.ilike(arguments.column, "%#arguments.value#%");
				}
			break;
		}

		// variables.filters.append({column:arguments.column, value:arguments.value});
	}

	public function sort(required string column, required string direction){
		// structDelete(variables,"countCache");
		variables.Criteria.order(arguments.column, arguments.direction);
	};

	public array function list(required string max=10, required string offset=1){
		return variables.Criteria.list(max=arguments.max, offset=arguments.offset);
	};

	public void function search(required string searchString){

		variables.countCriteria = variables.ORM.newCriteria("product");
		structDelete(variables,"countCache");


		variables.countCriteria.OR(
			Criteria.restrictions.ilike("name","%#arguments.searchString#%"),
			Criteria.restrictions.ilike("category","%#arguments.searchString#%"),
			Criteria.restrictions.ilike("price","%#arguments.searchString#%")
		);
		// structDelete(variables,"countCache");
		variables.Criteria.OR(
			Criteria.restrictions.ilike("name","%#arguments.searchString#%"),
			Criteria.restrictions.ilike("category","%#arguments.searchString#%"),
			Criteria.restrictions.ilike("price","%#arguments.searchString#%")
		);

	}

	public void function whereIdsMatch(array ids){

	}

	public void function orSearchIdsMatch(array ids){

	}

}