/**
 * A collection of slides with charts that we can use to display findings
*/
component accessors="true" {

	property name="Id";
	property name="Package";
	property name="Name";
	property name="Slides" type="array";

	public function init(
		required string name,
		required Package Package,
		required string Id = createUUID()
	){
		variables.id = arguments.Id;
		variables.name = arguments.name;
		variables.Package =	arguments.Package;
		arguments.Package.addStory( this );
		arguments.Package.getChartSQLStudio().addStory( this );
		variables.slides = [];
		return this;
	}

	public function addSlide(
		required Slide Slide
	){
		variables.Slides.append(Slide);
	}

	public Slide function createSlide(
		required string FullName,
		string title,
		string Id = createUUID()
	){
		arguments.Story = this;
		var Slide = new Slide(
			argumentCollection = arguments
		);
		variables.Package.getChartSQLStudio().saveConfig();
		return Slide;
	}

	public function delete(){
		variables.Package.removeStory( this );
		variables.Package.getChartSQLStudio().removeStory( this );
	}

	public optional function findSlideById(required string Id){
		for(var Slide in variables.Slides){
			if(Slide.getId() == arguments.Id){
				return new optional(Slide);
			}
		}
		return new optional(nullValue());
	}

	public optional function findSlideByFullName(required string FullName){
		for(var Slide in variables.Slides){
			if(Slide.getFullName() == arguments.FullName){
				return new optional(Slide);
			}
		}
		return new optional(nullValue());
	}

	public void function removeSlide(required Slide Slide){
		var newSlides = [];
		for(var Slide in variables.Slides){
			if(Slide.getId() != arguments.Slide.getId()){
				newSlides.append(Slide);
			}
		}
		variables.Slides = newSlides;
		variables.Package.getChartSQLStudio().saveConfig();
	}

	public void function setName(required string Name){
		variables.Name = arguments.Name;
		variables.Package.getChartSQLStudio().saveConfig();
	}

}