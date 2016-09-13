<!--.........................................................................
: DESCRIPTION:
: Admin Menu Page: Place to Add new feature Set...
:
: AUTHORS:
: CSCud06651	
: @author Divya Garg  (digarg@cisco.com)
: Enhancement : CSCud06651 
: Copyright (c) 2012 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@page import="com.cisco.eit.sprit.dataobject.FeatureSetNonIosInfo"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.cisco.eit.sprit.model.dao.csprfeatureset.CsprFeatureSetDAO" %>
<%@ page import="com.cisco.eit.sprit.ui.FeatureSetUpGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>




<%
	SpritAccessManager spritAccessManager;
SpritGlobalInfo globals;
SpritGUIBanner banner;
String htmlButtonSubmit1;
String htmlButtonSubmit2;
String pathGfx;
String servletMessages;
boolean isSpritAdmin=false;
// Initialize globals
globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );
spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

	
// Set up banner for later
banner =  new SpritGUIBanner( globals );
banner.addContextNavElement( "REL:",
    SpritGUI.renderReleaseNumberNav(globals,null)
    );

// HTML macros
htmlButtonSubmit1 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSaveUpdates1",
            "Save Updates",
            "javascript:submitEditFeatureSet()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates1')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
            );

htmlButtonSubmit2 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSaveUpdates2",
            "Save Updates",
            "javascript:submitEditFeatureSet()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates2')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates2')"
            );
%>


<%=SpritGUI.pageHeader( globals,"Admin Menu","" )%>
<%=banner.render()%>

<%
	isSpritAdmin=spritAccessManager.isAdminSprit();
if(!(isSpritAdmin))
{
    response.sendRedirect("ErrorAccessPermissions.jsp");
}  // if( !spritAccessManager.isAdminSprit() )
%>

<span class="headline">
    <align="center">Feature Set Mapping - NonIOS<align="center">
</span><br /><br />

<%
	// See if there were any messages generated
servletMessages = (String) request.getAttribute( "Sprit.servMsg" );

if( servletMessages!=null ) {
    PrintWriter printWriter;
    printWriter = response.getWriter();
    printWriter.print( ""
        + "<br />\n"
        + servletMessages
        + "<br /><br />\n\n"
        );
}  // if( servletMessages!=null )
FeatureSetNonIosInfo          mFeatureSetNonIosInfo           = null;
Vector                    listOfNonOs        = new Vector();

FeatureSetUpGUI gui = new FeatureSetUpGUI(globals);

CsprFeatureSetDAO dao = (CsprFeatureSetDAO)SpringUtil.getApplicationContext().getBean("csprFeatureSetDAO");  //Spring JDBC

listOfNonOs  = gui.getOsTypesForFSet();
%>

<script language="javascript"><!--
// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================

