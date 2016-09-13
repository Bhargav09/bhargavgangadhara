<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
: @author Kelly Hollingshead (kellmill) CSCsc19024, modified for clone function.
: @author Holly Chen (holchen@cisco.com) Add releaseNotes/ImageNotes CSCsi47314;
: @author Holly Chen (holchen@cisco.com) Sprit 7.0 MCP productization for management metadata
:
: Copyright (c) 2005-2008 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import = "com.cisco.eit.sprit.ui.SpritGUI,
                   com.cisco.eit.sprit.ui.SpritGUIBanner,
                   com.cisco.eit.sprit.ui.SpritReleaseTabs,
                   com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import = "com.cisco.eit.sprit.model.csprjdbc.CsprSoftwareTypeMetaDataJdbc" %>
<%@ page import = "com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import = "com.cisco.eit.sprit.beans.SwtypeReleaseComponent" %>
<%@ page import = "com.cisco.eit.sprit.dataobject.CsprReleaseNotesInfo"%>
<%@ page import = "com.cisco.eit.sprit.dataobject.CsprImageRecordInfo" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import = "com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import = "com.cisco.eit.sprit.dataobject.CsprImageRecordInfo" %>
<%@ page import = "com.cisco.eit.sprit.util.RelatedSoftwareHelper"%>
<%@ page import = "com.cisco.eit.sprit.util.SpritPropertiesUtil" %>
<%@ page import = "com.cisco.eit.sprit.ui.dataobject.ReleaseInfo" %>
<%@ page import = "com.cisco.eit.sprit.logic.managmentMetadata.ManagementMetadataHelper" %>
<%@ page import = "com.cisco.eit.sprit.dataobject.PlatformOsTypeObject"%>
<%@ page import = "com.cisco.eit.sprit.dataobject.PlatformMdfVo"%>
<%@ page import = "com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import = "com.cisco.eit.sprit.util.QueryUtil" %>
<%@ page import="com.cisco.eit.sprit.util.StringComparator"%>
<%@ page import="com.cisco.eit.sprit.utils.FreeSwApprovalQueryUtil"%>
<!-- CSCud06651	-->
<%@ page import="com.cisco.eit.sprit.model.dao.csprfeatureset.CsprFeatureSetDAO"%>
<%@page import="com.cisco.eit.sprit.dataobject.FeatureSetNonIosInfo"%>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<!--CSCud06651 -->

<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.Vector" %>
<%@ page import = "java.util.Collection" %>
<%@ page import="java.util.Collections"%>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.Iterator" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.lang.Exception" %>

<%
  Integer               osTypeId            = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;
  SpritAccessManager    spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  boolean               isSoftwareTypePM    = false;
  
  String htmlButtonAddImages1;
  
  HashMap mdfConceptNameHmap=null;
  HashMap    allMachineOsTypeNameHmap = null;
  
//=====
    String  releaseNumber          = "";
    String  imageName              = "";
    String  imageDescription       = "";
    Vector machineOsTypeIdV        = new Vector();
    HashMap machineOsTypeNameHmap  = new HashMap();
    Iterator machineOsTypeNameIterator = null;
    String  memory                 = "";
    String  hardDiskFootprint      = "";
    String  releaseNotesUrl        = "";
    String  installationDocUrl     = "";
    String  productCode            = "";
    String  isSoftwareAdvisory     = "";
    String  softwareAdvisoryDocUrl = "";
    String  isDeferred             = "";
    String  deferralAdvisoryDocUrl = "";
    String  isRelatedSoftware      = "";
    String  sourceLocation         = "";
    String  osType                 = "";
    String  message                = "";
    String hiddenMdfName           = "";
    String hiddenMdfId             = "";
    String    mReleaseComponent[] = new String[8];
    String releaseMessage ="";
        
    
    //6.9 related software
    session.removeAttribute("relatedSoftwareMap");
    session.removeAttribute("platformMap");

//=====
  if ( WebUtils.getParameter(request,"monActionStr") != null ) {
     MonitorUtil.cesMonitorCall(WebUtils.getParameter(request,"monActionStr"), request);
  }
  
  Vector csprSoftwareTypeMetaDataNameV = null;
  CsprImageRecordInfo csprImageRecordInfo=null;
  Iterator csprImageRecordsVector = null;
  Collection csprImageRecordsColl = null;
  
  //add for Release Notes and Image Notes  
  CsprReleaseNotesInfo releaseNotesInfoVo = null;
  CsprImageRecordInfo imageNotesInfoVo = null;
  //Map imageNotesMap = null;
 
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );

  nonIosCcoPostHelper = new NonIosCcoPostHelper();
  String strMode = nonIosCcoPostHelper.getMode(request);

  if ( session.getAttribute("csprImageRecordInfo") == null ) {

    try{
      osTypeId = new Integer(WebUtils.getParameter(request,"osTypeId"));
      String releaseName = WebUtils.getParameter(request,"releaseName");
      imageName = WebUtils.getParameter(request,"imageName");
       	
      csprImageRecordsColl = CsprImageDataJdbc.getCsprImageRecord(osTypeId,releaseName,imageName);
      ArrayList csprImageRecordsArray = new ArrayList(csprImageRecordsColl);
      if ( csprImageRecordsArray != null ) {
        csprImageRecordsVector = csprImageRecordsArray.iterator();
	    while ( csprImageRecordsVector.hasNext() ) {
          csprImageRecordInfo = (CsprImageRecordInfo) csprImageRecordsVector.next();
	    }
      }
      // get the release notes info Value object
	  releaseNotesInfoVo = CsprImageDataJdbc.getReleaseNotes(releaseName, osTypeId);
	  if(csprImageRecordInfo!= null){
	  	if(releaseNotesInfoVo.getReleaseMessage()!=null) 
	  		releaseMessage = releaseNotesInfoVo.getReleaseMessage();
	  	csprImageRecordInfo.setReleaseNotesLabel(releaseNotesInfoVo.getReleaseLabel());
	  	csprImageRecordInfo.setReleaseNotesURL(releaseNotesInfoVo.getReleaseURL());
	  	csprImageRecordInfo.setReleaseNotesSRC(releaseNotesInfoVo.getReleaseSRC());
	  }	
	 
    //get the image notes map
      imageNotesInfoVo  = CsprImageDataJdbc.getImageNotes(releaseName, osTypeId, imageName);
      if(csprImageRecordInfo!=null){
	  	csprImageRecordInfo.setImageNotesLabel(imageNotesInfoVo.getImageNotesLabel());
	  	csprImageRecordInfo.setImageNotesURL(imageNotesInfoVo.getImageNotesURL());
	  	csprImageRecordInfo.setImageNotesSRC(imageNotesInfoVo.getImageNotesSRC());
	  }	
      
      //get platformIdList
      //if(csprImageRecordInfo!=null){
      	//List platformIdList = ManagementMetadataHelper.getPlatformListByImageId(csprImageRecordInfo.getImageId());
      	//csprImageRecordInfo.setPlatformIdList(platformIdList);
      //}	
          
    }catch( Exception fe ) {
  	  System.out.println("Exception in create metadata page");
  	  fe.printStackTrace();
    }
  } else {
     csprImageRecordInfo = (CsprImageRecordInfo) session.getAttribute("csprImageRecordInfo");
  }

    if ( csprImageRecordInfo != null ) {
      osType                 = csprImageRecordInfo.getOsTypeName();
      osTypeId               = csprImageRecordInfo.getOsTypeId();
      releaseNumber          = csprImageRecordInfo.getReleaseName();
      imageName              = csprImageRecordInfo.getImageName();
      imageDescription       = (csprImageRecordInfo.getImageDescription()!= null &&  !"null".equalsIgnoreCase(csprImageRecordInfo.getImageDescription())) 
      								? csprImageRecordInfo.getImageDescription() : "";
      //machineOsTypeIdList    = (String[])session.getAttribute("machineOsTypeIdList");  
      if(csprImageRecordInfo.getMemoryFootprint() != null) {
        memory                 = (csprImageRecordInfo.getMemoryFootprint()).toString();
      }
      if (csprImageRecordInfo.getHardDiskFootprint() != null) {
        hardDiskFootprint      = (csprImageRecordInfo.getHardDiskFootprint()).toString();
      }
    
      releaseNotesUrl        = csprImageRecordInfo.getReleaseDocUrl();
      installationDocUrl     = csprImageRecordInfo.getInstallationDocUrl();
      productCode            = (csprImageRecordInfo.getProductCode() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getProductCode())) 
      								? csprImageRecordInfo.getProductCode() : "";
      if(productCode==null || "null".equals(productCode)) productCode="";

      isSoftwareAdvisory     = csprImageRecordInfo.getIsSoftwareAdvisory();
      softwareAdvisoryDocUrl = csprImageRecordInfo.getSoftwareAdvisoryDocUrl();
      if(softwareAdvisoryDocUrl==null || "null".equalsIgnoreCase(softwareAdvisoryDocUrl)) {
         softwareAdvisoryDocUrl="";
       }

      isDeferred             = csprImageRecordInfo.getIsDeferred();
      deferralAdvisoryDocUrl = csprImageRecordInfo.getDeferralAdvisoryDocUrl();

       if(deferralAdvisoryDocUrl==null || "null".equalsIgnoreCase(deferralAdvisoryDocUrl)) {
         deferralAdvisoryDocUrl="";
       }

      isRelatedSoftware      = csprImageRecordInfo.getIsRelatedSoftware();
      sourceLocation         = (csprImageRecordInfo.getSourceLocation()!= null && !"null".equalsIgnoreCase(csprImageRecordInfo.getSourceLocation()))
      							? csprImageRecordInfo.getSourceLocation(): "";
      osType                 = csprImageRecordInfo.getOsTypeName();   
   	  mdfConceptNameHmap = csprImageRecordInfo.getMdfConceptName();
      machineOsTypeNameHmap  = csprImageRecordInfo.getMachineOsTypeName();
      mReleaseComponent[0] = csprImageRecordInfo.getReleaseComponent1();
      mReleaseComponent[1] = csprImageRecordInfo.getReleaseComponent2();
      mReleaseComponent[2] = csprImageRecordInfo.getReleaseComponent3();
      mReleaseComponent[3] = csprImageRecordInfo.getReleaseComponent4();
      mReleaseComponent[4] = csprImageRecordInfo.getReleaseComponent5();
      mReleaseComponent[5] = csprImageRecordInfo.getReleaseComponent6();
      mReleaseComponent[6] = csprImageRecordInfo.getReleaseComponent7();
      mReleaseComponent[7] = csprImageRecordInfo.getReleaseComponent8();
      releaseMessage       = csprImageRecordInfo.getReleaseMessage();
      
      
      session.removeAttribute("csprImageRecordInfo");
    }

 
   //if(request.getParameter("callingForm")!=null) { 
       		message = (String) session.getAttribute("message");
                  if(message == null || "null".equalsIgnoreCase(message)) message="";

       		session.removeAttribute("message");
       //}
       //System.out.println("message inside CsprCreateMetaData.jsp      " +message);
       
  
  if(osType == null || osType.equals("")) {
    osType = (String) request.getAttribute("osType");
    osTypeId = (Integer) request.getAttribute("osTypeId");
  }


  // Get os type ID.  Try to convert it to an Integer from the web value!
  try{
    if(osType == null || osType.equals("")) {
     osTypeId = nonIosCcoPostHelper.getOSTypeId(request); 
     //osTypeId = request.getParameter("osTypeId");
    }
  } catch ( Exception e ) {
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  osType = nonIosCcoPostHelper.getOSType(osTypeId);
  
  if(osType == null || osType.equals("")) {
    // No os type!  Bad!  Redirect to error page.
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId); 

  if (!isSoftwareTypePM && !NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
    response.sendRedirect(NonIosCcoPostHelper.REDIRECT_URL + 
                          NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" +
                          NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId);
  }

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(strMode != null && NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNav(globals,osType)
    );
  } else {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNav(globals,osType,releaseNumber)
    );
  }

   List listOfComponents = CsprSoftwareTypeMetaDataJdbc.getSwtypeReleaseComponentByOsTypeId(osTypeId) ;
  //html macros
   // html macros
    String pathGfx = globals.gs( SpritConstants.PATH_GFX );
    htmlButtonAddImages1 = SpritGUI.renderButtonRollover(
    	globals,
    	"btnAddImages1",
    	"Add Images",
    	"javascript:validateAndsubmitForm('csprCreateMetaData')",
    	pathGfx + "/" + "btn_image_add.gif",
      	"actionBtnSaveUpdates('btnAddImages1')",
	"actionBtnSaveUpdatesOver('btnAddImages1')"
  	);
    
    
   // Get MinFlash and MinDram Arrays
    //spritPropertiesUtil = new SpritPropertiesUtil(globals.gs("envMode"));
    String[] minFlashArr;
    String[] minDramArr;
    minFlashArr =  SpritPropertiesUtil.getMinFlashArray();
    minDramArr = SpritPropertiesUtil.getMinDramArray();
    
    //for clone
    String pageAction = request.getParameter("pageAction")!=null?request.getParameter("pageAction"):"";
