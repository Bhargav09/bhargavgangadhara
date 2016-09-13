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
	var serviceUrl = "http://wwwin-hdonepud-irt-dev.cisco.com/software" + '/v1/image/upgradeplanner/1108';
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
				                	'name' : 'Image Name',
				                	'field' : 'isGoingToCco',
				                	'width' : '200px'
				                },
				                {
				                	'name' : 'CCO',
				                	'field' : 'isGoingToCco',
				                	'width' : '50px'
				                },
				                {
				                	'name' : 'Feature Set Description',
				                	'field' : 'imageName',
				                	'width' : '300px',
				                	/*'formatter' : function(item, rowIndex,cell) {
				                		var info = "<table><tr><td><ul>";
				                		for (var key in item) {
				                			//console.log(key + ': ' + item[key]);
				                			if(key.indexOf("_") != -1){//do nothing
				                			}else{
				                				info = info + "<li>" + item[key] + "</li>";
				                			}
				                		}
				                		info = info + "</ul></td></tr></table>";
				                		return info; */
				                	//}
				                },
				                {
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
				               ];

				dojo.forEach(dijit.findWidgets(dojo
						.byId(upgradePlannerViewgridDiv)), function(w) {
					w.destroyRecursive();
				});

				/*create a new grid*/
				grid = new DataGrid({
					id : 'upgradePlannerViewgrid',
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
			
				
				/*if ($.inArray('IS_SOFTWARE_ADVISORY', metaDataArray) != -1) {
					console.log('SA  true');
					grid.layout.setColumnVisibility(6,true);
				} else {
					console.log('SA  false');
					grid.layout.setColumnVisibility(6,false);
				}*/
				/*if ($.inArray('IS_DEFERRED', metaDataArray) != -1) {
					console.log('deferred  true');
					grid.layout.setColumnVisibility(7,true);
				} else {
					console.log('deferred  false');
					grid.layout.setColumnVisibility(7,false);
				}*/
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
				url: softwareServiceURL + "/v1/metadataList/" + document.getElementById('osTypeId').value,
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