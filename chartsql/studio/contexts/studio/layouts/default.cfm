<!doctype html>
<!--
	* Tabler - Premium and Open Source dashboard template with responsive and high quality UI.
	* @version 1.0.0-beta19
	* @link https://tabler.io
	* Copyright 2018-2023 The Tabler Authors
	* Copyright 2018-2023 codecalm.net Paweł Kuna
	* Licensed under MIT (https://github.com/tabler/tabler/blob/master/LICENSE)
-->
<cf_handlebars context="#rc#">
	<html lang="en" style="scroll-behavior: smooth;">
		<head>
			<meta charset="utf-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
			<meta http-equiv="X-UA-Compatible" content="ie=edge"/>
			{{#if data.CurrentPackage}}
				<title id="headTitle">{{data.CurrentPackage.FriendlyName}}</title>
			{{else}}
				<title id="headTitle">ChartSQL</title>
			{{/if}}
			<!-- CSS files -->
			<link href="/assets/vendor/tabler/dist/css/tabler.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-flags.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-payments.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-vendors.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/demo.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/datatables/datatables.min.css?1684106062" rel="stylesheet"/>

			<!--- Tabler Webfont Icons. Used when we want to programaticallty display icons based on names which is hard to do with SVG --->
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css" />


			<!-- CodeMirror CSS -->
			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css">
			<!-- CodeMirror Theme CSS -->
			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/theme/dracula.min.css">
			<!-- Bootstrap Bundle with Popper -->
			<!--- <script src="https://cdn.jsdelivr.net/npm/bootstrap@5/dist/js/bootstrap.bundle.min.js"></script> --->
			<!-- CodeMirror JS and SQL Language Mode -->
			<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/sql/sql.min.js"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/javascript/javascript.min.js"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/search/searchcursor.min.js" integrity="sha512-+ZfZDC9gi1y9Xoxi9UUsSp+5k+AcFE0TRNjI0pfaAHQ7VZTaaoEpBZp9q9OvHdSomOze/7s5w27rcsYpT6xU6g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/comment/comment.min.js" integrity="sha512-UaJ8Lcadz5cc5mkWmdU8cJr0wMn7d8AZX5A24IqVGUd1MZzPJTq9dLLW6I102iljTcdB39YvVcCgBhM0raGAZQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
			<script src="/assets/editor/js/PresentationMode.js"></script>

			<!--- Jquery CDN --->
			<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
			<!--- Cookies library --->
			<script src="https://cdn.jsdelivr.net/npm/js-cookie@rc/dist/js.cookie.min.js"></script>

			<!--- Split JS --->
			<script src="https://cdnjs.cloudflare.com/ajax/libs/split.js/1.6.0/split.min.js"></script>

			<!--- Apache eCharts --->
			<script src="/assets/vendor/apache-echarts/echarts.min.js"></script>

			<!--- ZeroJS --->
			<script src="/zero/zerojs/src/zsx.js"></script>
			<link rel="stylesheet" href="/zero/zerojs/src/zsx.css">

			<script>
				// Create a global variable to store the ChartSQLStudio javascript widgets
				// that will be created throughout the application
				var ChartSQLStudio = ChartSQLStudio || {};
			</script>

			<style>
				@import url('https://rsms.me/inter/inter.css');
				:root {
					--tblr-font-sans-serif: 'Inter Var', -apple-system, BlinkMacSystemFont, San Francisco, Segoe UI, Roboto, Helvetica Neue, sans-serif;
				}
				body {
					font-feature-settings: "cv03", "cv04", "cv11";
				}

				.split {
					display: flex;
					flex-direction: row;
				}

				.splitVertical {
					display: flex;
					flex-direction: column;
				}

				.gutter {
					background-color: var(--tblr-bg-surface-tertiary);
					background-repeat: no-repeat;
					background-position: 50%;
				}

				.gutter.gutter-horizontal {
					background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAYAAADkftS9AAAAIklEQVQoU2M4c+bMfxAGAgYYmwGrIIiDjrELjpo5aiZeMwF+yNnOs5KSvgAAAABJRU5ErkJggg==');
					cursor: col-resize;
				}

				.gutter.gutter-vertical {
					background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAFAQMAAABo7865AAAABlBMVEVHcEzMzMzyAv2sAAAAAXRSTlMAQObYZgAAABBJREFUeF5jOAMEEAIEEFwAn3kMwcB6I2AAAAAASUVORK5CYII=');
					cursor: row-resize;
				}

				/**
				* ---------------------------------------
				* VERTICAL NAVIGATION HIDING
				* ---------------------------------------
				* Override the default tabler design to collapse the menu. I used GPT to assist with this.
				* When the .nav-bar is added to the asize, it hide the default elements. We also needed to add
				* .left-collapsed to the page-wrapper to achieve the same affect.
				*
				* We will still need to clean up the regular collapsed menu and reopen the menu
				* when any of the menu buttons are clicked
				*/
				.navbar-collapsed {
					width: 55px !important; /* Adjust the width as necessary to fit your icons */
					transition: width 0.3s; /* Smooth transition for the collapsing action */
				}

				.navbar-collapsed .navbar-brand,
				.navbar-collapsed .nav-link span.nav-link-title,
				.navbar-collapsed .dropdown-menu {
					display: none; /* Hide brand, labels, and dropdown menus */
				}

				.navbar-collapsed .navbar-nav .nav-link {
					text-align: center; /* Center the icons vertically */
				}

				.navbar-collapsed .navbar-nav .nav-item {
					margin: 0;
					padding: 0.1rem 0; /* Adjust padding for items */
				}

				.navbar-toggler {
					/* Adjust the toggle button style if needed */
				}

				div.left-collapsed {
					margin-left:55px !important;
				}

				.navbar-collapsed-restore {
					display:none !important;
				}

				.navbar-collapsed .navbar-collapsed-restore {
					display:block !important;
				}

				.leftcollapsed.dropdown-toggle:after {
					content: "";
					display: inline-block;
					vertical-align: 0.306em;
					width: 0.36em;
					height: 0.36em;
					border-bottom: none;
					border-left: none;
					margin-right: 0.1em;
					margin-left: 0.4em;
				}

				.CodeMirror-scrollbar-filler {
					display: none !important;
				}

				.navbar-nav * .nav-item {
					min-height: 40px !important;
				}

				* {
					scrollbar-width: thin;
				}

				.bottom-menu-items {
						position:absolute;
						bottom: 10px;
						width:100%;
					}

				.nav-tabs .nav-link {
					border-radius:0;
					border-top:none;
				}

				.nav-tabs:first-child {
					border-left:none;
				}
				.nav-item {
					border-radius:0;
				}

				.card {
					box-shadow:none;
				}

				.nav-link-icon-custom {
					color: #929DAB !important;
					margin-right: 10px;
					max-height: 20px !important;
					max-width: 20px !important;
				}

				.nav-link-icon-custom-loading-indicator {
					margin-right: 4px !important;
				}

				/* .nav-link.dropdown-toggle {
					height: 36px !important;
					padding: 8px 16px !important;
				} */

				/* Add a btn-xs which copies the size of badges */
				.btn-xs {
					--tblr-badge-padding-x: 0.5em;
					--tblr-badge-padding-y: 0.25em;
					--tblr-badge-font-size: 85.714285%;
					--tblr-badge-font-weight: var(--tblr-font-weight-medium);
					--tblr-badge-border-radius: var(--tblr-border-radius);
					display: inline-block;
					padding: var(--tblr-badge-padding-y) var(--tblr-badge-padding-x);
					font-size: var(--tblr-badge-font-size);
					font-weight: var(--tblr-badge-font-weight);
					line-height: 1;
					text-align: center;
					white-space: nowrap;
					vertical-align: baseline;
					border-radius: var(--tblr-badge-border-radius);
				}

				.navbar-vertical .dropdown-toggle.show {
					padding-top: 10px !important;
				}

				.tooltip {
					z-index: 999999 !important;
				}

			</style>
			<script>
				function toggleNavbar() {
					var navbar = document.querySelector('.navbar-vertical');
					navbar.classList.toggle('navbar-collapsed');
					var pageWrapper = document.getElementById('pageContent');
					pageWrapper.classList.toggle('left-collapsed');

					var dropdowns = document.querySelectorAll('.navbar-vertical .dropdown-toggle');
					dropdowns.forEach(function(dropdown) {
						dropdown.classList.toggle('leftcollapsed');
					});


					//if the navbar is collapsed, save into ZeroClient
					if (navbar.classList.contains('navbar-collapsed')) {
						ZeroClient.set('navbar_collapsed', 'true');
					} else {
						ZeroClient.set('navbar_collapsed', 'false');
					}

					// Submit the hidden-toggle-navbar-button button
					// document.getElementById('hidden-toggle-navbar-button').click();
					if (window != null && window.chartHandle != null) {
						window.chartHandle.resize();
					}
				}

				function toggleAllSeries(checkbox) {
					const option = window.chartHandle.getOption();
					if (option && option.series) {
						const seriesNames = option.series.map(s => s.name).filter(Boolean); // Get all series names
						// Get the new value of the toggleAllSeries checkbox
						const isChecked = checkbox.checked;
						if (isChecked) {
							// If the checkbox is checked, select all series
							seriesNames.forEach(seriesName => {
								window.chartHandle.dispatchAction({
									type: 'legendSelect',
									name: seriesName,
								});
							});
						} else {
							// If the checkbox is not checked, unselect all series
							seriesNames.forEach(seriesName => {
								window.chartHandle.dispatchAction({
									type: 'legendUnSelect',
									name: seriesName,
								});
							});
						}
					}
				}

				//If the navbar is collapsed, clicking any nav-item should open it
				// $(document).on('click', '.navbar-collapsed .nav-item', function() {
				// 	//console.log('clicked');
				// 	//console.log($(this).find('.dropdown-toggle'));
				// 	$(this).find('.dropdown-toggle').dropdown('toggle');
				// });
			</script>
		</head>
		<body class="layout-fluid" data-bs-theme="dark">
			<div class="page">
				<!-- Sidebar -->
				<aside id="aside" class="{{#if client_state.navbar_collapsed}}navbar-collapsed{{/if}} navbar navbar-vertical navbar-expand-lg" data-bs-theme="dark" style="overflow-y:unset; z-index: 9999 !important;">

					<div class="container-fluid h-100">
						<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#sidebar-menu" aria-controls="sidebar-menu" aria-expanded="false" aria-label="Toggle navigation">
							<span class="navbar-toggler-icon"></span>
						</button>
						<h1 class="navbar-brand navbar-brand-autodark" style="">

							<div class="d-flex align-items-center">

								<!--- <img src="/assets/img/logo-white.png" height="25" alt="Tabler" class="me-3" style="cursor: pointer;"  onclick="toggleNavbar();"> --->
								<img src="/studio/main/logo" height="25" alt="Logo" class="me-3" style="cursor: pointer;"  onclick="toggleNavbar();">

								<a class="" onclick="toggleNavbar();" style="">
									<span class="" type="button" style="">
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-menu-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 6l16 0" /><path d="M4 12l16 0" /><path d="M4 18l16 0" /></svg>
									</span>
								</a>

							</div>
						</h1>
						<h1 class="navbar-brand navbar-brand-autodark navbar-collapsed-restore" style="">
							<a class="nav-link d-flex align-items-center justify-content-center" onclick="toggleNavbar();" style="">
								<span class="" type="button" style="">
									<!--- <img src="/assets/img/mark-white.png" height="25" alt="ChartSQL Studio" class=""> --->
									<img src="/studio/main/mascot" height="25" alt="Mascot Logo" class="">
								</span>
							</a>
						</h1>
						<div class="collapse navbar-collapse" id="sidebar-menu">
							<ul id="applicationMenu" class="navbar-nav h-100">

								<div id="main-menu-nav-items" class="h-100">


								<li id="editorMenuLink" class="nav-item d-flex justify-content-center align-items-between {{#if (eq action "studio:main.list")}}active{{/if}}">
									<a
										href="{{view_state.editor_link}}"
										class="nav-link"
										zero-icon-class="nav-link-icon-custom-loading-indicator"
										studio-form-links="false"
										zx-swap="#aside,#pageContent,#globalSearchModal"
										zx-loader="true"
										zx-link-mode="app"
									>
										<span class="nav-link-icon-custom d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Chart Editor"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-code" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 8l-4 4l4 4" /><path d="M17 8l4 4l-4 4" /><path d="M14 4l-4 16" /></svg>
										</span>
										<span class="nav-link-title">
											Editor
										</span>
									</a>
								</li>

								<li class="nav-item d-flex justify-content-center align-items-between dropdown">
									<a id="packages-menu-item" class="nav-link dropdown-toggle {{#if data.GlobalChartSQLStudio.IsPackagesDropdownOpened}}show{{/if}} {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false">
										<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Switch Charts Folder"><!-- Download SVG icon from http://tabler-icons.io/i/star -->
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-folder me-2">
												<path stroke="none" d="M0 0h24v24H0z" fill="none" />
												<path d="M5 4h4l3 3h7a2 2 0 0 1 2 2v8a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2" />
											</svg>
										</span>
										<span class="nav-link-title">
											Folders
										</span>
									</a>
									<div class="dropdown-menu {{#if data.GlobalChartSQLStudio.IsPackagesDropdownOpened}}show{{/if}}">
										<div class="dropdown-menu-columns">
											<div class="dropdown-menu-column">
												{{#each data.GlobalChartSQLStudio.Packages}}
													<a
														href="{{OpenPackageLink}}"
														class="dropdown-item w-100 {{#if this.IsFiltered}}d-none{{/if}}"
														zx-swap="#aside,#pageContent,#globalSearchModal"
														zx-loader="true"
														zx-link-mode="app"
														studio-form-links="false"
													>
														{{FriendlyName}}
													</a>
													<!--- <form {{#if this.IsFiltered}}class="d-none"{{/if}} action="/studio/main" method="GET" zero-target="#aside,#pageContent,#globalSearchModal">
														{{#each OpenPackageParams}}
															<input type="hidden" name="{{key}}" value="{{value}}">
														{{/each}}
														<button type="submit" class="dropdown-item w-100">
															<!--- {{this}} --->
															{{FriendlyName}}
														</button>
													</form> --->
												{{/each}}
											</div>
										</div>
									</div>
								</li>
								<li class="nav-item d-flex justify-content-center align-items-between dropdown d-none">
									<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-help" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
										<span class="nav-link-icon-custom d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-layout-dashboard" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 4h6v8h-6z" /><path d="M4 16h6v4h-6z" /><path d="M14 12h6v8h-6z" /><path d="M14 4h6v4h-6z" /></svg>
										</span>
										<span class="nav-link-title">
											Dashboards
										</span>
									</a>
									<div class="dropdown-menu">
										<a class="dropdown-item" href="./changelog.html">
											Getting Started
										</a>
										<a class="dropdown-item" href="https://github.com/tabler/tabler" target="_blank" rel="noopener">
											Reference
										</a>
									</div>
								</li>
								<div class="d-flex flex-column" style="height: 80%;">
								{{#each MenuItems}}
									{{#if (neq Location 'bottom')}}
										{{#if HasChildren}}
											<li class="nav-item d-flex justify-content-center align-items-between dropdown">
												<a id="{{Name}}-menu-item" class="nav-link dropdown-toggle {{#if IsOpen}}show{{/if}} {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-help" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
													<span class="nav-link-icon-custom d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
														<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
													</span>
													<span class="nav-link-title">
														{{Name}}
													</span>
												</a>
												<div class="dropdown-menu {{#if IsOpen}}show{{/if}}">
													{{#each Children}}
														<a
															class="dropdown-item"
															href="{{Link}}"
															studio-form-links="false"
															zx-swap="#aside,#pageContent"
															zx-loader="true"
															zx-link-mode="app"
														>
															{{#if IconClass}}<i class="{{IconClass}}"></i>&nbsp;{{/if}}{{Name}}
														</a>
													{{/each}}
												</div>
											</li>
										{{else}}
											<li class="nav-item d-flex justify-content-center align-items-between {{#if IsActive}}active{{/if}}">
												<a 	class="nav-link"
													href="{{Link}}"
													{{#if OpenNewTab}}target="_blank"{{/if}}
													studio-form-links="false"
													zx-swap="#aside,#pageContent"
													zx-loader="true"
													zx-link-mode="app"
												>
													<span class="nav-link-icon-custom d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
														<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
													</span>
													<span class="nav-link-title">
														{{Name}}
													</span>
												</a>
											</li>
										{{/if}}
									{{/if}}
								{{/each}}
								<div class="bottom-menu-items">
									<li class="nav-item d-flex justify-content-center align-items-between dropdown">
										<a id="workspaces-menu-item" class="nav-link dropdown-toggle {{#if data.GlobalChartSQLStudio.isWorkspacesDropdownOpened}}show{{/if}} {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false">
											<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Switch Workspaces">
												<svg class="icon icon-tabler icon-tabler-package me-2" xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-packages"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M2 13.5v5.5l5 3" /><path d="M7 16.545l5 -3.03" /><path d="M17 16.5l-5 -3l5 -3l5 3v5.5l-5 3z" /><path d="M12 19l5 3" /><path d="M17 16.5l5 -3" /><path d="M12 13.5v-5.5l-5 -3l5 -3l5 3v5.5" /><path d="M7 5.03v5.455" /><path d="M12 8l5 -3" /></svg>
											</span>
											<span class="nav-link-title">
												Workspaces
											</span>
										</a>
										<div class="dropdown-menu {{#if data.GlobalChartSQLStudio.isWorkspacesDropdownOpened}}show{{/if}}">
											<div class="dropdown-menu-columns">
												<div class="dropdown-menu-column">
													{{#each data.GlobalChartSQLStudio.Workspaces}}
														<a 	href="{{OpenWorkspaceLink}}"
															class="dropdown-item w-100"
															zx-swap="#aside,#pageContent,#globalSearchModal"
															zx-loader="true"
															zx-link-mode="app"
															studio-form-links="false"
														>
															{{FriendlyName}}
														</a>
														<!--- <form action="/studio/main" method="GET" zero-target="#aside,#pageContent,#globalSearchModal">
															{{#each OpenWorkspaceParams}}
																<input type="hidden" name="{{key}}" value="{{value}}">
															{{/each}}
															<button type="submit" class="dropdown-item w-100">
																<!--- {{this}} --->
																{{FriendlyName}}
															</button>
														</form> --->
													{{/each}}
												</div>
											</div>
										</div>
									</li>
									{{#each MenuItems}}
										{{#if (eq Location 'bottom')}}
											{{#if HasChildren}}
												<li class="nav-item d-flex justify-content-center align-items-between dropdown">
													<a  id="{{Name}}-menu-item"
														class="nav-link dropdown-toggle {{#if IsOpen}}show{{/if}} {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}"
														href="#navbar-help"
														data-bs-toggle="dropdown"
														data-bs-auto-close="false" role="button"
														aria-expanded="false"
													>
														<span class="nav-link-icon-custom d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
															<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
														</span>
														<span class="nav-link-title">
															{{Name}}
														</span>
													</a>
													<div class="dropdown-menu {{#if IsOpen}}show{{/if}}">
														{{#each Children}}
															<a 	class="dropdown-item"
																href="{{Link}}"
																studio-form-links="false"
																zx-swap="#aside,#pageContent,#globalSearchModal"
																zx-loader="true"
																zx-link-mode="app"
															>
																{{#if IconClass}}<i class="{{IconClass}}"></i>&nbsp;{{/if}}{{Name}}
															</a>
														{{/each}}
													</div>
												</li>
											{{else}}
												<li class="nav-item d-flex justify-content-center align-items-between {{#if IsActive}}active{{/if}}">
													<a
														class="nav-link"
														href="{{Link}}"
														{{#if OpenNewTab}}
															target="_blank"
														{{else}}
															zx-swap="#aside,#pageContent"
															zx-loader="true"
														{{/if}}
													>
														<span class="nav-link-icon-custom d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
															<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
														</span>
														<span class="nav-link-title">
															{{Name}}
														</span>
													</a>
												</li>
											{{/if}}
										{{/if}}
									{{/each}}
								</div>
								</div>
								</div>
							</ul>
						</div>
					</div>
					<script>
						var openedDropdownMenuItems = "{{view_state.opened_dropdown_menu_items}}";
							$( document ).ready(function() {
								// Add event click to every 'dropdown-toggle'
								$('.dropdown-toggle').click(function () {
									var elementId = this.id;
									if (openedDropdownMenuItems == "") {
										openedDropdownMenuItems = [];
									} else if (typeof openedDropdownMenuItems === 'string') {
										openedDropdownMenuItems = openedDropdownMenuItems.split(',');
									}

									if (!this.classList.contains('show')) {
										openedDropdownMenuItems = openedDropdownMenuItems.filter(item => item !== elementId);
									} else {
										if (!openedDropdownMenuItems.includes(elementId)) {
											openedDropdownMenuItems.push(elementId);
										}
									}
									ZeroClient.set('opened_dropdown_menu_items', openedDropdownMenuItems.join(','));

									if (this.classList.contains('leftcollapsed')) {
										if (!this.classList.contains('show')) {
											$(this).dropdown('toggle')
										}
										toggleNavbar();
									}
								});
							});
					</script>
				</aside>
				<div id="pageContent" class="page-wrapper {{#if client_state.navbar_collapsed}}left-collapsed{{/if}}" style="height:100vh; overflow:hidden;">
					<cfoutput>#body#</cfoutput>
				</div>
			</div>
			<div class="modal" id="globalSearchModal" tabindex="-1" style="z-index: 9999 !important;">
			  <div class="modal-dialog modal-dialog-scrollable" role="document">
				<div class="modal-content">
				  <div class="modal-header px-0 mx-0">
					<h5 class="modal-title w-100 h1 px-0 mx-0">
						<form class="w-100" id="globalSearchForm" method="GET" action="/studio/main" zx-swap="#globalSearchResults">
							{{#each view_state.params}}
								{{#unless (eq key "globalSearchQuery")}}
									<input type="hidden" name="{{key}}" value="{{value}}">
								{{/unless}}
							{{/each}}
						  <div class="input-group flex-1 w-100 px-2">
							  <input class="form-control w-100 mx-0" id="globalSearchQueryInput" name="globalSearchQuery" onfocus="this.select();" autocomplete="off" oninput="document.getElementById('globalSearchSubmitButton').click();" value="{{#if view_state.globalSearchQuery}}{{view_state.globalSearchQuery}}{{/if}}" type="text" placeholder="Search..." aria-label="Search...">
							  <button id="globalSearchSubmitButton" type="submit" class="d-none"></button>
							  <!--- <button type="button" class="btn btn-link text-decoration-none" onclick="document.getElementById('globalSearchQueryInput').value = ''; document.getElementById('globalSearchSubmitButton').click();">
								<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-x"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
							  </button> --->
						  </div>
					  </form>
					</h5>
				  </div>
				  <div class="modal-body" style="height: 75vh;">
					<div class="d-flex flex-row justify-content-center">
						<span class="text-muted text-center">Find packages, datasources, files and settings very quickly</span>
					</div>
					  <div id="globalSearchResults" class="mt-3">
						{{#each data.globalSearchResults.resultsByType.packages}}
							<div class="d-flex flex-row justify-content-between align-items-center m-0 h5 arrow-selectable">
								<div>
									<i class="ti ti-box me-2"></i>
									<a href="{{metadata.OpenPackageLink}}" class="text-decoration-none">{{name}}</a>
								</div>
								<div>
									<a href="/studio/settings/packages?EditPackage={{metadata.uniqueid}}" class="m-0 btn btn-ghost-secondary btn-sm" style="cursor: pointer;">configure</a>
								</div>
							</div>
						{{/each}}
						{{#if data.globalSearchResults.resultsByType.packages.[0]}}
							<div class="mb-1" style="background-color: grey; width: 100%; height: 0.5px;"></div>
						{{/if}}
						{{#each data.globalSearchResults.resultsByType.datasources}}
							<div class="d-flex flex-row justify-content-between align-items-center m-0 h5 arrow-selectable">
								<div>
									<i class="ti ti-database me-2"></i>
									<a href="{{metadata.SelectLink}}" class="text-decoration-none">{{name}}</a>
								</div>
								<div>
									<a href="/studio/settings/datasources?EditStudioDatasource={{metadata.name}}" class="m-0 btn btn-ghost-secondary btn-sm" style="cursor: pointer;">configure</a>
								</div>
							</div>
						{{/each}}
						{{#if data.globalSearchResults.resultsByType.datasources.[0]}}
							<div class="mt-1 mb-2" style="background-color: grey; width: 100%; height: 0.5px;"></div>
						{{/if}}
						{{#each data.globalSearchResults.resultsByType.sqlfiles}}
							<div class="d-flex align-items-center justify-content-between h5 arrow-selectable m-0">
								<div class="d-flex align-items-center">
									<i class="ti ti-file me-2"></i>
									<a href="{{metadata.OpenLink}}" class="text-decoration-none">{{name}}</a>
								</div>
								{{#if metadata.IsOpen}}
									<div class="d-flex align-items-center">
										<div class="text-primary ms-3">opened</div>
									</div>
								{{/if}}
							</div>
						{{/each}}

						<!--- {{#each data.globalSearchResults.results}}
							<div class="d-flex align-items-center mt-3 h5">
								{{#if (eq entityType 'package')}}
									<i class="ti ti-box me-2"></i>
								{{/if}}
								{{#if (eq entityType 'datasource')}}
									<i class="ti ti-database me-2"></i>
								{{/if}}
								{{#if (eq entityType 'sqlfile')}}
									<i class="ti ti-file me-2"></i>
								{{/if}}
								{{#if (eq entityType 'setting')}}
									<i class="ti ti-gear me-2"></i>
								{{/if}}
									<a href="{{openLink}}" class="text-decoration-none">{{name}}</a>
								{{#if (eq entityType 'package')}}
									<a href="/studio/settings/packages?EditPackage={{metadata.uniqueid}}" class="badge badge-outline text-azure ms-2" style="cursor: pointer;">configure</a>
								{{else if (eq entityType 'datasource')}}
									<a href="/studio/settings/datasources?EditStudioDatasource={{metadata.name}}" class="badge badge-outline text-azure ms-2" style="cursor: pointer;">configure</a>
								{{/if}}
							</div>
						{{/each}} --->
						{{#unless data.globalSearchResults.results.[0]}}
							<div class="text-center text-muted w-100 my-3">
								No results
							</div>
						{{/unless}}
					</div>
				  </div>
				</div>
			  </div>
			</div>
			<div id="modalErrorContainer">
			{{#if view_state.response.view_state.error}}
				<div class="modal modal-blur fade" id="error-modal" tabindex="-1" role="dialog" aria-hidden="true">
					<div class="modal-dialog modal-sm modal-dialog-centered" role="document">
					<div class="modal-content">
						<div class="modal-status bg-danger"></div>
						<div class="modal-body text-center py-4">
						<!-- Download SVG icon from http://tabler-icons.io/i/alert-triangle -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon mb-2 text-danger icon-lg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.24 3.957l-8.422 14.06a1.989 1.989 0 0 0 1.7 2.983h16.845a1.989 1.989 0 0 0 1.7 -2.983l-8.423 -14.06a1.989 1.989 0 0 0 -3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></svg>
						<h3>Something happened</h3>
						{{#if view_state.response.view_state.error.message}}
							<div class="text-danger">{{view_state.response.view_state.error.message}}</div>
						{{else}}
							<div class="text-muted">An error happened while executing</div>
						{{/if}}
						</div>
						<div class="modal-footer">
						<div class="w-100">
							<div class="row">
							<div class="col">
								<a href="#" class="btn w-100" data-bs-dismiss="modal">
									Okay
								</a>
								</div>
							</div>
						</div>
						</div>
					</div>
					</div>
				</div>
				<script>
					$(document).ready(function() {
						$('#error-modal').modal('show');
					});
				</script>
			{{else if view_state.error}}
				<div class="modal modal-blur fade" id="error-modal" tabindex="-1" role="dialog" aria-hidden="true">
					<div class="modal-dialog modal-sm modal-dialog-centered" role="document">
					<div class="modal-content">
						<div class="modal-status bg-danger"></div>
						<div class="modal-body text-center py-4">
						<!-- Download SVG icon from http://tabler-icons.io/i/alert-triangle -->
						<svg xmlns="http://www.w3.org/2000/svg" class="icon mb-2 text-danger icon-lg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M10.24 3.957l-8.422 14.06a1.989 1.989 0 0 0 1.7 2.983h16.845a1.989 1.989 0 0 0 1.7 -2.983l-8.423 -14.06a1.989 1.989 0 0 0 -3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" /></svg>
						<h3>Something happened</h3>
						{{#if view_state.error.message}}
							<div class="text-danger">{{{view_state.error.message}}}</div>
						{{else}}
							<div class="text-muted">An error happened while executing</div>
						{{/if}}
						</div>
						<div class="modal-footer">
						<div class="w-100">
							<div class="row">
							<div class="col">
								<a href="#" class="btn w-100" data-bs-dismiss="modal">
									Okay
								</a>
								</div>
							</div>
						</div>
						</div>
					</div>
					</div>
				</div>
				<script>
					$(document).ready(function() {
						$('#error-modal').modal('show');
					});
				</script>
			{{/if}}
			</div>
			<style>
				.arrow-selectable {
					height: 25px;
					margin-bottom: 5px !important;
				}
				.arrow-selected {
					background-color: #8a8a8a3a;
				}
			</style>
			<!-- Libs JS -->
			<script src="/assets/vendor/tabler/dist/libs/apexcharts/dist/apexcharts.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/js/jsvectormap.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/maps/world.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/maps/world-merc.js?1684106062" defer></script>
			<!-- Tabler Core -->
			<script src="/assets/vendor/tabler/dist/js/tabler.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/js/demo.min.js?1684106062" defer></script>
			<script>

				// Add event listener to every arrow keys up and down
				document.addEventListener('keydown', function(event) {
					// If modal is not opening ignore the event
					if (!document.getElementById('globalSearchModal').classList.contains('show')) {
						return;
					}
					// Every item with class "arrow-selectable" is going to be able to be selected with the arrow keys
					// if it is selected then we will add the class "arrow-selected" to it

					// Get all arrow-selectable items
					var arrowSelectableItems = document.querySelectorAll('.arrow-selectable');

					// If is empty ignore the event
					if (arrowSelectableItems.length === 0) {
						return;
					}

					if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
						// Get the index of the selected item
						var selectedIndex = -1;
						for (var i = 0; i < arrowSelectableItems.length; i++) {
							if (arrowSelectableItems[i].classList.contains('arrow-selected')) {
								selectedIndex = i;
								break;
							}
						}

						// Remove the arrow-selected class from all items
						arrowSelectableItems.forEach(function(item) {
							item.classList.remove('arrow-selected');
						});

						let selectedItem;

						// If no item is selected, select the first one
						if (selectedIndex === -1) {
							selectedItem = arrowSelectableItems[0];
							selectedItem.classList.add('arrow-selected');
						} else {
							// If the arrow key is down, select the next item
							if (event.key === 'ArrowDown') {
								if (selectedIndex + 1 < arrowSelectableItems.length) {
									selectedItem = arrowSelectableItems[selectedIndex + 1];
									selectedItem.classList.add('arrow-selected');
								} else {
									selectedItem = arrowSelectableItems[0];
									selectedItem.classList.add('arrow-selected');
								}
							} else {
								// If the arrow key is up, select the previous item
								if (selectedIndex - 1 >= 0) {
									selectedItem = arrowSelectableItems[selectedIndex - 1];
									selectedItem.classList.add('arrow-selected');
								} else {
									selectedItem = arrowSelectableItems[arrowSelectableItems.length - 1];
									selectedItem.classList.add('arrow-selected');
								}
							}
						}

						selectedItem.scrollIntoView({behavior: "auto", block: "end"});
						// Add an event that if we pressed Enter it will click on the first link of the selected item
						document.addEventListener('keydown', function(event) {
							if (!document.getElementById('globalSearchModal').classList.contains('show')) {
								return;
							}
							if (event.key === 'Enter') {
								let selectedItem = document.querySelector('.arrow-selected');
								if (selectedItem) {
									selectedItem.querySelector('a').click();
								}
							}
						});
					}
				});

			</script>
			<script>
				// Open globalSearchModal when presing Cmd + P or Ctrl + P
				// and prevent default browser print dialog
				document.addEventListener('keydown', function(event) {
					if ((event.ctrlKey || event.metaKey) && event.key === 'p') {
						event.preventDefault();
						let modal = $('#globalSearchModal');

						if (modal.hasClass('show')) {
							modal.modal('hide');
							// Clear input
							document.getElementById('globalSearchQueryInput').value = '';
							// And click on form submit button
							document.getElementById('globalSearchSubmitButton').click();
						} else {
							document.getElementById('globalSearchQueryInput').value = '';
							document.getElementById('globalSearchSubmitButton').click();
							modal.modal('show');
							$('#globalSearchQueryInput').focus();
						}
					}
				});

				// If modal closes, clear input
				$('#globalSearchModal').on('hidden.bs.modal', function (e) {
					document.getElementById('globalSearchQueryInput').value = '';
					document.getElementById('globalSearchSubmitButton').click();
				});
			</script>
			<script zx-script-skip="true">
				let zsxjs = new ZsxJs();
				zsxjs.init(document, {
					/* options */
				});
			</script>
			<script>
				ZERO_JS_ICON_CLASS = "spinner-border spinner-border-sm me-2";
				ZERO_JS_LOG_LEVEL = "debug";
				ZERO_TARGET_CALLBACK = function(target) {
					// Remove all tooltips and popovers to prevent stuck tooltips
					$('.tooltip').remove();
					$('.popover').remove();

					var tooltipTriggerList = [].slice.call(target[0].querySelectorAll('[data-bs-toggle="tooltip"]'))
					var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
						return new bootstrap.Tooltip(tooltipTriggerEl)
					});

					var popoverTriggerList = [].slice.call(target[0].querySelectorAll('[data-bs-toggle="popover"]'))
					var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
						return new bootstrap.Popover(popoverTriggerEl)
					});

					//Call the zuxjs setup functions on the target
					zsxjs._setupDialog(target[0]);
					zsxjs._setupSwap(target[0]);
				}

				document.addEventListener('zsx.zx-swap.after', function(event) {

					// Get the new element from the swap event
					// var element = event.detail.newElement;

					var tooltips = document.querySelectorAll('.tooltip');
					var popovers = document.querySelectorAll('.popover');

					tooltips.forEach(function(tooltip){
						tooltip.remove();
					});

					popovers.forEach(function(popover){
						popover.remove();
					});

					var tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
					tooltipTriggerList.forEach(function(tooltipTriggerEl){
						return new bootstrap.Tooltip(tooltipTriggerEl)
					})

					var popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
					popoverTriggerList.forEach(function (popoverTriggerEl) {
						return new bootstrap.Popover(popoverTriggerEl)
					});
				})
			</script>
			<!--- <style>
				.spinner-border-sm {
					width:.9rem !important;
					height:.9rem !important;
				}
			</style> --->
			<script src="/zero/zero.js"></script>
			<script src="/assets/js/form-links.js" defer></script>
			<script src="/assets/vendor/datatables/datatables.min.js?1684106062"></script>
			<!--- ZERO AUTO FORMS
				These forms are used to call refreshes of elements on the page using the ZeroJs library.
				They should be targted by zero-target whenever a refresh is needed.
			--->
			<div id="refreshMemoryUsage">
				{{#if client_state.REFRESH_CPU}}
					<form method="POST" action="/studio/main/keyPerformanceInfo" zero-auto="1" zx-swap="#memoryUsage,#refreshMemoryUsage">
					</form>
				{{/if}}
			</div>
		</body>
	</html>
</cf_handlebars>