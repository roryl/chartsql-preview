// @ts-nocheck
// @ts-ignore
var expect = chai.expect;
// @ts-ignore
suite('ZsxJs', function() {

	var ZsxJstest = new ZsxJs();

	// @ts-ignore
	setup(function() {
		// @ts-ignore
		window.TestVars = {};
		var bodyTag = document.getElementsByTagName('body')[0];
		// @ts-ignore
		//Create a container div for our tests with id 'testContainer'
		var container = document.createElement('div');
		container.id = 'testContainer';

		// @ts-ignore
		bodyTag.appendChild(container);

	});

	// @ts-ignore
	teardown(function() {

		// @ts-ignore
		// Delete the test container
		var container = document.getElementById('testContainer');
		// @ts-ignore
		container.remove();

	});

	test('_parseZxEvent', function() {

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;

		console.log(linkElement);

		var zxEvent = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		expect(zxEvent.type.isLink).to.be.true;
		expect(zxEvent.type.isForm).to.be.false;
		expect(zxEvent.method).to.equal('get');
		expect(zxEvent.url).to.equal('http://127.0.0.1:51404/foo');

		console.log(zxEvent);
	});

	// @ts-ignore
	test('_parseResponseAndSwapSelectors - Executes inline scripts', function() {

		// @ts-ignore
		window.TestVars.scriptIsExecuted = false;

		var content = '<div id="testId"><script>window.TestVars.scriptIsExecuted = true;</script></div>';
		var holder = document.createElement('div');
		holder.innerHTML = content;

		var bodyTag = document.getElementsByTagName('body')[0];
		// @ts-ignore
		bodyTag.appendChild(holder.firstChild);

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;
		var zxTrigger = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		// zxTrigger = ZsxJstest._normalizeZxTrigger(holder.firstChild);

		ZsxJstest._parseResponseAndSwapSelectors(document, content, '#testId', zxTrigger);
		// @ts-ignore
		expect(window.TestVars.scriptIsExecuted).to.be.true;

	});

	// @ts-ignore
	test('_parseResponseAndSwapSelectors - Multiple selector elements defaults to Id', function() {

		var content = '<div class="replaceMe"><div class="replaceMe" ></div></div>';
		var holder = document.createElement('div');
		holder.innerHTML = content;

		var testContainer = document.getElementById('testContainer');
		// @ts-ignore
		testContainer.appendChild(holder.firstChild);

		// @ts-ignore
		expect(function() {
			ZsxJstest._parseResponseAndSwapSelectors(document, content, '.replaceMe');
		}).to.throw('ZsxJs: Multiple elements found with selector ".replaceMe" but no id found to disambiguate them.');

	});

	//@ts-ignore
	test('_parseResponseAndSwapSelectors - Class selector with Id', function() {

		var content = `
			<div>
				<div id="test1" class="replaceMe1">foo</div>
				<div id="test2" class="replaceMe1">foo</div>
			</div>
		`;

		var originalHolder = document.createElement('div');
		originalHolder.innerHTML = content;

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');

		// @ts-ignore
		testContainer.appendChild(originalHolder);

		var newContent = `
			<div>
				<div id="test1" class="replaceMe1">bar</div>
				<div id="test2" class="replaceMe1">bar</div>
			</div>
		`;

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;
		var zxTrigger = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		// console.log('foo' + document.getElementById('testContainer').innerHTML);

		// @ts-ignore
		ZsxJstest._parseResponseAndSwapSelectors(document, newContent, '.replaceMe1', zxTrigger);

		// alert(document.getElementById('test1').innerHTML);

		// @ts-ignore
		expect(document.getElementById('test1').innerHTML).to.equal('bar');
		// @ts-ignore
		expect(document.getElementById('test2').innerHTML).to.equal('bar');

	});

	//@ts-ignore
	test('_parseResponseAndSwapSelectors - Multiple selectors', function() {

		var content = `
			<div>
				<div id="test1">foo</div>
				<div id="test2">foo</div>
			</div>
		`;

		var originalHolder = document.createElement('div');
		originalHolder.innerHTML = content;

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');

		// @ts-ignore
		testContainer.appendChild(originalHolder);

		var newContent = `
			<div>
				<div id="test1">bar</div>
				<div id="test2">bar</div>
			</div>
		`;

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;
		var zxTrigger = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		// @ts-ignore
		ZsxJstest._parseResponseAndSwapSelectors(document, newContent, '#test1,#test2', zxTrigger);

		// alert(document.getElementById('test1').innerHTML);

		// @ts-ignore
		expect(document.getElementById('test1').innerHTML).to.equal('bar');
		// @ts-ignore
		expect(document.getElementById('test2').innerHTML).to.equal('bar');

	});

	//@ts-ignore
	test('_parseResponseAndSwapSelectors - Zx-Keep', function() {

		var content = `
			<div>
				<div id="subContainer">
					<div id="test1">foo</div>
					<div id="test2" zx-keep="true">foo</div>
				</div>
			</div>
		`;

		var originalHolder = document.createElement('div');
		originalHolder.innerHTML = content;

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');

		// @ts-ignore
		testContainer.appendChild(originalHolder);

		var newContent = `
			<div>
				<div id="subContainer">
					<div id="test1">bar</div>
					<div id="test2" zx-keep="true">bar</div>
				</div>
			</div>
		`;

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;
		var zxTrigger = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		// @ts-ignore
		ZsxJstest._parseResponseAndSwapSelectors(document, newContent, '#subContainer', zxTrigger);

		// @ts-ignore
		console.log(document.getElementById('testContainer').innerHTML);

		// @ts-ignore
		expect(document.getElementById('test1').innerHTML).to.equal('bar');
		// @ts-ignore
		expect(document.getElementById('test2').innerHTML).to.equal('foo');

	});

	//@ts-ignore
	test('_parseResponseAndSwapSelectors - Zx-Keep Maintains Scroll Position', function() {

		var content = `
			<div id="outerContainer">
				<div id="scrollContainer" zx-keep="true" style="height: 100px; overflow-y: scroll;">
					<div style="height: 1000px;">
						<div id="test1">foo</div>
						<div id="test2">foo</div>
					</div>
				</div>
			</div>
		`;

		var originalHolder = document.createElement('div');
		originalHolder.innerHTML = content;

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');

		// @ts-ignore
		testContainer.appendChild(originalHolder);

		// @ts-ignore
		var scrollContainer = testContainer.querySelector('#scrollContainer');

		// Set the scroll of the scrollContainer as if the user scrolled it
		// @ts-ignore
		scrollContainer.scrollTop = 50;

		var newContent = `
			<div id="outerContainer">
				<div id="scrollContainer" zx-keep="true" style="height: 100px; overflow-y: scroll;">
					<div style="height: 1000px;">
						<div id="test1">foo</div>
						<div id="test2">foo</div>
					</div>
				</div>
			</div>
		`;

		var parser = new DOMParser();
		var responseDom = parser.parseFromString(newContent, 'text/html');

		var parser = new DOMParser();
		var linkElement = parser.parseFromString('<a href="/foo" zx-swap="#testId">Foo</a>', 'text/html').body.firstChild;
		var zxTrigger = ZsxJstest._normalizeZxTrigger(
			linkElement
		);

		// @ts-ignore
		ZsxJstest._parseResponseAndSwapSelector(document, responseDom, '#outerContainer', zxTrigger);

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');
		// @ts-ignore
		var scrollContainer = testContainer.querySelector('#scrollContainer');

		expect(scrollContainer.scrollTop).to.equal(50);

	});

	//@ts-ignore
	test('Form test', function() {

		var content = `
			<div id="outerContainer">
				<div id="innerContainer">
					Foo
				</div>
				<form action="/home/echo" method="POST" zx-swap="#innerContainer">
					<input type="hidden" name="goto" value="/ZsxJs/list"/>
					<button type="Submit">Form Swap</button>
				</form>
			</div>
		`;

		var originalHolder = document.createElement('div');
		originalHolder.innerHTML = content;

		// @ts-ignore
		var testContainer = document.getElementById('testContainer');

		// @ts-ignore
		testContainer.appendChild(originalHolder);

		// @ts-ignore
		var formItem = testContainer.querySelector('form');
		var formButton = formItem.querySelector('button');
		// formButton.click();
		// @ts-ignore
		ZsxJstest._decorateZeroSwapForm(testContainer, formItem);

	});

	test('_syncLinkParams', function() {

		var content = `
			<a href="/foo?bar=1" zx-swap="#testId">Foo</a>
			<a href="/foo?bar=2" zx-swap="#testId">Foo</a>
			<a href="/foo?bar=3" zx-swap="#testId">Foo</a>
			<a href="/foo?bar=4" zx-swap="#testId">Foo</a>
		`
		var documentFragment = document.createDocumentFragment();
		var parser = new DOMParser();
		documentFragment.appendChild(parser.parseFromString(content, 'text/html').body);

		var newLink = 'http://127.0.0.1:51404/foo?bar=5';
		var syncParams = ZsxJstest._parseSyncParams("bar");
		// @ts-ignore
		ZsxJstest._syncLinkParams(documentFragment, newLink, syncParams);

		var getLinks = documentFragment.querySelectorAll('a');

		console.log(getLinks);

		// Check that each link bar=5
		// @ts-ignore
		getLinks.forEach(function(link) {
			// @ts-ignore
			expect(link.href).to.equal('http://127.0.0.1:51404/foo?bar=5');
		});
	});

	test('_doSwap - aLink - zx-jump-guard=true', function() {

		var docText = `
			<div id="outerContainer">
			</div>
		`
		var parser = new DOMParser();
		var testDocument = new DocumentFragment();
		testDocument.appendChild(parser.parseFromString(docText, 'text/html').body);
		var oldElement = testDocument.querySelector('#outerContainer');

		var contentText = `
			<div id="outerContainer">foo</div>
			<a id="link" href="/foo" zx-swap="#outerContainer" zx-jump-guard="true">Foo</a>
		`
		var content = new DocumentFragment();
		content.appendChild(parser.parseFromString(contentText, 'text/html').body);
		var newElement = content.querySelector('#outerContainer');
		var linkElement = content.querySelector('#link');

		var zxTrigger = ZsxJstest._normalizeZxTrigger(linkElement);

		// console.log(zxTrigger);

		// zxTrigger = ZsxJstest._normalizeZxTrigger(holder.firstChild);
		ZsxJstest._doSwap(testDocument, oldElement, newElement, '#outerContainer', zxTrigger);

		// @ts-ignore
		expect(testDocument.querySelector('#outerContainer').innerHTML).to.equal('foo');
		//We should have an element called #zeroViewportSpacer on the testDocument
		// @ts-ignore
		expect(testDocument.querySelector('#zeroViewportSpacer')).to.not.be.null;

	});

	test('_doSwap - form - zx-jump-guard=true', function() {

		var docText = `
			<div id="outerContainer">
			</div>
		`
		var parser = new DOMParser();
		var testDocument = new DocumentFragment();
		testDocument.appendChild(parser.parseFromString(docText, 'text/html').body);
		var oldElement = testDocument.querySelector('#outerContainer');

		var contentText = `
			<div id="outerContainer">foo</div>
			<form action="/home/echo" method="POST" zx-swap="#container" zx-jump-guard="true">
				<button id="button" type="Submit">Form Swap</button>
			</form>
		`
		var content = new DocumentFragment();
		content.appendChild(parser.parseFromString(contentText, 'text/html').body);
		var newElement = content.querySelector('#outerContainer');
		var formElement = content.querySelector('form');
		var buttonElement = content.querySelector('#button');

		var zxTrigger = ZsxJstest._normalizeZxTrigger(formElement, buttonElement);

		console.log(zxTrigger);

		// zxTrigger = ZsxJstest._normalizeZxTrigger(holder.firstChild);
		ZsxJstest._doSwap(testDocument, oldElement, newElement, '#outerContainer', zxTrigger);

		// @ts-ignore
		expect(testDocument.querySelector('#outerContainer').innerHTML).to.equal('foo');
		//We should have an element called #zeroViewportSpacer on the testDocument
		// @ts-ignore
		expect(testDocument.querySelector('#zeroViewportSpacer')).to.not.be.null;

	});

	test('_doSwap - button overrides form - zx-jump-guard=true', function() {

		var docText = `
			<div id="outerContainer">
			</div>
		`
		var parser = new DOMParser();
		var testDocument = new DocumentFragment();
		testDocument.appendChild(parser.parseFromString(docText, 'text/html').body);
		var oldElement = testDocument.querySelector('#outerContainer');

		var contentText = `
			<div id="outerContainer">foo</div>
			<form action="/home/echo" method="POST" zx-swap="#container" zx-jump-guard="false">
				<button id="button" type="Submit" zx-jump-guard="true">Form Swap</button>
			</form>
		`
		var content = new DocumentFragment();
		content.appendChild(parser.parseFromString(contentText, 'text/html').body);
		var newElement = content.querySelector('#outerContainer');
		var formElement = content.querySelector('form');
		var buttonElement = content.querySelector('#button');

		var zxTrigger = ZsxJstest._normalizeZxTrigger(formElement, buttonElement);

		console.log(zxTrigger);

		// zxTrigger = ZsxJstest._normalizeZxTrigger(holder.firstChild);
		ZsxJstest._doSwap(testDocument, oldElement, newElement, '#outerContainer', zxTrigger);

		// @ts-ignore
		expect(testDocument.querySelector('#outerContainer').innerHTML).to.equal('foo');
		//We should have an element called #zeroViewportSpacer on the testDocument
		// @ts-ignore
		expect(testDocument.querySelector('#zeroViewportSpacer')).to.not.be.null;
	});

	test('_doSwap - button - zx-jump-guard=true', function() {

		var docText = `
			<div id="outerContainer">
			</div>
		`
		var parser = new DOMParser();
		var testDocument = new DocumentFragment();
		testDocument.appendChild(parser.parseFromString(docText, 'text/html').body);
		var oldElement = testDocument.querySelector('#outerContainer');

		var contentText = `
			<div id="outerContainer">foo</div>
			<form action="/home/echo" method="POST" zx-swap="#container">
				<button id="button" type="Submit" zx-jump-guard="true">Form Swap</button>
			</form>
		`
		var content = new DocumentFragment();
		content.appendChild(parser.parseFromString(contentText, 'text/html').body);
		var newElement = content.querySelector('#outerContainer');
		var formElement = content.querySelector('form');
		var buttonElement = content.querySelector('#button');

		var zxTrigger = ZsxJstest._normalizeZxTrigger(formElement, buttonElement);

		console.log(zxTrigger);

		// zxTrigger = ZsxJstest._normalizeZxTrigger(holder.firstChild);
		ZsxJstest._doSwap(testDocument, oldElement, newElement, '#outerContainer', zxTrigger);

		// @ts-ignore
		expect(testDocument.querySelector('#outerContainer').innerHTML).to.equal('foo');
		//We should have an element called #zeroViewportSpacer on the testDocument
		// @ts-ignore
		expect(testDocument.querySelector('#zeroViewportSpacer')).to.not.be.null;

	});
});
