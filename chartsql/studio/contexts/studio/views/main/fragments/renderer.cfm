<!--- Styles used by the canvas overlay to draw on the chart --->
<style>
	.paint-canvas {
		/* border: 1px black solid; */
		display: block;
		margin: 1rem;
	}

	.color-picker {
		margin: 1rem 1rem 0 1rem;
	}
</style>
<div id="renderer-card" class="card" style="border-radius:0; width:100%; height:100%">
	<div id="renderer-card-header" class="card-header">
		<ul id="renderer-card-tabs" class="nav nav-tabs card-header-tabs" data-bs-toggle="tabs" role="tablist" style="padding:0;">
			<li class="nav-item" role="presentation">
				<form method="GET" action="{{view_state.render_panel.chart.link}}" zero-target="#rendererPanel">
					<button type="submit" class="nav-link {{#if (eq view_state.render_panel.active_view "chart")}}active{{/if}}">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-eye me-2" style="--tblr-icon-size: 1rem;" width="10" height="10" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10 12a2 2 0 1 0 4 0a2 2 0 0 0 -4 0" /><path d="M21 12c-2.4 4 -5.4 6 -9 6c-3.6 0 -6.6 -2 -9 -6c2.4 -4 5.4 -6 9 -6c3.6 0 6.6 2 9 6" /></svg>
						Preview
					</button>
				</form>
			</li>
			<li class="nav-item" role="presentation">
				<form method="GET" action="{{view_state.render_panel.option.link}}" zero-target="#rendererPanel">
					<button type="submit" class="nav-link {{#if (eq view_state.render_panel.active_view "option")}}active{{/if}}">
						<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-code-dots me-2" style="--tblr-icon-size: 1rem;" width="10" height="10" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M15 12h.01" /><path d="M12 12h.01" /><path d="M9 12h.01" /><path d="M6 19a2 2 0 0 1 -2 -2v-4l-1 -1l1 -1v-4a2 2 0 0 1 2 -2" /><path d="M18 19a2 2 0 0 0 2 -2v-4l1 -1l-1 -1v-4a2 2 0 0 0 -2 -2" /></svg>
						Option
					</button>
				</form>
			</li>
			<!--- <li class="nav-item dropdown">
				<a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Dropdown</a>
				<div class="dropdown-menu" style="">
					<a class="dropdown-item" href="#">
						Action
					</a>
					<a class="dropdown-item" href="#">
						Another action
					</a>
				</div>
			</li> --->
			<!--- <li class="nav-item" data-bs-toggle="tooltip" data-bs-placement="top" title="Maintain 4:3 aspect ratio regardless of editor size">
				<a href="" class="nav-link">
					<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-aspect-ratio" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 5m0 2a2 2 0 0 1 2 -2h14a2 2 0 0 1 2 2v10a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2z" /><path d="M7 12v-3h3" /><path d="M17 12v3h-3" /></svg>
				</a>
			</li> --->
			<!--- <li class="nav-item">
				{{#if view_state.renderer_is_maximized}}
					<form method="GET" action="{{view_state.minimizeLink}}" zero-target="#renderingContainer">
						<input type="hidden" name="goto" value="{{view_state.minimizeLink}}">
						<button type="submit" class="nav-link">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-minimize" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M15 19v-2a2 2 0 0 1 2 -2h2" /><path d="M15 5v2a2 2 0 0 0 2 2h2" /><path d="M5 15h2a2 2 0 0 1 2 2v2" /><path d="M5 9h2a2 2 0 0 0 2 -2v-2" /></svg>
						</button>
					</form>
				{{else}}
					<form method="GET" action="{{view_state.maximizeRendererLink}}" zero-target="#renderingContainer">
						<input type="hidden" name="goto" value="{{view_state.maximizeRendererLink}}">
						<button class="nav-link">
							<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-maximize" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 8v-2a2 2 0 0 1 2 -2h2" /><path d="M4 16v2a2 2 0 0 0 2 2h2" /><path d="M16 4h2a2 2 0 0 1 2 2v2" /><path d="M16 20h2a2 2 0 0 0 2 -2v-2" /></svg>
						</button>
					</form>
				{{/if}}
			</li> --->
			<!--- <li class="ms-auto align-items-center d-flex me-4 mt-1">
				<label class="form-check form-switch" data-bs-toggle="tooltip" data-bs-placement="top" title="Automatically re-render the visualization on change">
					<input class="form-check-input" type="checkbox" {{#if view_state.auto_preview}}checked{{/if}}>
					<span class="form-check-label">Render on Open</span>
				</label>
			</li> --->
		</ul>
	</div>
	<div class="card-body w-100 h-100 p-0">
		<div class="tab-content w-100 h-100 p-0">
			<div id="renderContainer" class="tab-pane active w-100 d-flex p-0" id="tabs-home-4" role="tabpanel" style="height:100%; overflow-y:scroll;">
				{{#if data.CurrentSqlFile.LastExecutionRequest.IsError}}
					<div class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
						<button id="renderingErrorButton" class="btn btn-outline-danger" style="opacity:.4" onclick="document.getElementById('renderingErrorContent').classList.remove('d-none');document.getElementById('renderingErrorButton').classList.add('d-none');">
							Error Querying Data
						</button>
					</div>
					<div id="renderingErrorContent" class="d-none" style="width:100%; height:100%;">
						{{{data.CurrentSqlFile.LastExecutionRequest.ErrorContent}}}
					</div>
				{{else if data.CurrentSqlFile.LastRendering.IsError}}
					<div id="renderingErrorButton" class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
						<button class="btn btn-outline-danger" style="opacity:.4" onclick="document.getElementById('renderingErrorContent').classList.remove('d-none');document.getElementById('renderingErrorButton').classList.add('d-none');">
							Error: {{data.CurrentSqlFile.LastRendering.ErrorMessage}}
						</button>
					</div>
					<div id="renderingErrorContent" class="d-none" style="width:100%; height:100%;">
						{{{data.CurrentSqlFile.LastRendering.ErrorContent}}}
					</div>
				{{else}}
					{{#if data.CurrentSqlFile.Id}}
						{{#if data.CurrentSqlFile.IsMissingFile}}
							<div class="p-2 align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
								<span class="btn btn-outline-info text-muted" style="pointer-events:none; opacity:.4">
									Missing file
								</span>
							</div>
						{{else}}
							{{#if data.CurrentSqlFile.HasDirectiveErrors}}
								<div class="p-2 text-muted align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
									<span class="btn btn-outline-danger" style="pointer-events:none;">Invalid Directives. Check Directives tab for complete details</span>
								</div>
							{{else}}
								{{#if (eq view_state.render_panel.active_view "chart")}}
									<div style="width:100%; height:100%; overflow:scroll;">
										{{{data.CurrentSqlFile.LastRendering.Content}}}
									</div>

										<!--- <div class="d-flex py-3 ms-3" style="height:100%; width:92%;">
											<div class="card d-flex w-100 h-100 m-0">
												<div class="card-header">
													<div>
														<h3 class="card-title">
															Title
														</h3>
														<p class="card-subtitle">
															Subtitle
														</p>
													</div>
												</div>
												<div class="card-body flex-grow-1 p-0">
													<div class="w-100 h-100">
														{{{data.CurrentSqlFile.Preview}}}
													</div>
												</div>
												<div class="card-footer text-muted">
													<div>2 days ago</div>
												</div>
											</div>

										</div>
										<div class="pt-3" style="width:8%; height:100%; display:flex; flex-flow:column; align-items:center;">
											<button class="btn btn-icon btn-outline-secondary">
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-container" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M20 4v.01" /><path d="M20 20v.01" /><path d="M20 16v.01" /><path d="M20 12v.01" /><path d="M20 8v.01" /><path d="M8 4m0 1a1 1 0 0 1 1 -1h6a1 1 0 0 1 1 1v14a1 1 0 0 1 -1 1h-6a1 1 0 0 1 -1 -1z" /><path d="M4 4v.01" /><path d="M4 20v.01" /><path d="M4 16v.01" /><path d="M4 12v.01" /><path d="M4 8v.01" /></svg>
											</button>
										</div> --->

									{{else if (eq view_state.render_panel.active_view "option")}}
											<pre style="width:100%; height:100%;">{{{data.CurrentSqlFile.LastRendering.Option}}}</pre>
								{{/if}}
						{{/if}}
						{{/if}}
					{{else}}
						<div id="renderer-no-open-file" class="p-2 align-items-center justify-content-center" style="display:flex; height:100%; width:100%">
							<span class="btn btn-outline-info text-muted" style="pointer-events:none; opacity:.4">
								No file open
							</span>
						</div>
					{{/if}}
				{{/if}}
			</div>
		</div>
	</div>
</div>