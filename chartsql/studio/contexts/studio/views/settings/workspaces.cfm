<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2-bootstrap-5-theme/1.3.0/select2-bootstrap-5-theme.min.css" integrity="sha512-z/90a5SWiu4MWVelb5+ny7sAayYUfMmdXKEAbpj27PfdkamNdyI3hcjxPxkOPbrXoKIm7r9V2mElt5f1OtVhqA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<style>



</style>
<div class="card-header">

	<div class="card-title">
		<svg class="icon icon-tabler icon-tabler-package me-2" xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-packages"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M2 13.5v5.5l5 3" /><path d="M7 16.545l5 -3.03" /><path d="M17 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M12 19l5 3" /><path d="M17 16.5l5 -3" /><path d="M12 13.5v-5.5l-5 -3l5 -3l5 3v5.5" /><path d="M7 5.03v5.455" /><path d="M12 8l5 -3" /></svg>
		Workspace
	</div>
	<div class="ms-auto">
		<a
			href="{{view_state.links.open_create}}" class="btn btn-primary btn-sm"
			zx-swap="#workspaces"
			zx-link-mode="app"
			studio-form-links="false"
			zero-icon="false"
		>
			<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package-plus me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 19h-7a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2h4l3 3h7a2 2 0 0 1 2 2v3.5" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
			Add Workspace
		</a>
	</div>