%>

<link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css">
<link rel="stylesheet" type="text/css" href="../css/ext-date-sprit.css">
<script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
<script language="JavaScript" src="../js/sprit.js"></script>

<form name="softwareSelection" action="<%= globals.gs("currentPage")  %>" method="get">
<%= SpritGUI.pageHeader( globals,"mmd","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getOSTypeTabs(globals,"mmd") %>
<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>
</form>
<form name="csprCreateMetaData" method="post" action="CsprImageProcessor">



<script type="text/javascript" src="../js/prototype.js"></script>
<script type="text/javascript" src="../js/datetimepicker.js">
	//Date Time Picker script- by TengYong Ng of http://www.rainforestnet.com
	//Script featured on JavaScript Kit (http://www.javascriptkit.com)
	//For this script, visit http://www.javascriptkit.com 
</script>



<script language="javascript">
<!--
// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================

  //---
  //........................................................................
  // DESCRIPTION:
  //     Submits this form and checks for errors.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  
  function validateAndsubmitForm(formName) {
    var formObj = document.forms[formName];
    var imageNameValidRegex = new RegExp( "^[a-zA-Z0-9\-_\.]+$" );

    // Add validation for required release number field.
    if ( formObj.releaseNumber.value == "" ) {
       alert("Release Number is a required field.");
       return false;
    }
    
    // Add validation for required image name field.
    if ( formObj.imageName.value.length == 0) {
       alert("Image Name is a required field.");
       return false;
    }
    
   
    if( !imageNameValidRegex.test(formObj.imageName.value) ) {
    	alert( "Image Name can not have special characters, only A-Z,a-z,0-9, -, _ and . are allowed" );
    	return false;
	}    
    
    // add validation for unique release number/image name pair.
    if ( formObj.releaseNumber.value == "<%=releaseNumber%>" 
      && formObj.imageName.value == "<%=imageName%>" ) {
       alert("You must change either the release number or image name values before adding this image.");
       return false;
    }
    
   // Prevent image file name format like .pl,.cgi, CSCsq32937 sprit 7.2.1
   var imgName = document.forms[formName].imageName.value;
   var fileFormat = imgName.toUpperCase().substring(imgName.lastIndexOf(".") + 1);
   //CSCug34471 : Checking inverted (?) in Image Description
   var formData = document.csprCreateMetaData.imageDescription.form;
   var description = formData.imageDescription.value;
   if(description.indexOf('¿')>=0){
	   alert("Image Description contains invalid character ¿");
	   return false;
   }
   //alert(fileFormat);
   var invalidFileArray = new Array();
   <% for (int i=0; i< QueryUtil.getInvalidFileFormat().size(); i++){%>
	   invalidFileArray[<%=i%>] = '<%=((String)QueryUtil.getInvalidFileFormat().get(i)).toUpperCase()%>';
   <%}%>
   for(i=0;i<invalidFileArray.length;i++) {
		 var name = invalidFileArray[i];
	     if(fileFormat == name){
	       alert("Image name file format is wrong!");
	       return false;
	    }
   }
       
    	
    errorMessage = objReleaseNotes.validateReleaseNotes();
    if(errorMessage!=''){
    	alert(errorMessage);
    	return false;	
    }
    
    //CSCsr29132 - Checks if the image name is duplicate within a Software Type
    if (imgName != null && imgName.length >0 ) {
    	cursor_wait();
	   	var url = 'NonIosAjaxHelper';
	   	var pars = 'imageName='+ imgName +'&action=checkDuplicateImageName';
	   	var ajax_req = new Ajax.Request(
				url,
			   	{
			   		method: 'post',
			   		parameters: pars,
			   		asynchronous: false,
			   		onComplete:function(req) {}
			   	});
		cursor_clear();
		if(trim(ajax_req.transport.responseText)!=''){
			var rtnVal = trim(ajax_req.transport.responseText);
	  		if(rtnVal.indexOf('true')==0){
	  			alert('Image Name "' + imgName + '" already exist for Software Type '+rtnVal.substring(5)+'\nPlease verify and change Image Name to continue.');
	  			return false;
	  		}
		}
	}
	
	// validates the fields software adv, deferral adv, image source location, image doc url and image doc source location
	if(!validateMetadataFields(formName, imgName)) {
		return false;
	}
        
    formObj.submit();
  }
  
  function actionBtnSaveUpdates(elemName) {
  	if( document.forms['csprCreateMetaData'].elements['_submitformflag'].value==0 ) {
  	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
  	}  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
  	if( document.forms['csprCreateMetaData'].elements['_submitformflag'].value==0 ) {
  	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
  	}  // if
  }

function changeSoftwareType() {
   document.csprCreateMetaData.submit();
   return true;
}

function changeSoftwareType() {
   document.softwareSelection.submit();
   return true;
}

function trim(str) {
       for (var k=0; k<str.length && str.charAt(k)<=" " ; k++) ;
       var newString = str.substring(k,str.length)
       for (var j=newString.length-1; j>=0 && newString.charAt(j)<=" " ; j--) ;

       return newString.substring(0,j+1);
  }
  
 
			// Release Notes
			 //-----------------release Notes-----------------------------------------------------------------------------------------------
			   			  release_max_row = 4;
			              release_count =0;
			  
			  			//add a new row to the table release notes
			  			function addReleaseUrlRow()
			  			{
			  				
			  				var tblReleaseNoteTable = document.getElementById('tblReleaseNoteTable');
			  				var releaseAddBtn = document.getElementById("addBtn");
			  				
							
			  				
			  				if(tblReleaseNoteTable.rows.length<release_max_row){
			  					//add a row <tr> to the rows collection and get a reference to the newly added row
			  					var newRow = document.getElementById('tblReleaseNoteTable').insertRow(tblReleaseNoteTable.rows.length);
			  					  							
			  				
			  					//add 3 cells (<td>) to the new row and set the innerHTML to contain text boxes
			  					var oCell = newRow.insertCell(0);
			  					oCell.innerHTML = "<input type='text' size='20' maxlength='60'  name='releaseLabel' id ='releaseLabel' value = '' />";
			  				
			  								
			  					var oCell = newRow.insertCell(1);
			  					var inputReleaseURL = "<input type='text' size='30' maxlength='1000' name='releaseURL' id='releaseURL' value = '' />";
			  					oCell.innerHTML = inputReleaseURL;
			  					
			  					var oCell = newRow.insertCell(2);
			  					var inputReleaseSRC = "<input type='text' size='30' maxlength='1000' name='releaseSRC' id='releaseSRC' value = '' />";
			  					oCell.innerHTML = inputReleaseSRC;
			  					
			  					var oCell = newRow.insertCell(3);
			  					oCell.innerHTML= "<input type='button' id ='deleteBtn' value='Delete' onclick='removeReleaseRow(this);'/>";	
			  					
			  					release_count++;
			  					if(tblReleaseNoteTable.rows.length==release_max_row) releaseAddBtn.disabled= true;
			  				}
			  				
			  				
			  			}
			  			
			  			//deletes the specified row from the table
			  			function removeReleaseRow(src)
			  			{
			  				/* src refers to the input button that was clicked.	
			  				   to get a reference to the containing <tr> element,
			  				   get the parent of the parent (in this case case <tr>)
			  				*/			
			  				var oRow = src.parentNode.parentNode;		
			  				var releaseAddBtn = document.getElementById("addBtn");
			  				
			  				//once the row reference is obtained, delete it passing in its rowIndex			
			  				document.getElementById("tblReleaseNoteTable").deleteRow(oRow.rowIndex);	
			  				releaseAddBtn.disabled=false;
			  				release_count--;
						}
			//-----------------End Release notes --------------------------------------------------------------------------------------------  
			
			
			//--------------------------------- Image Notes------------------------------------------------------------------------------------
			//add a new row to the table for image notes
						image_max_row = 4;
			                        image_count =0;
						function addImageUrlRow()
						{
							
						     var tblImageNoteTable = document.getElementById('tblImageNote');
						     var imageAddBtn = document.getElementById("imageNotesAddBtn");
			  				
						     if(tblImageNoteTable.rows.length<image_max_row){	
							//add a row to the rows collection and get a reference to the newly added row
							var newRow = document.getElementById("tblImageNote").insertRow(tblImageNoteTable.rows.length);
							
							//add 3 cells (<td>) to the new row and set the innerHTML to contain text boxes
							var oCell = newRow.insertCell(0);
							oCell.innerHTML = "<input type='text' size='20' maxlength='60' name='imageLabel' id='imageLabel' value='' />";
							
											
							var oCell = newRow.insertCell(1);
							var inputImageURL = "<input type='text' size='30' maxlength='1000' name='imageUrl' id='imageUrl' value='' />";
							oCell.innerHTML = inputImageURL;
							
							var oCell = newRow.insertCell(2); 
							var inputImageSRC = "<input type='text' size='30' maxlength='1000' name='imageSRC' id='imageSRC' value='' />";
							oCell.innerHTML = inputImageSRC;
							
							var oCell = newRow.insertCell(3);
							oCell.innerHTML ="<input type='button' value='Delete' onclick='removeImageRow(this);'/>";
							
							image_count++;
			  				if(tblImageNoteTable.rows.length==image_max_row) imageAddBtn.disabled= true;
						     }	
						}
						
						//deletes the specified row from the table
						function removeImageRow(src)
						{
							/* src refers to the input button that was clicked.	
							   to get a reference to the containing <tr> element,
							   get the parent of the parent (in this case case <tr>)
							*/			
							var oRow = src.parentNode.parentNode;	
							var imageAddBtn = document.getElementById("imageNotesAddBtn");
							
							//once the row reference is obtained, delete it passing in its rowIndex			
							document.getElementById("tblImageNote").deleteRow(oRow.rowIndex);	
							imageAddBtn.disabled=false;
			  				image_count--;
						}			
  


	var objReleaseNotes = {
	
		
		validateReleaseNotes: function(){
					var errorMessage = '';
					var unsupportedHTML = '';
										
					//Image Label not empty
					if(this.arrayFieldIsRequired(document.getElementsByName('imageLabel'))){
						errorMessage = errorMessage + 'Image Label is Required\n';
					}
										
					//image label not unique
					//var imageLabelArray = document.getElementsByName("imageLabel");
					//if(!this.arrayFieldIsUnique(imageLabelArray)) {
						//errorMessage = errorMessage + 'Duplicate Image Labels found \n';
					//}
					
					//image URL not unique
					var imageUrlArray = document.getElementsByName('imageUrl');
					if(!this.arrayFieldIsUnique(imageUrlArray)) {
						errorMessage = errorMessage + 'Image URL must be unique \n';
					}
										
					//image URL not empty 
					if(this.arrayFieldsRequired(document.getElementsByName('imageUrl'), document.getElementsByName('imageSRC'))) {
						errorMessage = errorMessage + 'Image URL / Source Location is Required, provide either Image Notes URL or Source Location not both\n';
					}
					
					// Check and make sure Image Source Location doesn't have any special chars
					var imageSRCValidRegex = new RegExp( "^[a-zA-Z0-9\-_\./]+$" );
    				if( this.arrayFieldPatternCheck(document.getElementsByName('imageSRC'), imageSRCValidRegex) ) {
    					errorMessage = errorMessage + 'Image Doc Source Location can not have special characters, only A-Z,a-z,0-9, -, _, /, and . are allowed\n';
					}
					
					// Check and make sure user keyed in allowed file formats
					// for now restricting .htm files as WCM team doesn't render .htm files
					var fileTypes = new Array();
					fileTypes[0] = new RegExp( ".htm$" );
					if ( this.arrayFieldFileTypeCheck(document.getElementsByName('imageSRC'), fileTypes) ) {
						errorMessage = errorMessage + 'Image Doc Source Location can not have .htm file type, please rename file to .html\n';
					}
					
					return errorMessage;
				},
				
				checkText: function(text,allowedTags) {
					var returnMsg = '';
					var invalidTag = false;
					// Pattern to strip HTML Tags from text
					var pattern = /<\/?\s*\w+\s*(\s*\w+\s*=?\s*[\"|\']?(\s*[^ >]*\s*)*[\"|\']?)*\s*\/?>/g;
					var arrHtmlTags = text.match(pattern);
					if(arrHtmlTags != null) {
						for(i=0;i<arrHtmlTags.length;i++){
							var wordPattern = /\w+/g;
							var arrTag = arrHtmlTags[i].match(wordPattern);
							// Loop through allowed HTML tags to check if
							// this HTML tag is valid
							if (allowedTags != null && allowedTags.length > 0) {
								for(j=0;j<allowedTags.length;j++){
									if(arrTag[0].toLowerCase() != allowedTags[j]){
										invalidTag = true;
									}else{
										invalidTag = false;
										break;
									}
								}
							}
							//break out of for loop if an invalid tag is found
							if (invalidTag)
								break;
						} //for
					}
					
					if(invalidTag)
						returnMsg = 'Unsupported HTML Tag found\n';
					return returnMsg;	
				},
				
				arrayFieldIsRequired: function(objArr) {
					var flag = false;
					if (objArr != null) {
						if (isNaN(objArr.length)) {
							var tmp = objArr;
							objArr = new Array();
							objArr[0] =  tmp;
							
						}
						for(i=0;i<objArr.length;i++) {
							if (trim(objArr[i].value).length == 0) {
								flag = true;
								break;
							}
						}
					}
					return flag;			
				},
				
				
				arrayFieldsRequired: function(object1, object2) {
					var flag = false;
					if ((object1 == null) && (object2 == null)) {
						return flag;
					}
					
					var object1length = 0;
					if (object1 != null) {
						if (isNaN(object1.length)) {
							var tmp = object1;
							object1 = new Array();
							object1[0] = tmp;
						}
						object1length = object1.length;
					}
					
					var object12ength = 0;
					if (object2 != null) {
						if (isNaN(object2.length)) {
							var tmp = object2;
							object2 = new Array();
							object2[0] = tmp;
						}
						object2length = object2.length;
					}
					var maxLength = Math.max(object1length, object2length);
					for(i=0; i < maxLength; i++) {
						if (object1[i] != null) {
							if (object1[i].value.length == 0) {
								flag = true;
							}
						}
						
						if (object2[i] != null) {
							if (flag) {
								if (object2[i].value.length == 0) {
									break;
								} else {
									flag = false;
								}
							} else {
								if (object2[i].value.length != 0) {
									flag = true;
									break;
								}
							}
						}
					}
					return flag;
				},
				
				
				arrayFieldPatternCheck: function(objArr, regExPattern) {
					var flag = false;
					
					if (objArr == null) {
						return flag;
					}
					
					if (isNaN(objArr.length)) {
						var tmp = objArr;
						objArr = new Array();
						objArr[0] = tmp;
					}
					
					for (i = 0; i < objArr.length; i++) {
						if (objArr[i].value.length != 0) {
							if (!regExPattern.test(objArr[i].value)) {
								flag = true;
								return flag;
							}
						}
					}
					
					return flag;
				},
				
				
				arrayFieldFileTypeCheck: function(objArr, fileTypes) {
					var flag = false;
					
					if ((objArr == null) || (fileTypes == null)) {
						return flag;
					}
					
					if (isNaN(objArr.length)) {
						var tmp = objArr;
						objArr = new Array();
						objArr[0] = tmp;
					}
					
					if (isNaN(fileTypes.length)) {
						var tmp = fileTypes;
						fileTypes = new Array();
						fileTypes[0] = tmp;
					}
					
					for (i = 0; i < objArr.length; i++) {
						if (objArr[i].value.length != 0) {
							for (j = 0; j < fileTypes.length; j++) {
								if (fileTypes[j].test(objArr[i].value)) {
								flag = true;
								return flag;
								}
							}
						}
					}
					
					return flag;
				},
				
				trimBlankSpace:function(str){
					return str.replace(/^\s*/, "").replace(/\s*$/, "");
				},
				arrayFieldIsUnique: function(objArr) {
						var flag = true;
						if (objArr != null) {
							// Only one release label is present
							if (objArr.length == 1) {
								return flag;
							}
							// More than one release labels are present
							for(i=0;i<objArr.length;i++) {
								var label = objArr[i].value;
								for(j=i+1;j<objArr.length;j++){
									//label is not unique
									if(this.trimBlankSpace(label) == this.trimBlankSpace(objArr[j].value) && label!=''){
										return false;
								}
							}
						}
					}
					return flag;
				
				}
				
				
		

	}
	
	
	var AjaxGetReleaseInfo ={
		
		
		
		loseFocusEventHandler: function(releaseName,osTypeId) {
						   	if (releaseName != null && releaseName.length >0 ) {
							   	var url = 'NonIosAjaxHelper';
							   	var pars = 'releaseName='+ releaseName+'&osTypeId='+ osTypeId;
							   	var ajax_req = new Ajax.Request(
							   						url,
							   						{
							   							method: 'post',
							   							parameters: pars,
							   							onComplete: this.showReleaseInfoResult
							   						});
							   }
		},
		
		showReleaseInfoResult: function(xmlReq) {
				
			
			    			//clean all the value first
							var labelArray = document.getElementsByName('releaseLabel');
							var urlArray = document.getElementsByName('releaseURL');
							var rnsourcelocationArray = document.getElementsByName('releaseSRC');
							for (i = 0; i<labelArray.length; i++){
								labelArray[i].value='';
								urlArray[i].value='';
								rnsourcelocationArray[i].value='';
							}
			
							if (xmlReq.responseText != ''){
								
								var labelArray = document.getElementsByName('releaseLabel');
								var urlArray = document.getElementsByName('releaseURL');
								var rnsourcelocationArray = document.getElementsByName('releaseSRC');
															
							    //if current rows less than db rows, add row first
								var releaseNotes = xmlReq.responseXML.getElementsByTagName("ReleaseNotes")[0];
							   	//alert(releaseNotes.childNodes.length);
							   	if(labelArray.length< releaseNotes.childNodes.length){
							    	for (i=0; i<releaseNotes.childNodes.length-1; i++){
							    		addReleaseUrlRow();
							    		
							    	}
							    }
							   	
						        //set value
							    for (j = 0; j < releaseNotes.childNodes.length; j++) {
									
									var releaseNote = releaseNotes.childNodes[j];
									var releaseLabel  = (releaseNote.getElementsByTagName("ReleaseLabel")[0]).childNodes[0].nodeValue;
							        var releaseURL  = (releaseNote.getElementsByTagName("ReleaseURL")[0]).childNodes[0].nodeValue;
							        var releaseSRC = (releaseNote.getElementsByTagName("ReleaseSRC")[0]).childNodes[0].nodeValue;
							       
							        labelArray[j].value = releaseLabel;
							        urlArray[j].value = releaseURL;
							        rnsourcelocationArray[j].value = releaseSRC;
											     
								}
								document.getElementById('releaseMessage').value = xmlReq.responseXML.getElementsByTagName("ReleaseMessage")[0].childNodes[0].nodeValue;
							}else  {
								var labelArray = document.getElementsByName('releaseLabel');
								var urlArray = document.getElementsByName('releaseURL');
								var rnsourcelocationArray = document.getElementsByName('releaseSRC');
								for (i = 0; i<labelArray.length; i++){
									labelArray[i].value='';
									urlArray[i].value='';
									rnsourcelocationArray[i].value='';
								}
							}
						}
	}
  
 
	
 var AjaxGetFCSDate ={
      
		getFCSDateHandler: function(osTypeId) {
		       var releaseNameSelect = $("releaseNumber");
		       var releaseName = releaseNameSelect.options[releaseNameSelect.selectedIndex].text;
		       //alert (releaseName);
			   if (releaseName != null && releaseName.length >0 ) {
				
					   	var url = 'NonIosAjaxHelper';
					   	var pars = 'releaseName='+ releaseName+'&osTypeId='+ osTypeId +'&action=getReleaseFCSDate';
					   	var ajax_req = new Ajax.Request(
								url,
							   	{
							   		method: 'post',
							   		parameters: pars,
							   		onComplete: this.showReleaseFCSDate
							   	});
				}
		},
		
		showReleaseFCSDate: function(xmlReq) {  
			$('fcsDate').value = xmlReq.responseText;
		}
 }		   
 function popUpPlatform(){
    var W;
    
    <% String imageIdString = "0";
       if(csprImageRecordInfo !=null && csprImageRecordInfo.getImageId()!=null)
    	   imageIdString = csprImageRecordInfo.getImageId().toString();
    %>
    W = window.open('PlatformMdfPopup.jsp?showCheck=true'+'&osTypeId=<%=osTypeId%>' +'&imageId=<%=imageIdString%>' + '&formName=nonIosImageCreate', 'PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=800,height=500')
    W.focus();
 
 }	
	
/*CSCud06651*/
	
	 function popUpFeatureSet(){
		    var W;
		    
		    <%String imageString = "0";
			if (csprImageRecordInfo != null
					&& csprImageRecordInfo.getImageId() != null)
				imageString = csprImageRecordInfo.getImageId().toString();%>
		    W = window.open('FeatureSetPopUp.jsp?showCheck=true'+'&osTypeId=<%=osTypeId%>' +'&imageId=<%=imageString%>'+'&formName=nonIosImageCreate', 'FeatureSetPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=800,height=500')
		    W.focus();
		 
		 }			 
/*end CSCud06651*/
			
-->

</script>

<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr bgcolor="#BBD1ED">
    <td valign="middle" width="70%" align="left">
      <%

    if(isSoftwareTypePM ||spritAccessManager.isAdminSprit() ) {
        if (SpritUtility.isProductizationSupportedBySoftwareType(osType)) {
            out.println(SpritGUI.renderTabContextNav(
                    globals,secNavBar.render( new boolean [] {false,true,true,true},
                           new String [] { "Create","Delete", "View All", "Productization" },
                           new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                           "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                           "CsprImageViewAll.jsp?osTypeId=" + osTypeId,
                                           "ProductizationEdit.jsp?osTypeId=" + osTypeId}
                           ))); 
        } else {
            out.println(SpritGUI.renderTabContextNav(
                    globals,secNavBar.render( new boolean [] {false,true,true},
                           new String [] { "Create","Delete", "View All", },
                           new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                           "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                           "CsprImageViewAll.jsp?osTypeId=" + osTypeId}
                           ))); 
        }      
    }   
    else {
              out.println(SpritGUI.renderTabContextNav(
                            globals,secNavBar.render( new boolean [] {false,true,true},
                                   new String [] { "View All" },
                                   new String [] { "CsprImageViewAll.jsp?osTypeId=" + osTypeId}
                                   ))); 
    }
      %>
    </td>
  </tr>
</table>
<!-- @digarg CSCub43008
Displaying Guest Register Enable Banner when 
1)Software is approved from BU -->
<%
SpritGUIBanner        banner1;
banner1 =  new SpritGUIBanner( globals );
if(FreeSwApprovalQueryUtil.isFreeSwApproved(osTypeId)){
 %>
<%= banner1.addContextNavElementNew() %>
<div style="position:relative; width:100%; height:60%; overflow-x:hidden; overflow-y:scroll;">
<%}%>
<!-- @digarg CSCub43008 End Of Banner -->

<font size="+1" face="Arial,Helvetica"><b>
<center>
  
  Create Metadata <br>
 
</center>
</b></font>

  <%   
        csprSoftwareTypeMetaDataNameV =CsprSoftwareTypeMetaDataJdbc.getCsprSoftwareTypeMetadataNameVector(osTypeId);
 /*     for(int i=0;i<csprSoftwareTypeMetaDataNameV.size();i++) {
          System.out.println("MetaDataName = "+csprSoftwareTypeMetaDataNameV.get(i) );
        }
  */
  %>


<input name="callingForm" value="CsprCreateMetaData" type="hidden">
<input name="_submitformflag" value="0" type="hidden">

<!-- Added new Table to Image entry -->
<center>
 <table>
   <tr> 
     <td> 
        <%= htmlButtonAddImages1 %>
     </td>
   </tr>	   
  </table>

 <%=message %>
 
<table>
<tbody><tr><td></td></tr>
</tbody></table>
  
  <!-- @digarg CSCub43008
  Removing one Break-->
  <!--<br>-->
  <!-- @digarg CSCub43008
  end of removing Break-->
  <br>
  <table border="0" cellpadding="1" cellspacing="0" width="70%">
    <tbody><tr><td bgcolor="#3d127b">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tbody><tr><td bgcolor="#bbd1ed">
  
      <table border="0" cellpadding="3" cellspacing="1" width="100%">
      <tbody>

<tr bgcolor="#d9d9d9">
	<td align="left" valign="top" colspan="2"><span class="dataTableTitle">
	  Release  Metadata (* Required Elements)
	</span></td>
</tr>
<input type="hidden" name="pageAction" value='<%=pageAction %>' >
<%
 if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_NUMBER") ) {
 %>
 <tr bgcolor="#d9d9d9">
 	<td align="left" valign="top"  width="20%"><span class="dataTableTitle">
 	  Release Number *
            <a href="../../help/help.shtml#releaseNumber" onclick="return helpPopup('../../help/help.shtml#releaseNumber');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
 	</span></td>
 	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
 		   <Select name="releaseNumber" id="releaseNumber"   
 		    <%if(!pageAction.equalsIgnoreCase("clone")){ %>
 		   		onChange="AjaxGetFCSDate.getFCSDateHandler('<%=osTypeId.toString()%>');"
 		   <%} %>>
	  				<option value="">Select </option>
	  				<%List releaseList = ManagementMetadataHelper.getReleaseListByOstypeId(osTypeId);
             		  Collections.sort(releaseList,new StringComparator());
	  				  for(int i=0; i<releaseList.size(); i++){
	  						ReleaseInfo vo = (ReleaseInfo)releaseList.get(i);
	  						Integer releaseNumberId = vo.getReleaseNumberId();
	  						String releaseName = vo.getReleaseName();%>
	  	             <option value='<%=releaseNumberId%>:<%=releaseName%>' 
	  	             <%if(releaseNumber.equalsIgnoreCase(releaseName)){%> selected <%} %>> <%=releaseName%>  </option>
	  	            <%} %>
	  	   </Select>			
 	</span></td>
 </tr>
 <%if(pageAction.equalsIgnoreCase("clone")){ %>
 	<input name="hiddenReleaseNumber"  type=hidden value="<%= csprImageRecordInfo.getReleaseName() %>" />	
<% }
 } %>



