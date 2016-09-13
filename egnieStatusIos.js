var imageListStore;
var platformObj;// contains the array of platform mdf assoc
var relatedSoftwareObj;//contains the array of related software info
var gridLength;
var mdfListObj = new Array();//stores the array of mdf concepts
var imageNotesArr = new Array();// stores the image notes
var imageListDataGridArr = new Array();
var grid;
// handles for view/edit/create buttons
var viewImageHandle, editImageHandle, createImageHandle;

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
				                	'name' : 'Product Code',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Software Product Description',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'CCO FCS',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Mfg FCS',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Availability',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Flash',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'DRAM',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Image Name',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Platform Product Family',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Item Type',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Boot Image',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Encrypt Value',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'Parent Product Code',
				                	'field' : 'imageName',
				                	'width' : '200px'
				                },
								{
				                	'name' : 'Action',
				                	'field' : 'message',
				                	'width' : '150px',
				                	formatter : function(item, rowIndex,cell) {
				                		return "<div><button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"viewImage(" + rowIndex +");\">View</button> <button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"editImage(" + rowIndex + ");\">Edit</button></div>";
				                	}
				                },
								{
				                	'name' : 'Action',
				                	'field' : 'message',
				                	'width' : '150px',
				                	formatter : function(item, rowIndex,cell) {
				                		return "<div><button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"viewImage(" + rowIndex +");\">View</button> <button class=\"claro\" dojoType=\"dijit/form/Button\" onClick=\"editImage(" + rowIndex + ");\">Edit</button></div>";
				                	}
				                },
				                {
				                	'name' : 'Platform Managers',
				                	'field' : 'isGoingToCco',
				                	'width' : '350px',
				                 }
				                
				                ] ];

				dojo.forEach(dijit.findWidgets(dojo
						.byId(eGniegirdDiv)), function(w) {
					w.destroyRecursive();
				});

				/*create a new grid*/
				grid = new DataGrid({
					id : 'upgradePlannerListGrid',
					store : imageListStore,
					structure : layout,
					noDataMessage : '<span class="dojoxGridNoData"> No Image Available </span>',
					loadingMessage : '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
					escapeHTMLInData : false,
					autoWidth : true,
					autoHeight : true,
					columns: {
		                first: "First Name",
		                last: "Last Name",
		                totalG: "Games Played"
		            }
				},"grid");
				/*append the new grid to the div*/
				grid.placeAt("eGniegirdDiv");
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
					viewAll(document.getElementById('osTypeId').value,document.getElementById('releaseNumberId').value);
				},
				error: function(error) {}
			});
						
		}
);