<style>
	.nav-link a {
		font-size: var(--tblr-nav-link-font-size);
		font-weight: var(--tblr-nav-link-font-weight);
		color: var(--tblr-nav-link-color);
		background: 0 0;
		border: 0;
		transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
	}

	.nav-link a.active {
		font-size: var(--tblr-nav-link-font-size);
		font-weight: var(--tblr-nav-link-font-weight);
		color: var(--tblr-nav-link-color);
		border: 0;
		transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
	}

	.nav-tabs .nav-item.show .nav-link, .nav-tabs .nav-link a.file-link.active {
		color: var(--tblr-nav-tabs-link-active-color);
		background-color: var(--tblr-card-bg);
		border-color: var(--tblr-nav-tabs-link-active-border-color);
	}

	.nav-link:focus, .nav-link:hover a.file-link {
		color: var(--tblr-nav-link-hover-color);
		text-decoration: none;
	}

</style>
<div class="card-header" style="min-height: 43px; border-radius:0; border:none;">
	<ul class="nav nav-tabs card-header-tabs" data-bs-toggle="tabs" role="tablist" style="padding:0; border-radius:0; border:none;">

		{{#each data.ChartSQLStudio.SqlFiles}}
		{{#if IsScratch}}
		<li class="nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
			<span class="nav-link {{#if IsActive}}active{{/if}} pe-0">
				<a href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}} me-0 pe-0" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
					<span class="me-2">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
					</span>
					{{Name}}

					<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
				</a>
				<a href="{{CloseLink}}" class="btn btn-icon btn-ghost-primary btn-sm" zero-icon="false" style="visibility:hidden;">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
				</a>
			</span>
		</li>
		{{/if}}
		{{/each}}

		{{#each data.ChartSQLStudio.SqlFiles}}

		{{#if IsOpen}}{{#unless IsScratch}}
			{{#if IsMissingFile}}
				<li class="nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
					<span class="nav-link {{#if IsActive}}active{{/if}}">
						<a href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}}" zero-target="{{view_state.main_zero_targets}},#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
							<span class="me-2">
								<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
							</span>
							<span class="text-decoration-line-through text-danger">
								{{Name}}
							</span>
							<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
	
						</a>
						<a href="{{CloseLink}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
						</a>
					</span>
				</li>
			{{else}}
				<li class="nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">

				<!--- Commenting out the original nav link but keeping for troubleshooting purposes. We needed to be
					able to have 2 links within the nav (one to close the file). We had to override the styles to achieve
					this --->
					<!--- <a href="{{OpenLink}}" class="nav-link {{#if IsActive}}active{{/if}}" style="">
						<span class="me-2">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
						</span>
						{{Name}}
	
	
						<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
	
					</a> --->
					<span class="nav-link {{#if IsActive}}active{{/if}}">
						<a href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}}" zero-target="{{view_state.main_zero_targets}},#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
							<span class="me-2">
								<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
							</span>
							{{Name}}
	
							<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
	
						</a>
						<a href="{{CloseLink}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
						</a>
					</span>
				</li>
			{{/if}}
			{{/unless}}{{/if}}
			{{/each}}
			{{#if data.CurrentSQLFile.IsActiveButNotOpen}}
				{{#with data.CurrentSQLFile}}
					{{#if IsMissingFile}}
						<li class="nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
							<span class="nav-link {{#if IsActive}}active{{/if}}">
								<a href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}}" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
									<span class="me-2">
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
									</span>

									<span class="open-file-name text-decoration-line-through text-danger"><i>{{Name}}</i></span>
	
									<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
	
								</a>
								<a href="{{PreviewCloseLink}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false">
									<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
								</a>
							</span>
						</li>
					{{else}}
						{{#if data.ChangeActiveFileName}}
							<li id="change-file-name-dropdown" class="nav-item nav-item border-info d-flex align-items-center" role="presentation">
								<span class="nav-link {{#if IsActive}}active{{/if}}">
									<span href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}}" zero-target="{{view_state.main_zero_targets}},#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
										<span class="me-2">
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
										</span>
									</span>
									<form id="changeFileNameForm" method="POST" action="/studio/main/changeFileName" style="display:inline;" zero-target="{{view_state.main_zero_targets}},#editorCard">
										<input type="hidden" name="goto" value="{{view_state.rename_file_go_to}}"/>
										<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
										<input type="hidden" name="SqlFileFullName" value="{{FullName}}"/>
										<!--- <input type="hidden" name="PackageName" value="{{data.CurrentPackage.FullName}}"> --->
										<div id="changeFileNameContainer" class="input-group">
											<input id="changeFileNameInput" type="text" name="fileName" class="form-control form-control-sm" placeholder="File name" value="{{Name}}">
											<button form="changeFileNameForm" class="d-none btn btn-primary btn-sm" type="submit">Save</button>
											<!--- <a href="{{view_state.stop_change_file_name_link}}" class="btn btn-ghost btn-sm">Cancel</a> --->
										</div>
									</form>
									<form id="stopChangeFileNameForm" method="GET" action="{{view_state.stop_change_file_name_link}}" style="display:inline;" zero-target="#openFilesList">
										<input type="hidden" name="goto" value="{{view_state.stop_change_file_name_link}}"/>
										<input type="hidden" name="goto_fail" value="{{view_state.stop_change_file_name_link}}"/>
									</form>
								</span>
							</li>
						{{else}}
							<li class="nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">

								<!--- Commenting out the original nav link but keeping for troubleshooting purposes. We needed to be
									able to have 2 links within the nav (one to close the file). We had to override the styles to achieve
									this --->
									<!--- <a href="{{OpenLink}}" class="nav-link {{#if IsActive}}active{{/if}}" style="">
										<span class="me-2">
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
										</span>
										{{Name}}
			
			
										<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
			
									</a> --->
									<span class="nav-link {{#if IsActive}}active{{/if}}">
										<a href="{{OpenLink}}" class="file-link {{#if IsActive}}active{{/if}}" zero-target="{{view_state.main_zero_targets}},#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none;">
											<span class="me-2">
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
											</span>
			
											<span class="open-file-name"><i>{{Name}}</i></span>
			
											<span class="status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
			
										</a>
										<a href="{{PreviewCloseLink}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false">
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
										</a>
									</span>
								</li>
						{{/if}}
					{{/if}}
				{{/with}}
				{{/if}}

			<li id="new-file-dropdown" class="nav-item d-flex align-items-center" role="presentation">
				<form id="createFileForm" method="POST" action="/studio/main/createSqlFile" style="display:inline;">
					<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
					<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
					<input type="hidden" name="OpenFileAt" value="{{view_state.current_url}}"/>
					<input type="hidden" name="PackageName" value="{{data.CurrentPackage.FullName}}">
					<div id="createFileContainer" class="input-group d-none">
						<input id="createFileInput" type="text" name="FileName" class="form-control form-control-sm" placeholder="File name" value=".sql">
						<button form="createFileForm" class="btn btn-sm" type="submit">Create</button>
					</div>
				</form>
				<div class="btn-group " style="position:relative;">
					<!--- <button class="btn btn-ghost-primary btn-sm" type="button" onclick="document.getElementById('createFileContainer').remove('d-none'); document.getElementById('createFileInput').focus();"> --->
						<button class="btn btn-ghost-primary" style="border-radius: 0; padding: var(--tblr-nav-link-padding-y) var(--tblr-nav-link-padding-x);" type="button" onclick="document.getElementById('createFileContainer').classList.remove('d-none'); document.getElementById('createFileInput').focus();">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-file-type-sql" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M5 20.25c0 .414 .336 .75 .75 .75h1.25a1 1 0 0 0 1 -1v-1a1 1 0 0 0 -1 -1h-1a1 1 0 0 1 -1 -1v-1a1 1 0 0 1 1 -1h1.25a.75 .75 0 0 1 .75 .75" /><path d="M5 12v-7a2 2 0 0 1 2 -2h7l5 5v4" /><path d="M18 15v6h2" /><path d="M13 15a2 2 0 0 1 2 2v2a2 2 0 1 1 -4 0v-2a2 2 0 0 1 2 -2z" /><path d="M14 20l1.5 1.5" /></svg>
							New
						</button>
						<button type="button" class="btn btn-ghost-primary dropdown-toggle dropdown-toggle-split" style="padding: var(--tblr-nav-link-padding-y) var(--tblr-nav-link-padding-x);" data-bs-toggle="dropdown" aria-expanded="false">
							<span class="visually-hidden">Toggle Dropdown</span>
						</button>
						<ul class="dropdown-menu">
							<a class="dropdown-item" href="{{view_state.close_all_link}}">
								<svg xmlns="http://www.w3.org/2000/svg" style="z-index:10;" class="icon icon-tabler icon-tabler-square-rounded-x me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10 10l4 4m0 -4l-4 4" /><path d="M12 3c7.2 0 9 1.8 9 9s-1.8 9 -9 9s-9 -1.8 -9 -9s1.8 -9 9 -9z" /></svg>
								<span class="me-2">Close All Open Scripts</span>
							</a>
							
							<form method="GET" action="{{view_state.change_file_name_link}}" zero-target="#openFilesList">
								<button type="submit" class="dropdown-item">
									<svg xmlns="http://www.w3.org/2000/svg" style="z-index: 10;" class="icon icon-tabler icon-tabler-file-pencil me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" /><path d="M10 18l5 -5a1.414 1.414 0 0 0 -2 -2l-5 5v2h2z" /></svg>
									<span class="me-2">Rename File</span>
								</button>
							</form>
						</ul>
					</div>
				</li>

			</ul>
		</div>
		<script>
			$(document).keydown(function(e) {
				if (e.key === "Escape") {
					// Submit to 'stopChangeFileNameForm'
					let stopChangeFileNameFormElement = $('#stopChangeFileNameForm');
					if (stopChangeFileNameFormElement.length > 0) {
						stopChangeFileNameFormElement.submit();
					}
					// If 'createFileContainer' element doest have a 'd-none property'
					if ($('#createFileContainer').hasClass('d-none') === false) {
						$('#createFileContainer').addClass('d-none');
					}
				}
			});
		</script>