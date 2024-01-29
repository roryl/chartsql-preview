/**
 * Assists in tracking the time it takes to complete various tasks in a request
*/
component accessors="true"{

	property name="ticks";

	public function init(){
		variables.ticks = [];
		variables.start = getTickCount();
		variables.latest = getTickCount();
		variables.lastLogName = "";
		variables.lastLog = {};
		return this;
	}

	public function tick(required string name){
		var current = getTickCount();
		var out = {
			Name:arguments.name,
			SinceLastTrace:current - variables.latest,
			SinceStart: current - variables.start,
		}
		variables.ticks.append(out);
		variables.latest = current;
	}

	public function log(required string name){
		if(arguments.name == variables.lastLogName){
			//closing log
			variables.lastLog.EndTime = getTickCount();
			variables.lastLog.ElapsedTime = variables.lastLog.EndTime - variables.lastLog.StartTime;
			variables.ticks.append(lastLog);
		} else {
			variables.lastLog = {
				Name:arguments.name,
				StartTime:getTickCount()
			}
			variables.lastLogName = arguments.name;
			//opening log
		}
	}

	public function getElapsedTime(){
		return getTickCount() - variables.start;
	}

	public function getStats(){

		// if(variables.lastLog.keyExists("ElapsedTime")){
		// 	variables.ticks.append(variables.lastLog);
		// } else {
		// 	variables.LastLog.ElapsedTime = getTickCount() - variables.lastLog.StartTime;
		// 	variables.ticks.append(variables.lastLog);
		// }
		writeDump(variables.ticks);
		var out = {
			summary:{
				TotalTime:getTickCount() - variables.start
			},
		}
		var totalTime = 0
		for(var ii=1; ii <= variables.ticks.len(); ii++){
			variables.ticks[ii].TotalTime = variables.ticks[ii].EndTime - variables.start;
			// for(jj=ii+1; jj<= variables.ticks.len(); jj++){
			// 	timeAfter += variables.ticks[jj].SinceLastTrace;
			// }
			// variables.ticks[ii].TillEnd = timeAfter;
		}

		out.ticks = variables.ticks;

		out.ticks.prepend({
			Name:"Request Start",
			StartTime: variables.Start,
			ElapsedTime: out.ticks[1].StartTime - variables.Start,
			EndTime: out.ticks[1].StartTime,
			TotalTime:out.ticks[1].StartTime - variables.Start
		})
		return out;
	}

	public function do(string name, func){
		var start = getTickCount();
		arguments.func();
		var end = getTickCount();
		var out = {
			Name:arguments.name,
			StartTime: start,
			EndTime: end,
			ElapsedTime:end - start
		}
		variables.ticks.append(out);
	}
}