<style>
	.nav-link button {
		font-size: var(--tblr-nav-link-font-size);
		font-weight: var(--tblr-nav-link-font-weight);
		color: var(--tblr-nav-link-color);
		background: 0 0;
		border: 0;
		transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
	}

	.nav-link button.active {
		font-size: var(--tblr-nav-link-font-size);
		font-weight: var(--tblr-nav-link-font-weight);
		color: var(--tblr-nav-link-color);
		border: 0;
		transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
	}

	.nav-tabs .nav-item.show .nav-link, .nav-tabs .nav-link button.file-link.active {
		color: var(--tblr-nav-tabs-link-active-color);
		background-color: var(--tblr-card-bg);
		border-color: var(--tblr-nav-tabs-link-active-border-color);
	}

	.nav-link:focus, .nav-link:hover button.file-link {
		color: var(--tblr-nav-link-hover-color);
		text-decoration: none;
	}

</style>
<div class="card-header" style="min-height: 43px; border-radius:0; border:none;">
	<ul class="nav nav-tabs card-header-tabs" data-bs-toggle="tabs" role="tablist" style="padding:0; border-radius:0; border:none;">

		{{#each data.ChartSQLStudio.SqlFiles}}
		{{#if IsScratch}}
		<li data-sqlfile-id="{{Id}}" class="file-item nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
			<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}} pe-0">
				<button type="submit" form="SqlFileForm-{{Id}}" class="file-link stretched-link btn btn-dark border-0 {{#if IsActive}}active{{/if}} me-0 pe-0" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;">
					<span class="me-2">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
					</span>
					{{Name}}

					<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
				</button>
				<button type="submit" form="CloseSqlFileForm-{{Id}}" class="btn btn-icon btn-ghost-primary btn-sm" zero-icon="false" style="visibility:hidden; z-index: 1;">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
				</button>
			</span>
		</li>
		{{/if}}
		{{/each}}

		{{#each data.ChartSQLStudio.SqlFiles}}
			<form id="SqlFileForm-{{Id}}" action="/studio/main/" method="GET" zx-swap="{{view_state.main_zero_targets}},#filterContainer">
				{{#each OpenUrlParams}}
					{{#if value}}
							<input type="hidden" name="{{{key}}}" value="{{{value}}}">
					{{/if}}
				{{/each}}
			</form>
			<form id="CloseSqlFileForm-{{Id}}" action="/studio/main/" method="GET" zx-swap="{{view_state.main_zero_targets}},#filterContainer">
				{{#each CloseUrlParams}}
					{{#if value}}
							<input type="hidden" name="{{{key}}}" value="{{{value}}}">
					{{/if}}
				{{/each}}
			</form>
		{{#if IsOpen}}{{#unless IsScratch}}
			<div id="{{Id}}-file-rightclick-dropdown" class="file-right-click-dropdown" style="display: none; z-index: 9999;">
				<ul class="dropdown-menu show" data-popper-placement="bottom-start" style="position: absolute; inset: 0px auto auto 0px; margin: 0px;">
					<a class="dropdown-item" href="{{view_state.close_all_link}}" zx-swap="#pageContent" studio-form-links="false">
						<svg xmlns="http://www.w3.org/2000/svg" style="z-index:10;" class="icon icon-tabler icon-tabler-square-rounded-x me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
						<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10l4 4m0 -4l-4 4"></path><path d="M12 3c7.2 0 9 1.8 9 9s-1.8 9 -9 9s-9 -1.8 -9 -9s1.8 -9 9 -9z"></path>
						</svg> <span class="me-2">Close All Open Files</span>
					</a>
					<a class="dropdown-item" href="{{CloseAllOtherFilesLink}}" zx-swap="#pageContent" studio-form-links="false">
						<svg xmlns="http://www.w3.org/2000/svg" style="z-index:10;" class="icon icon-tabler icon-tabler-square-rounded-x me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
						<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10l4 4m0 -4l-4 4"></path><path d="M12 3c7.2 0 9 1.8 9 9s-1.8 9 -9 9s-9 -1.8 -9 -9s1.8 -9 9 -9z"></path>
						</svg> <span class="me-2">Close Other Files</span>
					</a>
					<a href="{{RenameFileLink}}" class="dropdown-item" zx-swap="#openFilesList" zx-link-mode="app" studio-form-links="false">
						<svg xmlns="http://www.w3.org/2000/svg" style="z-index: 10;" class="icon icon-tabler icon-tabler-file-pencil me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
						<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z"></path><path d="M10 18l5 -5a1.414 1.414 0 0 0 -2 -2l-5 5v2h2z"></path>
						</svg> <span class="me-2">Rename File</span>
					</a>
					<button {{#if data.CurrentPackage.IsReadOnly}}disabled{{/if}} type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#delete-sqlfile-modal-{{Id}}">
						<svg class="icon icon-tabler me-2"  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-trash"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 7l16 0" /><path d="M10 11l0 6" /><path d="M14 11l0 6" /><path d="M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2 -2l1 -12" /><path d="M9 7v-3a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v3" /></svg>
						<span class="me-2">Delete File</span>
					</button>
				</ul>
			</div>
			<div class="modal modal-blur fade" id="delete-sqlfile-modal-{{Id}}" tabindex="-1" role="dialog" aria-hidden="true">
				<div class="modal-dialog modal-sm modal-dialog-centered" role="document">
					<form method="POST" action="/studio/main/deleteFile" zx-swap={{view_state.main_zero_targets}} >
						<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
						<input type="hidden" name="FullName" value="{{FullName}}">
						<div class="modal-content">
							<button type="button" zero-icon="false" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
							<div class="modal-status bg-danger"></div>
							<div class="modal-body text-center py-4">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon mb-2 text-danger icon-lg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.24 3.957l-8.422 14.06a1.989 1.989 0 0 0 1.7 2.983h16.845a1.989 1.989 0 0 0 1.7 -2.983l-8.423 -14.06a1.989 1.989 0 0 0 -3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></svg>
							<h3>Are you sure?</h3>
							<div class="text-muted">Do you really want to remove the file <b class="h3 text-danger">{{Name}}</b>? What you've done cannot be undone.</div>
							</div>
							<div class="modal-footer">
								<div class="w-100">
									<div class="row">
										<div class="col">
											<button type="button" class="btn w-100" data-bs-dismiss="modal" zero-icon="false">
												Cancel
											</button>
										</div>
										<div class="col">
											<button type="submit" class="btn btn-danger w-100" data-bs-dismiss="modal">
												Delete file
											</button>
										</div>
									</div>
								</div>
							</div>
						</div>
					</form>
				</div>
			  </div>
			{{#if IsMissingFile}}
				<li data-sqlfile-id="{{Id}}" class="file-item nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
					<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
						<button type="submit" form="SqlFileForm-{{Id}}" class="file-link stretched-link btn btn-dark border-0 {{#if IsActive}}active{{/if}}" zx-sync-params="ActiveFile" zx-swap="{{view_state.main_zero_targets}},#filterContainer,#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;" onclick="document.getElementById('{{Id}}-spinnner').classList.remove('d-none'); document.getElementById('{{Id}}-icon').classList.add('d-none');">
							<div id="{{Id}}-spinnner" class="d-none" style="margin-right: 16px; max-width: 20px !important; max-height: 20px !important;">
								<div class="spinner-border spinner-border-sm text-white" role="status"></div>
							</div>
							<div id="{{Id}}-icon">
								<span class="me-2">
									{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
										<!--- BAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
											<!--- COLUMN --->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
										<!--- LINE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
										<!--- PIE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
										<!--- AREA --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
										<!--- SCATTER --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
										<!--- RADAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
									{{else}}
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{/if}}
								</span>
							</div>
							<span class="text-decoration-line-through text-danger">
								{{#if view_state.presentation_mode.is_active}}
									{{#if this.NamedDirectives.Title.ValueRaw}}
										{{this.NamedDirectives.Title.ValueRaw}}
									{{else}}
										{{Name}}
									{{/if}}
								{{else}}
									{{Name}}
								{{/if}}
							</span>
							<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>

						</button>
						<button type="submit" form="CloseSqlFileForm-{{Id}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false" style="z-index: 2;">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
						</button>
					</span>
				</li>
				{{else if IsRenamingFile}}
					<li id="{{Id}}-change-file-name-dropdown" class="nav-item border-info d-flex align-items-center" role="presentation">
						<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
							<span class="file-link border-0 {{#if IsActive}}active{{/if}}" zx-sync-params="ActiveFile" zx-swap="{{view_state.main_zero_targets}},#filterContainer,#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;">
								<span class="me-2">
									{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
										<!--- BAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
											<!--- COLUMN --->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
										<!--- LINE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
										<!--- PIE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
										<!--- AREA --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
										<!--- SCATTER --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
										<!--- RADAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
									{{else}}
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{/if}}
								</span>
							</span>
							<form id="{{Id}}-changeFileNameForm" method="POST" action="/studio/main/changeFileName" style="display:inline;">
								{{#each view_state.params}}
									{{#if this.value}}
											<input type="hidden" name="{{{this.key}}}" value="{{{this.value}}}">
									{{/if}}
								{{/each}}
								<!--- <input type="hidden" name="goto" value="{{view_state.rename_file_go_to}}"/>
								<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/> --->
								<input type="hidden" name="SqlFileFullName" value="{{FullName}}"/>
								<div id="{{Id}}-changeFileNameContainer" class="input-group">
									<input id="{{Id}}-changeFileNameInput" type="text" name="fileName" class="form-control form-control-sm" placeholder="File name" value="{{Name}}">
									<button form="{{Id}}-changeFileNameForm" class="d-none btn btn-primary btn-sm" type="submit">Save</button>
								</div>
							</form>
						</span>
					</li>
					<script>
						// Focus the input on document ready
						document.getElementById('{{Id}}-changeFileNameInput').focus();
					</script>
			{{else}}
				<li data-sqlfile-id="{{Id}}" class="file-item nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white;{{/if}}">

				<!--- Commenting out the original nav link but keeping for troubleshooting purposes. We needed to be
					able to have 2 links within the nav (one to close the file). We had to override the styles to achieve
					this --->
					<!--- <button type="submit" form="SqlFileForm-{{Id}}" class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}" style="">
						<span class="me-2">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
						</span>
						{{Name}}


						<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>

					</button> --->
					<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
						<a 	href="{{OpenLink}}"
							class="file-link stretched-link btn btn-dark border-0 {{#unless IsActive}}text-muted{{/unless}}"
							<!--- zx-swap="#infoPanel,#fileList,#editorPanel,#renderPanel,#openFilesList,#openFilePath" --->
							zx-swap="#infoPanel,#editorCard,#rendererPanel,#openFilePath,#openFilesList,#fileList"
							zx-sync-params="ActiveFile"
							studio-form-links="false"
							zx-link-mode="app"
							zero-icon="false"
							style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1; {{#if IsActive}}pointer-events: none;{{/if}}"
							<!--- onclick="document.getElementById('switchFileProgress{{Id}}').classList.remove('d-none'); document.getElementById('{{Id}}-spinnner').classList.remove('d-none'); document.getElementById('{{Id}}-icon').classList.add('d-none');" --->
							{{#unless IsActive}}
								onclick="document.getElementById('switchFileProgress{{Id}}').classList.remove('d-none');"
							{{/unless}}
						>
							<div id="{{Id}}-spinnner" class="d-none" style="margin-right: 16px; max-width: 20px !important; max-height: 20px !important;">
								<div class="spinner-border spinner-border-sm text-white" role="status"></div>
							</div>
							<div id="{{Id}}-icon">
								<span class="me-2">
									{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
										<!--- BAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
											<!--- COLUMN --->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
										<!--- LINE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
										<!--- PIE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
										<!--- AREA --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
										<!--- SCATTER --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
										<!--- RADAR --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
									{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
										<!--- BUBBLE --->
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
									{{else}}
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
									{{/if}}
								</span>
							</div>
								{{#if view_state.presentation_mode.is_active}}
								{{#if this.NamedDirectives.Title.ValueRaw}}
									{{this.NamedDirectives.Title.ValueRaw}}
								{{else}}
									{{Name}}
								{{/if}}
							{{else}}
								{{Name}}
							{{/if}}
							<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>
						</a>
						<button type="submit" form="CloseSqlFileForm-{{Id}}" class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0" zero-icon="false" style="z-index: 2;">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
						</button>
						<div style="position:absolute; bottom:0px; left:0; width:100%;">
							<div id="switchFileProgress{{Id}}" class="progress progress-sm d-none" style="border-radius:0; height:1px;">
								<div class="progress-bar progress-bar-indeterminate bg-info"></div>
							</div>
						</div>
					</span>

				</li>
			{{/if}}
			{{/unless}}{{/if}}
			{{/each}}
			{{#if data.CurrentSQLFile.IsActiveButNotOpen}}
				{{#with data.CurrentSQLFile}}
					<form id="PreviewCloseSqlFileForm" action="/studio/main/" method="GET" zx-swap="{{../view_state.main_zero_targets}}">
						{{#each CloseUrlParams}}
							{{#if value}}
									<input type="hidden" name="{{{key}}}" value="{{{value}}}">
							{{/if}}
						{{/each}}
					</form>
					{{#if IsMissingFile}}
						<li data-sqlfile-id="{{Id}}" class="file-item nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
							<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
								<button type="submit" form="SqlFileForm-{{Id}}" class="file-link stretched-link btn btn-dark border-0 {{#if IsActive}}active{{/if}}" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;" onclick="document.getElementById('{{Id}}-spinnner').classList.remove('d-none'); document.getElementById('{{Id}}-icon').classList.add('d-none');">
									<div id="{{Id}}-spinnner" class="d-none" style="margin-right: 16px; max-width: 20px !important; max-height: 20px !important;">
										<div class="spinner-border spinner-border-sm text-white" role="status"></div>
									</div>
									<div id="{{Id}}-icon">
										<span class="me-2">
											{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
												<!--- BAR --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
													<!--- COLUMN --->
													<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
												<!--- LINE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
												<!--- PIE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
												<!--- AREA --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
												<!--- SCATTER --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
												<!--- RADAR --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
												<!--- BUBBLE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
												<!--- BUBBLE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
											{{else}}
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
											{{/if}}
										</span>
									</div>

									<span class="open-file-name text-decoration-line-through text-danger"><i>
										{{#if view_state.presentation_mode.is_active}}
											{{#if this.NamedDirectives.Title.ValueRaw}}
													{{this.NamedDirectives.Title.ValueRaw}}
												{{else}}
													{{Name}}
												{{/if}}
										{{else}}
											{{Name}}
										{{/if}}
									</i></span>

									<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>

								</button>
								<button form="PreviewCloseSqlFileForm"
										class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0"
										style="z-index: 2;"
										zx-loader="cursor-wait"
									>
									<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
								</button>
							</span>
						</li>
					{{else}}
						{{#if data.ChangeActiveFileName}}
							<li id="change-file-name-dropdown" class="nav-item border-info d-flex align-items-center" role="presentation">
								<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
									<span class="file-link border-0 {{#if IsActive}}active{{/if}}" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;">
										<span class="me-2">
											{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
												<!--- BAR --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
													<!--- COLUMN --->
													<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
												<!--- LINE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
												<!--- PIE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
												<!--- AREA --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
												<!--- SCATTER --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
												<!--- RADAR --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
												<!--- BUBBLE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
											{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
												<!--- BUBBLE --->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
											{{else}}
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
											{{/if}}
										</span>
									</span>
									<form id="changeFileNameForm" method="POST" action="/studio/main/changeFileName" zx-sync-params="ActiveFile" zx-swap="{{view_state.main_zero_targets}},#filterContainer,#editorCard" style="display:inline;">
										{{#each view_state.params}}
											{{#if this.value}}
													<input type="hidden" name="{{{this.key}}}" value="{{{this.value}}}">
											{{/if}}
										{{/each}}
										<!--- <input type="hidden" name="goto" value="{{view_state.rename_file_go_to}}"/>
										<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/> --->
										<input type="hidden" name="SqlFileFullName" value="{{FullName}}"/>
										<!--- <input type="hidden" name="PackageName" value="{{data.CurrentPackage.UniqueId}}"> --->
										<div id="changeFileNameContainer" class="input-group">
											<input id="changeFileNameInput" type="text" name="fileName" class="form-control form-control-sm" placeholder="File name" value="{{Name}}">
											<button form="changeFileNameForm" class="d-none btn btn-primary btn-sm" type="submit">Save</button>
											<!--- <a href="{{view_state.stop_change_file_name_link}}" class="btn btn-ghost btn-sm">Cancel</a> --->
										</div>
									</form>
								</span>
							</li>
							<script>
								// Focus the input on document ready
								document.getElementById('changeFileNameInput').focus();
							</script>
						{{else}}
							<li data-sqlfile-id="{{Id}}" class="file-item nav-item border-info" role="presentation" style="{{#if IsActive}}border-bottom:2px solid; text-decoration:none; color:white{{/if}}">
								<div id="{{Id}}-file-rightclick-dropdown" class="file-right-click-dropdown" style="display: none; z-index: 9999;">
									<ul class="dropdown-menu show" data-popper-placement="bottom-start" style="position: absolute; inset: 0px auto auto 0px; margin: 0px;">
										<a class="dropdown-item" href="{{view_state.close_all_link}}">
											<svg xmlns="http://www.w3.org/2000/svg" style="z-index:10;" class="icon icon-tabler icon-tabler-square-rounded-x me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
											<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10l4 4m0 -4l-4 4"></path><path d="M12 3c7.2 0 9 1.8 9 9s-1.8 9 -9 9s-9 -1.8 -9 -9s1.8 -9 9 -9z"></path>
											</svg> <span class="me-2">Close All Open Files</span>
										</a>
										<a class="dropdown-item" href="{{CloseAllOtherFilesLink}}">
											<svg xmlns="http://www.w3.org/2000/svg" style="z-index:10;" class="icon icon-tabler icon-tabler-square-rounded-x me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
											<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10l4 4m0 -4l-4 4"></path><path d="M12 3c7.2 0 9 1.8 9 9s-1.8 9 -9 9s-9 -1.8 -9 -9s1.8 -9 9 -9z"></path>
											</svg> <span class="me-2">Close Other Files</span>
										</a>
										{{#if (eq data.ActiveFile this.FullName)}}
											<form method="GET" action="{{view_state.change_file_name_link}}" zx-swap="#openFilesList" > <button type="submit" class="dropdown-item">
											<svg xmlns="http://www.w3.org/2000/svg" style="z-index: 10;" class="icon icon-tabler icon-tabler-file-pencil me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
											<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z"></path><path d="M10 18l5 -5a1.414 1.414 0 0 0 -2 -2l-5 5v2h2z"></path>
											</svg> <span class="me-2">Rename File</span> </button>
											</form>
										{{else}}
											<form method="GET" action="{{RenameFileLink}}" zx-swap="#openFilesList"> <button type="submit" class="dropdown-item">
											<svg xmlns="http://www.w3.org/2000/svg" style="z-index: 10;" class="icon icon-tabler icon-tabler-file-pencil me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
											<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M14 3v4a1 1 0 0 0 1 1h4"></path><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z"></path><path d="M10 18l5 -5a1.414 1.414 0 0 0 -2 -2l-5 5v2h2z"></path>
											</svg> <span class="me-2">Rename File</span> </button>
											</form>
										{{/if}}
									   <button {{#if data.CurrentPackage.IsReadOnly}}disabled{{/if}} type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#delete-sqlfile-modal-{{Id}}">
											<svg class="icon icon-tabler me-2"  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-trash"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 7l16 0" /><path d="M10 11l0 6" /><path d="M14 11l0 6" /><path d="M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2 -2l1 -12" /><path d="M9 7v-3a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v3" /></svg>
											<span class="me-2">Delete File</span>
										</button>
									</ul>
								</div>
								<div class="modal modal-blur fade" id="delete-sqlfile-modal-{{Id}}" tabindex="-1" role="dialog" aria-hidden="true">
									<div class="modal-dialog modal-sm modal-dialog-centered" role="document">
										<form method="POST" action="/studio/main/deleteFile" zx-swap={{view_state.main_zero_targets}} >
											<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
											<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
											<input type="hidden" name="FullName" value="{{FullName}}">
											<div class="modal-content">
												<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
												<div class="modal-status bg-danger"></div>
												<div class="modal-body text-center py-4">
												<svg xmlns="http://www.w3.org/2000/svg" class="icon mb-2 text-danger icon-lg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.24 3.957l-8.422 14.06a1.989 1.989 0 0 0 1.7 2.983h16.845a1.989 1.989 0 0 0 1.7 -2.983l-8.423 -14.06a1.989 1.989 0 0 0 -3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></svg>
												<h3>Are you sure?</h3>
												<div class="text-muted">Do you really want to remove the file <b class="h3 text-danger">{{Name}}</b>? What you've done cannot be undone.</div>
												</div>
												<div class="modal-footer">
													<div class="w-100">
														<div class="row">
															<div class="col">
																<button type="button" class="btn w-100" data-bs-dismiss="modal" zero-icon="false">
																	Cancel
																</button>
															</div>
															<div class="col">
																<button type="submit" class="btn btn-danger w-100" data-bs-dismiss="modal">
																	Delete file
																</button>
															</div>
														</div>
													</div>
												</div>
											</div>
										</form>
									</div>
								  </div>

								<!--- Commenting out the original nav link but keeping for troubleshooting purposes. We needed to be
									able to have 2 links within the nav (one to close the file). We had to override the styles to achieve
									this --->
									<!--- <button type="submit" form="SqlFileForm-{{Id}}" class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}" style="">
										<span class="me-2">
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
										</span>
										{{Name}}


										<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>

									</button> --->
									<span class="nav-link position-relative h-100 m-0 {{#if IsActive}}active{{/if}}">
										<button type="submit" form="SqlFileForm-{{Id}}" class="file-link stretched-link btn btn-dark border-0 {{#if IsActive}}active{{/if}}" zx-sync-params="ActiveFile" zx-swap="{{view_state.main_zero_targets}},#filterContainer,#editorCard" style="text-decoration:none; {{#if IsActive}}color:white{{/if}} margin:0; padding:0; background:none; z-index: 1;" onclick="document.getElementById('{{Id}}-spinnner').classList.remove('d-none'); document.getElementById('{{Id}}-icon').classList.add('d-none');">
											<div id="{{Id}}-spinnner" class="d-none" style="margin-right: 16px; max-width: 20px !important; max-height: 20px !important;">
												<div class="spinner-border spinner-border-sm text-white" role="status"></div>
											</div>
											<div id="{{Id}}-icon">
												<span class="me-2">
													{{#if (eq NamedDirectives.Chart.ValueRaw "bar")}}
															<!--- BAR --->
															<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "column")}}
															<!--- COLUMN --->
															<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "line")}}
														<!--- LINE --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "pie")}}
														<!--- PIE --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "area")}}
														<!--- AREA --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "scatter")}}
														<!--- SCATTER --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "radar")}}
														<!--- RADAR --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "bubble")}}
														<!--- BUBBLE --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
													{{else if (eq NamedDirectives.Chart.ValueRaw "combo")}}
														<!--- BUBBLE --->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
													{{else}}
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
													{{/if}}
												</span>
											</div>

											<span class="open-file-name"><i>
												{{#if view_state.presentation_mode.is_active}}
													{{#if this.NamedDirectives.Title.ValueRaw}}
														{{this.NamedDirectives.Title.ValueRaw}}
													{{else}}
														{{Name}}
													{{/if}}
												{{else}}
													{{Name}}
												{{/if}}
												</i>
											</span>

											<span class="{{#if IsActive}}active{{/if}} status-dot {{#if LastExecutionRequest.IsError}}status-dot-animated status-red{{else}}status-primary{{/if}} ms-2" style="{{#if LastExecutionRequest.IsError}}{{else}}{{#unless IsDirty}}visibility:hidden;{{/unless}}{{/if}}{{#unless IsActive}}opacity:.8;{{/unless}}"></span>

										</button>

										<button form="PreviewCloseSqlFileForm"
												class="btn btn-icon btn-ghost-primary btn-sm ms-2 me-0"
												style="z-index: 2;"
												zx-loader="cursor-wait"
											>
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-x" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
										</button>
									</span>
								</li>
						{{/if}}
					{{/if}}
				{{/with}}
				{{/if}}

			<li id="new-file-dropdown" class="nav-item d-flex align-items-center" role="presentation">
				<form id="createFileForm" method="POST" action="/studio/main/createSqlFile" style="display:inline;" zx-swap="{{view_state.main_zero_targets}},#filterContainer">
					{{#each view_state.params}}
						{{#unless (eq key "PackageName")}}
							{{#if value}}
								<input type="hidden" name="{{{key}}}" value="{{{value}}}">
							{{/if}}
						{{/unless}}
					{{/each}}
					<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
					<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
					<input type="hidden" name="OpenFileAt" value="{{view_state.current_url}}"/>
					<input type="hidden" name="preserve_response" value="view_state.response">
					<!--- {{#if data.CurrentPackage}}
						<input type="hidden" name="PackageName" value="{{data.CurrentPackage.UniqueId}}">
						<div id="createFileContainer" class="input-group d-none">
							<input id="createFileInput" type="text" name="FileName" class="form-control form-control-sm" placeholder="File name" value=".sql">
							<button form="createFileForm" class="btn btn-sm" type="submit">Create</button>
						</div>
					{{/if}} --->
				</form>
				<div class="btn-group" style="position:relative;" {{#if data.CurrentPackage.IsReadOnly}}data-bs-toggle="tooltip" data-bs-placement="bottom" title="{{data.CurrentPackage.FriendlyName}} Folder is Read Only"{{/if}}>
					<!--- <button class="btn btn-ghost-primary btn-sm" type="button" onclick="document.getElementById('createFileContainer').remove('d-none'); document.getElementById('createFileInput').focus();"> --->
						<!--- {{#unless data.CurrentPackage}} --->
							<div class="dropdown">
								<a data-bs-toggle="dropdown" href="#" id="new-file-button" class="btn btn-ghost-primary {{#if data.CurrentPackage.IsReadOnly}}disabled{{/if}}" style="border-radius: 0; padding: var(--tblr-nav-link-padding-y) var(--tblr-nav-link-padding-x);" type="button" zero-icon="false" onclick="document.getElementById('createFileInputDropdown').focus();">
									<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-file-type-sql" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M5 20.25c0 .414 .336 .75 .75 .75h1.25a1 1 0 0 0 1 -1v-1a1 1 0 0 0 -1 -1h-1a1 1 0 0 1 -1 -1v-1a1 1 0 0 1 1 -1h1.25a.75 .75 0 0 1 .75 .75" /><path d="M5 12v-7a2 2 0 0 1 2 -2h7l5 5v4" /><path d="M18 15v6h2" /><path d="M13 15a2 2 0 0 1 2 2v2a2 2 0 1 1 -4 0v-2a2 2 0 0 1 2 -2z" /><path d="M14 20l1.5 1.5" /></svg>
									New
								</a>
								<div class="dropdown-menu">
									<div class="px-2">
										<select form="createFileForm" name="PackageName" class="form-select" onchange="document.getElementById('createFileInputDropdown').focus();" required>
											<option value="" disabled>Select a Folder</option>
											{{#each data.GlobalChartSQLStudio.Packages}}
												{{#unless this.IsFiltered}}
													{{#unless this.IsReadOnly}}
														{{#if (eq data.CurrentPackage.UniqueId this.UniqueId)}}
															<option value="{{this.UniqueId}}" selected>{{this.FriendlyName}}</option>
														{{else}}
															<option value="{{this.UniqueId}}">{{this.FriendlyName}}</option>
														{{/if}}
													{{/unless}}
												{{/unless}}
											{{/each}}
										</select>
									</div>
									<a class="dropdown-item" >
										<input form="createFileForm" id="createFileInputDropdown" type="text" name="FileName" class="form-control form-control-sm" placeholder="File name" value=".sql">
									</a>
									<a class="dropdown-item">
										<button form="createFileForm" class="w-100 btn btn-sm" type="submit">Create</button>
									</a>
								</div>
							</div>
						<!--- {{else}}
							<button {{#if data.CurrentPackage.IsReadOnly}}disabled{{/if}} id="new-file-button" class="btn btn-ghost-primary" style="border-radius: 0; padding: var(--tblr-nav-link-padding-y) var(--tblr-nav-link-padding-x);" type="button" onclick="document.getElementById('createFileContainer').classList.remove('d-none'); this.classList.add('d-none'); document.getElementById('createFileInput').focus();">
								<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-file-type-sql" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M5 20.25c0 .414 .336 .75 .75 .75h1.25a1 1 0 0 0 1 -1v-1a1 1 0 0 0 -1 -1h-1a1 1 0 0 1 -1 -1v-1a1 1 0 0 1 1 -1h1.25a.75 .75 0 0 1 .75 .75" /><path d="M5 12v-7a2 2 0 0 1 2 -2h7l5 5v4" /><path d="M18 15v6h2" /><path d="M13 15a2 2 0 0 1 2 2v2a2 2 0 1 1 -4 0v-2a2 2 0 0 1 2 -2z" /><path d="M14 20l1.5 1.5" /></svg>
								New
							</button>
						{{/unless}} --->
				</li>

			</ul>
			<div class="modal modal-blur fade" id="delete-sqlfile-modal" tabindex="-1" role="dialog" aria-hidden="true">
				<div class="modal-dialog modal-sm modal-dialog-centered" role="document">
					<form method="POST" action="/studio/main/deleteFile" zx-swap={{view_state.main_zero_targets}} >
						<input type="hidden" name="goto" value="{{view_state.current_url}}"/>
						<input type="hidden" name="goto_fail" value="{{view_state.current_url}}"/>
						<input type="hidden" name="FullName" value="{{data.CurrentSqlFile.FullName}}">
						<div class="modal-content">
							<button type="button" zero-icon="false" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
							<div class="modal-status bg-danger"></div>
							<div class="modal-body text-center py-4">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon mb-2 text-danger icon-lg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.24 3.957l-8.422 14.06a1.989 1.989 0 0 0 1.7 2.983h16.845a1.989 1.989 0 0 0 1.7 -2.983l-8.423 -14.06a1.989 1.989 0 0 0 -3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></svg>
							<h3>Are you sure?</h3>
							<div class="text-muted">Do you really want to remove the file <b class="h3 text-danger">{{Name}}</b>? What you've done cannot be undone.</div>
							</div>
							<div class="modal-footer">
								<div class="w-100">
									<div class="row">
										<div class="col">
											<button type="button" class="btn w-100" data-bs-dismiss="modal" zero-icon="false">
												Cancel
											</button>
										</div>
										<div class="col">
											<button type="submit" class="btn btn-danger w-100">
												Delete file
											</button>
										</div>
									</div>
								</div>
							</div>
						</div>
					</form>
				</div>
			  </div>
		</div>
		{{#if data.ChangeActiveFileName}}
			<form method="GET" action="{{view_state.stop_change_file_name_link}}" style="display:inline;" zx-swap="#openFilesList">
				<input type="hidden" name="goto" value="{{view_state.stop_change_file_name_link}}"/>
				<input type="hidden" name="goto_fail" value="{{view_state.stop_change_file_name_link}}"/>
				<!--- Hidden button --->
				<button id="stopChangeFileNameButton" type="submit" class="d-none"></button>
			</form>
		{{else if data.ChangingFileName}}
			<form method="GET" action="{{view_state.stop_change_file_name_link}}" style="display:inline;" zx-swap="#openFilesList">
				<input type="hidden" name="goto" value="{{view_state.stop_change_file_name_link}}"/>
				<input type="hidden" name="goto_fail" value="{{view_state.stop_change_file_name_link}}"/>
				<!--- Hidden button --->
				<button id="stopChangeFileNameButton" type="submit" class="d-none"></button>
			</form>
		{{/if}}
		<script>
			$(document).keydown(function(e) {
				if (e.key === "Escape") {
					// Unfocus all inputs
					$('input').blur();

					// Hide all 'file-right-click-dropdown' class
					$('.file-right-click-dropdown').css('display', 'none');

					// Submit to 'stopChangeFileNameForm' if we are changing a file name
					let stopChangeFileNameButton = $('#stopChangeFileNameButton');
					if (stopChangeFileNameButton.length > 0) {
						stopChangeFileNameButton.click();
					}
					// If 'createFileContainer' element doest have a 'd-none property'
					if ($('#createFileContainer').hasClass('d-none') === false) {
						$('#createFileContainer').addClass('d-none');
						$('#new-file-button').removeClass('d-none');
					}
				}
			});
		</script>
		<script>
			$('.file-item').on('contextmenu', function(e) {
				// If the ctrl or commnand key is pressed, don't show the right click menu
				if (e.ctrlKey || e.metaKey) {
					return;
				}
				$('.file-right-click-dropdown').css('display', 'none');
				var top = e.pageY - 10;
				var left = e.pageX;
				// Get property 'data-sqlfile-id' from the element
				var sqlFileId = $(this).attr('data-sqlfile-id');
				$(`#${sqlFileId}-file-rightclick-dropdown`).css({
					display: "block",
					position: "fixed",
					top: top,
					left: left
				}).addClass("show");

				// Hide all 'file-right-click-dropdown' class when clicking outside of the dropdown
				$(document).click(function() {
					$('.file-right-click-dropdown').css('display', 'none');
				});
				return false; //blocks default Webbrowser right click menu
			});

		</script>