/**

*/
component {
	public function init(required string value){

		variables.values = structNew("ordered");

		values["1D"] = {
			start: dateAdd("d", -1, now()),
			end: now()
		}
		values["7D"] = {
			start: dateAdd("d", -7, now()),
			end: now()
		}
		values["14D"] = {
			start: dateAdd("d", -14, now()),
			end: now()
		}
		values["30D"] = {
			start: dateAdd("d", -30, now()),
			end: now()
		}
		values["60D"] = {
			start: dateAdd("d", -60, now()),
			end: now()
		}
		values["90D"] = {
			start: dateAdd("d", -90, now()),
			end: now()
		}
		values["180D"] = {
			start: dateAdd("d", -180, now()),
			end: now()
		}
		values["360D"] = {
			start: dateAdd("d", -360, now()),
			end: now()
		}
		values["TM"] = {
			start: createDate(year(now()), month(now()), 1),
			end: now()
		}
		values["LM"] = {
			start: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), 1),
			end: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), daysInMonth(dateAdd("m", -1, now())))
		}
		values["L3M"] = {
			start: createDate(year(dateAdd("m", -3, now())), month(dateAdd("m", -3, now())), 1),
			end: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), daysInMonth(dateAdd("m", -1, now())))
		}
		values["L6M"] = {
			start: createDate(year(dateAdd("m", -6, now())), month(dateAdd("m", -6, now())), 1),
			end: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), daysInMonth(dateAdd("m", -1, now())))
		}
		values["L12M"] = {
			start: createDate(year(dateAdd("m", -12, now())), month(dateAdd("m", -12, now())), 1),
			end: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), daysInMonth(dateAdd("m", -1, now())))
		}
		values["L24M"] = {
			start: createDate(year(dateAdd("m", -24, now())), month(dateAdd("m", -24, now())), 1),
			end: createDate(year(dateAdd("m", -1, now())), month(dateAdd("m", -1, now())), daysInMonth(dateAdd("m", -1, now())))
		}
		values["TY"] = {
			start: createDate(year(now()), 1, 1),
			end: now()
		}
		values["LY"] = {
			start: createDate(year(dateAdd("yyyy", -1, now())), 1, 1),
			end: createDate(year(dateAdd("yyyy", -1, now())), 12, 31)
		}
		values["L2Y"] = {
			start: createDate(year(dateAdd("yyyy", -2, now())), 1, 1),
			end: createDate(year(dateAdd("yyyy", -1, now())), 12, 31)
		}
		values["2Y"] = {
			start: createDate(year(dateAdd("yyyy", -2, now())), 1, 1),
			end: now()
		}
		values["3Y"] = {
			start: createDate(year(dateAdd("yyyy", -3, now())), 1, 1),
			end: now()
		}
		values["ALL"] = {
			start: createDate(1900, 1, 1),
			end: now()
		}


		variables.value = values[arguments.value];

		return this;
	}

	public function getStart(){
		return variables.value.start;
	}

	public function getEnd(){
		return variables.value.end;
	}

	public function getLinks(required queryStringNew qs, string SliceDatetime){
		var qs = arguments.qs.clone();
		var out = [];
		for(var key in variables.values){

			var qsNew = qs.clone();
			qsNew.setValue("SliceDatetime", key);
			var fields = qsNew.getFields();

			out.append({
				key: key,
				value: qsNew.get(),
				isActive: key == arguments.SliceDatetime?:"",
				params: fields
			});
		}
		// writeDump(out);
		// abort;
		return out;
	}

}