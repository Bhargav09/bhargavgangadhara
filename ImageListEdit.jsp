<!--.........................................................................
: DESCRIPTION:
: Image List page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002-2010 by Cisco Systems, Inc. All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties,
                 java.util.ArrayList,java.util.HashMap" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator"%>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.beans.ImageCcoPusPostedInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.*" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.imagelist.*" %>
<%@ page import="com.cisco.eit.sprit.logic.releaseselectorsession.ReleaseSelectorSessionHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.logic.releaseselectorsession.ReleaseSelectorSessionLocal" %>
<%@ page import="com.cisco.eit.sprit.model.imagetype.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.ui.ImageListGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.ParseString" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritPropertiesUtil" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.ImageDbUtil" %>
<%@ page import="com.cisco.eit.sprit.util.ImageListSortAsc" %>


<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>
<%
  String strOsType;
  boolean showDelete = true;
  CisrommAPI cisrommAPI;
  Context ctx;
  Integer releaseNumberId;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseSelectorSessionHomeLocal rssHome;
  ReleaseSelectorSessionLocal rssObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String htmlButtonCopyImages1;
  String htmlButtonCopyImages2;
  String htmlButtonSaveUpdates1;
  String htmlButtonSaveUpdates2;
  String ImageFilter = "";
  String pathGfx;
  String PlatformFilter = "";
  String releaseNumber = null;
  String[] minFlashArr;
  String[] minDramArr;
  Integer postingTypeId = new Integer(0);
  ArrayList pseudoImageListArray = new ArrayList();
  
  //SpritPropertiesUtil spritPropertiesUtil ;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  try {
    releaseNumberId = new Integer(
      WebUtils.getParameter(request,"releaseNumberId"));
      PlatformFilter = WebUtils.getParameter(request,"PlatformFilter");
      ImageFilter = WebUtils.getParameter(request,"ImageFilter");
  } catch( Exception e ) {
    // Nothing to do.
  }

    MonitorUtil monUtil = new MonitorUtil();
        monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image List Edit");


  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  } 
 
  
// Grab a session object so we can ask it to go and perform services for us.
try {
  ctx = new InitialContext();
  rssHome = (ReleaseSelectorSessionHomeLocal)
    ctx.lookup("ejblocal:ReleaseSelectorSession.ReleaseSelectorSessionHome");
  if( rssHome==null ) {
    throw new Exception("ReleaseSelectorSessionHome can't initialize.");
  }  // if( rssHome==null ) {
  rssObj = rssHome.create();
  if( rssObj==null ) {
    throw new Exception("ReleaseSelectorSession can't initialize.");
  }  // if( rssObj==null )
  else
  {
  rnmInfo = rssObj.getReleaseNumberModelInfo( globals,releaseNumberId );
  releaseNumber = rnmInfo.getFullReleaseNumber();
  postingTypeId = rnmInfo.getPostingTypeId();
  }

  // Get MinFlash and MinDram Arrays
  //spritPropertiesUtil = new SpritPropertiesUtil(globals.gs("envMode"));
  minFlashArr =  SpritPropertiesUtil.getMinFlashArray();
  minDramArr = SpritPropertiesUtil.getMinDramArray();



  } catch( Exception e ) {
    throw e;
  }  // catch

  strOsType = rnmInfo.getOsType();
// Make sure we can see this page.  If not then send them to view
// mode!
if( !spritAccessManager.isMilestoneOwner(releaseNumberId,releaseNumber, "IL") ) {
  response.sendRedirect( ""
      + "ImageList.jsp?releaseNumberId="
      + WebUtils.escUrl(releaseNumberId.toString())
      );
}  // if( !spritAccessManager.isMilestoneOnwer() )

// Set up banner for later
banner =  new SpritGUIBanner( globals );
banner.addReleaseNumberElement(releaseNumberId);
//banner.addContextNavElement( "REL:",
//    SpritGUI.renderReleaseNumberNav(globals,releaseNumber )
//    );

String releaseId = request.getParameter("releaseNumberId");

// Figure out if we need to deny the delete boxes because this release
// has posted.
try {
  cisrommAPI = new CisrommAPI();
} catch( Exception e ) {
  throw e;
}  // try
boolean goneToCco = false;
boolean goneToOpus = false;

if( cisrommAPI.getMilestoneActualDate((new Integer(releaseId)).intValue(),"CCO FCS")!=null) {
  showDelete = false;
  goneToCco = true;
}  // if cisrommAPI...

if(cisrommAPI.getMilestoneActualDate((new Integer(releaseId)).intValue(),"OPUS")!=null) {
  showDelete = false;
  goneToOpus = true;
}  // if cisrommAPI...


// HTML macros
/*htmlButtonSaveUpdates1 = SpritGUI.renderButtonRollover(
    globals,
    "btnSaveUpdates1",
    "Save Updates",
    "javascript:validateAndsubmitForm('editImageList')",
    pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
    "actionBtnSaveUpdates('btnSaveUpdates1')",
    "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
    );
*/

htmlButtonSaveUpdates1 = SpritGUI.renderButtonRollover(
    globals,
    "btnSaveUpdates1",
    "Save Updates",
    "javascript: itemsToDelete('editImageList') ",
    pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
    "actionBtnSaveUpdates('btnSaveUpdates1')",
    "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
    );

htmlButtonSaveUpdates2 = SpritGUI.renderButtonRollover(
    globals,
    "btnSaveUpdates2",
    "Save Updates",
    "javascript: itemsToDelete('editImageList') ",
    pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
    "actionBtnSaveUpdates('btnSaveUpdates2')",
    "actionBtnSaveUpdatesOver('btnSaveUpdates2')"
    );
htmlButtonCopyImages1 = SpritGUI.renderButtonRollover(
    globals,
    "btnCopyImages1",
    "Copy Images",
    "javascript:ImageCopyPopup('copyImageList','" + releaseId + "')",
    pathGfx + "/" + "btn_copy_image.gif",
    "setImg('btnCopyImages1','" + pathGfx + "/" + "btn_copy_image.gif" + "')",
    "setImg('btnCopyImages1','" + pathGfx + "/" + "btn_copy_image_over.gif" + "')"
    );
htmlButtonCopyImages2 = SpritGUI.renderButtonRollover(
    globals,
    "btnCopyImages2",
    "Copy Images",
    "javascript:ImageCopyPopup('copyImageList','" + releaseId + "')",
    pathGfx + "/" + "btn_copy_image.gif",
    "setImg('btnCopyImages2','" + pathGfx + "/" + "btn_copy_image.gif" + "')",
    "setImg('btnCopyImages2','" + pathGfx + "/" + "btn_copy_image_over.gif" + "')"
    );

//getting the response from the copy Image JSP
String result;
if(request.getParameter("result") != null)
result = request.getParameter("result");
else
result = "";

%>

<%= SpritGUI.pageHeader( globals,"Image List","" ) %>
<%= banner.render() %>
<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript" src="../js/prototype.js"></script>
<form action="ImageListEdit.jsp">
<%= SpritReleaseTabs.getTabs(globals, "il") %>
<INPUT TYPE="HIDDEN" NAME="releaseNumberId" VALUE="<%=releaseId%>"/>
<%
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );

  if(((request.getParameter("ImageFilter") == null)||(request.getParameter("ImageFilter").equals(""))))
    navBar.addFilters( "ImageFilter", "*", 25,
                        pathGfx+"/filter_label_imgname.gif",
                        "Enter full part/part of the Image Name filter",
                        "Image Name Filter" );
  else
      navBar.addFilters( "ImageFilter", request.getParameter("ImageFilter"), 25,
                         pathGfx+"/filter_label_imgname.gif",
             "Enter full part/part of the Image Name filter",
             "Image Name Filter" );

  if(((request.getParameter("PlatformFilter") == null)||(request.getParameter("PlatformFilter").equals(""))))
      navBar.addFilters( "PlatformFilter", "*", 25,
                        pathGfx+"/filter_label_platform.gif",
            "Enter full part/part of the Platform Name filter",
            "Platform Name Filter" );
    else
        navBar.addFilters( "PlatformFilter", request.getParameter("PlatformFilter"), 25,
                           pathGfx+"/filter_label_platform.gif",
               "Enter full part/part of the Platform Name filter",
               "Platform Name Filter" );



   out.println(SpritGUI.renderTabContextNav( globals,navBar.render(true,
                                                                   false,
                                                                   "ImageList.jsp?releaseNumberId="+releaseNumberId+"&ImageFilter="+request.getParameter("ImageFilter")+"&PlatformFilter="+request.getParameter("PlatformFilter")+"&sort="+ImageListSortAsc.ImageSort,
                                   "ImageListEdit.jsp?releaseNumberId="+releaseNumberId+"&ImageFilter="+request.getParameter("ImageFilter")+"&PlatformFilter="+request.getParameter("PlatformFilter")+"&sort="+ImageListSortAsc.ImageSort,
                                   "ImageListReport.jsp?releaseNumberId="+releaseNumberId+"&ImageFilter="+request.getParameter("ImageFilter")+"&PlatformFilter="+request.getParameter("PlatformFilter")+"&sort="+ImageListSortAsc.ImageSort
                                   )));

