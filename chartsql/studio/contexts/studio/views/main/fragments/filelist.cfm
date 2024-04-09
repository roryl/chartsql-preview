<div id="fileList" class="list-group list-group-flush" style="max-height:10vh;" data-current-open-files="{{data.CurrentOpenFiles}}" data-current-active-file="{{data.CurrentActiveFile}}">
	<div class="list-group-header sticky-top">A</div>
	{{#each data.CurrentPackage.SqlFiles}}
	<form class="open-file-form" method="get" action="/studio/main/" class="text-body d-block" style="text-decoration:none;"
	zero-target="{{view_state.main_zero_targets}},#filterContainer"
	>
		{{#each UrlParams}}
			{{#if value}}
					<input type="hidden" name="{{{key}}}" value="{{{value}}}">
			{{/if}}
		{{/each}}
		<button class="open-file" data-sqlfile-id="{{this.Id}}" id="openFile{{@index}}" type="submit" style="display:none;"/></button>
	</form>
	<form id="keep-file-open-form-{{this.Id}}" class="keep-file-open" method="get" action="/studio/main/" class="text-body d-block" style="text-decoration:none;"
	zero-target="{{view_state.main_zero_targets}},#filterContainer"
	>
		{{#each OpenUrlParams}}
			{{#if value}}
					<input type="hidden" name="{{{key}}}" value="{{{value}}}">
			{{/if}}
		{{/each}}
		<button class="open-file" id="keepFileOpenButton{{@index}}" type="submit" style="display:none;"/></button>
	</form>

	<div class="list-group-item {{#if IsActive}}active{{/if}}" onclick="if (isPressingCmdOrCtrl) {document.getElementById('keepFileOpenButton{{@index}}').click();} else { document.getElementById('openFile{{@index}}').click(); }; document.getElementById('fileOpenProgress{{Id}}').classList.remove('d-none');" style="{{#if IsFiltered}}display:none;{{/if}}cursor: pointer; {{#if IsOpen}}border-right:solid 1px #4299e1;{{/if}}">
		<div class="row">
			<div class="col text-truncate">
				<span class="">
					{{#if NamedDirectives.Title.ValueRaw}}
						{{NamedDirectives.Title.ValueRaw}}
					{{else}}
						{{name}}
					{{/if}}
					</span>

				<div class="text-secondary text-truncate mt-n1">
					{{#if NamedDirectives.Subtitle.ValueRaw}}
						{{NamedDirectives.Subtitle.ValueRaw}}
					{{else}}
						{{name}}
					{{/if}}
				</div>
			</div>
			<div class="col-auto">
				{{#if (eq NamedDirectives.Chart.value "bar")}}
					<span class="avatar">
						<!--- BAR --->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 18l14 0" /><path d="M9 9l3 3l-3 3" /><path d="M14 15l3 3l-3 3" /><path d="M3 3l0 18" /><path d="M3 12l9 0" /><path d="M18 3l3 3l-3 3" /><path d="M3 6l18 0" /></svg>
					</span>
				{{else if (eq NamedDirectives.Chart.value "column")}}
					<span class="avatar">
						<!--- COLUMN --->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-arrows-vertical" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 21v-14" /><path d="M9 15l3 -3l3 3" /><path d="M15 10l3 -3l3 3" /><path d="M3 21l18 0" /><path d="M12 21l0 -9" /><path d="M3 6l3 -3l3 3" /><path d="M6 21v-18" /></svg>
					</span>
				{{else if (eq NamedDirectives.Chart.value "line")}}
				<span class="avatar">
					<!--- LINE --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-line" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "pie")}}
				<span class="avatar">
					<!--- PIE --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-pie-3" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12l-6.5 5.5" /><path d="M12 3v9h9" /><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "area")}}
				<span class="avatar">
					<!--- AREA --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-area" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 19l16 0" /><path d="M4 15l4 -6l4 2l4 -5l4 4l0 5l-16 0" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "scatter")}}
				<span class="avatar">
					<!--- SCATTER --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-circles" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9.5 9.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /><path d="M14.5 14.5m-5.5 0a5.5 5.5 0 1 0 11 0a5.5 5.5 0 1 0 -11 0" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "radar")}}
				<span class="avatar">
					<!--- RADAR --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-radar" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l9.5 7l-3.5 11h-12l-3.5 -11z" /><path d="M12 7.5l5.5 4l-2.5 5.5h-6.5l-2 -5.5z" /><path d="M2.5 10l9.5 3l9.5 -3" /><path d="M12 3v10l6 8" /><path d="M6 21l6 -8" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "bubble")}}
				<span class="avatar">
					<!--- BUBBLE --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-bubble" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 16m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" /><path d="M16 19m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" /><path d="M14.5 7.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" /></svg>
				</span>
				{{else if (eq NamedDirectives.Chart.value "combo")}}
				<span class="avatar">
					<!--- BUBBLE --->
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-chart-histogram" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 3v18h18" /><path d="M20 18v3" /><path d="M16 16v5" /><path d="M12 13v8" /><path d="M8 16v5" /><path d="M3 11c6 0 5 -5 9 -5s3 5 9 5" /></svg>
				</span>
				{{/if}}

			</div>
		</div>
		<div style="position:absolute; bottom:0; left:0; width:100%;">
			<div id="fileOpenProgress{{Id}}" class="progress progress-sm d-none" style="height:2px;">
				<div class="progress-bar progress-bar-indeterminate"></div>
			</div>
		</div>
	</div>
	{{/each}}
	<div class="list-group-header sticky-top">B</div>
</div>
<script>
	var isPressingCmdOrCtrl = false;

	$(document).keydown(function(e) {
		if (e.which == 91 || e.which == 17) {
			isPressingCmdOrCtrl = true;
		}
	});

	$(document).keyup(function(e) {
		if (e.which == 91 || e.which == 17) {
			isPressingCmdOrCtrl = false;
		}
	});
</script>
<script src="/assets/js/filter-files.js" defer></script>