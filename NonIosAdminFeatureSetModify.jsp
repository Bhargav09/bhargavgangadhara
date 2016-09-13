<%--.........................................................................
: DESCRIPTION:
:    Feature Set Modify Page: 
:
: CSCud06651	
: AUTHORS: Divya Garg  ( digarg@cisco.com )
: Enhancement: CSCud06651
: Copyright (c) 2012 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................--%>
<%@page import="com.cisco.eit.sprit.dataobject.FeatureSetNonIosInfo"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="com.cisco.eit.sprit.model.dao.csprfeatureset.CsprFeatureSetDAO"%>
<%@ page import="com.cisco.eit.sprit.ui.FeatureSetUpGUI"%>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI"%>
<%@ page import="com.cisco.eit.sprit.gui.Footer"%>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner"%>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext"%>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager"%>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants"%>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo"%>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals"%>
<%@ page import="com.cisco.rtim.ui.TableMaker"%>
<%@ page import="com.cisco.rtim.util.WebUtils"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Enumeration"%>
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
Integer nCsprFeatureSetId=null;
String strCsprFeatureSetId;
FeatureSetNonIosInfo fsInfo = null;

// Initialize globals
globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );
spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
strCsprFeatureSetId = request.getParameter("csprfeaturesetid");

try {
	nCsprFeatureSetId = new Integer(strCsprFeatureSetId);
} catch(Exception e) {
	response.sendRedirect("CsprFeatureSetupEdit.jsp");
	return;
}

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

<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<%
FeatureSetUpGUI handler = new FeatureSetUpGUI(globals);
HashMap colMask = handler.getColumnMask();
Vector mFeatureSetInfo = handler.getAllByCsprFeatureSetId(nCsprFeatureSetId);
if(mFeatureSetInfo.size()>0){
fsInfo = (FeatureSetNonIosInfo) mFeatureSetInfo.get(0);
}
Vector  listOfNonOs  = handler.getOsTypesForFSet(); 

if( !handler.hasUserAccess())
{
    response.sendRedirect("ErrorAccessPermissions.jsp");
}  // if( !spritAccessManager.isAdminSprit() )
%>

<span class="headline"> <align="center">Feature Set
	Information for "<%=fsInfo.getFeatureSetName()%>"</align>
</span>
<br />
<br />

<%
// See if there were any messages generated
servletMessages = (String) request.getAttribute( "Sprit.servMsg" );

if( servletMessages!=null ) {
%>
<br />
<%=servletMessages%>
<br />
<br />
<%         
}  // if( servletMessages!=null )
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

  function trim(str) {
       for (var k=0; k<str.length && str.charAt(k)<=" " ; k++) ;
       var newString = str.substring(k,str.length)
       for (var j=newString.length-1; j>=0 && newString.charAt(j)<=" " ; j--) ;

       return newString.substring(0,j+1);
  }