<%
 if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_NAME") ) {
 %>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Image Name *
            <a href="../../help/help.shtml#imageName" onclick="return helpPopup('../../help/help.shtml#imageName');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="imageName" size="50" type="text" value="<%= imageName %>" maxlength="64"> Note: Only A-Z,a-z,0-9, -, _ and . are allowed.
	</span></td>
</tr>
<%if(pageAction.equalsIgnoreCase("clone")){ %>
	<input name="hiddenImageName" size="50" type="hidden" value="<%= csprImageRecordInfo.getImageName()  %>">
<% } 

}%>

<%
 if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_DESCRIPTION") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Image Description
            <a href="../../help/help.shtml#imgDesc" onclick="return helpPopup('../../help/help.shtml#imgDesc');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <TEXTAREA NAME="imageDescription" ROWS=2 COLS=80 align="left" maxlength="240" onkeypress="return imposeMaxLength(this, <%=SpritConstants.NONIOS_IMAGE_DESCRIPTION_LENGTH%>);"><%= imageDescription %></TEXTAREA>
	</span></td>
</tr>
<% } %>


<!-- Sprit 7.0 productization Platform Pop Up window -->
<%
 if (csprSoftwareTypeMetaDataNameV.contains("INDIVIDUAL_PLATFORM_NAME"))  {
 %>
  <%StringBuffer sb = new StringBuffer(); %>

<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Platform
	  <font size="-2"> (Platform - MDF)
            <a href="../../help/help.shtml#mdfProd" onclick="return helpPopup('../../help/help.shtml#mdfProd');">  
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	 </span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<div id="platformDisplay">
	<%if(csprImageRecordInfo!=null && csprImageRecordInfo.getImageId()!=null){
	  List platformMdfList = ManagementMetadataHelper.getPlatformAndMdfByImageId(csprImageRecordInfo.getImageId());
	  
           for (int i=0; i< platformMdfList.size(); i++){
        	   PlatformMdfVo vo  = (PlatformMdfVo)platformMdfList.get(i);
        	   if(sb.length()>0)
        	   		sb.append(",");
        	   sb.append(vo.getPlatformId());
        	   sb.append(":");
        	   sb.append(vo.getMdfId());
           %>
	    	   <li> <%=vo.getPlatformName()%>- <%=vo.getMdfName()%>
           <%} 
	}%>
	</div>
	<a href="javascript:popUpPlatform()"> Choose Platform</a>  
	</span></td>	
</tr>     
<!-- the following format like: platformId:mdfId,platformId:mdfId,platformId:mdfId  --> 
<input type="hidden" name="platformIds" id="platformIds" value=<%=sb.toString()%>> 

 <% } %>  


