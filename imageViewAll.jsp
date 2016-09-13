<%@ page import="java.util.Vector"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Iterator"%>
<%@page import="com.cisco.irt.util.RESTServiceClient"%>
<%@page import="com.cisco.irt.form.action.ActionConstants"%>

<%
	String hostName = "wwwin-vbabumus-irt-dev.cisco.com";
	Integer osTypeId = 306;//(Integer) request.getAttribute("osTypeId");
	Integer releaseNumberId = 31130;//(Integer) request.getAttribute("releaseNumberId");
	String userId = request.getRemoteUser();//"himsriva";//request.getParameter("userId");
	String releaseName = "3.2.0 S";//(String)request.getAttribute("releaseName");
	String hiddenMdfName = "";
	String hiddenMdfId = "";
	String sourceLocation = "";
	String taskId = (String) request.getAttribute("taskId");
	System.out.println("releaseNumberId::" + releaseNumberId);
	RESTServiceClient restServiceClient = new RESTServiceClient();
	String softwareServiceHostURL = restServiceClient
			.getProperty("software.services.url.base");
%>
<link
	href="http://<%=hostName%>/dojo1_8/1_8_3/dojox/grid/resources/claroGrid.css"
	rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css"
	href="/irt/resources/auessome/auessome.css" media="screen" />
<!--  added extra  -->

<style type="text/css">
#gridDiv {
	height: 40em;
}
</style>

<!-- added extra -->
<!-- <script>dojoConfig = {parseOnLoad: true}</script> -->
<script type="text/javascript"
	src="/irt/resources/js/jquery/min/jquery-latest.js"></script>
<!-- end of extra -->
<script type="text/javascript" src="/irt/resources/js/posting/sprit.js"></script>
<script type="text/javascript"
	src="/irt/resources/js/posting/imageView.js"></script>
<script type="text/javascript"
	src="/irt/resources/js/posting/createImage.js"></script>
	<script type="text/javascript"
	src="/irt/resources/js/posting/updatePlanner.js"></script>
<!-- 	<script type="text/javascript"
	src="/irt/resources/js/posting/updatePlannerTrial.js"></script -->
<script type="text/javascript"
	src="/irt/resources/js/posting/BrowserSniff.js"></script>
<script>
var metaDataArray = [];
var softwareServiceURL = "<%=softwareServiceHostURL%>";
var submitUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SUBMIT_ACTION%>/<%=taskId%>";
var saveUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SAVE_ACTION%>/<%=taskId%>";
	function submitForm() {
		console.log('gridLength' + gridLength);
		if (gridLength == 0) {
			alert('Please create an image before submitting this form!');
			return;	
		}		
		//alert("submitting Form");
		if ((document.getElementById('hasProductization').value == '') || (document.getElementById('hasProductization').value == undefined)) {
			getProductizationFlag(document.getElementById('osTypeId').value, false);//added to set the process variables
		}
		if (document.getElementById('needGuestApproval').value == '') {
			document.getElementById('needGuestApproval').value = 'N';
		}
		/* grid.imageListStore.fetch({ 
		     onComplete: function (items) { 
		         dojo.forEach(items, function (item, index) {
		        	 console.log(dojo.toJson(item));
		        	 if (item.accesslevel == "Guest Registered") {
		        		 document.getElementById('needGuestApproval').value = "Y";
		        		 break;
		        	 }
		        	 document.getElementById('needGuestApproval').value = "N";
		         }) 
		     } 
		}); */
		/* if ((document.getElementById('needGuestApproval').value == '') || (document.getElementById('needGuestApproval').value == undefined)) {
			//activate the logic to check for guest approval images
			imageListStore.fetch({query: { accessLevel: "Guest Registered"}, 
							onComplete: document.getElementById('needGuestApproval').value = "Y", 
							onError: document.getElementById('needGuestApproval').value = "N"
			});
		} */
		//fetchMetaDataArray
		if ((document.getElementById('hasPlatform').value == '') || (document.getElementById('hasPlatform').value == undefined)) {
			fetchMetaDataArray(document.getElementById('osTypeId').value);
			if ($.inArray('INDIVIDUAL_PLATFORM_NAME', metaDataArray) != -1) {
				document.getElementById('hasPlatform').value = "Y";
			} else {
				document.getElementById('hasPlatform').value = "N";
			}
			if ($.inArray('FEATURE_SET_NAME', metaDataArray) != -1) {
				document.getElementById('hasFeatureSet').value = "Y";
			} else {
				document.getElementById('hasFeatureSet').value = "N";
			}
		}
		var dataStr = $("#csprCreateMetaData").serialize();
		console.log('dataStr::'+ dataStr);
		$
				.ajax({
					url : submitUrl,
					data: dataStr,
					type : "POST",
					success : function(response) {
						dashboard.formSubmitSuccessCallback(response);
					},
					error : function(result, str, err) {
						alertBox("Unable to submit form currenlty, please try again later.");
						dashboard.formSubmitFailureCallback(result);
					}
				});
	}

	function saveForm() {
		//alert("saving Form");
		$
				.ajax({
					url : saveUrl,
					type : "POST",
					success : function(response) {
						dashboard.formSubmitSuccessCallback(response);
					},
					error : function(result, str, err) {
						alertBox("Unable to submit form currenlty, please try again later.");
						dashboard.formSubmitFailureCallback(result);
					}
				})
;
}

