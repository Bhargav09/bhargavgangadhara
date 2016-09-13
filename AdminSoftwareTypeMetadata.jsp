<!--
.........................................................................
: DESCRIPTION:
: Metadata Associate Software Type page.
:
: 
: AUTHORS:
: @author Holly Chen (holchen@cisco.com)
:
: Copyright (c) 2007-2011 by Cisco Systems, Inc.
:.........................................................................
-->

<%@ page import="java.lang.Integer" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.eit.sprit.util.QueryUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.model.spritproperties.*" %>
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprSoftwareTypeMetaDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.logic.softwaretypemetadataadmin.SoftwareMetadataAdmin" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprSoftwareTypeMetaData" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprSoftwareReleaseComponent" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprSoftwareTypePM" %>
<%@ page import="com.cisco.eit.sprit.dataobject.OsTypeMDFSwTypeVo" %>
<%@ page import="com.cisco.eit.shrrda.ostypemdfswtype.ShrOSTypeMDFSWTypeLocalHome" %>
<%@ page import="com.cisco.eit.shrrda.ostypemdfswtype.ShrOSTypeMDFSWTypeLocal" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.dataobject.OSTypeInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.managmentMetadata.ManagementMetadataHelper" %> 
<%@ page import="javax.ejb.CreateException" %>
<%@ page import="javax.ejb.EJBException" %>
<%@ page import="javax.ejb.FinderException" %>
<%@ page import="javax.ejb.SessionBean" %>
<%@ page import="javax.ejb.SessionContext" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="com.cisco.eit.sprit.model.cspraccesslevelapproval.CsprAccessLevelApprovalLocal" %>
<%@ page import="com.cisco.eit.sprit.model.cspraccesslevelapproval.CsprAccessLevelApprovalLocalHome" %> 
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.util.SpritPropertiesUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="java.util.Vector" %>
 
<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
   
  Integer               osTypeId            = null;
  String                osType              = null;
  String                releaseNumber       = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;
  SpritAccessManager    spritAccessManager;
  boolean               isSoftwareTypePM    = false;
  boolean               isFreeSoftware    = false; 
  List 					freeSoftwareApproverTypes = null;
  
  
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );

  nonIosCcoPostHelper = new NonIosCcoPostHelper();
  String strMode = nonIosCcoPostHelper.getMode(request);
  
  try {
	    if(osType == null || osType.equals("")) {
	       osType = request.getParameter("osTypeId");
	       if(osType ==null) {
	    	   osType ="";
	        }
	       if(osType.length()>1)
	       	   //osTypeId = Integer.valueOf(osType);
	    	   osTypeId = Integer.valueOf(osType.substring(0, osType.indexOf(':')));
	     
	    }
	} catch ( Exception e ) {
	       response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
	}	
   

	try{
    	session.removeAttribute((String) session.getAttribute("message"));
  	} catch ( Exception e ) {
      //do nothing
  	}
  
  freeSoftwareApproverTypes =  SpritPropertiesUtil.getFreeSwApproverTypes();
  
  releaseNumber =WebUtils.getParameter(request,"releaseName");
  
  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId); 
  boolean isSpritAdmin = spritAccessManager.isAdminSprit();

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(strMode != null && NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNavForAdminUI(globals,osType, "softwareTypeMetadata")
    );
  } else {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNavForAdminUI(globals,osType,releaseNumber, "softwareTypeMetadata")
    );
  }
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);

  //SpritAccessManager acc = (SpritAccessManager) globals.go( "accessManager" );
  //String userId =  acc.getUserId();

  //TODO: check for Admin access here
%>



<FORM name=editfrom method=POST action="SoftwareTypeMetadataAdminProcessor">

<%= SpritGUI.pageHeader( globals,"Sprit Software Metadata Module","" ) %>

<%= banner.render() %>
<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript" src="../js/prototype.js"></script>

