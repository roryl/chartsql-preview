$(document).ready(function() {

	if(typeof ZERO_JS_LOG_LEVEL == 'undefined'){
		ZERO_JS_LOG_LEVEL = 'warning'
	}

	if(typeof ZERO_JS_PRELOAD_ALL_LINKS == 'undefined'){
		ZERO_JS_PRELOAD_ALL_LINKS = false;
	}

	if(typeof ZERO_JS_ICON == 'undefined'){
		ZERO_JS_ICON = true;
	}

	if(typeof ZERO_JS_ICON_CLASS == 'undefined'){
		ZERO_JS_ICON_CLASS = 'fas fa-circle-notch fa-spin';
	}

	// if(typeof ZERO_JS_ICON_SPINNER == 'undefined'){
	// 	ZERO_JS_ICON_SPINNER = 'fa fa-circle-o-notch fa-spin';
	// }

	var doLog = function(message, level){

		if(typeof level == 'undefined'){
			level = 'error';
		}

		switch(ZERO_JS_LOG_LEVEL){


			case "debug":
				if(
					level == 'debug' ||
					level == 'error' ||
					level == 'warning' ||
					level == 'info' ){
					console.log(message);
				}
			break;

			case "error":
				if(
					level == 'error' ||
					level == 'warning' ||
					level == 'info' ){
					console.log(message);
				}
			break;

			case "warning":
				if(
					level == 'warning' ||
					level == 'info' ){
					console.log(message);
				}
			break;

			case "info":
				if(level == 'info' ){
					console.log(message);
				}
			break;

			default:
				console.log(message);
			break;
		}
	}

	var lastButtonClickedValue = {};

	zeroIcon = function(){
		var allFormButtons = $('form button, a.btn, [zero-icon="true"]');
		allFormButtons.each(function(index, element){
			var element = $(element);

			if(element.attr('href') !== undefined){
				if(element.attr('href').includes("Javascript")){
					return;
				}
			}

			$(element).on('click', function(){
				var attr = element.attr('zero-submit-text');
				// For some browsers, `attr` is undefined; for others, `attr` is false. Check for both.
				if (typeof attr !== undefined && attr !== false) {
					//We need to get the icon out of the element and then replace
					//the text and append the icon, as otheriwse the
					//click event seems to get lost
					//when the user clicks on the icon
					if(attr !== 'false'){
						var i = element.find('i');
						element.html(attr);
						element.prepend(i);
					}
				}

				var showIcons = true;

				//If this was in a form, we are going to check if the form
				//was validated client side before adding in the spinner
				var Form = $(this).closest('form');
				if(Form.length){
					if (Form[0].checkValidity() == false) {
						showIcons = false;
					}
				}

				if(typeof element.attr('target') !== 'undefined') {
					if(element.attr('target') == '_blank'){
						showIcons = false;
					}
				}

				if(typeof element.attr('zero-icon') !== 'undefined') {
					if(element.attr('zero-icon') == 'false'){
						showIcons = false;
					}
				}
				if(showIcons){
					if(typeof element.attr('zero-icon-target') !== 'undefined') {
						zeroIconTargetElement = element.find(element.attr('zero-icon-target'));
						zeroIconTargetElement.replaceWith(`<i class="${ZERO_JS_ICON_CLASS}"></i>`);
					} else if(element.has('i').length){
						var icon = $(element).find('i');
						icon.removeClass();
						icon.addClass(ZERO_JS_ICON_CLASS);
					} else {
						if(element.has('svg').length){
							element.find('svg').remove();
						}
						element.prepend(`<i class="${ZERO_JS_ICON_CLASS}"></i>`);
					}
					element.addClass('disabled');
				}
			});

		});
	}
	if(ZERO_JS_ICON){
		zeroIcon();
	}


	zeroConfirm = function(){
		var confirmButtons = $('a[zero-confirm],button[zero-confirm]');
		$(confirmButtons).each(function(index, item){

			var id = $(item).attr('id');
			var text = $(item).attr('zero-confirm');

			if($(item).is("[form]")){
				var formId = $(item).attr('form');
				var form = $(`#${formId}`);
			} else {
				var form = $(item).parent('form');
			}

			var originalText = $(item).html();
			var cancelText = 'Cancel';

			if($(item).is("[zero-confirm-text]")){
				var buttonText = $(item).attr('zero-confirm-text');
			} else {
				var buttonText = originalText;
			}

			if($(item).is("[zero-submit-text]")){
				var zeroSubmitText = $(item).attr('zero-submit-text');
			} else {
				var zeroSubmitText = $(item).text();
			}

			if($(item).is("[zero-cancel-text]")){
				var cancelText = $(item).attr('zero-cancel-text');
			}

			// console.log(zeroSubmitText);
			// console.log(id);
			// console.log(text);
			// console.log(form);

			$(item).on('click', function(event){

				event.preventDefault();

				$(item).addClass('d-none');

				var out = '<div id="deleteConfirm' + id + '" style="display:inline;">' +
								text + ' ' +
								'<button form="'+form.attr("id")+'" type="submit" class="btn btn-xs btn-warning me-1" zero-submit-text=' + zeroSubmitText + '>' + buttonText + '</button>' +
								'<button id="confirmCancel' + id + '" type="button" class="btn btn-xs btn-default" zero-icon="false">' + cancelText + '</button>' +
							'</div>';

				$(out).insertBefore(item);
				zeroIcon();

				$('#deleteConfirm' + id).show();
				$('#confirmCancel' + id).on('click', function(){
					$('#' + id).html(originalText);
					$('#' + id).show();
					$('#' + id).attr('disabled', false);
					$('#' + id).removeClass('disabled');
					$('#deleteConfirm' + id).remove();
					$(item).html(originalText);
					$(item).removeClass('d-none');
					$(item).attr('disabled', false);
					$(item).removeClass('disabled');
				});

				$('#' + id).hide();
			})
		});
	}
	zeroConfirm();

	zeroAjax = function(html){
		var zeroForms = $(html).find('form[zero-target]');
		$(zeroForms).off('submit');

		for(var i=0 ; i < zeroForms.length; i++){

			var action = $(zeroForms[i]).attr('action');
			var goto = $(zeroForms[i]).find('input[name=goto]').val();
			var currentPath = window.location.pathname;


			var gotoAndCurrentPathAreTheSame = true;
			// var gotoAndCurrentPathAreTheSame = (goto == currentPath);

			if(gotoAndCurrentPathAreTheSame){

				//Check if we already have a click handler and if we do then do nothing
				//because we do not want to add a second click handler
				// var hasClickHandler = $(zeroForms[i]).data('events');
				// if(typeof hasClickHandler == 'undefined'){


				$(zeroForms[i]).on('submit',function(event){

					var event = event;
					event.preventDefault();
					// console.log(event);

					var form = $(event.target);
					doLog(form);
					doLog(form[0].action);
					var target = form.attr('zero-target');
					var formButton = $(form).find('button');
					var icon = $(formButton).find('i');
					// console.log(icon.hasClass('fa'));

					var oldClass = icon.attr('class');

					formButton.attr('disabled', true);

					// var data = form.serialize();
					// console.log(data);

					// Use Ajax to submit form data. Add the button value to the submit
					var formData = form.serializeArray();
					formData.push(lastButtonClickedValue);

					/*
					Check if the last button clicked had a formaction. This is a HTML5
					feature to send forms to a different URL. If so, this needs to override the
					form's action. There is no way in Javascript cross browser, to get the
					button's formaction from the onSubmit event.

					We need to know what button the user last clicked to determine if we are to
					load the form action from the button, or to load it from
					the form's action.
					 */
					if(typeof lastButtonClickedElement != 'undefined' && lastButtonClickedElement){
						var buttonHasFormAction = $(lastButtonClickedElement).attr('formaction');
						if(typeof buttonHasFormAction != 'undefined' && buttonHasFormAction){
							var formAction = buttonHasFormAction;
						} else {
							var formAction = form.attr('action');
						}
					} else {
						var formAction = form.attr('action');
					}

					var formMethod = form.attr('method');
					var formPushState = form.attr('zero-push-state');
					//If its empty or null, then we are using push state, otherwise we are not
					if(formPushState == null || formPushState == ''){
						usingPushState = true;
					} else {
						usingPushState = false;
					}

					//if the method is get
					if(formMethod.toLowerCase() == 'get' && usingPushState){


						//If there are any form parameters in formData
						//then we need to add them to the URL
						//If the URL already has a querystring, then we don't need to add a ?
						if(formAction.includes('?')){
							var newUrl = formAction + '&' + $.param(formData);
						} else {
							var newUrl = formAction + '?' + $.param(formData);
						}

						// Remove '&=' from the very end of the URL
						var newUrl = newUrl.replace(/&=$/,'');

						console.log(newUrl);
						// window.history.pushState({}, '', newUrl);
						window.history.pushState({formData: formData, formAction: formAction, target: target}, '', newUrl);
					}


					doLog(formAction);

					var successFunc = function(result) {

						//http://stackoverflow.com/questions/405409/use-jquery-selectors-on-ajax-loaded-html
						//

						// http://stackoverflow.com/questions/14423257/find-body-tag-in-an-ajax-html-response
						if(target == 'body'){
							var targetHTML = result.substring(result.indexOf("<body>")+6,result.indexOf("</body>"));



							var targetPut = $('body');
							targetPut.html(targetHTML);
						} else {
							// console.log(result);
							var response = $('<html />').html(result);

							/*
							The target can be a comma separated list of targets. This is useful for updating a number
							of sections on the page based on the response
							 */
							var targetArray = target.split(',');

							for(var i=0; i < targetArray.length; i++){

								$(response).find(targetArray[i]).each(function(){

									var targetHTML = $(this);

									var id = targetHTML.attr('id');
									console.log('THIS!' + targetHTML.attr('id'));
									if(typeof id === "undefined"){

										// var targetPut = document.getElementsByTagName(targetHTML[0].tagName.toLowerCase())[0];
										var targetPut = $(targetHTML[0].tagName.toLowerCase());
										// console.log(targetPut);
										// var targetPut = $(targetArray[i]);
									} else {
										// var targetPut = document.getElementById(id);
										var targetPut = $('#' + id);
									}
									// console.log(targetHTML);
									// var targetPut = $(targetArray[i]);

									if(!targetPut.length){
										throw "Could not find the target " + targetArray[i] + " check your references and ensure it exists";
									}
									// console.log(targetPut);
									targetPut.html(targetHTML.html());
									zeroAuto($(targetPut));
								});
							}

							formButton.removeAttr('disabled');
						}

						/* Undo the last button clicked because we do not want this to interfere with subsequent zero-autos
						*/
						delete lastButtonClickedElement;

						icon.removeClass();
						icon.addClass(oldClass);

						//Call zeroAjax over the document again to add event listeners
						zeroAjax($(document));
						// zeroAuto($(document));
						zeroOnChange($(document));
						zeroIcon($(document));
						lastButtonClicked($(document));
						// console.log(targetHTML);
					}


					window.onpopstate = function(event) {
						if(event.state) {
							// event.state is equal to the data-attribute of the last pushState
							var formData = event.state.formData;
							var formAction = event.state.formAction;
							var target = event.state.target;

							// perform the AJAX call again to get the form content
							$.ajax({
							url: formAction,
							type: 'GET',
							data: formData,
							success: successFunc
							});
						}
					};

		            $.ajax({
		                url: formAction,
		                type: formMethod,
		                data: formData,
		                success: successFunc
		            });
				})
			}
		}

	}
	zeroAjax($(document));

	var lastButtonClicked = function(html){
		lastButtonClickedValue = {};
		var formButtons = $(html).find('button,input[type="submit"]');
		formButtons.each(function(index, button){
			$(button).on("click",function(element){
				lastButtonClickedElement = this;
				lastButtonClickedValue = { name: this.name, value: this.value };
				doLog(lastButtonClickedValue);
			})
		});
		// console.log(formButtons);
	}
	lastButtonClicked($(document));


	zeroAuto = function(html){

		var zeroAutos = $(html).find('form[zero-auto]');
		// $(zeroAutos).off('submit');
		// console.log(zeroAutos);
		for(var i = 0; i < zeroAutos.length; i++){

			var auto = zeroAutos[i];

			var formButton = $(auto).find('button');
			var icon = $(formButton).find('i');
			// console.log(icon.hasClass('fa'));

			if(icon.hasClass('fa-refresh')){
				icon.addClass('fa-spin');
			} else {
				icon.removeClass();
				icon.addClass('fa fa-circle-o-notch fa-spin');
			}

			// console.log(auto);
			var timeout = $(auto).attr('zero-auto');
			setTimeout(function(){
				doLog(auto);
				// throw "";
				$(auto).trigger("submit");
			}, timeout * 1000)
		}

	}
	zeroAuto($(document));

	zeroOnChange = function(html){

		zeroForms = $(html).find('form[zero-submit-onchange]');
		doLog(zeroForms);
		for(var i=0; i < zeroForms.length; i++){
			var zeroForm = zeroForms[i];
			var currentForm = $(zeroForm);
			var inputs = currentForm.find('input,select,textarea');
			// console.log(inputs);
			for(var i2=0; i2 < inputs.length; i2++){

				var input = inputs[i2];
				$(input).on("change", function(){
					// console.log('change');
					$(this).closest('form').trigger("submit");
				})

			}

		}

	}
	zeroOnChange($(document));


	zeroPreload = function(html){

		startTime = new Date().getTime();
		loadTime = "";
		loadInProgress = false;

		if(ZERO_JS_PRELOAD_ALL_LINKS){
			var allLinks = $(html).find('a');
			doLog('zeropreload: Load Links', 'debug');

			allLinks.each(function(index, alink){
				var link = $(alink);
				var defaultPreloadType = link.attr('zero-preload');


				doLog(link.html() + ' defaultPreloadType: ' + defaultPreloadType);
				// console.log($(preload).attr('href'));
				if(defaultPreloadType == 'false' || defaultPreloadType == false){
					return;
				}

				doLog('zeropreload: do link' + link.attr('href'), 'debug');
				doLog(link, 'debug');

				if(typeof link.attr('onClick') != 'undefined'){
					doLog('zeropreload: link is using onclick so it is ignored', 'debug');
					//We do not preload anchor links that
					//are using an onClick
				} else if (this.pathname == window.location.pathname &&
				    this.protocol == window.location.protocol &&
				    this.host == window.location.host) {
					doLog('zeropreload: link pathname, protocol and host match', 'debug');
				 	doLog('zeropreload: pathname:' + this.pathname);
				 	doLog('zeropreload: protocol:' + this.protocol);
				 	doLog('zeropreload: host:' + this.host);
				 	//If we are on the current page then we need to determine
				 	//if this is a hash for the current page.
				 	if(
				 		link.attr('href').includes("#") ||
				 		link.attr('href').includes('Javascript(')
				 	){
				 		doLog('zeropreload: href included # or javascript', 'debug');
				 	} else {
				 		if(typeof defaultPreloadType == 'undefined'){
							link.attr('zero-preload', 'mouseenter');
							doLog($(alink).attr('href'));
						}
				 	}

				} else {
					if(link.attr('href') === undefined){
						doLog('empty string');
					} else {

						doLog('includes js ' + link.attr('href').includes("Javascript"));

						if(link.attr('href').includes("Javascript")){
							//We exclude the javascript links because
							//they are handling their own implementation
						} else {
							if(typeof defaultPreloadType == 'undefined'){
								link.attr('zero-preload', 'mouseenter');
								doLog($(alink).attr('href'));
							}
						}

					}
				}

			});
		}

		// console.log('foobar');
		var zeroPreloads = $(html).find('[zero-preload]');
		for(var i = 0; i < zeroPreloads.length; i++){
			var preload = $(zeroPreloads[i]);
			var preloadType = preload.attr('zero-preload');
			doLog('preloadType: ' + preloadType);
			// console.log($(preload).attr('href'));
			if(preloadType == 'false' || preloadType == false){
				continue;
			}
			// alert(preloadType);
			// var url = preload.attr('href');

			preload.on('mouseenter', function(){
				doLog('time: ' + 0, 'debug');
			});

			preload.on(preloadType, function(){
				doLog('time ' + preloadType + ' :' + (new Date().getTime() - loadTime).toString(), 'debug');
				var d = new Date();
				var preloadUrl = $(this).attr('href');
				var preloadMaxAge = $(this).attr('preload-max-age');

				loadInProgress = true;
				var doPreload = function(){
					loadTime = new Date().getTime();
					// var uuid = generateUUID();
					// console.log(uuid);
					// $(this).attr('preloaduuid', uuid);
					// document.cookie = "zeropreload=" + uuid;
					// document.cookie = "zeropreload=" + uuid + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/";
					// console.log(document.cookie);

					$.ajax({
						url: preloadUrl,
						success: function(){},
						cache: true,
						beforeSend: function(xhr){

							if(typeof preloadMaxAge != 'undefined'){
								doLog('zeropreload: preload-max-age defined' + preloadMaxAge, 'debug');
								xhr.setRequestHeader('X-Zero-preload', preloadMaxAge);
							} else {
								xhr.setRequestHeader('X-Zero-preload', 60);
							}

						},
					}).done(function(){
						doLog('loading done: ' + preloadUrl, 'debug');
						loadInProgress = false;
					});
				}

				if(preloadType == "mouseenter"){
					doLog('start timer', 'debug');
					var startedEnter = loadTime;
					var link = $(this);
					$(this).attr('mousing', true);

					$(link).on('mouseleave',function(){
						doLog('mouseing false', 'debug');
						$(this).attr('mousing', false);
					});

					var startTimeOn = new Date().getTime();;
					var checkTimeOn = function(link){
						var currentTime = new Date().getTime();
						var elapsed = currentTime - startTimeOn;
						// console.log('mousing: ' + $(link).attr('mousing'));
						// console.log('elapsed:' + elapsed.toString());
						if(elapsed >= 200){
							// console.log('hit elapsed, mousing: ' + $(link).attr('mousing'));
							// console.log($(link).attr('mousing') != 'false');
							if($(link).attr('mousing') != 'false'){
								startTimeOn = new Date().getTime();;
								doPreload();
							} else {
								doLog('abandon loading ' + preloadUrl);
								// loadInProgress = false;
								startTimeOn = new Date().getTime();;
							}
						} else {
							setTimeout(function(){
								checkTimeOn(link);
							}, 20);
						}
					}
					checkTimeOn(link);

				} else {
					doPreload();
				}
			});

			preload.on('click', function(event){
				var timeToClick = new Date().getTime() - loadTime;
				doLog('time to click: ' + (new Date().getTime() - loadTime).toString());
				var original = event;
				var url = $(this).attr('href');
				var checkLoading = function(){
					// console.log('checking loading');
					if(loadInProgress){
						// console.log('preload waiting');
						setTimeout(function(){
							if(loadInProgress){
								checkLoading();
							} else {
								totalTime = new Date().getTime();
								doLog('saved time:')
								doLog((timeToClick - loadTime).toString());
								// console.log('going to ' + url);
								window.location = url;
							}
						}, 20);
						event.preventDefault();
					} else {
						//Do nothing load is done
					}
				}
				checkLoading();


				var d = new Date();
				endTime = d.getTime() - loadTime;
				doLog(endTime);
				// alert();
				// event.preventDefault();
				// var attr = $(this).attr('preloaduuid');

				// if (typeof attr !== typeof undefined && attr !== false) {
				// 	document.cookie = "zeropreload=" + attr + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/";
				// }
			});
		}
		doLog(zeroPreloads);
	}
	zeroPreload($(document));

	//Implement a polyfill for HTML5 form action
	//attribute. Will help support older browsers
	//that do not have formAction, but this does
	//require javascript be enabled
    if (!("formAction" in document.createElement("input"))) {
      var elements = document.querySelectorAll('button');
      if (elements) {
        for (var i = 0; i < elements.length; i++) {
          var element = elements[i];
          if (element.attributes.formAction) {
            element.addEventListener('click', function () {
              this.form.action = this.attributes.formAction.value;
              return true;
            });
          }
        }
      }
    }
	// zeroPreload($(document));
});