<%if (csprSoftwareTypeMetaDataNameV.contains("MDF_ID") ) {
 %>
<tr bgcolor="#d9d9d9">
        <td align="left" valign="top"><span class="dataTableTitle">
           MDF Based Cisco Product
            <a href="../../help/help.shtml#mdfProd" onclick="return helpPopup('../../help/help.shtml#mdfProd');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
        </span></td>
          <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
            <div id="mdfDiv">
            
            <%
                    int mdfIdIndex =0;
	                try{
	    	    	  Set mdfConceptNameSet  = mdfConceptNameHmap.entrySet();
	    	    	  Iterator  mdfConceptNameIterator = mdfConceptNameSet.iterator();
	    	    	  while (mdfConceptNameIterator.hasNext() ) {
	    	    	    Map.Entry mdfConceptNameHmapEntry = (Map.Entry) mdfConceptNameIterator.next();
	    	    	    if( mdfIdIndex == 0 ) {
  	    	    	      hiddenMdfId   = mdfConceptNameHmapEntry.getKey().toString();
				          hiddenMdfName = mdfConceptNameHmapEntry.getValue().toString();
				        } else {  	    	    	              
  	    	    	      hiddenMdfId   = hiddenMdfId +"$"+mdfConceptNameHmapEntry.getKey().toString();
  	    	    	      hiddenMdfName = hiddenMdfName +"$"+ mdfConceptNameHmapEntry.getValue().toString();
  	    	    	    }
	    	%>
	    	    	            <img src="../gfx/dot_black.gif">&nbsp; <%= mdfConceptNameHmapEntry.getValue().toString() %><br>
	    	    	              
	    	<%  //System.out.println("Hmap Key is in CsprImageProcessor(Mdf concept)   " + mdfConceptNameHmapEntry.getKey().toString() );
	    	    //System.out.println("Hmap Value is in CsprImageProcessor(Mdf value) " + mdfConceptNameHmapEntry.getValue().toString() );
  	    	            mdfIdIndex++; 
	    	          }
  	    	    	} catch (Exception e) {
  	    	    	  if ( mdfConceptNameHmap != null ) {
  	    	    	    System.out.println("Value of mdfconceptvalue in while loop in CsprCreateMetaData.jsp  " );
  	    	    	    e.printStackTrace();
  	    	    	  }
	    	    	}// end of try
             %>
            </div>
            <input type="hidden" name="hiddenMdfId"  value="<%= hiddenMdfId %>" >
            <input type="hidden" name="hiddenMdfName"  value="<%= hiddenMdfName %>">

            <a href="javascript:mdfPopupPost('csprCreateMetaData',
	    	                             'mdfDiv',
	    	                             'div',
	    	                             'csprCreateMetaData',
	    	                             'hiddenMdfId',
	    	                             'hiddenMdfName',
                                             '<%=osType%>' )"> Choose MDF Based Cisco Product</a>
                                              
            </td>
    </tr>
    
  <% } %>  
  <!-- CSCud06651 /*To select feature set*/ -->
													<%
														if (csprSoftwareTypeMetaDataNameV.contains("FEATURE_SET_NAME")) {
													%>
													<%
														StringBuffer sb = new StringBuffer();
													%>

													<tr bgcolor="#d9d9d9">
														<td align="left" valign="top"><span
															class="dataTableTitle"> Feature Set <font
																size="-2"> (Feature Set- Name , Description and IsGoingToCCO) <a
																	href="../../help/help.shtml#mdfProd"
																	onclick="return helpPopup('../../help/help.shtml#mdfProd');">
																		<img src="../gfx/help_qn_mark.gif" border="0">
																</a></span></td>
														<td bgcolor="#f5d6a4" align="left" valign="top"><span
															class="dataTableData">
																<div id="featuresetdisplay">
																	<%
																	CsprFeatureSetDAO dao = null;
																	dao = (CsprFeatureSetDAO)SpringUtil.getApplicationContext().getBean("csprFeatureSetDAO");
																		if (csprImageRecordInfo != null
																					&& csprImageRecordInfo.getImageId() != null) {
																				System.out.println("osTypeId" + osTypeId);
																				List featureSetNameList = dao.getImageNonIosRecords(osTypeId,csprImageRecordInfo.getImageId());

																				for (int i = 0; i < featureSetNameList.size(); i++) {
																					FeatureSetNonIosInfo fsinfo = (FeatureSetNonIosInfo) featureSetNameList
																							.get(i);
																					if (sb.length() > 0)
																						sb.append(",");
																					sb.append(fsinfo.getFeatureSetName());
																					sb.append(":");
																					sb.append(fsinfo.getFeatureSetDesc());
																					sb.append(":");
																					sb.append(fsinfo.getIsFSetGoingToCCO());
																					sb.append("+");
																					sb.append(fsinfo.getCsprfeatureSetId());
																	%>
																	<li><%=fsinfo.getFeatureSetName()%>:<%=fsinfo.getFeatureSetDesc()%>:<%=fsinfo.getIsFSetGoingToCCO()%>
																		<%
																			}
																				}
																		%>
																</div> <a href="javascript:popUpFeatureSet()"> Choose
																	FeatureSet</a>
														</span></td>
													</tr>
													<input type="hidden" name="featuresetInfo"
														id="featuresetInfo" value=<%=sb.toString()%>>


													<%
														}
													%>
													<!-- CSCud06651-->
 
 <%
  if(csprSoftwareTypeMetaDataNameV.contains("MACHINE_OS_TYPE_NAME") ) {
    String hiddenMachineOsTypeId ="";
    if ( machineOsTypeNameHmap != null ) {
      Set machineOsTypeNameSet  = machineOsTypeNameHmap.entrySet();
      machineOsTypeNameIterator = machineOsTypeNameSet.iterator();
      while (machineOsTypeNameIterator.hasNext() ) {
        Map.Entry machineOsTypeNameHmapEntry = (Map.Entry) machineOsTypeNameIterator.next();
        //System.out.println("Hmap Key is     "+ machineOsTypeNameHmapEntry.getKey().toString() );
        //System.out.println("Hmap Value is   "+ machineOsTypeNameHmapEntry.getValue().toString() );
        machineOsTypeIdV.addElement(machineOsTypeNameHmapEntry.getKey().toString() );	
        hiddenMachineOsTypeId = hiddenMachineOsTypeId +"$"+machineOsTypeNameHmapEntry.getKey().toString();
      } //while loop
    }
  
%>
  <tr bgcolor="#d9d9d9">
      <td align="left" valign="top"><span class="dataTableTitle">
             Machine Operating System
            	<a href="../../help/help.shtml#machineOS" onclick="return helpPopup('../../help/help.shtml#machineOS');"> 
                <img src="../gfx/help_qn_mark.gif" border="0"></a>
      </span></td>
         
         <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
             <select name="machineOsTypeId" multiple="multiple" width="200" size="4">
             <option value="">Select Machine Operating System... </option>

             <%
	      try{ 
	        allMachineOsTypeNameHmap = CsprImageDataJdbc.getAllMachineOsTypeName();
	        Set machineOsTypeNameset  = allMachineOsTypeNameHmap.entrySet();
	        machineOsTypeNameIterator = machineOsTypeNameset.iterator();
	        while (machineOsTypeNameIterator.hasNext() ) {
	          Map.Entry allMachineOsTypeNameHmapEntry = (Map.Entry) machineOsTypeNameIterator.next();
	          if(machineOsTypeIdV.contains(allMachineOsTypeNameHmapEntry.getKey().toString() )) {
	        %>     
	           <option value="<%= allMachineOsTypeNameHmapEntry.getKey().toString() %>" selected > <%=allMachineOsTypeNameHmapEntry.getValue().toString()%></option>
	        
	         <% }else {   %>
	            <option value="<%= allMachineOsTypeNameHmapEntry.getKey().toString() %>" > <%=allMachineOsTypeNameHmapEntry.getValue().toString()%></option>
	         <% }
	       
	            //System.out.println("Hmap Key is     "+ allMachineOsTypeNameHmapEntry.getKey().toString() );
	            //System.out.println("Hmap Value is   "+ allMachineOsTypeNameHmapEntry.getValue().toString() );
	        }
	      }catch (Exception e) {
	          System.out.println("Exception in CSPRImageDataJdbc.java in machineOsTypeName[] Hmap2");
	          //System.out.println("ImageId is          " +new Integer(rSet.getInt("image_id")) );
	          e.printStackTrace();
	      }// end of try
              %>
             </select>
         </td>
 </tr>
<input type="hidden" name="hiddenMachineOsTypeId"  value="<%= hiddenMachineOsTypeId %>" >
 <% } %>  
 