%>
<INPUT TYPE="HIDDEN" NAME="sort" VALUE="Image"/>
</form>
<%

Iterator ImageListInfoVector = null;
Collection imageData = null;
ImageListSessionHome mImageListSessionHome = null;
ImageListSession mImageListSession = null;
ImageListInfo mImageListInfo = null;

try
{
    //Context ctx = JNDIContext.getInitialContext();
        Object homeObject = ctx.lookup("ImageListSessionBean.ImageListSessionHome");
        mImageListSessionHome = (ImageListSessionHome)PortableRemoteObject.narrow(homeObject, ImageListSessionHome.class);
        mImageListSession = mImageListSessionHome.create();
}
catch(Exception e)
{

    e.printStackTrace();
 }

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: BEGIN
 //----------------------------------------------------------------
 HashMap imageId2IssuStateInfoHash  = null;
 Vector  issuStateVect              = null;
 String  issuState                  = null;
 Vector  issuStateDispHighlightVect = new Vector();
 boolean foundIssuImage             = false;  //will be used for adoption rate

 issuStateDispHighlightVect.addElement("ISSU_OFF");

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: END
 //----------------------------------------------------------------


 try
 {
 //ImageListInfoVector = mImageListSession.getAllImageListInfo(new Integer(releaseId));

 imageData = mImageListSession.getAllImageListInfoUtil(new Integer(releaseId));
 
	//-------------------------------------------------------------------------------
	//Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
	//-------------------------------------------------------------------------------
	//Get Pseudo Imagelist information	
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
	//Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
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

 } catch(Exception e)
 {

    e.printStackTrace();
 }

if ((request.getParameter("ImageFilter") != null) ||(request.getParameter("PlatformFilter") != null)){
if((!request.getParameter("ImageFilter").equals("*")) || (!request.getParameter("PlatformFilter").equals("*"))) {
imageData = ImageListGUI.htmlFilter(request.getParameter("ImageFilter"),
                          request.getParameter("PlatformFilter"),
                          imageData);
}
}

%>

