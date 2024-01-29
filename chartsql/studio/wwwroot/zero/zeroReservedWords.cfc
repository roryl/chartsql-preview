component {

	property name="words";

	public function init(){
		variables.words = [
			"csrf_token",
			"current_step",
			"delete_key",
			"delete_empty_fields",
			"form_state",
			"goto",
			"goto_before",
			"goto_fail",
			"move_forward",
			"move_backward",
			"preserve_redirect",
			"preserve_map",
			"preserve_request",
			"preserve_response",
			"preserve_form",
			"redirect",
			"resume",
			"start_over",
			"submit_overload",
			"view_state",
			"client_state",
			"fieldnames"
		];
		return this;
	}

	public boolean function has(string checkWord){
		var result = false;
		for(var word in variables.words){
			if(lcase(word) == lcase(checkWord)){
				result = true;
				break;
			}
		}
		return result;
	}

}