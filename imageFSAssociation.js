function imageFSAssociation() {
	this.onLoading = onLoading;
	this.initializeImageGrid = initializeImageGrid;
	this.processResultForImageGrid = processResultForImageGrid;
	this.taskGrid1 = null;
	this.taskGridLayout;
	this.saveData = saveData;
	this.store;
	function saveData(){
		var jsonData = {};
		var i = 0;
		jsonData.imageName = [];
		jsonData.featureSetName = [];
		jsonData.imageId = [];
		for(var index in img.store._itemsByIdentity){
			jsonData.imageName[i] = img.taskGrid1._by_idty[index].item.imageName.toString();
			jsonData.featureSetName[i] = img.taskGrid1._by_idty[index].item.featureSet.toString();
			jsonData.imageId[i] = img.taskGrid1._by_idty[index].item.imageId.toString();
			i = i+1;
		}
		jsonData.admUserId = user;
		//alert(JSON.stringify(jsonData));
		var finalString = "jsonData="+JSON.stringify(jsonData);
		$.ajax({
			type : "POST",
			url : saveUrl,
			data : finalString,
			success : function(result) {
				console.log("result-" + result);
				if (result) {
					console.log("result.message-" + result.message);
					if (result.message == undefined) {
						result.message = "Form saved successfully.";
					}
				}
			},
			error : function(result, str, err) {
				if (isNaN(result.status)) {
					//showNotificationStatus(result.status, result.message);
				} else {
					result.status = "Failure";
				}

			}
		});
	}
	function onLoading(){
		img.initializeImageGrid();
	}
	function MultiselectDropdown () {
        var checkbox = "<select multiple="true"; name="multiselect"; data-dojo-type="dojox.form.CheckedMultiSelect">
      <option value="TN">Tennessee</option>
      <option value="VA" selected="selected">Virginia</option>
      <option value="WA" selected="selected">Washington</option>
      <option value="FL">Florida</option>
      <option value="CA">California</option>";
                    return checkbox;
    },
	function initializeImageGrid() {
		img.taskGridLayout = [ [ {
			'name' : 'S.No',
			'field' : 'id',
			'width' : '5%'
		}, {
			'name' : 'Image Name',
			'field' : 'imageName',
			'width' : '30%'
		},{
			name : 'Feature Set',
			field : 'featureSet',
			width : '30%',
			editable: true, 
			/* type: 'dojox.grid.cells.Select', 
			options: ["None","SUP2E-NPE","SUP1","UNIVERSAL (IP BASE)","SUP1-NPE","SUP2-NPE"] */
			formatter: MultiselectDropdown,
            width: '65px'
		} ] ];
		
		/*create a new grid:*/

		//Define the layouts
		require(
				[ "dojo/ready", "dijit/layout/TabContainer",
						"dijit/layout/ContentPane", "dojox/grid/EnhancedGrid",
						"dojo/data/ItemFileWriteStore",
						"dojox/widget/DialogSimple", "dijit/MenuBar",
						"dijit/PopupMenuBarItem", "dijit/Menu",
						"dijit/MenuItem", "dijit/DropDownMenu",
						"dijit/form/Select",
						"dojox/grid/enhanced/plugins/Filter",
						"dojox/grid/enhanced/plugins/Pagination",
						"dijit/form/Button", "dojox/widget/Standby",
						"dojo/fx/easing", "dojo/parser", "dojo/store/Memory",
						"dojo/data/ObjectStore", "dijit/form/ComboButton",
						"dojo/request/registry", "dojox/io/xhrPlugins","dojox/form/CheckedMultiSelect" ],

				function(ready, TabContainer, ContentPane, EnhancedGrid,
						ItemFileWriteStore, Dialog, MenuBar, PopupMenuBarItem,
						Menu, MenuItem, DropDownMenu, DropDownSelect, filter,
						pagination) {
					ready(function() {
						img.taskGrid1 = new dojox.grid.EnhancedGrid(
								{
									id : 'taskGridFS',
									columnReordering : true,
									store : null,
									noDataMessage : '<span class="dojoxGridNoData"> No Feature Data available </span>',
									structure : img.taskGridLayout,
									escapeHTMLInData : false,
									rowSelector : '20px',
									plugins : {
										/* filter : {
											// Show the closeFilterbarButton at the filter bar
											//closeFilterbarButton: true,
											// Set the maximum rule count to 5
											ruleCount : 5,
											// Set the name of the items
											itemsName : "items"
										}, */
										pagination : {
											pageSizes : [ "10", "25", "50",	"All" ],
											description : true,
											sizeSwitch : true,
											pageStepper : true,
											gotoButton : true,
											maxPageStep : 4,
											position : "bottom"
										}
									}
								}, dojo.byId("fsImageGridDiv"));
						img.taskGrid1.startup();
						img.taskGrid1.resize();
						img.processResultForImageGrid();

					});
				});
	}
	
	function processResultForImageGrid(){
				
		var jsonTest = jsonOsType;
		//alert(JSON.stringify(jsonTest));
		var jsonDataForGrid = new Array();
		var count = 0;
		 
		for ( var i = 0; i < jsonTest.length; i++) {
			var imageName = jsonTest[i].imageName;
			var imageId = jsonTest[i].imageId;
			var finalStr;
			finalStr = '{"id":' + (count + 1) +',"imageName":"'+imageName+'","featureSet":"","imageId":"'+imageId+'"}';
			jsonDataForGrid[count++] = finalStr;
			//alert(finalStr);
		}
		//alert(finalStr);
		var temp = jsonDataForGrid.toString();
		temp = "[" + jsonDataForGrid + "]";
		var tempArr = JSON.parse(temp)
		try {

			var taskData = {
				identifier : 'id',
				items : tempArr
				
			};
			img.store = new dojo.data.ItemFileWriteStore({
				data : taskData
			});
			img.taskGrid1.setStore(img.store);
		} catch (e) {
			//console.log("Exception" + e);
		}
		img.taskGrid1.resize();
		
	}
	
};
try {
var img = new imageFSAssociation();
$(document).ready(
		function() {
			img.onLoading();
			require(["dojo/parser","dojo/domReady!"], function(parser,domReady){
				  // will not be called until DOM is ready
				parser.parse();
				});
				dojo.connect(dojo.byId("submitButton"), "onclick", function(evt){
					img.saveData();
					$.ajax({
						type : "POST",
						url : submitUrl,
						data : dataStr,
						beforeSend : function() {
							console.log('inside post save.');
						},
						success : function(result) {
							console.log('inside post save success.');
							// This would be needed when we refresh the worklist for user.
							dashboard.formSubmitSuccessCallback(result);
						},
						error : function(result, str, err) {
							if (isNaN(result.status)) {
								dashboard.formSubmitFailureCallback(result);
							} else {
								result.status = "Failure";
								dashboard.formSubmitFailureCallback(result);
							}
						}
					});
				});
			});
}catch (e) {
	console.log("exception"+e);
}