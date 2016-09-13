/* require(["dojo/aspect"], function(aspect){
    aspect.after(myInstance, "execute", callback);
    ...
    handle.remove();
}); */


/* var eventHandle = dojo.connect(dojo.byId('myElement'), 'onclick', null, function() { //null = dojo.global
	alert('you clicked myElement');
}); 
// Disconnect eventHandle 
dojo.disconnect(eventHandle);*/
//First we create the buttons to add/del rows
var addBtn = new dijit.form.Button({
        id: "addBtn",
        type: "submit",
        label: "Add Row"  },
    "divAddBtn");//div where the button will load


//Button for Delete

var delBtn = new dijit.form.Button(
{ id: "delBtn", 
type: "submit", 
label: "Delete Selected Rows" }, "divDelBtn");


//Connect to onClick event of this buttons the respective actions to add/remove rows. 
//where grid is the name of the grid var to handle. 
dojo.connect(addBtn, "onClick", function(event) { 
// set the properties for the new item: 
var myNewItem = { id: grid.rowCount+1, type: "country", name: "Fill this country name" }; 
alert('you clicked myNewItem')
// Insert the new item into the store: 
// (we use store3 from the example above in this example) 
store.newItem(myNewItem); });

dojo.connect(delBtn, "onClick", function(event) {
    // Get all selected items from the Grid:
    var items = grid.selection.getSelected();
        if (items.length) {
        // Iterate through the list of selected items.
        // The current item is available in the variable
        // "selectedItem" within the following function:
            dojo.forEach(items, function(selectedItem) {
                if (selectedItem !== null) {
                    // Delete the item from the data store:
                    store.deleteItem(selectedItem);
                } // end if
            }); // end forEach
        } // end if
});