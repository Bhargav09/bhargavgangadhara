<!--.........................................................................
: DESCRIPTION:
: Image List page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002-2005 by Cisco Systems, Inc. All rights reserved.
:.........................................................................-->
<!-- Java -->
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator"%> 
<%@ page import="java.util.ArrayList" %>

<!-- SPRIT -->
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.ImageListSortAsc" %>
<%@ page import="com.cisco.eit.sprit.logic.imagelist.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.*" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.model.imagetype.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.ui.ImageListGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import= "com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.util.ImageDbUtil" %>
<%@page import="java.util.Iterator;"%>
<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>

<% //Getting the filters and values
 // Get Platform, Image Filters.
  Context ctx;
  Integer releaseNumberId;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseNumberModelLocal rnmObj;
  SpritGlobalInfo globals;
  String htmlButtonSaveImages1;
  String htmlButtonSaveImages2;
  ArrayList pseudoImageListArray = null ; //Licensing and Pseudo Image feature changes May 2008 - Akshay
  ArrayList imageTypeList = null; //Licensing and Pseudo Image feature changes May 2008 - Akshay
//  String ImageFilter = "*";
//  String imageFilter = null;
  String jndiName;
  String pathGfx;
//  String PlatformFilter = "*";
//  String platformFilter = null;
  SpritAccessManager spritAccessManager;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  Integer postingTypeId = new Integer(0);  //Sprit 6.9 CSCsj91893

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = new Integer(0);
  try {
    releaseNumberId = new Integer(
      WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }
  
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHome) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    postingTypeId = rnmInfo.getPostingTypeId();
  } catch( Exception e ) {
    throw e;
  }  // catch

  String fullRelease = rnmInfo.getFullReleaseNumber();

  htmlButtonSaveImages1 = SpritGUI.renderButtonRollover(
      globals,
      "btnSaveImages1",
      "Save Images",
      "javascript:validateAndSubmitForm('copyImageList')",
      pathGfx + "/" + "btn_save_image.gif",
      "actionBtnSaveImages('btnSaveImages1')",
      "actionBtnSaveImagesOver('btnSaveImages1')"
      );
  htmlButtonSaveImages2 = SpritGUI.renderButtonRollover(
      globals,
      "btnSaveImages2",
      "Save Images",
      "javascript:validateAndSubmitForm('copyImageList')",
      pathGfx + "/" + "btn_save_image.gif",
      "actionBtnSaveImages('btnSaveImages2')",
      "actionBtnSaveImagesOver('btnSaveImages2')"
      );
%>