</script>
<div>
	<a href="#" onclick="javascript:viewAll(document.getElementById('osTypeId').value, document.getElementById('releaseNumberId').value);"><b>Upgrade-Planner</b></a><b><br>
<button onclick="javascript:deleteImage();"><b>Delete Checked>></button>
<button onclick="javascript:createImage();"><b>Add Image>></button>
	&nbsp;
	<!-- viewAll(osTypeId, releaseId) viewAll(document.getElementById('osTypeId').value, document.getElementById('releaseNumberId').value); -->
	<!-- <div data-dojo-type="dijit.form.Button">
		Remove Selected Rows
		<script type="dojo/method" data-dojo-event="onClick"
			data-dojo-args="evt">
        // Get all selected items from the Grid:
        var items = imageListGrid.selection.getSelected();
        if(items.length){
            // Iterate through the list of selected items.
            // The current item is available in the variable
            // "selectedItem" within the following function:
            dojo.forEach(items, function(selectedItem){
                if(selectedItem !== null){
                    // Delete the item from the data store:
                    imageListStore.deleteItem(selectedItem);
                } // end if
            }); // end forEach
        } // end if
    </script>
	</div>-->
</div>
<div class="claro mine" id="gridDiv" align="center"
	style="display: block; overflow: auto;"></div>