</div>
<div id="workspaces" class="card-body">

	<div class="card bg-azure-lt text-primary-fg mb-3">
		<div class="card-stamp">
			<div class="card-stamp-icon bg-azure text-primary">
				<!-- Download SVG icon from http://tabler-icons.io/i/star -->
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l8 4.5l0 9l-8 4.5l-8 -4.5l0 -9l8 -4.5" /><path d="M12 12l8 -4.5" /><path d="M12 12l0 9" /><path d="M12 12l-8 -4.5" /><path d="M16 5.25l-8 4.5" /></svg>
			</div>
		</div>
		<div class="card-body">
			<h3 class="card-title">Chart SQL Workspaces</h3>
			<p>Groups related folders into one.</p>
		</div>
	</div>

	{{#if view_state.show_create}}
	<form
		class="card mb-3"
		method="POST"
		action="/studio/workspaces"
		zx-swap="#workspaces"
	>
		<input type="hidden" name="goto" value="/studio/settings/workspaces">
		<input type="hidden" name="goto_fail" value="/studio/settings/workspaces">
		<div class="card-header bg-primary">
			<h3 class="card-title">
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package-plus me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 19h-7a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2h4l3 3h7a2 2 0 0 1 2 2v3.5" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
				Add new Workspace
			</h3>
		</div>
		<div class="card-body">
			<div class="mb-3">
				<label class="form-label">Friendly Name</label>
				<div>
					<input type="input" class="form-control" name="FriendlyName" placeholder="Friendly Name">
					<small class="form-hint">
						Friendly title for your Workspace that will be used in the UI
					</small>
				</div>
			</div>
		</div>
		<div class="card-footer text-end">
			<a 	href="{{view_state.links.close_create}}"
				class="btn btn-outline-secondary me-2"
				zx-swap="#workspaces"
				zx-link-mode="app"
				studio-form-links="false"
			>Cancel</a>
			<button type="submit" class="btn btn-primary">Submit</button>
		</div>
	</form>
	{{/if}}

	<h3>Workspaces</h3>
	{{#each data.ChartSQLStudio.Workspaces}}
	<div id="workspace-container-{{this.UniqueId}}" class="card mb-3">
		<div class="card-header">
			<div>
				<h3 class="card-title">
					{{#if FriendlyName}}
					{{FriendlyName}}
					{{else}}
					{{UniqueId}}
					{{/if}}
				</h3>
				{{#if FriendlyName}}
				<p class="card-subtitle">
					{{UniqueId}}
				</p>
				{{/if}}
			</div>
			<div class="ms-auto d-flex align-items-center">
				<a  href="{{#if IsEditing}}{{CloseEditLink}}{{else}}{{EditLink}}{{/if}}"
					class="btn btn-icon btn-ghost-primary"
					zx-swap="#workspace-container-{{this.UniqueId}}"
					zx-link-mode="app"
					studio-form-links="false"
				>
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-settings" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z" /><path d="M9 12a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /></svg>
				</a>
			</div>
		</div>
		{{#if IsEditing}}
		<div class="card-body">
			<form
				class="card mb-3"
				method="POST"
				action="/studio/workspaces/{{UniqueId}}"
				zx-swap="#workspace-container-{{this.UniqueId}}"
			>
				<input type="hidden" name="goto" value="{{EditLink}}">
				<input type="hidden" name="goto_fail" value="{{EditLink}}">
				<div class="card-header bg-primary">
					<h3 class="card-title">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-edit" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 7h-1a2 2 0 0 0 -2 2v9a2 2 0 0 0 2 2h9a2 2 0 0 0 2 -2v-1" /><path d="M20.385 6.585a2.1 2.1 0 0 0 -2.97 -2.97l-8.415 8.385v3h3l8.385 -8.415z" /><path d="M16 5l3 3" /></svg>
						Edit {{FriendlyName}}
					</h3>
				</div>
				<div class="card-body">
					<h4 class="subheader">Basic Settings</h4>
					<div class="mb-3">
						<label class="form-label">Friendly Name</label>
						<div>
							<div class="input-group">
								<input type="input" class="form-control" name="FriendlyName" placeholder="Friendly Name" value="{{FriendlyName}}">
								<button type="submit" class="btn text-muted">Change Friendly Name</button>
							</div>
							<small class="form-hint">
								Friendly title for your Workspace that will be used in the UI
							</small>
						</div>
					</div>
                    <div class="mb-3 w-100">
						<label class="form-label">Folders</label>
						<div>
							<small class="form-hint">
								The folders that are part of this workspace
							</small>
							<div class="input-group">
								<select form="create-workspace-package-{{this.UniqueId}}" class="form-select" name="PackageId">
									{{#each data.GlobalChartSQLStudio.Packages}}
										<option value="{{this.UniqueId}}">{{this.FriendlyName}}</option>
									{{/each}}
								</select>
								<button form="create-workspace-package-{{this.UniqueId}}" class="btn text-muted">Add Folder</button>
							</div>
						</div>
					</div>
                    <div class="mb-3 w-100">
						<div>
							<div id="packages-table-{{UniqueId}}" class="table-responsive">
								<table class="table table-vcenter">
								  <thead>
									<tr>
									  <th>Folder Name</th>
									  <th>Default Studio Datasource</th>
									  <th class="w-1">Actions</th>
									</tr>
								  </thead>
								  <tbody>
									{{#each this.WorkspacePackages}}
										<tr>
											<td>{{this.Package.FriendlyName}}</td>
											<td class="text-secondary">
												<div class="d-flex flex-row" style="max-width: 200px;">
													<input form="update-workspace-package-{{../UniqueId}}-{{this.Package.UniqueId}}" type="hidden" name="PackageId" value="{{this.Package.UniqueId}}"/>
													<select form="update-workspace-package-{{../UniqueId}}-{{this.Package.UniqueId}}" class="form-select me-2" name="DefaultStudioDatasource">
														{{#if this.DefaultStudioDatasource}}
															<option value="{{this.DefaultStudioDatasource.Name}}" selected>{{this.DefaultStudioDatasource.Name}} (current)</option>
														{{else}}
															<option value="" selected>None (current)</option>
														{{/if}}
														{{#each data.GlobalChartSQLStudio.StudioDatasources}}
															{{#if (eq this.DefaultStudioDatasource.Name this.Name)}}
																<option value="{{this.Name}}">{{this.Name}}</option>
															{{else}}
																<option value="{{this.Name}}">{{this.Name}}</option>
															{{/if}}
														{{/each}}
													</select>
													<button
														form="update-workspace-package-{{../UniqueId}}-{{this.Package.UniqueId}}"
														class="btn btn-sm primary"
														zero-icon="false"
													>Update</button>
												</div>
											</td>
											<td>
												<button
													form="remove-workspace-package-{{this.Package.UniqueId}}"
													class="btn btn-link btn-sm"
													zx-dialog-confirm="Are you sure you want to remove this folder from the workspace?"
													zero-icon="false"
												>Remove</button>
											</td>
										</tr>
									{{/each}}
								  </tbody>
								</table>
							  </div>
						</div>
						{{#unless this.WorkspacePackages.[0]}}
							<h4 class="text-muted text-center">No folders</h4>
						{{/unless}}
					</div>
					<hr/>
				<div class="card-footer">
					<div class="row">
						<div class="col">
							<button
								form="removeForm-{{this.UniqueId}}"
								type="submit"
								class="btn btn-ghost-warning"
								zx-dialog-confirm="Are you sure you want to delete this workspace?"
							>Remove
							</button>
							<a href="{{this.OpenLink}}" class="btn btn-ghost-info">Open Workspace</a>
						</div>
						<div class="col text-end">
							<a href="{{CloseEditLink}}" class="btn btn-outline-secondary me-2" zx-swap="#workspace-container-{{this.UniqueId}}">Close</a>
						</div>
					</div>
				</div>
			</form>
		</div>
		{{/if}}
		{{#each this.WorkspacePackages}}
			<form
				id="remove-workspace-package-{{this.Package.UniqueId}}"
				method="POST"
				action="/studio/workspaces/{{../UniqueId}}/removePackage"
				zx-swap="#workspace-container-{{../UniqueId}}"
			>
				<input form="remove-workspace-package-{{this.Package.UniqueId}}" type="hidden" name="PackageId" value="{{this.Package.UniqueId}}"/>
				<input type="hidden" name="goto" value="/studio/settings/workspaces?EditWorkspace={{../UniqueId}}"/>
				<input type="hidden" name="goto_fail" value="/studio/settings/workspaces?EditWorkspace={{../UniqueId}}"/>
			</form>
			<form
				id="update-workspace-package-{{../UniqueId}}-{{this.Package.UniqueId}}"
				method="POST"
				action="/studio/workspaces/{{../UniqueId}}/updateWorkspacePackage"
				zx-swap="#workspace-container-{{../UniqueId}}"
			>
				<input type="hidden" name="goto" value="/studio/settings/workspaces?EditWorkspace={{../UniqueId}}"/>
				<input type="hidden" name="goto_fail" value="/studio/settings/workspaces?EditWorkspace={{../UniqueId}}"/>
			</form>
		{{/each}}
		<form
			id="create-workspace-package-{{this.UniqueId}}"
			method="POST"
			action="/studio/workspaces/{{this.UniqueId}}/addPackage"
			zx-swap="#workspace-container-{{this.UniqueId}}"
		>
			<input type="hidden" name="goto" value="/studio/settings/workspaces?EditWorkspace={{this.UniqueId}}"/>
			<input type="hidden" name="goto_fail" value="/studio/settings/workspaces?EditWorkspace={{this.UniqueId}}"/>
		</form>
		<form id="removeForm-{{this.UniqueId}}" method="POST" action="/studio/workspaces/{{this.UniqueId}}/delete" zx-swap="#workspaces">
			<input type="hidden" name="goto" value="/studio/settings/workspaces"/>
			<input type="hidden" name="goto_fail" value="/studio/settings/workspaces"/>
		</form>
	</div>
	{{/each}}
</div>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.9.2/umd/popper.min.js" integrity="sha512-2rNj2KJ+D8s1ceNasTIex6z4HWyOnEYLVC3FigGOmyQCZc2eBXKgOxQmo3oKLHyfcj53uz4QMsRCWNbLd32Q1g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script>
	// On document ready
	$(document).ready(function() {
		// Initialize select2
		$('.select2-multiple').select2({
			multiple: true,
			theme: 'bootstrap-5'
		});
	});
</script>