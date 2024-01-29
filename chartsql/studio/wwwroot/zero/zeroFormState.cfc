component accessors="true" {

	property name="name";
	property name="currentStep";
	property name="steps";
	property name="state";
	property name="stepsOrder";
	property name="formData";
	property name="complete";
	property name="formStateUrl";

	public function init(	required steps,
							string name,
							required struct clientStorage,
							){

		variables.complete = false;
		variables.clientStorage = arguments.clientStorage;

		variables.steps = listToArray(arguments.steps);

		clientStorage.form_state = arguments.steps;

		if(arguments.keyExists("name")){
			variables.name = arguments.name;
			clientStorage.form_state_name = arguments.name;
		} else {
			variables.name = hash(toString(arguments.steps));
			clientStorage.form_state_name = variables.name;
		}

		// clientStorage.put("form_state", arguments.steps);
		reloadFromCache();
		// writeDump(this);abort;
		return this;
	}

	public function serialize(){
		return "foo";
	}

	public function toString(){
		return "foo";
	}

	/*
	CACHE FUNCTIONS
	 */
	public void function clearFormData(){
		variables.formData = {};
		variables.state[variables.currentStep].form_data = {};
		saveCurrentState();
		// clientStorage.getValues().form_cache[variables.name].form_data = {};
	}

	public void function clearStepData(){
		if(isFirst(variables.currentStep)){
			clearFormData();
		} else {
			variables.state[variables.currentStep].form_data = {};
			variables.formData = variables.state[previousStep(variables.currentStep)].form_data;
		}
		saveCurrentState();
		reloadFromCache();
	}

	public void function completeStep(step=variables.currentStep){

		var order = getStepsOrder();
		var max = order[step];

		//Set all the prior steps to complete
		for(var i = 1; i <= max; i++){
			setState(step:"#steps[i]#", show:true, complete:true);
		}

		//Set the form data for this step
		setState(step:steps[max], show:true, complete:true, formData:variables.formData);

		if(isLast(step)){
			variables.complete = true;
			variables.currentStep = step;
		} else {
			//Set the step after this one to show
			setState(step:steps[max+1], show:true, complete:false, formData:{});
			var end = arrayLen(steps);

			//Set anything after the next step to false
			for(var i = max + 2; i <= end; i++){
				setState(step:"#steps[i]#", show:false, complete:false, formData:{});
			}
			variables.currentStep = steps[max+1];
		}

		saveCurrentState();
	}

	public void function completeForm(){
		lastStep = variables.steps[arrayLen(variables.steps)];
		completeStep(lastStep);
		deleteFormCache();
	}

	public void function deleteFormCache(){
		structDelete(clientStorage.form_cache, variables.name);
		structDelete(clientStorage,"form_state");
		structDelete(clientStorage,"form_state_name");
	}

	public void function first(){
		restoreStep(steps[1]);
	}

	public struct function getFormCache(){
		return clientStorage.form_cache[variables.name];
	}

	public boolean function getIsStarted(){
		return !structIsEmpty(variables.state)
	}

	public struct function getStepsOrder(){

		if(!variables.keyExists("stepsOrder")){
			var out = {};
			var step = "";
			var i = "";
			loop array="#variables.steps#" item="step" index="i"{
				out[step] = i;
			}
			variables.stepsOrder = out;
		}
		return variables.stepsOrder;
	}

	public boolean function hasFormCache(){
		if(!clientStorage.keyExists("form_cache")){
			clientStorage.form_cache = {};
		}
		return clientStorage.form_cache.keyExists(variables.name);
	}

	public boolean function hasSteps(required string steps){
		return lcase(arrayToList(variables.steps)) == lcase(arguments.steps);
	}

	public boolean function isAfter(step){
		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId > expectedId){
			return true;
		} else {
			return false;
		}
	}

	public boolean function isAtFirst(){
		return isFirst(variables.currentStep);
	}

	public boolean function isAtLeast(step){

		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId >= expectedId){
			return true;
		} else {
			return false;
		}
	}

	public boolean function isBefore(step){

		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId < expectedId){
			return true;
		} else {
			return false;
		}
	}

	public boolean function isFirst(step){
		return getStepsOrder()[step] == 1;
	}

	public boolean function isLast(step){
		return getStepsOrder()[step] == arrayLen(variables.steps);
	}

	public function isValidStep(step){
		return arrayFindNoCase(variables.steps, step);
	}

	public void function last(){
		var lastStep = variables.steps[arrayLen(variables.steps)];
		var stepBeforeLast = previousStep(lastStep);
		completeStep(stepBeforeLast);
	}

	/*
	Will test the passed in URL against the formStateUrl
	contained within this instance of the form state. This is
	used by Zero to determine if the form state is valid
	for the current URL.
	*/
	public boolean function matchesURL(required string uri){
		var match = reMatchNoCase(variables.formStateUrl, arguments.uri);
		if(arrayLen(match) > 0){
			return true;
		} else {
			return false;
		}
	}

	public void function moveForward(){
		completeStep(variables.currentStep);
	}

	public void function moveBackward(clearStepData=false){

		if(isFirst(variables.currentStep)){
			start(true);
		} else {
			restoreStep(previousStep(variables.currentStep));
			if(clearStepData){
				this.clearStepData();
				// if(isFirst(previousStep(variables.currentStep))){
				// 	start(true);
				// } else {
				// 	restoreStep(previousStep(previousStep(variables.currentStep)));
				// 	completeStep();
				// }

			}
		}
	}

	public string function nextStep(step){
		return steps[getStepsOrder()[step] + 1];
	}

	public string function previousStep(step){
		return steps[getStepsOrder()[step] - 1];
	}

	public void function resetFormCache(){
		clientStorage.form_cache[variables.name] = {
			steps:variables.steps,
			name:variables.name,
			current_step:variables.currentStep?:variables.steps[1],
			state:variables.state?:{},
			form_data:{},
			complete:false,
		};
	}

	public void function reloadFromCache(){
		if(!hasFormCache()){
			resetFormCache();
		}
		var cache = getFormCache();
		variables.steps = cache.steps?:variables.steps;
		variables.name = cache.name?:variables.name;
		variables.currentStep = cache.current_step?:variables.currentStep?:variables.steps[1];
		variables.state = cache.state?:variables.state?:{};
		variables.formData = cache.form_data?:{};
		variables.complete = cache.complete?:false;
		variables.formStateUrl = cache.form_state_url?:"";
	}

	public void function restoreStep(step){
		var order = getStepsOrder();
		var max = order[step];

		variables.currentStep = step;
		variables.formData = variables.state[step].form_data;
		//Set the form data for this step
		setState(step:step, show:true, complete:false, formData:variables.formData);

		//Set all later steps to not show and now completed, and clear their form data
		var end = arrayLen(steps);
		for(var i = max + 1; i <= end; i++){
			setState(step:"#steps[i]#", show:false, complete:false, formData:{});
		}

		saveCurrentState();
	}

	public void function resume(name){

		var name = arguments.name;

		if(!hasFormCache()){
			start();
			// throw("Could not load the form state #name#")
		} else {
			var resumeForm = clientStorage.form_cache[name];
			variables.name = resumeForm.name;
			clientStorage.form_state_name = variables.name;
			reloadFromCache();

			if(!getIsStarted()){
				start();
			}
		}
	}


	public void function saveCurrentState(){
		saveStateKeyValue("steps", variables.steps);
		saveStateKeyValue("name", variables.name);
		saveStateKeyValue("current_step", variables.currentStep);

		for(var step in variables.state){
			if(step == variables.currentStep){
				variables.state[step].is_current_step = true;
			} else {
				variables.state[step].is_current_step = false;
			}
		}

		saveStateKeyValue("state", variables.state);
		saveStateKeyValue("complete", variables.complete);
		saveStateKeyValue("form_data", variables.formData);
		saveStateKeyValue("form_state_url", variables.formStateUrl);
	}

	public void function saveStateKeyValue(key, value){
		if(!hasFormCache()){
			resetFormCache();
		}

		var formCache = getFormCache();
		formCache[key] = value;
	}

	public void function setFormData(required struct formData){
		if(!hasFormCache()){
			resetFormCache();
		}

		if(!structKeyExists(clientStorage.form_cache[variables.name], "form_data")){
			clientStorage.form_cache[variables.name].form_data = {};
		}

		var reservedWords = new zeroReservedWords();
		var fieldsToSave = {};

		for(var key in formData){

			// Although view_state is a reserved word, when using the form state,
			// we want to save view_state during any POST requests (or calls to setFormData)
			// This is so that the view_state can be persisted on the next request
			if(lcase(key) == "view_state" OR !reservedWords.has(key)){
				fieldsToSave.insert(key, formData[key], true);
			}
		}
		variables.formData = fieldsToSave;
		saveCurrentState();
		reloadFromCache();
	}

	public function setFormStateUrl(required string uri){
		variables.formStateUrl = arguments.uri;
		saveStateKeyValue("form_state_url", variables.formStateUrl);
	}

	/*
	FORM FUNCTIONS
	 */
	public void function setState(required string step, required boolean show, required boolean complete, struct formData){
		// writeDump(arguments);
		if(!variables.state.keyExists(step)){
			variables.state[step] = {}
		}

		variables.state[step].append({show:show, complete:complete});

		if(arguments.keyExists("formData")){
			variables.state[step].form_data = duplicate(arguments.formData);
		}
	}

	public void function start(clearCache=true){
		variables.currentStep = steps[1];
		if(clearCache){
			resetFormCache();
		}

		var order = getStepsOrder();
		var steps = variables.steps;

		setState(step:steps[1], show:true, complete:false, formData:{});

		for(var i = 2; i <= arrayLen(steps); i++){
			setState(step:"#steps[i]#", show:false, complete:false, formData:{});
		}

		variables.complete = false;
		saveCurrentState();

	}



}