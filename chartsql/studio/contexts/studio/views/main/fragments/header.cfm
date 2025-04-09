<style>
	.btn {
		/* border-radius:0; */
	}
</style>
<div id="header" class="container-xl py-1 px-2">
	<!--- <script>alert();</script> --->
	<div class="d-flex flex-row align-items-center">
		<div class="col-auto" style="">
			<!-- Avatar -->
			<div class="avatar">
				{{#if data.CurrentWorkspace}}
					<svg class="icon icon-tabler icon-tabler-package" xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-packages"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M2 13.5v5.5l5 3" /><path d="M7 16.545l5 -3.03" /><path d="M17 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M12 19l5 3" /><path d="M17 16.5l5 -3" /><path d="M12 13.5v-5.5l-5 -3l5 -3l5 3v5.5" /><path d="M7 5.03v5.455" /><path d="M12 8l5 -3" /></svg>
				{{else}}
					<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-folder">
						<path stroke="none" d="M0 0h24v24H0z" fill="none" />
						<path d="M5 4h4l3 3h7a2 2 0 0 1 2 2v8a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2" />
					</svg>
				{{/if}}
			</div>
		</div>
		<div class="col ms-2">
			<div class="d-flex flex-row align-items-center">
				<div>
					<!-- Page pre-title -->
					<div class="page-pretitle">
						{{#if data.CurrentPackage}}
							Folder
						{{else}}
							Workspace
						{{/if}}
					</div>
					<h4 class="page-title" style="font-size:.9rem;">
						{{#if data.CurrentWorkspace}}
							{{#if data.CurrentPackage}}
								<ol class="breadcrumb" aria-label="breadcrumbs">
									<li class="breadcrumb-item">
										<a 	href="{{data.CurrentWorkspace.OpenWorkspaceLink}}"
											zx-swap="#aside,#pageContent"
											studio-form-links="false"
											zx-link-mode="app"
											zx-loader="cursor-progress"
										>
											{{data.CurrentWorkspace.FriendlyName}}
										</a>
									</li>
									<li class="breadcrumb-item active" aria-current="page">{{data.CurrentPackage.FriendlyName}}</li>
								</ol>
								<div class="ms-2">
									<a 	href="{{data.CurrentWorkspace.OpenWorkspaceLink}}"
										class="btn btn-icon btn-sm text-muted"
										aria-label="Button"
										title="Close Folder"
										data-bs-toggle="tooltip"
										zx-swap="#aside,#pageContent"
										studio-form-links="false"
										zx-link-mode="app"
										zx-loader="true"
									>
										<!--- close --->
										<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-x"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
									</a>
								</div>
							{{else}}
								{{data.CurrentWorkspace.FriendlyName}}
								<div class="ms-2">
									<a 	href="/studio/main"
										class="btn btn-icon btn-sm text-muted"
										aria-label="Button"
										title="Close Workspace"
										data-bs-toggle="tooltip"
										zx-swap="#aside,#pageContent"
										studio-form-links="false"
										zx-link-mode="app"
										zx-loader="true"
										zero-icon="false"
									>
										<!--- close --->
										<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-x"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
									</a>
								</div>
							{{/if}}
						{{else}}
							<ol class="breadcrumb" aria-label="breadcrumbs">
								<li class="breadcrumb-item">
									<a href="/studio/main"
										zx-swap="#aside,#pageContent"
										studio-form-links="false"
										zx-link-mode="app"
										zx-loader="cursor-progress"
									>Home</a>
								</li>
								<li class="breadcrumb-item active" aria-current="page">{{data.CurrentPackage.FriendlyName}}</li>
							</ol>
							<div class="ms-2">
								<a 	href="/studio/main"
									class="btn btn-icon btn-sm text-muted"
									aria-label="Button"
									title="Close Folder"
									data-bs-toggle="tooltip"
									studio-form-links="false"
									zx-swap="#aside,#pageContent"
									zx-loader="true"
									zero-icon="false"
								>
									<!--- close --->
									<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-x"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
								</a>
							</div>
						{{/if}}
					</h4>
				</div>
			</div>
			<!--- Close Folder button --->
		</div>
		<!-- Page title actions -->
		<div id="headerActions" class="col-auto ms-auto d-print-none">
			<div class="btn-list">
				<div class="dropdown">
					<a class="btn dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-bs-toggle="dropdown" aria-expanded="false" zero-icon="false">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
						{{#each data.ChartSQLStudio.StudioDatasources}}
							{{#if IsSelected}}
								{{Name}}
							{{/if}}
						{{/each}}
					</a>

					<ul class="dropdown-menu" aria-labelledby="dropdownMenuLink">
						{{#each data.ChartSQLStudio.StudioDatasources}}
							<li><a class="dropdown-item" href="{{SelectLink}}" zx-loader="cursor-progress" zx-link-mode="app" studio-form-links="false" zx-swap="#headerActions, #editorPanel, #rendererPanel, #resultsetContent" zx-sync-params="StudioDatasource">{{Name}}</a></li>
						{{/each}}
					</ul>
				</div>
				<!--- <a href="#" class="btn btn-primary d-none d-sm-inline-block" data-bs-toggle="modal" data-bs-target="#modal-report">
					<!-- Download SVG icon from http://tabler-icons.io/i/plus -->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-send" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10 14l11 -11" /><path d="M21 3l-6.5 18a.55 .55 0 0 1 -1 0l-3.5 -7l-7 -3.5a.55 .55 0 0 1 0 -1l18 -6.5" /></svg>
					Publish Folder to Dash
				</a> --->
				<a href="#" class="btn btn-primary d-sm-none btn-icon" data-bs-toggle="modal" data-bs-target="#modal-report" aria-label="Create new report">
					<!-- Download SVG icon from http://tabler-icons.io/i/plus -->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M12 5l0 14"></path><path d="M5 12l14 0"></path></svg>
				</a>
			</div>
		</div>
	</div>
</div>
<!--- <div class="d-flex flex-row align-items-center">
	<div class="flex-grow-1 align-items-center d-flex ms-2">
		<h1>Script Editor</h1>
	</div>
	<div class="justify-content-end d-flex p-3">
		<button class="btn btn-info">Publish</button>
	</div>
</div> --->