<SCRIPT type=text/javascript>
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form "hasn't" been submitted.
  //........................................................................

  function actionBtnSaveImages(elemName) {
    setImg( elemName,"../gfx/btn_save_updates.gif" );
  }
  function actionBtnSaveImagesOver(elemName) {
    setImg( elemName,"../gfx/btn_save_updates_over.gif" );
  }
   
  releaseComponentMaxSize = 8; 
  function validateAndSubmitForm() {
  	  // I guess no validation is required as we set the maximum 
  	  // length for all the fields.
  	  var submitFlag = true;
  	  var i;
  	  
<% if(isSpritAdmin) { %>
  	  if ( document.editfrom.osTypeId.value == null || document.editfrom.osTypeId.value == "" ) {
  	      alert("Select a Software Type before saving updates.");
  	      return;
  	  }
  	
    //var size = document.editfrom.elements["configurableMetadataSize"].value; 
    var size = document.getElementById("configurableMetadataSize").value;
    var isIncludeInSwTypeFreeSwPubAllow = '';
    var isIncludeInSwTypeProdCd = '';
    var isIncludeInSwTypeCcats = '';
   	for(i=0;i<size;i++){
		var isIncludeInSwType = "isIncludeInSwType_" + i;
		var isDeletable = "swMetadaDeletable_" + i;
		var name  = "metadataName_" +i;
		// CSCte90976 anonymous free sw publish
		if (document.editfrom.elements[name].value == 'FREE_SW_PUBLISH_ALLOWED') {
			isIncludeInSwTypeFreeSwPubAllow = isIncludeInSwType;
		}
		if (document.editfrom.elements[name].value == 'PRODUCT_CODE') {
			isIncludeInSwTypeProdCd = isIncludeInSwType;
		}
		if (document.editfrom.elements[name].value == 'CCATS') { 
			isIncludeInSwTypeCcats = isIncludeInSwType;
		}
		
		
		if(document.editfrom.elements[isDeletable].value=="N" && document.editfrom.elements[isIncludeInSwType].checked == false){
		    alert ("Can't Uncheck " + document.editfrom.elements[name].value +" for 'Include In Software Type', It has been in use");
		   //document.editfrom.elements[isIncludeInSwType].value="N";
		    submitFlag = false;
		}
	 }
	 
	 // before submitting the form, check if the product code and ccats unchecked,
	 // if so alert the user and check them automatically if the free_sw_publish_allowed is checked
		if(document.editfrom.elements[isIncludeInSwTypeFreeSwPubAllow].checked == true) {
			if (document.editfrom.elements[isIncludeInSwTypeProdCd].checked == false) {
				document.editfrom.elements[isIncludeInSwTypeProdCd].checked = true;	
				alert ("Product Code has been checked since the FREE_SW_PUBLISH_ALLOWED is checked.");
				submitFlag = false;
			}
			if (document.editfrom.elements[isIncludeInSwTypeCcats].checked == false) {
				document.editfrom.elements[isIncludeInSwTypeCcats].checked = true;	
				alert ("CCATS has been checked since the FREE_SW_PUBLISH_ALLOWED is checked.");
				submitFlag = false;
			}
		}
	 
  	  for (i=0; i<releaseComponentMaxSize;i++){
  	    var name  = "componentName" + "_" +i;
  	    var label = "componentLabel" + "_" +i;
  	    var seq =   "componentSeq"+ "_" + i;
  	    var dataType = "componentDataType"+ "_" + i;
  	    var group = "componentGroup_" +i;
  	    if(document.editfrom.elements[name].value.length != 0){
  	      if(document.editfrom.elements[label].value.length  <1){
  	      		alert ("The Component Display name can't be empty");
  	      		submitFlag  = false;
  	      		break;
	       }
  	    
  	    }
  	    
  	     if(document.editfrom.elements[name].value.length != 0){
  	        if(document.editfrom.elements[seq].options[0].selected){
  	        	alert ("The Sequence must be selected");
  	        	submitFlag  = false;
  	        	break;
  	         }
 	     }
 	     
 	     if(document.editfrom.elements[name].value.length != 0){
	       	  if(document.editfrom.elements[dataType].options[0].selected){
	       	      	alert ("The DataType must be selected");
	       	       	submitFlag  = false;
	       	       	break;
	       	   }
 	     }
 	     
 	     if(i>3 && document.editfrom.elements[name].value.length != 0){
	     	       	  if(document.editfrom.elements[group][0].checked ){
	     	       	      	alert ("Component 3-8 can't set group to TRUE");
	     	       	       	submitFlag  = false;
	     	       	       	break;
	     	       	   }
 	     }   
 	        
  	  }
  	 
  	
  	   
  	 //check duplicate component name 
  	 var componentNameArray = new Array();
	 for(i=0;i<releaseComponentMaxSize;i++){
	     var name = "componentName_" + i;
	     if(document.editfrom.elements[name].value.length!=0)
	        componentNameArray[i] = document.editfrom.elements[name].value;
	 }
	 for (var i=0; i<componentNameArray.length - 1; i++)
	 	  {
	 	     for (var j=i+1; j<componentNameArray.length; j++)
	 	     {
	 	       if (componentNameArray[i] == componentNameArray[j]){
	 	          alert ("Component Name can't be duplicate in all the components");
	 	          submitFlag  = false;
	 	       	  break;
	 		  
	 		}
	 	      }
	  }  
	  
	  
	  //check duplicate component label 
	    	 var componentLabelArray = new Array();
	  	 for(i=0;i<releaseComponentMaxSize;i++){
	  	     var label = "componentLabel_" + i;
	  	     if(document.editfrom.elements[label].value.length!=0)
	  	        componentLabelArray[i] = document.editfrom.elements[label].value;
	  	 }
	  	 for (var i=0; i<componentLabelArray.length - 1; i++)
	  	 	  {
	  	 	     for (var j=i+1; j<componentLabelArray.length; j++)
	  	 	     {
	  	 	       if (componentLabelArray[i] == componentLabelArray[j]){
	  	 	          alert ("Component Label can't be duplicate in all the components");
	  	 	          submitFlag  = false;
	  	 	       	  break;
	  	 		  
	  	 		}
	  	 	      }
	  }
  	
  	//check duplicate sequence  
  	 var myArray = new Array();
	 for( i=0;i<releaseComponentMaxSize; i++){
	    var seq =   "componentSeq_" + i;
	    if(document.editfrom.elements[seq].selectedIndex!=0)
	    myArray[i] = document.editfrom.elements[seq].selectedIndex;
	 }
		  	   	  
	 for (var i=0; i<myArray.length - 1; i++)
	  {
	     for (var j=i+1; j<myArray.length; j++)
	     {
	       if (myArray[i] == myArray[j]){
	          alert("Sequence can't be duplicate in all the components");
	          submitFlag  = false;
	       	  break;
		  //myArray[j] = '';
		}
	      }
	  }	  
  	
  	  if ( document.editfrom.maxReleaseNotes.value == 0 ) {
  	      alert ("A value for Max Release Notes must be selected.");
  	      submitFlag  = false;
  	      return;
  	  }
  	  
  	  var sdsSortByArray = document.getElementsByName('sdsSortBy');
  	  if(!arrayFieldIsUnique(sdsSortByArray)){
  	  		alert("SDS Sort field should be unique");
  	        submitFlag  = false;
 	  }
  	  
  	  if ( document.editfrom.maxImageNotes.value == 0 ) {
  	      document.editfrom.maxImageNotes.value = null;
  	  }
  	  
  	  for (i=0; i<releaseComponentMaxSize;i++){
  	  
  	    var name  = "componentName" + "_" +i;
  	    var nameHidden = "componentHiddenName" + "_" +i;
  	    if(document.editfrom.elements[name].value.length != 0)
  	       document.editfrom.elements[nameHidden].value = document.editfrom.elements[name].value;
  	  
  	  }

  	  
  	  // asuman added this comment
  	  var pms = document.editfrom.elements["swTypeMetadataPMs"].value;
  	  var pmArray = pms.split(",");
  	  if(arrHasDupes(pmArray)){
  	  		alert("you input duplicate PM User Id, please change it, Thank you!");
  	  		submitFlag  = false;
  	  }

      var alias = document.editfrom.elements["swTypeCcoPostEmailAlias"].value;
  	  var aliasArray = alias.split(",");
  	  if(arrHasDupes(aliasArray)){
  	  		alert("you input duplicate email alias, please change it, Thank you!");
  	  		submitFlag  = false;
  	  }
	  if(checkApproverIdType()){
		   submitFlag  = false;
	  }

	  if(submitFlag){
		  if(checkDupApproverName()){
			  submitFlag  = false;
		  }
	  }
  	  
<%  } %>
  	  if(submitFlag){
  	        document.editfrom.hidfield.value="SaveUpdate";
	  	document.editfrom.submit();
	  }	
  }

  function checkDupApproverName(){
	var eform = document.forms[0];
	var freeSoftwareAppIds1 = eform['freeSwAppId'];
	
	for(var i=2;i < freeSoftwareAppIds1.length; i++){
		var appId1 = trimBlankSpace(freeSoftwareAppIds1[i].value);

		for(var j=i+1;j < freeSoftwareAppIds1.length; j++){

			var appId2 = trimBlankSpace(freeSoftwareAppIds1[j].value);

			if((appId1.length > 0 && appId2.length > 0) && (appId1 == appId2)){
				alert("Duplicate Free Software Approver Id '"+appId2+"'. Please verify.");
				return true;
			}
		}
	}
	return false;
 }