<%= SpritGUI.pageHeader( globals,"Copy Images From : "+fullRelease,"" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Copy Images From : "+fullRelease ) %>

<script language="javascript"><!--
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................
  function actionBtnSaveImages(elemName) {
    if( document.forms['copyImageList'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + "btn_save_image.gif"%>" );
    }  // if
  }
  function actionBtnSaveImagesOver(elemName) {
    if( document.forms['copyImageList'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + "btn_save_image_over.gif"%>" );
    }  // if
  }

  function validateAndSubmitForm(formName) {
    var elements;
    var formObj;
    var numRecs;
    var idx;
    var regexCopyCheckbox;
    var elementName;

    formObj = document.forms[formName];
    elements = formObj.elements;

    // Check to see if we've submitted this before!
    if( elements['_submitformflag'].value==1 ) {
      return;
    }

    /* ************************************

        TO ENABLE THIS CODE UNCOMMENT THIS
        SECTION.

    // Count the number of records that have been selected.
    numRecs = 0;
    regexCopyCheckbox = /^_\d+Copy$/;
    for( idx=0; idx<elements.length; idx++ ) {
      elementName = elements[idx].name;
      if( elementName.match( regexCopyCheckbox ) ) {
        if( elements[idx].checked==true ) {
          numRecs++;
        }  // if( elements[idx].checked==true )
      }  // if( elementName.match( regexCopyCheckbox ) )
    }  // for( idx=0; idx<elements.length; idx++ )

    if( numRecs==0 ) {
      alert( "ERROR: You have not selected any images to copy!  Please "
          + "place a check next to the records you want to copy.  To cancel "
          + "copying close the window." );
      return;
    }  // if( numRecs==0 )

    // Now display the wait notice.
    alert( ""
        + "Now copying " + numRecs + " images.  This may take several "
        + "minutes.  Please be patient."
        + "\n\nPress OK to continue."
        );
    ************************************ */

    // Now display the wait notice.
    alert( ""
        + "Now copying images.  This may take several "
        + "minutes.  Please be patient."
        + "\n\nPress OK to continue."
        );

    elements['_submitformflag'].value=1;
    //setImg( 'btnSaveImages1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
    //setImg( 'btnSaveImages2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

    formObj.submit();
  }  // function validateAndSubmitForm
//--></script>


<%
String workingReleaseId = request.getParameter("workingReleaseId");
String releaseId =request.getParameter("releaseNumberId");
Iterator ImageListInfoVector = null;
Collection ImageListCollection = null;
ImageListSessionHome mImageListSessionHome = null;
ImageListSession mImageListSession = null;
ImageListInfo mImageListInfo = null;

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: BEGIN
 //----------------------------------------------------------------
 HashMap imageId2IssuStateInfoHash  = null;
 Vector  issuStateVect              = null;
 String  issuState                  = null;
 String  fontTagOpen                = null;
 String  fontTagClose               = null;
 Vector  issuStateDispHighlightVect = new Vector();

 issuStateDispHighlightVect.addElement("ISSU_OFF");

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: END
 //----------------------------------------------------------------

try{    //getting the context of ImageList Session
    Context cntx = JNDIContext.getInitialContext();
        Object homeObject = cntx.lookup("ImageListSessionBean.ImageListSessionHome");
        mImageListSessionHome = (ImageListSessionHome)PortableRemoteObject.narrow(homeObject, ImageListSessionHome.class);
        mImageListSession = mImageListSessionHome.create();
}
catch(Exception e){
 e.printStackTrace();
}

 try {
 ImageListCollection = mImageListSession.getAllImageListInfoUtil(new Integer(releaseId));

 
 //-------------------------------------------------------------------------------
 // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
 //-------------------------------------------------------------------------------
 //Get Pseudo Imagelist information
 pseudoImageListArray = new ArrayList(); //Will contain all pseudo images
 Collection pseudoImageListCollection = mImageListSession.getAllPseudoImageListInfoUtil(new Integer(releaseId)); 
 
 if(pseudoImageListCollection!=null && pseudoImageListCollection.size() > 0){
	 
	 ArrayList pseudoImageListArrayTemp;
	 ImageListInfo pseudoImageListInfoTemp;
	 Iterator pseudoImageListArrayItr;
	 
	 //The below loop filters out Parent Images and keeps just the Pseudo Images
	 pseudoImageListArrayTemp = new ArrayList(pseudoImageListCollection);
	 pseudoImageListArrayItr = pseudoImageListArrayTemp.iterator();
	 while(pseudoImageListArrayItr.hasNext()){
		 pseudoImageListInfoTemp = (ImageListInfo) pseudoImageListArrayItr.next();
		 if(pseudoImageListInfoTemp!=null && pseudoImageListInfoTemp.getParentImageId()!=null && pseudoImageListInfoTemp.getParentImageId().intValue()!=0){
			 pseudoImageListArray.add(pseudoImageListInfoTemp);
		 }
	 }
 }
 //-------------------------------------------------------------------------------
 // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
 //-------------------------------------------------------------------------------

  //----------------------------------------------------------------
  // SPRIT-ISSU. Added 10/24/2006 nadialee: BEGIN
  //----------------------------------------------------------------
  if( "IOS".equals(rnmInfo.getOsType()) ) {
      imageId2IssuStateInfoHash = mImageListSession.getAllImageListIssuState(new Integer(releaseId));
  }
  //----------------------------------------------------------------
  // SPRIT-ISSU. Added 10/24/2006 nadialee: END
  //----------------------------------------------------------------

 } catch(Exception e) {
 e.printStackTrace();
 }


%>

<!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->
<SCRIPT language="javascript">
 
 //This function ensures that pseudo images dont remain selected if the parent is Unchecked. 
 function checkSelectedPseudo(ImageIndex,recordsSize,firstParentImageIndex){
		
		formObj = document.forms['copyImageList'];
		var parentCheckbox = formObj.elements["_"+ImageIndex+"Copy"];
		var imageId = trim(formObj.elements["_"+ImageIndex+"ImageId"].value);
		var platformId = trim(formObj.elements["_"+ImageIndex+"PlatformId"].value);
		var parentImageId = "";
		var parentPlatformId = "";
		var alertpseudomsg = "";
		
		if(!parentCheckbox.checked){
			var i = (ImageIndex*1 + 1);
	 		for(; i < recordsSize; i++){
	 			parentImageId = trim(formObj.elements["_"+i+"ParentImageId"].value);
	 			parentPlatformId = trim(formObj.elements["_"+i+"PlatformId"].value);
	 		
	 			if(imageId == parentImageId && platformId == parentPlatformId) {
	 				if(formObj.elements["_"+i+"Copy"].checked){
	 					//alertpseudomsg =  alertpseudomsg + "'" + formObj.elements["_"+i+"ImageName"].value + "' ";
	 					//parentCheckbox.checked = true;
	 					formObj.elements["_"+i+"Copy"].checked = false;
	 				}
	 			}
	 			else{
	 				break;
	 			}
	 		}
	 		//if(alertpseudomsg.length > 0){
	 		//	alert("Pseudo Image(s) " + alertpseudomsg + " must be unchecked before unchecking its Parent Image.");
	 		//}
 		}
 		else{	
 			var i = (firstParentImageIndex*1);
 			formObj.elements["_"+ImageIndex+"Copy"].checked=false;
 			
			var parentImageSelected = false;
			for(;i < recordsSize; i++){
				var currImageId = trim(formObj.elements["_"+i+"ImageId"].value);
				var currParentImageId = trim(formObj.elements["_"+i+"ParentImageId"].value);
				var currCheckbox = formObj.elements["_"+i+"Copy"];
				
				if(imageId==currImageId || imageId == currParentImageId){
				}else{
					break;
				}
						
				if(imageId == currImageId){
					if(currCheckbox.checked){
					    if(parentImageSelected){
					    	break;
					    }
						parentImageSelected = true;
					}
					else{
						parentImageSelected = false;
					}
				}
				else if(currCheckbox.checked && parentImageSelected){
					for(var j=(ImageIndex*1+1);j<recordsSize; j++){
						if(currParentImageId != trim(formObj.elements["_"+j+"ParentImageId"].value)){
							break;
						}
						if(currImageId == trim(formObj.elements["_"+j+"ImageId"].value)){
							formObj.elements["_"+j+"Copy"].checked=true;
						}						
					}
				}
			}
			formObj.elements["_"+ImageIndex+"Copy"].checked=true;
 		}
 }
 
 function checkPseudoforSelectedPlatform(ImageIndex,recordsSize,firstParentImageIndex){
	formObj = document.forms['copyImageList'];
	var pseudoCheckbox = formObj.elements["_"+ImageIndex+"Copy"];
	var imageId = trim(formObj.elements["_"+ImageIndex+"ImageId"].value);
	var parentImageId = trim(formObj.elements["_"+ImageIndex+"ParentImageId"].value);
	var platformId = trim(formObj.elements["_"+ImageIndex+"PlatformId"].value);
	
	var i = (firstParentImageIndex*1);
	var parentImageSelected = false;
	
	for(;i < recordsSize; i++){
		var currImageId = trim(formObj.elements["_"+i+"ImageId"].value);
		var currParentImageId = trim(formObj.elements["_"+i+"ParentImageId"].value);
		var currCheckbox = formObj.elements["_"+i+"Copy"];
		
		//Break if all the pseudo images for all platforms are traversed.
		if(imageId == currImageId || parentImageId == currImageId || parentImageId == currParentImageId){
		}
		else{
			break;
		}
		
		if(parentImageId == currImageId){
			if(currCheckbox.checked){
				parentImageSelected = true;
			}
			else{
				parentImageSelected = false;
			}
		}
		if(imageId == currImageId && parentImageSelected){
			currCheckbox.checked = pseudoCheckbox.checked;
		}
	} 	
 }
      		
</SCRIPT>
<!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->

<form action="ImageNameValidator" method="post" name="copyImageList" >
  <INPUT TYPE="HIDDEN" NAME="callingForm" VALUE="copyImageList">
  <INPUT TYPE="HIDDEN" NAME="workingReleaseId" VALUE="<%=workingReleaseId%>">
  <INPUT TYPE="HIDDEN" NAME="releaseNumberId" VALUE="<%=releaseId%>">
  <INPUT TYPE="HIDDEN" NAME="os" VALUE="<%=rnmInfo.getOsType()%>">
  <input type="hidden" name="_submitformflag" value="0" />

<center>
  <%= htmlButtonSaveImages1 %><br /><br />
</center>
<%if(pseudoImageListArray!=null && pseudoImageListArray.size()>0){ %>
<small><style="font-style:italic;"><U>NOTE:</U><I> Pseudo Images are represented as italicized rows</I></style></small>
<%}%>
<center>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">

      <tr bgcolor="#d9d9d9">
    <td align="center" valign="top"><span class="dataTableTitle">
      Select Copy<br />

      <a href="javascript:checkboxSelectAll('copyImageList','Copy')"><img
          src="<%=pathGfx%>/btn_all_mini.gif" border="0"
          /></a><a href="javascript:checkboxSelectNone('copyImageList','Copy')"><img
          src="<%=pathGfx%>/btn_none_mini.gif" border="0" /></a>
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      <a href="ImageListCopy.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=ImageListSortAsc.ImageSort%>"/>
     ImageName
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      <a href="ImageListCopy.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=ImageListSortAsc.PlatformSort%>"/>
      Platform
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Min Flash
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Min Dram
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      CCO
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Deferal
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      SoftwareA
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Type
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->
    </td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Licensed
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
    <td align="center" valign="top"><span class="dataTableTitle">
      Test
    </span></td>
    <% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%> 
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Posting Type
    </span></td>
    <%} %>
<%
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
    //----------------------------------------------------------------
     if( "IOS".equals(rnmInfo.getOsType()) ) {
%>
     <td align="center" valign="top"><span class="dataTableTitle">
         ISSU State
     </span></td>
<%
      } // if( "IOS".equals(rnmInfo.getOsType()) )
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 11/07/2006 nadialee: END
    //----------------------------------------------------------------
%>
      </tr>

    <%
      //Following are added for the sort function
      String sortByWhat = request.getParameter("sort");
          //preparing to sort
      ArrayList ImageListArray = new ArrayList(ImageListCollection);
      if(sortByWhat != null){
            ImageListArray = sortBean.getImageListColSorted(sortByWhat, ImageListArray);
      }
      
    //-------------------------------------------------------------------------------
    // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
    //-------------------------------------------------------------------------------

      //Adding pseudo images to sorted ImageList to create an arraylist with Parent image and pseudo image
      //The parent image+platform will be followed by its pseudo image and platform. Also setting up a corresponding 
      //arraylist imageTypeList which will help identify if the image is parent image, pseudo image or normal image 
      //so that further processing will be simpler.
      imageTypeList = new ArrayList();
      ArrayList ImageListArrayTemp = new ArrayList();
      ImageListArrayTemp.addAll(ImageListArray);
      Iterator ImageListArrayTempItr = ImageListArrayTemp.iterator();
      int index=0;
      Integer prevImageId = null;
      
      
      while(ImageListArrayTempItr.hasNext()){
      	ImageListInfo imageListInfoTemp = (ImageListInfo)ImageListArrayTempItr.next();
      	imageTypeList.add(index,"normal");
      	      	
      	if(pseudoImageListArray !=null && pseudoImageListArray.size() >0 ){
	      	Iterator pseudoImageListArrayItr = null;
	      	pseudoImageListArrayItr = pseudoImageListArray.iterator();
	      	int indexpseudo = 0;
	      	boolean firstparentMarked = false;
	      	boolean parentMarked = false;
	      	
	      	 while(pseudoImageListArrayItr.hasNext()){
	      		 ImageListInfo pseudoImageListInfoTemp = (ImageListInfo)pseudoImageListArrayItr.next();
	      		 
	      		 if(pseudoImageListInfoTemp.getParentImageId()!=null && pseudoImageListInfoTemp.getParentImageId().intValue()!=0
	      			&& imageListInfoTemp.getImageId().intValue() == pseudoImageListInfoTemp.getParentImageId().intValue()
	      			&& imageListInfoTemp.getPlatformId().intValue() == pseudoImageListInfoTemp.getPlatformId().intValue()){
	      				      			 
		      	      	if(!firstparentMarked && prevImageId==null || (prevImageId != null && prevImageId.intValue() != imageListInfoTemp.getImageId().intValue())){
		      				imageTypeList.remove(index);
		      				imageTypeList.add(index,"parentfirst");
		      				firstparentMarked = true;
		      			 }
		      	      	else{
		      	      		if(!parentMarked){
			      				imageTypeList.remove(index);
			      				imageTypeList.add(index,"parent");
			      				parentMarked = true;
		      	      		}
			      		}
		      			indexpseudo++;
		      			imageTypeList.add((index+indexpseudo),"pseudo");
		      			ImageListArray.add((index+indexpseudo),pseudoImageListInfoTemp);
		      		 }
	      	 }
	      	index = index + indexpseudo;
      	}
      	prevImageId = imageListInfoTemp.getImageId();
      	index++;
      }
     
      //-------------------------------------------------------------------------------
      // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
      //-------------------------------------------------------------------------------      
    
      //Using Array list and iterating
      Iterator imageListRecords = ImageListArray.iterator();
      //initializes the index
      int imageIndex = 0;
      int parentImageIndex = 0;
      int firstParentImageIndex = 0;
      int imageListTotalIndex = ImageListArray.size();
      //Iterating through the Image List Records for display
      while (imageListRecords.hasNext()) {
        mImageListInfo = (ImageListInfo) imageListRecords.next();
        
      //Licensing and Pseudo Image feature changes May 2008 - Akshay
        if("pseudo".equals(imageTypeList.get(imageIndex))){ 
          %>
          <tr bgcolor="#ffffff" style="font-style:italic;">
          <%}else{%>
          	<tr bgcolor="#fffccc">
          <%} %>
        <input type="Hidden" name="<%="_"+imageIndex+"ImageName"%>" value="<%=mImageListInfo.getImageName()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"ImageId"%>" value="<%=mImageListInfo.getImageId()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"PlatformId"%>" value="<%=mImageListInfo.getPlatformId()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"PlatformName"%>" value="<%=mImageListInfo.getPlatformName()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"MinFlash"%>" value="<%=mImageListInfo.getMinFlash()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"MinDram"%>" value="<%=mImageListInfo.getMinDram()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"ccoFlag"%>" value="<%=mImageListInfo.getCcoFlag()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"cdcAccessLevel"%>" value="<%=mImageListInfo.getCdcAccessLevel()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"Test"%>" value="<%=mImageListInfo.getTest()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"Type"%>" value="<%=mImageListInfo.getType()%>" />
        <input type="Hidden" name="<%="_"+imageIndex+"Licensed"%>" value="<%=mImageListInfo.getLicensed()%>" /><!--Licensing and Pseudo Image feature changes May 2008 - Akshay-->
        <input type="Hidden" name="<%="_"+imageIndex+"SwtMdfId"%>" value="<%=((mImageListInfo.getMdfSwtConceptId() ==null) ? "" : "" + mImageListInfo.getMdfSwtConceptId())%>" />
	<input type="Hidden" name="<%="_"+imageIndex+"ImagePostingType"%>" value="<%=mImageListInfo.getMImagePostingType()%>" />
	<input type="Hidden" name="<%="_"+imageIndex+"ParentImageId"%>" value="<%=((mImageListInfo.getParentImageId()==null)? "" : "" + mImageListInfo.getParentImageId())%>" />
              <!--Licensing and Pseudo Image feature changes May 2008 - Akshay-->
		
		
		<%
		//-------------------------------------------------------------------------------
		// Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
		//-------------------------------------------------------------------------------
		  //Validation: -Pseudo image cannot be checked without checking its Parent Image.
       	  //Likewise Parent Image cannot be unchecked if its Pseudo Image is checked.
		if("pseudo".equals(imageTypeList.get(imageIndex))){%>
			<td align="center" valign="top"><span class="dataTableData">
	            <input type="checkbox" value="Y" name="<%="_"+imageIndex+"Copy"%>" onclick="if(!_<%=parentImageIndex%>Copy.checked){ _<%=imageIndex%>Copy.checked=false; alert('Image ' + _<%=parentImageIndex%>ImageName.value + ' for platform ' + _<%=parentImageIndex%>PlatformName.value + ' must be checked before checking its Pseudo Image'); return;} checkPseudoforSelectedPlatform('<%=imageIndex%>','<%=imageListTotalIndex%>','<%=firstParentImageIndex%>');"/>
	            <input type="Hidden" name="imageListTotalIndex" value="<%= imageListTotalIndex %>" />
	        </span></td>
        <%}else if("parent".equals(imageTypeList.get(imageIndex)) || "parentfirst".equals(imageTypeList.get(imageIndex))){ 
        	parentImageIndex = imageIndex;
        	if("parentfirst".equals(imageTypeList.get(imageIndex))){
        		firstParentImageIndex = imageIndex;	
        	}
        %>
			<td align="center" valign="top"><span class="dataTableData">
	            <input type="checkbox" value="Y" name="<%="_"+imageIndex+"Copy"%>" onclick="checkSelectedPseudo('<%=imageIndex%>','<%=imageListTotalIndex%>','<%=firstParentImageIndex%>')"/>	            
	            <input type="Hidden" name="imageListTotalIndex" value="<%= imageListTotalIndex %>" />
	        </span></td>
		<%}else{ %>
	        <td align="center" valign="top"><span class="dataTableData">
	            <input type="checkbox" value="Y" name="<%="_"+imageIndex+"Copy"%>"/>
	            <input type="Hidden" name="imageListTotalIndex" value="<%= imageListTotalIndex %>" />
	        </span></td>
        <%}
		//-------------------------------------------------------------------------------
		// Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
		//-------------------------------------------------------------------------------
        %>
        
        <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getImageName() %>
        </span></td>
        <td align="left" valign="top"><span class="dataTableData">
              <%=(mImageListInfo.getPlatformName()==null||"null".equals(mImageListInfo.getPlatformName()))?"":mImageListInfo.getPlatformName()%>
        </span></td>
            <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getMinFlash()%>
        </span></td>
                <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getMinDram()%>
        </span></td>
        <% if (spritAccessManager.isAdminGLA()) {
            Integer cdclvl = mImageListInfo.getCdcAccessLevel();
            %> <td valign="top" align="center"> <%
            if (cdclvl.equals(new Integer(0))) { %>
                Not Going to CCO
            <% } else if (cdclvl.equals(new Integer(1))) { %>
                Guest Registered
            <% } else if (cdclvl.equals(new Integer(2))) { %>
                Contract Registered
            <% } else { %>
                Access Level Not Known
            <% } %> </td> <%
          } else { %>
            <% if(mImageListInfo.getCcoFlag()!= null){
                if(mImageListInfo.getCcoFlag().equals("Y")) { %>
                    <td valign="top" align="center">
                    <img src="../gfx/ico_check.gif" />
                    </td>
                <% } else { %>
                    <td valign="top" align="center">
                       <img src="../gfx/ico_cross.gif" />
                    </td>
                        <% }
                    } else { %>
                <td valign="top" align="center">
                <img src="../gfx/ico_cross.gif" />
                </td>
                    <% }
                } %>

                <% if(mImageListInfo.getDeffered()!= null){
                if(mImageListInfo.getDeffered().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% }
                } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>

                <%
                if(mImageListInfo.getSoftwareAdvisory()!= null){
                if(mImageListInfo.getSoftwareAdvisory().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
        <td align="center" valign="top"><span class="dataTableData">
            <%= mImageListInfo.getType()%>
        </span></td>
        
        <%
      //-------------------------------------------------------------------------------
      // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
      //-------------------------------------------------------------------------------
        if(mImageListInfo.getLicensed()!= null){
                if(mImageListInfo.getLicensed().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
        <% }
      //-------------------------------------------------------------------------------
      // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
      //-------------------------------------------------------------------------------                
        %>

                <% if(mImageListInfo.getTest()!= null){
                if(mImageListInfo.getTest().equals("T")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                
        <!-- Sprit 6.9 adding image Posting Type for copy image -->
       <input type="Hidden" name="releasePostingTypeId"  value="<%=postingTypeId %>" />
   		<% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>  
        <td align="left" valign="top"><span class="dataTableData">
      		<%=mImageListInfo.getMImagePostingType()%>
     	</span></td>
     	<%} %>
     <!-- End Sprit 6.9 add image Posting Type -->         
<%
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
    //----------------------------------------------------------------
     if( "IOS".equals(rnmInfo.getOsType()) &&
         imageId2IssuStateInfoHash != null &&
         imageId2IssuStateInfoHash.containsKey(mImageListInfo.getImageId())
       ) {
         issuStateVect = (Vector) imageId2IssuStateInfoHash.get(mImageListInfo.getImageId());

         issuState = (String) issuStateVect.elementAt(1);

         issuState = (issuState==null || issuState.trim().length()==0 ) ? "N/A" : issuState;

         if( issuStateDispHighlightVect != null &&
             issuState != null &&
             issuState.trim().length() > 0 &&
             issuStateDispHighlightVect.contains(issuState) ) {

             fontTagOpen  = "<font color=\"ff0000\">";
             fontTagClose = "</font>";
         } else {
            fontTagOpen  = "";
            fontTagClose = "";
         }

%>
     <td align="center" valign="top"><span class="dataTableData"><%=fontTagOpen%>
         <%=issuState%>
     <%=fontTagClose%></span></td>
<%
      }
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 11/07/2006 nadialee: END
    //----------------------------------------------------------------
    //Licensing and Pseudo Image feature changes May 2008 - Akshay
    if("pseudo".equals(imageTypeList.get(imageIndex))){%>
    	<td align="center" valign="top"><span class="dataTableData">N/A</span></td>
<%
    }
%>
      </tr>
      <%  imageIndex ++;
       } %>

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table><br />

  <%= htmlButtonSaveImages2 %>
</center>

<%=Footer.pageFooter(globals)%>

<!-- end -->
