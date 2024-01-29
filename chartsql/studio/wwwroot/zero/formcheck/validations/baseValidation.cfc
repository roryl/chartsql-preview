/**
*/
component {
	variables.is_success = true;
	public function init(){
		return this;
	}

	public function isSuccess(){
		return variables.is_success;
	}

	public function getMessage(){
		return variables.message;
	}

	public function getType(){
		return variables.type;
	}
}