<%
if(csprSoftwareTypeMetaDataNameV.contains("MEMORY_FOOTPRINT") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Memory 
            <a href="../../help/help.shtml#memory" onclick="return helpPopup('../../help/help.shtml#memory');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="memory" size="12" type="text" value="<%= memory %>" onChange ='if(!isNumber(memory.value) ) {
	               alert("Please enter a number for Memory");
	               memory.value="";
	             }'>
	</span></td>
</tr>
<% } %>  

<%
if(csprSoftwareTypeMetaDataNameV.contains("HARD_DISK_FOOTPRINT") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Hard Disk Footprint
            <a href="../../help/help.shtml#hardDiskFootprint" onclick="return helpPopup('../../help/help.shtml#hardDiskFootprint');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="hardDiskFootprint" size="12" type="text" value="<%= hardDiskFootprint %>" onChange ='if(!isNumber(hardDiskFootprint.value) ) {
	               alert("Please enter a number for Hard Disk Footprint");
	               hardDiskFootprint.value="";
	             }'>
	</span></td>
</tr>
<% } %>  

<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_CRYPTO") ) {
  String KxSelected="";
  String K2Selected="";
  String K4Selected="";
  String K9Selected="";
  String NoneSelected="Selected";

  if ( csprImageRecordInfo != null ) {
    if("Kx".equalsIgnoreCase(csprImageRecordInfo.getIsCrypto()) ) {
      KxSelected="Selected";
      NoneSelected="";
    } else if("K2".equalsIgnoreCase(csprImageRecordInfo.getIsCrypto()) ) {
      K2Selected="Selected";
      NoneSelected="";
    } else if("K4".equalsIgnoreCase(csprImageRecordInfo.getIsCrypto()) ) {
      K4Selected="Selected";
      NoneSelected="";
    } else if("K9".equalsIgnoreCase(csprImageRecordInfo.getIsCrypto()) ) {
      K9Selected="Selected";
      NoneSelected="";
    }
  }
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Crypto
            <a href="../../help/help.shtml#crypto" onclick="return helpPopup('../../help/help.shtml#crypto');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <!--<input type="checkbox" name="isCrypto"> -->
          <Select name="isCrypto" STYLE="width: 100px">
            <option value="">Select One..</option>
            <option value="None" <%=  NoneSelected  %> >None</option>
            <option value="Kx"   <%=  KxSelected    %> >Kx</option>          
            <option value="K2"   <%=  K2Selected    %> >K2</option>
            <option value="K4"   <%=  K4Selected    %> >K4</option>
            <option value="K9"   <%=  K9Selected    %> >K9</option> 
          </select> <br>
	</span></td>