function generateUUID(){
    var d = new Date().getTime();
    if(window.performance && typeof window.performance.now === "function"){
        d += performance.now(); //use high-precision timer if available
    }
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c=='x' ? r : (r&0x3|0x8)).toString(16);
    });
    return uuid;
}


function getClientName(name){
	return "CLIENT.CLIENT_STATE." + name.toUpperCase();
}

ZeroClient = {
		"set":function(name, value, options){
			if(typeof options == "undefined"){options = {}}
			Cookies.set(getClientName(name), value, options);
		},

		"get":function(name, value){
			if(typeof Cookies.get(getClientName(name)) == "undefined"){
				return value;
				// if(typeof default != "undefined"){
				// 	return default;
				// }
			}
			return Cookies.get(getClientName(name));
		},

		"require":function(name, value, options){
			if(typeof options == "undefined"){options = {}}
			if(typeof Cookies.get(getClientName(name)) == "undefined"){
				Cookies.set(getClientName(name), value, options);
			}
			// Cookies.setDefault = function(name, value, options){
			// }

		},

		"toggle":function(name){
			if(typeof Cookies.get(getClientName(name)) == "undefined"){
				Cookies.set(getClientName(name), true);
			} else {
				console.log(Cookies.get(getClientName(name)));
				if(Cookies.get(getClientName(name)) == 'true'){
					console.log('set cookie false');
					Cookies.set(getClientName(name), false);
				} else {
					console.log('set cookie true');
					Cookies.set(getClientName(name), true);
				}
			}
		},

		"remove":function(name){
			Cookies.remove(getClientName(name));
		}
}