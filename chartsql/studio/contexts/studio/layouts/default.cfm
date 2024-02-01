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
	<html lang="en">
		<head>
			<meta charset="utf-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
			<meta http-equiv="X-UA-Compatible" content="ie=edge"/>
			<title>Sales Insights - Delaware Limo Research</title>
			<!-- CSS files -->
			<link href="/assets/vendor/tabler/dist/css/tabler.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-flags.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-payments.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/tabler-vendors.min.css?1684106062" rel="stylesheet"/>
			<link href="/assets/vendor/tabler/dist/css/demo.min.css?1684106062" rel="stylesheet"/>

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

			<!--- Jquery CDN --->
			<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
			<!--- Cookies library --->
			<script src="https://cdn.jsdelivr.net/npm/js-cookie@rc/dist/js.cookie.min.js"></script>

			<!--- Split JS --->
			<script src="https://cdnjs.cloudflare.com/ajax/libs/split.js/1.6.0/split.min.js"></script>

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
				}

				//If the navbar is collapsed, clicking any nav-item should open it
				// $(document).on('click', '.navbar-collapsed .nav-item', function() {
				// 	//console.log('clicked');
				// 	//console.log($(this).find('.dropdown-toggle'));
				// 	$(this).find('.dropdown-toggle').dropdown('toggle');
				// });
			</script>
		</head>
		<body class="{{#if data.CurrentPackage}}layout-fluid{{/if}}" data-bs-theme="dark">
			<div class="page">
				<!-- Sidebar -->
				<aside id="aside" class="{{#if client_state.navbar_collapsed}}navbar-collapsed{{/if}} navbar navbar-vertical navbar-expand-lg" data-bs-theme="dark" style="overflow-y:unset;">

					<div class="container-fluid h-100">
						<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#sidebar-menu" aria-controls="sidebar-menu" aria-expanded="false" aria-label="Toggle navigation">
							<span class="navbar-toggler-icon"></span>
						</button>
						<h1 class="navbar-brand navbar-brand-autodark mt-3">
							<span href="" style="display:flex; flex-flow:row; align-items:center;">
								<img src="/assets/img/logo.fw.png" width="175" alt="Tabler" class="me-3">
								<!--- <img src="/assets/img/mascot.fw.png" width="50" alt="Tabler" class="me-3">
								<div style="margin-top:2px;">ChartSQL<br /><i class="text-uppercase text-info" style="">Studio</i></div> --->
								<a class="" onclick="toggleNavbar();" style="margin-top:0px; margin-left:0px;">
									<span class="" type="button" style="">
										<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-menu-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 6l16 0" /><path d="M4 12l16 0" /><path d="M4 18l16 0" /></svg>
									</span>
								</a>
							</span>
						</h1>
						<div class="collapse navbar-collapse" id="sidebar-menu">
							<ul id="applicationMenu" class="navbar-nav pt-lg-3 h-100">
								<li class="nav-item navbar-collapsed-restore">
									<a class="nav-link" onclick="toggleNavbar();" style="width:70px; margin-left:-5px; margin-top:-10px; margin-bottom:10px;">
										<span class="nav-link-icon d-md-none d-lg-inline-block" type="button" style="width:70px;">
											<!--- <img src="/assets/img/mark-white.png" width="70" alt="Tabler" class="me-3" style=""> --->
											<img src="/studio/main/mascot" width="70" alt="ChartSQL Studio" class="me-3" style="">
											<!--- <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-menu-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 6l16 0" /><path d="M4 12l16 0" /><path d="M4 18l16 0" /></svg> --->
										</span>
									</a>
								</li>

								<!--- <div id="storyMenu" style="display:none;">
									<li id="" class="nav-item">
										<a class="nav-link" href="{{view_state.editor_link}}">
											<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="From beginning"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-slideshow" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M15 6l.01 0" /><path d="M3 3m0 3a3 3 0 0 1 3 -3h12a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-12a3 3 0 0 1 -3 -3z" /><path d="M3 13l4 -4a3 5 0 0 1 3 0l4 4" /><path d="M13 12l2 -2a3 5 0 0 1 3 0l3 3" /><path d="M8 21l.01 0" /><path d="M12 21l.01 0" /><path d="M16 21l.01 0" /></svg>
											</span>
											<span class="nav-link-title">
												From Beginning
											</span>
										</a>
									</li>
									<li id="" class="nav-item">
										<a class="nav-link" href="{{view_state.editor_link}}">
											<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Exit Presenation"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
												<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-player-stop" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M5 5m0 2a2 2 0 0 1 2 -2h10a2 2 0 0 1 2 2v10a2 2 0 0 1 -2 2h-10a2 2 0 0 1 -2 -2z" /></svg>
											</span>
											<span class="nav-link-title">
												Exit
											</span>
										</a>
									</li>
								</div> --->

								<div id="main-menu-nav-items" class="h-100">
								<li id="editorMenuLink" class="nav-item {{#if (eq action "studio:main.list")}}active{{/if}}">
									<a class="nav-link" href="{{view_state.editor_link}}">
										<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Chart Editor"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-code" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 8l-4 4l4 4" /><path d="M17 8l4 4l-4 4" /><path d="M14 4l-4 16" /></svg>
										</span>
										<span class="nav-link-title">
											Editor
										</span>
									</a>
								</li>
								<!--- <li class="nav-item">
									<a class="nav-link" href="{{view_state.presentation_mode.link}}">
										<span class="nav-link-icon d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-presentation" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M3 4l18 0" /><path d="M4 4v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-10" /><path d="M12 16l0 4" /><path d="M9 20l6 0" /><path d="M8 12l3 -3l2 2l3 -3" /></svg>
										</span>
										<span class="nav-link-title">
											Present
										</span>
									</a>
								</li> --->
								<li class="nav-item dropdown d-none">
									<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-base" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
										<span class="nav-link-icon d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/package -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-database" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0" /><path d="M4 6v6a8 3 0 0 0 16 0v-6" /><path d="M4 12v6a8 3 0 0 0 16 0v-6" /></svg>
										</span>
										<span class="nav-link-title">
											Datasources
										</span>
									</a>
									<div class="dropdown-menu">
										<div class="dropdown-menu-columns">
											<div class="dropdown-menu-column">
												<a class="dropdown-item" href="./accordion.html">
													Accordion
												</a>
												<a class="dropdown-item" href="./blank.html">
													Blank page
												</a>
												<a class="dropdown-item" href="./badges.html">
													Badges
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./buttons.html">
													Buttons
												</a>
												<div class="dropend">
													<a class="dropdown-item dropdown-toggle" href="#sidebar-cards" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
														Cards
														<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
													</a>
													<div class="dropdown-menu">
														<a href="./cards.html" class="dropdown-item">
															Sample cards
														</a>
														<a href="./card-actions.html" class="dropdown-item">
															Card actions
															<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
														</a>
														<a href="./cards-masonry.html" class="dropdown-item">
															Cards Masonry
														</a>
													</div>
												</div>
												<a class="dropdown-item" href="./colors.html">
													Colors
												</a>
												<a class="dropdown-item" href="./datagrid.html">
													Data grid
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./datatables.html">
													Datatables
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./dropdowns.html">
													Dropdowns
												</a>
												<a class="dropdown-item" href="./modals.html">
													Modals
												</a>
												<a class="dropdown-item" href="./maps.html">
													Maps
												</a>
												<a class="dropdown-item" href="./map-fullsize.html">
													Map fullsize
												</a>
												<a class="dropdown-item" href="./maps-vector.html">
													Vector maps
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./navigation.html">
													Navigation
												</a>
												<a class="dropdown-item" href="./charts.html">
													Charts
												</a>
												<a class="dropdown-item" href="./pagination.html">
													<!-- Download SVG icon from http://tabler-icons.io/i/pie-chart -->
													Pagination
												</a>
											</div>
											<div class="dropdown-menu-column">
												<a class="dropdown-item" href="./placeholder.html">
													Placeholder
												</a>
												<a class="dropdown-item" href="./steps.html">
													Steps
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./stars-rating.html">
													Stars rating
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./tabs.html">
													Tabs
												</a>
												<a class="dropdown-item" href="./tables.html">
													Tables
												</a>
												<a class="dropdown-item" href="./carousel.html">
													Carousel
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./lists.html">
													Lists
												</a>
												<a class="dropdown-item" href="./typography.html">
													Typography
												</a>
												<a class="dropdown-item" href="./offcanvas.html">
													Offcanvas
												</a>
												<a class="dropdown-item" href="./markdown.html">
													Markdown
												</a>
												<a class="dropdown-item" href="./dropzone.html">
													Dropzone
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./lightbox.html">
													Lightbox
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./tinymce.html">
													TinyMCE
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<a class="dropdown-item" href="./inline-player.html">
													Inline player
													<span class="badge badge-sm bg-green-lt text-uppercase ms-auto">New</span>
												</a>
												<div class="dropend">
													<a class="dropdown-item dropdown-toggle" href="#sidebar-authentication" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
														Authentication
													</a>
													<div class="dropdown-menu">
														<a href="./sign-in.html" class="dropdown-item">
															Sign in
														</a>
														<a href="./sign-in-link.html" class="dropdown-item">
															Sign in link
														</a>
														<a href="./sign-in-illustration.html" class="dropdown-item">
															Sign in with illustration
														</a>
														<a href="./sign-in-cover.html" class="dropdown-item">
															Sign in with cover
														</a>
														<a href="./sign-up.html" class="dropdown-item">
															Sign up
														</a>
														<a href="./forgot-password.html" class="dropdown-item">
															Forgot password
														</a>
														<a href="./terms-of-service.html" class="dropdown-item">
															Terms of service
														</a>
														<a href="./auth-lock.html" class="dropdown-item">
															Lock screen
														</a>
													</div>
												</div>
												<div class="dropend">
													<a class="dropdown-item dropdown-toggle" href="#sidebar-error" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
														<!-- Download SVG icon from http://tabler-icons.io/i/file-minus -->
														<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-inline me-1" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M14 3v4a1 1 0 0 0 1 1h4" /><path d="M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" /><path d="M9 14l6 0" /></svg>
														Error pages
													</a>
													<div class="dropdown-menu">
														<a href="./error-404.html" class="dropdown-item">
															404 page
														</a>
														<a href="./error-500.html" class="dropdown-item">
															500 page
														</a>
														<a href="./error-maintenance.html" class="dropdown-item">
															Maintenance page
														</a>
													</div>
												</div>
											</div>
										</div>
									</div>
								</li>
								<!--- <li class="nav-item">
									<a class="nav-link" href="./form-elements.html" >
										<span class="nav-link-icon d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/checkbox -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9 11l3 3l8 -8" /><path d="M20 12v6a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-12a2 2 0 0 1 2 -2h9" /></svg>
										</span>
										<span class="nav-link-title">
											Forms
										</span>
									</a>
								</li> --->
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false">
										<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="Switch Charts Package"><!-- Download SVG icon from http://tabler-icons.io/i/star -->
											<svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-package me-2" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3l8 4.5l0 9l-8 4.5l-8 -4.5l0 -9l8 -4.5" /><path d="M12 12l8 -4.5" /><path d="M12 12l0 9" /><path d="M12 12l-8 -4.5" /><path d="M16 5.25l-8 4.5" /></svg>
										</span>
										<span class="nav-link-title">
											Packages
										</span>
									</a>
									<div class="dropdown-menu">
										<div class="dropdown-menu-columns">
											<div class="dropdown-menu-column">
												{{#each data.GlobalChartSQLStudio.Packages}}
													<a class="dropdown-item" href="{{OpenPackageLink}}">
														<!--- {{this}} --->
														{{FriendlyName}}
													</a>
													<!--- <div class="dropend">
														<a class="dropdown-item dropdown-toggle" href="{{OpenPackageLink}}" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
															{{FriendlyName}}
														</a>
														<div class="dropdown-menu">
															<a href="./sign-in.html" class="dropdown-item">
																Sign in
															</a>
															<a href="./sign-in-link.html" class="dropdown-item">
																Sign in link
															</a>
															<a href="./sign-in-illustration.html" class="dropdown-item">
																Sign in with illustration
															</a>
															<a href="./sign-in-cover.html" class="dropdown-item">
																Sign in with cover
															</a>
															<a href="./sign-up.html" class="dropdown-item">
																Sign up
															</a>
															<a href="./forgot-password.html" class="dropdown-item">
																Forgot password
															</a>
															<a href="./terms-of-service.html" class="dropdown-item">
																Terms of service
															</a>
															<a href="./auth-lock.html" class="dropdown-item">
																Lock screen
															</a>
														</div>
													</div> --->
												{{/each}}
											</div>
										</div>
									</div>
								</li>
								<li class="nav-item dropdown d-none">
									<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-help" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
										<span class="nav-link-icon d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
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
											<li class="nav-item dropdown">
												<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-help" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
													<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
														<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
													</span>
													<span class="nav-link-title">
														{{Name}}
													</span>
												</a>
												<div class="dropdown-menu">
													{{#each Children}}
														<a class="dropdown-item" href="{{Link}}">
															{{#if IconClass}}<i class="{{IconClass}}"></i>&nbsp;{{/if}}{{Name}}
														</a>
													{{/each}}
												</div>
											</li>
										{{else}}
											<li class="nav-item {{#if IsActive}}active{{/if}}">
												<a class="nav-link" href="{{Link}}" {{#if OpenNewTab}}target="_blank"{{/if}}>
													<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
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
									{{#each MenuItems}}
										{{#if (eq Location 'bottom')}}
											{{#if HasChildren}}
												<li class="nav-item dropdown">
													<a class="nav-link dropdown-toggle {{#if client_state.navbar_collapsed}}leftcollapsed{{/if}}" href="#navbar-help" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
														<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/lifebuoy -->
															<i class="{{IconClass}}" style="font-size:1.2rem; font-weight:100;"></i>
														</span>
														<span class="nav-link-title">
															{{Name}}
														</span>
													</a>
													<div class="dropdown-menu">
														{{#each Children}}
															<a class="dropdown-item" href="{{Link}}">
																{{#if IconClass}}<i class="{{IconClass}}"></i>&nbsp;{{/if}}{{Name}}
															</a>
														{{/each}}
													</div>
												</li>
											{{else}}
												<li class="nav-item {{#if IsActive}}active{{/if}}">
													<a class="nav-link" href="{{Link}}" {{#if OpenNewTab}}target="_blank"{{/if}}>
														<span class="nav-link-icon d-md-none d-lg-inline-block" data-bs-toggle="tooltip" data-bs-placement="right" title="{{Tooltip}}"><!-- Download SVG icon from http://tabler-icons.io/i/home -->
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
				</aside>
				<style>
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
				</style>
				<div id="pageContent" class="page-wrapper {{#if client_state.navbar_collapsed}}left-collapsed{{/if}}" style="height:100vh; overflow:hidden;">
					<cfoutput>#body#</cfoutput>
				</div>
			</div>
			<!-- Libs JS -->
			<script src="/assets/vendor/tabler/dist/libs/apexcharts/dist/apexcharts.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/js/jsvectormap.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/maps/world.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/libs/jsvectormap/dist/maps/world-merc.js?1684106062" defer></script>
			<!-- Tabler Core -->
			<script src="/assets/vendor/tabler/dist/js/tabler.min.js?1684106062" defer></script>
			<script src="/assets/vendor/tabler/dist/js/demo.min.js?1684106062" defer></script>
			<script>
				ZERO_JS_ICON_CLASS = "spinner-border spinner-border-sm me-2";
				ZERO_JS_LOG_LEVEL = "debug";
			</script>
			<script src="/zero/zero.js"></script>
			<script src="/assets/js/form-links.js" defer></script>
			<!--- ZERO AUTO FORMS
				These forms are used to call refreshes of elements on the page using the ZeroJs library.
				They should be targted by zero-target whenever a refresh is needed.
			--->
			<div id="refreshMemoryUsage">
				{{#if client_state.REFRESH_CPU}}
					<form method="POST" action="/studio/main/keyPerformanceInfo" zero-auto="1" zero-target="#memoryUsage,#refreshMemoryUsage">
					</form>
				{{/if}}
			</div>

		</body>
		<script>
				$( document ).ready(function() {
					// Add event click to every 'dropdown-toggle'
					$('.dropdown-toggle').click(function () {
						if (this.classList.contains('leftcollapsed')) {
							if (!this.classList.contains('show')) {
								$(this).dropdown('toggle')
							}
							toggleNavbar();
						}
					});
				});
		</script>
	</html>
</cf_handlebars>