<script language="javascript"><!--
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................
  function actionBtnSaveUpdates(elemName) {
    if( document.forms['editImageList'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['editImageList'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
  }
//--></script>

<%
if("IOS".equals(rnmInfo.getOsType())) {

ArrayList ImageListArray = new ArrayList(imageData);
String bootImageRequired = mImageListSession.getBootImageRequiredAndNotPresent(ImageListArray);


if (! bootImageRequired.equals("")) { %>
<br>
<center><table border='1'><tr><td bgcolor='#d9d9d9'><font color="#ff0000"><br></b>Warning <%=bootImageRequired %> platform requires boot image in this release.</b><br><br></font></td></tr></table></center>
<br>
<% } // if (! bootImageRequired.equals(""))
} //if("IOS".equals(rnmInfo.getOsType())) {
%>


<center>

<form action="ImageProcessor" method="post" name="editImageList">
  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="callingForm" value="editImageList" />
  <input type="hidden" name="releaseId" value="<%=releaseId%>" />
  <input type="hidden" name="PlatformFilter" value="<%=PlatformFilter%>" />
  <input type="hidden" name="ImageFilter" value="<%=ImageFilter%>" />
  <input type="hidden" name="result" value="<%=result%>" />
  <input type="hidden" name="showDelete" value="<%=showDelete%>" />
  <INPUT TYPE="HIDDEN" NAME="os" VALUE="<%=rnmInfo.getOsType()%>" />

<table>
<tr> <td>
  <%= htmlButtonSaveUpdates1 %>
</td>
<td>
</td>
<td>
  <%= htmlButtonCopyImages1 %>
</td>
</tr>
</table>
<%=ImageListGUI.htmlSummarize(imageData)%>

<table>
<tr><td></td></tr>
</table>

<!--Licensing and Pseudo Image feature changes May 2008 - Akshay - START -->
<SCRIPT language="javascript">
	//Check/Uncheck all platforms of an image as Licensed if any one of the platform is checked/unchecked
    
    function markAllImageNames(imageName, imageId, imageIndex, imageListSize) {
        var sameImageName = false; 
    	formObj = document.forms['editImageList'];
    	var licensedCheckbox = formObj.elements["_"+imageIndex+"Licensed"];
    	
    	if(!licensedCheckbox.checked){
    		if(checkHasPseudoImages(imageId)){
    			var input_box=confirm("This Image contains Pseudo Image(s). Refer UpgradePlanner Licensing page. Marking this Image as NOT Licensed will delete all its Pseudo Image(s). Do you wish to continue?");
     			if(!input_box){
     				licensedCheckbox.checked = true;
     			}		    		
    		}
    	}
    	
   		for(var i=0; i < imageListSize; i++){
   			if(imageName == formObj.elements["_"+i+"inImageName"].value){
   				sameImageName = true;
   				formObj.elements["_"+i+"Licensed"].checked = licensedCheckbox.checked;
   			}else if(sameImageName && imageName != formObj.elements["_"+i+"inImageName"].value){
   				break;
   			}
   		}
    }
    
	//Verify if the entered image name is same as existing pseudo image
	function checkPseudoImageName(content) {
		var allPseudoImageList = new Array();
      	
      	<%Iterator pseudoImageListRecords = pseudoImageListArray.iterator();
      	int allPseudoImageListidx = 0;
	      while (pseudoImageListRecords.hasNext()) {
	        ImageListInfo mpseudoImageListInfo = (ImageListInfo) pseudoImageListRecords.next();
	        if(mpseudoImageListInfo !=null && mpseudoImageListInfo.getImageName()!=null){
	        %>
	        	allPseudoImageList[<%=allPseudoImageListidx%>] = "<%=mpseudoImageListInfo.getImageName()%>";
	        <%
	      	    allPseudoImageListidx = allPseudoImageListidx + 1;
	      	}
	      }
      %>
      for(var i=0;i < allPseudoImageList.length; i++){
      	if(allPseudoImageList[i] == content){
      		return true;
      	}
      }
      return false;
	}
	
	//Verify if the Licensed image has any pseudo image.
	function checkHasPseudoImages(content) {
		var allPseudoImageList = new Array();
      	
      	<%pseudoImageListRecords = pseudoImageListArray.iterator();
      	int allPseudoImageListindex = 0;
	      while (pseudoImageListRecords.hasNext()) {
	        ImageListInfo mpseudoImageListInfo = (ImageListInfo) pseudoImageListRecords.next();
	        if(mpseudoImageListInfo !=null && mpseudoImageListInfo.getImageName()!=null){
	        %>
	        	allPseudoImageList[<%=allPseudoImageListindex%>] = "<%=mpseudoImageListInfo.getParentImageId() %>";
	        <%
	        allPseudoImageListindex = allPseudoImageListindex + 1;
	      	}
	      }
      %>
      for(var i=0;i < allPseudoImageList.length; i++){
      	if(allPseudoImageList[i] == content){
      		return true;
      	}
      }
      return false;
	}
    
    
</SCRIPT>
<!--Licensing and Pseudo Image feature changes May 2008 - Akshay - END-->

  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      <tr bgcolor="#d9d9d9">
      <% if("CatOS".equals(rnmInfo.getOsType())) {%>
    <td align="center" valign="top"><span class="dataTableTitle">
      Platform
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Featureset Name
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Name
    </span></td>
    <% } else { %>
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Name
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Platform
    </span></td>
    <% } %>
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
      Deferral
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      SoftwareA
    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Type
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->
    <td align="center" valign="top"><span class="dataTableTitle">
      Licensed
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
    <td align="center" valign="top"><span class="dataTableTitle">
      Test
    </span></td>
    
    <% if("IOS".equals(strOsType) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Posting Type
    </span></td>
    <%} %>
    
    <td align="center" valign="top"><span class="dataTableTitle">
    </span></td>
    </tr>

      <tr bgcolor="#F5D6A4">
    <td align="left" valign="top"><span class="dataTableData">
    Add
      <% if("CatOS".equals(rnmInfo.getOsType())) {%>
    <img src="<%=pathGfx%>/ico_arrow_right_orange.gif" />
      <input type="text" name="addPlatformName" size="14" value="" onblur="fillImageName()" onFocus="PlatformPopup('false','<%= "" %>','<%="addPlatformName"%>','<%="addPlatformId"%>')"/>
    </span></td>
    <td align="right" valign="top"><span class="dataTableData">
          <input type="text" name="addFeatureSetName" size="12" value="" onblur="fillImageName()" onkeyup="fillImageName()" />
    </span></td>
    <td align="right" valign="top"><span class="dataTableData">
          <div id="addImageNameLabel"></div>
    </span></td>
    <input type="Hidden" name="addPlatformId" value="" />
    <input type="hidden" name="addImageName" size="12" value="" />
    <% } else { %>
    <img src="<%=pathGfx%>/ico_arrow_right_orange.gif" />
          <input type="text" name="addImageName" id="addImageName" size="12" value="" />
    </span></td>
    <td align="right" valign="top"><span class="dataTableData">
      <input type="text" name="addPlatformName" size="14" value="" onFocus="PlatformPopup('true','<%= "" %>','<%="addPlatformName"%>','<%="addPlatformId"%>')"/>
    </span></td>
    <input type="Hidden" name="addPlatformId" value="" />
    <% } %>
    <td align="right" valign="top"><span class="dataTableData">
    <select name="addMinFlash" size="1" onMouseOver="addMinFlashItems(this, '0')">
		<option   value="0">0</option>    	
    </select></span></td>

        <td align="right" valign="top"><span class="dataTableData">
    <select name="addMinDram" size="1"  onMouseOver="addMinDramItems(this, '0')">
		<option   value="0">0</option>    	
    </select></span></td>
        <td align="left" valign="top"><span class="dataTableData">
        <% if (spritAccessManager.isAdminGLA()) { %>
           <select name="addCCO" size="1">
            <option value="2" Selected="Selected">Contract Registered</option>
            <option value="1">Guest Registered</option>   //rnevitt
            <option value="0">Not Going To CCO</option>
        <% } else { %>

           <input type="checkbox" checked value="Y" name="addCCO"/>
        <% } %>
    </span></td>
        <td align="right" valign="top">&nbsp;</td>
        <td align="right" valign="top">&nbsp;</td>

        <td align="right" valign="top"><span class="dataTableData">
           <select name="addType" size="1">
             <option    value="1" Selected="Selected">I</option>
                <% if("IOS".equals(strOsType)) { %>
             <option    value="2">B</option>
             <option    value="3">S</option>
             <% } %>
           </select></span></td>
    
	    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START --> 
	    <td align="center" valign="top"><span class="dataTableData">
	         <input type="checkbox" name="addLicensedCheckBox" value="Y"/>
	    </span></td>
	    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
           
        <td align="right" valign="top"><span class="dataTableData">
         <input type="checkbox" name="addTestCheckBox" value="T" />
    </span></td>
    
   <!--  6.9 adding imageposting type for adding new image-->
   <input type="Hidden" name="postingType"  value="<%=postingTypeId %>" />
   <% if("IOS".equals(strOsType) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>
         <td align="left" valign="top"><span class="dataTableData">
      		<select name="addImagePostingType">
			              <option value="Hidden">  Hidden</option>
			              <option value="Public" selected>  Public</option>
			              <option value="Hidden with ACL" >  Hidden with ACL</option>          
			</select> 
     </span></td>
    <%}%>
   <!-- 6.9 end -->
 
 <td align="right" valign="top">
       <a href="javascript:ResetForm('editImageList')"><img
                    src="<%=pathGfx%>/btn_resetfield.gif" border="0" /></a>
        </td>
        </tr>

      </table>

  </td></tr>
  </table>
  </td></tr>
  </table>

 <br />
 
 <br />

 <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      <% try
      {
          int ImageListTotalIndex = imageData.size();

      %>
      <input type="Hidden" name="imageTotalIndex" value="<%= ImageListTotalIndex %>" />
      <tr bgcolor="#d9d9d9">
        <td align="center" valign="top"><span class="dataTableTitle">
          Select Delete<br />

          <a href="javascript:checkboxSelectAll('editImageList','delete')"><img
              src="<%=pathGfx%>/btn_all_mini.gif" border="0"
              /></a><a href="javascript:checkboxSelectNone('editImageList','delete')"><img
              src="<%=pathGfx%>/btn_none_mini.gif" border="0" /></a>
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
         <a href="ImageListEdit.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=ImageListSortAsc.ImageSort%>"/>
          Image Name
        </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
         <a href="ImageListEdit.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=ImageListSortAsc.PlatformSort%>"/>
          Platform
        </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
          Software Type
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
    <td align="center" valign="top"><span class="dataTableTitle">
          Licensed
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
    <td align="center" valign="top"><span class="dataTableTitle">
      Test
    </span></td>
    <% if("IOS".equals(strOsType) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>
    <td align="center" valign="top"><span class="dataTableTitle">
          Image Posting Type
    </span></td>
    <%} %>
<%
 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: BEGIN
 //----------------------------------------------------------------
    if( "IOS".equals(rnmInfo.getOsType()) ) {
%>
    <td align="center" valign="top"><span class="dataTableTitle">
      ISSU State
    </span></td>
<%
    }
 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 10/24/2006 nadialee: END
 //----------------------------------------------------------------
%>
       </tr>

       <% //Following are added for the sort function
    String sortByWhat = request.getParameter("sort");
    ArrayList imageDataArray = new ArrayList(imageData);

    if((sortByWhat != null) && (imageDataArray != null))
     imageDataArray = sortBean.getImageListColSorted(sortByWhat, imageDataArray);

    if (imageDataArray != null) {
    ImageListInfoVector = imageDataArray.iterator();
    // Take one by one and display them.

    int imageIndex = 0;
    int imageListSize = imageDataArray.size(); //Licensing and Pseudo Image feature changes May 2008 - Akshay
    ImageDbUtil dbUtil=new ImageDbUtil();
    
   

    while (ImageListInfoVector.hasNext()) {
      mImageListInfo = (ImageListInfo) ImageListInfoVector.next();
      ImageCcoPusPostedInfo mImageCcoPusPostedInfo = dbUtil.getImageCcoOpusPostedInfo(releaseNumber,mImageListInfo.getImageId(),mImageListInfo.getImageName());
      showDelete=mImageCcoPusPostedInfo.isDeleteAllowed().booleanValue();
	%>
      <tr bgcolor="#ffffff">    
      <td align="center" valign="top" bgcolor="#F6E8D0"><span class="dataTableData">
          <%
          if( showDelete ) {
        	  %><input type="checkbox" value="D" name="<%="_"+imageIndex+"delete"%>"/><%
     	  } else 
            out.println(mImageCcoPusPostedInfo.getStatus());
          %>
      </span></td>
      <td align="left" valign="top" size="20"><span class="dataTableData">
        <%= mImageListInfo.getImageName() %>
      </span></td>
      <input type="Hidden" name="<%="_"+imageIndex+"inImageName"%>" value="<%= mImageListInfo.getImageName()  %>" />
      <input type="Hidden" name="<%="_"+imageIndex+"ImageId"%>" value="<%= mImageListInfo.getImageId()  %>" />
      <% if(mImageListInfo.getPlatformId()==null||"null".equals(mImageListInfo.getPlatformId())){ %>
        <input type="Hidden" name="<%="_"+imageIndex+"PlatformId"%>" value="" />
        <input type="Hidden" name="<%="_"+imageIndex+"inPlatformId"%>" value="" />
      <% }else { %>
        <input type="Hidden" name="<%="_"+imageIndex+"PlatformId"%>" value="<%= mImageListInfo.getPlatformId() %>" />
        <input type="Hidden" name="<%="_"+imageIndex+"inPlatformId"%>" value="<%= mImageListInfo.getPlatformId()  %>" />
      <% } %>
      <td align="left" valign="top"><span class="dataTableData">
      <% if("IOS".equals(rnmInfo.getOsType())) {%>
      <input type="text" name="<%="_"+imageIndex+"platformName"%>" size="14" value="<%=(mImageListInfo.getPlatformName()==null||"null".equals(mImageListInfo.getPlatformName()))?"":mImageListInfo.getPlatformName()%>" onFocus="PlatformPopup('false','<%= mImageListInfo.getPlatformId() %>','<%="_"+imageIndex+"platformName"%>','<%="_"+imageIndex+"PlatformId"%>')" />
      <% } else { %>
      <%=(mImageListInfo.getPlatformName()==null||"null".equals(mImageListInfo.getPlatformName()))?"":mImageListInfo.getPlatformName()%>
      <input type="hidden" name="<%="_"+imageIndex+"platformName"%>" size="14" value="<%= mImageListInfo.getPlatformName()  %>" onFocus="PlatformPopup('false','<%= mImageListInfo.getPlatformId() %>','<%="_"+imageIndex+"platformName"%>','<%="_"+imageIndex+"PlatformId"%>')" />
      <% } %>
      <input type="Hidden" name="<%="_"+imageIndex+"inPlatformName"%>"  value="<%= mImageListInfo.getPlatformName()  %>" />
      </span></td>
          <td valign="top" align="left">
               &nbsp;<%=(mImageListInfo.getMdfSwtConceptName()==null || "null".equals(mImageListInfo.getMdfSwtConceptName()))?"":mImageListInfo.getMdfSwtConceptName()%>
          </td>
      <td align="right" valign="top"><span class="dataTableData">
      <select name="<%="_"+imageIndex+"minFlash"%>" size="1"  onMouseOver="addMinFlashItems(this, '<%=mImageListInfo.getMinFlash()%>')">
	      <option   value="<%=mImageListInfo.getMinFlash()%>"><%=mImageListInfo.getMinFlash()%></option>
      </select>
      <input type="Hidden" name="<%="_"+imageIndex+"inMinFlash"%>" value="<%= mImageListInfo.getMinFlash()  %>" />
      </span></td>


      <td align="right" valign="top"><span class="dataTableData">
      <select name="<%="_"+imageIndex+"minDram"%>" size="1" onMouseOver="addMinDramItems(this, '<%=mImageListInfo.getMinDram()%>')">
	      <option   value="<%=mImageListInfo.getMinDram()%>"><%=mImageListInfo.getMinDram()%></option>
      </select>
      <input type="Hidden" name="<%="_"+imageIndex+"inMinDram"%>" value="<%= mImageListInfo.getMinDram()  %>" />
      </span></td>

          <% if (spritAccessManager.isAdminGLA()) {
              Integer cdclvl = mImageListInfo.getCdcAccessLevel();  %>
              <td align="left" valign="top"><span class="dataTableData">
              <select name="<%="_"+imageIndex+"ccoFlag"%>" size="1">
              <option value="1" <% if (cdclvl.equals(new Integer(1))) {  %> Selected="Selected" <% } %>>Guest Registered</option>
              <option value="2" <% if (cdclvl.equals(new Integer(2))) {  %> Selected="Selected" <% } %>>Contract Registered</option>
              <option value="0" <% if (cdclvl == null || cdclvl.equals(new Integer(0))) {  %> Selected="Selected" <% } %>>Not Going To CCO</option>
          </span></td>
          <input type="Hidden" name="<%="_"+imageIndex+"inCcoFlag"%>" size="4" value= "<%=mImageListInfo.getCdcAccessLevel()%>" />
          <% } else { %>

        <%  if ("Y".equals(mImageListInfo.getCcoFlag()) ) {
        %>
            <td align="left" valign="top"><span class="dataTableData">
            <input type="checkbox" checked value="<%=mImageListInfo.getCcoFlag()%>" name="<%="_"+imageIndex+"ccoFlag"%>">
            </span></td>
        <% } else { %>
            <td align="left" valign="top"><span class="dataTableData">
             <input type="checkbox" value="Y" name="<%="_"+imageIndex+"ccoFlag"%>"/>
            </span></td>
        <% }

        %>    <input type="Hidden" name="<%="_"+imageIndex+"inCcoFlag"%>" size="4" value= "<%=mImageListInfo.getCcoFlag()%>" />
      <% } %>

      <input type="Hidden" name="<%="_"+imageIndex+"inCcoFlag"%>" size="4" value= "<%=mImageListInfo.getCcoFlag()%>" />

      <% if(mImageListInfo.getDeffered()!= null){
      if(mImageListInfo.getDeffered().equals("Y")) { %>
      <td valign="top" align="center">
      <img src="<%=pathGfx%>/ico_check.gif" />
      </td>
      <% } else { %>
      <td valign="top" align="center">
                <img src="<%=pathGfx%>/ico_cross.gif" />
      </td>
      <% }
      } else { %>
      <td valign="top" align="center">
                <img src="<%=pathGfx%>/ico_cross.gif" />
      </td>
      <% } %>

      <%
      if(mImageListInfo.getSoftwareAdvisory()!= null){
      if(mImageListInfo.getSoftwareAdvisory().equals("Y")) { %>
      <td valign="top" align="center">
          <img src="<%=pathGfx%>/ico_check.gif" />
      </td>
      <% } else { %>
      <td valign="top" align="center">
                <img src="<%=pathGfx%>/ico_cross.gif" />
      </td>
      <% } %>
      <% } else { %>
      <td valign="top" align="center">
                <img src="<%=pathGfx%>/ico_cross.gif" />
      </td>
      <% } %>

      <input type="Hidden" name="<%="_"+imageIndex+"Deffered"%>" size="4" value="<%= mImageListInfo.getDeffered()  %>" />
      <input type="Hidden" name="<%="_"+imageIndex+"softwareAdvisory"%>" size="4" value="<%= mImageListInfo.getSoftwareAdvisory()  %>" />

      <td align="right" valign="top"><span class="dataTableData">
      <select name="<%="_"+imageIndex+"Type"%>" size="1">
      <% if("IOS".equals(strOsType)) {
      for (int i = 0; i < SpritConstants.IMAGE_TYPE.length; i++) {
      if (SpritConstants.IMAGE_TYPE[i].equalsIgnoreCase((mImageListInfo.getType().toString()))){
      %>
      <option   value="<%=mImageListInfo.getImageTypeId()%>" Selected = "Selected"><%=SpritConstants.IMAGE_TYPE[i]%></option>
      <% }  else  {%>
      <option   value="<%=i+1%>"><%=SpritConstants.IMAGE_TYPE[i]%></option>
      <% } }
      } else {%>
      <option   value="1" Selected = "Selected">I</option>
      <% } %>
      </select>
      <input type="Hidden" name="<%="_"+imageIndex+"inType"%>" value="<%= mImageListInfo.getType()  %>" />
      <input type="Hidden" name="<%="_"+imageIndex+"inImageTypeId"%>" value="<%= mImageListInfo.getImageTypeId()  %>" />
      </span></td>
      
      <%  
    //-------------------------------------------------------------------------------
    // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
    //-------------------------------------------------------------------------------
      if(mImageListInfo.getLicensed() != null){
      if (mImageListInfo.getLicensed().equals("Y")) {
      %>
      <td align="center" valign="top"><span class="dataTableData">
      <input type="checkbox" checked value="<%=mImageListInfo.getLicensed()%>" name="<%="_"+imageIndex+"Licensed"%>" onClick="markAllImageNames('<%=mImageListInfo.getImageName()%>','<%=mImageListInfo.getImageId()%>','<%=imageIndex%>','<%=imageListSize%>')"/>
      </span></td>
      <% } else { %>
      <td align="center" valign="top"><span class="dataTableData">
      <input type="checkbox" value="Y" name="<%="_"+imageIndex+"Licensed"%>" onClick="markAllImageNames('<%=mImageListInfo.getImageName()%>','<%=mImageListInfo.getImageId()%>','<%=imageIndex%>','<%=imageListSize%>')"/>
      </span></td>
      <% }
      } else { %>
      <td align="center" valign="top"><span class="dataTableData">
      <input type="checkbox" value="Y" name="<%="_"+imageIndex+"Licensed"%>" onClick="markAllImageNames('<%=mImageListInfo.getImageName()%>','<%=mImageListInfo.getImageId()%>','<%=imageIndex%>','<%=imageListSize%>')"/>
      </span></td>
      <% } %>
      <input type="Hidden" name="<%="_"+imageIndex+"inLicensed"%>" value="<%= mImageListInfo.getLicensed()  %>" />
      <%  
    //-------------------------------------------------------------------------------
    // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
    //-------------------------------------------------------------------------------

      
      if(mImageListInfo.getTest()!= null){
      if (mImageListInfo.getTest().equals("T")) {
      %>
      <td align="left" valign="top"><span class="dataTableData">
      <input type="checkbox" checked value="<%=mImageListInfo.getTest()%>" name="<%="_"+imageIndex+"Test"%>">
      </span></td>
      <% } else { %>
      <td align="left" valign="top"><span class="dataTableData">
      <input type="checkbox" value="T" name="<%="_"+imageIndex+"Test"%>"/>
      </span></td>
      <% }
      } else { %>
      <td align="left" valign="top"><span class="dataTableData">
      <input type="checkbox" value="T" name="<%="_"+imageIndex+"Test"%>"/>
      </span></td>
      <% } %>
      
      <!-- Sprit 6.9 adding image Posting Type for editing image -->
     <% if("IOS".equals(strOsType) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>
      <td align="left" valign="top"><span class="dataTableData">
      		<select name="<%="_"+imageIndex+"imagePostingType"%>" <%if(mImageCcoPusPostedInfo.isChangePostingTypeAllowed() == Boolean.FALSE){%> DISABLED <%}%> >
			          <option value="Public"
			                <%if(mImageListInfo.getMImagePostingType()!=null && (mImageListInfo.getMImagePostingType().equalsIgnoreCase("Public"))){%> selected <%}%>>Public</option>          
			          <option value="Hidden"  
			              	<%if(mImageListInfo.getMImagePostingType()!=null && (mImageListInfo.getMImagePostingType().equalsIgnoreCase("Hidden"))){%> selected <%}%>>Hidden</option>
                      <option value="Hidden with ACL"  
                            <%if(mImageListInfo.getMImagePostingType()!=null && (mImageListInfo.getMImagePostingType().equalsIgnoreCase("Hidden with ACL"))){%> selected <%}%>>Hidden with ACL</option>
    		</select> 
     </span></td>
    <%} %>
     
     
     <!-- End Sprit 6.9 add image Posting Type -->
           
      <input type="Hidden" name="<%="_"+imageIndex+"inTest"%>" size="4" value="<%= mImageListInfo.getTest()  %>" />
      <input type="Hidden" name="<%="_"+imageIndex+"inImagePostingType"%>"  value="<%=mImageListInfo.getMImagePostingType()%>" />
<%
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 10/24/2006 nadialee: BEGIN
    //----------------------------------------------------------------
     String strCssVal;

     if( "IOS".equals(rnmInfo.getOsType()) &&
         imageId2IssuStateInfoHash != null &&
         imageId2IssuStateInfoHash.containsKey(mImageListInfo.getImageId())
       ) {

         foundIssuImage = true;   // will be used to call CES monitor

         issuStateVect = (Vector) imageId2IssuStateInfoHash.get(mImageListInfo.getImageId());

         issuState = (String) issuStateVect.elementAt(1);

         issuState = (issuState==null || issuState.trim().length()==0 ) ? "N/A" : issuState;

         if( issuStateDispHighlightVect != null &&
             issuState != null &&
             issuState.trim().length() > 0 &&
             issuStateDispHighlightVect.contains(issuState) ) {

                 strCssVal  = "dataTableDataRed";
             } else {
                 strCssVal  = "dataTableData";
             }
%>
     <td align="center" valign="top"><span class=<%=strCssVal%>>
         <%=issuState%>
     </span></td>
<%
      } // if( "IOS".equals(rnmInfo.getOsType()) && ...
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 10/24/2006 nadialee: END
    //----------------------------------------------------------------
%>
      </tr>

      <%
      imageIndex ++;
      }
      }

     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/20/2006 nadialee: BEGIN
     //----------------------------------------------------------------
     //
     // Use same page title for all Image List for easier tracking.
     //
      if( foundIssuImage ) {
         monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image List ISSU State Display");
      } //if( foundIssuImage )
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/20/2006 nadialee: END
     //----------------------------------------------------------------

      }catch(Exception E)
      {}%>

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>
<table>
<tr> <td>
  <%= htmlButtonSaveUpdates2 %>
</td>
<td>
</td>
<td>
  <%= htmlButtonCopyImages2 %>
</td>
</tr>
</table>
</center>

</form>


<form method="get" name="hiddenImageListPopup" >
<input type="hidden" name="showCheckbox" />
<input type="hidden" name="fieldName" />
<input type="hidden" name="selectedPlatformId" />
<input type="hidden" name="fieldId" />
</form>


<script language="javascript">
    function LTrim(String)
    {
      var i = 0;
      var j = String.length - 1;

      if (String == null)
          return (false);

      for (i = 0; i < String.length; i++)
      {
          if (String.substr(i, 1) != ' ' &&
              String.substr(i, 1) != '\t')
              break;
      }

      if (i <= j)
          return (String.substr(i, (j+1)-i));
      else
          return ('');
    }

    function RTrim(String)
    {
      var i = 0;
      var j = String.length - 1;

      if (String == null)
          return (false);

      for(j = String.length - 1; j >= 0; j--)
      {
          if (String.substr(j, 1) != ' ' &&
              String.substr(j, 1) != '\t')
          break;
      }

      if (i <= j)
          return (String.substr(i, (j+1)-i));
      else
          return ('');
    }

    function Trim(String)
    {
      if (String == null)
          return (String);

      return RTrim(LTrim(String));
    }

    function fillImageName() {
        formObj = document.forms['editImageList'];
        var strPlatformNameValue = formObj.addPlatformName.value.toLowerCase();
        var strHyphen = '';
        var strFeatureSet = Trim(formObj.addFeatureSetName.value);

        if( strPlatformNameValue.indexOf('-') == -1) {
            strHyphen = '-';
        }

        if( strPlatformNameValue != '' || strFeatureSet != '' ) {
            formObj.addImageName.value = strPlatformNameValue + strHyphen + strFeatureSet;
        } else {
            formObj.addImageName.value = '';
        }
            document.getElementById('addImageNameLabel').innerHTML = '<span class="dataTableData">' +
                                    formObj.addImageName.value + '</span>';


    }
    
  //........................................................................
  // DESCRIPTION:
  //     Submits this form and checks for errors.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  function validateAndsubmitForm(formName) {
    var formObj;
    var elements;
    var fieldObj;
    var fieldValue;
    var idx;
    var nameRegex;
    var platformName;
    var imageName;
    var bSubmitFlag = true;
    var imageNotEmpty = true;
    var platformNotEmpty = true;
    var where_is_boot;
    var i = 0;
    var numberofhyphen = 0;
    var MiddlePartStart = 0;
    var MiddlePartEnd = 0;
    var inc = 1;

    formObj = document.forms[formName];
    elements = formObj.elements;

    // Check to see if we've submitted this before!
    if( elements['_submitformflag'].value==1 ) {
      return;
    }

    //if (formObj == 'copyImageList')
    //{
    //  W = window.open('ReleaseSelectorPopupIC.jsp','PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=500,height=500')
    //    W.focus();
    //}

    //if(formObj == 'editImageList') {

    platformName = Trim(formObj.addPlatformName.value);
    imageName    = Trim(formObj.addImageName.value);
    isLicensed   = formObj.addLicensedCheckBox.checked;

    //if the new platform or image name is empty, this alerts the user
    //if both are empty, we are fine
    if (formObj.addPlatformName.value.length == 0 ) {
      platformNotEmpty = false;
      imageNotEmpty = false;
      if (formObj.addImageName.value.length != 0 && !formObj.addTestCheckBox.checked && (ImageNameValidate(formObj.addImageName.value,'<%=strOsType%>'))) {
        alert("ERROR: Please enter New Platform Name");
        bSubmitFlag = false;
        platformNotEmpty = false;
        imageNotEmpty = true;
        return;

      } else if (formObj.addImageName.value.length != 0 && !formObj.addTestCheckBox.checked && !(ImageNameValidate(formObj.addImageName.value,'<%=strOsType%>'))) {
        alert("Error: This image does not comply with ios naming conventions and must be marked test if it is to be saved.");
        bSubmitFlag = false;
            imageNotEmpty = true;
            return;
      }
      else if (formObj.addImageName.value.length != 0) {
            imageNotEmpty = true;
      }
    } else {

          if (formObj.addImageName.value.length == 0 ) {
        alert("ERROR: Please enter New Image Name");
        bSubmitFlag = false;
        imageNotEmpty = false;
        return;
      } else if (!(ImageNameValidate(formObj.addImageName.value,'<%=strOsType%>'))) {  // if
        alert("Error: An image which does not comply with ios naming conventions can not have a platform assigned.");
        bSubmitFlag = false;
        imageNotEmpty = true;
        return;
      } else {
        imageNotEmpty = true;

      }
    }  // else
    
    //Licensing and Pseudo Image feature changes May 2008 - Akshay START
	//If imageName is same as Pseudo Image name in the release
	if(checkPseudoImageName(imageName)){
      		alert("Error: This image name already exists in release as Pseudo Image Name. Please verify UpgradePlanner Licensing page.");
        	bSubmitFlag = false;
            imageNotEmpty = true;
            return;
     }
     
    
    //Gets user confirmation on addition if the image already exists and there is mismatch between existing and new image Licensing flag
     var i=0;
     for(i=0; i <<%=imageData.size()%>; i++){
     	if(imageName == trim(formObj.elements["_"+i+"inImageName"].value)){
     	if(isLicensed && !formObj.elements["_"+i+"Licensed"].checked){
     			var input_box=confirm("Image is being added as Licensed. The existing Image is NOT Licensed. Do you wish to continue?");
     			if(!input_box){
     				bSubmitFlag = false;
     				return;
     			}
     			else{
     				break;
     			}
     		}
			if(!isLicensed && formObj.elements["_"+i+"Licensed"].checked){
     			var input_box=confirm("Image is being added as NOT Licensed. The existing Image is Licensed. Do you wish to continue?");
     			if(!input_box){
     				bSubmitFlag = false;
     				return;
     			}
     			else{
     				break;
     			}
     		}      		      		
     	}
     }
     //Licensing and Pseudo Image feature changes May 2008 - Akshay END


    // See if we put up a wait message or not?  Use threshholds of 100 and
    // 300+ records.  Remember, the if-then-else is in Java, not JavaScript!
    <%
      if( imageData.size()>300 ) {
        %> alert( ""
          + "Now processing <%=imageData.size()%> records...\n\n"
          + "This amount of records will take several minutes to process. "
          + "Please be patient."
          + "\n\nPress OK to continue."
          );
        <%
      } else if( imageData.size()>100 ) {
        %> alert( ""
          + "Now processing <%=imageData.size()%> records...\n\n"
          + "Processing may take a couple of minutes. "
          + "Please be patient."
          + "\n\nPress OK to continue."
          );
        <%
      }  // else if 100
    %>

    // if the fields are not null, then validates for the Image
    // Name and Boot Image

    if(imageNotEmpty ) {

      if (( !(ImageNameValidate(formObj.addImageName.value,'<%=strOsType%>')) ) && !formObj.addTestCheckBox.checked) {
        alert("Error: Invalid Image Name. Please enter the valid Image Name.         \nNote: Name should follow the standard pattern xxxx-yyy-zz or xxxx-yyy.zzz");
        bSubmitFlag = false;
        return;
      }  // if

      var iter = formObj.addImageName.value.length;
      var imageValue = formObj.addImageName.value;

        // make sure lengh of image name doesn't exceed the limit.
        if(iter > <%=SpritConstants.IOS_MAXIMUM_IMAGE_LENGTH%>) {
        alert("Error: Invalid Image Name. The length of the image name can't exceed <%=SpritConstants.IOS_MAXIMUM_IMAGE_LENGTH%>");
        bSubmitFlag = false;
        return;
      }

      <% if("CatOS".equals(strOsType)) {%>
            var strFeatureSetName = formObj.addFeatureSetName.value.length;
            if( strFeatureSetName < 1 ) {
                alert( "Featureset Name can't be empty" );
                bSubmitFlag = false;
                return;
            }
      <% } %>

      <% if("IOS".equals(strOsType)) { %>
      i=0; //CSCsu54883 -fix to initialize variable
      while(i<=iter) {
        if (imageValue.substring(i,i+1) == "-") {
          numberofhyphen++;
        }  // if

        if(numberofhyphen == 1 && inc == 1) {
          inc++;
          MiddlePartStart = i;
        }  // if

        if(numberofhyphen == 2) {
          MiddlePartEnd = i;
          var MiddlePart = imageValue.substring(MiddlePartStart+1,MiddlePartEnd);
          // make sure lengh of featureset name doesn't exceed the limit.

          if(MiddlePart.length > <%=SpritConstants.IOS_MAXIMUM_FEATURE_SET_LENGTH%>) {
            alert("Error: Invalid Image Name. The length of the feature set name can't exceed <%=SpritConstants.IOS_MAXIMUM_FEATURE_SET_LENGTH%>");
            bSubmitFlag = false;
            return;
          }

          where_is_boot = MiddlePart.indexOf('boot');
          break;
        }  // if

        i++;
      }  // while

      //This would validate the presence of boot
      //var where_is_boot=formObj.addImageName.value.toLowerCase().indexOf('boot');

      var newType = formObj.elements['addType'].options[
          formObj.elements['addType'].selectedIndex
          ].value;
      var msg = "Error: ";

      //This is validating the patterns like boot image whose type to be "B"
      //for the new images
      if(where_is_boot >= 0 && newType != 2) {
        msg += "Type of New Image should be B for the Boot Image";
        alert(msg);
        bSubmitFlag = false;
        return;
      }  // if

      if(where_is_boot == -1 && newType == 2)  {
        msg += "New ImageName does not have Boot as Middle Part,     \n Please change the New ImageName to suit Type B";
        alert(msg);
        bSubmitFlag = false;
        return;
      }  // if
      <% }

      if("CatOS".equals(strOsType)) {
          %>

<%--
          var nPlatformIndex = imageName.toUpperCase().indexOf(platformName.toUpperCase());
          if(nPlatformIndex != 0 ) {
            alert( "Error: Invalid image Name. Image name should start with platform name.");
            bSubmitFlag = false;
            return;
          }  // if

--%>
         var strFeatureSet = imageName.substr(platformName.length);
        // make sure lengh of featureset name doesn't exceed the limit.
        if(formObj.addFeatureSetName.value.length > <%=SpritConstants.IOS_MAXIMUM_FEATURE_SET_LENGTH%>) {
            alert("Error: Invalid Image Name. The length of the feature set name can't exceed <%=SpritConstants.IOS_MAXIMUM_FEATURE_SET_LENGTH%>");
            bSubmitFlag = false;
            return;
        }
          // make sure lengh of image name doesn't exceed the limit.
        if(imageName.length > <%=SpritConstants.IOS_MAXIMUM_IMAGE_LENGTH%>) {
            alert("Error: Invalid Image Name. The length of the image name can't exceed <%=SpritConstants.IOS_MAXIMUM_IMAGE_LENGTH%>");
            bSubmitFlag = false;
            return;
        }
      <%
      }
      %>
    }  // if

    var errormsg = "";

    //validating all the fields that are in the update part of the form for the boot images
    for (i =0; i<formObj.imageTotalIndex.value; i++) {
      var imageRecordDelete = "_"+i+"delete";
          var checkThisRow;

          checkThisRow = false;
          if( formObj.elements['showDelete'].value=="false" ) {
            checkThisRow = true;
          } else {  // if( formObj.elements['showDelete'].value=="false" )
            if( formObj.elements[imageRecordDelete] != undefined &&
                formObj.elements[imageRecordDelete].checked == false ) {
              checkThisRow = true;
            }  // if( formObj.elements[imageRecordDelete].checked == false )
          }  // else if( formObj.elements['showDelete'].value=="false" )

          // validate the rows if they are NOT deleted
      if(checkThisRow==true) {
        var typeField = "_"+i+"Type";
        var imageNameField = "_"+i+"inImageName";
        var imageCCOFlag = "_"+i+"ccoFlag";
        var imageTestFlag = "_"+i+"Test";
        var minDram = "_"+i+"minDram";
        var minFlash = "_"+i+"minFlash";
        var minDramFieldValue = formObj.elements[minDram].value;
        var minFlashFieldValue = formObj.elements[minFlash].value;
        var imageNameFieldValue = formObj.elements[imageNameField].value;
        var up_where_is_boot = imageNameFieldValue.toLowerCase().indexOf('boot');
        var typeFieldValue = formObj.elements[typeField].options[
            formObj.elements[typeField].selectedIndex
            ].value;
        var platformField = "_"+i+"platformName";
        var platformFieldValue = formObj.elements[platformField].value;
    <% if (spritAccessManager.isAdminGLA()) { %>

         var CcoAccessLvl = formObj.elements[imageCCOFlag].options[
            formObj.elements[imageCCOFlag].selectedIndex
            ].value;
         //formObj.elements[imageCCOFlag].value;
        if((CcoAccessLvl!=0) && (formObj.elements[imageTestFlag].checked)) {
           errormsg +="Error: Select either CCO or Test Flag, selecting both is invalid for the Image : " + imageNameFieldValue + " \n";
           bSubmitFlag = false;
            }

        if ((CcoAccessLvl!=0) && (formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: This image ("+imageNameFieldValue+") which does not comply with image naming standards\n  The image must remain a Test image.";
               bSubmitFlag = false;
            }

            if ((CcoAccessLvl!=0) && !(formObj.elements[imageTestFlag].checked) && ImageNameValidate(imageNameFieldValue,'<%=strOsType%>') && platformFieldValue == "") {
                   errormsg +="Error: This image ("+imageNameFieldValue+") requeries a platform to be assigned before being set to CCO.\n";
                       bSubmitFlag = false;
            }

            if ((CcoAccessLvl!=0) && (formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: This image ("+imageNameFieldValue+") does not have a platform specified.\n The image must remain a test image until it a platform is specified.";
               bSubmitFlag = false;
            }
        if ((CcoAccessLvl==0) && !(formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: Image ("+imageNameFieldValue+") which does not comply with image naming standards should remain marked as a Test image.";
               bSubmitFlag = false;
            }

            if ((CcoAccessLvl==0) && !(formObj.elements[imageTestFlag].checked) && platformFieldValue == "") {
           errormsg +="Error: Image ("+imageNameFieldValue+") does not have a platform specified.\n The image must have a platform to go to CCO.\n";
               bSubmitFlag = false;
            }

            if ((CcoAccessLvl!=0) && !formObj.elements[imageTestFlag].checked && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')){
              errormsg +="Error: Image "+imageNameFieldValue+" is selected as CCO but does not conform to image naming conventions. \n";
          bSubmitFlag=false;
        }

    <% } else { %>

        //checks the mutual exclusiveness of the flag of cco and test
        if ((formObj.elements[imageCCOFlag].checked) && (formObj.elements[imageTestFlag].checked)) {
           errormsg +="Error: Select either CCO or Test Flag, selecting both is invalid for the Image : " + imageNameFieldValue + " \n";
           bSubmitFlag = false;
            }


        if ((formObj.elements[imageCCOFlag].checked) && (formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: This is image ("+imageNameFieldValue+") which does not comply with image naming standards\n  The image must remain a Test image.";
               bSubmitFlag = false;
            }


            if ((formObj.elements[imageCCOFlag].checked) && (formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: This image ("+imageNameFieldValue+") does not have a platform specified.\n The image must remain a test image until it a platform is specified.";
               bSubmitFlag = false;
            }
        if (!(formObj.elements[imageCCOFlag].checked) && !(formObj.elements[imageTestFlag].checked) && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')) {
           errormsg +="Error: Image ("+imageNameFieldValue+") which does not comply with image naming standards should remain marked as a Test image.";
               bSubmitFlag = false;
            }

            if (!(formObj.elements[imageCCOFlag].checked) && !(formObj.elements[imageTestFlag].checked) && ImageNameValidate(imageNameFieldValue,'<%=strOsType%>') && platformFieldValue == "") {
           errormsg +="Error: Image ("+imageNameFieldValue+") does not have a platform specified.\n The image must have a platform to go to CCO.\n";
               bSubmitFlag = false;
            }

            if ((formObj.elements[imageCCOFlag].checked) && !(formObj.elements[imageTestFlag].checked) && ImageNameValidate(imageNameFieldValue,'<%=strOsType%>') && platformFieldValue == "") {
           errormsg +="Error: Image ("+imageNameFieldValue+") does not have a platform specified.\n The image must have a platform to go to CCO.\n";
               bSubmitFlag = false;
            }

            if (formObj.elements[imageCCOFlag].checked && !formObj.elements[imageTestFlag].checked && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')){
              errormsg +="Error: Image "+imageNameFieldValue+" is selected as CCO but does not conform to image naming conventions. \n";
          bSubmitFlag=false;
        }



    <% } %>

            if (platformFieldValue != "" && !ImageNameValidate(imageNameFieldValue,'<%=strOsType%>')){
              errormsg +="Error: Image "+imageNameFieldValue+": does not conform to image naming convention and cannot have a platform selected. \n";
          bSubmitFlag=false;
        }

        if (platformFieldValue == "" && (minDramFieldValue != 0 || minFlashFieldValue != 0)) {
          errormsg += "Error: "+imageNameFieldValue + " does not have a platform specified, therefore minDram and minFlash values may not be entered \n";
          bSubmitFlag = false;
        }

        if(up_where_is_boot != -1 &&  typeFieldValue != 2) {
          errormsg += "Error: Image Type should be B for the Boot Image: "+imageNameFieldValue + " \n";
          bSubmitFlag = false;
        }

        if(up_where_is_boot == -1 && typeFieldValue == 2) {
          errormsg += "Error: Image Type should not be B for the Image: "+imageNameFieldValue + " \n";
          bSubmitFlag = false;
        }

      }  // if
    }  // for

    <% if (spritAccessManager.isAdminGLA()) { %>
             var addCcoAccessLvl = formObj.addCCO.options[
                formObj.addCCO.selectedIndex
            ].value;

        //checks the mutual exclusiveness of the flag of cco and test
            if ((addCcoAccessLvl!=0) && (formObj.addTestCheckBox.checked))
            {  errormsg +="Error: Select either CCO or Test Flag, selecting both is invalid for the Image : " + formObj.addImageName.value +" \n";
               bSubmitFlag = false;
            }

    <% } else { %>

        //checks the mutual exclusiveness of the flag of cco and test
            if ((formObj.addTestCheckBox.checked) && (formObj.addCCO.checked))
            {  errormsg +="Error: Select either CCO or Test Flag, selecting both is invalid for the Image : " + formObj.addImageName.value +" \n";
               bSubmitFlag = false;
            }

    <% } %>

        if(errormsg.length > 0) {
      alert(errormsg);
    }
    
    //Fix for CSCsi68437 - Prevents duplicate Image and Platform combination - START
	var i=0;
	var size = <%=imageData.size()%>;
	
    for(i=0; i <size; i++){
    	cImageName = trim(formObj.elements["_"+i+"inImageName"].value);
    	cPlatformName = trim(formObj.elements["_"+i+"platformName"].value);
	    for(var j=(i+1); j <size; j++){
			nImageName = trim(formObj.elements["_"+j+"inImageName"].value);
	    	nPlatformName = trim(formObj.elements["_"+j+"platformName"].value);

	    	if(nImageName == cImageName){
	    		if(nPlatformName == cPlatformName){
	    			alert('Duplicate image "'+nImageName+'" and platform "'+nPlatformName+'" exist. Please verify.');
	    			bSubmitFlag = false;
	    		}
	    	}else{
	    		break; //Assuming that the imagelist on ImageListEdit page is always sorted by image name.
	    	}
	    }
    }
    var addplatformNames = Trim(formObj.addPlatformName.value);
    var cImageName    = Trim(formObj.addImageName.value);
    if(cImageName.length >0 && addplatformNames.length > 0){
    	var addplatformName = addplatformNames.split(':');
        for(i=0;i< addplatformName.length;i++){
        	for(j=0;j <size; j++){
            	var nImageName = trim(formObj.elements["_"+j+"inImageName"].value);
    	    	var nPlatformName = trim(formObj.elements["_"+j+"platformName"].value);

    	    	if(nImageName == cImageName){
    	    		if(nPlatformName == addplatformName[i]){
    	    			alert('Duplicate image "'+nImageName+'" and platform "'+nPlatformName+'" exist. Please verify.');
    	    			bSubmitFlag = false;
    	    			break;
    	    		}
    	    	}                
            }
        }
        
    }
   //Fix for CSCsi68437 - Prevents duplicate Image and Platform combination - END

    if(bSubmitFlag) {
      //  Flag form as submitted.  Change the image too.
      elements['_submitformflag'].value=1;
      //setImg( 'btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
      //setImg( 'btnSaveUpdates2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

      formObj.submit();
    }  // if
  }  // function submitForm
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


//Input parameters: checkbox "yes" or "no",
//fieldName is the field name which poped up the platformPopup
//selectedPlatformId:Platform Id that has to be edited
  function PlatformPopup(showCheckbox, selectedPlatformId, fieldName, fieldId, osTypeId){
    // 1. populate platform popup form at the bottom of this page with
    //    input values
    // 2. unfocus current field (blur)
    // 3. pop up new window with target href going to PlatformPopup.jsp
    var W;
    document.forms['hiddenImageListPopup'].elements['showCheckbox'].value=showCheckbox;
    document.forms['hiddenImageListPopup'].elements['selectedPlatformId'].value=selectedPlatformId;
    document.forms['hiddenImageListPopup'].elements['fieldName'].value=fieldName;
    document.forms['hiddenImageListPopup'].elements['fieldId'].value=fieldId;
    document.forms['editImageList'].elements[fieldName].blur();
    W = window.open('PlatformPopup.jsp?showCheck='+showCheckbox+'&platformFieldId='+fieldId+'&platformFieldName='+fieldName+'&imageSize=<%=imageData.size()%>&osname=<%=strOsType%>','PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=500,height=500')
    W.focus();
  }


  function ImageCopyPopup(formName, releaseId) {
    W = window.open('ReleaseSelectorPopupImageCopy.jsp?workingReleaseId='+releaseId+'&osType=<%=strOsType%>','PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=750,height=500')
    W.focus();
  }

  //........................................................................
  // DESCRIPTION:
  //     Resets the form
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  function ResetForm(formName) {
  var formObj;
  var elements;
  var fieldObj;
  var fieldValue;

  formObj = document.forms[formName];
  elements = formObj.elements;

  formObj.addImageName.value = "";
  formObj.addPlatformName.value = "";
  formObj.addMinDram.value = 0;
  formObj.addMinFlash.value = 0;
  formObj.addCCO.checked = true;
  formObj.addLicensedCheckBox.checked = false;
  formObj.addType.value = 1;
  formObj.addTestCheckBox.checked = false;

  }

	// Image Name Validator Object. The object makes a Ajax call
	// to verify the image name
	var imageNameValidator = {
		verifyImageName: function(imageName,releaseId,formName) {
		   	if (imageName != null && imageName.length >0 ) {
			   	var url = 'ImageNameValidator';
			   	var pars = 'imageName='+imageName+'&releaseId='+releaseId+'&callingForm='+formName;
			   	var ajax_req = new Ajax.Request(
			   						url,
			   						{
			   							method: 'post',
			   							parameters: pars,
			   							onComplete: this.showValidationResult
			   						});
			   }
		},
		showValidationResult: function(xmlReq) {
			if (xmlReq.responseText != ''){
				showImageNameErrorMessage(xmlReq.responseText);
			}else
				processItemsToDelete('editImageList');
		}
	}  
	
	function showImageNameErrorMessage(errorString){
		var arrDelimiter = errorString.split('~!');
		if (arrDelimiter.length != 1)
			alert('Formatted value of Image Name greater than '+ arrDelimiter[arrDelimiter.length-1] +' characters');		
		else
			alert('Image Name could not be validated. Try again later or contact support team for assistance');	
	}

  function processItemsToDelete(formName){
	var elements;
	var formObj;
	var numRecs;
	var idx;
	var regexDeleteCheckbox;
	var elementName;
	
	formObj = document.forms[formName];
	elements = formObj.elements;
	// Count the number of records that have been selected.
	numRecs = 0;
	regexDeleteCheckbox = /^_\d+delete$/;
	for( idx=0; idx<elements.length; idx++ ) {
	  elementName = elements[idx].name;
	  if( elementName.match( regexDeleteCheckbox ) ) {
	    if( elements[idx].checked==true ) {
	      	numRecs++;
	    }  // if( elements[idx].checked==true )
	  }  // if( elementName.match( regexDeleteCheckbox ) )
	}  // for( idx=0; idx<elements.length; idx++ )
	
	 if( numRecs>0 ) {
	        if (confirm (numRecs + ' image(s) marked for deletion. Are you sure you want to delete these images?')) validateAndsubmitForm('editImageList'); 
	
	 } else { // if( numRecs==0 )
	
	   validateAndsubmitForm('editImageList'); 
	 }
  }

  function itemsToDelete(formName)
  {
  	if($F('addImageName') != '')
		imageNameValidator.verifyImageName($F('addImageName'),<%=releaseId %>,formName);
	else
		processItemsToDelete(formName);
  }
  
	var arrayMinFlash = new Array();
	var arrayMinDram = new Array();

    var arrayAccessLevel = new Array();
	arrayAccessLevel[0] =  "Not Going To CCO";
	arrayAccessLevel[1] =  "Guest Registered"
	arrayAccessLevel[2] =  "Contract Registered";   
	
    <% for (int i = 0; i < minFlashArr.length; i++) { %>
    	arrayMinFlash[<%=i%>]="<%=minFlashArr[i]%>";
	<% } %>	
    <% for (int i = 0; i < minDramArr.length; i++) { %>
    	arrayMinDram[<%=i%>]="<%=minDramArr[i]%>";
	<% } %>	

	function addAccessLevelItems(combo, defaultval) {
	    if( combo.options.length > 1)
	    	return;
	    	
		for(var i = 0; i < arrayAccessLevel.length; i++) {
			combo.options[i] = new Option(i, arrayAccessLevel[i]);
			if( arrayAccessLevel[i] == defaultval)
				combo.selectedIndex = i;
		}
	}
	
	function addMinFlashItems(combo, defaultval) {
	    if( combo.options.length > 1)
	    	return;
	    	
		for(var i = 0; i < arrayMinFlash.length; i++) {
			combo.options[i] = new Option(arrayMinFlash[i], arrayMinFlash[i]);
			if( arrayMinFlash[i] == defaultval)
				combo.selectedIndex = i;
		}
	}

	function addMinDramItems(combo, defaultval) {
	    if( combo.options.length > 1)
	    	return;
	    	
		for(var i = 0; i < arrayMinDram.length; i++) {
			combo.options[i] = new Option(arrayMinDram[i], arrayMinDram[i]);
			if( arrayMinDram[i] == defaultval)
				combo.selectedIndex = i;
		}
	}

</script>

<%= Footer.pageFooter(globals) %>
<!-- end -->
