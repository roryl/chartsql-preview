<style>
	.btn {
		/* border-radius:0; */
	}
</style>
<div id="header" class="container-xl py-1">
	<!--- <script>alert();</script> --->
	<div class="d-flex flex-row align-items-center">
		<div class="col-auto" style="">
			<!-- Avatar -->
			<div class="avatar">
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
					<path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M12 3l8 4.5l0 9l-8 4.5l-8 -4.5l0 -9l8 -4.5"></path><path d="M12 12l8 -4.5"></path><path d="M12 12l0 9"></path><path d="M12 12l-8 -4.5"></path><path d="M16 5.25l-8 4.5"></path>
				   </svg>
			</div>
		</div>
		<div class="col ms-2">
			<!-- Page pre-title -->
			<div class="page-pretitle">
				Package
			</div>
			<h2 class="page-title">
				{{data.CurrentPackage.FriendlyName}}
			</h2>
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
							<li><a class="dropdown-item" href="{{SelectLink}}">{{Name}}</a></li>
						{{/each}}
					</ul>
				</div>
				<!--- <a href="#" class="btn btn-primary d-none d-sm-inline-block" data-bs-toggle="modal" data-bs-target="#modal-report">
					<!-- Download SVG icon from http://tabler-icons.io/i/plus -->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-send" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10 14l11 -11" /><path d="M21 3l-6.5 18a.55 .55 0 0 1 -1 0l-3.5 -7l-7 -3.5a.55 .55 0 0 1 0 -1l18 -6.5" /></svg>
					Publish Package to Dash
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