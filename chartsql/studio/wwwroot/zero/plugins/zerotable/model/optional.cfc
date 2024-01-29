/**
 * Optional.cfc

 * Implements an Optional class inspired Java's optional. This is useful when particularly calling ORM objects and we want to be able to
 * pass the NULL reference to future objects which may check
 * @author Rory Laitila
 * @date 2/18/2016
 **/
component {

    public function init(value,key){
        
        if(structKeyExists(arguments,"key") AND !isNull(arguments.key)){
            if(structKeyExists(arguments.value, arguments.key) AND !isNull(arguments.value[key])){
                variables.value = arguments.value[arguments.key];
                return this;
            } else {
                return this;
            }
        }

        if(isClosure(arguments.value)){
            try {
                variables.value = arguments.value();
                return this;
            } catch (any e){
                //No nothing.
                return this;
            }
        }

        if(!isNull(arguments.value)){
            variables.value = arguments.value;
            return this;
        }
        return this;
    }

    /**
    * Used to check if the value exists or is null
    */
    public boolean function Exists(){
        if(!isNull(variables.value)){
            return true;
        } else {
            return false;
        }
    }

    /**
    * Executes a passed in function or returns the passed value if the object exists. Useful to shorthand:
    * object = new Object();
    * if(!iNull(object)){
    *    //doSomething
    * }
    * The values passed to if can be a value, or a closure which returns a value
    */
    public any function if(required any if){
        if(Exists()){
            return getOrCallValue(arguments.if);
        }
    }

    /*
    * Will get the value of the optional or throw an error if it does not exists. Typical usage will be to check
    * exists() first before calling get()
    */
    public any function get(){
        if(Exists()){
            return variables.value;
        } else {
            throw "Object was null, cannot return. Use Exists to check if the Optional value exists";
        }
    }

    /*
    * Allow defining two closures which will be executed if the optional value
    * exists or does not exist. Short hand for
    *
    * object = new Object();
    * if(!isNull(object()){
    *   //Do something if null
    * } else {
    *   //Do something if not null
    * }
    * The values passed to ifElse can be a value, or a closure which returns a value
    */
    public any function ifElse(required any if, required any else){
        if(Exists()){
            return getOrCallValue(arguments.if);
        } else {
            return getOrCallValue(arguments.else);
        }
    }

    /*
    * Returns the value if it exists otherwise throws the passed message
    */
    public any function elseThrow(message){
        if(Exists()){
            return get();
        } else {
            throw arguments.message;
        }
    }

    /*
    * Returns the passed value whether or not the Optional is NULL. The value passed
    * to or can be a value, or a closure which returns a value
    */
    public any function or(required any other){
        if(Exists()){
            return getOrCallValue(arguments.other);
        } else {
            return getOrCallValue(arguments.other);
        }
    }

    /*
    * Returns the Optional value if it is not Null, or returns the passed in value
    * if the Optional is NULL. The value passed to else can be a value, or a
    * closure which returns a value
    */
    public any function else(required any other){
        if(Exists()){
            return get();
        } else {
            return getOrCallValue(arguments.other);
        }
    }

    /*
    * Equats two Optionals to each other, possible outcomes
    * Both Null - true
    * Both Have the same Value - true
    * One Null, and one Has Value - false
    * Both have different Values - false
    */
    public boolean function equals(required Optional value){

        var testValue = arguments.value;
        if(!isInstanceOf(testValue, "Optional")){
            throw "The value being checked is not of Type optional, so it cannot be compared"
        }

        if(testValue.exists() AND this.Exists()){
            if(testValue.get() === this.get()){
                return true;
            } else {
                return false;
            }
        }

        if(!testValue.Exists() AND !this.Exists()){
            return true;
        }

        return false;
    }

    /**
    * Function to return the passed value, or execute the closure if provided
    */
    private any function getOrCallValue(required any value){
        var value = arguments.value;
        if(isClosure(value)){
            if(exists()){
                return arguments.value(variables.value);
            } else {
                return arguments.value();
            }

        } else {
            return arguments.value;
        }
    }

}
