var imageListStore;
var platformObj;// contains the array of platform mdf assoc
var relatedSoftwareObj;//contains the array of related software info
var gridLength;
var mdfListObj = new Array();//stores the array of mdf concepts
var imageNotesArr = new Array();// stores the image notes
var imageListDataGridArr = new Array();
var grid;
// handles for view/edit/create buttons
// var viewImageHandle, editImageHandle, createImageHandle;

function viewAll(releaseId){
	alert(releaseId);
	var data = {
			//identifier: "imageName",
			items: []
	};
	/*var serviceUrl = softwareServiceURL + '/v1/cspr/imagesViewAll/'+osTypeId+'/'+releaseId;*/
	var serviceUrl = "http://wwwin-hdonepud-irt-dev.cisco.com/software" + '/v1/shr/image/upgradeplanner/1108';
	console.log('serviceUrl' + serviceUrl);
	/*v1/image/upgradeplanner*/

	require(['dojo/_base/lang', 'dojox/grid/DataGrid', 'dojo/data/ItemFileWriteStore', 'dijit/form/Button' , 'dojox/grid/_CheckBoxSelector', 'dojo/dom', 'dojo/domReady!', 'dojo/request/xhr'],
			function(lang, DataGrid, ItemFileWriteStore, Button, _CheckBoxSelector, dom , domReady, xhr){
		/*set up data store*/
		xhr(
			serviceUrl,{
			// Handle as JSON Data
			handleAs : "json",
			headers: {
                "X-Requested-With": null
            },
			preventCache: true
		}).then(function(data_list) {
				//console.log("data>>>");// + dojo.toJson(data_list[0]));
				gridLength = data_list.length;
				for ( var q = 0, n = data_list.length; q < n; q++) {										
					data.items.push(lang.mixin(data_list[q % n]));
					if (data_list[q % n].accesslevel == "Guest Registered") {
						console.log('setting guest level apprival >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
						document.getElementById('needGuestApproval').value = "Y";
					}
					//data.items.push(dojo.mixin({ id: i+1 }, data_list[q]));
					imageListDataGridArr.push(data_list[q]);
				}

				imageListStore = new ItemFileWriteStore({
					data : data
				});

				/*set up layout*/
				var layout = [ 
								{
									type : "dojox.grid._CheckBoxSelector"
								},			               
				               [
{
	'name' : 'Feature Set Description',
	'field' : 'imageName',
	'width' : '300px',
	
},{
	'name' : 'Designator',
	'field' : 'isGoingToCco',
	'width' : '350px',
	'formatter' : function(item, rowIndex,cell) {
		var info = "<table><tr><td><ul>";
		for (var key in item) {
			//console.log(key + ': ' + item[key]);
			if(key.indexOf("_") != -1){//do nothing
			}else{
				info = info + "<li>" + item[key] + "</li>";
			}
		}
		info = info + "</ul></td></tr></table>";
		return info; 
	}
},
{
	'name' : 'Feature setDesc:CCO',
	'field' : 'isGoingToCco',
	'width' : '350px'
}
				             
				                
				                ] ];

				dojo.forEach(dijit.findWidgets(dojo
						.byId(upgradePlannerViewgridDiv)), function(w) {
					w.destroyRecursive();
				});

				/*create a new grid*/
				grid = new DataGrid({
					id : 'upgradePlannerViewGrid',
					store : imageListStore,
					structure : layout,
					noDataMessage : '<span class="dojoxGridNoData"> No Image Available </span>',
					loadingMessage : '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
					escapeHTMLInData : false,
					autoWidth : true,
					autoHeight : true
				});
				/*append the new grid to the div*/
				grid.placeAt("upgradePlannerViewgridDiv");
				/*Call startup() to render the grid*/
				if ($.inArray('RELEASE_NUMBER', metaDataArray) != -1) {
					console.log('rel true');
					grid.layout.setColumnVisibility(0,true);
				} else {
					console.log('rel false');
					grid.layout.setColumnVisibility(0,false);
				}
				if ($.inArray('IMAGE_NAME', metaDataArray) != -1) {
					console.log('img name true');
					grid.layout.setColumnVisibility(1,true);
				} else {
					console.log('img name false');
					grid.layout.setColumnVisibility(1,false);
				}
				if ($.inArray('IMAGE_NAME', metaDataArray) != -1) {
					console.log('img name true');
					grid.layout.setColumnVisibility(1,true);
				} else {
					console.log('img name false');
					grid.layout.setColumnVisibility(1,false);
				}
				
							
				grid.startup();
				//hideWait();
			}, 
			function(err) { 
				console.log(err);
			},
			function(evt) {
			});
		//});
	});

}

function editImage(index)
{
console.log('in side edit Image' + index);
var items = grid.selection.getSelected();
var str = grid.structure;
/*if(items.length>1){
					        	alertBox("Please select only one row at a time to edit");
					        }*/ 
console.log('len::' + items.length);
/*selectedItem = items[0];
editRowIndex = grid.getItemIndex(items[0]);
editProject = grid.getCell(0).get(editRowIndex,items[0]);
editProduct = grid.getCell(5).get(editRowIndex, items[0]);
editComponent = grid.getCell(6).get(editRowIndex, items[0]);
str[0][4].editable=true;
str[0][5].editable=true;
str[0][6].editable=true;
grid.set("structure",str);
grid.selection.setMode('none');*/
if(items.length>0) {
	/*var imageFeatureSetArr = [];*/
    dojo.forEach(items, function(selectedItem) {
        if(selectedItem !== null){
        	/*console.log('selectedItem>>' + dojo.toJson(selectedItem));*/
				// var imageObj = {"imageName" : selectedItem.imageName,
						// "isGoingToCco" : selectedItem.isGoingToCco};
				 /*imageFeatureSetArr.push(imageObj);*/
				 //imageListStore.push(imageObj);
				 //var newItem = {"id" : cdets.i, "col2": project, "col3": product, "col4": component, "col5": deManager, "col6": dtManager, "col7": org};

				 require(["dojo/_base/lang"], function(lang){

				 // lang now contains the module features
					 $(document)
					 .ready(
					 		function() {
					 			console.log('test');
					 			//showWait();
					 			$.ajax({
					 				url: softwareServiceURL + "/v1/cspr/metadataList/" + document.getElementById('osTypeId').value,
					 				type: "GET",
					 				handleAs: "json",
					 				beforeSend: function() {},
					 				success: function (result) {
					 					for (var i=0;i<result.length;i++) {
					 						metaDataArray[i] = result[i].metaDataName;
					 					}
					 					updateAll(document.getElementById('releaseNumberId').value);
					 					//updateAll(document.getElementById('releaseNumberId').value);
					 				},
					 				error: function(error) {}
					 			});
					 						
					 		}
					 );

					// dijit.byId('imageListGrid').store.newItem( imageObj );
					// updateAll(document.getElementById('releaseNumberId').value);
					 //grid.setStore(imageListStore);
/*for (var itemkey in grid.store._itemsByIdentity)
	{
	
	var abc = grid.store._itemsByIdentity[itemkey].imageName.toString();
	grid.store._itemsByIdentity[itemkey].isGoingToCco.toString()=abc;
	console.log('inside for loop');
	}*/
				 });
        }							
	});
}
dashboard.upgradePlannerSaveDialog.hide();
}

$(document)
.ready(
		function() {
			console.log('test');
			//showWait();
			$.ajax({
				url: softwareServiceURL + "/v1/cspr/metadataList/" + document.getElementById('osTypeId').value,
				type: "GET",
				handleAs: "json",
				beforeSend: function() {},
				success: function (result) {
					for (var i=0;i<result.length;i++) {
						metaDataArray[i] = result[i].metaDataName;
					}
					viewAll(document.getElementById('releaseNumberId').value);
					//updateAll(document.getElementById('releaseNumberId').value);
				},
				error: function(error) {}
			});
						
		}
);