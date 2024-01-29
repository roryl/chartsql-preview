<div class="col-auto">
	<div class="btn-toolbar" role="toolbar" aria-label="Toolbar with button groups">
		<div class="btn-group" role="group" aria-label="First group">
			<button type="button" class="btn btn-icon" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Custom Range">
				<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-calendar-event" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 5m0 2a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2z" /><path d="M16 3l0 4" /><path d="M8 3l0 4" /><path d="M4 11l16 0" /><path d="M8 15h2v2h-2z" /></svg>
			</button>
			{{#each view_state.datetime_slicer_links}}
				<button onclick="document.getElementById('datetimeSlicer{{key}}').click();" type="button" class="btn {{#if isActive}}active{{/if}}" data-bs-toggle="tooltip" zero-icon="false" data-bs-placement="bottom" title="From 1 day ago">{{key}}</button>
				<form method="GET" action="/studio/main" style="display:none;" zero-target="#renderContainer,#header,#fileList,#aside">
					{{#each params}}
						<input type="hidden" name="{{key}}" value="{{value}}">
					{{/each}}
					<button id="datetimeSlicer{{key}}" type="submit" style="display:none;"/></button>
				</form>
			{{/each}}
		</div>
	</div>
</div>