//........................................................................
// DESCRIPTION:
// Submit the form.
//........................................................................
function submitEditFeatureSet() {

    var THIS_FUNC = "[CsprFeatureSetModify.jsp.submitEditFeature] ";
    var formObj;
    var elements;



    // Make a shortcut to our form's objects.
    formObj = document.forms['editFeatureSet'];
    elements = formObj.elements;

<% if(((Boolean) colMask.get("FeatureSetName")).booleanValue()) { %>
    if(trim(elements['featuresetname'].value) == '' || trim(elements['featuresetname'].value) == null || trim(elements['featuresetname'].value) == "NULL") {
    	alert('FeatureSet Name can\'t be empty or NULL');
    	return false;
    }
<% } %>

<% if(((Boolean) colMask.get("FeatureSetDesc")).booleanValue()) { %>
    if(trim(elements['featuresetdesc'].value) == '' || trim(elements['featuresetdesc'].value) == null || trim(elements['featuresetdesc'].value) == "NULL") {
    	alert('FeatureSet Description can\'t be empty or NULL');
    	return false;
    }
<% } %>


<% if (((Boolean) colMask.get("OsTypeName")).booleanValue()) { %>
if(trim(elements['ostypename'].value) == null || trim(elements['ostypename'].value) == ''){
    	alert('Os Type can\'t be empty');
    	return false;
    }
<% } %>

    // See if we've already submitted this form.  If so then halt!
    if( elements['_submitformflag'].value==0 )
    {
        // Flag it.  Change the image too.
        elements['_submitformflag'].value=1;
        
        setImg('btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
        setImg('btnSaveUpdates2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");

        document.forms['editFeatureSet'].submit();
     }  // if( elements['_submitformflag'].value==0 )

} // function submitEditFeature()

function resetForm() {
    var formObj = document.forms['editFeatureSet'];
    var elements = formObj.elements;

	formObj.reset();
	var result = "";
	
	
	}
//-->
</script>

<form name="editFeatureSet" action="FeatureSetProcessor" method="post">
	<input type="hidden" name="csprfeaturesetid"
		value="<%=fsInfo.getCsprfeatureSetId()%>"> <input
		type="hidden" name="featuresetnameid"
		value="<%=fsInfo.getFeatureSetNameId()%>"> <input
		type="hidden" name="featuresetdescid"
		value="<%=fsInfo.getFeatureSetDescId()%>"> <input
		type="hidden" name="ostypeid" value="<%=fsInfo.getOstypeid()%>">
	<input type="hidden" name="callingForm" value="editFeature"> <input
		type="hidden" name="_submitformflag" value="0"> <input
		type="hidden" name="isgoinftocco" value="">

	<center>
		<%= htmlButtonSubmit1 %>&nbsp;&nbsp;&nbsp; <img
			src="../gfx/btn_reset_image.gif" alt="reset" border="0"
			name="btnReset1" onclick="javascript:resetForm()"><br />
		<br />

		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td align="left" valign="top"><span class="dataTableTitle">*
						required fields. </span></td>
			</tr>

			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td bgcolor="#BBD1ED">
					<table border="0" cellpadding="3" cellspacing="1">
						<% if(((Boolean) colMask.get("FeatureSetName")).booleanValue()) { %>
						<tr>
							<td align="left" valign="top" bgcolor="#d9d9d9"><span
								class="dataTableTitle">FeatureSet Name *</span></td>
							<td align="left" valign="top" bgcolor="#ffffff"><span
								class="dataTableTitle"> <input type="text"
									name="featuresetname" size="15"
									value="<%=fsInfo.getFeatureSetName()%>"
									OnKeyUp='toUpper(this);' OnChange='toUpper(this);'
									onBlur='toUpper(this);'> <input type="hidden"
									name="oldfeaturesetname"
									value="<%=fsInfo.getFeatureSetName()%>">
							</span></td>
						</tr>
						<% } 

 if(((Boolean) colMask.get("FeatureSetDesc")).booleanValue()) { %>
						<tr>
							<td align="left" valign="top" bgcolor="#d9d9d9"><span
								class="dataTableTitle">FeatureSet Description*</span></td>
							<td align="left" valign="top" bgcolor="#ffffff"><span
								class="dataTableTitle"> <input type="text"
									name="featuresetdesc" size="30"
									value="<%=fsInfo.getFeatureSetDesc()%>"
									OnKeyUp='toUpper(this);' OnChange='toUpper(this);'
									onBlur='toUpper(this);'> <input type="hidden"
									name="oldfeaturesetdesc"
									value="<%=fsInfo.getFeatureSetDesc()%>">
							</span></td>
						</tr>
						<% } 

   if( ((Boolean) colMask.get("OsTypeName")).booleanValue() ) { %>

						<tr>
							<td align="left" valign="top" bgcolor="#d9d9d9"><span
								class="dataTableTitle">OS Type *</span></td>
							<td align="left" valign="top" bgcolor="#ffffff"><span
								class="dataTableTitle"> <%if(listOfNonOs != null && !(listOfNonOs.isEmpty())) {%>
									<select name="ostypename">
										<% for(int i=0; i < listOfNonOs.size(); i++) { 
                           		      if( fsInfo.getOstypename() != null && fsInfo.getOstypename().equals(listOfNonOs.get(i))) { %>
										<option value="<%=listOfNonOs.get(i)%>" selected><%=listOfNonOs.get(i)%></option>
										<%}else {%>
										<option value="<%=listOfNonOs.get(i)%>"><%=listOfNonOs.get(i)%></option>
										<% }
                           		  }
                           		%>
								</select> <%}else{%> <select name="ostypename">
										<option value="" selected>List Is Empty</option>
								</select> <%}%> <input type="hidden" name="oldostypename"
									value="<%=fsInfo.getOstypename()%>">
							</span></td>
						</tr>
						<%  } 
   if( ((Boolean) colMask.get("IsGoingToCco")).booleanValue() ) { %>
						<tr>
							<td align="left" valign="top" bgcolor="#d9d9d9"><span
								class="dataTableTitle">Is Going To Cco</span></td>
							<td align="center" valign="top" bgcolor="#ffffff"><span
								class="dataTableTitle"> <input type="checkbox"
									name="isgoingtocco"
									<%=((fsInfo.getIsFSetGoingToCCO().equals("Y")) ? "CHECKED" : "")%>>
									<input type="hidden" name="oldisgoingtocco"
									value="<%=fsInfo.getIsFSetGoingToCCO()%>">
							</span></td>
						</tr>

						<% } %>
					</table>
				</td>
			</tr>
		</table>
		<br />
		<%= htmlButtonSubmit2 %><br />
		<br />
	</center>
</form>

<ul>
	<li><a href="NonIosAdminFeatureSet.jsp">Feature Set View</a></li>
</ul>
<%= Footer.pageFooter(globals) %>
