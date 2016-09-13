var imageListStore = new Array();
var platformObj;// contains the array of platform mdf assoc
var relatedSoftwareObj;//contains the array of related software info
var gridLength;
var mdfListObj = new Array();//stores the array of mdf concepts
var imageNotesArr = new Array();// stores the image notes
var imageIdArr = new Array();//global variable
var imageListDataGridArr = new Array();
var grid;
var upgradePlannerIndex;
// handles for view/edit/create buttons
//var viewImageHandle, editImageHandle, createImageHandle;

function editPlanner(index) {
	
	//save this index
	upgradePlannerIndex = index;
	updateIndex = index;
	console.log('index');
	console.log("row index ::" + index);
		dashboard.displayUpgradePlannerSave(index);
	}

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
			alert(data_list.length);
				gridLength = data_list.length;
				for ( var q = 0, n = data_list.length; q < n; q++) {										
					data.items.push(lang.mixin(data_list[q % n]));
					/*if (data_list[q % n].accesslevel == "Guest Registered") {
						console.log('setting guest level apprival >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
						document.getElementById('needGuestApproval').value = "Y";
					}*/
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
				                	'name' : 'DEL',
				                	'field' : 'col1',
				                	'width' : '90px'
				                },
				                {
				                	'name' : 'Image Name',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'CCO',
				                	'field' : 'isGoingToCco',
				                	'width' : '50px'
				                },
				                {
				                	'name' : 'Feature Set Description',
				                	'field' : 'featureSet',
				                	'width' : '300px',
				                	'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			console.log(key + ': ' + item[key]);
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
				                	'name' : 'Designator',
				                	'field' : 'col5',
				                	'width' : '350px',
				                	'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			console.log(key + ': ' + item[key]);
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
				                	'field' : 'col6',
				                	'width' : '350px',
				                	'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			console.log(key + ': ' + item[key]);
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
				                	'name' : 'EDIT',
				                	'field' : 'col8',
				                	'width' : '50px',
				                	formatter : function(item, rowIndex,cell) {
				                		return "<div><button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"editPlanner(" + rowIndex +");\">Edit</button></div>";
				                		//call js function editPlanner(rowindex)
				                	}
				                } ] ];

				dojo.forEach(dijit.findWidgets(dojo
						.byId(gridDiv)), function(w) {
					w.destroyRecursive();
				});

				/*create a new grid*/
				grid = new DataGrid({
					id : 'imageListGrid',
					store : imageListStore,
					structure : layout,
					noDataMessage : '<span class="dojoxGridNoData"> No Image Available </span>',
					loadingMessage : '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
					escapeHTMLInData : false,
					autoWidth : true,
					autoHeight : true
				});
				/*append the new grid to the div*/
				grid.placeAt("gridDiv");
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
				if ($.inArray('INDIVIDUAL_PLATFORM_NAME', metaDataArray) != -1) {
					console.log('indid platf  true');
					grid.layout.setColumnVisibility(2,true);
				} else {
					console.log('indid platf  false');
					grid.layout.setColumnVisibility(2,false);
				}
				if ($.inArray('MDF_ID', metaDataArray) != -1) {
					console.log('mdf  true');
					grid.layout.setColumnVisibility(3,true);
				} else {
					console.log('mdf  false');
					grid.layout.setColumnVisibility(3,false);
				}
				if ($.inArray('IMAGE_DESCRIPTION', metaDataArray) != -1) {
					console.log('img desc  true');
					grid.layout.setColumnVisibility(4,true);
				} else {
					console.log('img desc  false');
					grid.layout.setColumnVisibility(4,false);
				}
				if ($.inArray('POSTING_TYPE_NAME', metaDataArray) != -1) {
					console.log('posting type  true');
					grid.layout.setColumnVisibility(5,true);
				} else {
					console.log('posting type  false');
					grid.layout.setColumnVisibility(5,false);
				}
				
				grid.startup();
				//hideWait();
			}, 
			function(err) { 
				console.log(err);
			},
			function(evt) {
			});
			});

}