</tr>
<% } %> 


<!---------------------- Sprit 7, Add MinDram ------------------------------------------------------------------------> 
<%
if(csprSoftwareTypeMetaDataNameV.contains("MIN_FLASH") ) {
%>
 <tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Min Flash
            <a href="../../help/help.shtml#minFlash" onclick="return helpPopup('../../help/help.shtml#minFlash');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
		 <select name="minFlash" size="1" STYLE="width: 100px">
		 <option value="">Select </option>
    	<%
    	String minFlash = "";
    	if(csprImageRecordInfo!=null && csprImageRecordInfo.getMinFlash()!=null) 
    		minFlash = csprImageRecordInfo.getMinFlash().toString();
    	for (int i = 0; i < minFlashArr.length; i++) { %>
    		<option value="<%=minFlashArr[i]%>" 
    		<%if(minFlashArr[i].equalsIgnoreCase(minFlash)){ %> selected <%} %> ><%=minFlashArr[i]%></option>
        <% } %>
        </select></span></td>
   
  </tr>    
<% } %>    
<!----------------------- Sprit 7, Add MinDram ----------------------------------------------------------->        
<%
if(csprSoftwareTypeMetaDataNameV.contains("DRAM") ) {
%>
  <tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Min Dram
            <a href="../../help/help.shtml#minDram" onclick="return helpPopup('../../help/help.shtml#minDram');">
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
    	<select name="minDram" size="1" STYLE="width: 100px">
    	<option value="">Select </option>
     	<%
     	String dramInDb = "";
     	if(csprImageRecordInfo!=null && csprImageRecordInfo.getDram()!=null)
     		dramInDb = csprImageRecordInfo.getDram().toString();
    	for (int i = 0; i < minDramArr.length; i++) { %>
    	<option value="<%=minDramArr[i]%>" <%if(minDramArr[i].equalsIgnoreCase(dramInDb)){ %> selected <%} %>><%=minDramArr[i]%></option>
    	<% } %>
    	</select></span>
   	</td>
</tr>
<% } %>
<!-- 
<%
if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_DOC_URL") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Release Notes URL
            <a href="../../help/help.shtml#releaseNotesURL" onclick="return helpPopup('../../help/help.shtml#releaseNotesURL');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="releaseNotesUrl" size="100" type="text" value="<%= releaseNotesUrl %>" >
        </span></td>
