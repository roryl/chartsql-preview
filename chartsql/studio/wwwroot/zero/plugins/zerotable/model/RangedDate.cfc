/**
* Utility class to work with a date and determine if it is within
* one of the predefined ranges
*/
component {
    processingdirective preservecase="true";

	public function init(date date = now()){
        variables.date = arguments.date;
        variables.ranges = this.getRanges();
        return this;
    }

    public function hasRange(required any key){
		if(isStruct(arguments.key)){
			if(isDate(arguments.key.start?:"") or isDate(arguments.key.end?:"")){
				return true;
			}
		} else {
			return structKeyExists(variables.ranges, arguments.key);
		}
    }

    public function getRange(required any key){
		if(isStruct(arguments.key)){
			var out = {}
			if(isDate(arguments.key.start?:"")){
				out.start = arguments.key.start;
			}

			if(isDate(arguments.key.end?:"")){
				out.end = arguments.key.end;
			}
			return out;
		} else {
			if(!this.hasRange(arguments.key)){throw("Did not find the range #arguments.key#.")}
			return variables.ranges[arguments.key];
		}
    }

    /**
     * Gets the ranges as an array so that we can easily loop over and
     * create <options>
     */
    public function getRangeOptions(){
        var out = [];
        var optionGroups = this.getRangeOptionGroups();
        for(group in optionGroups){
            out.append(group.options, true);
        }
        return out;
    }

    /**
     * Gets the ranges as an array of arrays grouped by the type of
     * range so that we can easily loop over and create <option> elements
     * with <optgroup>
     *
     * @date
     */
    public function getRangeOptionGroups(){
        var ranges = variables.ranges;
        var out = [

                {
                    name:"Recently",
                    options:[
                        {name:"Today", id:"today", range:ranges['today']},
                        {name:"Tomorrow", id:"tomorrow", range:ranges['tomorrow']},
                        {name:"Yesterday", id:"yesterday", range:ranges['yesterday']},
                    ]
                }
            ,
				{
					name:"All Time",
					options:[
						{name:"Today Forward", id:"today_forward", range:ranges['today_forward']},
						{name:"Today Backward", id:"today_backward", range:ranges['today_backward']},
						{name:"In the Future", id:"in_the_future", range:ranges['in_the_future']},
						{name:"In the Past", id:"in_the_past", range:ranges['in_the_past']},
					]
				}
			,
                {
                    name:"This Period",
                    options:[
                        {name:"This Week", id:"this_week", range:ranges['this_week']},
                        {name:"This Month", id:"this_month", range:ranges['this_month']},
                        {name:"This Quarter", id:"this_quarter", range:ranges['this_quarter']},
                        {name:"This Year", id:"this_year", range:ranges['this_year']},
                    ]
                }
            ,

                {
                    name:"Last Period",
                    options:[
                        {name:"Last Week", id:"last_week", range:ranges['last_week']},
                        {name:"Last Month", id:"last_month", range:ranges['last_month']},
                        {name:"Last Quarter", id:"last_quarter", range:ranges['last_quarter']},
                        {name:"Last Year", id:"last_year", range:ranges['last_year']},
                    ]
                }
            ,

                {
                    name:"Next Period",
                    options:[
                        {name:"Next Week", id:"next_week", range:ranges['next_week']},
                        {name:"Next Month", id:"next_month", range:ranges['next_month']},
                        {name:"Next Quarter", id:"next_quarter", range:ranges['next_quarter']},
                        {name:"Next Year", id:"next_year", range:ranges['next_year']},
                    ]
                }
            ,

                {
                    name:"Last Days",
                    options:[
                        {name:"Last 7 Days", id:"last_7_days", range:ranges['last_7_days']},
                        {name:"Last 14 Days", id:"last_14_days", range:ranges['last_14_days']},
                        {name:"Last 30 Days", id:"last_30_days", range:ranges['last_30_days']},
                        {name:"Last 60 Days", id:"last_60_days", range:ranges['last_60_days']},
                        {name:"Last 90 Days", id:"last_90_days", range:ranges['last_90_days']},
                        {name:"Last 180 Days", id:"last_180_days", range:ranges['last_180_days']},
                        {name:"Last 360 Days", id:"last_360_days", range:ranges['last_360_days']},
                    ]
                }
            ,

                {
                    name:"Next Days",
                    options:[
                        {name:"Next 7 Days", id:"next_7_days", range:ranges['next_7_days']},
                        {name:"Next 14 Days", id:"next_14_days", range:ranges['next_14_days']},
                        {name:"Next 30 Days", id:"next_30_days", range:ranges['next_30_days']},
                        {name:"Next 60 Days", id:"next_60_days", range:ranges['next_60_days']},
                        {name:"Next 90 Days", id:"next_90_days", range:ranges['next_90_days']},
                        {name:"Next 180 Days", id:"next_180_days", range:ranges['next_180_days']},
                        {name:"Next 360 Days", id:"next_360_days", range:ranges['next_360_days']},
                    ]
                }
            ,
        ]
        return out;
    }

    /**
     * Returns all of the ranges around the date provided
     */
    public function getRanges(date = variables.date){
        var dateStart = createDate(year(arguments.date), month(arguments.date), day(arguments.date));
        var dateEnd = createDateTime(year(arguments.date), month(arguments.date), day(arguments.date), 23, 59, 59);

        // today
        // tomorrow
        // yesterday

		//today_forward
		//today_backward
		//future
		//past

        // this_week
        // this_month
        // this_year
        // this_quarter

        // last_week
        // last_month
        // last_year
        // last_quarter

        // next_week
        // next_month
        // next_year
        // next_quarter

        // next_7_days
        // next_14_days
        // next_30_days
        // next_60_days
        // next_90_days
        // next_180_days
        // next_365_days

        // last_7_days
        // last_14_days
        // last_30_days
        // last_60_days
        // last_90_days
        // last_180_days
        // last_365_days

        //next_january
        //next_february
        //next_march
        //next_april
        //next_may
        //next_june
        //next_july
        //next_august
        //next_september
        //next_october
        //next_november
        //next_december

        var dates = {}
        var quarters = {
            1:{start:1, end:3},
            2:{start:4, end:6},
            3:{start:7, end:9},
            4:{start:10, end:12}
        }

        dates.dayOfWeek = dayOfWeek(dateStart);

        dates.today = {
            start: dateStart,
            end: dateEnd
        }
        dates.tomorrow = {
            start: dateAdd("d", 1, dateStart),
            end: dateAdd("d", 1, dateEnd)
        }
        dates.yesterday = {
            start: dateAdd("d", -1, dateStart),
            end: dateAdd("d", -1, dateEnd)
        }

		dates.today_forward = {
			start:dateStart
		}

		dates.today_backward = {
			end:dateEnd
		}

		dates.in_the_future = {
			start:dateAdd("d", 1, dateStart)
		}

		dates.in_the_past = {
			end:dateAdd("d", -1, dateEnd)
		}

        dates.this_week = {
            start:dateAdd("d", 1 - dates.dayOfWeek, dateStart),
            end:dateAdd("d", 7 - dates.dayOfWeek, dateEnd)
        }
        dates.this_month.start = createDate(year(dateStart), month(dateStart), 1)
        dates.this_month.end = createDateTime(
            year(dates.this_month.start),
            month(dates.this_month.start),
            daysInMonth(dates.this_month.start),
            23,
            59,
            59
        )

        dates.this_year.start = createDate(year(dateStart), 01, 01);
        dates.this_year.end = createDateTime(year(dateStart), 12, 31, 23, 59, 59);

        dates.this_quarter.start = createDate(year(dateStart), quarters[quarter(dateStart)].start, 01);
        var firstDayOfLastMonthInQuarter = createDateTime(year(dateStart), quarters[quarter(dateStart)].end, 1);
        dates.this_quarter.end = createDateTime(year(dateStart), quarters[quarter(dateStart)].end, daysInMonth(firstdayOfLastMonthInQuarter), 23, 59, 59);

        dates.last_week = {
            start:dateAdd("d", -7, dates.this_week.start),
            end:dateAdd("d", -7, dates.this_week.end),
        }

        dates.last_month.start = dateAdd("m", -1, dates.this_month.start);
        dates.last_month.end = createDateTime(year(dates.last_month.start), month(dates.last_month.start), daysInMonth(dates.last_month.start), 23, 59, 59);

        dates.last_year.start = dateAdd("yyyy", -1, dates.this_year.start);
        dates.last_year.end = dateAdd("yyyy", -1, dates.this_year.end);

        var dateInLastQuarter = dateAdd("m", -3, dateStart);
        dates.last_quarter.start = createDate(year(dateInLastQuarter), quarters[quarter(dateInLastQuarter)].start, 01);
        var firstDayOfLastMonthInLastQuarter = createDateTime(year(dateInLastQuarter), quarters[quarter(dateInLastQuarter)].end, 1);
        dates.last_quarter.end = createDateTime(year(dateInLastQuarter), quarters[quarter(dateInLastQuarter)].end, daysInMonth(firstdayOfLastMonthInLastQuarter), 23, 59, 59);

        dates.next_week = {
            start:dateAdd("d", 7, dates.this_week.start),
            end:dateAdd("d", 7, dates.this_week.end),
        }

        dates.next_month.start = dateAdd("m", 1, dates.this_month.start);
        dates.next_month.end = createDateTime(year(dates.next_month.start), month(dates.next_month.start), daysInMonth(dates.next_month.start), 23, 59, 59);

        dates.next_year.start = dateAdd("yyyy", 1, dates.this_year.start);
        dates.next_year.end = dateAdd("yyyy", 1, dates.this_year.end);

        var dateInNextQuarter = dateAdd("m", 3, dateStart);
        dates.next_quarter.start = createDate(year(dateInNextQuarter), quarters[quarter(dateInNextQuarter)].start, 01);
        var firstDayOfLastMonthInNextQuarter = createDateTime(year(dateInNextQuarter), quarters[quarter(dateInNextQuarter)].end, 1);
        dates.next_quarter.end = createDateTime(year(dateInNextQuarter), quarters[quarter(dateInNextQuarter)].end, daysInMonth(firstdayOfLastMonthInNextQuarter), 23, 59, 59);

        dates.next_7_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 6, dateEnd)
        }

        dates.next_14_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 13, dateEnd)
        }

        dates.next_30_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 29, dateEnd)
        }

        dates.next_60_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 59, dateEnd)
        }

        dates.next_90_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 89, dateEnd)
        }

        dates.next_180_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 179, dateEnd)
        }

        dates.next_360_days = {
            start:dateAdd("d", 0, dateStart),
            end:dateAdd("d", 359, dateEnd)
        }

        dates.last_7_days = {
            start:dateAdd("d", -6, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_14_days = {
            start:dateAdd("d", -13, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_30_days = {
            start:dateAdd("d", -29, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_60_days = {
            start:dateAdd("d", -59, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_90_days = {
            start:dateAdd("d", -89, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_180_days = {
            start:dateAdd("d", -179, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        dates.last_360_days = {
            start:dateAdd("d", -359, dateStart),
            end:dateAdd("d", -0, dateEnd)
        }

        return dates;
    }
}