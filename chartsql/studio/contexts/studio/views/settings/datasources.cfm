<div class="card-header">

	<div class="card-title">
		<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
		Datasources
	</div>
	<div class="ms-auto">
		<a href="{{view_state.links.open_create}}" class="btn btn-primary btn-sm">
			<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database-plus" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 6c0 1.657 3.582 3 8 3s8 -1.343 8 -3s-3.582 -3 -8 -3s-8 1.343 -8 3" /><path d="M4 6v6c0 1.657 3.582 3 8 3c1.075 0 2.1 -.08 3.037 -.224" /><path d="M20 12v-6" /><path d="M4 12v6c0 1.657 3.582 3 8 3c.166 0 .331 -.002 .495 -.006" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
			Add Datasource
		</a>
	</div>
</div>
<div class="card-body">
	<!--- <cfdump var="#rc#"> --->
	<div class="card bg-azure-lt text-primary-fg mb-3">
		<div class="card-stamp">
			<div class="card-stamp-icon bg-azure text-primary">
				<!-- Download SVG icon from http://tabler-icons.io/i/star -->
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
			</div>
		</div>
		<div class="card-body">
			<h3 class="card-title">Chart SQL Datasources</h3>
			<p>Datasources are the SQL, NoSQL and API resources that you want to create visualizations for.</p>
		</div>
	</div>

	{{#if view_state.show_create}}
	<form id="datasourceCreate" method="post" action="/studio/datasources/validate">
		<div class="card mb-3">
			<div class="card-header bg-azure">
				<h3 class="card-title">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database-plus" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 6c0 1.657 3.582 3 8 3s8 -1.343 8 -3s-3.582 -3 -8 -3s-8 1.343 -8 3" /><path d="M4 6v6c0 1.657 3.582 3 8 3c1.075 0 2.1 -.08 3.037 -.224" /><path d="M20 12v-6" /><path d="M4 12v6c0 1.657 3.582 3 8 3c.166 0 .331 -.002 .495 -.006" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
					{{#if data.ChartSqlStudio.ConfigureDatasourceTemplate.Type}}Configure {{data.ChartSqlStudio.ConfigureDatasourceTemplate.Type}} Settings{{else}}Add New Datasource{{/if}}
				</h3>
			</div>
			<div class="card-body bg-azure-lt">

				<!--- {{view_state}} --->
				{{#if view_state.create_datasource}}
				{{#if view_state.create_datasource.success}}
				<div class="alert alert-success bg-green-lt">
					{{view_state.create_datasource.message}}
				</div>
				{{else}}
				<div class="alert alert-danger bg-red-lt">
					{{view_state.create_datasource.message}}
				</div>
				{{/if}}
				{{/if}}
				{{#if data.ChartSqlStudio.ConfigureDatasourceTemplate.Type}}

				<input type="hidden" name="goto" value="{{view_state.links.goto_configure}}">
				<input type="hidden" name="goto_fail" value="{{view_state.links.goto_configure}}">
				<input type="hidden" name="type" value="{{data.ChartSqlStudio.ConfigureDatasourceTemplate.Type}}">
				<input type="hidden" name="preserve_request" value="true">
				<input type="hidden" name="preserve_response" value="view_state.create_datasource">
				<input type="hidden" name="Config.submit" value="true">
				<div class="mb-3">
					<label class="form-label required" style="padding-left:3px;">Name</label>
					<div>
						<input type="input" name="Name" class="form-control" aria-describedby="" placeholder="Friendly name" value="{{view_state.Name}}" required>
						<small class="form-hint">A friendly name for your datasource</small>
					</div>
				</div>
				{{#each data.ChartSqlStudio.ConfigureDatasourceTemplate.Fields}}
				<div class="mb-3">
					<label class="form-label {{#if required}}required{{/if}}" style="padding-left:3px;">{{Name}}</label>
					<div>
						<input type="input" name="config.{{Name}}" class="form-control" {{#if required}}required{{/if}} aria-describedby="emailHelp" placeholder="{{Placeholder}}" value="{{#if view_state.config.submit}}{{lookup view_state.config Name}}{{else}}{{default}}{{/if}}">
						<small class="form-hint">{{description}}</small>
					</div>
				</div>
				{{/each}}
				<!--- <button type="submit" class="btn btn-outline-info" zero-icon="false">Test Connection</button> --->

				{{else}}
				<div class="row row-cols-3">
					{{#each data.ChartSQLStudio.AvailableDatasourceTypes}}
					<div class="col p-2">
						<div class="card h-100">
							<div class="card-body text-center">
								<div class="mb-3">
									<span class="avatar avatar-xl rounded" style="">
										<i class="{{IconClass}}"></i>
									</span>
								</div>
								<div class="card-title mb-1">{{Name}}</div>
								<div class="text-secondary">{{Description}}</div>
							</div>
							<a href="{{ConfigureLink}}" class="card-btn">Configure {{Type}}</a>
						</div>
					</div>
					{{/each}}
				</div>
				{{/if}}
			</div>
			<div class="card-footer {{#unless view_state.is_configuring}}d-none{{/unless}}">
				{{#if view_state.validate_datasource}}
				{{#if view_state.validate_datasource.success}}
				<div class="row">
					<div class="col">
						<div class="alert alert-success bg-green-lt">
							The datasource was successfully connected
						</div>
					</div>
				</div>
				{{else}}
				<div class="row">
					<div class="col">
						<div class="alert alert-danger bg-red-lt">
							{{view_state.validate_datasource.message}}
						</div>
					</div>
				</div>
				{{/if}}
				{{/if}}
				<div class="row">
					<div class="col">
						<button zero-icon="true" type="submit" name="submit_overload" value="{'preserve_response':'view_state.validate_datasource'}" class="btn btn-outline-info">Test Connection</button>
					</div>
					<div class="col text-end">
						<a href="{{view_state.links.close_create}}" class="btn btn-outline-secondary me-2">Cancel</a>
						<button formAction="/studio/datasources/create" name="submit_overload" value="{'goto':'/studio/settings/datasources'}" type="submit" class="btn btn-primary">Create</button>
					</div>
				</div>
			</div>
		</div>
	</form>
	{{/if}}

	<h3>Existing Datasources</h3>
	{{#each data.ChartSQLStudio.StudioDatasources}}
	<div class="card mb-3">
		<div class="card-header">
			<div>
				<div class="row align-items-center">
					<div class="col-auto">
						<span class="avatar"><i class="{{MetaData.IconClass}}"></i></span>
					</div>
					<div class="col">
						<div class="card-title">{{Name}}</div>
						<div class="card-subtitle">{{MetaData.Description}}</div>
					</div>
				</div>
			</div>
			<div class="card-actions">
				<a href="{{#if IsEditing}}{{CloseEditLink}}{{else}}{{EditLink}}{{/if}}" class="btn btn-icon btn-ghost-primary">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-settings" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z" /><path d="M9 12a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /></svg>
				</a>
			</div>
		</div>
		{{#if IsEditing}}
		<div class="card-body">
			<form class="card mb-3" method="POST" action="/studio/datasources/{{Name}}">
				<input type="hidden" name="goto" value="{{EditLink}}">
				<input type="hidden" name="goto_fail" value="{{EditLink}}">
				<input type="hidden" name="preserve_response" value="view_state.update_datasource">
				<input type="hidden" name="Type" value="{{Type}}">
				<div class="card-header bg-primary">
					<h3 class="card-title">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-edit" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 7h-1a2 2 0 0 0 -2 2v9a2 2 0 0 0 2 2h9a2 2 0 0 0 2 -2v-1" /><path d="M20.385 6.585a2.1 2.1 0 0 0 -2.97 -2.97l-8.415 8.385v3h3l8.385 -8.415z" /><path d="M16 5l3 3" /></svg>
						Edit {{Name}}
					</h3>
				</div>
				<div class="card-body">
					<div class="mb-3">
						<label class="form-label required" style="padding-left:3px;">Name</label>
						<div>
							<input type="input" name="Name" class="form-control" aria-describedby="" placeholder="Friendly name" value="{{Name}}" required>
							<small class="form-hint">A friendly name for your datasource</small>
						</div>
					</div>
					{{#each MetaData.Fields}}
					<div class="mb-3">
						<label class="form-label {{#if required}}required{{/if}}" style="padding-left:3px;">{{Name}}</label>
						<div>
							<input type="input" name="config.{{Name}}" class="form-control" {{#if required}}required{{/if}} aria-describedby="emailHelp" placeholder="directory path" value="{{value}}">
							<small class="form-hint">{{description}}</small>
						</div>
					</div>
					{{/each}}
				</div>
				<div class="card-footer">
					{{#if view_state.update_datasource.success}}
					<div class="row">
						<div class="col">
							<div class="alert alert-success bg-green-lt">
								The datasource was successfully updated
							</div>
						</div>
					</div>
					{{/if}}
					{{#if view_state.validate_datasource}}
					{{#if view_state.validate_datasource.success}}
					<div class="row">
						<div class="col">
							<div class="alert alert-success bg-green-lt">
								The datasource was successfully connected
							</div>
						</div>
					</div>
					{{else}}
					<div class="row">
						<div class="col">
							<div class="alert alert-danger bg-red-lt">
								{{view_state.validate_datasource.message}}
							</div>
						</div>
					</div>
					{{/if}}
					{{/if}}
					<div class="row">
						<div class="col">
							<button form="removeForm" type="submit" class="btn btn-ghost-info" zero-confirm="Are you sure?">Remove</button>
							<button zero-icon="true" formAction="/studio/datasources/validate" type="submit" name="submit_overload" value="{'preserve_response':'view_state.validate_datasource'}" class="btn btn-outline-info">Test Connection</button>
						</div>
						<div class="col-auto text-end">
							<a href="{{CloseEditLink}}" class="btn btn-outline-secondary me-2">Close</a>
							<button type="submit" class="btn btn-primary">Update</button>
						</div>
					</div>
				</div>
			</form>
			<form id="removeForm" method="POST" action="/studio/datasources/{{Name}}/delete">
				<input type="hidden" name="goto" value="/studio/settings/datasources"/>
				<input type="hidden" name="goto_fail" value="/studio/settings/datasources"/>
			</form>
		</div>
		{{/if}}
	</div>
	{{/each}}
</div>
<!--- <div class="card-footer bg-transparent mt-auto">
	<div class="btn-list justify-content-end">
		<a href="#" class="btn">
			Cancel
		</a>
		<a href="#" class="btn btn-primary">
			Submit
		</a>
	</div>
</div> --->