function checkApproverIdType(){
  	  var eform = document.forms[0];
	  var freeSoftwareAppId1 = eform['freeSwAppId'];
	  var newAppId1 = eform['newAppId'];
  	  var freeSoftwareAppType1 = eform['freeSwAppType'];
	  var invalidApprId = false;

	  for(var i=2;i < freeSoftwareAppId1.length; i++){
		  var appId = trimBlankSpace(freeSoftwareAppId1[i].value);
		  var appType = trimBlankSpace(freeSoftwareAppType1[i].value);
		  var newAppId = trimBlankSpace(newAppId1[i].value);
		  if(appId.length == 0){
			   alert("Free Software Approver Id cannot be blank. Please specify.");
 		       return true;
		  }else{
			  if(newAppId=='Y' && !isUserIdValid(appId)){
 			      alert("Free Software Approver Id '"+appId+"' is not a valid CISCO user id. Please verify.");
			      return true;
			  }
		  }
		  if(appType.length == 0){
			   alert("Please select Free Software Approver Type for '"+appId+"'.");
			   return true;
		  }
	  }
	  return false;
  }
  
  function changeSoftwareType() {
     document.editfrom.submit();
     return true;
  }
  
  function arrHasDupes( A ) {     // finds any duplicate array elements using the fewest possible comparison
	var i, j, n;
	n=A.length;
                                        // to ensure the fewest possible comparisons
	for (i=0; i<n; i++) {               // outer loop uses each item i at 0 through n
		for (j=i+1; j<n; j++) {         // inner loop only compares items j at i+1 to n
			if (A[i]==A[j]) return true;
	}	}
	return false;
}
  
  sds_max_row = 3;
  sds_count =1;
  function addSDSSortInfo(){
									
		var tblSDSSortInfoTable = document.getElementById('tblSDSSortInfo');
		var sdsSortAddBtn = document.getElementById("sdsSortAddBtn");
		var tblLength = tblSDSSortInfoTable.rows.length;
			  				
		if(tblSDSSortInfoTable.rows.length<sds_max_row){	
			//add a row to the rows collection and get a reference to the newly added row
			var newRow = document.getElementById("tblSDSSortInfo").insertRow(tblSDSSortInfoTable.rows.length);
						
			//add 3 cells (<td>) to the new row and set the innerHTML to contain text boxes
			var oCell = newRow.insertCell(0);
			if(tblLength==1)
			oCell.innerHTML = "<td><select name='sdsSortBy'><option value='Publish_Date'>Publish Date</option>"
			+ "<option value='File_Name'>Image Name</option>"
			+ "<option value='Round_File_Size'>File Size </option>		</select></td>";
			
			else 	
			oCell.innerHTML = "<td><select name='sdsSortBy'><option value='File_Name'>Image Name </option>"
			+ "<option value='Publish_Date'>Publish Date</option>"
			+ "<option value='Round_File_Size'>File Size </option>		</select></td>";
									
			var oCell = newRow.insertCell(1);
			if(tblLength==1)
			oCell.innerHTML = "<td><select name='sdsSortOrder' ><option value='DESC' >DESC</option>"
			+ " <option value='ASC'>ASC </option>	</select></td>"	;
			
			else 	
			oCell.innerHTML = "<td><select name='sdsSortOrder' ><option value='ASC' >ASC</option>"
			+ " <option value='DESC'>DESC </option>	</select></td>"	;	
			
			var oCell = newRow.insertCell(2); 
			var sdsSeq="Secondary";
			if(tblLength==1) sdsSeq="Primary";
			oCell.innerHTML = "<td>" + sdsSeq +" </td>";
					
			var oCell = newRow.insertCell(3);
			oCell.innerHTML ="<input type='button' value='Delete' onclick='removeSDSSort(this);'/>";
							
			sds_count++;
			if(tblSDSSortInfoTable.rows.length==sds_max_row) sdsSortAddBtn.disabled= true;
		}	
  }
  
  
  //deletes the specified row from the table
  function removeSDSSort(src){
	    	/* src refers to the input button that was clicked.	
			   to get a reference to the containing <tr> element,
			   get the parent of the parent (in this case case <tr>)
			*/			
				var oRow = src.parentNode.parentNode;	
				var sdsSortAddBtn = document.getElementById("sdsSortAddBtn");
				
				//once the row reference is obtained, delete it passing in its rowIndex			
				document.getElementById("tblSDSSortInfo").deleteRow(oRow.rowIndex);	
				sdsSortAddBtn.disabled=false;
			  	sds_count--;
  }			
  
  function arrayFieldIsUnique(objArr) {
						var flag = true;
						if (objArr != null) {
							
							if (objArr.length == 1) {
								return flag;
							}
							
							for(i=0;i<objArr.length;i++) {
								var label = objArr[i].value;
									for(j=i+1;j<objArr.length;j++){
										if(this.trimBlankSpace(label) == this.trimBlankSpace(objArr[j].value) && label!=''){
										return false;
								}
							}
						}
					}
					return flag;
 } 
 
 function trimBlankSpace(str){
					return str.replace(/^\s*/, "").replace(/\s*$/, "");
				}

	//CSCsv19029 - Show/Hide Guest Registered approver list
	// CSCte90976 SW Type level admin config ( change guest reg to free sw publish)
	function showhidefreesoftwareapp(){
		if(document.getElementById('freeSwApprCheck').checked == true){	
			groupRegApprDiv.style.visibility = 'visible';
			groupRegApprDiv.style.height = '100%';
			groupRegApprDiv.style.overflow = 'auto';
			checkProdCdCcats();
		}else{
			groupRegApprDiv.style.visibility = 'hidden';
			uncheckProdCdCcats();
		}
	}
		
	//CSCte90976 Anonymous download - SW type level Admin Configuration
	// If the free_sw_publish_allowed is checked, automatically check
	// the product code and show the ccats field and check it automatically
	function checkProdCdCcats() {	
	    var alertProd = '';	   
	    var alertCcat = ''; 
		var prodCdFlag = false;
		var ccatsFlag = false;
	    var size = document.getElementById("configurableMetadataSize").value;
	   	for(i=0;i<size;i++){
			var isIncludeInSwType = "isIncludeInSwType_" + i;
			var name  = "metadataName_" +i;
			if (document.editfrom.elements[name].value == 'PRODUCT_CODE' &&
				document.editfrom.elements[isIncludeInSwType].checked == false)  {
				document.editfrom.elements[isIncludeInSwType].checked = true;
				prodCdFlag = true;
				alertProd = 'Product Code and ';
			}
			
			if (document.editfrom.elements[name].value == 'CCATS') {
				document.getElementById('displayCcats').style.display = '';
				document.editfrom.elements[isIncludeInSwType].checked = true;
				ccatsFlag = true;
				alertCcats = 'CCATS.';
			}
			if (prodCdFlag == true && ccatsFlag == true) {
				break;
			}
		}
		alert('Checking FREE_SW_PUBLISH_ALLOWED will automatically checks '+ alertProd + alertCcats);
		return true;
	}
	
	//CSCte90976 Anonymous download - SW type level Admin Configuration
	// If the free_sw_publish_allowed is unchecked, automatically uncheck
	// product code and hide the ccats field and uncheck it.
	function uncheckProdCdCcats() {	
		var size = document.getElementById("configurableMetadataSize").value;
	   	for(i=0;i<size;i++){
			var isIncludeInSwType = "isIncludeInSwType_" + i;
			var name  = "metadataName_" +i;
			if (document.editfrom.elements[name].value == 'CCATS' &&
				document.editfrom.elements[isIncludeInSwType].checked == true)  {
				document.editfrom.elements[isIncludeInSwType].checked = false;
				document.getElementById('displayCcats').style.display = 'none';
				ccatsFlag = true;
				alert('Unchecking FREE_SW_PUBLISH_ALLOWED will automatically unchecks CCATS');
				break;
			}
		}	
		return true;
	}
	
	//CSCsv19029
	function delGroupRegRow(row){
		var oRow = row.parentNode.parentNode;	
		document.getElementById("freeSwAppTbody").deleteRow(oRow.rowIndex);	
	}
	//to get unique div name everytime
	var index = 1;
	
	//CSCsv19029
	function addGroupRegRow(){
		var tbodyid = document.getElementById('freeSwAppTbody');
		
		//div to identify it uniquely and update it
		var div_id = "Div" + index;		
		index++;
		
		var newRow = tbodyid.insertRow(-1);
		
		var newCell = newRow.insertCell(-1);
		newCell.innerHTML =  "<Select name=\"freeSwAppType\" onchange=\"onChangeApproverTypeDropDown('"+div_id+"', this.options[this.selectedIndex].value);\">"
									+ "<option value=\"\" selected></option>"
									<%
										Iterator itFreeSoftwareApprTypeMetaDataJs = freeSoftwareApproverTypes.iterator();
										while(itFreeSoftwareApprTypeMetaDataJs.hasNext()){
											List apprTypeMetaDataJs = (List)itFreeSoftwareApprTypeMetaDataJs.next();
											String apprTypeJs = (String)apprTypeMetaDataJs.get(0);
											%>
												+ "<option value=\"<%=apprTypeJs%>\"><%=apprTypeJs%></option>"
											<%
										}
									%>									
									+"</Select>";
		
		var newCell = newRow.insertCell(-1);
		newCell.innerHTML =  "<div id = '"+ div_id +"'>"+
		                     "<input type=\"hidden\" name=\"newAppId\" value=\"Y\">" +
							 "<input name=\"freeSwAppId\" size=\"10\" type=\"text\">"+
							 "</div>";	

		var newCell = newRow.insertCell(-1);
		newCell.innerHTML =  "<font style=\"color:#ff0000;\"><i>pending</i>";
		
		var newCell = newRow.insertCell(-1);
		newCell.innerHTML = "<textarea rows=\"3\" cols=\"20\" name=\"freeSwAppComments\" </textarea>"
		
		var newCell = newRow.insertCell(-1);
		newCell.innerHTML =  "<input type=\"button\" value=\"Delete\" onclick=\"javascript:delGroupRegRow(this);\">";
	}
	function onChangeApproverTypeDropDown(div_id, selectedApproverType){
        
        //if corporate revenue is selected, display drop down
        if(selectedApproverType == "Corporate Revenue"){
        
        	document.getElementById(div_id).innerHTML = "<span class=\"dataTableData\">"
		    + "<input type=\"hidden\" name=\"newAppId\" value=\"Y\"/>"
		    + "<Select name=\"freeSwAppId\" class=\"small\">"
			+ "<option selected></option>"
			<%
				Vector corporateRevenueRole = (Vector) spritAccessManager.getRoleUserIds("corporateRevenue");
		        Iterator corporateRevenueRoleIterator = corporateRevenueRole.iterator();
		        while(corporateRevenueRoleIterator.hasNext()){
		   
		        String corporateRevenue = (String)corporateRevenueRoleIterator.next();
			%>
				+ "<option value=\"<%=corporateRevenue%>\"><%=corporateRevenue%></option>"
			<%
				}
		    %>
			 + "</Select></span>";
        }else{
           //display edit box
           document.getElementById(div_id).innerHTML =   "<input type=\"hidden\" name=\"newAppId\" value=\"Y\">"+
							 "<input class='small'  name='freeSwAppId' size='10' type='text'>";
		}
        return;
	}			
