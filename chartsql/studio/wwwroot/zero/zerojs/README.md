<!-- ![alt text](docs/img/mascot-small.fw.png) -->


# ZSX.js

<img src="docs/img/mascot-small.fw.png" align="left">

Build a ***Zero JavaScript*** **User Experience** ;)

ZSX is a dependency free progressive enhancement library for server-rendered web applications. Build slick web apps with semantic HTML, CSS, links and forms — In any backend language.

Start with HTML and end with an amazing user experience!

<br />

```html
<!-- Swap out the element from the response of a link click into the page -->
<a href="./zxswap.html?message=hello" zx-swap="#targetContent">Say Hello</a>
```

![alt text](docs/img/examples/zxswap.gif)

ZSX is spiritually closest to [Unpoly](https://unpoly.com/), and similar to frameworks like [HTMX](https://htmx.org/), [Twinspark](https://twinspark.js.org/), and [Turbo](https://turbo.hotwired.dev/). However, it has an opinionated feature set for building highly maintainable yet interactive web applications. ZSX is more like a toolbox of HTML/HTTP enhancements, rather than a client side framework.


[ChartSQL Studio Editor](https://docs.chartsql.com) was the original source of ZSX and funds its development.

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [HTML API](#html-api)
- [Events API](#events)
- [CSS Reference](#css-reference)
- [ZSX Design Goals](#zsx-design-goals)
- [Developing Applications](#developing-applications)
- [Cookbook](#cookbook)
- [Common Issues](#common-issues)
- [Roadmap](#roadmap)

# Quick Start

Include the zsx.js script. It can be in the head or end of the body. There is `zsx.css` which contains styles and animations for visual elements like `zx-loader`.

## Installation
```html
<head>
	<!-- Style sheet for ZSX loading indicator styles -->
	<link rel="stylesheet" href="dist/zsx.css">
	<script src="dist/zsx.js"></script>
</head>
```

```html
<body>
	<!-- ... You can also include the script in the body -->
	<script src="dist/zsx.js"></script>
</body>
```
## Initialization

```html
<body>
	<!-- set zx-script-skip="true" so that body swaps do not execute this again -->
	<script zx-script-skip="true">
		let zsxjs = new ZsxJs();
		zsxjs.init(document, {
			/* options */
		});
	</script>
</body>
```

↑ [top](#zsxjs)

## Basic Example

```html
<!--- SERVER SIDE RENDERED HANDLEBARS TEMPLATE --->
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="stylesheet" href="dist/zsx.css">
		<script src="dist/zsx.js"></script>
		<title>ZSX - QuickStart</title>
	</head>
	<body>
		<h1>ZSX QuickStart</h1>

		<a href="?hello=true" zx-swap="#targetContent">Hello</a>
		<a href="?hello=false" zx-swap="#targetContent">Good Bye</a>

		<div id="targetContent" style="width: 300px; height:100px;">
			{{#if url.hello}}
				Hello World
			{{else}}
				Goodbye World
			{{/if}}
		</div>
		<script zx-script-skip="true">
			let zsxjs = new ZsxJs();
			zsxjs.init(document, {
				/* options */
			});
		</script>
	</body>
</html>
```

↑ [top](#zsxjs)

# Features

ZSX upgrades links, forms and buttons to make server rendered applications more responsive and user friendly.

ZSX adds improvements across three areas: *Page Fragment Updates*, *Enhanced Interactivity*, and *Navigation & State Management*. Together these features allow developers to build slick server rendered applications with HTML markup.

**Page Fragment Updates**: *Updating the DOM without full page reloads*

 - [Swap Client Side Content without Reload](#swap-client-side-content-without-reload) — [`zx-swap`](#zx-swap)
 - [Keep Client-Side Content During Swaps](#keep-client-side-content-during-swaps) — [`zx-keep`](#zx-keep)

**Enhanced Interactivity**: *Improving the user's visual experience*
 - [Page Jump Supression](#page-jump-suppression) - [`zx-jump-guard`](#zx-jump-guard)
 - [Visual Loading Indicators](#visual-loading-indicators) — [`zx-loader`](#zx-loader)
 - [Scroll Elements Into View](#scroll-elements-into-view) — [`zx-scroll-to`](#zx-scroll-to)
 - [Action Confirmation Dialogs](#action-confirmation-dialogs) — [`zx-dialog-confirm`](#zx-dialog-confirm)
 - [App-Style Links](#app-style-links) — [`zx-link-mode`](#zx-link-mode)

**Navigation and State Management**: *Maintaining the user's state*
 - [Synchronize URL Parameters Across Links](#synchronize-url-parameters-across-links) — [`zx-sync-params`](#zx-sync-params)
 - [Automatic History Management](#automatic-history-management)



↑ [top](#zsxjs) | *next:* [Features](#features)

## Swap Client Side Content without Reload

Dynamically update parts of the page by swapping elements based on their ID, class, or tag in response to link clicks or form submissions.

The content swap feature allows you to update portions of your page without a full page reload, enhancing performance and user experience.

See [`zx-swap`](#zx-swap)

![alt text](docs/img/examples/zxswap.gif)


↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## Keep Client-Side Content During Swaps

When swapping content, keep client side elements, javascript, canvas, or media content that should not be changed. You can mark which child elements need to be maintained.

See [`zx-keep`](#zx-keep-true--false)

![alt text](docs/img/examples/zxkeep.gif)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## Page Jump Suppression

Minimize disruptive page jumps from removed content.

When elements are removed from the DOM, the page may abruptly jump upward if the combined height of the remaining content and the viewport is less than the current scroll position. ZSX can guard against these jumps.

See [`zx-jump-guard`](#zx-jump-guard)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

##  Visual Loading Indicators

Easily add loading indicators to all of your links and buttons to improve responsiveness

**Links**

Links get a background color that moves from left to right to simulate a progress loading indicator

![alt text](docs/img/link_with_loader.png)

**Buttons**

Buttons get a background color that moves from left to right to simulate a progress loading indicator

![Button Loading](docs/img/button_with_loader.png)

See [`zx-loader`](#zx-loader)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

##  Scroll Elements Into View

Scroll newly swapped elements into the viewport. You can define custom scroll targets to ensure important content is brought into focus.

See [`zx-scroll-to`](#zx-scroll-to)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## Synchronize URL Parameters Across Links

Synchronize all links on the page to match the parameters of the clicked link.

URL syncrhonization allows you to swap small portions of the page, but ensure all other links on the page match the correct parameters.

See [`zx-sync-params`](#zx-sync-params)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## Automatic History Management

All links and forms that redirect to GET update the browser history and allow the user to navigate back to previous URLs.

***This feature is automatic and does not require any zx-attributes***

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## Action Confirmation Dialogs

Present a confirmation dialog before proceeding with destructive actions.

![alt text](docs/img/zx-dialog-confirm.png)

See [`zx-dialog-confirm`](#zx-dialog-confirm)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

## App-Style Links

Convert traditional `<a>` tags into app-like buttons or interactive controls that blend seamlessly into your application's interface. App Links prevent the display of URL tooltips and the standard context menu, providing a cleaner, more cohesive user experience for full screen apps.

See [`zx-link-mode`](#zx-link-mode)

↑ [top](#zsxjs) | [Features](#features) | *next section* → [HTML API](#html-api)

<br>

# HTML API

ZSX works by adding attributes like `zx-swap` to your existing HTML markup.


| attribute | Description |
| --- | --- |
| [zx-dialog-confirm](#zx-dialog-confirm) | Confirmation question before proceeding with the click |
| [zx-jump-guard](#zx-jump-guard) | Guards against page jumps from removed content
| [zx-keep](#zx-keep) | Keeps specified content in the DOM after a parent element is swapped  |
| [zx-link-mode](#zx-link-mode) | Whether to render the link as a browser (default) link or an application clickable element |
| [zx-loader](#zx-loader) | Specify that the link or button should have a loading indicator |
| [zx-script-skip](#zx-script-skip) | Whether to ignore executing a script tag during a swap |
| [zx-scroll-to](#zx-scroll-to) | Where to sroll to after the content swap |
| [zx-swap](#zx-swap) | Swaps target selector content from the response of a link click or form post |
| [zx-sync-params](#zx-sync-params) | Syncronizes URL parameters across links after a click |

## zx-dialog-confirm
**`string`**

Generates a confirmation dialog modal to confirm the action before proceeding with the link or button click.

**Used on Tags**: `<a>`, `<button>`

**Valid Values:** Any text string

There are additional attributes you can add to control the content:

- **zx-dialog-confirm-title**: Sets a title for the dialog (defaults to 'Confirm')
- **zx-dialog-confirm-yes**: The text of the yes/ok button
- **zx-dialog-confirm-no**: The text of the no/cancel button

### Examples:

#### `<a>` anchor links
```html
<a href="?hello=true" zx-dialog-confirm="Continue?">Hello</a>
```

#### `<button>` buttons inside forms
```html
<form method="post" action="/foo" zx-swap="#container">
	<button zx-dialog-confirm="Continue?">Hello</button>
</form>
```

### Usage Guidelines
You should ask users for confirmation of actions that are sensitive, cannot be easily undone, or have side effects. For example, deleting a record which cannot be recovered. Typically this will be used on form buttons (because links/GET should not make permanent changes).


↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-jump-guard
**`true | false`**

Enables or disables the use of a spacer element to guard against page jumps when content is expected to shrink or be removed.

**Used on Tags:** `<a>`, `<button>`, `<form>`

**Valid Values:**
- `true`: Activates the spacer to maintain page stability and prevent jumps during content changes.
- `false`: Deactivates the spacer, allowing the page to adjust naturally, which may result in jumps.

### Examples

#### `<a>` anchor links

```html
<a href="/shrinkContent" zx-swap="#targetContent" zx-jump-guard="true">Shrink Content</a>
```

#### `<form>` forms
```html
<form action="/home/echo" method="POST" zx-swap="#container" zx-jump-guard="true">
	<button id="button" type="submit">Form Swap</button>
</form>
```

#### `<button>` form buttons
The button within a form can also have zx-jump-guard, which will override the `<form>` value if it exists

```html
<form action="/home/echo" method="POST" zx-swap="#container" zx-jump-guard="false">
	<button id="button" type="submit" zx-jump-guard="true">Form Swap</button>
</form>
```

### Usage Guidelines:

When elements are removed from the DOM, the page may abruptly jump upward if the combined height of the remaining content and the viewport is less than the current scroll position.

`zx-jump-guard` manages the content height of elements that are being swapped to ensure that the page does not jump.

Calculating the page size to prevent jumps is an expensive (about 20ms) operation per swap. Therefore only add `zx-jump-guard` where you expect content may be removed or shrink.

- Use `zx-jump-guard="true"` for links, buttons or forms that swap content likely to cause large decreases in content size, ensuring that user experience remains smooth and uninterrupted.
- Set `zx-jump-guard="false"` disables zx-jump-guard

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-keep
**`true | false`**

Keeps an an element and its descendants unchanged when a parent is swapped out. Useful for maintaining page level content like video, audio forms or other interactive content that should not be swapped.

**Used on tags:** any html element

**Values Values:**

- `true`: Keep the element when swapping out the parent
- `false`: Do not keep the element when swapping out the parent


### Examples

```html
<a href="/" zx-swap="#container">Update</a>
<div id="container">
	Updated Content
	<div id="someContent" zx-keep="true">
		Kept Conent
	</div>
</div>
```

<aside>
<img src="https://www.notion.so/icons/error_green.svg" alt="https://www.notion.so/icons/error_green.svg" width="40px" />

Element with zx-keep requires that an Id be set

</aside>

### Usage Guidelines

To perform a zx-keep, ZSX needs to move, swap and restore the elements, which can be a costly operation. In conjunction with targeted use of zx-swap, use zx-keep on the inner most elements that are necessary to retain.

#### Limitations

**`<iframe>`**

Moving and restoring iframe element with zx-keep does not work. The iframe will be reloaded when it is restored into the DOM.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)



## zx-link-mode
**`browser | app`**

Specifies whether a link should behave like a regular browser link, or adopt a more application-like interaction.

**Used on Tags:** `<a>`

**Valid Values:**

- `"browser"`: (default link behavior) Maintains standard browser link behavior, including displaying URL tooltips and offering content menus. This is the default.
- `"app"`: Suppresses the URL tooltip and modifies the link's behavior to mimic a form button or application-like interaction.

### Examples:

#### App Link

```html
<a href="https://example.com/action" zx-link-mode="app">App-like Link</a>
```

#### Browser Link
This works exactly like a typical link and is provided in case we provide more types in the future

```html
<a href="https://example.com/page" zx-link-mode="browser">Standard Link</a>
```

### Usage Guidelines

Browsers provide some default features for links like tooltips, right click menu, and clicked and unclicked states. For some application where we want a desktop like app experience, disabling these default browser behaviors is desired.

When `zx-link-mode="app"` the link is just clickable text. You handle all additional styling for the link.

You'll typically want app style links when links wrap more complex context than just a test string, like cards, list items or links that are styled as buttons.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)


## zx-loader
**`true | false | cursor-wait | cursor-progress`**

Adds a visual progress indicator to buttons and links for requests that take time to complete.

**Used on Tags:** `<a>`, `<button>`

**Valid Values:**
- **true**: Add the default loading indicator when clicked
- **false**: Do not add a loading indicator
- **cursor-wait**: Change the cursor to the browsers default wait cursor
- **cursor-progress**: Change the cursor to the browsers default progress cursor

### Examples

- [`<a>` loading indicator](#a-loading-indicator)
- [`<a>` link with 'wait' cursor](#a-link-with-wait-cursor)
- [`<a>` link with 'progress' cursor](#a-link-with-progress-cursor)
- [`<button>` loading indicator](#button-loading-indicator)

#### `<a>` loading indicator

Animates the background of the text with a progress indicator. Useful for App-Style links or links that look like buttons.

![Link background loader](docs/img/link_with_loader.png)

```html
<a href="/path" zx-swap="#target" zx-loader="true">Link with Loader</a>
```

#### `<a>` link with 'wait' cursor

Uses the browsers default wait cursor style. Useful for regular links where you want to disuade clicking the element again.

```html
<a href="/path" zx-swap="#target" zx-loader="cursor-wait">Link with Wait Cursor</a>
```

<span style="cursor:wait;">Hover to Show Cursor</span>

You can override the `.zx-loading-cursor-wait` class if you need to customize the icon

```css
.zx-loading-cursor-wait {
	cursor: wait !important;
}
```

#### `<a>` link with 'progress' cursor

Uses the browsers default progress cursor style. Useful for regular links where it's okay for the user to click again

```html
<a href="/path" zx-swap="#target" zx-loader="cursor-wait">Link with Progress Cursor</a>
```

<span style="cursor:progress;">Hover to Show Cursor</span>

You can override the `.zx-loading-cursor-progress` class if you need to customize the icon

```css
.zx-loading-cursor-progress {
	cursor: progress !important;
}
```

#### `<button>` loading indicator

Animates the button with a simulated progress indicator and disables the button until the request completes

![Button Loading](docs/img/button_with_loader.png)

```html
<button type="submit" zx-loader="true">
	Loading Indicator
</button>
```

### Usage Guidelines
Use `zx-loader` for any action which is not, or nearly not immediate. You *shouldn't* add loaders to elements which do not have much delay because the quick flash of the loader is more distracting.

We provide different types of loading styles that serve different UX purposes.

- **progress**: Used to imply that an operation is proceeding. The simulated progress indicator gives a feeling that the application is moving forward.
- **cursor-wait**: Used to imply that the application is processing and the user should not click again.
- **cursor-progress**: Used to imply that the application is processing and the user CAN click again.


↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-script-skip

**`true | false`**

Tells ZSX to skip executing an inline `<script>` tag received in the response

**Used on Tags:** `<a>`, `<button>`

**Valid Values:**

- `true`: Skip executing the `<script>` tag
- `false`: Executes the script tag, this is the same as not existing

### Examples

```html
<body>
	<a href="/" zx-swap="body">Update!</a>
	Content {{now}}
	<script zx-script-skip="true">
		//Execute only on initial page load
	</script>
</body>
```

### Usage Guidelines

Uze `zx-script-skip` when you want to specify that a script should not be executed after performing a `zx-swap`. This is necessary in cases when the javascript should only have been executed on initial page load. For example setting up global libraries, like zsx.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-scroll-to
**`true | false | top | CSS selector`**

Tells ZSX to scroll to a particular element after completing a zx-swap. This can improve the user experience when the swapped elements may be out of view or we want to focus the new elements.

**Used on Tags:** `<a>`, `<button>`

**Valid Values:**

- **`true | false`**: When true, scroll to the first zx-swap selector element. When false, this disables zx-scroll-to and also a link URL hash target.
- **`#idSelector`**: Scroll to the provided Id, regardless of the zx-swap selectors
- `.classSelector` : Any valid CSS selector. The first item returned will be the target of the scroll
- `"top"` : Scroll to the top of the page

### Examples

**Default Browser hash(#) identifier**

When zx-swap is applied, if there is an id hash in the URL, it will scroll to that ID. This is the browser's semantic way to scroll to.

```html
<a href="/page#elementId" zx-swap="#elementId">Link</a>
```

**Scrolling to the Swap Target**

When `zx-scroll-to="true"` it will scroll to the location of the `zx-swap`

```html
<a href="?hello=true" zx-swap="#targetContainer" zx-scroll-to="true">Hello</a>
```

#### Scrolling to the newest created element

Sometimes as a result of adding a new item to the page, we will want to scroll to that item, except we do not know a unique ID for it because it does not exist yet. You can use a complex class selector to scroll to the last (or first) item.

```html
<button type="submit" zx-scroll-to=":nth-last-child(1 of .classList)">
```

#### Disable Page Change Scrolling

By default, ZSX handles links to different pages (base paths) by scrolling to the top of the page. This matches default browser behavior and user expectations when switching pages. In effect, when the base path changes, it is as if you set `zx-scroll-to="top"`.

You can change this by setting zx-scoll-to="false" to disable scrolling to top when the base path changes, or any other zx-scroll-to value.

```html
<a href="/page1" zx-swap="#targetContainer" zx-scroll-to="false">Hello</a>
<a href="/page2" zx-swap="#targetContainer" zx-scroll-to="false">Hello</a>
```

The reason for this behavior is that typically, in a multi-page appication, each page route is significantly different content. The usual experience is to start that page at the top of the content.

#### Smooth Scrolling

ZSX follows the browser/application level scroll setting. You can enable smooth scrolling by setting the `scroll-behavior` at the page level with CSS.

```html
<html lang="en" style="scroll-behavior: smooth;">
```

#### Scroll Margin

Sometimes you want the scroll location to be just above the target element. You define this in CSS on the element that will be scrolled to with CSS.

```html
<div id="myElement" style="scroll-margin-top: 20px;"></div>
```

### Usage Guidelines

Use `zx-scroll-to` sparingly, only when necessary to highlight an element that the user must perform in a workflow, or important information that they must see after an action.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-swap
**`#idSelector | .classSelector | tag-selector | list of CSS selectors`**

Swap out content in the current page with content from the response HTML.Specify the CSS selectors to target.

**Used on tags:** `<a>`, `<form>`

**Valid Values:**

- `#id`: An HTML element ID to swap
- `.class`: A set of class elements to swap
- `html-tag`: A set of HTML tags to swap
- `list`: A comma separated list of selectors to swap

### Examples

#### Swap #id Target

Swap a single element by target id

```html
<a href="?hello=true" zx-swap="#targetContent">Hello</a>
```

#### Swap .class Target

Swap all elements matching the target class

```html
<a href="?hello=true" zx-swap=".targetContent">Hello</a>
```

<aside>
<img src="https://www.notion.so/icons/error_green.svg" alt="https://www.notion.so/icons/error_green.svg" width="40px" />

When a class target is defined, each element needs a unique id in order to disambiguate the elements

</aside>

#### Swap Tag Target

Swaps the elements matching the given tag

```html
<a href="?hello=true" zx-swap="body">Hello</a>
```

<aside>
<img src="https://www.notion.so/icons/error_green.svg" alt="https://www.notion.so/icons/error_green.svg" width="40px" />

When a tag target is defined, if there are more than one result, each tag will need its own Id

</aside>

#### Swap Multiple Targets

Swap multiple targets by providing a comma separated list

```html
<a href="?hello=true" zx-swap="#targetContent,#target2,.classTarget">Hello</a>
```


#### &lt;form&gt; zx-swap

Swap out the element from the form post content

```html
<form action="/" method="POST" zx-swap="#anchorTargetContainer">
	<button type="Submit">Form Swap</button>
</form>
```

### Usage Guidelines
`zx-swap` is the primary feature of ZSX. As a result of every link or form action, you describe one or more elements to swap from the response HTML.

You should liberally use zx-swap throughout the application. For best performance, specify as narrow a target as possible. See [minimizing zx-swap targets](#minimzing-zx-swap-targets)

#### Swap Behavior
`zx-swap` swaps the innerHTML of the target and merges the attributes. This will preserve event handlers and references of the old element, but any child event handlers will not be preserved.

***Reattach event handlers using `zsx-zx-swap-after` event***

Listen for the zx-swap event and reattach the event handlers manually for any children after the swap is complete. See [`zsx-zx-swap.after`](#zsxzx-swapafter)

#### Form Redirects

Forms can either be a GET request or a POST. Typically when a POST, the server should redirect back to a GET (POST-REDIRECT-GET style) so that the browser does not perform duplicate submits.

ZSX will update the URL history to the value of any GET redirect. POST redirects are not added to the history.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

## zx-sync-params
**`string list`**

Synchronizes parameters from an `<a>` link click with other links on the page.

**Used on tags**: `<a>`

**Valid Values:**

- `param`: A single param to be synchronized with other links
- `list`: A comma separated list of params to sync with other links

### Examples

#### Single Parameter

```html
<a href="?hello=true" zx-swap="#targetContent" zx-sync-params="hello" >Hello</a>
<a href="?hello=false" zx-swap="#targetContent" zx-sync-params="hello" >Goodbye</a>
<a href="?hello=false" zx-swap="#targetContent" >Other Link</a>
```

#### Multiple Parameters

```html
<a href="?hello=true&foo=bar" zx-swap="#targetContent" zx-sync-params="hello,foo" >Hello</a>
```

### Usage Guidelines

You use `zx-sync-params` when you need to sync all links using the parameter, even when only a small subset of the page content is updated.

This is necessary when the URL contains important state that should persist across subsequent clicks, regardless of swapped content.

The `zx-sync-params` logic is:

- **WHEN** a link with `zx-sync-params` is clicked
- **FOR** each link on the page
- **FOR** each of the parameters in the clicked `zx-sync-params`
- **IF** that parameter is in the other link's `href`
- **THEN** update the parameter to the value of the parameter in the clicked link.
- **UNLESS** the other link itself contains a `zx-sync-params` with the same parameter name


`zx-sync-params` can take a single parameter or multiple parameters.

**Bypassing Link Update**

Other links on the page which should maintain their parameter value can be excluded by having their own `zx-sync-params`.

For example, consider an element that needs to be visible or hidden. One link shows it, the other link hides it, all other links need to reflect the last action

```html
<a href="?showMessage=true" zx-swap="#pageContent" zx-sync-params="showMessage" >Show</a>
<a href="?showMessage=false" zx-swap="#pageContent" zx-sync-params="showMessage" >Hide</a>
<a href="?showMessage=false" zx-swap="#pageContent" >Other Link</a>

<div id="pageContent">
	Hellow World,
	{{#if url.showMessage}}
		<div>
			It is a good day!
		</div>
	{{/if}}
</div>
```

Because both the show and hide links have a `zx-sync-params`, that means the inverse link is ignored when updated. Therefore only the 'Other Link' gets updated.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [Events](#events)

# Events
ZSX fires the following events that your application can listen to and perform additional actions.

| Event | Description |
| --- | --- |
| zsx.zx-swap.after | After a content zx-swap for one selector has been completed.

## zsx.zx-swap.after
Fired after the swap for a selector is completed. If the zx-swap contained multiple selectors, a `zsx.zx-swap.after` event is emitted for each selector.

**event.detail {object}**

* `oldElement` The old element that was swapped out. No longer exists in the DOM
* `newElement` Live DOM reference to the new element that was swapped in
* `selector` The selector that was used to locate the elements

### Examples

```javascript
// Example resetting bootstrap tooltips and popovers after a swap
document.addEventListener('zsx.zx-swap.after', function(event) {
	// Respond to zsx.zx-swap.after event
})
```

### Usage Guidelines
Use the `zsx.zx-swap.after` to process the content after ZSX is finished replacing it. You might use this to re-attach event listeners and state from other libraries or purposes.

See Cookbook [Restoring Events and Features After Swap](#restoring-events-and-features-after-swap)


↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | *next section* → [CSS Reference](#css-reference)

# CSS Reference
The following CSS classes are created by zsx.css for the visual features. You can override these style classes if needed.

| CSS | Purpose |
| --- | --- |
| .zx-link-app | Added to links that have `zx-link=mode="app"` to add default pointer styles.
|.zx-loading-cursor-wait | The cursor style applied when `zx-loader="cursor-wait"` is used
|.zx-loading-cursor-progress | The cursor style applied when `zx-loader="cursor-progress"` is used

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | *next section* → [ZSX Design Goals](#zsx-design-goals)

# ZSX Design Goals

ZSX has an opinionated philosophy in regards to web application architecture. These opinions dictate it's featureset. The ZSX Design Goals will help you determine if ZSX is right for your development style.

ZSX is designed to enhance server rendered applications without breaking user’s expectations of browser behavior.

We built [ChartSQL Studio](https://docs.chartsql.com) with ZSX and followed these guiding principles:


- [URLs and HTTP is the Right Architecture](#urls-and-http-is-the-right-architecture)
- [Links, Forms, and Buttons Are All You (mostly) Need](#links-forms-and-buttons-are-all-you-mostly-need)
- [Web Components Are Not Necessary](#web-components-are-not-necessary)
- [Use Minimal Javascript](#use-minimal-javascript)
- [Assume Full Page Rendering](#assume-full-page-rendering)
- [Explicit Link and Form Handling](#explicit-link-and-form-handling)
- [Must Be Able to Hard Refresh](#must-be-able-to-hard-refresh)

Use Cases, Future Development plans & Alternatives to ZSX

 - [When to Use ZSX](#when-to-use-zsxjs)
 - [Future Development](#future-development)
 - [Alternatives](#alternatives)


## URLs and HTTP is the Right Architecture

Regardless of how you render the front end of the application, we believe that URLs and HTTP (GET and POST) is broadly the right application architecture.

Web applications should be addressible by URLs (links) and backend state changes should be communicated to the server with POSTs (forms).

Applications should be decomposed into pages (/entity1, /entity2) representing different resources, following a generally RESTful style.

It follows that HTML, links and forms are the natural way to work with the web application architecture.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Links, Forms and Buttons Are All You (Mostly) Need

Modern HTML contains everything necessary for a user to interract with 99% of web applications in an accessible and semantic way. It is not necessary to reinvent form controls or client side routing mechanisms. Virtually any DOM driven user experience can be maniuplated with just links, forms and buttons. Many developers are not even aware of modern features of HTML.

More advanced visual fidelity can be achieved with minor javascript, canvas and WebGL functionality. But when you are working with the DOM, rely on links, forms and buttons unless it can't be achieved any other way.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Web Components Are Not Necessary
A lot of 'modern' front end development seeks to componetize HTML. In fact 'web components' in the general sense is not a new technology. Some of the earliest web frameworks like JSP were very component-like. However, unless you are creating a "component library" for others to use, we do not believe web components bring enough benefits.

Building HTML UIs requires a lot of markup. Componetizing that markup does not lead to significant user improvement or developer ergonomics, in our opinion.

We believe that it is easiest and most maintainable to build web UIs in basic HTML pages that can be read as straight HTML.

ZSX exists to enhance that experience while staying true to the nature of HTML and HTTP.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Use Minimal JavaScript

ZSX takes an minimalist approach to JavaScript. While some JS is necessary, we think JS heavy applications are not good UX.

We believe the best UX is based on fundamental HTML/HTTP, links and forms, and that JavaScript-first frontends are overly complex and brittle to maintain.

In a ZSX application, you should be able to look at the rendered HTML and follow the links and forms to understand the application interactions.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Assume Full Page Rendering

In a ZSX application, the server by default always fully renders pages. ZSX provides features to hot swap elements on the page and avoid a full browser page reload.

Avoiding a full page reload improves performance of the browser. Browser performance is improved because it doesn't need to reflow the entire document and re-execute scripts. This performance improvement is perceived by the user as more responsive.

Full server renders might seem costly, but it greatly improves the maintainability of applications:

- Most pages in an application are fast enough that it doesn't matter.
- Forces developers to think through the first page load experience up front.
- Dissuades client side hydration which we consider an anti-pattern.
- "Premature optimization is the root of all evil" - You don't need to spend time optimizing the performance of pages that are seldom used.
- Caching of pages can be done server-side in a more robust manner

The payload size of compressed HTML over the wire is not a significant factor in perceived latency compared to server response time and client side processing.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Explicit Link and Form Handling

As compared to some similar libraries, ZSX does not automatically enhance all links or forms, because:

- The application will be most responsive when you swap the smallest amount of content necessary
- You should be able to inspect the HTML and understand what each link/form behavior is without having to know hidden information
- You should think through exactly which content needs to be updated after every click or form post.

Therefore when using ZSX, for every link or form, you explicitly decide which content needs to be updated, and which zx-* features to apply.


↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Must Be Able to Hard Refresh

A litmus test for web applications with proper UX is “can you hard refresh.” Many applications exhibit poor user experience on hard refresh:

- It takes a long time for the page to load
- Time to interaction is delayed as client side features are hydrated
- There may be a lot of flashing and layout thrashing as elements are loaded in
- States that were clicked through may be lost

This leads to many lost features native to browsers:

- Cannot share links
- Cannot bookmark links
- Cannot open a link in a new tab
- Cannot duplicate a tab
- Cannot refresh to see style changes when developing

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## When to Use ZSX

Use ZSX for server rendered applications that rely on links, forms and HTML. Often referred to as 'multi-page applications'

If your application is fully SPA, then ZSX is not a good fit.

ZSX is a small library and will work well with other JS libraries.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Future Development
ZSX will only add enhancement features that we find solve common tasks in our applications, without breaking fundemental browser architecture. The HTML specification is continually evolving with new features that make browser apps more responsive and user-friendly. We are betting on HTML/CSS/HTTP and Server Side Rendering as the core of applications.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

## Alternatives

ZSX is similar to HTMX and Unpoly.js in its fundamental philosophy of server rendered applications. However it differs from them in important ways:

### HTMX

HTMX seeks to add new non-standard “hypermedia” features to HTML. Essentially, it allows turning any element into a link, button, GET/POST/PATCH. This is not semantic and means that applications built in HTMX cannot work with JavaScript turned off.

We explicitly do not like that any element on the page can be an interaction point, instead [Links, Forms, and Buttons Are All You (mostly) Need](#links-forms-and-buttons-are-all-you-mostly-need).

### Unpoly.js

Unpoly.js is probably the closest philosophically to ZSX. However we consider it’s feature set more complex than we desire. We believe there are only a few necessary conventions that we need. Unpoly drifts away from semantic HTML with features like layers. In comparison, ZSX only enhances fundamental browser behavior.

Unpoly also has a lot of configurations for targeting different elements, parents, children, appending, prepending and automatically choosing ambiguous cases. We consider these uncessary.

Instead, with ZSX, you control your HTML, the IDs, and classes you wish to target. This makes it easier to maintain your HTML and understand your content updates. You can always inspect the source HTML to understand precisely what will happen.

### Turbo / Hotwire

Turbo is also another strategy to “dramatically reduce the amount of custom JavaScript” but it has different goals. It provides features like ‘Frames’ and ‘Streams’ to add additional architectural options. We believe that Turbo goes too far beyond the idea that [URLs and HTTP is the Right Architecture](#urls-and-http-is-the-right-architecture)

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | *next section* → [Developing Applications](#developing-applications)

# Developing Applications

Additional architectural tips and tricks for building maintainable and interactive web applications with ZSX

- [Start with the Raw HTML](#start-with-the-raw-html)
- [Understanding Application State](#understanding-application-state)
- [User Interactions](#user-interactions)
- [Using Loading Indicators](#using-loading-indicators)
- [Using Animations](#using-animations)
- [Performance Optimization](#ui-performance-optimization)

## Start With The Raw HTML

When building your application, start with your HTML, Links and FORMs without any zx-* attributes. Get your basic workflows and content correct. When you are confident in the features, then enhance the UX by adding in attributes like `zx-swap`, `zx-loader`, `zx-dialog-confirm` to improve the slickness of your application.


## Understanding Application State

State for an application UI can live in different architectural layers. Where you decide to store your state depends on how it needs to be accessed and interact with browser capabilities.

One of the most challenging decisions in designing an application is deciding just where the UI state should live. This guide gives some requirements and recommendations.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### Database/Backend

Use the Database/Backend when the UI state must survive browser sessions or application restarts. The application will load and render the database/backend state into the HTML.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### Server Session

Use Server Sessions when the UI state must not be shareable, does not need to be permenantly persisteted, but must survive page refreshes. Mutating session state requires interacting with the server. Your server will maintain the session variables and render them into HTML. With session state, all open tabs for a single browser instance will share the same state.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### URL Parameters

Use URL Parameters when the UI state can be shareable, disclosable, and survive refreshes. URL state should be used whenever possible to match users expectations of browser functionality. URL state allows the page to be shareable, bookmarkable, deep linked, and opened in multiple tabs and multiple browsers independently.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### Cookies

Use Cookies when the UI state must not be shareable across users or browsers, and can be set by the client without posting to the server. Cookies allow bi-directional synchronization of state with the browser and server. The server can use the cookies to control rendering output, and the client can also set the cookies (whereas the browser cannot set session data without a request to the server)

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### localStorage

Use localStorage when the UI state must not be shareable, and does not or must not be shared with the server for rendering. The client can set and restore values on page load into localStorage.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

### Javascript/Page State

Use Javascript/Page Stage when you need small client side features like tooktops. Page state is kept in runtime variables or HTML data-* attributes. Page State is never rendered by the server or shared with it. Page state should be kept to a minimum so that the convention of URL refreshing and link sharing is maintained.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

## User Interactions

Links and Forms are the bedrock of HTML and HTTP interaction through a browser. Links (&lt;a href&gt;) represent GET requests and Forms (&lt;form&gt;) represent POST requests.

You should build your application interaction elements entirely out of links and forms wherever possible. This is the most maintainable, accessible and straightforward way to build on the web.

ZSX enhances links and forms by providing features to control how to render the response content. It is the same response content that would have rendered had JS been turned off. But with ZSX, you can speed up your responsiveness of links and forms.

Minor interactions like hover states, tooltips and alerts can be entiely client side.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

## Using Loading Indicators

Loading indicators should be used whenever the server response time can be greater than 100ms.

We do not automatically add loading indicators to every link/button because when they are not needed, they add unecessary distraction.

See [`zx-loader`](#zx-loader) for optionally adding loading indicators.

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

## Using Animations
In general, using animations and page transitions is an anti-pattern. The best UX is: ***Instantly change that which the user should notice***

The fastest change possible is simply to update the content. Animating content in and out is initially slick, but unecessary.

If you use any animations, they must do the following:
- Start immediately on the user click
- The user must never have to wait for the animation itself to finish to click the next action that is available.

This means that you cannot wait to start animations after a request has finished. It's too late and ***will make the application feel sluggish***

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

## UI Performance Optimization

Most of the processing time is waiting on one of three operations: network requests, DOM swaps, and inline javascript. Decreasing the amount of time for these operations will have the biggest impact on application responsiveness.

Follow these techniques in this order to improve the performance of your application:

- [Optimize Time to Response](#optimize-time-to-response)
- [Minimize zx-swap Targets](#minimzing-zx-swap-targets)
- [Decrease Inline Javascript](#decreasing-inline-javascript)
- [Syncrhonizing Links](#synchronizing-links)
- [Server Side Fragments](#server-side-fragments)

### Optimize Time to Response
You should always seek to first optimize the backend server performance. Requests which respond in &lt; 100ms are going to feel almost instantaneous to the user. Fast server responses improve both full page loads, and subsequent zx-swap loads.

Note: We find that the amount of raw HTML returned is not a significant factor, just response time. So a lot of HTML fully cached and quick from the server is a very viable optimization.

### Minimzing zx-swap Targets
The time it takes to place new HTML into the DOM is many time larger than it takes to parse the HTML. While parsing takes 1-10ms, DOM placement per swap target will be 5-100ms.

Therefore you want to reduce the amount of HTML to be swapped, and the number of swaps that need to take place.

Ideally, have each `zx-swap` only target the smallest parent that is necessary to update the content. Don't have more `zx-swap` targets than is necessary. Don't just `zx-swap` the body tag, instead think carefully about updating only specific page fragments.

### Synchronizing Links
Don't use `zx-swap` to replace link URLs on the page, as swapping is an expensive operation. You can use [`zx-sync-params`](#zx-sync-params) feature to update all links on the page to match the clicked URL.

### Decreasing Inline Javascript
`zx-swap` also executes any inline javascript and can be a source of unexpected delay. If the javascript is not necessary to run on every swap, move it outside of the target.

### Server Side Fragments
COMING SOON:

The final optimization is to have the server return partial HTML based on the `zx-swap` target that was requested. Because this adds complexity to the backend to maintain two rendering paths, we use this sparingly. Relying too much on server side fragments means that the initial page loads will be slow, which is not good UX. Also the amount of HTML returned is not a critical factor compared to the server response time. So only use this method when you can significantly decrease the server response time.


↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | *next section* → [Cookbook](#cookbook)

# Cookbook
Solving common application design tasks with ZSX

- [Restoring Events and Features After Swap](#restoring-events-and-features-after-swap)

## Restoring Events and Features After Swap
If you have other javascript that needs to be attached to the swapped elements, you can do so by listening on [`zsx.zx-swap.after`](#zsxzx-swapafter) event

```javascript
// Example resetting bootstrap tooltips and popovers after a swap
document.addEventListener('zsx.zx-swap.after', function(event) {

	// Get the new element from the swap event
	var element = event.detail.newElement;

	// Remove any existing tooltips and popovers if they exist
	var tooltips = element.querySelectorAll('.tooltip');
	var popovers = element.querySelectorAll('.popover');

	tooltips.forEach(function(tooltip){
		tooltip.remove();
	});

	popovers.forEach(function(popover){
		popover.remove();
	});

	// Select and add the tooltips
	var tooltipTriggerList = element.querySelectorAll('data-bs-toggle="tooltip"]')
	tooltipTriggerList.forEach(function(tooltipTriggerEl){
		return new bootstrap.Tooltip(tooltipTriggerEl)
	})

	// Select and add the popovers
	var popoverTriggerList = element.querySelectorAll('[data-bs-toggle="popover"]')
	popoverTriggerList.forEach(function (popoverTriggerEl) {
		return new bootstrap.Popover(popoverTriggerEl)
	});

})
```

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | [Cookbook](#cookbook) | *next section* → [Roadmap](#roadmap)

# Roadmap
Features or improvements to be completed

| Feature |
| --- |
| Enhance zx-dialog-confirm to work from either buttons or forms

↑ [top](#zsxjs) | [Features](#features) | [HTML Api](#html-api) | [Events](#events) | [ZSX Design Goals](#zsx-design-goals) | [Developing Applications](#developing-applications) | [Cookbook](#cookbook) | [Roadmap](#roadmap) | *next section* → [Common Issues](#common-issues)

# Common Issues

The following are common errors that ZSX will throw when misusing features

## ZSX: Multiple elements found with selector "${selector}" but no id found to disambiguate them.

When your zx-swap directive results in multiple elements, each element needs a unique id in order to be able to determine which content area is which

# Contributing

We are not currently taking other contributors but you can open issues and we will address them.
