var controlIsPressed = false;
var fKeyWasHandled = false;
var fileSearch = document.getElementById('fileSearch');

window.addEventListener('keydown', function(e) {
    if (fileSearch === null) {
        return;
    }

    if (e.key === 'Control' || e.key === 'Meta') {
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
    if (e.key === 'Control' || e.key === 'Meta') {
        controlIsPressed = false;
        fKeyWasHandled = false;
    }
});

if (fileSearch != null) {
    fileSearch.addEventListener('keydown', function(e) {
        // If the key pressed was 'Escape'
        if (e.key === 'Escape') {
            // console.log('ESCAPE')
            // this.value = ''; // Clear the input
            // Unfocus all inputs
            document.activeElement.blur();
            document.getElementById('filterClear').click();
            // ZeroClient.set('Filter', ''); // Clear out the stored filter state
            // filterList(''); // Restore the list to show all items
            // toggleFilterClearButton(); // Hide the filter clear button
        }
    });
}