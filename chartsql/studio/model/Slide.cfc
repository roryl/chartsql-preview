/**
 * Represents a Slide on a Story which is one visualization to display
*/
component accessors="true" {

	property name="Id";
	property name="Story";
	property name="FullName";
	property name="Title";
	property name="Order";
	property name="NextSlide" type="optional";
	property name="PreviousSlide" type="optional";

	public function init(
		required Story Story,
		required string FullName,
		string Id = createUUID(),
		string Title = "New Slide"
	){
		variables.Id = Id;
		variables.Story = arguments.Story;
		variables.FullName = arguments.FullName;
		variables.Story.addSlide(this);
		variables.Title = arguments.Title;
		this.setOrder(variables.Story.getSlides().len());
	}

	public function delete(){
		variables.Story.removeSlide(this);
	}

	public function getNextSlide(){

		var Slides = variables.Story.getSlides();
		if(variables.Order < Slides.len()){
			return new optional(Slides[variables.Order + 1]);
		} else {
			return new optional(nullValue())
		}
	}

	public function getPreviousSlide(){
		var Slides = variables.Story.getSlides();
		if(variables.Order > 1){
			return new optional(Slides[variables.Order - 1]);
		} else {
			return new optional(nullValue())
		}
	}



}