</tr>
<% } %> 
-->


<%
if(csprSoftwareTypeMetaDataNameV.contains("POSTING_TYPE_NAME") ) {
	String postingTypeChecked1="";
	String postingTypeChecked2="";
    String postingTypeChecked3="";
    String postingTypeChecked4="";
   String postingTypeChecked7="";
   String postingTypeChecked9="";
  
  String postingTypeCheckedNK="checked";
  
  if ( csprImageRecordInfo != null ) {
    if( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(2)) ) {
      postingTypeChecked2="checked";
      postingTypeCheckedNK = "";
    } else if ( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(3)) ) {
      postingTypeChecked3="checked";
      postingTypeCheckedNK = "";
    } else if ( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(4)) ) {
      postingTypeChecked4="checked";
      postingTypeCheckedNK = "";
    } else if ( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(7)) ) {
      postingTypeChecked7="checked";
      postingTypeCheckedNK = "";
    
    } else if ( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(1)) ) {
      postingTypeChecked1="checked";
      postingTypeCheckedNK = "";
    } else if ( csprImageRecordInfo.getPostingTypeId() != null && csprImageRecordInfo.getPostingTypeId().equals(new Integer(9)) ) {
      postingTypeChecked9="checked";
      postingTypeCheckedNK = "";
    }
  }
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Posting Type
            <a href="../../help/help.shtml#postingType" onclick="return helpPopup('../../help/help.shtml#postingType');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="bottom"><span class="dataTableData">
          <input type="radio" name="postingTypeId" value=2 <%=postingTypeChecked2 %> > CCO Only
          <%if(ManagementMetadataHelper.getProductizationByOsType(osTypeId).equalsIgnoreCase("Y")){%>
          		<input type="radio" name="postingTypeId" value=1 <%=postingTypeChecked1 %> > CCO and MFG
          <%} %>
          <input type="radio" name="postingTypeId" value=3 <%=postingTypeChecked3 %> > Hidden Post CCO Only
          <input type="radio" name="postingTypeId" value=4 <%=postingTypeChecked4 %> > Hidden Post MFG Only
          <input type="radio" name="postingTypeId" value=7 <%=postingTypeChecked7 %> > Hidden with ACL
          <input type="radio" name="postingTypeId" value=9 <%=postingTypeChecked7 %> > Hidden Machine to Machine
          <input type="radio" name="postingTypeId" value="" <%=postingTypeCheckedNK %> > Not known
        </span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("INSTALLATION_DOC_URL") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Installation Docs URL
            <a href="../../help/help.shtml#insDocsURL" onclick="return helpPopup('../../help/help.shtml#insDocsURL');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="installationDocUrl" size="100" type="text" value="<%= installationDocUrl %>" maxlength="1000" >
	</span></td>
</tr>
<% } %> 


<%
if(csprSoftwareTypeMetaDataNameV.contains("PRODUCT_CODE") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Product Code
            <a href="../../help/help.shtml#prodCode" onclick="return helpPopup('../../help/help.shtml#prodCode');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	      <!-- start CSCud61563 : Convert PID to upper-case -->
          <!--<input name="productCode" size="25" type="text" value="<%--= productCode --%>" maxlength="18" >-->
          <!-- digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie -->
          <input name="productCode" size="25" type="text" OnKeyUp='toUpper(this);'
          OnChange='toUpper(this);' onBlur='toUpper(this);' title='Any lowercase chars will be converted to uppercase to avoid eGenie submission errors' value="<%= productCode %>" maxlength="18" >
          <!-- end CSCud61563 : Convert PID to upper-case -->
        </span></td>
</tr>
<% } %>  


<%
if(request.getRemoteUser()!= null && !"null".equalsIgnoreCase(request.getRemoteUser())) {
	String userId = request.getRemoteUser();
%>
<input type="hidden" name="userId" value="<%=userId%>">
<%
}
if(csprSoftwareTypeMetaDataNameV.contains("CCATS") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  CCATS
            <a href="../../help/help.shtml#ccats" onclick="return helpPopup('../../help/help.shtml#ccats');">
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <input name="ccats" size="8" type="text" value="" maxlength="8"  
          <%
          	if(!FreeSwApprovalQueryUtil.isFreeSwApproved(osTypeId)){
          %>          	
          	readOnly=\"true\"
          <%
          	}
          %>
          >
        </span></td>
</tr>
<% } %>  


<!--- FCS CCO Date add for  CSCsi47314 6.8 --------------------------------------------------------------------->
<%
if(csprSoftwareTypeMetaDataNameV.contains("FCS_DATE") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  CCO FCS Date
            <a href="../../help/help.shtml#ccoFCSDate" onclick="return helpPopup('../../help/help.shtml#ccoFCSDate');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	 <% 
	String fcsDate = "";
	   if(csprImageRecordInfo !=null   && csprImageRecordInfo.getCcoFcsDate() !=null){
	   	SimpleDateFormat format = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
		fcsDate = format.format(csprImageRecordInfo.getCcoFcsDate());
	   }
	  
	 %>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	
	 <input id="fcsDate" name="fcsDate" type="text" size="25" value="<%=fcsDate%>" onFocus="this.blur()" />
	       	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle" onclick="javascript:NewCal('fcsDate','ddmmmyyyy',true,12)"
	         	onmouseover="window.status='Date Picker';return true;" onmouseout="window.status='';return true;"> 
	         <!--	<div id='divFCSDate' />  -->
        </td>
</tr>
<% } %>

 

<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_SOFTWARE_ADVISORY") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Software Advisories 
            <a href="../../help/help.shtml#softAdv" onclick="return helpPopup('../../help/help.shtml#softAdv');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<!-- //digarg : Rally(US10041) disable Software advisor, deferral advisor text boxes for IOS XE -->
	<% if ("Y".equalsIgnoreCase(isSoftwareAdvisory) ){ if(osTypeId.equals(new Integer(306))){ %>
        <input disabled type="checkbox" name="isSoftwareAdvisory" checked>
		 <% } else { %>
		 <input  type="checkbox" name="isSoftwareAdvisory" checked>
		 <% }} else { if(osTypeId.equals(new Integer(306))) { %>
		 <input disabled type="checkbox" name="isSoftwareAdvisory">
		 <% }else { %>
		   <input type="checkbox" name="isSoftwareAdvisory">
		 <% }}%>
		 <%if(osTypeId.equals(new Integer(306))){ %>
                  <input disabled name="softwareAdvisoryDocUrl" size="100" type="text" value="<%= softwareAdvisoryDocUrl %>">
          <%}else{ %>
                 <input name="softwareAdvisoryDocUrl" size="100" type="text" value="<%= softwareAdvisoryDocUrl %>">
           <%} %>
	</span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_DEFERRED") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Deferral Advisories 
            <a href="../../help/help.shtml#defAdv" onclick="return helpPopup('../../help/help.shtml#defAdv');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<!-- //digarg : Rally(US10041) disable Software advisor, deferral advisor text boxes for IOS XE -->
          <% if ("Y".equalsIgnoreCase(isDeferred)){ if(osTypeId.equals(new Integer(306))){%>
     	 <input disabled type="checkbox" name="isDeferred" checked>
     	<% } else { %> 
     	 <input type="checkbox" name="isDeferred" checked>
     	<% }} else { if(osTypeId.equals(new Integer(306))){%>
     	 <input disabled type="checkbox" name="isDeferred">
     	 <% } else { %> 
     	 <input type="checkbox" name="isDeferred">
         <% }} %>
         <%if(osTypeId.equals(new Integer(306))){ %>
          <input disabled name="deferralAdvisoryDocUrl" size="100" type="text" value="<%= deferralAdvisoryDocUrl %>">
          <%}else{ %>
          <input name="deferralAdvisoryDocUrl" size="100" type="text" value="<%= deferralAdvisoryDocUrl %>">
          <%} %>
          
	</span></td>