//........................................................................
// DESCRIPTION:
// Changes the up/over images if the form hasn't been submitted.
//........................................................................
function actionBtnSaveUpdates(elemName) {
    if( document.forms['editFeatureSet'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
}

function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['editFeatureSet'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
}


//........................................................................
// DESCRIPTION:
// Submit the form.
//........................................................................
function submitEditFeatureSet() {
    var THIS_FUNC = "[CsprFeatureSetupEdit.jsp.submitEditFeatureSet] ";
    var formObj;
    var elements;

    // Make a shortcut to our form's objects.
    formObj = document.forms['editFeatureSet'];
    elements = formObj.elements;
    // See if we've already submitted this form.  If so then halt!
   // alert(formObj.newOsType.value);
    //alert("elements['newOSType'].value" + elements['newOSType'].value);
    if( elements['_submitformflag'].value==0 )
    {
        if(checkValidationErrors()) {
          // Flag it.  Change the image too.
          elements['_submitformflag'].value=1;
          setImg( 'btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
          setImg( 'btnSaveUpdates2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
  
          //----------------------------------------------------
          // Submit the form.
          //----------------------------------------------------
          document.forms['editFeatureSet'].submit();
        } else {
          return;
        }
    }  // if( elements['_submitformflag'].value==0 )
} // function submitEditFeature()

function checkValidationErrors() {
	  var validRegex = /^[0-9a-zA-Z-_\s]+$/ ;
	  var formObj = document.forms['editFeatureSet'];
	  if (formObj.newFeatureName.value != "" && !validRegex.test(formObj.newFeatureName.value)) {
	    alert( "FeatureSet Name can not have special characters, only A-Z,a-z,0-9, -, _ and space are allowed" );
	    return false;
	  }
	  if(formObj.newFeatureName.value == "NULL" || formObj.newFeatureName.value == null){
		  alert( "FeatureSet Name can't be set as NULL" );
		    return false; 
	  }
	  if (formObj.newFeatureDesc.value != "" && !validRegex.test(formObj.newFeatureDesc.value)) {
	    alert( "FeatureSet Description can not have special characters, only A-Z,a-z,0-9, -, _ and space are allowed" );
	    return false;
	  }
	  if(formObj.newFeatureDesc.value == "NULL" || formObj.newFeatureDesc.value == null){
		  alert( "FeatureSet Description can't be set as NULL" );
		    return false; 
	  }
	  return true;
}

//--></script>

<form name="editFeatureSet" action="FeatureSetProcessor" method="post" >

<input type="hidden" name="callingForm" value="newFeature">
<input type="hidden" name="_submitformflag" value="0" />

<%
if (isSpritAdmin ) {

%>
<input type="hidden" name="_addFeatureFlag" value="1" />
<%
} else {
%>
	<input type="hidden" name="_addFeatureFlag" value="0" />
	<%
}
%>

<center>
<%
if (isSpritAdmin ) { %>
<%= htmlButtonSubmit1 %><br /><br />
<%
}
%>
<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#BBD1ED">
                <table border="0" cellpadding="3" cellspacing="1">
                <tr bgcolor="#d9d9d9">
<%
    if (gui.isColumnRequired("Obsolete")) {
%>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">Delete</span>
                    </td>
<%
    } //Show the Obsolete Column for Feature Editors Only
%>
                    <td align="center" valign="top"><span class="dataTableTitle">
                        FeatureSet Name *
                    </span></td>
                    <td align="center" valign="top"><span class="dataTableTitle">
                        FeatureSet Description *
                    </span></td>
                    <td align="center" valign="top"><span class="dataTableTitle">
                        OS Type *
                    </span></td>
                    <td align="center" valign="top"><span class="dataTableTitle">
                        Is Going To Cco 
                    </span></td>
    </tr>
<%
if (spritAccessManager.isAdminSprit())
{
// Only allow add for the Admin Feature Editors
%>
                <tr bgcolor="#F5D6A4">
<%
    if (isSpritAdmin) {
%>
                    <td align="center" valign="top"><img src="../gfx/b1x1.gif" /></td>
<%
    }

%>
                    <td align="left" valign="top"><span class="dataTableData">
                        Add
  <img src="../gfx/ico_arrow_right_orange.gif" />
      <input type="text" name="newFeatureName" OnKeyUp='toUpper(this);'
        OnChange='toUpper(this);' onBlur='toUpper(this);' size="22" value="" />
</span></td>
 <td align="left" valign="top"><span class="dataTableData">
  <input type="text" name="newFeatureDesc" OnKeyUp='toUpper(this);'
     OnChange='toUpper(this);' onBlur='toUpper(this);' size="52" value="" />
</span></td>
<td align="left" valign="top"><span class="dataTableData">

    <%if(listOfNonOs != null && !(listOfNonOs.isEmpty())) {%>
    
    <input type="hidden" name="newOsTypeName" value="<%=listOfNonOs.get(0)%>">
    
    <select name="newOSType" size="1">
        <% for(int nIndex=0; nIndex<listOfNonOs.size();nIndex++){%>
            <option value="<%=listOfNonOs.get(nIndex)%>"><%=listOfNonOs.get(nIndex)%></option>
        <% }%>
    </select>
       <%}else{%>
        <input type="hidden" name="newOsTypeName" value="">
       <select name="newOSType" size="1">
        	<option value=" ">List Is Empty</option>
    </select>
    <%}%>
</span></td>
 <td align="left" valign="top"><span class="dataTableData">
  <input type="checkbox" name="isGoingToCco" value="" />
</span></td>

<%} %>

<tr bgcolor="#ffffff">
<%

List featureSetsVector = null;
featureSetsVector = dao.findByCsprFeatureSet(null);
int featureSetIndex = featureSetsVector.size();

int featureSetInc=0;

%>

<input type="Hidden" name="featureSetIndex" value="<%=featureSetIndex%>" >

<%
for(featureSetInc=0; featureSetInc<featureSetIndex; featureSetInc++) {

	mFeatureSetNonIosInfo = (FeatureSetNonIosInfo) featureSetsVector.get(featureSetInc);
    if (! (mFeatureSetNonIosInfo.getOstypename().equals("IOS") || mFeatureSetNonIosInfo.getOstypename().equals("CatOS") || mFeatureSetNonIosInfo.getOstypename().equals("IOSXE") || mFeatureSetNonIosInfo.getOstypename().equals("IOX") )){
    	System.out.println("mFeatureSetNonIosInfo name"+mFeatureSetNonIosInfo.getFeatureSetName());
    	List FeatureSetList = dao.findByCsprFeatureSet(null);
%>
    	<tr bgcolor="#ffffff">
    	<%= gui.renderFeatureSetRow(mFeatureSetNonIosInfo, "editFeatureSet" ,isSpritAdmin)%>
    
<% }} %>
</tr>
</table>
</td></tr>
</table>
</td></tr>
</table>
<br />

<%
if (isSpritAdmin) { %>
<%= htmlButtonSubmit2 %><br /><br />
<%
}
%>
</center>
</form>

<%= Footer.pageFooter(globals) %>
<!-- end xxxx-->