function addImage()
{
console.log('in side add Image');
console.log("release number::" + document.getElementById('releaseNumberId').value);

//var addImageArr = document.getElementById('releaseNumberId');
var addImageSelId;
var addImageSelName;
var items = grid.selection.getSelected();
//var imageIdArr = new Array();//global variable
console.log('len::' + items.length);
/*for (var i=0;i < addImageArr.length;i++) {
		if (addImageArr[i].checked) {
			addImageSelId = addImageArr[i].value;
			addImageSelName = addImageArr[i].text;
			console.log("Image name::" + addImageSelName);
		}
	}*/
	console.log("release number::" + document.getElementById('releaseNumberId').value);
	
	 if(items.length>0) {
         dojo.forEach(items, function(selectedItem) {
             if(selectedItem !== null){
					 var imageObj = {"imageName" : selectedItem.imageName,
										"isGoingToCco" : selectedItem.isGoingToCco};
					 //imageListStore.push(imageObj);
					 //var newItem = {"id" : cdets.i, "col2": project, "col3": product, "col4": component, "col5": deManager, "col6": dtManager, "col7": org};

					 require(["dojo/_base/lang"], function(lang){

					 // lang now contains the module features

						 dijit.byId('imageListGrid').store.newItem( imageObj );
						 //grid.setStore(imageListStore);

					 });
             }							
		});
    }
         dashboard.upgradePlannerAddDialog.hide();
         //save selected images
         //$.ajax() POST selected images
         //success { //hide add image
         //call ajax() get method for first grid}
         //store
}

function updateAll(releaseId){
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
			alert(data_list.length);
				gridLength = data_list.length;
				for ( var q = 0, n = data_list.length; q < n; q++) {										
					data.items.push(lang.mixin(data_list[q % n]));
					/*if (data_list[q % n].accesslevel == "Guest Registered") {
						console.log('setting guest level apprival >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
						document.getElementById('needGuestApproval').value = "Y";
					}*/
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
	'name' : 'DEL',
	'field' : 'col1',
	'width' : '90px'
},
				                {
				                	'name' : 'Image Name',
				                	'field' : 'imageName',
				                	'width' : '90px'
				                },
				                {
				                	'name' : 'CCO',
				                	'field' : 'isGoingToCco',
				                	'width' : '200px'
				                },
				               /* {
				                	'name' : 'CCO',
				                	'field' : 'featureSet',
				                	'width' : '50px'
				                },*/
				                {
				                	'name' : 'Feature Set Description',
				                	'field' : 'imageName',
				                	'width' : '350px',
				                	/*'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			console.log(key + ': ' + item[key]);
				                			if(key.indexOf("_") != -1){//do nothing
				                			}else{
				                				info = info + "<li>" + item[key] + "</li>";
				                			}
				                		}
				                		info = info + "</ul></td></tr></table>";
				                		return info; 
				                	}*/
				                },
				                {
				                	'name' : 'Designator',
				                	'field' : 'isGoingToCco',
				                	'width' : '350px',
				                	/*'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			console.log(key + ': ' + item[key]);
				                			if(key.indexOf("_") != -1){//do nothing
				                			}else{
				                				info = info + "<li>" + item[key] + "</li>";
				                			}
				                		}
				                		info = info + "</ul></td></tr></table>"; 
				                		return info; 
				                	}*/
				                	
				                },
				               
				                {
				                	'name' : 'Feature setDesc:CCO',
				                	'field' : 'isGoingToCco',
				                	'width' : '100px'
				                },
				             
				                {
				                	'name' : 'EDIT',
				                	'field' : 'col8',
				                	'width' : '50px',
				                	formatter : function(item, rowIndex,cell) {
				                		return "<div><button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"editPlanner(" + rowIndex +");\">Edit</button></div>";
				                		//call js function editPlanner(rowindex)
				                	}
				                } ] ];

				dojo.forEach(dijit.findWidgets(dojo
						.byId(gridDiv)), function(w) {
					w.destroyRecursive();
				});

				/*create a new grid*/
				grid = new DataGrid({
					id : 'imageListGrid',
					store : imageListStore,
					structure : layout,
					noDataMessage : '<span class="dojoxGridNoData"> No Image Available </span>',
					loadingMessage : '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
					escapeHTMLInData : false,
					autoWidth : true,
					autoHeight : true
				});
				/*append the new grid to the div*/
				grid.placeAt("gridDiv");
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
				if ($.inArray('INDIVIDUAL_PLATFORM_NAME', metaDataArray) != -1) {
					console.log('indid platf  true');
					grid.layout.setColumnVisibility(2,true);
				} else {
					console.log('indid platf  false');
					grid.layout.setColumnVisibility(2,false);
				}
				if ($.inArray('MDF_ID', metaDataArray) != -1) {
					console.log('mdf  true');
					grid.layout.setColumnVisibility(3,true);
				} else {
					console.log('mdf  false');
					grid.layout.setColumnVisibility(3,false);
				}
				if ($.inArray('IMAGE_DESCRIPTION', metaDataArray) != -1) {
					console.log('img desc  true');
					grid.layout.setColumnVisibility(4,true);
				} else {
					console.log('img desc  false');
					grid.layout.setColumnVisibility(4,false);
				}
				if ($.inArray('POSTING_TYPE_NAME', metaDataArray) != -1) {
					console.log('posting type  true');
					grid.layout.setColumnVisibility(5,true);
				} else {
					console.log('posting type  false');
					grid.layout.setColumnVisibility(5,false);
				}
				
				grid.startup();
				//hideWait();
			}, 
			function(err) { 
				console.log(err);
			},
			function(evt) {
			});
			});

}
function deleteImage() {
	var items = grid.selection.getSelected();
	var imageIdArr = new Array();
	console.log('len::' + items.length);
	 if(items.length) {
         /*dojo.forEach(items, function(selectedItem){
             if(selectedItem !== null){
            	 //imageListStore.deleteItem(selectedItem);TODO make it work properly
                 dojo.forEach(grid.store.getAttributes(selectedItem), function(attribute){
                     var value = grid.store.getValues(selectedItem, attribute);                     
                     if(attribute == 'imageId'){
                    	 console.log(value[0]);
                    	 imageIdArr.push(value[0]);
                     }
                });
             }
         });*/
         dojo.forEach(items, function(selectedItem){
             if(selectedItem !== null){
                 // Delete the item from the data store:
                 imageListStore.deleteItem(selectedItem);
             } // end if
         });
         /*var postData = {
        		    		"imageIds": imageIdArr,
        		    		"userId": document.getElementById('userId').value
        				};*/
/*         var serviceUrl = '/irt/app/software/cspr/deleteImage';
         $.ajax({
        	url: serviceUrl,
        	data: JSON.stringify(postData),
        	type: "POST",
        	headers: {
                "X-Requested-With": null
            },
 			contentType: "application/json; charset=utf-8",
 			beforeSend: function() {},
 			success: function (data, items) {
 				var responseString;
 				console.log('delete response>>' + data);
 				data = JSON.parse(data);
 				var failureString = '';
 				var successString = '';
 				for (var key in data) {
    				console.log("key:"+key);
    				console.log("value:"+data[key]);
    				if (data[key] == 'Sucess') {
    					successString += key + '\n';
    					gridLength--;
    					imageListStore.fetch({query: { imageName: key}, 
							onComplete: function (selectedItem, request) {
								imageListStore.deleteItem(selectedItem);
							},
							onError: {}
    					});
    					dojo.forEach(items, function(selectedItem){
    		                if(selectedItem !== null){
    		                    // Delete the item from the data store:
    		                    imageListStore.deleteItem(selectedItem);
    		                } // end if
    		            });
    					//remove[key] from store TODO
    				} else {
    					failureString += key + '\n';
    				}
    			}
 				if (successString != '') {
 					if (failureString != '') {
 						alert('Following images were deleted successfully:\n' + successString + '\nFollowing images were not deleted:\n' + failureString);
 					} else {
 						alert('Following images were deleted successfully:\n' + successString); 
 					}
 				} else {
 					alert('None of the images were deleted successfully');
 				}
 				viewAll(document.getElementById('osTypeId').value, document.getElementById('releaseNumberId').value);	
 			},
 			error: function(error) {
 				alert('Image deletion failed due to some errors');
 			}
         });*/
     } else {
    	 alert('Please select atleast one item');
     }
}

