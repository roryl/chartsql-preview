import zerotable.model.zeroTable;
import zerotable.model.arrayData;
import zerotable.model.entityData;
import zerotable.model.column;
component accessors="true" {    
	
	/**
	 * Controller constructor, receives an instance of Application.cfc as fw
	 * @param  {component} fw An instance of the Application.cfc
	 * @return {component}    An instance of this controller
	 */
	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	/**
	 * Lists a collection of the current resource 
	 * @return {struct} The data for the list view
	 */
	/**
	 * Lists a collection of the current resource 
	 * @return {struct} The data for the list view
	 */
	public struct function list(				
								max=10,
								more=0,
								page=1,
								offset="1",
								sort="name",
								direction="asc",								
								goto_page,
								search,
								edit_col="",
								edit_id="",
								cacheKey=createUUID(),
								errors){
		// writeDump(arguments);
		// abort;
		// 
		// if(arguments.keyExists("errors")){
		// 	writeDump(arguments);
		// 	abort;
		// }

		// var sort = replaceNoCase(arguments.sort,"_", "", "all");
		// var edit_col = replaceNoCase(arguments.sort,"_", "", "all");
		
		

		
		getCaseSensitivePropertyName = function(name){

			var properties = getMetaData(entityNew("product")).properties;
			var noUnderscore = replaceNoCase(name,"_","","all");
			for(var prop in properties){
				if(lcase(prop.name) == lcase(name) OR lcase(prop.name) == lcase(noUnderscore)){
					return prop.name;
				}
			}
		};

		//Create an entity data object
		var entityData = new entityData("product");

		//Create a zero table
		zeroTable = new zeroTable(rows=entityData, 
								  max=arguments.max,
								  more=arguments.more, 
								  offset=arguments.offset, 
								  basePath="/zerotable/main",
								  useZeroAjax=true);		

		
		
		zeroTable.addColumn(new column(columnName="id", isPrimary=true, wrap='<a href="/zerotable/main/{{value}}">{{value}}</a>'));			

		zeroTable.addColumn(new column(	columnName="name", 
										editable=true));

		zeroTable.addColumn(new column(	columnName="rack_rate", 
										friendlyName="rack rate", 
										dataName="rackRate", 
										editable=true));


		zeroTable.addColumn(new column(columnName="category",
									   wrap='<span style="color:red;">{{value}}</span>',
									   editable=true, 
									   columnType= {
									   		select:true,
									   		options:[
												{id:"Shoes",name:"Shoes"},
												{id:"Gloves",name:"Gloves"},
												{id:"Accessories",name:"Accessories"},
											]
										},
										filter:[
											{id:"Shoes",name:"Shoes"},
											{id:"Gloves",name:"Gloves"},
											{id:"Accessories",name:"Accessories"},
										]
							)
		);

		zeroTable.addColumn(new column(	columnName="price", 
										editable=true));

		zeroTable.addColumn(new column(	columnName="isActive", 
										editable=true, 
										columnType={
											checkbox:true
										}
		));

		zeroTable.addColumn(new column(columnName="actions:", 
									   columnType = {
									        "custom":true,
									        "output":function(row){
									        	// writeDump(row);									        	
									        	var out = '
													<form action="/zerotable/main/#row.id#/delete" method="post" style="display:inline;">
							  							<input type="hidden" name="goto" value="/zerotable/main" />
							  							<button class="btn btn-primary btn-xs">delete</button>
							  						</form>
							  						<form action="/zerotable/main/#row.id#/hide" method="post" style="display:inline;">
							  							<input type="hidden" name="goto" value="/zerotable/main" />
							  							<button class="btn btn-primary btn-xs">hide</button>
							  						</form>
									        	'; 
									        	return out;
									        }
									   }
		));


		if(arguments.keyExists("search") and search != ""){
			zeroTable.search(arguments.search);
		}

		//Set the sort for the table
		zeroTable.sort(sort,direction);		

		//Set a colum and row to edit if need be
		if(edit_id >= 0 and edit_col != ""){

			if(arguments.keyExists("errors") and arguments.errors.keyExists(edit_col)){
				zeroTable.edit(columnName=edit_col, rowId=edit_id, errorMessage=arguments.errors[edit_col].message);					
			} else {
				zeroTable.edit(columnName=edit_col, rowId=edit_id);							
			}

		}

		if(arguments.keyExists("goto_page") and goto_page != ""){
			var pagination = zeroTable.getPagination();
			var page = pagination.findPageById(arguments.goto_page).elseThrow("That is not a valid page");
			location url="#page.getLink()#" addtoken="false";
			// writeDump(page);
			// abort;
		}

		//Serialize zeroTable for the view
		// var zeroTableOut = variables.fw.serialize(zeroTable, {
		// 	rows:{

		// 	},
		// 	columns:{
		// 		filter:{}
		// 	},
		// 	primaryColumn:{},
		// 	pagination:{				
		// 		firstPage:{},
		// 		lastPage:{},
		// 		currentPage:{},
		// 		nextPage:{},
		// 		previousPage:{},				

		// 	},
		// 	currentParams:{}
		// });

		
		var zeroTableOut = zeroTable.toJson();
			
		

		
		var out = {
			"success":true,
			"data":zeroTableOut
		}	

		

		// writeDump(out);		
		// abort;
		return out;
	}

	/**
	 * A controller function to validate a new entity
	 * @return {struct} The data for the new entity
	 */
	public struct function validate() {
		return {};
	}	

	/**
	 * A controller function to represent a new form
	 * @return {struct} The data for the new view
	 */
	public struct function new() {
		return {};
	}	

	/**
	 * A controller function to represent a an edit form
	 * @return {struct} The data for the edit view
	 */
	public struct function edit( required id ) {
		return {};
	}

	/**
	 * Creates an item at the current resource
	 * @return {struct} The data for the create view
	 */
	public struct function create() {
		return {};
	}

	/**
	 * Reads an item at the current resource
	 * @return {struct} The data for the read view
	 */
	public struct function read( required id ) {

		var Zero = fw.getZeroModel();
		var Product = Zero.getProductById(arguments.id)?:throw("could not load that product");
		var out = {
			"success":true,
			"data":variables.fw.serialize(Product)
		}
		return out;
	}

	/**
	 * Updates an item at the current resource
	 * @return {struct} The data for the update view
	 */
	public struct function update( required id,
								   notEmpty name,
								   category,
								   notZeroInteger price,
								   rackRate,
								   isActive ) {

		variables.cacheKey = createUUID();
		var Zero = fw.getZeroModel();
		var Product = Zero.getProductById(arguments.id)?:throw("could not load that product");
		transaction {
			if(arguments.keyExists("name")){Product.setName(name.toString())};
			if(arguments.keyExists("category")){Product.setCategory(category)};
			if(arguments.keyExists("price")){Product.setprice(price.toString())};
			if(arguments.keyExists("rackRate")){Product.setRackRate(rackRate)};

			arguments.keyExists("isActive") AND isActive ? Product.setIsActive(isActive) : Product.setIsActive(false);
			ORMFlush();
			transaction action="commit";
		}
		// writeDump(arguments);
		// writeDump(Product);
		// abort;

		return {};
	}

	/**
	 * Deletes an item at the current resource
	 * @return {struct} The data for the delete view
	 */
	public struct function delete( required id ) {
		var Zero = fw.getZeroModel();
		var Product = Zero.getProductById(arguments.id)?:throw("could not load that product");
		transaction {
			Zero.deleteProduct(Product);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			success:true,
			message:"product successfully deleted"
		}
		return out; 
	}

	/**
	 * Links two resources together 
	 * @return {struct} The data for the linked resource
	 */
	public struct function link( required id ){
		return {};
	}

	/**
	 * Unlinks two resources
	 * @return {struct} The data for the linked resource
	 */
	public struct function unlink( required id ){
		return {};
	}

	/**
	 * Function to override the request scope variables for this controller
	 * @param  {struct} rc The request context, the URL and FORM variables passed into the app
	 * @return {struct}    The update RC scope which will be used to find variables for the controllers
	 */
	public struct function request( required struct rc, required struct headers ){
		return rc;
	}

	/**
	 * A function to override all controller function responses, for example to decorate with extra information on every call
	 * @param  {struct} required struct        controllerResult Will receive the result of the controller method (list, create, read etc)
	 * @return {struct}          Should return the updated controller result
	 */
	public struct function result( required struct controllerResult ){
		return controllerResult;
	}	
}