</tr>
<% } %> 


<!-- 6.9 related software, clone with imageId, create without imageId -->
<%
if(csprSoftwareTypeMetaDataNameV.contains("RELATED_SOFTWARE") ) {
	String displayText ="";
	String imageId = new Integer("0").toString();
	//String pageAction = request.getParameter("pageAction")!=null?request.getParameter("pageAction"):"";
	String relatedSoftwareString ="";
%>
<%  if(pageAction.equals("clone")){
		Map mapInfo = RelatedSoftwareHelper.getSelectedRelatedSoftware(csprImageRecordInfo.getImageId());
		Map machineOsTypeMap = RelatedSoftwareHelper.getSelectedMachineOsTypeMap(csprImageRecordInfo.getImageId());
		//displayText = RelatedSoftwareHelper.getDisplayText(mapInfo);
		displayText = RelatedSoftwareHelper.getDisplayData(mapInfo); //group by softwaretype and in Alphabetical order
		relatedSoftwareString = RelatedSoftwareHelper.getStringforSave(mapInfo, machineOsTypeMap);
     	imageId = csprImageRecordInfo.getImageId().toString(); 
   }%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Related Software
            <a href="../../help/help.shtml#relatedSoftware" onclick="return helpPopup('../../help/help.shtml#relatedSoftware');">
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	 </span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
		<div rDisplay id="display">
				<%  if(pageAction.equals("clone")){%>
					<%=displayText%> 
				<%}%>	
		</div>
		<%  if(pageAction.equals("clone")){%>  
		  <a href="javascript:relatedSoftwarePopUp('csprImageEdit',
			                            '<%=osType%>', '<%=imageId%>' )"> Choose Related Software</a>        
		<%}else{%>	                            
          <a href="javascript:relatedSoftwarePopUp('csprImageEdit',
		                            '<%=osType%>', '0' )"> Choose Related Software</a>  
		<%}%>	                            
	</span></td>	
	</tr>
	<input type="hidden" name="relatedSoftwareInfo" id="relatedSoftwareInfo" <%  if(pageAction.equals("clone")){%>value=<%=relatedSoftwareString%><%}%>>
<% } %> 
 
<input type="hidden" name="relatedSoftwareUpdateFlag" id="relatedSoftwareUpdateFlag" value='true'> 


<%
if(csprSoftwareTypeMetaDataNameV.contains("CDC_ACCESS_LEVEL_NAME") ) {
  String cdcAccessLevel0="";
  String cdcAccessLevel1="";
  String cdcAccessLevel2="";
  String cdcAccessLevelNK="checked";

  if (csprImageRecordInfo != null ) {
  	if( csprImageRecordInfo.getCdcAccessLevelId() != null && csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(0)) ) {
      cdcAccessLevel0="";
    } else if( csprImageRecordInfo.getCdcAccessLevelId() != null && csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(1)) ) {
      cdcAccessLevel1="checked";
      cdcAccessLevelNK="";
    } else if ( csprImageRecordInfo.getCdcAccessLevelId() != null && csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(2)) ) {
      cdcAccessLevel2="checked";
      cdcAccessLevelNK="";
    }
  }
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Access Levels
            <a href="../../help/help.shtml#accessLevel" onclick="return helpPopup('../../help/help.shtml#accessLevel');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
			<%	//CSCsv19029 - Finance Control - Enhance manage metadata create/edit/clone
				String disableGuestReg = "";
				String disableAnonymous = "";
				if(!FreeSwApprovalQueryUtil.isFreeSwApproved(osTypeId)){
					disableGuestReg = "disabled";
					disableAnonymous = "disabled";
				}
			%>
          <input type="radio" name="cdcAccessLevelId" value=1 <%=disableGuestReg%> <%=cdcAccessLevel1 %>> Guest Registered
          <input type="radio" name="cdcAccessLevelId" value=2 <%=cdcAccessLevel2 %>> Contract Registered
          <input type="radio" name="cdcAccessLevelId" value=0 <%=disableAnonymous%> <%=cdcAccessLevel0 %>> Anonymous
          <input type="radio" name="cdcAccessLevelId" value=-1 <%=cdcAccessLevelNK %>> Not known
          
 
	</span></td>
</tr>
<% } %> 
<%
if(csprSoftwareTypeMetaDataNameV.contains("SOURCE_LOCATION") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Source Location
            <a href="../../help/help.shtml#srcLoc" onclick="return helpPopup('../../help/help.shtml#srcLoc');">
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top" ><span class="dataTableData">
          <input name="sourceLocation" size="100" type="text" value="<%= sourceLocation %>" maxlength="1000">
	</span></td>
</tr>
<% } %> 


<!-------    the following is  Image Label and URL ----------------------------------------------------------------------->
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
		Image Doc URL<br> Provide URL / Source Location, not both
            <a href="../../help/help.shtml#imgDocURL" onclick="return helpPopup('../../help/help.shtml#imgDocURL');"> 
            <img src="../gfx/help_qn_mark.gif" border="0"></a>
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top" width="85%"><span class="dataTableTitle">
		<table id="tblImageNote" class="dataTable" width="85%">
					<!--tr>
						<td width="150px">Image Label</td>
						<td width="250px">Image URL &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Add Row" onclick="addImageUrlRow();" /></td>
						
					</tr>
					<tr>
						<td><input type="text" name="imageLabel" /></td>
						<td><input type="text" name="imageUrl" /> &nbsp;&nbsp;<input type="button" value="Delete" onclick="removeImageRow(this);" /></td>
					</tr-->
					<tr>
						<td valign="top" width="20%">Image Label</td>
						<td valign="top" width="35%">Image URL</td> 
						<td valign="top" width="35%">
							Source Location
							<br>
							<font size="-2">
								Provide absolute path including filename
								<br />
								<b>
									Note: Only A-Z,a-z,0-9, -, _, / and . are allowed.
								</b>
							</font>
						</td>
						<td width="10%"> <input type="button" value="Add Row" id="imageNotesAddBtn" title="Please note that the document publishing takes upto 4 hrs to complete."  onclick="addImageUrlRow();" /></td>
											
					</tr>
					<%if(csprImageRecordInfo!=null && csprImageRecordInfo.getImageNotesLabel()!=null){
						String[] imageLabels = csprImageRecordInfo.getImageNotesLabel() ;
						String[] imageURLs = csprImageRecordInfo.getImageNotesURL();
						String[] imageSRC = csprImageRecordInfo.getImageNotesSRC();
				
					for (int i=0; i<csprImageRecordInfo.getImageNotesLabel().length; i++){%>
					<tr>
						<td><input type="text" name="imageLabel" id="imageLabel" size="20" maxlength="60" value="<%=imageLabels[i]%>" /></td>
                                    <% if(imageURLs[i]==null || "null".equals(imageURLs[i])) imageURLs[i]=""; %>
						<td><input type="text" name="imageUrl" id="imageUrl" size="30" maxlength="1000"  value="<%=imageURLs[i]%>" /></td>
                                    <% if(imageSRC[i]==null || "null".equals(imageSRC[i])) imageSRC[i]=""; %>
						<td><input type="text" name="imageSRC" id="imageSRC" size="30" maxlength="1000"  value="<%=imageSRC[i]%>" /></td> 
						<td><input type="button" value="Delete" id="imageNotesDeleteBtn" onclick="removeImageRow(this);" /></td>
					</tr>
					<%	}
					}%>
		</table>
	</span></td>
</tr>	

<tr bgcolor="#d9d9d9">
	<td align="left" valign="top" colspan="2"><span class="dataTableTitle">
	<!--  
	<td bgcolor="#f5d6a4" align="left" valign="top" ><span class="dataTableData">
    -->
	</span></td>
</tr>
 
 <input name="osTypeId" value=<%=osTypeId%> type="hidden">
 <input name="osType" value="<%=osType%>" type="hidden">
		
</tbody></table>
      
  </td></tr>
  </tbody></table>
  </td></tr>
  </tbody></table>
 
 <br>
 
 <%
  if(isSoftwareTypePM ||spritAccessManager.isAdminSprit() ) {
 %>
    <!-- <input type="submit" value="Submit">  -->
     <table>
       <tr> 
         <td> 
            <%= htmlButtonAddImages1 %>
         </td>
       </tr>	   
      </table>
    </center>
 <% } %>  

<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- @digarg CSCub43008
div -->
<%if(FreeSwApprovalQueryUtil.isFreeSwApproved(osTypeId)){ %>
</div> 
<%} %>
<!-- @digarg CSCub43008
end of div-->
<!-- end footer -->
</form>