</SCRIPT>


<!--span class="headline">
    <align="center">Software Metadata Admin<align="center">
</span><br /><br /-->


<input type="hidden" name="hidfield" value="novalue">

     <!--%  
        csprSoftwareTypeMetaDataNameV =CsprSoftwareTypeMetaDataJdbc.getCsprSoftwareTypeMetadataNameVector(osTypeId);
        for(int i=0;i<csprSoftwareTypeMetaDataNameV.size();i++) {
          out.println("MetaDataName = "+csprSoftwareTypeMetaDataNameV.get(i) );
        }
  
   %-->    
<center>

<% if (!isSoftwareTypePM && !isSpritAdmin) { %>
     <br><h3>You don't have a permission to access this page for osType '<%=osType%>'.</h3></br>
<% } else { %>
<table border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td align="center">
	    <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates1')"
		    onclick="javascript:validateAndSubmitForm()"
	    	onmouseout="actionBtnSaveImages('btnSaveUpdates1')" alt="Save Updates"
		    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates1><br /><br />
	</td>
  </tr>
</table>
</center>

<% if(isSpritAdmin) { %>
<table border="0" cellspacing="0" cellpadding="0">
<tr>
	<td align="left">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</B> </td>
	<td align="left"><B>Metadata Association</B> </td>
	<td align="left">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp   </td>
	<td align="right"><B>Release Component Management </B></td>
</tr>
</table>  
<% } %>

<center>
<table border="0" cellspacing="0" cellpadding="0">
  
  <tr>
  
    <td valign="top">
<% if(isSpritAdmin) { %>    
       <TABLE border="1" cellpadding="4" cellspacing="0">
       <TBODY>
           <tr bgcolor="#d9d9d9">
	     			<td align="center" valign="top" ><span class="dataTableTitle">
	 				Metadata Name 
	 			</span></td>
	 			 <td align="center" valign="top" ><span class="dataTableTitle">
				 	 CCO and BU Required 
	 			</span></td>
	 			<td align="center" valign="top" ><span class="dataTableTitle">
					 Include in Software Type
				</span></td>
	 			
	 </tr>
	 <%List csprSoftwareTypeMetaDataCCORequiredList =SoftwareMetadataAdmin.getSwTypeMetadataCCORequired();   
	   for (int i=0; i< csprSoftwareTypeMetaDataCCORequiredList.size(); i++){
	        CsprSoftwareTypeMetaData metadataObj= (CsprSoftwareTypeMetaData)csprSoftwareTypeMetaDataCCORequiredList.get(i); %>
	      
	 <tr>
	 <td class=dataTableData vAlign=top align=left>
	 		 <%=metadataObj.getMMetadataName() %>
		 </span></td>
		 <td align="center">Y</td>
		 <td align="center">Y<input type="hidden" name="mandatoryMetadataId" value=<%=metadataObj.getMMetadataId()%> >
         </td>
	 </tr> <%}%>
       	
       	
       	<tr bgcolor="#d9d9d9">
    			<td align="center" valign="top" ><span class="dataTableTitle">
	 				Configurable Fields
				</span></td>
				<td align="center" valign="top" ><span class="dataTableTitle">
	  				Include in <br>Software Type
				</span></td>
				<!--td align="center" valign="top" ><span class="dataTableTitle">
	  				Is <br>Obsolete
				</span></td-->
				<td align="center" valign="top" ><span class="dataTableTitle">
	  				Is BU <br>Required
				</span></td>
	        </tr>
   
    <% 
       Map swMetadataDeletableMap = SoftwareMetadataAdmin.getSwMetaDataDeletable(osTypeId);
       List csprSoftwareTypeMetaDataList =SoftwareMetadataAdmin.getSwTypeMetatadataConfigurable(osTypeId);   
       for (int recordIndex = 0; recordIndex < csprSoftwareTypeMetaDataList.size(); recordIndex++){
       	   CsprSoftwareTypeMetaData metadata = (CsprSoftwareTypeMetaData)csprSoftwareTypeMetaDataList.get(recordIndex);
    %>
        <!--td align="center" valign="top" class="tableCell"><span class="dataTableData">
	        <input type="checkbox" value='Y' name="">
        </span></td-->
        
        <input type ="hidden" name= "configurableMetadataSize" id= "configurableMetadataSize" 
        value ="<%= csprSoftwareTypeMetaDataList.size()%>">
        
    <tr
    	<%
    		if ("CCATS".equals(metadata.getMMetadataName())) {
    	%>
    	 id="displayCcats"
    	<% }
    	%>
    >        
        <td class=dataTableData vAlign=top align=left>
		 <%= metadata.getMMetadataName()%>
		 </span></td>
		 <input type ="hidden" name= "metadataName_<%=recordIndex%>" value ="<%= metadata.getMMetadataName()%>">
		 <input type ="hidden" name= "metadataIsInDb_<%=recordIndex%>" value ="<%= metadata.getMIsInSwTypeTable()%>">
		 <input type ="hidden" name= "swMetadataId_<%=recordIndex%>" value ="<%= metadata.getMSwTypeMetadtaId()%>">
		 <input type ="hidden" name= "swMetadaAdmFlag_<%=recordIndex%>" value ="<%= metadata.getMAdminFlag()%>">
       
       <td align="center" valign="top"><span class="dataTableData">
                 <input type="checkbox" name="isIncludeInSwType_<%=recordIndex%>"
                 	<%//CSCsv19029 - Guest Registered Approval 
                 	// CSCte90976 - Anonymous changed guest reg to free sw publish
                 	if("FREE_SW_PUBLISH_ALLOWED".equals(metadata.getMMetadataName())){
                 		if(metadata.getMIsInSwTypeTable().equalsIgnoreCase("Y") && metadata.getMAdminFlag().equalsIgnoreCase("V")){
                 			isFreeSoftware = true;
                 		}
                 	%>
                 		id="freeSwApprCheck" onclick="javascript:showhidefreesoftwareapp()"
                 	<%} if(metadata.getMIsInSwTypeTable().equalsIgnoreCase("Y") && metadata.getMAdminFlag().equalsIgnoreCase("V")){%> checked <%}%> value="Y">
                 <input type ="hidden" name= "swMetadaDeletable_<%=recordIndex%>" value ="<%= (String)swMetadataDeletableMap.get(metadata.getMMetadataName())%>">
                 <%//CSCsv19029 - Guest Registered Approval 
                 	// CSCte90976 - Anonymous changed guest reg to free sw publish
                 if("FREE_SW_PUBLISH_ALLOWED".equals(metadata.getMMetadataName())){%>
                	 <input type ="hidden" name= "FreeSwApprFieldName" value="isIncludeInSwType_<%=recordIndex%>"/>
  					 <%if(metadata.getMIsInSwTypeTable().equalsIgnoreCase("Y") && metadata.getMAdminFlag().equalsIgnoreCase("V")){ %>              	 
                	 	<input type ="hidden" name= "freeSwApproverPrevValue" value="required"/>
                 <%}}%>
                
       </span></td>
       
       <td align="center" valign="top"><span class="dataTableData">
           <input type="checkbox" name="isBURequired_<%=recordIndex%>" 
          	<%if(metadata.getMIsBuRequired().equalsIgnoreCase("Y")){%> checked<%}%>  value="Y">
	   </span></td>
        
	   </tr>
	   <%}%>
     </TBODY>
    </TABLE>
<% } %>    
    </td>
  
    <td>
      <img src="../gfx/b1x1.gif" width="30" />
    </td>
     
     
    
    <td valign="top" width="600">
<% if(isSpritAdmin) { %>    
      <table border="1" cellpadding="1" cellspacing="0">
        
       
        <tr bgcolor="#d9d9d9">
    		<td align="center" valign="top" ><span class="dataTableTitle">
	 			Release Component
			</span></td>
    		<td align="center" valign="top" ><span class="dataTableTitle">
	 			Component Name
			</span></td>
		    <td align="center" valign="top" ><span class="dataTableTitle">
	  			Component Display Name
			</span></td>
			<td align="center" valign="top" ><span class="dataTableTitle">
	  			Sequence
			</span></td>
			<td align="center" valign="top" ><span class="dataTableTitle">
	  			Group
			</span></td>
			<td align="center" valign="top" ><span class="dataTableTitle">
	  			Data Type
			</span></td>
	  </tr>
	
       <%  
	List csprSwReleaseComponentList =SoftwareMetadataAdmin.getSwTypeReleaseComponent(osTypeId);  
	int numberOfComponentInDB = csprSwReleaseComponentList.size();
	//System.out.println("From JSP: Number Of Component In DB is "  + numberOfComponentInDB);
	// currently, the release component max size is defined 8
	int size = 8 - (csprSwReleaseComponentList.size());
	if(csprSwReleaseComponentList.size()<8) {
	    for (int j=0; j< size; j++){
	    	CsprSoftwareReleaseComponent component = new CsprSoftwareReleaseComponent();
	    	component.setReleaseComponentGroup("False");
	    	csprSwReleaseComponentList.add(component);
	    }       	
	}
	
	
	for (int i=0;i<csprSwReleaseComponentList.size();i++)  {
		CsprSoftwareReleaseComponent component = (CsprSoftwareReleaseComponent)csprSwReleaseComponentList.get(i);
		//CSCsr29129 - Software Type Configuration Rules for Release Components - aburadka@cisco.com Sep 2008
		//Below condition ensures that the first component in a Release is always MajorRelease with default values for other fields 
		if (i==0 && component.getReleaseComponentName()==null && component.getReleaseComponentLabel()==null && component.getReleaseComponentSeq()==null){
			 component.setReleaseComponentName("MajorRelease");
			 component.setReleaseComponentLabel("Major Release");
			 component.setReleaseComponentSeq(new Integer(1));
			 component.setReleaseComponentGroup("TRUE");
			 component.setReleaseComponentDataType("ALPHANUMERIC");
		}%>
	<tr>
		<input type ="hidden" name="numberOfComponentInDB" value="<%=numberOfComponentInDB%>">
		<td  align="center" valign="top "><span class="dataTableData"> <%=i+1%>
			<input type ="hidden" name= "componentColumn_<%=i%>" value ="<%= component.getReleaseComponentColumn()%>">
		</span></td>
		<td align="left" valign="bottom"><span class="dataTableData">
			 <input type="text" name ="componentName_<%=i%>" 
			 <% if (component.getReleaseComponentName() != null) { %> disabled 
			 value="<%=component.getReleaseComponentName()%>" size ="25">
			 <% } else { %>
			  value="" size ="25">
			  <% } %>
			 <input type ="hidden" name= "componentHiddenName_<%=i%>">
			
		</span></td>
			
		<td  align="left" valign="bottom"><span class="dataTableData">
			<input type="text" name ="componentLabel_<%=i%>"   <% if (component.getReleaseComponentLabel()!=null){%> value="<%=component.getReleaseComponentLabel()%>" <%}%> size ="15">
		</span></td>
		
		<td  align="left" valign="bottom"><span class="dataTableData">	
			<Select name="componentSeq_<%=i%>">
				<option value="">Select</option>
			 	<option value="1"  
			 	    	<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("1")){%> selected <%}%>>1</option>
			 	<option value="2"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("2")){%> selected <%}%>>2</option> 
			 	<option value="3"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("3")){%> selected <%}%>>3</option>
			 	<option value="4"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("4")){%> selected <%}%>>4</option> 
			 	<option value="5"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("5")){%> selected <%}%>>5</option>   
			 	<option value="6"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("6")){%> selected <%}%>>6</option>
			 	<option value="7"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("7")){%> selected <%}%>>7</option>  
			 	<option value="8"  
			 		<%if(component.getReleaseComponentSeq()!=null && (component.getReleaseComponentSeq()).toString().equalsIgnoreCase("8")){%> selected <%}%>>8</option>            
			</select> 
		</span></td>
		
		<td  align="left" valign="bottom" NOWRAP><span class="dataTableData">
          		<input type="radio" name="componentGroup_<%=i%>" value="TRUE"  
          			<%if(component.getReleaseComponentGroup()!=null && component.getReleaseComponentGroup().equalsIgnoreCase("TRUE")){ %> checked <%}%> > True
          		<input type="radio" name="componentGroup_<%=i%>" value="FALSE"  
          			<%if(component.getReleaseComponentGroup()!=null && component.getReleaseComponentGroup().equalsIgnoreCase("FALSE")){ %> checked <%}%> > False
          
       		</span></td>
       		
		<td align="left" valign="bottom"><span class="dataTableData">
			<Select name="componentDataType_<%=i%>">
			              <option value="">Select</option>
			              <option value="NUMBER"  
			              	<%if(component.getReleaseComponentDataType()!=null && (component.getReleaseComponentDataType()).toString().equalsIgnoreCase("NUMBER")){%> selected <%}%>>NUMBER</option>
			              <option value="ALPHANUMERIC"
			                <%if(component.getReleaseComponentDataType()!=null && (component.getReleaseComponentDataType()).toString().equalsIgnoreCase("ALPHANUMERIC")){%> selected <%}%>>ALPHANUMERIC</option>          
			             
			</select> 
		</span></td>
		</tr>
		<%}%>
		
		
		
      </table>

      <br><br>
      <table border="1" cellpadding="1" cellspacing="0">
      <B> Release PM</B> &nbsp &nbsp &nbsp <!--a href="RoleSetupMenu.jsp">Software Type Metadata PM </a-->
                 <tr bgcolor="#d9d9d9">
      	      		<td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      	  	 			Release Project Manager User ID
      	  			</span></td>
      	  	         <% ArrayList pmList = (ArrayList)SoftwareMetadataAdmin.getMetatdataPM(osTypeId);
      	  	            StringBuffer sb = new StringBuffer();
      	  	            for (int i=0;i<pmList.size();i++){
      	  	                String pmUserId = ((CsprSoftwareTypePM)pmList.get(i)).getUserId();
      	  	                String adm_flag = ((CsprSoftwareTypePM)pmList.get(i)).getAdm_flag();
      	  	                if(adm_flag.equalsIgnoreCase("V")){
      	  	            		sb.append(pmUserId);
      	  	            		sb.append(",");
      	  	            	}	
      	  	            }
      	  	          %>  
      	      		  <td align="left" valign="top"><span class="dataTableData">
			        <textarea name="swTypeMetadataPMs" rows="3" cols="58" wrap="soft"><%=sb.toString()%></textarea>
			        <!--a href="RoleSetupMenu.jsp">Software Metadata PM </a-->
      			</span></td>
      	  	        
      	  			
	    </tr>
      </table>
      <br><br>
      <!----BTS-->
      <table border="1" cellpadding="1" cellspacing="0">
      <B> Email Alias </B> &nbsp &nbsp &nbsp 
                 <tr bgcolor="#d9d9d9">
                    <td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
                       CCO Post Email Alias
                    </span></td>
                   <%  
                        String emailAlias = "";
                        try{
                        	emailAlias = SpritUtility.getSpritEmailAliasListString(osTypeId, "TransactionNotificationAlias", System.getProperty("envMode"));
                           }catch(Exception e){
                           	e.printStackTrace();
                           }
                  
      	  	          %>  
                      <td align="left" valign="top"><span class="dataTableData">
                    <textarea name="swTypeCcoPostEmailAlias" rows="3" cols="58" wrap="soft"><%=emailAlias%></textarea>
                  
                </span></td>      
        </tr>
      </table>
      <br><br>
      <!----BTE-->