function populateContent(data, isEditable) {
	console.log('populate content::' + isEditable);
	document.getElementById('releaseNumberId').value = data.csprImage.csprReleaseNumber.releaseNumberId;
	//document.getElementById('userId').value = data.userId;
	document.getElementById('imageName').value = data.csprImage.imageName;
	document.getElementById('imageName').readonly = true;
	// start
	if (data.mdfConceptList != null) {
		console.log('mdf data :' + data.mdfConceptList); 
		var hiddenMdfId = '';
		var hiddenMdfName = ''; 
		for (var k=0;k<data.mdfConceptList.length;k++) {
			var mdfId = data.mdfConceptList[k].mdfConceptId;
			if (k!=0) {
				hiddenMdfId += '$';// check if first element or last element
				hiddenMdfName += '$';
			}
			hiddenMdfId += mdfId;
			var mdfConceptName = data.mdfConceptList[k].mdfConceptName;
			hiddenMdfName += mdfConceptName;
		}
		console.log('hiddenMdfId:' + hiddenMdfId);
		console.log('hiddenMdfName:' + hiddenMdfName);
		document.getElementById('hiddenMdfId').value = hiddenMdfId;
		document.getElementById('hiddenMdfName').value = hiddenMdfName;
		}
	// end
	/*if (!isEditable)
		document.getElementById('imageDesc').readonly = true;
	*/document.getElementById('imageDesc').value = data.csprImage.imageDescription;
	console.log('platform obj::' + data.platformList);
	document.getElementById('platformObject').value = JSON.stringify(data.platformList);
	//document.getElementById('hiddenMdfId').value = 
	//document.getElementById('hiddenMdfName').value = 
	document.getElementById('machineOSType').value = data.machineOsTypeList;// get the drop down first
	document.getElementById('memoryFootprint').value = data.csprImage.memoryFootprint;
	/*if (!isEditable)
		document.getElementById('memoryFootprint').readonly = true;
	*/document.getElementById('hardDiskFootprint').value = data.csprImage.hardDiskFootprint;
	/*if (!isEditable)
		document.getElementById('hardDiskFootprint').readonly = true;
	*/document.getElementById('crypto_flags').value = data.csprImage.isCrypto;
	document.getElementById('minflash').value = data.csprImage.minFlash;
	document.getElementById('mindram').value = data.csprImage.dram;
	var postingTypeIdArr = document.getElementsByName('postingTypeId');
	if (data.csprImage.shrPostingType != null) {
	console.log('data.csprImage.shrPostingType.postingTypeId' + data.csprImage.shrPostingType.postingTypeId);
	for(var i=0;i<postingTypeIdArr.length;i++) {
		if (postingTypeIdArr[i].value == data.csprImage.shrPostingType.postingTypeId) {
			console.log('insdie true');
			postingTypeIdArr[i].checked = "checked";
		} else {
			postingTypeIdArr[i].checked = false;
		}
	}
	}
	/*if (!isEditable)
		document.getElementById('postingTypeId').disabled = true;
	*/document.getElementById('installationDocUrl').value = data.csprImage.installationDocUrl;
	/*if (!isEditable)
		document.getElementById('installationDocUrl').readonly = true;
	*/document.getElementById('productCode').value = data.csprImage.productCode;
	/*if (!isEditable)
		document.getElementById('productCode').readonly = true;
	*/document.getElementById('ccats').value = data.csprImage.ccats;
	/*if (!isEditable)
		document.getElementById('ccats').readonly = true;
	*/document.getElementById('fscDate').value = data.csprImage.ccoFcsDate;
	document.getElementById('isSoftwareAdvisory').checked = ((data.csprImage.isSoftwareAdvisory == "Y") ? "checked" : "");
	/*if (!isEditable)
		document.getElementById('isSoftwareAdvisory').disabled = true;
	*/document.getElementById('softwareAdvisoryDocUrl').value = data.csprImage.softwareAdvisoryDocUrl;
	/*if (!isEditable)
		document.getElementById('softwareAdvisoryDocUrl').readonly = true;
	*/document.getElementById('isDeferred').checked = ((data.csprImage.isDeferred == "Y") ? "checked" : "");
	/*if (!isEditable)
		document.getElementById('isDeferred').disabled = true;
	*/document.getElementById('deferralAdvisoryDocUrl').value = data.csprImage.deferralAdvisoryDocUrl;
	/*if (!isEditable)
		document.getElementById('deferralAdvisoryDocUrl').readonly = true;
	*/document.getElementById('relatedSoftware').value = data.relatedSoftwaresList;
	var cdcAccessLevelIdArr = document.getElementsByName('cdcAccessLevelId');
	for (var j=0;j<cdcAccessLevelIdArr.length;j++) {
		if (cdcAccessLevelIdArr[j].value == data.csprImage.csprCdcAccessLevel.cdcAccessLevelId) {
			console.log('insdie true');
			cdcAccessLevelIdArr[j].checked = "checked";
		} else {
			cdcAccessLevelIdArr[j].checked = "";
		}
	}
	/*if (!isEditable)
		document.getElementById('cdcAccessLevelId').disabled = true;
	*/document.getElementById('sourceLocation').value = data.csprImage.sourceLocation;
	/*if (!isEditable)
		document.getElementById('sourceLocation').readonly = true;
	*/// get the image arr if not null then create the rows and populate data
	//data.csprImage.imageNotes
	//imageLabel
	//imageUrl
	//imageSrc
	if (data.imageNotes!=null && data.imageNotes.length != 0) {
		for (var k=0;k<data.imageNotes.length;k++) {
			addImageUrlRow(data.imageNotes[k]);
		}
	}
	//imageLabel imageUrl imageLoc
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
				},
				error: function(error) {}
			});
						
		}
);