<div data-dojo-type="dijit/Dialog" id="createImageDialog"
	title="Create Image" style="display: none" align="center">
	<form id="csprCreateMetaData">
		<input type="hidden" name="osTypeId" id="osTypeId"
			value="<%=osTypeId%>" /> <input type="hidden" name="releaseNumberId"
			id="releaseNumberId" value="<%=releaseNumberId%>" /> <input
			type="hidden" id="userId" name="userId" value="<%=userId%>" />
		<%-- <input type="hidden" name="userId" value="<%=userId%>"/> --%>
		<input type="hidden" name="imageId" id="imageId" value='' />
		<input type="hidden" name="primaryRole" id="primaryRole" value='<%= userId %>' />
		<input type="hidden" name="actorId" id="actorId" value='<%= userId %>' />
		<input type="hidden" name="displayId" id="displayId" value='<%= "test display" %>' />
		<input type="hidden" name="hasPlatform" id="hasPlatform" value='' />
		<input type="hidden" name="systemId" id="systemId" value='<%= "test system" %>' />
		<input type="hidden" name="hasFeatureSet" id="hasFeatureSet" value='<%= "test has featureset" %>' />
		<input type="hidden" name="hasProductization" id="hasProductization" value='' />
		<input type="hidden" name="needGuestApproval" id="needGuestApproval" value='' />
		<!-- primaryRole
		actorId
		displayId
		hasPlatform
		systemId
		hasFeatureSet
		hasProductization
		needGuestApproval -->
		<div class="dijitDialogPaneContentArea">
			<table width="100%">
			<tr align="center">
					<td colspan="4">
						<div id="buttonDiv" class="buttonbar" align="center">
							<span id="imageListId" style="white-space: nowrap;"
								align="center">
								<button id="imageListSubmit" data-dojo-type="dijit/form/Button"
									type="button" style="background-color:yellow;margin-left:auto;margin-right:auto;display:table;margin-top:0%;margin-bottom:0%">Save Updates</button>
								
							</span>
						</div>
					</td>
				</tr>
				<tr id="trMDFProduct" style="display: none">
					<td width="20%"><label for="name">MDF Based Cisco
							Product<span id="productCodeToolTipId" class="auessome_helpicon"></span>
					</label></td>
					<td width="80%">
						<input type="hidden" name="hiddenMdfId"	id="hiddenMdfId" value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" id="hiddenMdfName" value="<%=hiddenMdfName%>">
						<div id="mdfDiv"></div>
						<input type="hidden" name="hiddenMdfId"	value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" value="<%=hiddenMdfName%>"><a href="javascript:mdfPopupPost('csprCreateMetaData',
	    	                             'mdfDiv',
	    	                             'div',
	    	                             'csprCreateMetaData',
	    	                             '',
	    	                             '', '',
                                             '<%=osTypeId%>')">Choose
							MDF Based Cisco Product</a>
					</td>
				</tr>
				<%-- <tr id="trReleaseNumberId" style="display: none">
					<td width="20%"><label for="name">Release Number*<span
							id="releaseNumberToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input type="text" id="releaseName"
						value="<%=releaseName%>" readonly="true" /></td>
				</tr>
				<tr id="trImageName" style="display: none">
					<td valign="top" width="20%"><label for="name">Image
							Name*<span id="imageNameToolTipId" class="auessome_helpicon"></span>
					</label></td>
					<td valign="top" width="80%"><input type="text"
						name="imageName" id="imageName" required="true"
						data-dojo-type="dijit/form/ValidationTextBox" />&nbsp;Note: Only
						A-Z,a-z, 0-9, -, _ and . are allowed</td>
				</tr> --%>
				<tr id="trImageDesc" style="display: none">
					<td width="20%"><label for="name">Image Description<span
							id="imageDescToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><textarea id="imageDesc" name="imageDesc"
							style="width: 300px;">Enter Image Description.</textarea></td>
				</tr>
				<tr id="trIndividualPlatform" style="display: none">
					<td width="20%"><label for="name">Choose Platform<span
							id="chooseMDFToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%">
						<div id="platformDisplay"></div> <a
						href="javascript:popUpPlatform('<%=osTypeId%>', '<%= releaseNumberId %>')">
							Choose Platform</a> <input type=hidden id="platformObject" value="" />
					</td>
				</tr>
				<tr id="trMDFProduct" style="display: none">
					<td width="20%"><label for="name">MDF Based Cisco
							Product<span id="productCodeToolTipId" class="auessome_helpicon"></span>
					</label></td>
					<td width="80%">
						<input type="hidden" name="hiddenMdfId"	id="hiddenMdfId" value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" id="hiddenMdfName" value="<%=hiddenMdfName%>">
						<div id="mdfDiv"></div>
						<input type="hidden" name="hiddenMdfId"	value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" value="<%=hiddenMdfName%>"><a href="javascript:mdfPopupPost('csprCreateMetaData',
	    	                             'mdfDiv',
	    	                             'div',
	    	                             'csprCreateMetaData',
	    	                             '',
	    	                             '', '',
                                             '<%=osTypeId%>')">Choose
							MDF Based Cisco Product</a>
					</td>
				</tr>
				<!-- <tr id="trMachineOsType" style="display: none">
					<td width="20%"><label for="name">Machine Operating
							System<span id="machineOSTypeToolTipId" class="auessome_helpicon"></span>
					</label></td>
					<td width="80%">
						<table>
							<tbody>
								<tr>
									<td align="left"><select name="machineOSType"
										id="machineOSType">
											<option>--Select--</option>
									</select> <input type="hidden" name="machineOSType" value="" /></td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr> -->
				<tr id="trMemoryFootprint" style="display: none">
					<td width="20%"><label for="name">Memory<span
							id="memoryFootprintToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input type="text" id="memoryFootprint"
						name="memoryFootprint" required="true"
						data-dojo-type="dijit/form/ValidationTextBox" /></td>
				</tr>
				<tr id="trHardDiskFootprint" style="display: none">
					<td width="20%"><label for="name">Hard Disk Footprint<span
							id="hardiskFootprintToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input type="text" id="hardDiskFootprint"
						name="hardDiskFootprint" required="true"
						data-dojo-type="dijit/form/ValidationTextBox" /></td>
				</tr>
				<tr id="trIsCrypto" style="display: none">
					<td width="20%"><label for="name">Crypto<span
							id="isCryptoToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%">
						<table>
							<tbody>
								<tr>
									<td align="left"><select name="crypto_flags"
										id="crypto_flags">
											<option>--Select--</option>
									</select><input type="hidden" name="crypto_flags_val" value="" /></td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
				<tr id="trMinFlash" style="display: none">
					<td width="20%"><label for="name">MIN FLASH<span
							id="minFlashToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%">
						<table>
							<tbody>
								<tr>
									<td align="left"><select name="minflash" id="minflash">
											<option>--Select--</option>
									</select> <input type="hidden" id="selectedMinflash" name="minflash"
										value="" /></td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
				<tr id="trDRAM" style="display: none">
					<td width="20%"><label for="name">MIN DRAM<span
							id="minDramToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%">
						<table>
							<tbody>
								<tr>
									<td align="left"><select name="mindram" id="mindram">
											<option>--Select--</option>
									</select> <input type="hidden" name="mindram" value="" /></td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
				<tr id="trPostingType" style="display: none">
					<td valign="top" width="20%"><label for="dob">Posting
							Type<span id="postingTypeToolTipId" class="auessome_helpicon"></span>
					</label></td>
					<td valign="top" width="80%">
						<div id="postingTypeDiv">
							<input type="radio" name="postingTypeId" value="2">CCO
							Only</input> <input type="radio" name="postingTypeId" value="3">Hidden
							Post CCO Only</input> <input type="radio" name="postingTypeId" value="4">Hidden
							Post MFG Only</input> <input type="radio" name="postingTypeId" value="7">Hidden
							with ACL</input> <input type="radio" name="postingTypeId" value="9">Hidden
							Machine to Machine</input> <input type="radio" name="postingTypeId"
								value="" checked>Not Known</input>
						</div>
					</td>
				</tr>
				<tr id="trInstallationDocUrl" style="display: none">
					<td valign="top" width="20%"><label for="dob">Installation
							Docs URL<span id="installationDocUrlToolTipId"
							class="auessome_helpicon"></span>
					</label></td>
					<td valign="top" width="80%"><input id="installationDocUrl"
						name="installationDocUrl" size="100" type="text" value=""
						maxlength="1000"></td>
				</tr>
				<tr id="trProductCode" style="display: none">
					<td width="20%"><label for="name">Product Code<span
							id="productCodeToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input type="text" name="productCode"
						id="productCode" data-dojo-type="dijit/form/ValidationTextBox" /></td>
				</tr>
				<tr id="trCCATS" style="display: none">
					<td valign="top" width="20%">CCATS<span id="ccatsToolTipId"
						class="auessome_helpicon"></span></td>
					<td valign="top" width="80%"><input id="ccats" name="ccats"
						size="8" type="text" value="" maxlength="8" /></td>
				</tr>
				<tr id="trFCSDate" style="display: none">
					<td width="20%"><label for="name">CCO FCS Date<span
							id="fcsDateToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input data-dojo-type="dijit/form/DateTextBox"
						id="fscDate" name="fscDate" style="width: 280px !important"
						data-dojo-props="constraints: { datePattern : 'yyyy-MM-dd', min : new Date()}"></td>
				</tr>
				<tr id="trSoftwareAdvisory" style="display: none">
					<td width="20%"><label for="name">Software Advisories<span
							id="softwareAdvisoryToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input type="checkbox" id="isSoftwareAdvisory"
						name="isSoftwareAdvisory">&nbsp;<input type="text"
						id="softwareAdvisoryDocUrl" name="softwareAdvisoryDocUrl"
						data-dojo-type="dijit/form/ValidationTextBox" /></td>
				</tr>
				<tr id="trDeferral" style="display: none">
					<td width="20%"><label for="name">Deferral Advisories<span
							id="deferralToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input disabled type="checkbox"
						id="isDeferred" name="isDeferred">&nbsp;<input type="text"
						id="deferralAdvisoryDocUrl" name="deferralAdvisoryDocUrl"
						data-dojo-type="dijit/form/ValidationTextBox" /></td>
				</tr>
				<tr id="trRelatedSoftware" style="display: none">
					<td width="20%"><label for="name">Related Software<span
							id="relatedSoftwareToolTipId" class="auessome_helpicon"></span></label></td>
					<td align="left" valign="top" width="80%"><div></div>
						<input type=hidden id="relatedSoftware" value="" /><a
						href="javascript:relatedSoftwarePopUp('csprImageEdit',
		                            '<%=osTypeId%>', '0' )">
							Choose Related Software</a></td>
				</tr>
				<tr id="trCDCAccessLevel" style="display: none">
					<td valign="top" width="20%"><label for="dob">Access
							Levels<span id="cdcAccessLevelToolTipId"
							class="auessome_helpicon"></span>
					</label></td>
					<td valign="top" width="80%"><input type="radio"
						name="cdcAccessLevelId" value="1">Guest Registered</input> <input
						type="radio" name="cdcAccessLevelId" value="2">Contract
						Registered</input> <input type="radio" name="cdcAccessLevelId" value="0">Anonymous</input>
						<input type="radio" name="cdcAccessLevelId" value="-1" checked>Not
						Known</input></td>
				</tr>
				<tr id="trSourceLocation" style="display: none">
					<td width="20%"><label for="name">Source Location<span
							id="sourceLocationToolTipId" class="auessome_helpicon"></span></label></td>
					<td width="80%"><input id="sourceLocation"
						name="sourceLocation" size="100" type="text"
						value="<%=sourceLocation%>" maxlength="1000"></td>
				</tr>
				<!-- add row functionality -->
				<tr>
					<td align="left" valign="top" width="20%"><span
						class="dataTableTitle"> Image Doc URL<br> Provide URL
							/ Source Location, not both
					</span></td>
					<td align="left" valign="top" width="80%"><span>
							<table id="tblImageNote" width="85%">
								<tr>
									<td valign="top" width="20%">Image Label</td>
									<td valign="top" width="35%">Image URL</td>
									<td valign="top" width="15%">Source Location <br> <font
										size="-2"> Provide absolute path including filename <br />
											<b> Note: Only A-Z,a-z,0-9, -, _, / and . are allowed. </b>
									</font>
									</td>
									<td width="10%"><input type="button" value="Add Row"
										id="imageNotesAddBtn"
										title="Please note that the document publishing takes upto 4 hrs to complete."
										onclick="addImageUrlRow(null);" /></td>
								</tr>
							</table>
					</span></td>
				</tr>
				<tr align="center">
					<td colspan="4">
						<div id="buttonDiv" class="buttonbar" align="center">
							<span id="imageListId" style="white-space: nowrap;"
								align="center">
								<button onclick="javascript:deleteImage();"><b>Delete Checked>></button>