<% } %>
      <table border="1" cellpadding="1" cellspacing="0">
      <B> Secondary Publisher </B> &nbsp &nbsp &nbsp 
                 <tr bgcolor="#d9d9d9">
                    <td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
                        Secondary Publihser User ID's
                    </span></td>
                     <% List pmList = (ArrayList)SoftwareMetadataAdmin.getSecondaryPublisher(osTypeId);
                        StringBuffer sb = new StringBuffer();
                        for (int i=0;i<pmList.size();i++){
                            String pmUserId = ((CsprSoftwareTypePM)pmList.get(i)).getUserId();
                            String adm_flag = ((CsprSoftwareTypePM)pmList.get(i)).getAdm_flag();
                            if(adm_flag.equalsIgnoreCase("V")){
                                sb.append(pmUserId);
                                sb.append(",");
                            }   
                        }
                        System.out.println( "-------------->" + sb.toString());
                      %>  
                      <td align="left" valign="top"><span class="dataTableData">
                    <textarea name="swTypeSecondaryPublishers" rows="3" cols="58" wrap="soft"><%=sb.toString()%></textarea>
                    <!--a href="RoleSetupMenu.jsp">Software Metadata PM </a-->
                </span></td>      
        </tr>
      </table>
      <br><br>
      
<% if(isSpritAdmin) { %>
<%
    Integer currentReleaseNotesMax = new Integer("0");
    Integer currentImageNotesMax = new Integer("0");
    try {
        if ( osTypeId != null ) {
            ShrOSTypeMDFSWTypeLocalHome myLocalHome = EJBHomeFactory.getFactory().getShrOSTypeMDFSWTypeLocalHome();
            Collection osTypes = myLocalHome.findByOsTypeId(osTypeId);
            Iterator osTypesList = osTypes.iterator();
            ShrOSTypeMDFSWTypeLocal osTypeItem = (ShrOSTypeMDFSWTypeLocal) osTypesList.next();
            if (osTypeItem.getReleaseNotesMax() != null ) {
                currentReleaseNotesMax = osTypeItem.getReleaseNotesMax();
            }
            if (osTypeItem.getImageNotesMax() != null) {
                currentImageNotesMax = osTypeItem.getImageNotesMax();
            }
        }
%>

      <table border="1" cellpadding="1" cellspacing="0">
      <B>Notes Information</B>
      <tr bgcolor="#d9d9d9"><td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      Maximum Number of Release Notes
      </span></td>
      <td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      <select name="maxReleaseNotes">
      <option value=0><%=SoftwareMetadataAdmin.DEFAULT_NOTES_VALUE%></option>
      <% for ( int i = 1; i <= SoftwareMetadataAdmin.MAX_RELEASE_NOTES; i++ ) { %>
      <option value=<%=i%> <%if ( currentReleaseNotesMax.equals(new Integer(i)) ) {%> selected <%}%> ><%=i%></option>
      <% } %>
      </select>
      </span></td>
      </tr> 

      <tr bgcolor="#d9d9d9"><td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle"> 
      Maximum Number of Image Notes
      </span></td>
      <td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      <select name="maxImageNotes">
      <option value=0><%=SoftwareMetadataAdmin.DEFAULT_NOTES_VALUE%></option>
      <% for ( int i = 1; i <= SoftwareMetadataAdmin.MAX_IMAGE_NOTES; i++ ) { %>
      <option value=<%=i%> <%if ( currentImageNotesMax.equals(new Integer(i)) ) {%> selected <%}%> ><%=i%></option>
      <% } %>
      </select>
      </span></td>
      </tr>
<%
      
    } catch (Exception ex) {
        ex.printStackTrace();
    }   
%>      
      </table>
      <br><br>
     <!-- Sprit 7.0 productization -->
     <%
     	String producatization ="N";
     	String createByApp ="SPRIT";
     	if(osTypeId !=null){
     		OSTypeInfo osTypeObj = ManagementMetadataHelper.getOsTypeObjByOsTypeId(osTypeId);
        	producatization = osTypeObj.getProductization()!=null? osTypeObj.getProductization(): "N";
        	createByApp = osTypeObj.getCreatedByApp()!=null?osTypeObj.getCreatedByApp(): "";
        }	
     %>
   
      <table border="1" cellpadding="1" cellspacing="0">
      <B>Productization Information</B>
      <tr bgcolor="#d9d9d9">
      	<td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      		Productization 
      	</span></td>
      	<td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      		<select name="isProductization" STYLE="width: 90px">
      			<option value="N" <%if(producatization.equalsIgnoreCase("N")){ %> selected <%} %> >N </option>
      			<option value="Y" <%if(producatization.equalsIgnoreCase("Y")){ %> selected <%} %>>Y </option>
      		</select>
      	</span></td>
      </tr> 
      <tr bgcolor="#d9d9d9">
      	<td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      		Created by Application
      	</span></td>
      	<td align="center" valign="top" colspan="5" NOWRAP><span class="dataTableTitle">
      		<select name="createdByApp" >
      			<option value="SPRIT" <%if("SPRIT".equalsIgnoreCase(createByApp)){ %> selected <%} %>>SPRIT</option>
      			<option value="CISROMM" <%if("CISROMM".equalsIgnoreCase(createByApp)){ %> selected <%} %>>CISROMM</option>
      		</select>
      	</span></td>
      </tr> 
      
      </table>
	 
      <br><br>
      <table id="tblSDSSortInfo" class="dataTable" width="85%">
      <tr>
			<td valign="top" width="35%">SDS Sort Field</td>
			<td valign="top" width="30%">SDS Sort Order</td> 
			<td valign="top" width="35%">SDS Sort Seq</td>
							
			<td width="10%"> <input type="button" value="Add Row" id="sdsSortAddBtn" onclick="addSDSSortInfo();" /></td>
      </tr>
      <% OsTypeMDFSwTypeVo vo = SoftwareMetadataAdmin.getSDSSortInfo(osTypeId);
      	 String sdsPrimarySortBy = vo.getPrimarySortField();
      	 String sdsPrimarySortOrder = vo.getPrimarySortOrder();
      	 String sdsSecondarySortBy = vo.getSecondarySortField();
      	 String sdsSecondarySortOrder = vo.getSecondarySortOrder();
      	 
	  if(vo.getPrimarySortField()!=null){%>
      <tr>
	  	 <td>
			<select name="sdsSortBy" >
		 	   <option value="Publish_Date" <%if("Publish_Date".equalsIgnoreCase(sdsPrimarySortBy)){%> selected <%} %>>Publish Date</option>
      		   <option value="File_Name"   <%if("File_Name".equalsIgnoreCase(sdsPrimarySortBy)){%> selected <%}%>>Image Name </option>
      		   <option value="Round_File_Size" <%if("Round_File_Size".equalsIgnoreCase(sdsPrimarySortBy)){%> selected <%}%>>File Size </option>
     		</select>
      	</td>	
      	<td>
			<select name="sdsSortOrder" >
				<option value="DESC" <%if("DESC".equalsIgnoreCase(sdsPrimarySortOrder)){%> selected <%}%>>DESC</option>
      			<option value="ASC" <%if("ASC".equalsIgnoreCase(sdsPrimarySortOrder)){%> selected <%}%>>ASC </option>
     		</select>
      	</td>	
		<td>Primary</td>			
		<td><input type="button" value="Delete" id="sdsSortDeleteBtn" onclick="removeSDSSort(this);" /></td>
	  </tr>	
	  <%} if(vo.getSecondarySortField()!=null){%>
		<tr>
			<td>
				<select name="sdsSortBy" >
					<option value="File_Name" <%if("File_Name".equalsIgnoreCase(sdsSecondarySortBy)){%> selected <%} %>> Image Name </option>
					<option value="Publish_Date" <%if("Publish_Date".equalsIgnoreCase(sdsSecondarySortBy)){%> selected <%} %>>Publish Date</option>
      				<option value="Round_File_Size"<%if("Round_File_Size".equalsIgnoreCase(sdsSecondarySortBy)){%> selected <%}%>>File Size </option>
      			</select>
      		</td>	
      		<td>
				<select name="sdsSortOrder" >
					<option value="ASC" <%if("ASC".equalsIgnoreCase(sdsSecondarySortOrder)){%> selected <%}%>>ASC </option>
					<option value="DESC" <%if("DESC".equalsIgnoreCase(sdsSecondarySortOrder)){%> selected <%}%>>DESC</option>
     			</select>
      		</td>	
			<td>Secondary</td>			
			<td><input type="button" value="Delete" id="sdsSortDeleteBtn" onclick="removeSDSSort(this);" /></td>
		</tr>	
		<%}%>
   </table>
   <!-- CSCsv19029 Guest Registered Approval List -->
   <div id="groupRegApprDiv" 
	       style="<%if(isFreeSoftware){%>
	       	visibility:visible;height:100%;overflow:auto;<%}else{%>visibility:none;height:10px;overflow:hidden;<%}%>">
	  <br><br>
	    <table class="dataTable" width="85%">
	    <B>Approval For Publishing Free Software</B>
   		<tbody id="freeSwAppTbody">
   		<tr align="center" bgcolor="#d9d9d9">
   			<td valign="top">
				<input type="hidden" name="freeSwAppType" value=""/>
				<input type="hidden" name="freeSwAppType" value=""/>
   				<span class="dataTableTitle">Approver Type</span>
   			</td>
   			<td valign="top">
				<input type="hidden" name="freeSwAppId" value=""/>
				<input type="hidden" name="freeSwAppId" value=""/>
				<input type="hidden" name="newAppId" value="Y">
				<input type="hidden" name="newAppId" value="Y">
   				<span class="dataTableTitle">Approver Id</span>
   			</td>
   			<td valign="top">
   				<span class="dataTableTitle">Approval Status</span>
   			</td>
   			
   			<td valign="top" width="31%">
   			    <input type="hidden" name="freeSwAppComments" value=""/>
				<input type="hidden" name="freeSwAppComments" value=""/>
				<span class="dataTableTitle">Comments</span>
			</td>
   			
   			<td valign="top" width="10%">
   				<input type="button" value="Add Approver" onclick="javascript:addGroupRegRow();"/>
   			</td>
   		</tr>
	 	<%try {
	 		CsprAccessLevelApprovalLocal apprBean = null;
	 		String approverId = null;
	 		String approverType = null;
	 		String approvalStatus = null;
	 		String approvalComments = null;
		 	Context ctx = JNDIContext.getInitialContext();
	     	CsprAccessLevelApprovalLocalHome home = (CsprAccessLevelApprovalLocalHome)ctx.lookup("ejblocal:CsprAccessLevelApprovalBean.CsprAccessLevelApprovalHome");
	     	Collection freeSoftwareApprCollection = (Collection)home.findAllFreeSwApprByOsId(osTypeId);
	     	if(freeSoftwareApprCollection!=null && freeSoftwareApprCollection.size() > 0){%>
		    	<%Iterator itAppr = freeSoftwareApprCollection.iterator();
	     		while(itAppr.hasNext()){
	     			apprBean = (CsprAccessLevelApprovalLocal)itAppr.next();
	     			approverId = apprBean.getApproverId();
	     			approverType = apprBean.getApproverType();
	     			approvalStatus = apprBean.getStatus();
	     			approvalComments = apprBean.getApprovalComment();
   			        boolean isRowDeletable = false;
					if("pending".equals(approvalStatus)){
						isRowDeletable = true;
					}
	     			%>
     				<tr>
     					<td>
								<Select name="freeSwAppType">
								<%
								Iterator itFreeSwApprTypeMetaData = freeSoftwareApproverTypes.iterator();
								while(itFreeSwApprTypeMetaData.hasNext()){
									List apprTypeMetaData = (List)itFreeSwApprTypeMetaData.next();
									String apprType = (String)apprTypeMetaData.get(0);%>
									<option value="<%=apprType%>"
									<%if(apprType.equals(approverType)){%>
										selected
									<%}%>
									><%=apprType%></option>
								<%}%>
								</Select>
     					</td>
     					<td>
     		        			<input type="hidden" name="newAppId" value="N">
		        			<input type="hidden" name="freeSwAppId" value="<%=approverId%>"/>
     						<%=approverId%>
     					</td>
     					<td>
     						<i><%if("pending".equals(approvalStatus)){%>
     							<font style="color:#ff0000;"><%=approvalStatus%></font>
     						<%}else{%>
     							<%=approvalStatus%>
     						<%}%></i>
     					</td>
     					
     					
 <td>
     <%if(approvalComments==null || "null".equals(approvalComments)){
          approvalComments = "";
     }%>
  <span class="dataTableData">
      <!-- <textarea rows="3" cols="20" name="freeSwAppComments" onchange="onChangeTrackOsId('<%=osTypeId%>');"><%=approvalComments%></textarea>
           <input type="hidden" name="freeSwAppComments" value="<%=approvalComments%>"/>
       -->
     <textarea rows="3" cols="20" name="freeSwAppComments"><%=approvalComments%></textarea>
  </span>
 </td>

     					
     					
     					<td>
     						<input id="groupRegRow" type="button" value="Delete" onclick="javascript:delGroupRegRow(this);"
							<%if(!isRowDeletable){%>
									 disabled
							<%}%>/>
     					</td>
     				</tr>
     				
	     		<%}%>
	     	<%	
	     	}
	     	
	 	}catch (Exception e)   {
            e.printStackTrace();
            throw new EJBException();
        }	     	
     %>
    	</tbody>
	</table>
	<br><br>
   </div>
      
<% } %>
    </td>
     
  </tr> 
  
  
  <!--tr>
   <td align="right">
      <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates2')"
			onclick="javascript:validateAndSubmitForm()"
		    onmouseout="actionBtnSaveImages('btnSaveUpdates2')" alt="Save Updates"
		    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates2>
    </td>
  </tr-->
</table>

<table>
<tr>
   <td align="right">
      <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates2')"
			onclick="javascript:validateAndSubmitForm()"
		    onmouseout="actionBtnSaveImages('btnSaveUpdates2')" alt="Save Updates"
		    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates2>
    </td>
  </tr>
</table>
<% } %>
</FORM>
</center>

<%= Footer.pageFooter(globals) %>
<!-- end -->
