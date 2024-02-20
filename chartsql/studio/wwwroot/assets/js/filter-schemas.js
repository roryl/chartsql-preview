var isControlBeingPressedForSchemaFiltering = false;
var fKeyWasHandledForSchemaFiltering = false;
var schemaFilterSearch = document.getElementById('schemaFilterSearch');

window.addEventListener('keydown', function(e) {
    if (schemaFilterSearch === null) {
        return;
    }

    if (e.key === 'Control' || e.key === 'Meta') {
        isControlBeingPressedForSchemaFiltering = true;
    }

    if(isControlBeingPressedForSchemaFiltering && e.key === 'f' && !fKeyWasHandledForSchemaFiltering) {
        if(document.activeElement !== schemaFilterSearch) {
            e.preventDefault();
            schemaFilterSearch.focus();
            fKeyWasHandledForSchemaFiltering = true;
        }
    }
});

window.addEventListener('keyup', function(e) {
    if (e.key === 'Control' || e.key === 'Meta') {
        isControlBeingPressedForSchemaFiltering = false;
        fKeyWasHandledForSchemaFiltering = false;
    }
});

if (schemaFilterSearch != null) {
    schemaFilterSearch.addEventListener('keydown', function(e) {
        // If the key pressed was 'Escape'
        if (e.key === 'Escape') {
            // console.log('ESCAPE')
            // this.value = ''; // Clear the input
            document.activeElement.blur();
            document.getElementById('schemaFilterClear').click();
            // ZeroClient.set('Filter', ''); // Clear out the stored filter state
            // filterList(''); // Restore the list to show all items
            // toggleFilterClearButton(); // Hide the filter clear button
        }
    });
}