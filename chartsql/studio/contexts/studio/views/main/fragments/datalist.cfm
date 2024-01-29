<style>
	.scrollable-table-wrapper {
		overflow-y: auto;
		max-height: 100%; /* Adjust this value as needed */
	}

	.scrollable-table-wrapper::-webkit-scrollbar {
		/* display: none; For browsers that support this CSS property, it can be used to hide the scrollbar */
	}

	.scrollable-table {
		width: auto;
		margin-bottom: 0; /* Remove the margin from the table */
	}

	.table thead th {
		/* position: sticky;
		top: 0;
		z-index: 10; */
		/* The box-shadow gives the visual effect of thead being over tbody allowing the scrollbar not to overlay the cells */
		box-shadow: 2px 0px 5px rgba(0,0,0,.3);
	}

	.datalist td {
		font-size: .7rem;
	}

</style>
{{#if data.CurrentSqlFile.LastExecutionRequest.IsError}}
	<div class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%; align-items:center; justify-content:center;">
		<span class="btn btn-outline-danger" style="pointer-events:none; opacity:.4">Error Querying Data</span>
	</div>
{{else}}
	{{#unless data.CurrentSqlFile.Id}}
		<div class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%; align-items:center; justify-content:center;">
			<span class="btn btn-outline-info" style="pointer-events:none; opacity:.4">No file open</span>
		</div>
	{{/unless}}
{{/if}}

<!--- {{#if data.CurrentSqlFile.LastExecutionRequest.IsRunning}}
	<div class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
		<form method="POST" action="/studio/main/cancelExecution">
			<input type="hidden" name="Id" value="{{data.CurrentSqlFile.LastExecutionRequest.Id}}">
			<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
			<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
			<button class="btn btn-outline-azure" style="">Cancel Execution</button>
		</form>
	</div>
{{/if}} --->

<table class="table scrollable-table table-sm table-striped table-hover datalist">
	<thead class="">
		<tr>
			{{#each data.CurrentSqlFile.ResultSet.Columns}}

				<!--- Add a CSS class that will be used to decorate the column td
					  with a color if the column is used in a chart. This makes it
					  easier to see which columns are used in a chart.
				 --->
				{{#if IsUsedAnywhere}}
					<style>
						.isUsedAnywhere{{@index}} {
							color: rgba(var(--tblr-info-rgb))!important;
						}
					</style>
				{{/if}}

				<th style="text-transform: none;" class="pe-3">
					{{#if IsCategoryField}}
					<span data-bs-toggle="tooltip" data-bs-placement="top" title="{{Name}} is on the x-Axis">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-axis-x text-info" style="width:20px;" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 13v.01" /><path d="M4 9v.01" /><path d="M4 5v.01" /><path d="M17 20l3 -3l-3 -3" /><path d="M4 17h16" /></svg>
					</span>
					{{else if IsValueField}}
					<span data-bs-toggle="tooltip" data-bs-placement="top" title="{{Name}} is on the y-Axis">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-axis-y text-info" style="width:20px;" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M11 20h-.01" /><path d="M15 20h-.01" /><path d="M19 20h-.01" /><path d="M4 7l3 -3l3 3" /><path d="M7 20v-16" /></svg>
					</span>
					{{/if}}
					{{this.name}}
					{{#if IsStackingField}}
						<span data-bs-toggle="tooltip" data-bs-placement="top" title="{{Name}} is being stacked">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-stack-2 text-muted" style="width:20px;" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 4l-8 4l8 4l8 -4l-8 -4" /><path d="M4 12l8 4l8 -4" /><path d="M4 16l8 4l8 -4" /></svg>
						</span>
					{{/if}}
					{{#if IsStackingModePercentField}}
						<span data-bs-toggle="tooltip" data-bs-placement="top" title="{{Name}} is being stacked 100% because @stacking-mode: percent is defined">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-percentage text-muted" style="width:20px;" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M17 17m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M7 7m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M6 18l12 -12" /></svg>
						</span>
					{{/if}}

					{{#if IsGroupingField}}
						<span data-bs-toggle="tooltip" data-bs-placement="top" title="{{Name}} is in the @groups and so identical rows are summed to the same group">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-bucket text-muted" style="width:20px;"  width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 7m-8 0a8 4 0 1 0 16 0a8 4 0 1 0 -16 0" /><path d="M4 7c0 .664 .088 1.324 .263 1.965l2.737 10.035c.5 1.5 2.239 2 5 2s4.5 -.5 5 -2c.333 -1 1.246 -4.345 2.737 -10.035a7.45 7.45 0 0 0 .263 -1.965" /></svg>
						</span>
					{{/if}}


				</th>
			{{/each}}
			<!--- <th>Product</th>
			<th>Price</th>
			<th>Quantity</th>
			<th>Total Sales</th> --->
		</tr>
	</thead>
	<tbody>
		{{#each data.CurrentSqlFile.ResultSet.Data}}
			<tr>
				{{#each this}}
					<td class="pe-3 isUsedAnywhere{{@index}}">{{this}}</td>
				{{/each}}
			</tr>
		{{/each}}
		<!--- <tr><th scope="row">1</th><td>Widget A</td><td>$10</td><td>3</td><td>$30</td></tr>
		<tr><th scope="row">2</th><td>Widget B</td><td>$12</td><td>2</td><td>$24</td></tr>
		<tr><th scope="row">3</th><td>Widget C</td><td>$15</td><td>5</td><td>$75</td></tr>
		<tr><th scope="row">4</th><td>Gadget A</td><td>$20</td><td>1</td><td>$20</td></tr>
		<tr><th scope="row">5</th><td>Gadget B</td><td>$25</td><td>4</td><td>$100</td></tr>
		<tr><th scope="row">6</th><td>Tool A</td><td>$5</td><td>10</td><td>$50</td></tr>
		<tr><th scope="row">7</th><td>Tool B</td><td>$8</td><td>7</td><td>$56</td></tr>
		<tr><th scope="row">8</th><td>Tool C</td><td>$12</td><td>6</td><td>$72</td></tr>
		<tr><th scope="row">9</th><td>Appliance A</td><td>$150</td><td>1</td><td>$150</td></tr>
		<tr><th scope="row">10</th><td>Appliance B</td><td>$200</td><td>2</td><td>$400</td></tr>
		<tr><th scope="row">11</th><td>Device A</td><td>$40</td><td>3</td><td>$120</td></tr>
		<tr><th scope="row">12</th><td>Device B</td><td>$50</td><td>5</td><td>$250</td></tr>
		<tr><th scope="row">13</th><td>Device C</td><td>$60</td><td>2</td><td>$120</td></tr>
		<tr><th scope="row">14</th><td>Accessory A</td><td>$25</td><td>8</td><td>$200</td></tr>
		<tr><th scope="row">15</th><td>Accessory B</td><td>$30</td><td>3</td><td>$90</td></tr>
		<tr><th scope="row">16</th><td>Accessory C</td><td>$35</td><td>7</td><td>$245</td></tr>
		<tr><th scope="row">17</th><td>Material A</td><td>$3</td><td>50</td><td>$150</td></tr>
		<tr><th scope="row">18</th><td>Material B</td><td>$4</td><td>25</td><td>$100</td></tr>
		<tr><th scope="row">19</th><td>Material C</td><td>$5</td><td>20</td><td>$100</td></tr>
		<tr><th scope="row">20</th><td>Product A</td><td>$75</td><td>4</td><td>$300</td></tr> --->
	</tbody>
</table>
