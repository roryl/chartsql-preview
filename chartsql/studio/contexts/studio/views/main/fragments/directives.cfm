<table class="custom-table table table-dark table-sm table-striped" >
	<tbody>
		<!---
			---------------------------
			FIELD PILLS INLINE PARTIAL
			---------------------------
			Our own implementation of a multi-select list, this parties adds pills for each
			field added to the directive, and maintains an invisible backing input that keeps
			track of the comma separated fields added to the directive.

			Arguments:
			IconClass: The icon class to use for the input icon
			Directive: The directive object to use for the backing input
		--->
		{{#*inline "fieldPills"}}
		<div class="input-icon" style="background: var(--tblr-bg-forms);">
			<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
				<i class="{{IconClass}}"></i>
			</span>
			<form id="fieldsSubmitForm_{{Directive.CleanedName}}" method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
				<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
				<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
				<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
				<input type="hidden" name="Directive" value="{{Directive.Name}}">
				<input id="{{Directive.CleanedName}}SubmitButton" type="submit" style="display:none;">
				<input id="{{Directive.CleanedName}}Input" name="value" class="form-control" spellcheck="false" style="display:none; border:none; border-radius: 0;" placeholder="yAxis Fields" id="datepicker-icon-prepend" value="{{Directive.valueRaw}}">
				<div id="directivesFieldPills_{{Directive.CleanedName}}" style="width:80%; min-height: 2.3rem; height:100%; top:0; left:0; padding-left:40px; display:flex; align-items:center;">
					<div>
					{{#if data.CurrentSqlFile.CurrentDatasourceSqlFileCache.LastExecutionRequest.IsSuccess}}
						{{#if Directive.HasValue}}
						{{#each Directive.Parsed}}
							<button class="btn btn-sm bg-azure-lt me-1" style="height:20px;" onclick="removeFieldValue{{Directive.CleanedName}}('{{this}}')">{{this}}</button>
						{{/each}}
						{{/if}}
					{{else}}
						<span class="text-info">... run sql to see columns</span>
					{{/if}}
					</div>
				</div>
			</form>

			<div style="display:inline; position:absolute; right:0; top:0; height:100%; display:flex; align-items:center; justify-content:center;">
				<div class="dropdown me-1">
					<button class="btn btn-ghost-info btn-icon dropdown-toggle btn-sm ps-1" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
						Add Field
					</button>
					<script>

						function removeFieldValue{{Directive.CleanedName}}(field){
							//Removes the field value and trims any trailing or preceeding commas
							var input = document.getElementById('{{Directive.CleanedName}}Input');

							// console.log('before remove' + input.value);

							input.value = input.value.trim();
							input.value = input.value.replace(field, '').replace(',,', ',').replace(/^,|,$/g, '');

							//trim the input value
							input.value = input.value.trim();

							//If there is only a comma left after trim, remove it
							if (input.value == ',') {
								input.value = '';
							}

							//If the last character is trailing comma, remove it
							if (input.value.slice(-1) == ',') {
								input.value = input.value.slice(0, -1);
							}

							// console.log('after remove' + input.value);

							document.getElementById('{{Directive.CleanedName}}SubmitButton').click();
							document.getElementById('editorProgress').classList.remove('d-none');
						}

						function addValueField{{Directive.CleanedName}}(field) {
							var input = document.getElementById('{{Directive.CleanedName}}Input');
							//If the input is empty we will just append the field, otherwise append a comma and the field

							// console.log('before add' + input.value);

							input.value = input.value.trim();

							if (input.value == '') {
								input.value = field;
							} else {
								input.value = input.value + ', ' + field;
							}

							// console.log('after add ' + input.value);
							document.getElementById('{{Directive.CleanedName}}SubmitButton').click();
							document.getElementById('editorProgress').classList.remove('d-none');
						}
					</script>
					<ul id="directivesFieldAdd_{{Directive.CleanedName}}" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
						{{#each Directive.AvailableFields}}
						<li><a class="dropdown-item" onclick="addValueField{{Directive.CleanedName}}('{{this}}'); this.remove();">{{this}}</a></li>
						{{/each}}
					</ul>
				</div>
			</div>
		</div>
		{{/inline}}

		<!--- DIRECTIVE ERROR PARTIAL:
				Will loop through any errors if exists and display the error message
		 --->
		<!--- {{#*inline "directiveErrorRow"}}
		 	<div id="error{{Name}}" class="errorRow">
			{{#if Directive.Errors}}
				<tr>
					<td colspan="2"></td>
					<td colspan="2" class="p-0">
						<div class="alert alert-warning m-0 py-1" role="alert" style="background:none; border-radius:0; border-bottom:none; border-top:none;">
							{{#each Directive.Errors}}
								<h4 class="alert-title">{{Title}}</h4>
								<div class="text-secondary">{{message}}</div>
							{{/each}}
						</div>
					</td>
				</tr>
			{{/if}}
			</div>
		{{/inline}} --->

		{{#*inline "directiveErrorRow"}}

			<div id="directiveError{{Directive.Name}}" class="directiveErrorAlert" style="">
			{{#if Directive.Errors}}
				<div class="alert alert-warning m-0 py-1" role="alert" style="background:none; border-radius:0; border-bottom:none; border-top:none;">
					{{#each Directive.Errors}}
						<h4 class="alert-title">{{Title}}</h4>
						<div class="text-secondary">{{message}}</div>
					{{/each}}
				</div>
				{{/if}}
			</div>

		{{/inline}}

		{{#*inline "directiveTitleColumn"}}
			<td id="directiveEditorTitle{{Directive.Name}}" class="directiveEditorTitle p-0 ps-1 pe-2 pt-2 text-end text-nowrap">
				<span class="{{#if Directive.ValueRaw}}{{#if Directive.IsCommentedOut}}text-muted{{else}}text-success{{/if}}{{else}}text-muted{{/if}}">{{#if Directive.IsCommentedOut}}//{{/if}}{{Directive.Name}}:</span>
			</td>
		{{/inline}}

		{{#*inline "directiveDisabledColumn"}}
		<td class="text-center align-middle ps-4">
			{{#if Directive.ValueRaw}}
						<label class="form-check form-switch m-0">
							<form method="POST" action="/studio/main/toggleSQLFileDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" >
								<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
								<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
								<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}"/>
								<input type="hidden" name="Directive" value="{{Directive.Name}}"/>
								<input zero-icon="true" onChange="$(this).closest('form').submit()" class="form-check-input" type="checkbox" {{#if Directive.IsCommentedOut}}checked{{/if}}/>
							</form>
							<span class="form-check-label text-muted">
							</span>
						</label>
				{{/if}}
		</td>
		{{/inline}}

		<!--- CHART DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.chart}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.chart}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-infographic" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" /><path d="M7 3v4h4" /><path d="M9 17l0 4" /><path d="M17 14l0 7" /><path d="M13 13l0 8" /><path d="M21 12l0 9" /></svg>
					</span>
					<form method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="chart">
						<input type="submit" style="display:none;">
						<select name="value" class="form-select form-control" style="border:none; border-radius: 0;">
							<option value=""></option>
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="area">area</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="column">column</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="bar">bar</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="line">line</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="pie">pie</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="combo">combo</option>{{/select}}
							<!--- {{#select data.CurrentSqlFile.NamedDirectives.chart.ValueRaw}}<option value="line">line</option>{{/select}} --->
						</select>
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Chart
				}}
			</td>
			<!--- <td class="text-center align-middle ps-1">
				<button class="btn btn-ghost-secondary p-0 m-0" data-bs-toggle="tooltip" data-bs-placement="top" title="Erase directive">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-eraser mx-1" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19 20h-10.5l-4.21 -4.3a1 1 0 0 1 0 -1.41l10 -10a1 1 0 0 1 1.41 0l5 5a1 1 0 0 1 0 1.41l-9.2 9.3" /><path d="M18 13.3l-6.3 -6.3" /></svg>
				</button>
			</td> --->
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@chart" data-bs-content="The type of visualization that you wish to render with your query.">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- {{> directiveErrorRow
			Directive=data.CurrentSqlFile.NamedDirectives.chart
		}} --->
		<!--- TITLE DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.title}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.title}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-h-1" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19 18v-8l-2 2" /><path d="M4 6v12" /><path d="M12 6v12" /><path d="M11 18h2" /><path d="M3 18h2" /><path d="M4 12h8" /><path d="M3 6h2" /><path d="M11 6h2" /></svg>
					</span>
					<form method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="title">
						<input type="submit" style="display:none;">
						<input class="form-control" name="value" autocomplete="off" style="border:none; border-radius: 0;" placeholder="My Chart..." id="datepicker-icon-prepend" value="{{data.CurrentSqlFile.NamedDirectives.Title.ValueRaw}}">
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Title
				}}
			</td>

			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@title (string)" data-bs-content="A friendly name for your chart. This name shows up in the editor and various title areas" >
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- SUBTITLE DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.subtitle}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.subtitle}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-h-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M17 12a2 2 0 1 1 4 0c0 .591 -.417 1.318 -.816 1.858l-3.184 4.143l4 0" /><path d="M4 6v12" /><path d="M12 6v12" /><path d="M11 18h2" /><path d="M3 18h2" /><path d="M4 12h8" /><path d="M3 6h2" /><path d="M11 6h2" /></svg>
					</span>
					<form method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="subtitle">
						<input type="submit" style="display:none;">
						<input class="form-control" name="value" style="border:none; border-radius: 0;" placeholder="My Chart..." id="datepicker-icon-prepend" value="{{data.CurrentSqlFile.NamedDirectives.Subtitle.ValueRaw}}">
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Subtitle
				}}
			</td>

			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@subtitle (string)" data-bs-content="A short description of your chart. This is used in the file list and other areas.">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- TAGS DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.Tags}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.Tags}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-tag"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7.5 7.5m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M3 6v5.172a2 2 0 0 0 .586 1.414l7.71 7.71a2.41 2.41 0 0 0 3.408 0l5.592 -5.592a2.41 2.41 0 0 0 0 -3.408l-7.71 -7.71a2 2 0 0 0 -1.414 -.586h-5.172a3 3 0 0 0 -3 3z" /></svg>
					</span>
					<form method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="tags">
						<input type="submit" style="display:none;">
						<input class="form-control" name="value" style="border:none; border-radius: 0;" placeholder="Searchable words for your chart" id="datepicker-icon-prepend" value="{{data.CurrentSqlFile.NamedDirectives.Tags.ValueRaw}}">
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Tags
				}}
			</td>

			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@tags (string)" data-bs-content="Searchable words for your chart">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- MONGODB-QUERY DIRECTIVE --->
		{{#if data.CurrentSqlFile.ShouldLoadMongoDbEditor}}
			<tr>
				{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.MongoDB-Query}}

				{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.MongoDB-Query}}

				<td class="p-0 d-flex flex-wrap align-items-center" style="min-height: 34px; width: 100% !important; background-color: #151F2C !important;">
					<div class="input-icon d-flex flex-row align-items-center w-100">
						<span class="input-icon-addon"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
							<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-database"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
						</span>
						<form action="/studio/main" method="GET" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer">
							{{#each view_state.params}}
								{{#unless (eq key "EditorPanelView")}}
									<input type="hidden" name="{{key}}" value="{{value}}">
								{{/unless}}
							{{/each}}
							<input type="hidden" name="EditorPanelView" value="mongodb-query">
							<button style="" type="submit" class="nav-link text-info py-0 ps-5 ms-2" aria-selected="true" role="tab" style="background-color: #151F2C !important; border-radius:0; border-top:none; border-left:none; border-right:none; margin:0; height:100%; width: 100%;">
								Go to MongoDB Editor
								<!--- {{#if data.CurrentSqlFile.HasDirectiveErrors}}
								<span class="status-dot status-dot-animated status-orange ms-2"></span>
								{{/if}} --->
							</button>
						</form>
					</div>
					{{> directiveErrorRow
						Directive=data.CurrentSqlFile.NamedDirectives.MongoDB-Query
					}}
				</td>

				<td class="align-middle text-center">
					<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@tags (string)" data-bs-content="Searchable words for your chart">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
					</span>
				</td>
			</tr>
		{{/if}}
		<!--- BASELINES DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.baselines}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.baselines}}

			<td class="p-0">
				{{> fieldPills
					IconClass="ti ti-line-dashed"
					Directive=data.CurrentSqlFile.NamedDirectives.Baselines
				}}
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Baselines
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@baselines" data-bs-content="Defines which series you would like to add horizontal (for column charts) or vertical (for bar charts) marks with average, min, max, or median">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- BASELINE TYPES DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.baseline-types}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.baseline-types}}

			<td class="p-0">
				{{> fieldPills
					IconClass="ti ti-underline"
					Directive=data.CurrentSqlFile.NamedDirectives.Baseline-Types
				}}
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Baseline-Types
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@baseline-Types" data-bs-content="Whether the baseline should be average, min, max or median. Positionally aligns with @baselines">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- DESCRIPTION DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.description}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.description}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-text-caption" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 15h16" /><path d="M4 4m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" /><path d="M4 20h12" /></svg>
					</span>
					<textarea class="form-control" data-bs-toggle="autosize" style="border:none; border-radius: 0;" placeholder="Longer form description of the chart..."></textarea>
					<!--- <input class="form-control" style="border:none; border-radius: 0;" placeholder="Longer form description of the chart..." id="datepicker-icon-prepend" value="{{data.CurrentSqlFile.NamedDirectives.Description.ValueRaw}}"> --->
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Description
				}}
			</td>

			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@description" data-bs-content="Longform text describing the purpose and data of the chart. Used for documenting your visualizations.">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>

		<!--- CATEGORY DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.category}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.category}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-axis-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 13v.01" /><path d="M4 9v.01" /><path d="M4 5v.01" /><path d="M17 20l3 -3l-3 -3" /><path d="M4 17h16" /></svg>
					</span>
					<form method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="category">
						<input type="submit" style="display:none;">
						<select name="value" class="form-select form-control {{#if data.CurrentSqlFile.CurrentDatasourceSqlFileCache.LastExecutionRequest.IsSuccess}}text-muted{{else}}text-info{{/if}}" style="border:none; border-radius: 0;">
							{{#if data.CurrentSqlFile.CurrentDatasourceSqlFileCache.LastExecutionRequest.IsSuccess}}
								<option value="">Select primary category</option>
								{{#each data.CurrentSqlFile.NamedDirectives.Category.AvailableFields}}
									{{#select (lowerCase data.CurrentSqlFile.NamedDirectives.Category.ValueRaw)}}<option value="{{lowerCase this}}">{{this}}</option>{{/select}}
								{{/each}}
							{{else}}
							<option selected disabled style="">...run sql to see columns</option>
							{{/if}}
						</select>
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Category
				}}
			</td>

			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@category" data-bs-content="The primary category series to use for the chart, typically the x-axis" >
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>

		<!--- GROUPS DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.groups}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.groups}}

			<td class="p-0">
				{{> fieldPills
					IconClass="ti ti-bucket"
					Directive=data.CurrentSqlFile.NamedDirectives.Groups
				}}
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Groups
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@groups" data-bs-content="Mult-level category heirarchy to define for the chart, typically the x-axis">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>

		<!--- STACKS DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.stacks}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.stacks}}

			<td class="p-0">
				{{> fieldPills
					IconClass="ti ti-stack-3"
					Directive=data.CurrentSqlFile.NamedDirectives.Stacks
				}}
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Stacks
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover"title="@stacks" data-bs-content="Which category groups to stack the series values">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>

		<!--- STACKING-MODE DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.stacking-mode}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.stacking-mode}}

			<td class="p-0">
				<div class="input-icon">
					<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-percentage" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M17 17m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M7 7m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M6 18l12 -12" /></svg>
					</span>
					<form id="fieldsSubmitForm_stacking-mode" method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="#editorCard,#fileList,#renderer-card,#editorProgressContainer" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="stacking-mode">
						<input id="stackingmodeSubmitButton" type="submit" style="display:none;">
						<select name="value" class="form-select form-control" style="border:none; border-radius: 0;">
							<option value=""></option>
							{{#select data.CurrentSqlFile.NamedDirectives.Stacking-Mode.ValueRaw}}<option value="percent">percent</option>{{/select}}
							{{#select data.CurrentSqlFile.NamedDirectives.Stacking-Mode.ValueRaw}}<option value="none">none</option>{{/select}}
						</select>
					</form>
				</div>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Stacking-mode
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@stacking-mode" data-bs-content="Whether the stacks for the chart are rendered as 100% stacks so that the series data is shown as a percentage of the whole">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>

		<!--- SERIES DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.series}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.series}}

			<td class="p-0">
				{{> fieldPills
					IconClass="ti ti-axis-y"
					Directive=data.CurrentSqlFile.NamedDirectives.series
				}}
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.series
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@series" data-bs-content="The columns to use as the data series for the chart, typically the y-axis">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
		<!--- FORMATS MODE DIRECTIVE --->
		<tr>
			{{> directiveDisabledColumn Directive=data.CurrentSqlFile.NamedDirectives.formats}}

			{{> directiveTitleColumn Directive=data.CurrentSqlFile.NamedDirectives.formats}}

			<td class="p-0">
				<div class="input-icon" style="background: var(--tblr-bg-forms);">
					<span class="input-icon-addon pt-2" style="align-items:start"><!-- Download SVG icon from http://tabler-icons.io/i/calendar -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-transform" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 6a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /><path d="M21 11v-3a2 2 0 0 0 -2 -2h-6l3 3m0 -6l-3 3" /><path d="M3 13v3a2 2 0 0 0 2 2h6l-3 -3m0 6l3 -3" /><path d="M15 18a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /></svg>
					</span>
					<form id="fieldsSubmitForm_formats" method="POST" action="/studio/main/addOrUpdateDirective" zx-swap="{{view_state.directives_editor_targets}},#directivesFieldPills_formats,#directivesFieldAdd_formats,#fieldsSubmitForm_formats" onchange="this.querySelector('input[type=\'submit\']').click(); document.getElementById('editorProgress').classList.remove('d-none');">
						<input type="hidden" name="goto" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.save_or_update_file_redirect}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<input type="hidden" name="Directive" value="formats">
						<input id="formatsSubmitButton" type="submit" style="display:none;">
						<input id="formatsInput" name="value" class="form-control" spellcheck="false" style="visibility:hidden; border:none; border-radius: 0;" placeholder="Values display formats" id="datepicker-icon-prepend" value="{{data.CurrentSqlFile.NamedDirectives.Formats.ValueRaw}}">
					</form>

					<div id="directivesFieldPills_formats" style="position:absolute; width:80%; height:100%; z-index:1; top:0; left:0; padding-left:40px; display:flex; align-items:center;">
						{{#if data.CurrentSqlFile.NamedDirectives.Formats.HasValue}}
							{{#each data.CurrentSqlFile.NamedDirectives.Formats.Parsed}}
							<button class="btn btn-sm bg-azure-lt me-2" style="height:20px;" onclick="removeFieldValueFormats('{{this}}')">{{this}}</button>
							{{/each}}
						{{else}}
							<span class="text-muted">Add formats for values columns</span>
						{{/if}}
					</div>

					<div id="directivesFieldAdd_formats" style="display:inline; position:absolute; right:0; top:0; height:100%; display:flex; align-items:center; justify-content:center; z-index: 100;">
						<div class="dropdown me-1">
							<button class="btn btn-ghost-info btn-icon dropdown-toggle btn-sm ps-1" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
								Add Format
							</button>
							<ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
								<li><a class="dropdown-item" onclick="addValueFieldFormats('currency');">currency</a></li>
								<li><a class="dropdown-item" onclick="addValueFieldFormats('integer');">integer</a></li>
								<li><a class="dropdown-item" onclick="addValueFieldFormats('percent');">percent</a></li>
								<li><a class="dropdown-item" onclick="addValueFieldFormats('decimal');">decimal</a></li>
							</ul>
						</div>
					</div>
				</div>
				<script>

					function removeFieldValueFormats(field){
						//Removes the field value and trims any trailing or preceeding commas
						var input = document.getElementById('formatsInput');

						// console.log('before remove' + input.value);

						input.value = input.value.trim();
						input.value = input.value.replace(field, '').replace(',,', ',').replace(/^,|,$/g, '');

						//trim the input value
						input.value = input.value.trim();

						//If there is only a comma left after trim, remove it
						if (input.value == ',') {
							input.value = '';
						}

						//If the last character is trailing comma, remove it
						if (input.value.slice(-1) == ',') {
							input.value = input.value.slice(0, -1);
						}

						// console.log('after remove' + input.value);

						document.getElementById('formatsSubmitButton').click();
					}

					function addValueFieldFormats(field) {
						var input = document.getElementById('formatsInput');
						//If the input is empty we will just append the field, otherwise append a comma and the field

						// console.log('before add' + input.value);

						input.value = input.value.trim();

						if (input.value == '') {
							input.value = field;
						} else {
							input.value = input.value + ', ' + field;
						}

						// console.log('after add ' + input.value);
						document.getElementById('formatsSubmitButton').click();
					}
				</script>
				{{> directiveErrorRow
					Directive=data.CurrentSqlFile.NamedDirectives.Formats
				}}
			</td>
			<td class="align-middle text-center">
				<span type="button" class="" data-bs-trigger="hover" data-bs-toggle="popover" title="@formats" data-bs-content="The format to render the series in, currency, percent, integer or decimal">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-help-hexagon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M19.875 6.27c.7 .398 1.13 1.143 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" /><path d="M12 16v.01" /><path d="M12 13a2 2 0 0 0 .914 -3.782a1.98 1.98 0 0 0 -2.414 .483" /></svg>
				</span>
			</td>
		</tr>
	</tbody>
</table>
</script>
<style>
	/* Since the Directives table header and body are on different tables,
	to make all the columns the same width we need to explicitly put the same
	width and max-width to all columns. That way both tables is going to
	shrink and expand at the same rate whick will make them look synchronized.*/
	table.custom-table tbody tr td:nth-child(1) {
		width: 50px !important;
		max-width: 50px !important;
	}
	
	table.custom-table tbody tr td:nth-child(2) {
		width: 100px !important;
		max-width: 100px !important;
	}
	
	table.custom-table tbody tr td:nth-child(3) {
		width: 200px !important;
	}
	
	table.custom-table tbody tr td:nth-child(4) {
		width: 20px !important;
		max-width: 20px !important;
		max-width: 20px !important;
	}
	
	table.custom-table thead tr th:nth-child(1) {
		width: 50px !important;
		max-width: 50px !important;
	}
	
	table.custom-table thead tr th:nth-child(2) {
		width: 100px !important;
		max-width: 100px !important;
	}
	
	table.custom-table thead tr th:nth-child(3) {
		width: 200px !important;
	}
	
	table.custom-table thead tr th:nth-child(4) {
		width: 20px !important;
		min-width: 20px !important;
		max-width: 20px !important;
	}
</style>