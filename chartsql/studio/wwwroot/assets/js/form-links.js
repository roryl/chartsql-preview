/**
 * updateLinksToHiddenForm.js
 *
 * Purpose:
 * This script enhances the user experience for a desktop-like web application
 * by modifying the behavior of anchor tags with query parameters in their URLs.
 * The modification prevents the default browser action for links and avoids
 * displaying the hover tooltip that typically appears at the bottom of the browser.
 * Instead, the script programmatically creates and submits a hidden form with the
 * query parameters as input fields. It supports the principle of progressive
 * enhancement by allowing the application to function with standard links if
 * JavaScript is disabled.
 *
 * How it works:
 * 1. The script scans the document for all anchor tags.
 * 2. For each link that contains query parameters in the 'href' attribute,
 *    and is not a special link (such as 'mailto:', 'tel:', 'javascript:', or a hash link),
 *    the script performs the following actions:
 *    - Parses the query parameters and the pathname from the 'href' attribute.
 *    - Creates a hidden form with input elements corresponding to the query parameters.
 *    - Appends the form as a child of the link's immediate parent element.
 *    - Updates the link's click event to prevent the default navigation and
 *      submit the hidden form instead.
 *    - Removes the 'href' attribute from the anchor tag to prevent it from
 *      showing the URL tooltip and triggering navigation.
 *    - Applies a CSS class to ensure the link still shows a pointer cursor on hover.
 *
 * Why this approach:
 * This script is intended to be included in the 'head' of the HTML document
 * with the 'defer' attribute, which ensures that the script runs after the
 * document has been parsed but before the DOMContentLoaded event. By doing so,
 * the links are modified as early as possible, reducing the chance of users
 * seeing a URL tooltip before the JavaScript has had a chance to run.
 * Using this approach also allows for better SEO and accessibility, as the original
 * links are still present in the HTML markup and can be followed by crawlers or
 * when JavaScript is disabled, in line with progressive enhancement principles.
 *
 * Usage:
 * Include this script in your HTML document's head with the defer attribute:
 *
 * <script src="updateLinksToHiddenForm.js" defer></script>
 *
 */
function updateLinksToHiddenForm() {
	// Helper function to extract the query parameters and path from a URL
	function parseUrl(url) {
		const urlObj = new URL(url, window.location.origin);
		return {
			queryParams: Object.fromEntries(urlObj.searchParams),
			path: urlObj.pathname
		};
	}

	// Helper function to create a hidden form with key-value pairs as input fields
	function createHiddenForm(parentElem, action, queryParams) {
		const form = document.createElement('form');
		form.method = 'GET';
		form.action = action;
		form.style.display = 'none';

		for (const key in queryParams) {
			const input = document.createElement('input');
			input.type = 'hidden';
			input.name = key;
			input.value = queryParams[key];
			form.appendChild(input);
		}

		parentElem.appendChild(form);
		return form;
	}

	// Add a CSS rule to the head to style links with a pointer cursor
	const styleSheet = document.createElement('style');
	styleSheet.innerText = '.link-with-form { cursor: pointer; }';
	document.head.appendChild(styleSheet);

	// Get all anchor tags on the page
	const links = document.querySelectorAll('a');

	// Loop over each link and update it
	links.forEach(link => {

		// If the attribute studio-form-links="false" is present, skip this link
		if (link.getAttribute('studio-form-links') === 'false') {
			return;
		}

		const href = link.getAttribute('href');
		if (href && href.includes('?') && !href.startsWith('javascript:') && !href.startsWith('mailto:') && !href.startsWith('tel:') && !href.startsWith('#')) {
			const { queryParams, path } = parseUrl(href);
			const form = createHiddenForm(link.parentNode, path, queryParams);

			// Update the anchor link to submit the hidden form on click
			link.addEventListener('click', function(event) {
				event.preventDefault();
				form.submit();
			});

			// Remove the href attribute and style the link
			link.removeAttribute('href');

			// Apply a role of 'link' so assistive technologies treat this element as a link
			link.setAttribute('role', 'link');

			// Add tabindex to make the element focusable
			link.setAttribute('tabindex', '0');

			link.classList.add('link-with-form');
		}
	});
}

// Execute the function to update all links on the page
updateLinksToHiddenForm();