<button onclick="javascript:createImage();"><b>Add Image>></button>
	&nbsp;
							</span>
						</div>
					</td>
				</tr>
			</table>
		</div>
	</form>
</div>

<!-- choose platform dialog -->
<div data-dojo-type="dojox/widget/DialogSimple"
	id="choosePlatformMdfPopUpDialog" title="Choose Platform"
	style="display: none" executeScripts="true" align="center"></div>
<!-- choose MDF dialog -->
<div data-dojo-type="dojox/widget/DialogSimple"
	id="chooseMdfPopUpDialog" title="Choose MDF" style="display: none"
	executeScripts="true" align="center"></div>
<!-- choose related software dialog -->
<div data-dojo-type="dojox/widget/DialogSimple"
	id="chooseRelatedSoftwarePopUpDialog" title="Choose Related Software"
	style="display: none;height:300px;width:400px;overflow: auto" executeScripts="true"
	align="center"></div>
<div id="buttonBarDiv" class="buttonbar">
	<span id="buttonsid" style="white-space: nowrap;">
		<button id="btn_save" data-dojo-type="dijit/form/Button" type="button"
			onClick="saveForm();">Save</button>
		<button id="btn_submit" data-dojo-type="dijit/form/Button"
			type="button" onClick="submitForm();">Submit</button>
	</span>
</div>
<!-- <div id="waitDiv" data-dojo-type="dojox.widget.Standby"></div> -->
