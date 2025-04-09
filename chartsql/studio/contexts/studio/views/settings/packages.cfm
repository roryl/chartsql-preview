<div class="card-header">

	<div class="card-title">
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-folder me-2">
			<path stroke="none" d="M0 0h24v24H0z" fill="none" />
			<path d="M5 4h4l3 3h7a2 2 0 0 1 2 2v8a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2" />
		</svg>
		Folders
	</div>
	<div class="ms-auto">
		<a
			href="{{view_state.links.open_create}}"
			studio-form-links="false"
			zx-swap="#settingsContent"
			zx-link-mode="app"
			class="btn btn-primary btn-sm"
			 >
			<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-folder-plus me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 19h-7a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2h4l3 3h7a2 2 0 0 1 2 2v3.5" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
			Add Folder
		</a>
	</div>
</div>
<div class="card-body">

	<div class="card bg-azure-lt text-primary-fg mb-3">
		<div class="card-stamp">
			<div class="card-stamp-icon bg-azure text-primary">
				<!-- Download SVG icon from http://tabler-icons.io/i/star -->
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l8 4.5l0 9l-8 4.5l-8 -4.5l0 -9l8 -4.5" /><path d="M12 12l8 -4.5" /><path d="M12 12l0 9" /><path d="M12 12l-8 -4.5" /><path d="M16 5.25l-8 4.5" /></svg>
			</div>
		</div>
		<div class="card-body">
			<h3 class="card-title">Chart SQL Folders</h3>
			<p>Folders are a folder of SQL files that share a relationship with one another against a particular type of datasource. You can add any folder from your filesystem as a folder in ChartSQL. All subfolders are a part of the folder.</p>
		</div>
	</div>

	{{#if view_state.show_create}}
	<form class="card mb-3" method="POST" action="/studio/packages" zx-swap="#settingsContent">
		<input type="hidden" name="goto" value="/studio/settings/packages">
		<input type="hidden" name="goto_fail" value="/studio/settings/packages">
		<div class="card-header bg-primary">
			<h3 class="card-title">
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-folder-plus me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 19h-7a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2h4l3 3h7a2 2 0 0 1 2 2v3.5" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>
				Add new Folder
			</h3>
		</div>
		<div class="card-body">
			<div class="mb-3">
				<label class="form-label required">Directory Path</label>
				<div>
					<input type="input" name="FolderPath" class="form-control" aria-describedby="emailHelp" placeholder="directory path">
					<small class="form-hint">Path on your file system when the folder should exist. If it doesn't exist it will be created</small>
				</div>
			</div>
			<div class="mb-3">
				<label class="form-label">Friendly Name</label>
				<div>
					<input type="input" class="form-control" name="FriendlyName" placeholder="Friendly Name">
					<small class="form-hint">
						Friendly title for your folder that will be used in the UI
					</small>
				</div>
			</div>
		</div>
		<div class="card-footer text-end">
			<a href="{{view_state.links.close_create}}" class="btn btn-outline-secondary me-2">Cancel</a>
			<button type="submit" class="btn btn-primary" zx-scroll-to=":nth-last-child(1 of .existingFolder)">Submit</button>
		</div>
	</form>
	{{/if}}

	<h3>Existing Folders</h3>
	{{#each data.ChartSQLStudio.Packages}}
	<div id="folder{{UniqueId}}" class="card mb-3 existingFolder">
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
				{{#if IsDefaultPackage}}
					<span class="d-flex flex-row align-items-center justify-content-center badge bg-cyan-lt me-2">
						<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-pin"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M15 4.5l-4 4l-4 1.5l-1.5 1.5l7 7l1.5 -1.5l1.5 -4l4 -4" /><path d="M9 15l-4.5 4.5" /><path d="M14.5 4l5.5 5.5" /></svg>
						<div class="ms-1">Default Folder</div>
					</span>
				{{/if}}
				{{#if DefaultStudioDatasource}}
				<span class="badge bg-azure-lt me-2"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
					{{DefaultStudioDatasource.Name}}
				</span>
				{{/if}}
				<a href="{{#if IsEditing}}{{CloseEditLink}}{{else}}{{EditLink}}{{/if}}" zx-swap="#folder{{UniqueId}}" zx-link-mode="app" class="btn btn-icon btn-ghost-primary" studio-form-links="false">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-settings" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z" /><path d="M9 12a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /></svg>
				</a>
			</div>
		</div>
		{{#if IsEditing}}
		<div class="card-body">
			<form class="card mb-3" method="POST" action="/studio/packages/{{UniqueId}}" zx-swap="#folder{{UniqueId}}">
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
						<label class="form-label">Directory Path</label>
						<div>
							<input type="input" name="FolderPath" class="form-control" aria-describedby="emailHelp" placeholder="directory path" disabled value="{{Path}}">
							<small class="form-hint">Path on your file system when the folder should exist. If it doesn't exist it will be created</small>
						</div>
					</div>
					<div class="mb-3">
						<label class="form-label">Friendly Name</label>
						<div>
							<input type="input" class="form-control" name="FriendlyName" placeholder="Friendly Name" value="{{FriendlyName}}">
							<small class="form-hint">
								Friendly title for your folder that will be used in the UI
							</small>
						</div>
					</div>
					<div class="mb-3">
						<label class="form-label">Is Read Only</label>
						<div>
							<select class="form-control" placeholder="Yes/No" disabled>
								<option value="false" {{#if IsReadOnly}}{{else}}selected{{/if}}>No</option>
								<option value="true" {{#if IsReadOnly}}selected{{else}}{{/if}}>Yes</option>
							</select>
							<small class="form-hint">
								When a folder is read-only, it cannot be modified
							</small>
						</div>
					</div>
					<div class="mb-3">
						<label class="form-label">Default Datasource</label>
						<div>
							<select class="form-control" name="DefaultStudioDatasource" placeholder="Friendly Name">
								<option value="">None</option>
								{{#each data.ChartSQLStudio.StudioDatasources}}
									{{#select DefaultStudioDatasource.Name}}<option value="{{Name}}">{{Name}}</option>{{/select}}
								{{/each}}
							</select
							<small class="form-hint">
								The default datasource that will be selected whenever the folder is opened
							</small>
						</div>
					</div>
					<hr/>
					<h4 class="subheader">ChartSQL.com Publishing</h4>
					<div class="row mb-3">
						<div class="mb-3 col">
							<label class="form-label">ChartSQL.com Folder ID</label>
							<div>
								<input type="input" class="form-control" name="DashId" placeholder="xxxxxxxx" value="{{DashId}}">
								<small class="form-hint">
									The global unique identifier for this folder provided by ChartSQL.com
								</small>
							</div>
						</div>
						<div class="mb-3 col">
							<label class="form-label">Private Publishing Key</label>
							<div>
								<input type="input" class="form-control" name="PublisherKey" placeholder="xxxxxxxx" value="{{PublisherKey}}">
								<small class="form-hint">
									Do not share. API Key with publishing permissions for this folder on ChartSQL.com. This is your private password to publish to the folder.
								</small>
							</div>
						</div>
					</div>
					<div id="editPackageResults" class="row mb-3">
						<div class="mb-3 col">
							{{#if view_state.verify_publisher_key}}
							{{#if view_state.verify_publisher_key.success}}
							<div class="alert alert-success bg-green-lt">
								<h4 class="alert-title">Successful Verification!</h4>
								<div class="text-secondary">{{view_state.verify_publisher_key.message}}</div>
							</div>
							{{else}}
							<div class="alert alert-danger bg-red-lt">
								<h4 class="alert-title">Error verifying Publisher Key:</h4>
								<div class="text-secondary">{{view_state.verify_publisher_key.message}}</div>
								{{{view_state.verify_publisher_key.data.PublishingRequest.RawContent}}}
							</div>
							{{/if}}
							{{/if}}
							<button
								class="btn btn-outline-info"
								form="verifyPublisherKey"
								zx-loader="true"
								zero-icon="false"
							>Verify Publisher Key</button>
						</div>
					</div>
				</div>
				<div class="card-footer">
					<div class="row">
						<div class="col">
							<button
								form="removeForm"
								type="submit"
								class="btn btn-ghost-info"
								zx-dialog-confirm="Remove the folder from ChartSQL? It will remain on the filesystem"
							>Remove</button>
						</div>
						<div class="col text-end">
							{{#unless IsDefaultPackage}}
								<button form="setAsDefaultPackageForm" type="submit" class="btn btn-outline-info me-2">Set as Default Folder</button>
							{{/unless}}
							<a href="{{CloseEditLink}}" class="btn btn-outline-secondary me-2" zx-swap="#folder{{UniqueId}}">Close</a>
							<button type="submit" class="btn btn-primary">Update</button>
						</div>
					</div>
				</div>
			</form>
			<form
				id="verifyPublisherKey"
				method="POST"
				action="/studio/packages/{{UniqueId}}/verifyPublisherKey"
				zx-swap="#editPackageResults"
			>
				<input type="hidden" name="goto" value="{{EditLink}}">
				<input type="hidden" name="goto_fail" value="{{EditLink}}">
				<input type="hidden" name="preserve_response" value="view_state.verify_publisher_key">
			</form>
			<form id="setAsDefaultPackageForm" method="POST" action="/studio/packages/{{UniqueId}}" zx-swap="#folder{{UniqueId}}">
				<input type="hidden" name="setAsDefaultPackage" value="true">
				<input type="hidden" name="goto" value="{{EditLink}}">
				<input type="hidden" name="goto_fail" value="{{EditLink}}">
			</form>
			<form
				id="removeForm"
				method="POST"
				action="/studio/packages/{{UniqueId}}/delete"
				zx-swap="#settingsContent"
			>
				<input type="hidden" name="goto" value="/studio/settings/packages"/>
				<input type="hidden" name="goto_fail" value="/studio/settings/packages"/>
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