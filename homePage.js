var landing = {
	currentWidgets : [],
	searchUrl : "",
	allWidgetsList : ["Search", "WorkList", "BusinessAdmin", "Cca"],
	allRolesList : ["DE_MANAGER", "CFN_SME", "PRODUCT_MANAGER", "TECH_WRITER", "RELEASE_PM", "DEV_TEST_MANAGER"],
	widgetsForRole : {
		GUEST : ["Search"],
		DE_MANAGER : ["WorkList", "Search"],
		CFN_SME : ["WorkList", "Search"],
		PRODUCT_MANAGER : ["WorkList", "Search"],
		TECH_WRITER : ["WorkList", "Search"],
		RELEASE_PM : ["WorkList", "Search"],
		DEV_TEST_MANAGER : ["WorkList", "Search"]
	},
	defaultWidgetsForRole : {
		GUEST : ["Search"],
		DE_MANAGER : ["WorkList", "Search"],
		CFN_SME : ["WorkList", "Search"],
		PRODUCT_MANAGER : ["WorkList", "Search"],
		TECH_WRITER : ["WorkList", "Search"],
		RELEASE_PM : ["WorkList", "Search"],
		DEV_TEST_MANAGER : ["WorkList", "Search"],
	},
	userPref : {},
	widgetsTitle : {
		WorkList : "My Actions",
		Search : "Search",
		My_Team : "My Team",
		BusinessAdmin : "Business Admin",
		Cca : "CCA Commit Criteria"
	},
	addWidgetDialog : null,
	widgetContainer : null,
	layouter : null,
	userId : "",
	userRoles : [],
	currentRole : "",
	rolesSelect : undefined,
	pendingRequest : "",
	baAdminLi : null,
	isBusinessAdmin : false,
	myDialog : null,
	landingReady : function () {
		require(["dojo/ready", "dojox/widget/DialogSimple", "dijit/form/Button"], function (d, c, b) {
			d(function () {
				if (landing.myDialog == null) {
					landing.myDialog = new dojox.widget.DialogSimple({
							title : "",
							content : "",
							executeScripts : true,
							loadingMessage : '<div class="loadingWin"><div class="loadingIcon"><img width="16" height="16" src="/irt/resources/images/loading_ani.gif"></div><div class="loadingMessage"><p>Loading</p></div>',
							style : "width: auto;top:35px;"
						});
				}
			});
		});
		landing.userId = dashboard.loggedInUserName;
		landing.userRoles = dashboard.rolesListForCustomization;
		dojo.declare("myGrid", [dojox.layout.GridContainer], {
			setColumns : function () {
				this.inherited(arguments);
			},
			addChild : function () {
				this.inherited(arguments);
			}
		});
		landing.createRoleList();
		landing.widgetContainer = new myGrid({
				id : "widgetCnt",
				nbZones : 2,
				region : "center",
				opacity : "0.3",
				mode : "left",
				withHandles : true,
				dragHandleClass : "dijitTitlePaneTitle",
				hasResizableColumns : false,
				style : "width:765px;height:95%;float:left;background:transparent;overflow:auto"
			}, dojo.byId("grid"));
		landing.layouter = landing.LayoutManager();
		landing.layouter.init();
		landing.widgetContainer.startup();
		if (landing.getInitRole() === "GUEST") {
			landing.currentWidgets = landing.widgetsForCurrentRole("GUEST");
			landing.createWidgetContainer("GUEST");
			landing.initLayout("GUEST");
			landing.getRoleSelect().placeAt("guestSelect");
			guestDialog.show();
		} else {
			landing.createWidgetContainer(landing.getInitRole());
			landing.currentWidgets = landing.widgetsForCurrentRole(landing.getInitRole());
			landing.initLayout(landing.getInitRole());
			landing.setCurrentActiveRole(landing.getInitRole());
		}
		if (landing.pendingRequest.length !== 0) {
			var a = "Your request for access to the <b>" + landing.pendingRequest[0].replace(/_/, " ") + "</b> is pending approval. Please ask your manager to approve it before requesting for additional roles.";
			landing.getRoleSelect().disabled = true;
			dojo.byId("pendingRequest1").innerHTML = a;
			dojo.byId("pendingRequest2").innerHTML = a;
			dijit.byId("guestDialogSubmit").set("disabled", true);
			dijit.byId("requestAccessSubmit").set("disabled", true);
		}
		dojo.connect(requestAccessDialog, "onShow", function () {
			landing.getRoleSelect().placeAt("requestAccessSelect");
		});
	},
	LayoutManager : function () {
		return {
			xPos : 0,
			yPos : 0,
			columns : 2,
			widgetsPtr : 0,
			posArr : new Array(),
			init : function () {
				for (var a = 0; a < this.columns; a++) {
					this.posArr[a] = 0;
				}
			},
			setPosition : function () {
				if (this.widgetsPtr >= this.columns) {
					this.widgetsPtr = 0;
				}
				this.xPos = this.widgetsPtr;
				this.yPos = this.posArr[this.widgetsPtr];
				var a = this.columns;
				while (a != -1) {
					if (this.posArr[(a)] <= this.posArr[this.widgetsPtr]) {
						this.xPos = a;
						this.widgetsPtr = a;
					}
					a--;
				}
				this.posArr[this.widgetsPtr] = (this.posArr[this.widgetsPtr] + 1);
			},
			getPosition : function () {
				return [this.xPos, this.yPos];
			},
			updateDisplayPosition : function () {
				this.setPosition();
				var a = (this.widgetsPtr - 1);
				if (a == -1) {
					this.widgetsPtr++;
				} else {
					while (a != -1) {
						if (this.posArr[(a)] < this.posArr[this.widgetsPtr]) {
							this.widgetsPtr++;
						}
						a--;
					}
				}
				return this.getPosition();
			}
		};
	},
	getContent : function (b) {
		var a = "";
		if (b == "Notifications") {
			a = '<div class="widget-window"><div class="content "> <label class="label label-info"> You have 4 notification</label> <ul>' + "<li>Approve feature for IOS XE</li>" + "<li>Create feature for IOS</li>" + "</ul>" + '<a href="featureManagement" title="More"> More >> </a> </div>' + "</div></div>";
		} else {
			if (b == "Approvals") {
				a = '<div class="widget-window"><div class="content "> <label class="label label-info"> You have 10 approvals pending</label> <ul>' + "<li>Approve feature for IOS XE</li>" + "</ul>" + '<a href="featureManagement" title="More"> More ></a> </div>' + "</div></div>";
			} else {
				if (b == "Create_Feature") {
					a = '<div><div class="content "> <label class="label label-info"> Creating a feature has been made easier</label>' + '<div style="padding-top:15px;padding-left:10px;">You can create a feature by clicking <a href="featureManagement">here</a></div>' + "</div></div>";
				} else {
					if (b == "Clone_Feature") {
						a = '<div><div class="content "> <label class="label label-info"> Clone_Feature</label>' + '<div style="padding-top:15px;padding-left:10px;">You can clone a feature <a href="featureManagement">here</a></div>' + "</div></div>";
					} else {
						if (b == "Business_Intelligence") {
							a = '<div><div class="content "> <label class="label label-info"> IRT Business Intelligence</label>' + '<div style="padding-top:15px;padding-left:10px;">Click <a href="featureManagement">here</a> for more</div>' + "</div></div>";
						} else {
							if (b == "Pending Requests") {
								a = "<div> <p> Your request for access to<b> " + landing.pendingRequest + " </b>role is not yet approved by your manager on onramp.<br/>" + "</p></div>";
							} else {
								if (b == "BusinessAdmin") {
									a = '<div style="height:230px"><div id="businessAdminDiv" style="height:200px;">' + '<div id="businessAdminGrid"></div>' + "</div>" + '<div style="padding-top:8px;"><a href="featureManagement" style="color:#0088c2;font-size:12px;">More >> </a></div>' + "</div>";
								} else {
									if (b == "My_Team") {
										a = '<div id="myTeamTree" style:"height:200px"></div>';
									} else {
										if (b == "Feature_List") {
											a = '<div style="height:230px;"><div id="featureListDiv" style="height:200px;">' + '<div id="featureListGrid"></div>' + "</div>" + '<div style="padding-top:8px;"><a href="featureManagement?showFeatureList=\'Y\'" style="color:#0088c2;font-size:12px;">More >> </a></div>' + "</div>";
										} else {
											if (b === "Calendar") {
												a = '<div data-dojo-type="dijit/Calendar">    <script type="dojo/method" data-dojo-event="onChange" data-dojo-args="value">        require(["dojo/dom", "dojo/date/locale"], function(dom, locale){            dom.byId(\'formatted\').innerHTML = locale.format(value, {formatLength: \'full\', selector:\'date\'});        });    <\/script></div><p id="formatted"></p>';
											} else {
												if (b == "WorkList") {
													a = '<div style="height:230px;"><div id="workListDiv" style="height:200px;">' + '<div id="workListGrid"></div>' + "</div>" + '<div style="padding-top:8px;"><a href="featureManagement" style="color:#0088c2;font-size:12px;">More >> </a></div>' + "</div>";
												} else {
													if (b == "Search") {
														a = '<div style="height:230px;padding-top:20px;"><div id="searchDiv" style="height:200px;">' + '<div style="padding-bottom:15px;border: solid 1px #c8c8c8;border-radius: 4px;padding: 10px;margin-bottom:30px;"><div style="padding-bottom:10px;"><a style="color:#0088c2;font-size:12px;" href="#" onclick="searchWidget.onSearchFeatureIOwn()"><span>Features owned by me <img src="../resources/images/linkTo.png" style="padding-left:3px;"/></span></a> </div>' + '<div><a style="color:#0088c2;font-size:12px;" href="#" onclick="searchWidget.onSearchFeatureImPart()"><span>Features I participated <img src="../resources/images/linkTo.png" style="padding-left:3px;"/></span></a></div>' + "</div>" + '<div style="padding-top: 5px;border: solid 1px #c8c8c8;border-radius: 4px;padding: 5px;margin-top: 10px;"><div style="padding-bottom:10px;">Search by Roles:</div>  <div><table style="margin-bottom:5px;"><tr><td><div id="searchUserRoles" style="display:inline-block"></div></td>  <td style="padding-left:8px;"> <div class="srchWidgetCnt" style="display:inline-block"><input type="text" placeHolder="User Id" class="searchWidgetBox" id ="searchWidgetField" onkeyup="if(event.keyCode === 13){searchWidget.onSearchWithRolesClick()}"/>' + '<input type="button" value="" title="Search" class="srchBtn" onclick="searchWidget.onSearchWithRolesClick()"  />' + "</td></tr></table>" + "</div></div>" + "</div>";
														 + "</div>";
													} else {
														if (b == "Cca") {
															a = '<div id="ccaGrid" style="height:250px"/>';
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		return a;
	},
	initLayout : function (b) {
		for (var a = 0; a < landing.currentWidgets.length; a++) {
			landing.createWidget(landing.currentWidgets[a]);
		}
		dijit.byId("userRoles").disabled = false;
	},
	closePortlet : function (d) {
		var c = dijit.byId(d);
		var a = c.get("column");
		if (landing.layouter.posArr[a] != 0) {
			landing.layouter.posArr[a] = (landing.layouter.posArr[a] - 1);
		}
		landing.layouter.widgetsPtr = a;
		if (c != undefined) {
			c.destroyRecursive();
		}
		var b = d.replace("_portlet", "_cbk");
		dijit.byId(b).set("checked", false, false);
		dojo.removeClass(dojo.byId(d.replace("_portlet", "_lbl")));
	},
	loadWidgetScript : function (b) {
		var a = "/irt/resources/js/irt/min/widgets/";
		if (isDebugMode != null && isDebugMode) {
			a = "/irt/resources/js/irt/widgets/";
		}
		var f = b.replace(/_/, "");
		f = f.charAt(0).toLowerCase() + f.slice(1);
		var d = a + f + ".js";
		try {
			$.getScript(a + f + ".js").done(function (e, h) {
				var g;
				if ((g = dojo.getObject(f + "Widget")) != undefined) {
					g.init();
				}
			}).fail(function (g, h, e) {
				alert("Not able to load widget scripts. Please contact the support team for more information");
			});
		} catch (c) {}
	},
	initializeWidget : function (b, c, a) {
		dojo.connect(c, "onLoad", function (d) {
			landing.loadWidgetScript(b);
		});
		c.set("content", a);
	},
	createWidget : function (c) {
		var g = dojo.create("div", {
				innerHTML : landing.getContent(c)
			});
		g.setAttribute("style", "height:100%;width:100%");
		g.setAttribute("id", c + "_div");
		var f = [g];
		var b = c.replace(/[\s]/g, "-");
		var a = landing.widgetsTitle[c];
		if (a == undefined) {
			a = c.replace(/_/, " ");
		}
		var d = new dojox.widget.Portlet({
				id : c + "_portlet",
				title : '<span style="display:inline-block;"><h3>' + a + "</h3></label>",
				style : "padding-left:2px;padding-top:0px;box-shadow: 2px 2px 3px grey;padding-left: 0px !important;border-collapse:separate;overflow-y: auto;margin-bottom: 5px;",
				onClose : function (h) {
					console.log(this.id);
					landing.closePortlet(this.id);
					landing.currentWidgets.splice(landing.currentWidgets.indexOf(this.id.replace(/_portlet/, "")), 1);
					landing.savePreference();
				}
			});
		landing.initializeWidget(c, d, f);
		var e = landing.layouter.updateDisplayPosition();
		landing.widgetContainer.addChild(d, e[0], e[1]);
		dojo.addClass(c + "_lbl", "checked");
		dijit.byId(c + "_cbk").set("checked", true, false);
	},
	onCBChange : function (d) {
		var c = dijit.byId(d + "_cbk").get("checked");
		if (c) {
			dojo.addClass(d + "_lbl", "checked");
			landing.currentWidgets.push(d);
			landing.createWidget(d);
		} else {
			dojo.removeClass(d + "_lbl");
			var b = dijit.byId(d + "_portlet");
			var a = b.get("column");
			if (landing.layouter.posArr[a] != 0) {
				landing.layouter.posArr[a] = (landing.layouter.posArr[a] - 1);
			}
			landing.layouter.widgetsPtr = a;
			if (b != undefined) {
				b.destroyRecursive();
			}
			landing.currentWidgets.splice(landing.currentWidgets.indexOf(d), 1);
		}
		landing.savePreference();
	},
	addWidget : function () {
		if (!landing.addWidgetDialog) {
			landing.addWidgetDialog = new dijit.Dialog({
					title : "Add Widgets",
					style : "width: 640px",
					onCancel : function () {}
				});
			var f = landing.allWidgetsList;
			var e = "<tr>",
			a;
			for (var c = 0; c < f.length; c++) {
				var d = landing.currentWidgets.indexOf(f[c]) != -1 ? "checked" : "";
				a = "<input id='" + f[c] + "_cbk' data-dojo-type='dijit/form/CheckBox' " + d + " onChange='landing.onCBChange(\"" + f[c] + "\")'/>";
				var b = "<img src='images/" + f[c] + ".png' />";
				e += "<td style='padding-left:15px'><table><tr><td style='width:250px;padding-bottom:10px;'>" + a + " " + f[c] + "</td></tr><tr><td>" + b + "</td></tr></table></td>";
				if (c == 4) {
					e += "</tr><tr>";
				}
			}
			e += "</tr>";
			var g = dojo.create("table", {
					innerHTML : e
				});
			landing.addWidgetDialog.set("content", dojo.byId("addWidgetContentDiv"));
			dojo.place(g, dojo.byId("addWidgetContentDiv"));
		}
		dojo.parser.parse(landing.addWidgetDialog);
		landing.addWidgetDialog.show();
	},
	createWidgetContainer : function (d) {
		var c = JSON.parse(JSON.stringify(landing.defaultWidgetsForRole[d]));
		if (landing.isBusinessAdmin || (undefined != landing.userPref && landing.userPref.widgets[d].indexOf("BusinessAdmin") >= 0)) {
			c.push("BusinessAdmin");
		}
		var a;
		for (var b = 0; b < c.length; b++) {
			a = landing.createAddWidgetLi(c[b]);
			dojo.place(a, dojo.byId("widgetList"));
		}
		dojo.parser.parse();
	},
	createAddWidgetLi : function (d) {
		var c = "";
		var b = landing.currentWidgets.indexOf(d) != -1 ? "checked" : "";
		lbl = "<label id='" + d + "_lbl' for='" + d + "_cbk' class='" + b + "' >";
		cbk = "<input id='" + d + "_cbk' data-dojo-type='dijit/form/CheckBox' " + b + " class='cbk' onChange='landing.onCBChange(\"" + d + "\")'/>";
		cls = d.replace(/[\_]/g, "-");
		div = '<div> <i class="icon-big-' + cls + '"> </i></div>';
		var a = landing.widgetsTitle[d];
		if (a == undefined) {
			a = d.replace(/_/, " ");
		}
		c = lbl + cbk + div + a + "</label>";
		return dojo.create("li", {
			innerHTML : c,
			id : d + "_li"
		});
	},
	destroyWidgetContainer : function () {
		dojo.forEach(dijit.findWidgets(dojo.byId("widgetContainer")), function (a) {
			a.destroyRecursive();
		});
		dojo.destroy(dojo.byId("widgetList"));
		dojo.place(dojo.create("ul", {
				id : "widgetList"
			}), "widgetContainer");
	},
	loadJs : function (a) {
		var b = document.createElement("script");
		b.setAttribute("type", "text/javascript");
		b.setAttribute("src", a);
		if (typeof b !== "undefined") {
			document.getElementsByTagName("head")[0].appendChild(b);
		}
	},
	getRoleSelect : function () {
		var a = [];
		a.push({
			label : "Please Select...",
			value : "dummy"
		});
		for (var b = 0; b < landing.allRolesList.length; b++) {
			if (landing.userRoles.indexOf(landing.allRolesList[b]) === -1) {
				a.push({
					label : landing.allRolesList[b].replace(/_/g, " "),
					value : landing.allRolesList[b]
				});
			}
		}
		if (landing.rolesSelect == undefined) {
			landing.rolesSelect = new dijit.form.Select({
					options : a,
					disabled : (a.length <= 1) ? true : false,
					style : "width:160px !important"
				});
		}
		if (a.length <= 1) {
			dojo.removeClass("allAccess1");
			dijit.byId("requestAccessSubmit").set("disabled", true);
			dijit.byId("guestDialogSubmit").set("disabled", true);
		}
		landing.rolesSelect.startup();
		landing.rolesSelect.on("change", function () {
			if (this.getValue() === "dummy") {
				dijit.byId("requestAccessSubmit").set("disabled", true);
				dijit.byId("guestDialogSubmit").set("disabled", true);
			} else {
				dijit.byId("requestAccessSubmit").set("disabled", false);
				dijit.byId("guestDialogSubmit").set("disabled", false);
			}
		});
		dijit.byId("requestAccessSubmit").set("disabled", true);
		dijit.byId("guestDialogSubmit").set("disabled", true);
		return landing.rolesSelect;
	},
	setCurrentActiveRole : function (a) {
		dashboard.currentlySelectedUserRole = a;
		require(["dojo/request/xhr"], function (b) {
			b("/irt/app/switchRole/" + dashboard.currentlySelectedUserRole, {
				query : {},
				method : "POST",
				handleAs : "json",
				preventCache : true
			}).then(function (c) {
				landing.savePreference();
				landing.businessAdmin();
			}, function (c) {
				dijit.byId("userRoles").disabled = false;
			}, function (c) {});
		});
	},
	businessAdmin : function () {
		require(["dojo/request/xhr"], function (a) {
			a("/irt/app/isBusinessAdmin", {
				query : {},
				method : "GET",
				handleAs : "json",
				preventCache : true
			}).then(function (b) {
				if (b == true) {
					var c = dijit.byId("userRoles").value;
					landing.isBusinessAdmin = true;
					if (landing.userPref.widgets[c].indexOf("BusinessAdmin") < 0) {
						landing.currentWidgets.push("BusinessAdmin");
						landing.destroyWidgetContainer();
						landing.createWidgetContainer(c);
						landing.createWidget("BusinessAdmin");
						landing.savePreference();
					}
				} else {
					landing.isBusinessAdmin = false;
					if (landing.userPref.widgets[c].indexOf("BusinessAdmin") < 0) {
						landing.closePortlet("BusinessAdmin");
						landing.currentWidgets.splice(landing.currentWidgets.indexOf("BusinessAdmin"), 1);
						landing.destroyWidgetContainer();
						landing.createWidgetContainer(c);
						landing.savePreference();
					}
				}
				dijit.byId("userRoles").disabled = false;
			}, function (b) {
				dashboard.showNotificationStatus("FAILURE", "Unable to get Business Admin role information.");
				dijit.byId("userRoles").disabled = false;
			}, function (b) {});
		});
	},
	createRoleList : function () {
		var a = [];
		if (landing.getInitRole() !== "GUEST") {
			for (var b = 0; b < landing.userRoles.length; b++) {
				a.push({
					label : landing.userRoles[b].replace(/_/g, " "),
					value : landing.userRoles[b]
				});
			}
		} else {
			a.push({
				label : "GUEST",
				value : "GUEST"
			});
		}
		var c = new dijit.form.Select({
				options : a,
				id : "userRoles",
				disabled : (landing.getInitRole() === "GUEST") ? true : false
			}, dojo.byId("userRoles"));
		c.startup();
		c.on("change", function () {
			landing.rolesSelectOnChange(this.get("value"));
		});
		dijit.byId("userRoles").set("value", landing.getInitRole(), false);
	},
	widgetsForCurrentRole : function (a) {
		if (undefined == landing.userPref) {
			return JSON.parse(JSON.stringify(landing.defaultWidgetsForRole[a]));
		} else {
			return JSON.parse(JSON.stringify(landing.userPref.widgets[a]));
		}
	},
	rolesSelectOnChange : function (b) {
		dijit.byId("userRoles").disabled = true;
		landing.isBusinessAdmin = false;
		for (var a = 0; a < landing.currentWidgets.length; a++) {
			landing.closePortlet(landing.currentWidgets[a] + "_portlet");
		}
		landing.setCurrentActiveRole(b);
		landing.currentWidgets = landing.widgetsForCurrentRole(b);
		landing.destroyWidgetContainer();
		landing.createWidgetContainer(b);
		landing.initLayout(b);
	},
	loadHash : {},
	showLoadImage : function (a, b) {
		if (b === "show") {
			if (landing.loadHash[a] === undefined) {
				landing.loadHash[a] = new dojox.widget.Standby({
						target : a,
						text : "Loading",
						color : "#616060",
						zIndex : "auto"
					});
				document.body.appendChild(landing.loadHash[a].domNode);
				landing.loadHash[a].startup();
				landing.loadHash[a].show();
				landing.loadHash[a]._fadeIn();
			} else {
				landing.loadHash[a].show();
				landing.loadHash[a]._fadeIn();
			}
		} else {
			landing.loadHash[a].hide();
		}
	},
	onSearchClick : function () {
		var a = dojo.byId("searchInput").value;
		a = encodeURIComponent(a);
		window.open(landing.searchUrl + "?q=" + a, "_blank");
	},
	showRequestAccessDialog : function () {
		if (landing.userRoles[0] !== "") {
			requestAccessDialog.show();
		} else {
			guestDialog.show();
		}
	},
	showCreateCaseDialog : function () {
		createCaseDialog.show();
	},
	submitOnRampRequest : function () {
		var a = landing.getRoleSelect().getValue();
		landing.showLoadImage("widgetCnt", "show");
		var b = {
			url : "/irt/app/requestForRole",
			postData : dojo.toJson({
				role : a,
				userName : landing.userId
			}),
			handleAs : "json",
			headers : {
				"Content-Type" : "application/json"
			},
			load : function (c) {
				if (c.Status === "Request Approval pending") {
					landing.pendingRequest = a;
				}
				onrampConfirmDialog.hide();
				successDialog.show();
				var d = dojo.byId("successMessage");
				if (c.Status === "Request SuccessFull") {
					d.innerHTML = "Your request has been submitted successfully.";
				} else {
					d.innerHTML = "There was a problem creating the request. Please raise a support case for more details.";
				}
				landing.showLoadImage("widgetCnt", "hide");
			},
			error : function (c) {
				alert("error");
			}
		};
		dojo.xhrPost(b);
	},
	getInitRole : function () {
		if (landing.userRoles.length === 0 || landing.userRoles[0] === "") {
			return "GUEST";
		} else {
			if (landing.currentRole === "null" && undefined === landing.userPref) {
				return landing.userRoles[0];
			} else {
				if ("null" !== landing.currentRole) {
					return landing.currentRole;
				} else {
					return landing.userPref.lastRole;
				}
			}
		}
	},
	savePreference : function () {
		var b = dijit.byId("userRoles").get("value");
		var a = {
			"lastRole" : b,
			"widgets" : JSON.parse(JSON.stringify(landing.defaultWidgetsForRole))
		};
		if (undefined != landing.userPref) {
			for (i = 0; i < landing.allRolesList.length; i++) {
				a.widgets[landing.allRolesList[i]] = landing.userPref.widgets[landing.allRolesList[i]];
			}
		}
		a.widgets[b] = landing.currentWidgets;
		console.log(a);
		landing.userPref = a;
		var c = {
			url : "updateUserPreference",
			postData : dojo.toJson({
				userName : landing.userId,
				preference : a
			}),
			handleAs : "json",
			headers : {
				"Content-Type" : "application/json"
			},
			load : function (d) {
				console.log(d);
			},
			error : function (d) {
				console.error("Unable to save user Preferences: " + d);
			}
		};
		dojo.xhrPost(c);
	},
	createCase : function () {
		var c = dijit.byId("userRoles").get("value");
		var b = document.getElementById("notes").value;
		var a = document.getElementById("summary").value;
		if (a == null || a == "") {
			alert("Please enter summary.");
			return false;
		}
		if (landing.userId == null) {
			console.log("User Id is null.");
			return false;
		}
		landing.showLoadImage("createCaseDialog", "show");
		var d = {
			url : "/irt/app/createRemedyCase",
			postData : dojo.toJson({
				notes : b,
				summary : a,
				userId : landing.userId
			}),
			handleAs : "json",
			headers : {
				"Content-Type" : "application/json"
			},
			load : function (e) {
				landing.showLoadImage("createCaseDialog", "hide");
				if (e != null && e != "") {
					createCaseDialog.hide();
					alert("Remedy case created successfully, case id:" + e.caseId);
				} else {
					alert("Unable to create remedy case");
				}
			},
			error : function (e) {
				landing.showLoadImage("createCaseDialog", "hide");
				console.error("Unable to create remedy case: " + e);
				createCaseDialog.hide();
				alert("Unable to create remedy case.");
			}
		};
		dojo.xhrPost(d);
	}
};
