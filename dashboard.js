    var dashboard = {
    destroyChildElements:true, // to prevent destroy of descendants automatically.
    updateReleaseFlag:false,
    updatePackageFlag:false,
    csprReleaseId : null,
    grid: null,
    searchUrl: "",
    formTitle: "",
    featureId:"",
    osTypeId:"",
    dialogStyle:"width: 550px;height:auto",
    notificationGrid: null,
    myDialog: null,
    cloneDialog: null,
    bulkUpdateDialog: null,
    groupActionDialog: null,
    internalFeatureDialog:null,
    imageListDialog:null,
    marketMatrixDialog:null,
    listGrid: null,
    cp1: null,
    loggedInUserName: null,
    cp2: null,
    cp4: null,
    cp5: null,
    featureGrid: null,
    featureGridOwn: null,
    featureGridInt: null,
    featureGridAll: null, //mbhambri
    detailsGrid: null,
    selectionDetailsStore: null,
    successDialogBox: null,
    failureDialogBox: null,
    imageDialogBoxTaskId: null,
    imageDialogBox:null,
    imageBoxbusyIndicator:null,
    currentlySelectedUserRole: null,
    headerNamesListForRoles: [], // decides what to show for second table header based on role.
    itemsListUrlForRoles: [], // decides which web service to call based on role
    tmpRolesStringForCustomization: null,
    tmpAttributesStringForCustomization: null,
    rolesListForCustomization: [],
    attributesListForCustomization: [],
    featureServicesBase: null,
    isBusinessAdmin:false,
    isSwitchRole:false,
    pSubMenu2:null,
    pSubMenu3:null,
    milestoneMenu:null,
    menuItem1:null,menuItem2:null,menuItem3:null,menuItem4:null,menuItem5:null,
    menuItem6:null,menuItem7:null,menuItem8:null,menuItem9:null,menuItem10:null,
    menuItem11:null,menuItem12:null,menuItem13:null,menuItem14:null,menuItem15:null,menuItem16:null,menuItem17:null,
    menuItem18:null,menuItem19:null,menuItem20:null,
    menuItemManage1:null,menuItemManage2:null,menuItemManage3:null,menuItemManage4:null,
    menuItemManage5:null,menuItemManage6:null,menuItemManage7:null,menuItemManage8:null,menuItemManage9:null,
    
    //releaseMenuItem:null,
    trainMenuItem:null,
    branchMenuItem:null,
    businessUnitMenuItem:null,
    trainGroupMenuItem:null,
    packageMenuItem:null,
    menuItemBulkUpdate:null,
    tc:null,
    permissionListIds:null,
    pop_data:undefined,
    infoDialog:null,
    hideNotificationForInfo:false,
    featureCreationDialog:null,
    featureNameFromSearch:"",
    featureIdFromSearch:"",
    techAreaFromSearch:"",    	 
    	  createReleaseDialog:function(serviceUrl,title) {
    	    	 
    	    	// dashboard.destroyChildElements = false;	
    	    	
    	    	 //var serviceUrl = "/irt/view/release/jsp/selectReleaseType.jsp";

    	    	 console.debug("url:--->"+serviceUrl);
//    	    	dashboard.showModalLoadingImage();
    	    	 dashboard.formTitle = title;
    	    	 
    	    	
    	    	 require(["dojo/request/xhr"], function(xhr) {

    	    	        xhr(serviceUrl, {
    	    	        preventCache: true
    	    	        }).then(function(data) {               
    	    	            //we dont need to display notification for successful feature id creation
    	    	            //dashboard.showNotificationStatus(data.status, data.message);
    	    	        
    	    	        	dashboard.displayDialogBox(data);
    	    	        	dashboard.hideModalLoadingImage();
    	    	        	dashboard.formTitle=title;
    	    	            //dashboard.hideModalLoadingImage();
    	    	        }, function(err) {
    	    	            dashboard.showNotificationStatus("FAILURE", "Unable to Create Release Option!");
    	    	            // Handle the error condition
    	    	        }, function(evt) {
    	    	            // Handle a progress event from the request if the
    	    	            // browser supports XHR2
    	    	        });


    	    	    });
    	 
//    		//Need to hit different service for different roles.
//    	    var serviceUrl = "/irt/app/release/createRelease";  
//    	    require(["dojo/request/xhr"], function(xhr) {
//             console.log("inside create Release");    
//            xhr(serviceUrl, {
//            preventCache: true,
//                query: {
//                },
//                handleAs: "json"
//            }).then(function(data) {  
//
//            	dashboard.reloadWorkListItems();
//                dashboard.renderReleaselistTab();
//                //we dont need to display notification for successful feature id creation
//                //dashboard.showNotificationStatus(data.status, data.message);
//                if (data.nextTaskId) {// if next task available.
//                dashboard.hideModalLoadingImage();
//                    dashboard.formTitle = data.nextTaskName;
//             //       dashboard.featureId = data.nextTaskDisplayId;
//                    dashboard.osTypeId = data.osType;
//                    dashboard.openTaskForm(data.nextTaskId);
//                } else {
//                	dashboard.hideModalLoadingImage();
//                }
//                //dashboard.hideModalLoadingImage();
//            }, function(err) {
//                dashboard.hideModalLoadingImage();
//                dashboard.reloadWorkListItems();
//                dashboard.showNotificationStatus("FAILURE", "Unable to create new release!");
//                // Handle the error condition
//            }, function(evt) {
//                // Handle a progress event from the request if the
//                // browser supports XHR2
//            });
//
//
//        });
    },
    createSoftwareDialog:function() {
		//Need to hit different service for different roles.
		    var serviceUrl = "/irt/app/software/create";
		require([ "dojo/request/xhr" ], function(xhr) {
			console.log("inside create Software");
			xhr(serviceUrl, {
				preventCache : true,
				query : {},
				handleAs : "json"
			}).then(
					function(data) {

						dashboard.reloadWorkListItems();
						// dashboard.renderReleaselistTab();
						// we dont need to display notification for successful
						// feature id creation
						// dashboard.showNotificationStatus(data.status,
						// data.message);
						if (data.nextTaskId) {// if next task available.
							dashboard.hideModalLoadingImage();
							dashboard.formTitle = data.nextTaskName;
							// dashboard.featureId = data.nextTaskDisplayId;
							dashboard.osTypeId = data.osType;
							dashboard.openTaskForm(data.nextTaskId);
						} else {
							dashboard.hideModalLoadingImage();
						}
						// dashboard.hideModalLoadingImage();
					},
					function(err) {
						dashboard.hideModalLoadingImage();
						dashboard.reloadWorkListItems();
						dashboard.showNotificationStatus("FAILURE",
								"Unable to create new Software!");
						// Handle the error condition
					}, function(evt) {
						// Handle a progress event from the request if the
						// browser supports XHR2
					});

		});
    },
    createSoftwareImageDialog:function() {
//		//Need to hit different service for different roles.
//		    var serviceUrl = "/irt/app/software/imageManagement";
//		require([ "dojo/request/xhr" ], function(xhr) {
//			console.log("inside create Software");
//			xhr(serviceUrl, {
//				preventCache : true,
//				query : {},
//				handleAs : "json"
//			}).then(
//					function(data) {
//						console.log("Entered success block with data:"+data);
//						dashboard.reloadWorkListItems();
//						// dashboard.renderReleaselistTab();
//						// we dont need to display notification for successful
//						// feature id creation
//						// dashboard.showNotificationStatus(data.status,
//						// data.message);
//						if (data.nextTaskId) {// if next task available.
//							dashboard.hideModalLoadingImage();
//							dashboard.formTitle = data.nextTaskName;
//							// dashboard.featureId = data.nextTaskDisplayId;
//							dashboard.osTypeId = data.osType;
//							dashboard.openTaskForm(data.nextTaskId);
//						} else {
//							dashboard.hideModalLoadingImage();
//						}
//						// dashboard.hideModalLoadingImage();
//					},
//					function(err) {
//						dashboard.hideModalLoadingImage();
//						dashboard.reloadWorkListItems();
//						dashboard.showNotificationStatus("FAILURE",
//								"Unable to create new Software!");
//						// Handle the error condition
//					}, function(evt) {
//						// Handle a progress event from the request if the
//						// browser supports XHR2
//					});
//
//		});
    	
    	
    },

    //himsriva 03/20/14
    createImageDialog:function() {
    	dashboard.showModalLoadingImage();
    	console.log('createImageDialog11');
    	var serviceUrl = "/irt/app/software/imageList";
    	require(["dojo/request/xhr"], function(xhr) {
            xhr(serviceUrl, {
            	handleAs : "html",
            preventCache: true               
            }).then(function(data) {
            	dashboard.hideModalLoadingImage();            	           	
                dashboard.imageListDialog.set("content", data);
                dashboard.imageListDialog.show();
            	console.log('excuted>>>');
            }, function(err) {
            	console.log("err>>" + dojo.toJson(err));
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to create new branch!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    	
    },
    displyMarketMatrix:function(osTypeId, releaseNumberId) {
    	dashboard.showModalLoadingImage();
    	var serviceUrl = '/irt/app/software/marketMatrix/' + osTypeId + '/' + releaseNumberId;
    	require(["dojo/request/xhr"], function(xhr) {
            xhr(serviceUrl, {
            	handleAs : "html",
            preventCache: true               
            }).then(function(data) {
            	dashboard.hideModalLoadingImage();            	           	
                dashboard.marketMatrixDialog.set("content", data);
                dashboard.marketMatrixDialog.show();
            	console.log('excuted>>>');
            }, function(err) {
            	console.log("err>>" + dojo.toJson(err));
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to load market matrix!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    	
    },
    createTrainDialog:function() {
        /*dashboard.showModalLoadingImage();
        dashboard.formTitle = "Create Train";
        require(["dojo/request/xhr"], function(xhr) {

            //xhr("/irt/jsp/createTrain.jsp", {
        	xhr("/irt/app/release/createTrain", {
        	preventCache: true
            }).then(function(data) {
                dashboard.displayDialogBox(data);
            	//dashboard.setDialogBoxTitle("Create Train",[800,800]);
                dashboard.myDialog.set("style","width: 650px;height:auto");
                dashboard.myDialog.set("title", "Create Train");
                dashboard.hideModalLoadingImage();   
            })
        });*/
    	var serviceUrl = "/irt/app/release/createTrain";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
            query: {
            },
            handleAs: "json"
        }).then(function(data) {   
        	//dashboard.myDialog.set("style","width: 650px;height:auto");
        	dashboard.reloadWorkListItems();
            dashboard.renderReleaselistTab();
            //we dont need to display notification for successful feature id creation
            //dashboard.showNotificationStatus(data.status, data.message);
            if (data.nextTaskId) {// if next task available.
            dashboard.hideModalLoadingImage();
                dashboard.formTitle = data.nextTaskName;
              //  dashboard.featureId = data.nextTaskDisplayId;
                dashboard.osTypeId = data.osType;
                dashboard.openTaskForm(data.nextTaskId);
            } else {
            	dashboard.hideModalLoadingImage();
            }
            //dashboard.hideModalLoadingImage();
        }, function(err) {
            dashboard.hideModalLoadingImage();
            dashboard.reloadWorkListItems();
            dashboard.showNotificationStatus("FAILURE", "Unable to create new branch!");
            // Handle the error condition
        }, function(evt) {
            // Handle a progress event from the request if the
            // browser supports XHR2
        });


    });
    	
    },
    updatePackageDialog:function() {
		//Need to hit different service for different roles.
    	console.log("inside updatePackageDialog");
    	dashboard.showModalLoadingImage();
        dashboard.formTitle = "Update Package";
        dashboard.updatePackageFlag = true;
        console.log("updatePackageFlag from dashboard : " + dashboard.updatePackageFlag);
	    var serviceUrl = "/irt/view/release/jsp/createPackage.jsp";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
        }).then(function(data) { 
        	dashboard.displayDialogBox(data);
        	dashboard.hideModalLoadingImage();
        }, function(err) {
        	
        }, function(evt) {
        	
        });


    });
},
    updateReleaseDialog:function() {
		//Need to hit different service for different roles.
    	console.log("inside updateReleaseDialog");
    	dashboard.showModalLoadingImage();
        dashboard.formTitle = "Update Release";
        dashboard.updateReleaseFlag = true;
        console.log("updateReleaseFlag from dashboard : " + dashboard.updateReleaseFlag);
	    var serviceUrl = "/irt/view/release/jsp/selectReleaseType.jsp";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
        }).then(function(data) { 
        	dashboard.displayDialogBox(data);
        	dashboard.hideModalLoadingImage();
        }, function(err) {
        	
        }, function(evt) {
        	
        });


    });
},
    updateTrainDialog:function() {
		//Need to hit different service for different roles.
    	console.log("inside updateTrainDialog");
    	dashboard.showModalLoadingImage();
        dashboard.formTitle = "Select Train to update";
	    var serviceUrl = "/irt/view/release/jsp/updateTrain.jsp";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
        }).then(function(data) { 
        	dashboard.displayDialogBox(data);
        	dashboard.hideModalLoadingImage();
        }, function(err) {
        	
        }, function(evt) {
        	
        });


    });
},
    updateBranchDialog:function() {
		//Need to hit different service for different roles.
    	dashboard.showModalLoadingImage();
        dashboard.formTitle = "Select Branch";
	    var serviceUrl = "/irt/view/release/jsp/updateBranch.jsp";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
        }).then(function(data) {               
            //we dont need to display notification for successful feature id creation
            //dashboard.showNotificationStatus(data.status, data.message);
        	dashboard.displayDialogBox(data);
        	dashboard.hideModalLoadingImage();
        	//dashboard.formTitle="Select Branch";
            //dashboard.hideModalLoadingImage();
        }, function(err) {
         //   dashboard.hideModalLoadingImage();
         //   dashboard.reloadWorkListItems();
         //   dashboard.showNotificationStatus("FAILURE", "Unable to create new branch!");
            // Handle the error condition
        }, function(evt) {
            // Handle a progress event from the request if the
            // browser supports XHR2
        });


    });
},
updateCriteriaDialog:function() {
	//Need to hit different service for different roles.
	console.log("inside updateCriteriaDialog");
	dashboard.showModalLoadingImage();
    dashboard.formTitle = "Select Branch to update Criteria";
    var serviceUrl = "/irt/view/throttle/jsp/admApprovalCriteria.jsp?source=update";  
    require(["dojo/request/xhr"], function(xhr) {

    xhr(serviceUrl, {
    preventCache: true,
    }).then(function(data) { 
    	dashboard.displayDialogBox(data);
    	dashboard.hideModalLoadingImage();
    }, function(err) {
    	
    }, function(evt) {
    	
    });


});
},
updateBranchMetaDataDialog:function() {
	//Need to hit different service for different roles.
	console.log("inside updateBranchDialog");
	dashboard.showModalLoadingImage();
    dashboard.formTitle = "Select Branch to Update Metadata";
    var serviceUrl = "/irt/view/throttle/jsp/admEnableThrottleRestriction.jsp?source=update";  
    require(["dojo/request/xhr"], function(xhr) {

    xhr(serviceUrl, {
    preventCache: true,
    }).then(function(data) { 
    	dashboard.displayDialogBox(data);
    	dashboard.hideModalLoadingImage();
    }, function(err) {
    	
    }, function(evt) {
    	
    });


});
},
    
    createBusinessUnitDialog:function() {
		//Need to hit different service for different roles.
	    var serviceUrl = "/irt/app/release/createBusinessUnit";  
	    require(["dojo/request/xhr"], function(xhr) {

        xhr(serviceUrl, {
        preventCache: true,
            query: {
            },
            handleAs: "json"
        }).then(function(data) {               
        	dashboard.reloadWorkListItems();
            dashboard.renderReleaselistTab();
            //we dont need to display notification for successful feature id creation
            //dashboard.showNotificationStatus(data.status, data.message);
            if (data.nextTaskId) {// if next task available.
            dashboard.hideModalLoadingImage();
                dashboard.formTitle = data.nextTaskName;
               // dashboard.featureId = data.nextTaskDisplayId;
               // dashboard.osTypeId = data.osType;
                dashboard.openTaskForm(data.nextTaskId);
            } else {
            	dashboard.hideModalLoadingImage();
            }
            //dashboard.hideModalLoadingImage();
        }, function(err) {
            dashboard.hideModalLoadingImage();
            dashboard.reloadWorkListItems();
            dashboard.showNotificationStatus("FAILURE", "Unable to create new business unit!");
            // Handle the error condition
        }, function(evt) {
            // Handle a progress event from the request if the
            // browser supports XHR2
        });


    });
},

	createTrainGroupDialog:function() {
		//Need to hit different service for different roles.
	    var serviceUrl = "/irt/app/release/createTrainGroup";  
	    require(["dojo/request/xhr"], function(xhr) {
	
	    xhr(serviceUrl, {
	    preventCache: true,
	        query: {
	        },
	        handleAs: "json"
	    }).then(function(data) {               
	    	dashboard.reloadWorkListItems();
	        dashboard.renderReleaselistTab();
	        //we dont need to display notification for successful feature id creation
	        //dashboard.showNotificationStatus(data.status, data.message);
	        if (data.nextTaskId) {// if next task available.
	        dashboard.hideModalLoadingImage();
	            dashboard.formTitle = data.nextTaskName;
	       //     dashboard.featureId = data.nextTaskDisplayId;
	           // dashboard.osTypeId = data.osType;
	            dashboard.openTaskForm(data.nextTaskId);
	        } else {
	        	dashboard.hideModalLoadingImage();
	        }
	        //dashboard.hideModalLoadingImage();
	    }, function(err) {
	        dashboard.hideModalLoadingImage();
	        dashboard.reloadWorkListItems();
	        dashboard.showNotificationStatus("FAILURE", "Unable to create new train group!");
	        // Handle the error condition
	    }, function(evt) {
	        // Handle a progress event from the request if the
	        // browser supports XHR2
	    });
	
	
	});
	},
	createPackageDialog:function() {
		//Need to hit different service for different roles.
	    var serviceUrl = "/irt/app/release/createPackage";  
	    require(["dojo/request/xhr"], function(xhr) {
	
	    xhr(serviceUrl, {
	    preventCache: true,
	        query: {
	        },
	        handleAs: "json"
	    }).then(function(data) {               
	    	dashboard.reloadWorkListItems();
	        dashboard.renderReleaselistTab();
	        //we dont need to display notification for successful feature id creation
	        //dashboard.showNotificationStatus(data.status, data.message);
	        if (data.nextTaskId) {// if next task available.
	        dashboard.hideModalLoadingImage();
	            dashboard.formTitle = data.nextTaskName;
	          //  dashboard.featureId = data.nextTaskDisplayId;
	           // dashboard.osTypeId = data.osType;
	            dashboard.openTaskForm(data.nextTaskId);
	        } else {
	        	dashboard.hideModalLoadingImage();
	        }
	        //dashboard.hideModalLoadingImage();
	    }, function(err) {
	        dashboard.hideModalLoadingImage();
	        dashboard.reloadWorkListItems();
	        dashboard.showNotificationStatus("FAILURE", "Unable to create new package!");
	        // Handle the error condition
	    }, function(evt) {
	        // Handle a progress event from the request if the
	        // browser supports XHR2
	    });
	
	
	});
	},
	
	
	createBranchRestriction:function(action) {
		console.log("action on menu item click"+action);
		console.log("/irt/app/throttle/createBranchRestrictionMgmt/"+action);
        dashboard.showModalLoadingImage();
        dashboard.formTitle = "Enable/Disable Branch Commit Restriction";
        dashboard.dialogStyle = "width:850px;height:auto;";                
        dashboard.myDialog.set("style",dashboard.dialogStyle);
        require(["dojo/request/xhr"], function(xhr) {
        	
            xhr("/irt/app/throttle/createBranchRestrictionMgmt/"+action, {
        	preventCache: true,
        	 query: {
             },
        	handleAs: "json"
            }).then(function(data) {
            	
            	var temp =jsonUtil.parse(data);
            	
            	console.debug(temp);
            	
            	dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus(data.status, data.message);
                
                if (data.nextTaskId) {// if next task available.
                	dashboard.hideModalLoadingImage();
                    dashboard.formTitle = data.nextTaskName;                  
                    dashboard.openTaskForm(data.nextTaskId);
                } else {
					dashboard.hideModalLoadingImage();
                }              
                
                
            }, function(err) {
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to load form!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
        });
    },

	createThrottleRequest : function() {
			console.log("action on menu item click" );
			console.log("/irt/app/throttle/createBranchCommitMgmt");
			dashboard.showModalLoadingImage();
			dashboard.formTitle = "Create Throttle Request";
			dashboard.dialogStyle = "width:850px;height:auto;";
			dashboard.myDialog.set("style", dashboard.dialogStyle);
			require([ "dojo/request/xhr" ], function(xhr) {

				xhr("/irt/app/throttle/createBranchCommitMgmt/WEB", {
					preventCache : true,
					method:"POST",
					query : {},
					handleAs : "json"
				}).then(
						function(data) {

							var temp = jsonUtil.parse(data);

							console.debug(temp);

							dashboard.reloadWorkListItems();
							dashboard.showNotificationStatus(data.status,
									data.message);

							if (data.nextTaskId) {// if next task available.
								dashboard.hideModalLoadingImage();
								dashboard.formTitle = data.nextTaskName;
								dashboard.openTaskForm(data.nextTaskId);
							} else {
								dashboard.hideModalLoadingImage();
							}

						},
						function(err) {
							dashboard.hideModalLoadingImage();
							dashboard.reloadWorkListItems();
							dashboard.showNotificationStatus("FAILURE",
							"Unable to load form!");
							// Handle the error condition
						}, function(evt) {
							// Handle a progress event from the request if the
							// browser supports XHR2
						});
			});
		},
	
	
    createBranchDialog:function() {
    		//Need to hit different service for different roles.
    	    var serviceUrl = "/irt/app/release/createBranch";  
    	    require(["dojo/request/xhr"], function(xhr) {

            xhr(serviceUrl, {
            preventCache: true,
                query: {
                },
                handleAs: "json"
            }).then(function(data) {               
            	dashboard.reloadWorkListItems();
                dashboard.renderReleaselistTab();
                //we dont need to display notification for successful feature id creation
                //dashboard.showNotificationStatus(data.status, data.message);
                if (data.nextTaskId) {// if next task available.
                dashboard.hideModalLoadingImage();
                    dashboard.formTitle = data.nextTaskName;
                    
                    dashboard.osTypeId = data.osType;
                    dashboard.openTaskForm(data.nextTaskId);
                } else {
                	dashboard.hideModalLoadingImage();
                }
                //dashboard.hideModalLoadingImage();
            }, function(err) {
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to create new branch!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    }
//till here
,

    /**
     * Publish worklist item selected message.
     **/
    publish: function(message) {
        require(["dojo/_base/connect"], function(connect) {
            connect.publish("workListMessage", [{
                    item: message
                }]);
        });
    },
    
  
    /**
     * Render the  work list table.
     *
     **/
    renderWorkListTable: function() {

        // Define the layouts
        dashboard.layout = [[
				{
				    'name': 'ID',
				    'field': 'description',
				    'width': '20%',
				    'formatter': function(item, rowIndex, cell) {
				    	return dashboard.formatFTSIDWorkList(item, rowIndex, cell);
				    }
				},
				
                {
                    'name': '<span style=\'padding-left:45%\'>Actions</span>',
                    'field': 'name',
                    'width': '40%'
                },
                
                {
                    'name': '<span style=\'padding-left:45%\'>Perform</span>',
                    'field': '_item',
                    'width': '20%',
                    'formatter': function(item, rowIndex, cell) {
                        return dashboard.workItemOperations(item, rowIndex, cell);
                    }//dashboard.workItemOperations
                },
                
                {
                    'name': 'Software',
                    'field': 'osType',
                    'width': '10%'
                },
                {
                    'name': 'Created On',
                    'field': 'createdDate',
                    'width': '10%',
                    'datatype': 'date',
                    'datePattern':'mm-dd-yyyy',
                    'formatter':function(item){
                    	var date = new Date(parseFloat(item));
                    	var formattedDate="--";
                    	if(date.toString().indexOf("NaN")>0){
                    		return;
                    	}
                    	var month = date.getMonth();
                		var formattedMonth = month < 9 ? "0" + (month + 1) : month + 1;
                		formattedDate = formattedMonth + "-" + date.getDate() + "-" + date.getFullYear() ;
                    	return formattedDate;
                    }
                }
            ]];
     //madhakul: adding a layout definition for releaselist tab.
     dashboard.releaseLayout = [[
			            {
					"name": "Release Number",
					"field": "releaseNumber",
					"width": "15%"
                                        //comment this out as of now.. Will redo this during update release.
//					'formatter' : function(item, rowIndex, cell) {
//						return dashboard.formatReleaseNumber(item, rowIndex, cell);
//					}
			      	    }, 
                                    {
 					"name": "OS Type",
 					"field": "osType",
 					"width": "15%"
 				    }, 
 				    {
					"name": "EC Date", 
					"field": "ecDate", 
					"width": "15%"
//					'formatter' : function(item, rowIndex, cell ) {
//						return dashboard.formatReleaseColumns(item, rowIndex, cell);
//					}
 				    },
 				    {
					"name": "DTHO date", 
					"field": "dthoDate", 
					"width": "15%"
//					'formatter' : function(item, rowIndex, cell ) {
//						return dashboard.formatReleaseColumns(item, rowIndex, cell);
//					}
			 	    },
 			       	    {
						"name": "Target CCO Date", 
						"field": "targetCcoDate", 
						"width": "15%"
//						'formatter' : function(item, rowIndex, cell ) {
//							return dashboard.formatReleaseColumns(item, rowIndex, cell);
//						}
				    },  
				    
				    {
						"name": "Release PM", 
						"field": "releasePM", 
						"width": "15%"						
				    },  
				    {
						"name": "CFN SME", 
						"field": "cfnSME", 
						"width": "10%"						
				    }
     ]];
        
     // Define the layouts
       var baLayout = [[
				{
				    'name': 'Item Id',
				    'field': 'description',
				    'width': '45%'
				},
                {
                    'name': 'Task',
                    'field': 'name',
                    'width': '45%'
                },
                
                {
                    'name': 'Action',
                    'field': '_item',
                    'width': '10%',
                    'formatter': function(item, rowIndex, cell) {
                        return dashboard.workItemBAOperations(item, rowIndex, cell);
                    }//dashboard.workItemOperations
                }
            ]];


        var notificationLayout = [[
                {
                    'name': 'Item Type',
                    'field': 'itemName',
                    'width': '40%'
                },
                {
                    'name': 'Description',
                    'field': 'description',
                    'width': '40%'
                },
                {
                    'name': 'User',
                    'field': 'user',
                    'width': '20%'
                }
            ]];


        var tc = new dijit.layout.TabContainer({
            style: "height: 85%; width: 100%; margin-top:10px; overflow-y:hidden"
        }, "tc1-prog");
        
        

        dashboard.cp1 = new dijit.layout.ContentPane({
            title: "My Actions",
            content: " Loading ........",
            style: "overflow:hidden;height:100% !important;width:100% !important;margin-top:-8px;margin-left:-8px"
        });
        tc.addChild(dashboard.cp1);

        dashboard.cp2 = new dijit.layout.ContentPane({
            title: "Notifications",
            content: " Loading ........",
            style: "overflow:hidden;height:100% !important;width:100% !important;margin-top:-8px;margin-left:-8px"
        });

        dashboard.cp3 = new dijit.layout.ContentPane({
            id:"baTab",
            title: "Business Admin",
            content: " Loading ........",
            style: "overflow:hidden"
        });

        tc.addChild(dashboard.cp3);
        //Added to load ba tab when clicked
        require(["dijit/registry",  "dojo/on", "dojo/ready","dojo/aspect", "dojo/domReady!"], function (registry, on, ready) {
            ready(function (aspect) {
        var tabs = registry.byId('tc1-prog');     
	        tabs.watch("selectedChildWidget", function(name, oval, nval){
	            //console.log("selected child changed from ", oval.id, " to ", nval.id);
	            if (nval.id == 'baTab') {
	            	//load ba tab
	            	console.log("redering BA tab");
	            	dashboard.renderBATab();
	            }

	        });
            });
        });
        dashboard.cp4 = new dijit.layout.ContentPane({
            title: "Feature List Tab",
            content: "Feature List is Loading ........",
            style: "overflow:hidden;height:100% !important;width:100% !important;margin-top:-8px;margin-left:-8px"
            
        });
        tc.addChild(dashboard.cp4);

        dashboard.cp5 = new dijit.layout.ContentPane({
            title: "Release List",
            content: "Release List is Loading ........",
            style: "overflow:hidden;height:100% !important;width:100% !important;margin-top:-8px;margin-left:-8px"
            
        });
        if(dashboard.currentlySelectedUserRole == "RELEASE_PM" || dashboard.currentlySelectedUserRole == "CFN_SME" ) {
            tc.addChild(dashboard.cp5);
        }
        
        //this is store it in dashboard scope to be reused when a tab needs to be removed
        dashboard.tc = tc;
        //tc.refresh();
        /*Call startup() to render the grid*/

        /*create a new grid:*/
        dashboard.grid = new dojox.grid.EnhancedGrid({
            id: 'grid',
            structure: dashboard.layout,
            columnReordering: true,
            noDataMessage: '<span class="dojoxGridNoData"> No worklist items available </span>',
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            selectable: true,
            escapeHTMLInData: false,
            onRowClick: function(e) {
                var r = e;
                var y = 3;
                var z = e.rowIndex;
                var aa = e.rowNode;
                var d = 3;
            },
            rowSelector: '20px',
            plugins: {
            	filter: {
                    // Show the closeFilterbarButton at the filter bar
                    //closeFilterbarButton: true,
                    // Set the maximum rule count to 5
                    ruleCount: 5,
                    // Set the name of the items
                    itemsName: "items"
                    },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             }
        },
                document.createElement('div'));
		dashboard.grid.set("style", "margin-left:5px");
	
	//madhakul : Added it for release grid
        dashboard.releaselistGrid = new dojox.grid.EnhancedGrid({
	    id: "releaselistGrid",
	    structure: dashboard.releaseLayout,
            columnReordering: true,
            noDataMessage: '<span class="dojoxGridNoData"> No release items available </span>',
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            selectable: true,
            escapeHTMLInData: false,
            onRowClick: function(h) {
                var f = h;
                var l = 3;
                var k = h.rowIndex;
                var g = h.rowNode;
                var j = 3;
            },
            rowSelector: "20px",
            plugins: {
                filter: {
                            ruleCount: 5,
                            itemsName: "items"
                },
                pagination: {
                    pageSizes: ["10", "25", "50", "All"],
                    description: true,
                    sizeSwitch: true,
                    pageStepper: true,
                    gotoButton: true,maxPageStep: 4,position: "bottom"
                }
             }
         }, 
                document.createElement("div"));
		dashboard.releaselistGrid.set("style", "margin-left:5px");

        dashboard.notificationGrid = new dojox.grid.EnhancedGrid({
            id: 'notificationGrid',
            structure: notificationLayout,
            columnReordering: true,
            noDataMessage: '<span class="dojoxGridNoData"> Worklist not available </span>',
            selectable: true,
            escapeHTMLInData: false,
            rowSelector: '20px'
        },
        document.createElement('div'));
        

        dashboard.businessAdminGrid = new dojox.grid.EnhancedGrid({
            id: 'businessAdminGrid',
            structure: baLayout,
            columnReordering: true,
            noDataMessage: '<span class="dojoxGridNoData"> No worklist items available </span>',
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            selectable: true,
            escapeHTMLInData: false,
            onRowClick: function(e) {
                var r = e;
                var y = 3;
                var z = e.rowIndex;
                var aa = e.rowNode;
                var d = 3;
            },
            rowSelector: '20px',
            plugins: {
            	filter: {
                    // Show the closeFilterbarButton at the filter bar
                    //closeFilterbarButton: true,
                    // Set the maximum rule count to 5
                    ruleCount: 5,
                    // Set the name of the items
                    itemsName: "items"
                    },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             }
        },
        document.createElement('div'));

        dashboard.cp3.domNode.appendChild(dashboard.businessAdminGrid.domNode);
        dashboard.cp3.domNode.removeChild(dashboard.cp3.domNode.firstChild);
        dashboard.cp1.domNode.removeChild(dashboard.cp1.domNode.firstChild);
        dashboard.cp1.domNode.appendChild(dashboard.grid.domNode);
        dashboard.cp5.domNode.removeChild(dashboard.cp5.domNode.firstChild);
        dashboard.cp5.domNode.appendChild(dashboard.releaselistGrid.domNode);

	dashboard.grid.startup();
	dashboard.releaselistGrid.startup();
        dashboard.businessAdminGrid.startup();
        dashboard.buildRoleCustomizedView();
        //removing BA tab as this will be added when needed
        //this will be reused when we need to add it dynamically
        dashboard.tc.removeChild(dashboard.cp3);
        tc.startup();
        tc.resize();
        
	//madhkul - this is to help grid to refresh its all widget childs with latest window / screen size
	dojo.addOnLoad(function() {
            dojo.connect(window, "onresize", dashboard.resizeGrid(.75));
	});

	//madhakul - this to help widget to understand that there is tab change and accordingly lay out the sub tabs correctly
	dashboard.tc.watch("selectedChildWidget", function(name, oval, nval){
            if(nval.title === "Feature List" ) {
                dashboard.resizeGrid();
            }
        });

        dashboard.grid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        dashboard.notificationGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
	//madhakul: added message for releaselist grid
        dashboard.releaselistGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
       console.log('commented xhr call onload');
       //commented for improving performance.
     /*   require(["dojo/request/xhr", "dijit/Menu", "dijit/form/ComboButton", "dijit/MenuItem"], function(xhr) {
            xhr("/irt/app/listTasks", {
                query: {
                    role: dashboard.currentlySelectedUserRole
                },
                preventCache: true,
                handleAs: "text"
            }).then(function(result) {*/
                var data_list = [];
                var ba_admin_data_list = [];
                var notification_data_list = [];
                var result={};
                result = jsonUtil.parse(result);

               /* if (result.status != null && result.status.toUpperCase() == "FAILURE") {
                    //dashboard.showNotificationStatus("FAILURE", result.message);
                    //dashboard.grid.showMessage('<span class="dojoxGridError">' + result.message + '</span>');
                	dashboard.grid.showMessage('<span class="dojoxGridNoData"> No worklist items available </span>');
                    //dashboard.notificationGrid.showMessage('<span class="dojoxGridNoData"> No new notifications </span>');
                    return;
                }*/
                //data_list = result.worklist;
                notification_data_list = [];
                for (var key in result) {
                    console.log(key + ': ' + result[key]);
                    if (key=='worklist') {                    	
                    	var temp1 = result[key];//['list'];
                    	data_list = temp1.list;                    	
                    } else if (key=='baWorklist') {                    	
                    	var temp2 = result[key];//.list;
                    	ba_admin_data_list = temp2.list;                    	
                    }
                }
              
                var data = {
                    identifier: 'id',
                    items: data_list
                };

                var notificationData = {
                    identifier: 'id',
                    items: notification_data_list
                };
                
                var baAdminData = {
                        identifier: 'id',
                        items: ba_admin_data_list
                    };

                //Define the stores.
                var store = new dojo.data.ItemFileWriteStore({
                    data: data
                });
                var notificationStore = new dojo.data.ItemFileWriteStore({
                    data: notificationData
                });

                var baAdminStore = new dojo.data.ItemFileWriteStore({
                    data: baAdminData
                });
                
                dashboard.grid.setStore(store);
                dashboard.notificationGrid.setStore(notificationStore);
                dashboard.businessAdminGrid.setStore(baAdminStore);
       /*     }, function(err) {
                dashboard.showNotificationStatus("FAILURE", "Unable to load worklist Items");
                dashboard.grid.showMessage('<span class="dojoxGridNoData"> No worklist items available </span>');
                dashboard.notificationGrid.showMessage('<span class="dojoxGridNoData"> No new notifications </span>');
                dashboard.businessAdminGrid.showMessage('<span class="dojoxGridNoData"> No worklist items available </span>');

                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
            //madhakul - this is new tab logic for release tab.
	    dashboard.renderReleaselistTab();
        })*/
        if (dashboard.myDialog == null) {
            if (dashboard.formTitle == "") {
                  dashboard.formTitle = "Feature Creation Workflow";
                }
            dashboard.myDialog = new dojox.widget.DialogSimple({
                title: dashboard.formTitle,
                id:"dashBoardMyDialog",
                content: "Test content.",
                executeScripts: true,
                loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
                style: "width: 750px;height:auto"
            });
            
            dashboard.myDialog.connect(dashboard.myDialog, "hide", function (e) {
            	// we will set it to false 
            	if (dashboard.destroyChildElements) {
            		dashboard.myDialog.destroyDescendants();
            	}
            });
            
           dashboard.myDialog.connect(dashboard.myDialog, "hide", function (e) {
            	if (dijit.byId('datePickerId1')) {
            		dijit.byId('datePickerId1').destroy(true);
            	}
            	if (dijit.byId('datePickerId2')) {
            		dijit.byId('datePickerId2').destroy(true);
            	}
            	if (dijit.byId('datePickerId3')) {
            		dijit.byId('datePickerId3').destroy(true);
            	}
            	if (dijit.byId('btn_submit_enable_release')) {
            		dijit.byId('btn_submit_enable_release').destroy(true);
            	}
            	if (dijit.byId('majorReleaseDropdownId')) {
            		dijit.byId('majorReleaseDropdownId').destroy(true);
            	}
            	if (dijit.byId('requestedReleaseDropdownId')) {
            		dijit.byId('requestedReleaseDropdownId').destroy(true);
            	}
            	if (dijit.byId('majorReleaseDropdownId_arr')) {
            		dijit.byId('majorReleaseDropdownId_arr').destroy(true);
            	}
            	if (dijit.byId('requestedReleaseDropdownId_arr')) {
            		dijit.byId('requestedReleaseDropdownId_arr').destroy(true);
            	}
            	if (dijit.byId('addIndividualPlatformButtonId')) {
            		dijit.byId('addIndividualPlatformButtonId').destroy(true);
            	}
            	var element = document.getElementById("formQuestions");
            	if (element != null) {
            		element.parentNode.removeChild(element);
            	}
            });
        }
        if (dashboard.groupActionDialog == null) {    		
    		dashboard.groupActionDialog = new dojox.widget.DialogSimple({
            title: "Group Action",
            content: "Test content",
            executeScripts: true,
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 550px;height:auto"
        });
        }
        if (dashboard.cloneDialog == null) {    		
    		dashboard.cloneDialog = new dojox.widget.DialogSimple({
            title: "Clone Feature",
            content: "Test content",
            executeScripts: true,
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 550px;height:auto"
        });
        }
        // himsriva 03/20/14
        if (dashboard.imageListDialog == null) {    		
    		dashboard.imageListDialog = new dojox.widget.DialogSimple({
            title: "Image List",
            content: "Test content",
            executeScripts: true,
           // isLayoutContainer: true,
            overflow: "hidden",
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 1200px;height:auto;"
        });
    		dashboard.imageListDialog.connect(dashboard.imageListDialog, "hide", function (e) {
                // we will set it to false 
                dashboard.imageListDialog.destroyDescendants();
    		});
        }
        if (dashboard.marketMatrixDialog == null) {    		
    		dashboard.marketMatrixDialog = new dojox.widget.DialogSimple({
            title: "Market Matrix",
            content: "Test content",
            executeScripts: true,
           // isLayoutContainer: true,
            overflow: "hidden",
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 1200px;height:auto;"
        });
    		dashboard.marketMatrixDialog.connect(dashboard.marketMatrixDialog, "hide", function (e) {
                // we will set it to false 
                dashboard.marketMatrixDialog.destroyDescendants();
    		});
        }
        if (dashboard.bulkUpdateDialog == null) {    		
    		dashboard.bulkUpdateDialog = new dojox.widget.DialogSimple({
            title: "Bulk Update",
            content: "Test content",
            executeScripts: true,
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 850px;height:auto"
        });
        }
        if (dashboard.internalFeatureDialog == null) {    		
    		dashboard.internalFeatureDialog = new dojox.widget.DialogSimple({
            title: "Non Marketed Feature",
            content: "Test content",
            executeScripts: true,
            loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
            style: "width: 550px;height:550px;"
        });
        }
        if(dashboard.imageDialogBox == null){
        	dashboard.imageDialogBox = new dojox.widget.DialogSimple({
		        title: "Where Am I",
		        executeScripts: true,
		        content:"test content",
		        style: "width: 640px;height:370px"
		    });
        	
        }
        if(dashboard.imageBoxbusyIndicator == null){
        	dashboard.imageBoxbusyIndicator = busyIndicator("dashBoardMyDialog");
        }
        
    },
    
    openBulkUpdateForm: function() {
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/bulkAction/", {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openBulkUpdateForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.bulkUpdateDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Bulk Update Form" + imageHelp;
            	dashboard.bulkUpdateDialog.set("title", tempTitle);
                var domTitle = document.getElementById('dojox_widget_DialogSimple_1_title');
            	if (domTitle) {
                    //console.log('domTitle.parentNode.title'+domTitle.parentNode.title);
                    domTitle.parentNode.title = "";
                } else {
                    console.log('domTitle.parentNode.title is null'+domTitle);
                }
            	dashboard.bulkUpdateDialog.show();

            }, function(err) {
            	console.log('inside error openCloneForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open clone form.");            	
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    
    /**
     * Clone form.
     *
     **/
    openCloneForm: function() {
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/cloneFeature/", {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openCloneForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.cloneDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Clone Form" + imageHelp;
            	dashboard.cloneDialog.set("title", tempTitle);
                var domTitle = document.getElementById('dojox_widget_DialogSimple_1_title');
            	if (domTitle) {
                    //console.log('domTitle.parentNode.title'+domTitle.parentNode.title);
                    domTitle.parentNode.title = "";
                } else {
                    console.log('domTitle.parentNode.title is null'+domTitle);
                }
            	dashboard.cloneDialog.show();
            	
            }, function(err) {
            	console.log('inside error openCloneForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open clone form.");            	
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    /**
     * bulk Clone form.
     *
     **/
    openBulkCloneForm: function() {
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/bulkClone/", {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openBulkCloneForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.cloneDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Bulk Clone Form" + imageHelp;
            	dashboard.cloneDialog.set("title", tempTitle);
            	var domTitle = document.getElementById('dojox_widget_DialogSimple_1_title');
            	if (domTitle) {
                    //console.log('domTitle.parentNode.title'+domTitle.parentNode.title);
                    domTitle.parentNode.title = "";
                } else {
                    console.log('domTitle.parentNode.title is null'+domTitle);
                }
            	dashboard.cloneDialog.show();
            	
            }, function(err) {
            	console.log('inside error openBulkCloneForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open bulk clone form.");            	
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    /**
     * craete  internal feature form.
     *
     **/
    openCreateInternalForm: function( id ) {
    	
    	dashboard.showModalLoadingImage();

		
        require(["dojo/request/xhr"], function(xhr) {    		
            xhr("/irt/app/createInternalFeature?id="+id, {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback createInternalFeature');
            	dashboard.hideModalLoadingImage();
            	dashboard.internalFeatureDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Non Marketing Form" + imageHelp;
            	dashboard.internalFeatureDialog.set("title", tempTitle);
            	console.log("create!!");
    			dashboard.dialogStyle = "height:580px";
            	var domTitle = document.getElementById('dojox_widget_DialogSimple_1_title');
            	if (domTitle) {
                    //console.log('domTitle.parentNode.title'+domTitle.parentNode.title);
                    domTitle.parentNode.title = "";
                } else {
                    console.log('domTitle.parentNode.title is null'+domTitle);
                }
            	dashboard.internalFeatureDialog.show();
            	
            }, function(err) {
            	console.log('inside error createInternalFeature'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open Create Non Marketed Feature.");            	
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    /**
     * Enable release form.
     *
     **/
    openEnableReleaseForm: function() {
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/enableRelease/", {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openEnableReleaseForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.cloneDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Enable Release(s)" + imageHelp;
            	dashboard.cloneDialog.set("title", tempTitle);
            	            	dashboard.cloneDialog.connect(dashboard.cloneDialog, "hide", function (e) {
                	if (dijit.byId('datePickerId1')) {
                		dijit.byId('datePickerId1').destroy(false);
                	}
                	if (dijit.byId('datePickerId2')) {
                		dijit.byId('datePickerId2').destroy(false);
                	}
                	if (dijit.byId('datePickerId3')) {
                		dijit.byId('datePickerId3').destroy(false);
                	}
                	if (dijit.byId('btn_submit_enable_release')) {
                		dijit.byId('btn_submit_enable_release').destroy(false);
                	}
                	if (dijit.byId('majorReleaseDropdownId')) {
                		dijit.byId('majorReleaseDropdownId').destroy(true);
                	}
                	if (dijit.byId('requestedReleaseDropdownId')) {
                		dijit.byId('requestedReleaseDropdownId').destroy(true);
                	}
                	var element = document.getElementById("formQuestions");
                	if (element != null) {
                		element.parentNode.removeChild(element);
                	}
                });
            	dashboard.cloneDialog.show();
            	
            }, function(err) {
            	console.log('inside error openEnableReleaseForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open enable release form.");
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    skipWorkItem: function(taskId) {
    	dashboard.grid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/operation/Skip/" + taskId, {
                query: {
                    random: Math.random() * 1000000000
                },
                preventCache: true
            }).then(function(data) {
                dashboard.reloadWorkListItems();
            }, function(err) {
            	dashboard.showNotificationStatus("FAILURE", "Unable to skip workitem.");
            	dashboard.grid.showMessage('<span class="dojoxGridNoData"> Unable to skip workitem. Please refresh the page. </span>');
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    /**
     * Open Delegate Form.
     *
     **/
    openDelegateForm: function(taskId,featureId) {
    	dashboard.showModalLoadingImage();
    	console.log("systemID========"+featureId);
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/delegateForm/"+dashboard.currentlySelectedUserRole, {
            	query: {
                    taskId: taskId
                },
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openDelegateForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.cloneDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Delegate Form" + imageHelp;
            	dashboard.cloneDialog.set("title", tempTitle);
            	dashboard.featureId=featureId;
      
            	dashboard.cloneDialog.show();
            	
            }, function(err) {
            	console.log('inside error openEnableReleaseForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open delegate form.");
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },

    
    /*
     * Delegate Task
     */
    delegateWorkItem: function(formData) {
    	dashboard.cloneDialog.hide();
    	dashboard.grid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/operation/Delegate/" + formData.taskId, {
            	query:{
            		userId: formData.userId 
            	},
               preventCache: true
            }).then(function(data) {
                dashboard.reloadWorkListItems();
            }, function(err) {
            	console.log('inside error Delegate workitem-'+err);
            	dashboard.showNotificationStatus("FAILURE", "Unable to delegate workitem.");
            	dashboard.grid.showMessage('<span class="dojoxGridNoData"> Unable to delegate workitem. Please refresh the page. </span>');
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    /*
     * Click on open icon.
     */
    onActionClick: function(id) {
        dashboard.openTaskForm(id);
        //asahay
        console.log('item.id onclick button'+id);
       // console.log('dashboard.grid.store'+(dashboard.grid.store).toSource());
        var myStore = dashboard.grid.store;
        var itemObj = myStore._itemsByIdentity[id];
        var formname = itemObj.name;

        console.log("itemObj->"+itemObj+"formname->"+formname);
        dashboard.formTitle = formname;
        dashboard.featureId = itemObj.description;
        dashboard.osTypeId = itemObj.osType;
    },

    //For BA tasks - currently only delegate is applicable
    workItemBAOperations: function(item, rowIndex, cell) {
    	
    	var delegateImg = "<a href='#' onClick='dashboard.openDelegateForm("+item.id+");'  style='cursor:pointer;margin-right:5px;text-decoration:none'>Delegate</a>";
    	
    		//only delegate is applicable for BA ADMIN
    	var	str = "<span style='margin-right:5px;'>"+delegateImg+"</span>";    	
    	
    	return str;
    },
    	
    //madhakul: added this for parsing the data of release list grid
    formatReleaseColumns: function (item, rowIndex, cell) {
        var ar = item.split(" ");
        var status = ar[0];
        if( status == "") {
         status = "Not completed";
        }
        var line = status + "<br>" + ar[1] + "</br>";
        return line;
    }, 	
    //formatter for release number
    formatReleaseNumber: function(item, rowIndex, cell) {
	var arr = item.split("|");
       	if (item && item !='') {
       		arr[0] = "<a href='#' style='text-decoration:none' href='#' onClick='dashboard.openReleaseForm("+arr[1]+"); return false;'>"+arr[0]+"</a>";
       	}
       	return arr[0];
    },
    //Open release form
    openReleaseForm: function(relNo) {
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {
            xhr("/irt/app/enableRelease/?releaseNumberId="+relNo, {                
                preventCache: true
            }).then(function(data) {
            	console.log('inside callback openEnableReleaseForm');
            	dashboard.hideModalLoadingImage();
            	dashboard.cloneDialog.set("content", data);
//            	var imageHelp = "<span style='position:absolute; right:30px;'><img src='/irt/resources/images/help_small.png' height='16px;' width='16px;' alt='Help' title='Help' style='cursor:pointer' /></span>";
            	var imageHelp = "";
            	var tempTitle = "Release Rollback" + imageHelp;
            	dashboard.cloneDialog.set("title", tempTitle);
            	dashboard.cloneDialog.connect(dashboard.cloneDialog, "hide", function (e) {
                	if (dijit.byId('datePickerId1')) {
                		dijit.byId('datePickerId1').destroy(false);
                	}
                	if (dijit.byId('datePickerId2')) {
                		dijit.byId('datePickerId2').destroy(false);
                	}
                	if (dijit.byId('datePickerId3')) {
                		dijit.byId('datePickerId3').destroy(false);
                	}
                	if (dijit.byId('btn_submit_enable_release')) {
                		dijit.byId('btn_submit_enable_release').destroy(false);
                	}
                	if (dijit.byId('majorReleaseDropdownId')) {
                		dijit.byId('majorReleaseDropdownId').destroy(true);
                	}
                	if (dijit.byId('requestedReleaseDropdownId')) {
                		dijit.byId('requestedReleaseDropdownId').destroy(true);
                	}
                	var element = document.getElementById("formQuestions");
                	if (element != null) {
                		element.parentNode.removeChild(element);
                	}
                });
            	dashboard.cloneDialog.show();
            	
            }, function(err) {
            	console.log('inside error openEnableReleaseForm'+err);
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open enable release form.");
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    	/*var url = "/irt/app/releaseRollback/?releaseNumberId="+relNo;
    	var rollbackWin = window.open(url,
    			  'Release Form','toolbar=no,width=725,height=450,left=325,top=200,status=no,scrollbars=yes,resize=no');*/
    },
    
    workItemOperations: function(item, rowIndex, cell) {
    	//need to finalize action images.
    	//console.log("item desc"+item.description);
    	var openImg = "<a href='#' onclick='dashboard.onActionClick("+item.id+")' style='cursor:pointer;margin-right:5px;text-decoration:none' >Open</a>";
    	var skipImg = "<a href='#' onClick='dashboard.skipWorkItem("+item.id+");' style='cursor:pointer;margin-right:5px;text-decoration:none' >Skip</a>";
    	var delegateImg = "<a href='#' onClick=\"dashboard.openDelegateForm("+item.id+",'"+item.description+"');\"  style='cursor:pointer;margin-right:5px;text-decoration:none'>Delegate</a>";
    	var releaseImg = "<a href='#'  style='cursor:pointer;margin-right:5px;text-decoration:none'>Release</a>";
    	var str = "";
    	//skip is diabled for now, code needs to be updated to get all action from backend.
    	//skipImg = "";
    	
    	str = "<span style='padding-left:25%'>";//+openImg+skipImg+delegateImg+releaseImg+"</span>";
    	for (i = 0; i < item.operations.length; i++) {
    		if (item.operations[i] == "Claim") {
    			str = str + openImg;
    		}
    		if (item.operations[i] == "Open") {
    			str = str + openImg;
    		}
    		if (item.operations[i] == "Skip") {
    			str = str + "| " + skipImg;
    		} 
    		if (item.operations[i] == "Delegate") {
    			str = str + "| " + delegateImg;
    		}
    		if (item.operations[i] == "Release") {
    			str = str + "| " + releaseImg;
    		}
    	}
    	
    	str = str + "</span>";
    	
    	//console.log("action icons:"+str);
    	//var finalString = item.name + str;
    	var finalString = str;
        return finalString;
    },
    /**
     * Process events on the landing page. One stop place where all events can be processed.
     * As of now create feature and all work list items opening are captured here.
     */
    processWorkItem: function(message) {

        if (message.item == "createNewFeature") {
            dashboard.createNewFeatureConfirmDialog();
        } else {
            dashboard.openTaskForm(message.item);
        }
    },
    openTaskForm: function(taskId) {
    	console.log("myTaskId:"+taskId);
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {
console.log('inside require');
            xhr("/irt/app/showForm/" + taskId, {
                query: {
                    random: Math.random() * 1000000000
                },
                preventCache: true,
                handleAs: "html"
            }).then(function(data) {
            	dashboard.imageDialogBoxTaskId= taskId;
            	dashboard.hideModalLoadingImage();
            	var index=data.indexOf("{");
            	
            	console.log("Output data.status"+data.status);
            	var  datatext;
            	if(index==0)
            		{
            		 datatext=jsonUtil.parse(data).status;
            		}
            	
            	if(datatext=="Failure" || datatext=="failure")
            		{
            		       console.log("Output datatext "+datatext);

            		       alertBox("The task is either completed or deleted.Refresh your browser to list " +
            		 		"latest work list.");
            		}
            	else
            		{
            		 
                dashboard.displayDialogBox(data);
            		}


            }, function(err) {
            	dashboard.hideModalLoadingImage();
            	dashboard.showNotificationStatus("FAILURE", "Unable to open task form!");
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    formSubmitSuccessCallback: function(result) {
        dashboard.reloadWorkListItems();
        if (result.status == null || result.status.toUpperCase() != "FAILURE") {
            dashboard.hidePopupDialogBox();
            if (result.nextTaskId != null) {
                //asahay
                console.log('result next task name-->'+result.nextTaskName);
                dashboard.featureId = result.nextTaskDisplayId;
                dashboard.osTypeId = result.osType;
                dashboard.formTitle = result.nextTaskName;
                dashboard.publish(result.nextTaskId);

            } else {
            	console.log('inside formSubmit');
            	//dashboard.infoBox("Your actions for this workflow are completed.\nPlease click <a href='#' onclick='dashboard.infoDialog.hide();dojo.destroy(dashboard.infoDialog);'>Here</a> to see feature details.");
            	dashboard.hideNotificationForInfo = true;
            	//dashboard.showNotificationStatus("Info", "Your actions for this workflow are completed. Please <a href='#' onclick='dashboard.tc.selectChild(dashboard.cp4);'>click here</a> to see feature details.");
                dashboard.showNotificationStatus("Info", "Your actions for this workflow are completed");
            }
        } else {        	
            dashboard.showNotificationStatus(result.status, result.message);
            alertBox(result.message);
           
        }
    },
    infoBox: function(msg) {
    	require(["dojo/ready", "dojox/widget/DialogSimple","dijit/form/Button"], function(ready, DialogSimple,Button){
    	    ready(function(){
    	    	
    	    	dashboard.infoDialog = new dojox.widget.DialogSimple({
    	    		title: "Info",
    	            style: "width: 300px;height:auto",
    	            exceuteScript: true,
    	            content: msg
    	        });
    	        //Creating div element inside dialog to add OK button.
    	    	//onClick of ok button dialog box should get closed.
    	        var div = dojo.create('div', {style: "margin: 10px auto 5px auto; text-align: center;"}, dashboard.infoDialog.containerNode);

    	        var okBtn = new dijit.form.Button({
    	            label: "Ok",
    	            onClick: function() {
    	            	dashboard.infoDialog.hide();
    	                dojo.destroy(dashboard.infoDialog);
    	            }
    	        });
    	        //for using deafult dojo button size
    	        //dojo.style(okBtn,"width","100px");
    	        //adding buttons to the div, created inside the dialog
    	        dojo.create(okBtn.domNode, {}, div);
    	        dashboard.infoDialog.show();

    	    });
    	});
    },
    formSubmitFailureCallback: function(result) {
        dashboard.showNotificationStatus(result.status, result.message);
        dashboard.reloadWorkListItems();

    },
    displayGroupAction: function(formName) {
    	//dashboard.myDialog.hide();
    	dashboard.displayGroupActionPopup();
    	//display group action form
    },
    /**
     * Display dialog box with required content
     */
    displayDialogBox: function(content) {

    	console.log("Inside displayDialogBox"+ content.status);
            if (dashboard.featureId != null && dashboard.featureId.length > 0) { 
    	featureNameDialogInnerHtml = '<div class="formFeatureNameClass" id="featureNameDashboardDivId">';
    	featureNameDialogInnerHtml +='<table width="100%" cellspacing="0" cellpadding="0" border="0"><tr>';
		featureNameDialogInnerHtml +='<th>Feature Name:</th><td id="featureNameDashboardId"></td></tr></table></div>';
     
		featureNameDialogInnerHtml += '<script>';
    	featureNameDialogInnerHtml += 'document.getElementById("featureNameDashboardId").innerHTML="hello";';
		featureNameDialogInnerHtml += 'document.getElementById("featureNameDashboardDivId").style.display="none";';
    
		featureNameDialogInnerHtml += '</script>';
        this.myDialog.set("content", featureNameDialogInnerHtml + content);
    } else {
         this.myDialog.set("content",content);
    }
    
    
                   if (dashboard.featureId != null && dashboard.featureId.length > 0) { 

		$.ajax({
    			crossDomain:true,
    			type: "GET",
    			url: dashboard.featureServicesBase+'/v1/featureReleaseFromFtsId/'+dashboard.featureId,
				dataType: "json",
    			success: function(data){
					if(data.feature !=undefined){
						if(data.feature.mktgName !=undefined){
							document.getElementById("featureNameDashboardId").innerHTML=data.feature.mktgName;		
							document.getElementById("featureNameDashboardDivId").style.display="inline";
						}
					}
    			},
				failure:function(err){
					console.log("no internal name found"); 	
				}

		});
            }
        console.log('title for dialog box->'+dashboard.formTitle);
        //added check to make sure that we do not display undefined
        var tempTitle = dashboard.formTitle;

        //try {
        	//these if blocks need little more work. Keeping them as it is for now.
        	dashboard.dialogStyle = "width: 750px;height:auto";
        	if (tempTitle.indexOf('Associate Release & Platforms') == 0 || tempTitle[0].indexOf('Associate Release & Platforms') == 0) {
        		dashboard.dialogStyle = "width: 650px;height:auto";
        	} 
        	
        	if (tempTitle.indexOf('Identify Test') == 0 || tempTitle[0].indexOf('Identify Test') == 0) {
        		dashboard.dialogStyle = "width: auto;height:auto";
        	} 
        	
        	if (tempTitle.indexOf('Map Subsystem') == 0 || tempTitle[0].indexOf('Map Subsystem') == 0) {
        		dashboard.dialogStyle = "width: auto;height:auto";
        	}
        	if (tempTitle.indexOf('Approve FR for Release') == 0 || tempTitle[0].indexOf('Approve FR for Release') == 0) {
        		dashboard.dialogStyle = "width: auto;height:auto;overflow:auto;";
        	}
        	if (tempTitle.indexOf('Approve CR for Release') == 0 || tempTitle[0].indexOf('Approve FR for Release') == 0) {
        		dashboard.dialogStyle = "width: auto;height:auto;overflow:auto;";
        	}
        	if (tempTitle.indexOf('Approve FN for Release') == 0 || tempTitle[0].indexOf('Approve FR for Release') == 0) {
        		dashboard.dialogStyle = "width: auto;height:auto;overflow:auto;";
        	}
        	if (tempTitle.indexOf('Approve Release EC') == 0 || tempTitle[0].indexOf('Approve Release EC') == 0) {
        		dashboard.dialogStyle = "width: 1160px;height:550px;overflow:auto;";
        	}
        	
        	
        	if (tempTitle.indexOf('Create Train') == 0 || tempTitle[0].indexOf('Create Train') == 0) {
        		//dashboard.dialogStyle = "width: 1160px;height:550px;overflow:auto;";
        	}
        	
        	if (tempTitle.indexOf('Update Train') == 0 || tempTitle[0].indexOf('Create Train') == 0) {
        		//dashboard.dialogStyle = "width: 1160px;height:550px;overflow:auto;";
        		dashboard.dialogStyle = "width: 1000px;height:auto;overflow:auto;";
        	}
                
        	if (tempTitle.indexOf('Create Release') == 0 || tempTitle[0].indexOf('Create Release') == 0) {
        		dashboard.dialogStyle = "width: 1080px;height:auto;overflow:auto;";
        	} 
        	
        	if (tempTitle.indexOf('Validate CCO Readiness') == 0 || tempTitle[0].indexOf('Validate CCO Readiness') == 0) {
        		dashboard.dialogStyle = "width: 1000px;height:auto;overflow:auto;";
        	} 
        	
        	if (tempTitle.indexOf('Select Release') == 0 || tempTitle[0].indexOf('Select Release') == 0) {
        	        		dashboard.dialogStyle = "width: 800px;height:100px;overflow:auto;";
        	} 
        
        	if (tempTitle.indexOf('MetadataRepost') == 0 || tempTitle[0].indexOf('MetadataRepost') == 0) {
        		dashboard.dialogStyle = "width: 1000px;height:auto;overflow:auto;";
        	} 
        	
        	if (tempTitle.indexOf('Remove Images') == 0 || tempTitle[0].indexOf('Remove Images') == 0) {
        		dashboard.dialogStyle = "width: 1000px;height:auto;overflow:auto;";
        	} 
        
    /*} catch (e) {
        	//this block is added as in some cases we see title coming as array, indexOf will fail we get array.
        	//For now catch will handle this. We need to make sure that we always get string and not an array then we can remove try catch
            if (tempTitle[0].indexOf('Associate Platforms') > -1 || 
            		tempTitle[0].indexOf('Identify Test')  > -1 ||
            		tempTitle[0].indexOf('Map Subsystem')  > -1  ||
            		tempTitle[0].indexOf('Approve FR for Release')  > -1  ||
            		tempTitle[0].indexOf('Approve Release EC')  > -1 ) {
                dashboard.dialogStyle = "width: auto;height:auto";
                console.log('Inside set style for forms CATCH-'+dashboard.dialogStyle);
            } else {
            	//console.log('identify test catch else block');
                dashboard.dialogStyle = "width: 550px;height:auto";
            }
            
        }*/
        //add feature id to title
        
        if (dashboard.featureId != null && dashboard.featureId.length > 0)
            tempTitle = tempTitle +" : "+dashboard.featureId;
        
        
        //add image help icon. We need to put this to close button.
        var imageHelp = "<span id='processImageSpan' style='padding-right: 10px;padding-top: 15px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' onClick='dashboard.openProcessImage(dashboard.imageDialogBoxTaskId)'/></span>";
        var imageComments = "<span style='padding-right: 10px;padding-top: 15px;'><img src='/irt/resources/images/comments.svg' height='16px;' width='16px;'  title='View/Add Comments' style='cursor:pointer' onClick='dashboard.showCommentsPopup()'/></span>";

        //var imageHelp = "";
        
        if (tempTitle.indexOf("Train") < 1 &&  tempTitle.indexOf("Branch") < 1 && tempTitle.indexOf("Update Release") < 1
                && tempTitle.indexOf("Release Option") < 1 && tempTitle.indexOf("Related Software") < 1) {
           tempTitle = tempTitle + imageHelp + imageComments;
        }
        this.myDialog.set("style",dashboard.dialogStyle);

        this.myDialog.set("title", tempTitle);
        this.myDialog.show();
        document.getElementById("dashBoardMyDialog_title").parentNode.title = "";
        var domTitle = document.getElementById('dojox_widget_DialogSimple_0_title');
        if (domTitle) {
            //console.log('domTitle.parentNode.title'+domTitle.parentNode.title);
            domTitle.parentNode.title = "";
        } else {
            console.log('domTitle.parentNode.title is null'+domTitle);
        }
        //this.myDialog.layout(); // starts the resize
    },
    
    showCommentsPopup : function() {
    	require(["dojo/request/xhr"], function(xhr) {

	        xhr("/irt/view/irt/jsp/comments.jsp", {
	            preventCache: true,
	        }).then(function(displayData) {
	        	//busyObj.hide();
	        	dashboard.hideModalLoadingImage();
	        	if(! dashboard.commentsForm) {
	        		dashboard.commentsForm = new dojox.widget.DialogSimple({
	        			id: "commentsForm",
	        			content: "Test content",
	        			title : "Comments - "+dashboard.featureId,
	        			executeScripts: true,
	        			loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
	        			style: "width: 500px;height:auto"
	        			
	        		});
	        	}
	        	var innerHtml = "<textarea></textarea>";
	        	var tempTitle = "Comments : "+dashboard.featureId;
	         		dashboard.commentsForm.set("content", displayData);
	         		dashboard.commentsForm.set("title", tempTitle);
	             	dashboard.commentsForm.show();
	             	//enableBusyObj = busyIndicator("enableReleasePopup");
	             	//associateBulkCloneDetails.busyObjPopup = busyIndicator("busyObjPopup");
	        }, function(err) {
	        	console.log('inside error - Show comments'+err);
	        	dashboard.hideModalLoadingImage();
	        	dashboard.showNotificationStatus("FAILURE", "Unable to view comments.");            	
	        });

	        
		});
    },

    displayGroupActionPopup : function() {
    	require(["dojo/request/xhr"], function(xhr) {
    
	        xhr("/irt/view/feature/jsp/groupAction.jsp", {
	            preventCache: true,
	        }).then(function(displayData) {
	        	//busyObj.hide();
	        	dashboard.hideModalLoadingImage();
	        	if(! dashboard.groupActionDialog) {
	        		dashboard.groupActionDialog = new dojox.widget.DialogSimple({
	        			id: "groupActionDialog",
	        			content: "Test content",
	        			title : "Group Action",
	        			executeScripts: true,
	        			loadingMessage: '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
	        			style: "width: 500px;height:auto",

	        		});
	        	}
	        	var tempTitle = "Group Action";
	         		dashboard.groupActionDialog.set("content", displayData);
	         		dashboard.groupActionDialog.set("title", tempTitle);
	             	dashboard.groupActionDialog.show();
	             	//enableBusyObj = busyIndicator("enableReleasePopup");
	             	//associateBulkCloneDetails.busyObjPopup = busyIndicator("busyObjPopup");
	        }, function(err) {
	        	console.log('inside error - Show comments'+err);
	        	dashboard.hideModalLoadingImage();
	        	dashboard.showNotificationStatus("FAILURE", "Unable to load group action form.");            	
	        });

	        
		});
    },
    /**
     *
     * @param {type} title title of dialog box
     * @param {type} dimensions [x,y] value
     * @returns {undefined}
     */
    setDialogBoxTitle: function(title, dimensions) {
        this.myDialog.set("title", title);
        this.myDialog.set("dimensions", dimensions);
    },
    

    /**
     * This will open a popup window for rollback form
     * @param featureRelId
     * 
     */
    openRollBackWindow: function(ftsId) {
    	var url = "/irt/app/showRollBackFormFtsId/"+ftsId;
    	var rollbackWin = window.open(url,
    			  'Rollback','toolbar=no,width=725,height=450,left=325,top=200,status=no,scrollbars=yes,resize=no');
    },
    
/*    *//**
     * This will open a popup window for non marketing form
     * @param featureRelId
     * 
     *//*
    openInternalFeatureWindow: function(featureReleaseId) {
    	var url = "/irt/app/displayInternalFeature?featRelId="+featureReleaseId;
    	var internalFeatureWin = window.open(url,
    			  'Rollback','toolbar=no,width=725,height=450,left=325,top=200,status=no,scrollbars=yes,resize=no');
    },*/
    
    openProcessImage:function(taskId){
    	dashboard.imageBoxbusyIndicator.show();
    	require(["dojo/request/xhr"], function(xhr) {
    		xhr("/irt/app/processStatus/task/" + taskId, {
    		   handleAs: "html",
    		   preventCache: true,
    		}).then(function(data) {
    		 	dashboard.imageBoxbusyIndicator.hide();
    			dashboard.imageDialogBox.set("content", data);
    			dashboard.imageDialogBox.show();
    		}, function(err) {
    		  	dashboard.imageBoxbusyIndicator.hide();
    		  	dashboard.showNotificationStatus("FAILURE", "Unable to open image!");
    		}, function(evt) {
    		    // Handle a progress event from the request if the
    			// browser supports XHR2
    		});
    	});
    },
    
    /**
     * This will open a popup window for clone feature
     * @param none
     * 
     */
    openCloneWindow: function() {
    	//url will be updated once ready.
    	var url = "/irt/app/cloneFeature/";
    	var cloneWin = window.open(url,
    			  'Rollback','toolbar=no,width=725,height=450,left=325,top=200,status=no,scrollbars=no,resize=no');
    },
    //madhakul: function to handle loading and rendering of release list. This function will be called at startup and when reloaded.
    renderReleaselistTab: function() {
        dashboard.releaselistGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        require(["dojo/request/xhr", "dijit/Menu", "dijit/form/ComboButton", "dijit/MenuItem"], function(xhr) {
        xhr("/release/v1/release/dashboard/list/"+dashboard.loggedInUserName,
        {preventCache: true,handleAs: "text"}).then(function(r) {
        r = jsonUtil.parse(r);
        /*if (r.status != null && r.status.toUpperCase() == "FAILURE") {
            dashboard.releaselistGrid.showMessage('<span class="dojoxGridError">' + r.status.message + "</span>");
            return;
        }*/
        var releasedata = {
            items: r.releaseList,
            identifier:'releaseNumberId'
        };
        //Define the stores.
        var store = new dojo.data.ItemFileWriteStore({ data: releasedata });
        dashboard.releaselistGrid.setStore(store);
        }, function(e) {
            dashboard.releaselistGrid.showMessage('<span class="dojoxGridNoData"> No release list items available </span>');
        }, function(e) {
        });
    });
    },
  //Keeping BA admin list separate fro worklist. BA admin process data takes time and that affects worklist item rendering.
    renderBATab: function() {
        dashboard.businessAdminGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Please wait, this may take a while.</p></div>');
        require(["dojo/request/xhr", "dijit/Menu", "dijit/form/ComboButton", "dijit/MenuItem"], function(xhr) {
        xhr("/irt/app/baTaskList", {query: {userId: dashboard.loggedInUserName,role:dashboard.currentlySelectedUserRole},preventCache: true,handleAs: "text"}).then(function(badata) {
        badata = jsonUtil.parse(badata);
        if (badata.status != null && badata.status.toUpperCase() == "FAILURE") {
        	dashboard.businessAdminGrid.showMessage('<span class="dojoxGridNoData"> No business admin items available </span>');
            return;
        }
        var releasedata = {
            items: badata.list
        };
        //Define the stores.
        var store = new dojo.data.ItemFileWriteStore({ data: releasedata });
        dashboard.businessAdminGrid.setStore(store);
        }, function(e) {
            dashboard.businessAdminGrid.showMessage('<span class="dojoxGridNoData"> No business admin items available </span>');
        }, function(e) {
        });
    });
    },
    featurePartTab: function() {
	var c = dashboard.cp4.domNode;
        var b = dashboard.featureGridOwn;
        while (c.childNodes.length > 0) {
            c.removeChild(c.firstChild);
        }
        var d;
        require(["dojo/dom-construct"], function(e) {
            d = e.create("div", {innerHTML: "<ul class='tab_ul'><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureGridTab()'>Created By Me</a></li><li class='divider'></li><li class='tab_ul_li'><a>Participated in Current Role</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureIntTab()'>Non Marketed</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureAllTab()'>All Features</a></li></ul>",style: "font-weight:normal;"});
        });
        c.appendChild(d);
        var h = 0.75;
        var d = 25;
        var a = document.body.clientHeight * h - d;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        c.appendChild(b.domNode);
        b.resize(a);
        b.startup();
    },featureIntTab: function() {
        var c = dashboard.cp4.domNode;
        var b = dashboard.featureGridInt;
        while (c.childNodes.length > 0) {
            c.removeChild(c.firstChild);
        }
        var d;
        require(["dojo/dom-construct"], function(e) {
            d = e.create("div", {innerHTML: "<ul class='tab_ul'><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureGridTab()'>Created By Me</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featurePartTab()'>Participated in Current Role</a></li><li class='divider'></li><li class='tab_ul_li'><a>Non Marketed</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureAllTab()'>All Features</a></li></ul>",style: "font-weight:normal;"});
        });
        c.appendChild(d);
        var h = 0.75;
        var d = 25;
        var a = document.body.clientHeight * h - d;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        c.appendChild(b.domNode);
        b.resize(a);
        b.startup();
    },featureGridTab: function() {
        var c = dashboard.cp4.domNode;
        var b = dashboard.featureGrid;
        while (c.childNodes.length > 0) {
            c.removeChild(c.firstChild);
        }
        var d;
        require(["dojo/dom-construct"], function(e) {
            d = e.create("div", {innerHTML: "<ul class='tab_ul'><li class='tab_ul_li'><a>Created By Me</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featurePartTab()'>Participated in Current Role</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureIntTab()'>Non Marketed</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureAllTab()'>All Features</a></li></ul>",style: "font-weight:normal;"});
        });
        c.appendChild(d);
        var h = 0.75;
        var d = 25;
        var a = document.body.clientHeight * h - d;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        c.appendChild(b.domNode);
        b.resize(a);
        b.startup();
    },featureAllTab: function() {  
        var c = dashboard.cp4.domNode;
        var b = dashboard.featureGridAll;
        while (c.childNodes.length > 0) {
            c.removeChild(c.firstChild);
        }
        var d;
        require(["dojo/dom-construct"], function(e) {
            d = e.create("div", {innerHTML: "<ul class='tab_ul'><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureGridTab()'>Created By Me</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featurePartTab()'>Participated in Current Role</a></li><li class='divider'></li><li class='tab_ul_li'><a class='inactive' href='#' onclick='dashboard.featureIntTab()'>Non Marketed</a></li><li class='divider'></li><li class='tab_ul_li'><a>All Features</a></li></ul>",style: "font-weight:normal;"});
        });
        c.appendChild(d);
        var h = 0.75;
        var d = 25;
        var a = document.body.clientHeight * h - d;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        c.appendChild(b.domNode);
        b.resize(a);
        b.startup();
    },
    openWMI: function(param) {
    	var win = window.open(param,'_blank');
    },
    //for worklist feature item
    //Currently its for feature only.
    formatFTSIDWorkList: function(item, rowIndex, cell) {
    	
    	if (item.indexOf("FTS") != 0) {
    		return item;
    	}
    	
    			var urlWmI = "/irt/app/processStatus/feature/"+item;
    			
    			var imageWMI = "<span style='float: right;padding-right: 4px;padding-top: 4px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' " + " onClick=\"dashboard.openWMI('"+urlWmI+"')\"/></span>";
    			item = item + 
    			"<span style='float: right;padding-right: 4px;padding-top: 4px;'><img  src='/irt/resources/images/alert_noData.gif' height='16px;' width='16px;'  title='Status' style='cursor:pointer' " +
    			"onClick=\"dashboard.FeatureInfoListDialog('"+item+"')\" /></span>"+imageWMI;
    			
    		
    	//console.log("item for ftsid"+arr[0]);
    	return item;
    },
    /**
     * Load feature list..
     * @param {String } header - The list of column header titles to be shown
     * @param column - The column identifiers for the data coming from the server
     * @param fetchURL - The url to get the data from for the items
     * @return {null} returns nothing
     */
    loadItemList: function(header, column, fetchURL, title) {

        // Define the layouts
        //TODO: how do we handle success/failure over here?

        var headerList = header.split(",");
        var columnList = column.split(",");

        var layout = [];
        var layoutInternal = [];
        var layoutAll = [];
        var itemListIds = [];

        var width = Math.floor(100 / headerList.length) + "%";
        
        function formatDDTS(item, rowIndex, cell) {
        	//console.log('inside formatter'+item);        	
        		if (item && item !='') {
        			item = "<a href='http://wwwin-metrics/protected-cgi-bin/ddtsdisp.cgi?id="+item+"' target='_blank'>"+item+"</a>";
        		}
        	//console.log("item for ddts"+item);
        	return item;
        }
        
        function formatFTSID(item, rowIndex, cell) {
        	//console.log('inside formatter ftsid'+item);
        	//item has value ftsid|featurereleaseid
        	var arr = item.split("|");
        		if (item && item !='') {
        			var urlWmI = "/irt/app/processStatus/feature/"+arr[0];
        			
        			var imageWMI = "<span style='float: right;padding-right: 4px;padding-top: 4px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' " + " onClick=\"dashboard.openWMI('"+urlWmI+"')\"/></span>";
        			arr[0] = "<a href='#' style='text-decoration:none' href='#' onClick='dashboard.openRollBackWindow("+"\""+arr[0]+"\""+");return false;'>"+arr[0]+"</a> "+
        			"<span style='float: right;padding-right: 4px;padding-top: 4px;'><img  src='/irt/resources/images/alert_noData.gif' height='16px;' width='16px;'  title='Status' style='cursor:pointer' " +
        			"onClick=\"dashboard.FeatureInfoListDialog('"+arr[0]+"')\" /></span>"+imageWMI;
        			
        		}
        	//console.log("item for ftsid"+arr[0]);
        	return arr[0];
        }
        
        function formatFTSIDInternal(item, rowIndex, cell) {
        	//console.log('inside formatter ftsid'+item);
        	//item has value ftsid|featurereleaseid
        	var arr = item.split("|");
        		if (item && item !='') {
        			var urlWmI = "/irt/app/processStatus/feature/"+arr[0];
        			
        			var imageWMI = "<span style='float: right;padding-right: 4px;padding-top: 4px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' " + " onClick=\"dashboard.openWMI('"+urlWmI+"')\"/></span>";
        			arr[0] = "<a href='#' style='text-decoration:none' href='#' onClick='dashboard.openRollBackWindow("+"\""+arr[0]+"\""+");return false;'>"+arr[0]+"</a> ";
        			//WMI and Status icon not needed for internal features.
        			//"<span style='float: right;padding-right: 4px;padding-top: 4px;'><img  src='/irt/resources/images/alert_noData.gif' height='16px;' width='16px;'  title='Status' style='cursor:pointer' " +
        			//"onClick=\"dashboard.FeatureInfoListDialog('"+arr[0]+"')\" /></span>"+imageWMI;
        			
        		}
        	//console.log("item for ftsid"+arr[0]);
        	return arr[0];
        }
        
        //added by mbhambri for all features
        function formatFTSIDAll(item, rowIndex, cell) {
        	console.log('inside formatter ftsid'+item + '>>>>>>>>>>>' + itemListIds.length + ':::::::::::::::');
        	//item has value ftsid|featurereleaseid
        	var arr = item.split("|");
        	     for(var i = 0 ; i < itemListIds.length ; i++){
        	    	 console.log("itemListIds[i].ftsId " + itemListIds[i].ftsId);
        	    	 console.log("itemListIds[i].marketed" + itemListIds[i].marketed);
        	    	 if (itemListIds[i].ftsId == item){
        	    		 if(itemListIds[i].marketed == 'N'){
        	    			 if (item && item !='') {
        	         			var urlWmI = "/irt/app/processStatus/feature/"+arr[0];
        	         			
        	         			var imageWMI = "<span style='float: right;padding-right: 4px;padding-top: 4px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' " + " onClick=\"dashboard.openWMI('"+urlWmI+"')\"/></span>";
        	         			arr[0] = "<a href='#' style='text-decoration:none' href='#' onClick='dashboard.openRollBackWindow("+"\""+arr[0]+"\""+");return false;'>"+arr[0]+"</a> ";
        	         			//WMI and Status icon not needed for internal features.
        	         			//"<span style='float: right;padding-right: 4px;padding-top: 4px;'><img  src='/irt/resources/images/alert_noData.gif' height='16px;' width='16px;'  title='Status' style='cursor:pointer' " +
        	         			//"onClick=\"dashboard.FeatureInfoListDialog('"+arr[0]+"')\" /></span>"+imageWMI;
        	         			
        	         		} 
        	    		 }else{
        	    			 if (item && item !='') {
        	         			var urlWmI = "/irt/app/processStatus/feature/"+arr[0];
        	         			
        	         			var imageWMI = "<span style='float: right;padding-right: 4px;padding-top: 4px;'><img src='/irt/resources/images/pinPoint.png' height='16px;' width='16px;'  title='Where Am I' style='cursor:pointer' " + " onClick=\"dashboard.openWMI('"+urlWmI+"')\"/></span>";
        	         			arr[0] = "<a href='#' style='text-decoration:none' href='#' onClick='dashboard.openRollBackWindow("+"\""+arr[0]+"\""+");return false;'>"+arr[0]+"</a> "+
        	         			"<span style='float: right;padding-right: 4px;padding-top: 4px;'><img  src='/irt/resources/images/alert_noData.gif' height='16px;' width='16px;'  title='Status' style='cursor:pointer' " +
        	         			"onClick=\"dashboard.FeatureInfoListDialog('"+arr[0]+"')\" /></span>"+imageWMI;
        	         			
        	         		}
        	    			 
        	    		 }
        	    	 } 
        	     }
        	return arr[0];
        }
        
        
        
        //added by mbhambri for all features
        for (var i = 0; i < headerList.length; i++) {
        	
        	layoutAll[i] = {};
        	layoutAll[i].name = headerList[i];
        	layoutAll[i].field = columnList[i];
        	layoutAll[i].width = width;
            //console.log("headerList[i]"+headerList[i]);
            //console.log("columnList[i]"+columnList[i]);
            if (headerList[i] == 'DDTS') {
            	//console.log('inside header list formatter for ddts '+headerList[i]);
            	layoutAll[i].formatter = formatDDTS;
            }
            if (headerList[i] == 'FTS ID') {
            	//console.log('inside header list formatte for fts id '+headerList[i]);
            	layoutAll[i].formatter = formatFTSIDAll;
            }
            if (layoutAll[i].name.toLowerCase().indexOf('date') > 0) {
            	layoutAll[i].datatype = "date";
            	layoutAll[i].dataTypeArgs = {
                    datePattern: "mm/dd/yyyy"
                }
            }
            layoutAll[i].datatype = "string";
            layoutAll[i].autoComplete = true;
        }
        

        for (var i = 0; i < headerList.length; i++) {
        	layoutInternal[i] = {};
        	layoutInternal[i].name = headerList[i];
        	layoutInternal[i].field = columnList[i];
        	layoutInternal[i].width = width;
            //console.log("headerList[i]"+headerList[i]);
            //console.log("columnList[i]"+columnList[i]);
            if (headerList[i] == 'DDTS') {
            	//console.log('inside header list formatter for ddts '+headerList[i]);
            	layoutInternal[i].formatter = formatDDTS;
            }
            if (headerList[i] == 'FTS ID') {
            	//console.log('inside header list formatte for fts id '+headerList[i]);
            	layoutInternal[i].formatter = formatFTSIDInternal;
            }
            if (layoutInternal[i].name.toLowerCase().indexOf('date') > 0) {
            	layoutInternal[i].datatype = "date";
            	layoutInternal[i].dataTypeArgs = {
                    datePattern: "mm/dd/yyyy"
                }
            }
            layoutInternal[i].datatype = "string";
            layoutInternal[i].autoComplete = true;
        }
        
        //for Internal features
        for (var i = 0; i < headerList.length; i++) {
            layout[i] = {};
            layout[i].name = headerList[i];
            layout[i].field = columnList[i];
            layout[i].width = width;
            //console.log("headerList[i]"+headerList[i]);
            //console.log("columnList[i]"+columnList[i]);
            if (headerList[i] == 'DDTS') {
            	//console.log('inside header list formatter for ddts '+headerList[i]);
            	layout[i].formatter = formatDDTS;
            }
            if (headerList[i] == 'FTS ID') {
            	//console.log('inside header list formatte for fts id '+headerList[i]);
            	layout[i].formatter = formatFTSID;
            }
            if (layout[i].name.toLowerCase().indexOf('date') > 0) {
                layout[i].datatype = "date";
                layout[i].dataTypeArgs = {
                    datePattern: "mm/dd/yyyy"
                }
            }
            layout[i].datatype = "string";
            layout[i].autoComplete = true;
        }

        if (!(dashboard.featureGrid == null)) {
            dashboard.featureGrid.destroyRecursive(true);
	    //madhakul: new grids for own and internal features
            dashboard.featureGridOwn.destroyRecursive(true);
            dashboard.featureGridInt.destroyRecursive(true);
            dashboard.featureGridAll.destroyRecursive(true);//mbhambri
        }


        dashboard.featureGrid = new dojox.grid.EnhancedGrid({
            id: 'featureGrid',
            structure: layout,
            columnReordering: true,
            selectable: true,
            escapeHTMLInData: false,
            noDataMessage: '<span class="dojoxGridNoData"> No Data Available </span>',
            rowSelector: '20px',
            keepSelection: true,
            plugins: {
             filter: {
             // Show the closeFilterbarButton at the filter bar
             //closeFilterbarButton: true,
             // Set the maximum rule count to 5
             ruleCount: 5,
             // Set the name of the items
             itemsName: "items"
             },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             },
            selectionMode: "single"
        },
        document.createElement('div'));

	//madhakul: to show all owned features
        dashboard.featureGridOwn = new dojox.grid.EnhancedGrid({
            id: 'featureGridOwn',
            structure: layout,
            columnReordering: true,
            selectable: true,
            escapeHTMLInData: false,
            noDataMessage: '<span class="dojoxGridNoData"> No Data Available </span>',
            rowSelector: '20px',
            keepSelection: true,
            plugins: {
             filter: {
             // Show the closeFilterbarButton at the filter bar
             //closeFilterbarButton: true,
             // Set the maximum rule count to 5
             ruleCount: 5,
             // Set the name of the items
             itemsName: "items"
             },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             },
            selectionMode: "single"
        },
        document.createElement('div'));

	//madhakul: to show all internal features
        dashboard.featureGridInt = new dojox.grid.EnhancedGrid({
            id: 'featureGridInt',
            structure: layoutInternal,
            columnReordering: true,
            selectable: true,
            escapeHTMLInData: false,
            noDataMessage: '<span class="dojoxGridNoData"> No Data Available </span>',
            rowSelector: '20px',
            keepSelection: true,
            plugins: {
             filter: {
             // Show the closeFilterbarButton at the filter bar
             //closeFilterbarButton: true,
             // Set the maximum rule count to 5
             ruleCount: 5,
             // Set the name of the items
             itemsName: "items"
             },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             },
            selectionMode: "single"
        },
        document.createElement('div'));

      //mbhambri: to show both internal and owned features
        dashboard.featureGridAll = new dojox.grid.EnhancedGrid({
            id: 'featureGridAll',
            structure: layoutAll,
            columnReordering: true,
            selectable: true,
            escapeHTMLInData: false,
            noDataMessage: '<span class="dojoxGridNoData"> No Data Available </span>',
            rowSelector: '20px',
            keepSelection: true,
            plugins: {
             filter: {
             // Show the closeFilterbarButton at the filter bar
             //closeFilterbarButton: true,
             // Set the maximum rule count to 5
             ruleCount: 5,
             // Set the name of the items
             itemsName: "items"
             },
             pagination: {
             pageSizes: ["10", "25", "50", "All"],
             description: true,
             sizeSwitch: true,
             pageStepper: true,
             gotoButton: true,
             maxPageStep: 4,
             position: "bottom"
             }
             },
            selectionMode: "single"
        },
        document.createElement('div'));

        
        if (dashboard.cp4 == null) {
            dashboard.cp4 = new dijit.layout.ContentPane({
                title: title,
                content: " Loading ........",
                style: "overflow:hidden;height:100%;width:100%;margin-top:-8px;margin-left:-8px"
            });
        } else {
            dashboard.cp4.set("title", title);
        }
        var node = dashboard.cp4.domNode;
        while (node.childNodes.length > 0) {
            node.removeChild(node.firstChild);
        }

        dashboard.featureGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        dashboard.featureGridOwn.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        dashboard.featureGridInt.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        //mbhambri
        dashboard.featureGridAll.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');

        require(["dojo/request/xhr", "dojox/io/xhrPlugins"],
        function(xhr, plugins) {
            plugins.addCrossSiteXhr(dashboard.featureServicesBase);

        // We shouldnt really be doing this..
        // The ajax call will fail if the request is made to any other place than the host from which
        // this request originated.
        if (fetchURL == '/v1/dashboardfeatures') {
            //asahay
            //method is added in controller to handle this now.
            //fetchUrl will no longer be needed.
            fetchURL = "/irt/app/feature/getFeatureList";
            //fetchURL = dashboard.featureServicesBase + fetchURL;
            console.log(fetchURL);
        }
        //console.log('dashboard.currentlySelectedUserRole'+dashboard.currentlySelectedUserRole);
            xhr(fetchURL, {
                query: {
                    userid: dashboard.loggedInUserName,
                    applyFilter: "marketed"
                },
                preventCache: true,
                handleAs: "text",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

            }).then(function(result) {

                var dataList = jsonUtil.parse(result).items;
                //this will be use to format fts id
                itemListIds = dataList;
               
               
                //TODO: For now ignore release list.. Will happen when CISROMM comes in.
                var displayItems = {
                    identifier: 'id',
                    items: dataList
                };

                //Define the stores.
                var store = new dojo.data.ItemFileWriteStore({
                    data: displayItems
                });
                //dashboard.featureGrid.showFilterBar(true);
                dashboard.featureGrid.setStore(store);

                dashboard.featureGrid.selection.setSelected(0, true);
                //   dashboard.displaySelectionDetails(0);
                //console.log("hi");
            }, function(err) {
                console.log("Error in feature list table"+err);
                dashboard.showNotificationStatus("FAILURE", "Unable to load feature list table!");
                dashboard.featureGrid.showMessage('<span class="dojoxGridNoData"> Unable to load feature list table. Please refresh the page. </span>');
                
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
	    dashboard.featureGrid.startup();
            dashboard.featureGrid.resize();
	
	    //madhakul: Added for second sub tab
            xhr(fetchURL, {
                query: {
                    userid: dashboard.loggedInUserName,
		    applyFilter: "marketed",
                    role: dashboard.currentlySelectedUserRole
                },
                preventCache: true,
                handleAs: "text",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

            }).then(function(result) {

                var dataList = jsonUtil.parse(result).items;
                //this will be use to format fts id
                itemListIds = dataList;
               
               
                //TODO: For now ignore release list.. Will happen when CISROMM comes in.
                var displayItems = {
                    identifier: 'id',
                    items: dataList
                };

                //Define the stores.
                var store = new dojo.data.ItemFileWriteStore({
                    data: displayItems
                });
                //dashboard.featureGridOwn.showFilterBar(true);
                dashboard.featureGridOwn.setStore(store);

                dashboard.featureGridOwn.selection.setSelected(0, true);
                //   dashboard.displaySelectionDetails(0);
                //console.log("hi");
            }, function(err) {
                console.log("Error in feature list table"+err);
                dashboard.showNotificationStatus("FAILURE", "Unable to load feature list table!");
                dashboard.featureGridOwn.showMessage('<span class="dojoxGridNoData"> Unable to load feature list table. Please refresh the page. </span>');
                
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
	    dashboard.featureGridOwn.startup();
	    dashboard.featureGridOwn.resize();

	    //madhakul: Added for the third sub tab
            xhr(fetchURL, {
                query: {
                    userid: dashboard.loggedInUserName,
		    applyFilter: "internal",
                    role: dashboard.currentlySelectedUserRole
                },
                preventCache: true,
                handleAs: "text",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

            }).then(function(result) {

                var dataList = jsonUtil.parse(result).items;
                //this will be use to format fts id
                itemListIds = dataList;
               
               
                //TODO: For now ignore release list.. Will happen when CISROMM comes in.
                var displayItems = {
                    identifier: 'id',
                    items: dataList
                };

                //Define the stores.
                var store = new dojo.data.ItemFileWriteStore({
                    data: displayItems
                });
                //dashboard.featureGridInt.showFilterBar(true);
                dashboard.featureGridInt.setStore(store);

                dashboard.featureGridInt.selection.setSelected(0, true);
                //   dashboard.displaySelectionDetails(0);
                //console.log("hi");
            }, function(err) {
                console.log("Error in feature list table"+err);
                dashboard.showNotificationStatus("FAILURE", "Unable to load feature list table!");
                dashboard.featureGridInt.showMessage('<span class="dojoxGridNoData"> Unable to load feature list table. Please refresh the page. </span>');
                
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
	    dashboard.featureGridInt.startup();
            dashboard.featureGridInt.resize();
            
          //mbhambri: Added for the fourth sub tab
            xhr(fetchURL, {
                query: {
                    userid: dashboard.loggedInUserName,
		    applyFilter: "all",
                    role: dashboard.currentlySelectedUserRole
                },
                preventCache: true,
                handleAs: "text",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

            }).then(function(result) {

                var dataList = jsonUtil.parse(result).items;
                //this will be use to format fts id
                itemListIds = dataList;
               
                // alert(dojo.toJson(dataList));
                //TODO: For now ignore release list.. Will happen when CISROMM comes in.
                var displayItems = {
                    identifier: 'id',
                    items: dataList
                };

                //Define the stores.
                var store = new dojo.data.ItemFileWriteStore({
                    data: displayItems
                });
                //dashboard.featureGridAll.showFilterBar(true);
                dashboard.featureGridAll.setStore(store);

                dashboard.featureGridAll.selection.setSelected(0, true);
                //   dashboard.displaySelectionDetails(0);
                //console.log("hi");
            }, function(err) {
                console.log("Error in feature list table"+err);
                dashboard.showNotificationStatus("FAILURE", "Unable to load feature list table!");
                dashboard.featureGridAll.showMessage('<span class="dojoxGridNoData"> Unable to load feature list table. Please refresh the page. </span>');
                
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
	    dashboard.featureGridAll.startup();
            dashboard.featureGridAll.resize();
        })
        //madhakul: Now call function to render the required tabs and logic to form the sub tabs
	dashboard.featureGridTab();
        dashboard.resizeGrid();
    },
    //Using the id, retrieve the status details and show the table
    //this is not in use - will be updated or removed - asahay
    displaySelectionDetails: function(dataId) {
        require(["dojo/request/xhr"], function(xhr) {
            xhr("/irt/resources/json/featureDetails.json", {
                query: {
                    key1: dataId
                },
                handleAs: "text"
            }).then(function(result) {
                // Define the layouts
                var layout = [[
                        {
                            'name': 'Feature Detail',
                            'field': 'FeatureName',
                            'width': '40%'
                        },
                        {
                            'name': 'Value',
                            'field': 'Value',
                            'width': '40%'
                        }
                    ]];

                result = jsonUtil.parse(result);

                var data = {
                    identifier: 'id',
                    items: result
                };

                //Define the stores.
                if (dashboard.detailsGrid == null) {

                    dashboard.selectionDetailsStore = new dojo.data.ItemFileWriteStore({
                        data: data
                    });

                    dashboard.detailsGrid = new dojox.grid.EnhancedGrid({
                        id: 'detailsGrid',
                        store: selectionDetailsStore,
                        structure: layout,
                        columnReordering: true,
                        selectable: true,
                        escapeHTMLInData: false,
                        rowSelector: '20px',
                        keepSelection: true,
                        selectionMode: "single"
                    },
                    document.createElement('div'));

                    document.getElementById("StatusListTable").appendChild(dashboard.detailsGrid.domNode);
                    dashboard.detailsGrid.startup();
                } else {
                    //Just update the store..
                    selectionDetailsStore.data = data;
                    var x = 3;
                    //console.log("hi");
                }
            }, function(err) {
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });
        });
    },
    
    
    /**
     * Feature List Info dialog box for Actions Pending.
     */
    FeatureInfoListDialog: function(ftsid_arg) {
    	var ftsid = ftsid_arg.toString();
        var dialog = new dojox.widget.DialogSimple({
            title: ftsid+" - Actions Pending",
            style: "min-width:400px;height:auto; font-weight:bold",
            content: "<div></div>"
        });
        
        var div = dojo.create('div', {
        	id:"irt_featureinfo_buttonBarId",
        	'class':'buttonbar'	
        }, dialog.containerNode);
        
        var proc_id = "";
        var prc_view_url= window.location.origin + "/irt/app/processStatus/process/";
        
        var prc_view = dijit.byId('prc_view');
        if(!prc_view)
        prc_view = new dijit.form.Button({
            label: "Where am I?",
            id:"prc_view"
        });
        
        var noBtn = new dijit.form.Button({
            label: "Close",
            onClick: function() {
                dialog.hide();
            }
        });
        dojo.addClass(dijit.byId('prc_view').domNode, "dijitHidden");
        dojo.create(prc_view.domNode, {}, div);
        dojo.create(noBtn.domNode, {}, div);
        dialog.show();
        
        var layout_grid = [{name:"Task(s)", field:"taskName", width:"auto"},{name:"Role", field:"role", width:"auto"},{name:"UserID", field:"_item", width:"auto", formatter:function(item,id,rowIndx,cell){ var a = dijit.byId('irt_featureinfo_grid'); var b =  ""; var c = ""; if(a != null) {b = a.store.getValue(item, "taskName"); c = a.store.getValue(item, "actorId");} var d = encodeURI(b.toString().replace(/\&/g,"and")); return '<a href=\"mailto:'+ c.toString() + '@cisco.com?Subject='+d+'%20is%20Pending%20on%20Feature%20ID:'+ftsid+'\">'+ c.toString() +'</a>' }}];
        
        var featureInfo_grid = dijit.byId('irt_featureinfo_grid');
        if(!featureInfo_grid)
        featureInfo_grid = new dojox.grid.DataGrid({
        	id:"irt_featureinfo_grid",
        	structure:layout_grid,
        	noDataMessage: '<span class="dojoxGridNoData" style="font-size:13px; font-weight:normal; font-family:Arial;"> No Data Found </span>',
        	style:"width:450px; height:150px;",
        	rowsPerPage:10
        }, "irt_featureinfo_grid_holder"); 
        
        dojo.place(featureInfo_grid.domNode,dialog.containerNode,'first');
        featureInfo_grid.startup();
        featureInfo_grid._clearData();
        featureInfo_grid.resize();
   
        var xhr_url = "/irt/app/feature/tasks/"+ftsid
        var url_data = "";
        if(dashboard.pop_data != undefined)
            dojo.disconnect(dashboard.pop_data);

        if(!standby)
        var standby = new dojox.widget.Standby({target: "irt_featureinfo_grid", color:'black'});
    	standby.startup();
    	document.body.appendChild(standby.domNode);
        require(["dojo/request/xhr"], function(xhr) {	
        	standby.show();
            xhr(xhr_url, {
                query: {  
                },   method:"GET",
                handleAs: "json",
                preventCache: true
            }).then(function(data) {         	
            	var store_data = {
                		items:data.taskList
                		};
                var datastore = new dojo.data.ItemFileWriteStore({
                	data:store_data
                });
                proc_id = data.processInstanceId.toString();
                if(featureInfo_grid !== null){
                	featureInfo_grid.setStructure(layout_grid);
                	featureInfo_grid.setStore(datastore);
                	featureInfo_grid.resize();
                	}
                url_data = prc_view_url + proc_id;
                standby.hide();
                if(data != undefined && data != "" && data != null && data.taskList.length > 0)
                dojo.removeClass(dijit.byId('prc_view').domNode, "dijitHidden");
                connect_pop_data();
            }, function(err) {
            	dashboard.showNotificationStatus("FAILURE", "Unable to get Pending Actions for Feature ID: "+ftsid);
            	standby.hide(); 
            });
        });
        
       function connect_pop_data() {
        	dashboard.pop_data = dojo.connect(dojo.byId('prc_view'), 'onclick', function(){
            	window.open(url_data,'_blank');
            });
        }
        
    },
    
    
    /**
     * confirmation dialog box for create new feature.
     */
    createNewFeatureConfirmDialog: function() {
        //show loading icon
    	if(dashboard.featureCreationDialog == null){
    		dashboard.featureCreationDialog = new dojox.widget.DialogSimple({
    			title: "Create",
    			style: "width: 275px;height:auto; font-weight:bold",
    			content: "<div>Welcome to Feature Creation Workflow.<br/>" +
				" If you need help, please click <img src=\"../resources/auessome/images/misc/help.png\"> located <br/>on the individual forms or reach out to irtsupport@cisco.com. " +
				"</div><br/><div>Click \"YES\" to continue feature creation or \"NO\" to cancel.</div>"
    		});
    		//Creating div element inside dialog
    		var div = dojo.create('div', {
    			id:"buttonBarId"
    		}, dashboard.featureCreationDialog.containerNode);

    		var noBtn = new dijit.form.Button({
    			label: "NO",
    			onClick: function() {
    				dashboard.featureCreationDialog.hide();
    				dashboard.hideModalLoadingImage();
    				dojo.destroy(dashboard.featureCreationDialog);
    			}
    		});

    		var yesBtn = new dijit.form.Button({
    			label: "YES",
    			onClick: function() {
    				dashboard.showModalLoadingImage();
    				dashboard.createNewFeature();
    				dashboard.featureCreationDialog.hide();
    				dojo.destroy(dashboard.featureCreationDialog);
            }

    		});
    		//adding buttons to the div, created inside the dialog
    		dojo.create(yesBtn.domNode, {}, div);
    		dojo.create(noBtn.domNode, {}, div);
    		dojo.addClass("buttonBarId","buttonbar");
    	}
    	dashboard.featureCreationDialog.show();

    },
    /**
     * Create new Feature process
     */
    createNewFeature: function() {

    	//Need to hit different service for different roles.
    	var serviceUrl = "/irt/app/feature/create";
    	//For release pm role- only solution tracking is applicable
    	if (dashboard.currentlySelectedUserRole == 'RELEASE_PM') {
    	//	serviceUrl = "/irt/app/feature/createByRelPM";
    	} else if (dashboard.currentlySelectedUserRole == 'PRODUCT_MANAGER') {
    		serviceUrl = "/irt/app/feature/createByPDM";
    	}
    	serviceUrl = "/irt/app/feature/create";
        require(["dojo/request/xhr"], function(xhr) {

            xhr(serviceUrl, {
            	preventCache: true,
                query: {
                },
                handleAs: "json"
            }).then(function(data) {
                dashboard.reloadWorkListItems();
                dashboard.renderReleaselistTab();
                //we dont need to display notification for successful feature id creation
                //dashboard.showNotificationStatus(data.status, data.message);
                if (data.nextTaskId) {// if next task available.
                	dashboard.hideModalLoadingImage();
                    dashboard.formTitle = data.nextTaskName;
                    dashboard.featureId = data.nextTaskDisplayId;
                    dashboard.osTypeId = data.osType;
                    dashboard.openTaskForm(data.nextTaskId);
                } else {
					dashboard.hideModalLoadingImage();
                }
                //dashboard.hideModalLoadingImage();
            }, function(err) {
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to create new feature!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    
    
    /**
     * Bulk Clone Feature Action
     */
    bulkCloneFeatureAction: function(formData) {
    	dashboard.cloneDialog.hide();
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/feature/bulkClone", {
            	preventCache: true,
                query: {
                	refFtsId:formData.ftsIds,
                	osTypeId:formData.osType,
                	cloneType:formData.cloneType                	
                },
                handleAs: "json"
            }).then(function(data) {
                dashboard.reloadWorkListItems();
                //we dont need to display notification for successful feature id creation
                //dashboard.showNotificationStatus(data.status, data.message);
                if (data.nextTaskId) {// if next task available.
                	dashboard.hideModalLoadingImage();
                    dashboard.formTitle = data.nextTaskName;
                    dashboard.featureId = data.nextTaskDisplayId;
                    dashboard.openTaskForm(data.nextTaskId);
                } else {
					dashboard.hideModalLoadingImage();
                }
                //dashboard.hideModalLoadingImage();
            }, function(err) {
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to clone feature!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    /**
     * Clone Feature Action
     */
    cloneFeatureAction: function(formData) {
    	dashboard.cloneDialog.hide();
    	dashboard.showModalLoadingImage();
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/feature/clone", {
            	preventCache: true,
                query: {
                	refFtsId:formData.ftsId,
                	osTypeId:formData.osType,
                	cloneType:formData.cloneType                	
                },
                handleAs: "json"
            }).then(function(data) {
                dashboard.reloadWorkListItems();
                //we dont need to display notification for successful feature id creation
                //dashboard.showNotificationStatus(data.status, data.message);
                if (data.nextTaskId) {// if next task available.
                	dashboard.hideModalLoadingImage();
                    dashboard.formTitle = data.nextTaskName;
                    dashboard.featureId = data.nextTaskDisplayId;
                    dashboard.openTaskForm(data.nextTaskId);
                } else {
					dashboard.hideModalLoadingImage();
                }
                //dashboard.hideModalLoadingImage();
            }, function(err) {
                dashboard.hideModalLoadingImage();
                dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to clone feature!");
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    
    /**
     * Enable Release Action
     */
    enableReleaseAction: function(formData) {
    	
        require(["dojo/request/xhr"], function(xhr) {

            xhr("/irt/app/enableRelease/release/", {
            	preventCache: true,
                query: {
                	osType:formData.osType,
                	majorReleaseId:formData.majorReleaseId,
                	releaseNumberId:formData.releaseNumberId,
                	releaseName:formData.releaseName,
                	featureReviewDate:formData.featureReviewDate,
            		commitReviewDate:formData.commitReviewDate,
            		fnReviewDate:formData.fnReviewDate
                },
                handleAs: "json"
            }).then(function(data) {
            	if(dashboard.cloneDialog) {
            		dashboard.cloneDialog.hide();
            	
            		dashboard.reloadWorkListItems();
            		//we dont need to display notification for successful feature id creation
            		//dashboard.showNotificationStatus(data.status, data.message);
            		if (data.nextTaskId) {// if next task available.
            			dashboard.hideModalLoadingImage();
            			dashboard.formTitle = data.nextTaskName;
            			dashboard.featureId = data.nextTaskDisplayId;
            			dashboard.osTypeId = data.osType;
            			dashboard.openTaskForm(data.nextTaskId);
            		} else {
            			dashboard.hideModalLoadingImage();
            		}
            	} else {
            		//window.close();
            		//alert(JSON.stringify(data));
            	}
                //dashboard.hideModalLoadingImage();
            }, function(err) {
            	if(dashboard.cloneDialog) {
            		dashboard.cloneDialog.hide();
            		dashboard.hideModalLoadingImage();
            		dashboard.reloadWorkListItems();
            		dashboard.showNotificationStatus("FAILURE", "Unable to open task form.");
            	} else {
            		alertBox("Unable to submit data, please try again later.");
            	}
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            });


        });
    },
    /**
     * Show modal loading image
     */
    showModalLoadingImage: function() {
        dijit.byId("basicStandby1").show();
    },
    /**
     * Hide modal loading image
     */
    hideModalLoadingImage: function() {
        dijit.byId("basicStandby1").hide();
    },
    /**
     * Hide the popup dialog shown
     */
    hidePopupDialogBox: function() {
        dashboard.myDialog.hide();
    },
    /**
     * Delete a work item from the work item list table
     */
    deleteWorkItem: function(workItemId) {
        var store = dashboard.grid.store;
        var feat = store.getFeatures();
        //store.deleteItem(workItemId);
        var arr = store._arrayOfAllItems;
        var xx = -1;
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].id == workItemId) {
                xx = arr[i];
            }
        }
        store.deleteItem(xx);
    },

    /**
     * madhakul@cisco.com
     * This function is used to resize the feature grid as per window size or resize operation.
     */
    resizeGrid: function(e) {
	var b = dashboard.featureGrid;
        var h = 0.75;
        if( e != null ) {
            h = e;
        }
        var d = 25;
        var a = document.body.clientHeight * h - d;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        b.resize(a);
        //second grid
        b = dashboard.featureGridOwn;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        b.resize(a);
        //Third grid
        b = dashboard.featureGridInt;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        b.resize(a);
      //Fourth grid  mbhambri
        b = dashboard.featureGridAll;
        b.set("style", "height:" + a + "px");
        b.set("style", "margin-left:5px");
        b.set("style", "width:auto");
        b.resize(a);
    } ,

    /**
     * Reload the work item list
     */
    reloadWorkListItems: function() {
    	dashboard.grid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
    	dashboard.businessAdminGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
        require(["dojo/request/xhr", "dijit/Menu", "dijit/form/ComboButton", "dijit/MenuItem"], function(xhr) {
            xhr("/irt/app/listTasks", {
                query: {
                    role: dashboard.currentlySelectedUserRole
                },
                preventCache: true,
                handleAs: "text"
            }).then(function(result) {
                var data_list = [];
                var ba_admin_data_list = [];
                result = jsonUtil.parse(result);
               
                //data_list = result.list;
                for (var key in result) {
                    console.log(key + ': ' + result[key]);
                    if (key=='worklist') {                    	
                    	var temp1 = result[key];//['list'];
                    	data_list = temp1.list;                    	
                    } else if (key=='baWorklist') {                    	
                    	var temp2 = result[key];//.list;
                    	ba_admin_data_list = temp2.list;                    	
                    }
                }
              
                //for (var k=0; k < data_list.length; k++) {
                // data_list[k].action = '<a href="#" onclick="dashboard.publish('+data_list[k].id+')"> open </a>';
                //}

                var newData = {
                    identifier: 'id',
                    items: data_list
                };
                
                var newDataBA = {
                        identifier: 'id',
                        items: ba_admin_data_list
                 };


                //Define the stores.
                var newStore = new dojo.data.ItemFileWriteStore({
                    data: newData
                });
                //Define the stores.
                var newStoreBA = new dojo.data.ItemFileWriteStore({
                    data: newDataBA
                });
                if (dashboard.grid.save) {
                    dashboard.grid.save();
                }
         
                if (dashboard.businessAdminGrid.save) {
                	dashboard.businessAdminGrid.save();
                }

                dashboard.grid.store.close();
                dashboard.grid.setStore(newStore);
                dashboard.grid._refresh();
                dashboard.grid.setQuery();
                //for ba
                /*dashboard.businessAdminGrid.store.close();
                dashboard.businessAdminGrid.setStore(newStoreBA);
                dashboard.businessAdminGrid._refresh();
                dashboard.businessAdminGrid.setQuery();*/
                if (dashboard.isSwitchRole == true) {
	                if (dashboard.isBusinessAdmin == false) {
	                	console.log('inside remove ba admin tab child index '+dashboard.tc.getIndexOfChild(dashboard.cp3));
	                	if (dashboard.tc.getIndexOfChild(dashboard.cp3) != -1 ) {
	                		dashboard.tc.removeChild(dashboard.cp3);
	                	}
	                	
		           	} else {
		           		console.log('inside add ba admin tab child index '+dashboard.tc.getIndexOfChild(dashboard.cp3));
		           		if (dashboard.tc.getIndexOfChild(dashboard.cp3) == -1 ) {
		           			dashboard.tc.addChild(dashboard.cp3, 2);
		           			if(showDelegateFormForTask != null){
		           				dashboard.tc.selectChild(dashboard.cp3);
		           			}
		           		}
		           		
		           	}
	                dashboard.isSwitchRole = false;
                }
                //reload feature list everytime reload is called
                dashboard.buildRoleCustomizedView();
                //reload release list                
                dashboard.renderReleaselistTab();
                if (dashboard.isBusinessAdmin == true) {
                	//dashboard.renderBATab();
                }
                
            }, function(err) {
            	
            	dashboard.grid.showMessage('<span class="dojoxGridNoData"> Unable to load worklist. Please refresh the page. </span>');
            	dashboard.businessAdminGrid.showMessage('<span class="dojoxGridNoData"> Unable to load worklist. Please refresh the page. </span>');
            	dashboard.grid.showMessage('<span class="dojoxGridNoData"> No worklist items available </span>');
            	//dashboard.hideModalLoadingImage();
                //dashboard.reloadWorkListItems();
                dashboard.showNotificationStatus("FAILURE", "Unable to load worklist.");
                
                
                // Handle the error condition
            }, function(evt) {
                // Handle a progress event from the request if the
                // browser supports XHR2
            })            
        });

    },
    /**
     * Show notification status. Can be success, failure or info
     */
    showNonMarketingNotificationStatus: function(status, message) {
        dojo.byId("notificationMessageContainer").style.cssText = "opacity:0;";
        dojo.byId("notificationMessageDiv").innerHTML = message;

        var containerClass = "";
        var iconClass = "";
        if (status.toUpperCase() == "SUCCESS") {
            containerClass = "successWin";
            iconClass = "successIcon";
        } else if (status.toUpperCase() == "FAILURE") {
            containerClass = "alertWin";
            iconClass = "alertIcon";
        } else {
            containerClass = "infoWin";
            iconClass = "infoIcon";
        }

        dojo.byId("notificationContentDiv").className = containerClass;
        dojo.byId("notificationIconDiv").className = iconClass;
        dojo.style("notificationMessageContainer", "opacity", "0");
        var fadeArgs = {
            node: "notificationMessageContainer",
            duration: 5000,
            easing: dojo.fx.easing.expoOut
        };
        
        var fadeArgsInfo = {
                node: "notificationMessageContainer",
                duration: 10000,
                easing: dojo.fx.easing.expoOut
            };
        
        if (!dashboard.hideNotificationForInfo) {
	        dojo.fadeIn(fadeArgs).play();
	
	        setTimeout(function() {
	            dashboard.hideNotificationStatus()
	        }, 30000);
        } else {
        	dojo.fadeIn(fadeArgsInfo).play();
        	setTimeout(function() {
	            dashboard.hideNotificationStatus()
	        }, 10000); //10 seconds
        }
        dashboard.hideNotificationForInfo = false;
    },
    /**
     * Show notification status. Can be success, failure or info
     */
    showNotificationStatus: function(status, message) {
        dojo.byId("notificationMessageContainer").style.cssText = "opacity:0;";
        dojo.byId("notificationMessageDiv").innerHTML = message;

        var containerClass = "";
        var iconClass = "";
        if (status.toUpperCase() == "SUCCESS") {
            containerClass = "successWin";
            iconClass = "successIcon";
        } else if (status.toUpperCase() == "FAILURE") {
            containerClass = "alertWin";
            iconClass = "alertIcon";
        } else {
            containerClass = "infoWin";
            iconClass = "infoIcon";
        }

        dojo.byId("notificationContentDiv").className = containerClass;
        dojo.byId("notificationIconDiv").className = iconClass;
        dojo.style("notificationMessageContainer", "opacity", "0");
        var fadeArgs = {
            node: "notificationMessageContainer",
            duration: 5000,
            easing: dojo.fx.easing.expoOut
        };
        
        var fadeArgsInfo = {
                node: "notificationMessageContainer",
                duration: 10000,
                easing: dojo.fx.easing.expoOut
            };
        
        if (!dashboard.hideNotificationForInfo) {
	        dojo.fadeIn(fadeArgs).play();
	
	        setTimeout(function() {
	            dashboard.hideNotificationStatus()
	        }, 3000);
        } else {
        	dojo.fadeIn(fadeArgsInfo).play();
        	setTimeout(function() {
	            dashboard.hideNotificationStatus()
	        }, 10000); //10 seconds
        }
        dashboard.hideNotificationForInfo = false;
    },
    /**
     * Hide notification status. Usually called by the showNotificationStatus code after
     * a time out interval
     */
    hideNotificationStatus: function() {
        // dojo.style("notificationMessageContainer", "opacity", "1");
        var fadeArgs = {
            node: "notificationMessageContainer",
            duration: 5000,
            easing: dojo.fx.easing.expoOut
        };
        dojo.fadeOut(fadeArgs).play();
        dojo.byId("notificationMessageContainer").style.display='none';
        //IE has problems with opacity. So setting ivsibility to hidden here to hide it.
        require(["dojo/has", "dojo/_base/sniff"], function(has) {
            if (has("ie")) {
                dojo.style("notificationMessageContainer", "display", "none");
            }
        });
    },
    renderMenu: function(MenuBar, PopupMenuBarItem, Menu, MenuItem, DropDownMenu) {

          _HoverMixin = dojo.declare(null, {
        onItemHover: function(item){
                if(!this.isActive){
                    this._markActive();
                }
                this.inherited(arguments);
            }
        });
        
        ActiveMenuBar = dojo.declare([dijit.MenuBar, _HoverMixin], {});
        
        var pMenuBar = new ActiveMenuBar({popupDelay:5,id:"headerMenuBar"});

        var pSubMenu = new DropDownMenu({popupDelay:5});

        var popupMenuBarItem = new PopupMenuBarItem({
            label: "<i class='icon-home'></i> Home",
            popup: pSubMenu,
            id: 'menuBar'
        });

        pMenuBar.addChild(popupMenuBarItem);

        dashboard.pSubMenu2 = new DropDownMenu({popupDelay:5});
        dashboard.pSubMenu3 = new DropDownMenu({popupDelay:5});
        // Added by srajpal
      /*  dashboard.releaseMenuItem = new MenuItem({
            label: "Create Release",
            onClick: function() {
            	
                dashboard.createReleaseDialog();
            }
        });*/
        
        /*dashboard.trainMenuItem = new MenuItem({
            label: "Create Train",
            onClick: function() {
            	
                dashboard.createTrainDialog();
            }
        });
        
        dashboard.branchMenuItem = new MenuItem({
            label: "Create Branch",
            onClick: function() {
            	
                dashboard.createBranchDialog();
            }
        });*/
        //till here
        
        dashboard.menuItem1 = new MenuItem({
            label: "Create Feature",
            onClick: function() {            	
                dashboard.publish('createNewFeature');            	
            }
        });
        dashboard.menuItem2 = new MenuItem({
            label: "Clone Feature",
            onClick: function() {            	
            	dashboard.openCloneForm();          	
            }
        });
        dashboard.menuItem3 = new MenuItem({
            label: "Bulk Clone Feature",
            onClick: function() {            	
            	dashboard.openBulkCloneForm();           	
            }
        });
        dashboard.menuItem5 = new MenuItem({
        	label: "Create Non Marketed Feature",
        	onClick: function() {
        		dashboard.openCreateInternalForm();
        	}
            //label: " <span style='color: grey;'>Create Non Marketed Feature</span>"
        });
        
        dashboard.menuItemBulkUpdate = new MenuItem({
            label: "Bulk Update Feature(s)",
            onClick: function() {            	
            	dashboard.openBulkUpdateForm();           	
            }
        });
        
        dashboard.menuItem6 = new MenuItem({
            label: "Create Train",
            onClick: function() {            	
            	dashboard.createTrainDialog();  	
            }
        });
        dashboard.menuItem7 = new MenuItem({
            label: "Create Branch",
            onClick: function() {            	
            	dashboard.createBranchDialog();	
            }
        });

        dashboard.menuItem8 = new MenuItem({
                   label: "Create Release",
                   onClick: function() { 
                	dashboard.updateReleaseFlag = false;
                   	var serviceUrl = "/irt/view/release/jsp/selectReleaseType.jsp";
                   	        	 dashboard.createReleaseDialog(serviceUrl,"Create Release Option");
                   }
               });
        dashboard.menuItem9 = new MenuItem({
        	label: "Create Package",
        	onClick: function() {
        		dashboard.createPackageDialog();
        	}           
        });
        dashboard.menuItem10 = new MenuItem({
        	label: "Create Train Group",
        	onClick: function() {
        		dashboard.createTrainGroupDialog();
        	}           
        });
        dashboard.menuItem11 = new MenuItem({
            label: "Create Business Unit",
            onClick: function() {            	
            	dashboard.createBusinessUnitDialog();  	
            }
        });
        dashboard.menuItem12 = new MenuItem({
            label: "Create Image",
            onClick: function() {            	
            	//add call to create
            	var formType = "imageManagement";
        		var serviceUrl = "/irt/app/software/repostController/"+formType;
	        	 dashboard.createReleaseDialog(serviceUrl,"Select Software");
            }
        });
        dashboard.menuItem13 = new MenuItem({
        	label: "Clone Image",
        	onClick: function() {
        		//add call to create  
        	}           
        });
        
        dashboard.menuItem14 = new MenuItem({
            label: "Software Type Configuration",
            onClick: function() {            	
            	//add call to create         	
            }
        });
        dashboard.menuItem15 = new MenuItem({
        	label: "Setup Branch Restriction",
        	onClick: function() {
        		//add call to create  
        		dashboard.createBranchRestriction("setup"); 
        	}          
        });
        dashboard.menuItem16 = new MenuItem({
        	label: "Commit Request",
        	onClick: function() {
        		//add call to create 
					dashboard.createThrottleRequest();
        	}           
        });
        
       
		
		dashboard.menuItem17 = new MenuItem({
				label : "Create Branch Commit Request",
				onClick : function() {
					//add call to create  
					dashboard.createThrottleRequest();
				}
		});
		
		dashboard.menuItem18 = new MenuItem({
        	label: "Edit Image",
        	onClick: function() {
        		//add call to create  
        	}           
        });
		dashboard.menuItem19 = new MenuItem({
        	label: "Repost Image",
        	onClick: function() {
        		var formType = "repost";
        		var serviceUrl = "/irt/app/software/repostController/"+formType;
	        	 dashboard.createReleaseDialog(serviceUrl,"Select Software");
        		 
        		
        	}           
        });

        dashboard.menuItem20 = new MenuItem({
        	label: "Remove Image",
        	onClick: function() {
        		var formType = "remove";
        		var serviceUrl ="/irt/app/software/repostController/"+formType;
        		dashboard.createReleaseDialog(serviceUrl,"Select Software");
        	}           
        });
        
                //Do not display Create feature for roles other than DE,PdM and RelPM
       /* if (dashboard.currentlySelectedUserRole == 'DE_MANAGER' ||
    			dashboard.currentlySelectedUserRole == 'RELEASE_PM' ||
    			dashboard.currentlySelectedUserRole == 'PRODUCT_MANAGER') {        
        	dashboard.pSubMenu2.addChild(dashboard.menuItem2);
        
    	} 
        //Clone and BulkClone is for DE manager only
        if (dashboard.currentlySelectedUserRole == 'DE_MANAGER') {
        	dashboard.pSubMenu2.addChild(dashboard.menuItem2);    	
        	dashboard.pSubMenu2.addChild(dashboard.menuItem3);
        }*/
        
       //menu items for manage
        
        dashboard.menuItemManage1 = new MenuItem({
            label: "Branch",
            onClick: function() {              	
                // dashboard.openEnableReleaseForm();         
           	 // alert("done!");
           	  dashboard.updateBranchDialog();      
            	
            	//add call to create         	
            }
        });
        dashboard.menuItemManage2 = new MenuItem({
        	label: "Train",
        	onClick: function() {
        		//add call to create
        		console.log("onclick calling updateTrainDialog");
        		dashboard.updateTrainDialog();
        	}           
        });
        dashboard.menuItemManage3 = new MenuItem({
            label: "Release",
            onClick: function() {            	
            	//add call to create
            	console.log("onclick calling updateReleaseDialog");
        		dashboard.updateReleaseDialog();
            }
        });
        dashboard.menuItemManage4 = new MenuItem({
        	label: "Package",
        	onClick: function() {
        		//add call to create
        		dashboard.updatePackageDialog();
        	}           
        });
        dashboard.menuItemManage5 = new MenuItem({
            label: "Image",
            onClick: function() {            	
            	//add call to create
            	dashboard.displyMarketMatrix(1,104689);
            }
        });
        dashboard.menuItemManage6 = new MenuItem({
        	label: "Software Type Configuration",
        	onClick: function() {
        		//add call to create  
        	}           
        });
        dashboard.menuItemManage7 = new MenuItem({
        	label: "Approval & Submit Criteria",
        	onClick: function() {
        		//add call to create  
        		 dashboard.updateCriteriaDialog();
        		
        	}           
        });
        dashboard.menuItemManage8 = new MenuItem({
        	label: "Disable Branch Restriction",
        	onClick: function() {
        		//add call to create  
        		dashboard.createBranchRestriction("disable"); 
        	}           
        });
        
        dashboard.menuItemManage9 = new MenuItem({
        	label: "Branch Restriction Metadata",
        	onClick: function() {
        		//add call to create  
        		console.debug("branch restiction metadata update");
        		dashboard.updateBranchMetaDataDialog();
        	}           
        });
        
        pMenuBar.addChild(new PopupMenuBarItem({
            label: "<i class='icon-create'></i> Create",
            popup: dashboard.pSubMenu2,
            onMouseOver: function(){dashboard.pSubMenu2}
            
        }));
        pMenuBar.addChild(new PopupMenuBarItem({
            label: "<i class='icon-create'></i> Manage",
            popup: dashboard.pSubMenu3,
            onMouseOver: function(){dashboard.pSubMenu3}
            
        }));
        
        dashboard.milestoneMenu = new DropDownMenu({popupDelay:5});
        dashboard.menuItem4 = new MenuItem({
            label: "Enable Release(s)",
            onClick: function() {            	
                dashboard.openEnableReleaseForm();            	
            }
        });
        
        /*if (dashboard.currentlySelectedUserRole == 'RELEASE_PM') {
        	dashboard.milestoneMenu.addChild(dashboard.menuItem4);
    	}*/   
       
        //adding menu for release milestones
        pMenuBar.addChild(new PopupMenuBarItem({
            label: "<i class='icon-milestone'></i> Milestone Management",
            popup: dashboard.milestoneMenu
        }));
      //adding menu for reports
     
      var reportsMenu = new DropDownMenu({});
      reportsMenu.addChild(new MenuItem({
          label:"Feature Reports",
          onClick:function(){
        	  window.location.href='/irt/report.jsp?reportType=fr'},
      }));
      reportsMenu.addChild(new MenuItem({
    	  label:"Feature Score Cards",
    	  onClick:function(){
    		  window.location.href='/irt/report.jsp?reportType=fsc'
    	  },
      }));
      reportsMenu.addChild(new MenuItem({
    	  label:"Feature Task Status Reports",
    	  onClick:function(){
    		  window.location.href='/irt/report.jsp?reportType=ftsr'
    	  },
      }));
      

      pMenuBar.addChild(new PopupMenuBarItem({
        	label: "<i class='icon-report'></i> Report",
//            onclick:"location.href='/irt/report.jsp'",
            popup: reportsMenu
            }));
            
        
	//madhakul - added menu for support
       var supportMenu = new DropDownMenu({});
       supportMenu.addChild(new MenuItem({
           label: "Help and Support",
           onClick:function() {window.location.href="/irt/app/help.jsp";},
           iconClass:"noDisplay"
       }));
       pMenuBar.addChild(new PopupMenuBarItem({
           label: "<i class='icon-support'></i> Support",
           popup: supportMenu
       }));
        pMenuBar.placeAt("navMenu");
        pMenuBar.startup();

        var elem = dojo.byId('menuBar');

        elem.setAttribute("onclick", "location.href='/irt/app/landing'");
    },
    
    renderRolesDropDown: function(DropDownSelect,role) {
        var elem = document.getElementById("userRoles");


        var roles = dashboard.rolesListForCustomization;
        var options = [];
        console.log('rendering drop down with default set to'+role);
        for (var i = 0; i < roles.length; i++) {
            //options[i] = new Option(roles[i], roles[i]);
        	if (role == options[i]) {
        		options[i] = {id: roles[i], label: roles[i].split('_').join(' '), selected: true};
        	} else {
                options[i] = {id: roles[i], label: roles[i].split('_').join(' ')};
        	}
        }

        if(dashboard.currentlySelectedUserRole == null) {
        	if (role == null || role=='null') {
        		dashboard.currentlySelectedUserRole = roles[0];
        	} else {
        		dashboard.currentlySelectedUserRole = role;
        	}
        }
        dashboard.setCurrentActiveRole(dashboard.currentlySelectedUserRole);

        // dropDown.addOption(options);
        var store = new dojo.store.Memory({
            data: options
        });

        var os = new dojo.data.ObjectStore({objectStore: store});
        var dropDown = new DropDownSelect({
            store: os,
            value:dashboard.currentlySelectedUserRole
        }, elem );
        dropDown.startup();

        require(["dojo/on"], function(on) {
            var handle = on(dropDown, "change", function(e) {
                require(["dojo/_base/connect"], function(connect) {
                    connect.publish("roleChangeMessage", [{
                            item: e
                        }]);
                });

            });

        });
        dashboard.buildRoleCustomizedView();

    },
    /**
     * At the end of the function, the following will be defined.
     * dashboard.rolesListForCustomization - List of roles for the user
     * dashboard.attributesListForCustomization[] - each element in the array will contain
     *  a json object for role attributes
     * @returns {undefined}
     */
    parseRolesList: function() {
        var xx = dashboard.tmpRolesStringForCustomization.replace("[", "");
        xx = xx.replace("]", "");
        dashboard.rolesListForCustomization = xx.split("!!");

        var yy = dashboard.tmpAttributesStringForCustomization.split("!!");
        for (var i = 0; i < yy.length; i++) {
            var tmp = dashboard.rolesListForCustomization[i];
            dashboard.attributesListForCustomization[tmp] = {};
            var zz = yy[i]; // contains customizations for each roles
            zz = zz.split("||"); // contains list of properties in the format x = y.

            var holder = null;
            for (var dd = 0; dd < zz.length; dd++) {
                holder = zz[dd].split("=");

                switch (holder[0])
                {
                    case "role":
                        console.log("role");
                        dashboard.attributesListForCustomization[tmp].role = holder[1];
                        break;

                    case "itemsListHeader":
                        console.log("itemsListHeader");
                        dashboard.attributesListForCustomization[tmp].itemsListHeader = holder[1];
                        break;

                    case "itemsDisplayColumnList":
                        console.log("itemsDisplayColumnList");
                        dashboard.attributesListForCustomization[tmp].itemsDisplayColumnList = holder[1];
                        break;

                    case "itemsDisplayColumnsHeaderList":
                        console.log("itemsDisplayColumnsHeaderList");
                        dashboard.attributesListForCustomization[tmp].itemsDisplayColumnsHeaderList = holder[1];
                        break;


                    case "itemsFetchURL":
                        console.log("itemsFetchURL");
                        dashboard.attributesListForCustomization[tmp].itemsFetchURL = holder[1];
                        break;
                    default :
                        console.log("none matched for " + holder[1]);

                }
            }
        }



    },
    buildRoleCustomizedView: function() {
        var role = dashboard.currentlySelectedUserRole;
        console.log("role:"+dashboard.currentlySelectedUserRole);
        //console.log("dashboard.attributesListForCustomization:"+dashboard.attributesListForCustomization);
        var items = dashboard.attributesListForCustomization[role];
        //document.getElementById("itemListHeader").innerHTML = items.itemsListHeader;
        dashboard.loadItemList(items.itemsDisplayColumnsHeaderList,
                items.itemsDisplayColumnList,
                items.itemsFetchURL,
                items.itemsListHeader);
    },
    processRoleChange: function(message) {
        //dashboard.currentlySelectedUserRole = message.item;
        if(message.item == "CFN_SME" || message.item == "RELEASE_PM" ) {
            if( dashboard.tc.getIndexOfChild(dashboard.cp5) == -1 ) {
                dashboard.tc.addChild(dashboard.cp5);
            }
        } else {
	    if( dashboard.tc.getIndexOfChild(dashboard.cp5) != -1 ) {
            	dashboard.tc.removeChild(dashboard.cp5);
	    }
        }
        dashboard.setCurrentActiveRole(message.item);
        console.log('inside processRoleChange'+message.item);
        //dashboard.reloadWorkListItems();
        //dashboard.loadRoleBasedItems(message.item);
        //dashboard.buildRoleCustomizedView();
    },
    loadRoleBasedItems: function(itemId) {

    },

    businessAdmin:function(){
        
        require(["dojo/request/xhr"], function(xhr) {

              xhr("/irt/app/isBusinessAdmin", {
                  query: {                      
                  },   method:"GET",
                  handleAs: "json",
                  preventCache: true
              }).then(function(data) {
            	  console.log("isBusinessAdmin"+data);
              	if (data == true) {
              		dashboard.isBusinessAdmin = true;
              		//console.log("dashboard.isBusinessAdmin"+dashboard.isBusinessAdmin);
              	} else {
              		dashboard.isBusinessAdmin = false;
              		//console.log("dashboard.isBusinessAdmin"+dashboard.isBusinessAdmin);
              	}
              }, function(err) {
              	dashboard.showNotificationStatus("FAILURE", "Unable to get Business Admin role information.");
              	
              }, function(evt) {
                  // Handle a progress event from the request if the
                  // browser supports XHR2
              });
         });

   },
   

    setCurrentActiveRole:function(role){
          dashboard.currentlySelectedUserRole = role;
          if (dashboard.grid != null) {
        	  dashboard.grid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
              if (!(dashboard.featureGrid == null)) {
            	  dashboard.featureGrid.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
              }
              if (!(dashboard.featureGridOwn == null)) {
            	  dashboard.featureGridOwn.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
              }
              
              if (!(dashboard.featureGridInt == null)) {
            	  dashboard.featureGridInt.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
              }
              
              if (!(dashboard.featureGridAll == null)) {
            	  dashboard.featureGridAll.showMessage('<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>');
              }
          }
           /*Added by vutnal to set role to HttpSession in app*/
          require(["dojo/request/xhr"], function(xhr) {

                xhr("/irt/app/switchRole/" + dashboard.currentlySelectedUserRole, {
                    query: {
                        random: Math.random() * 1000000000
                    },   method:"POST",
                    handleAs: "json",
                    preventCache: true
                }).then(function(data) {
                	//business admin call can be clubbed with setCurrentActive role too but this would need a change.
                	dashboard.businessAdmin();
                	dashboard.isSwitchRole = true;
                	dashboard.permissionListIds=data;
                	console.log("permisson list"+data);
                	var menuItemsCreateArray = [dashboard.menuItem1,dashboard.menuItem2,dashboard.menuItem3,dashboard.menuItem5,dashboard.menuItem6,
                			dashboard.menuItem7,dashboard.menuItem8,dashboard.menuItem9,dashboard.menuItem10,dashboard.menuItem11,dashboard.menuItem12,dashboard.menuItem13,
                			dashboard.menuItem14,dashboard.menuItem15,dashboard.menuItem16,dashboard.menuItem17,dashboard.menuItem18,
                			dashboard.menuItem19,dashboard.menuItem20];
                 	var menuItemsManageArray = [dashboard.menuItemManage1,dashboard.menuItemManage2,dashboard.menuItemManage3,dashboard.menuItemManage4,dashboard.menuItemManage5,
                			dashboard.menuItemManage6,dashboard.menuItemManage7,dashboard.menuItemManage8,dashboard.menuItemManage9];
                			
           
                	if (data.length >= 0) { //dashboard.menuItem5
                		//remove all menu items and then add them back based on permission list
                /*		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem7) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem7);
                     	}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem8) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem8);
                     	}
                		//if (dashboard.pSubMenu2.getIndexOfChild(dashboard.releaseMenuItem) != -1) {
                     	//	dashboard.pSubMenu2.removeChild(dashboard.releaseMenuItem);
                     	//}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem1) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem1);
                     	}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem2) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem2);
                     	}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem3) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem3);
                     	}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItem5) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItem5);
                     	}
                        
                		if (dashboard.milestoneMenu.getIndexOfChild(dashboard.menuItem4) != -1) {
                     		dashboard.milestoneMenu.removeChild(dashboard.menuItem4);
                     	}
                		if (dashboard.pSubMenu2.getIndexOfChild(dashboard.menuItemBulkUpdate) != -1) {
                     		dashboard.pSubMenu2.removeChild(dashboard.menuItemBulkUpdate);
                     	} */
                    
                		//enable release will go in manage option. for now no changes
                		if (dashboard.milestoneMenu.getIndexOfChild(dashboard.menuItem4) != -1) {
                     		dashboard.milestoneMenu.removeChild(dashboard.menuItem4);
                     	}                    
                    
                		for (var arr=0; arr < menuItemsCreateArray.length;arr++  ) {
                			if (dashboard.pSubMenu2.getIndexOfChild(menuItemsCreateArray[arr]) != -1) {
                         		dashboard.pSubMenu2.removeChild(menuItemsCreateArray[arr]);
                         	}
                		}
                		for (var arr1=0; arr1 < menuItemsManageArray.length;arr1++  ) {
                			if (dashboard.pSubMenu3.getIndexOfChild(menuItemsManageArray[arr1]) != -1) {
                         		dashboard.pSubMenu3.removeChild(menuItemsManageArray[arr1]);
                         	}
                		}
                            }

                   /**	
                    17	Commit Request
                	16	Branch Restriction
                	15	software Type configuration                	
                	14	Clone Image
                	13	Image
                	10	Create Train Group
                	11	Create Business Unit
                	12	Create Package
                	1	Create Feature
                	2	Clone Feature
                	3	Bulk Clone
                	4	Enable Release
                	5	PERMS_IRT_ADMIN
                	6	Create Internal Feature
                	7	Create Train
                	8	Create Branch
                	9	Create Release
                	
                	menuItem6 - Create Train
					menuItem7 - Create Branch
					menuItem8 - Create release
					menuItem9 - Create Package
					menuItem10 - Create Train Group
					menuItem11 - Create Business Unit
					menuItem12 - Create Image
					menuItem13 - Clone Image
					menuItem14 - Software Type Configuration
					menuItem15 - Setup New Throttle
					menuItem16 - Commit Request
					
					
					menuItemManage1 -  Branch
					menuItemManage2 -  Train
					menuItemManage3 -  Release
					menuItemManage4 -  Package
					menuItemManage5 -  Image
					menuItemManage6 -  Software Type Configuration
					menuItemManage7 -  Approval & Submit Criteria
                	menuItemManage8 -  Disable Branch Restriction
                	menuItemManage9 -  Branch Restriction Metadata
                	**/

                  	 for (i = 0; i < data.length; i++) {
                  		 //console.log("permission ids"+data[i]);
                  		
                  		if (data[i] == 1) { // 1 is for create feature	                     	
	                     		dashboard.pSubMenu2.addChild(dashboard.menuItem1);	                     
                  		 } else if (data[i] == 2) { // 2 is for clone                  			
                        		dashboard.pSubMenu2.addChild(dashboard.menuItem2);                        	
                  		 } else if (data[i] == 3) { // 3 is for bulk clone                  			
                        		dashboard.pSubMenu2.addChild(dashboard.menuItem3);                        	
                  		 } else if (data[i] == 6) { // 6 is for create internal features                  			
                        		dashboard.pSubMenu2.addChild(dashboard.menuItem5);                        	
                  		 } else if (data[i] == 4) { // 4 is for enable release                  			
                        		dashboard.milestoneMenu.addChild(dashboard.menuItem4);                        	
                                    }else if (data[i] == 20) { // 20 is for bulk update features                   

                                    dashboard.pSubMenu2.addChild(dashboard.menuItemBulkUpdate);                         
                                                     
              		 } else if (data[i] == 7) { // 7 is for create train                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem6); 
                    		//manage train
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage2); 
                  		 }  else if (data[i] == 8) { // 8 is for create branch                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem7);
                    		//manage branch
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage1);     
                  		 }  else if (data[i] == 9) { // create release                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem8);     
                    		//manage release
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage3);     
                  		 }  else if (data[i] == 10) { // create train group                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem10);                        	
                  		 }  else if (data[i] == 11) { // create business unit                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem11);                        	
                  		 }  else if (data[i] == 12) { // create package                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem9);    
                    		//manage package
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage4); 
                  		 }  else if (data[i] == 13) { // create image                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem12);
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem18);
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem19);
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem20);
                    		//manage image
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage5);     
                  		 }  else if (data[i] == 14) { // clone image                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem13);                        	
                  		 }  else if (data[i] == 15) { // software Type configuration                			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem14);       
                    		//manage software type configuration
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage6); 
                  		 }  else if (data[i] == 16) { // Branch Restriction                  			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem15);                      		   
                    		//manage branch metadata
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage9); 
                    		//manage branch commit criteria
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage7);
                    		
                  		 }  else if (data[i] == 17) { // Commit request                 			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem16);                        	
                  		 }else if (data[i] == 18) { // Commit request                 			
                    		dashboard.pSubMenu3.addChild(dashboard.menuItemManage8);                        	
                  		 }else if (data[i] == 19) { // Commit request                 			
                    		dashboard.pSubMenu2.addChild(dashboard.menuItem17);                        	
                  		 }
                           
                  	 }
                	
                	dashboard.reloadWorkListItems();
                    //dashboard.loadRoleBasedItems(message.item);
                    //dashboard.buildRoleCustomizedView();
                }, function(err) {
                	dashboard.showNotificationStatus("FAILURE", "Unable to set role.");
                	dashboard.grid.showMessage('<span class="dojoxGridNoData"> Unable to set role. Please refresh the page. </span>');
                	//refresh the page, this will take the users to log in page
                	window.location.href = '/irt/app/landing';
                }, function(evt) {
                    // Handle a progress event from the request if the
                    // browser supports XHR2
                });
           });

     },
    onSearchClick: function() {
        var query = dojo.byId('searchInput').value;
        query=encodeURIComponent(query);
        window.open(dashboard.searchUrl + "?q=" + query, "_blank");
    },
}

//JSON Util.

jsonUtil = {
    /**
     * JSON escape chars.
     * @private
     */
    _m: {
        '\b': '\\b',
        '\t': '\\t',
        '\n': '\\n',
        '\f': '\\f',
        '\r': '\\r',
        '"': '\\"',
        '\\': '\\\\'
    },
    /**
     * JSON parsor.
     * @private
     */
    _s: {
        /** @ignore */
        'boolean': function(x) {
            return String(x);
        },
        /** @ignore */
        number: function(x) {
            return isFinite(x) ? String(x) : null;
        },
        /** @ignore */
        string: function(x) {
            if (/["\\\x00-\x1f]/.test(x)) {
                x = x.replace(/([\x00-\x1f\\"])/g, function(a, b) {
                    var c = jsonUtil._m[b];
                    if (c) {
                        return c;
                    }
                    c = b.charCodeAt();
                    return '\\u00' +
                            Math.floor(c / 16).toString(16) +
                            (c % 16).toString(16);
                });
            }
            return '"' + x + '"';
        },
        /** @ignore */
        object: function(x) {
            if (x) {
                var a = [], b, f, i, l, v;
                if (x instanceof Array) {
                    a[0] = '[';
                    l = x.length;
                    for (i = 0; i < l; i += 1) {
                        v = x[i];
                        f = jsonUtil._s[typeof v];
                        if (f) {
                            v = f(v);
                            if (typeof v == 'string') {
                                if (b) {
                                    a[a.length] = ',';
                                }
                                a[a.length] = v;
                                b = true;
                            }
                        }
                    }
                    a[a.length] = ']';
                } else if (typeof x.hasOwnProperty === 'function') {
                    a[0] = '{';
                    for (i in x) {
                        if (x.hasOwnProperty(i)) {
                            v = x[i];
                            f = jsonUtil._s[typeof v];
                            if (f) {
                                v = f(v);
                                if (typeof v == 'string') {
                                    if (b) {
                                        a[a.length] = ',';
                                    }
                                    a.push(jsonUtil._s.string(i), ':', v);
                                    b = true;
                                }
                            }
                        }
                    }
                    a[a.length] = '}';
                } else {
                    return null;
                }
                return a.join('');
            }
            return null;
        }
    },
    /**
     * Stringify a JavaScript value, producing JSON text.
     *
     * @param {Object} v A non-cyclical JSON object.
     * @return {boolean} true if successful; otherwise, false.
     */
    stringify: function(v) {
        var f = jsonUtil._s[typeof v];
        if (f) {
            v = f(v);
            if (typeof v == 'string') {
                return v;
            }
        }
        return null;
    },
    /**
     * Parse a JSON text, producing a JavaScript object.
     *
     * @param {String} text The string containing JSON text.
     * @return {boolean} true if successful; otherwise, false.
     */
    parse: function(text) {
        try {
            return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                    text.replace(/"(\\.|[^"\\])*"/g, ''))) && eval('(' + text + ')');
        } catch (e) {
            return false;
        }
    }
};

