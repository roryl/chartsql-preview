let controlIsPressed = false;
let fKeyWasHandled = false;

window.addEventListener('keydown', function(e) {
    if (e.key === 'Control') {
        controlIsPressed = true;
    }
    if(controlIsPressed && e.key === 'f' && !fKeyWasHandled) {
        if(document.activeElement !== fileSearch) {
            e.preventDefault();
            fileSearch.focus();
            fKeyWasHandled = true;
        }
    }
});

window.addEventListener('keyup', function(e) {
    if (e.key === 'Control') {
        controlIsPressed = false;
        fKeyWasHandled = false;
    }
});

fileSearch.addEventListener('keydown', function(e) {
    // If the key pressed was 'Escape'
    if (e.key === 'Escape') {
		// console.log('ESCAPE')
        // this.value = ''; // Clear the input
		document.getElementById('filterClear').click();
        // ZeroClient.set('Filter', ''); // Clear out the stored filter state
        // filterList(''); // Restore the list to show all items
        // toggleFilterClearButton(); // Hide the filter clear button
    }
});