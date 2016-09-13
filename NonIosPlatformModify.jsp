<%--.........................................................................
: DESCRIPTION:
:    Platform Admin Page: 
:
: AUTHORS: Divya Garg  ( digarg@cisco.com )
: Enhancement: CSCuc15774
: Copyright (c) 2012 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................--%>
<%@ page import="com.cisco.eit.shrrda.individualplatform.*,
                 java.io.PrintWriter" %>
<%@ page import="com.cisco.eit.shrrda.platformfamily.*" %>
<%@ page import="com.cisco.eit.shrrda.platformmdf.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.PlatformInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.platformfacade.*" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelLocal" %>
<%@ page import="com.cisco.eit.sprit.ui.PlatformSetupGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
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
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>
<%@ page import="com.cisco.eit.sprit.dataobject.Pair" %>

<%
SpritAccessManager spritAccessManager;
SpritGlobalInfo globals;
SpritGUIBanner banner;
String htmlButtonSubmit1;
String htmlButtonSubmit2;
String pathGfx;
String servletMessages;
Integer nPlatformId=null;
String strPlatformId;

// Initialize globals
globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );
spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
strPlatformId = request.getParameter("platformid");

try {
	nPlatformId = new Integer(strPlatformId);
} catch(Exception e) {
	response.sendRedirect("NonIosPlatformSetupEdit.jsp");
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
            "javascript:submitEditPlatform()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates1')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
            );

htmlButtonSubmit2 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSaveUpdates2",
            "Save Updates",
            "javascript:submitEditPlatform()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates2')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates2')"
            );

%>

<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<%
PlatformSetupGUI handler = new PlatformSetupGUI(globals);
HashMap colMask = handler.getColumnMask();
PlatformInfo mPlatformInfo = handler.getPlatformInfo(nPlatformId);

Vector  listOfNonOs  = handler.getNonOsTypesForPAM(); 
Vector listOfERP = handler.getAllERPPlatformInfoNames();

if( !handler.hasUserAccess())
{
    response.sendRedirect("ErrorAccessPermissions.jsp");
}  // if( !spritAccessManager.isAdminSprit() )
%>

<span class="headline">
    <align="center">Platform Information for "<%=mPlatformInfo.getPlatformName()%>"</align>
</span><br /><br />

<%
// See if there were any messages generated
servletMessages = (String) request.getAttribute( "Sprit.servMsg" );

if( servletMessages!=null ) {
%>
         <br/>
            <%=servletMessages%>
         <br/><br/>
<%         
}  // if( servletMessages!=null )
%>

<script language="JavaScript" src="../js/MdfTree.jsp"></script>
<script language="javascript"><!--
// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================

//........................................................................
// DESCRIPTION:
// Changes the up/over images if the form hasn't been submitted.
//........................................................................
function actionBtnSaveUpdates(elemName) {
    if( document.forms['editPlatform'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
}

function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['editPlatform'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
}

function add( source, destination) {

     var srcSelectBox = document.getElementsByName(source)[0];
     var dstSelectBox = document.getElementsByName(destination)[0];

     for( var i = srcSelectBox.length-1; i>=0; i--) {

         if(srcSelectBox.options[i].selected) {
             // add this to second box
             var opt = new Option(srcSelectBox.options[i].text, srcSelectBox.options[i].value);
             dstSelectBox.options[dstSelectBox.options.length] = opt;

             srcSelectBox.options[i].selected = false;
             // remove from the second one
             for(var j=i;j<srcSelectBox.length-1;j++) {
                 srcSelectBox.options[j].text=srcSelectBox.options[j+1].text;
                 srcSelectBox.options[j].value=srcSelectBox.options[j+1].value;
             }

             srcSelectBox.length--;
         }
     }
}

function toUpper(objThisCtrl)
{
    objThisCtrl.value=objThisCtrl.value.toUpperCase();
}

//........................................................................
// Save newly selected os type when new platform is added.
// This saved new os type value will be used to call MDF navigator.
// When save, save the text, not the value. ex: IOS, CatOS, etc.
//........................................................................
function saveNewOsType( listObj, textObj ) {

    var THIS_FUNC = "[PlatformSetupEdit.jsp: saveNewOsType] ";

//    alert( THIS_FUNC );

    for( i=0; i<listObj.length; i++ ) {

        if( listObj.options[i].selected ) {
            textObj.value = listObj.options[i].text;
            break;
        } // if
    } // for

     // OS changes... MDF is not valid any more.
     cleanMdf();

} // function saveNewOsType( listObj, textObj )

//........................................................................
// Clean all MDF related fields.
//........................................................................
function cleanMdf() {

    var THIS_FUNC = "[PlatformSetupEdit.jsp: cleanMdf] ";

//    alert( THIS_FUNC );

    document.forms['editPlatform'].elements['newMdfDisp'].value         = "";  //DIV
    document.forms['editPlatform'].elements['newMdfId'].value           = "";
    document.forms['editPlatform'].elements['newMdfNameHidden'].value   = "";

} // function cleanMdf()

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
function submitEditPlatform() {

    var THIS_FUNC = "[PlatformSetupEdit.jsp.submitEditPlatform] ";
    var formObj;
    var elements;



    // Make a shortcut to our form's objects.
    formObj = document.forms['editPlatform'];
    elements = formObj.elements;

<% if(((Boolean) colMask.get("Platform")).booleanValue()) { %>
    if(trim(elements['platformName'].value) == '' ) {
    	alert('Platform Name can\'t be empty');
    	return false;
    }
<% } %>

<% if(((Boolean) colMask.get("PltFamily")).booleanValue()) { %>
    if(trim(elements['platformfamilyName'].value) == '' ) {
    	alert('Platform Family Name can\'t be empty');
    	return false;
    }
<% } %>

	
  
  /* for( i=0; i<formObj.erpProductFamily.length; i++ ) {
    if( formObj.erpProductFamily.options[i].selected ) {
	    if (formObj.erpProductFamily.options[i].text == 'Select One') {
		  alert( "Please select a valid ERP Product Family."); 
		  return false;
	    } // if
    }
  } // for
 */
  
<%  if( ((Boolean) colMask.get("PCodeGroup")).booleanValue() ) { %>
    if(trim(elements['oldpcodeGroupName'].value) != "null"){
    if(trim(elements['pcodeGroupName'].value) == '' || trim(elements['pcodeGroupName'].value) == "NULL") {
    	alert('Pcode group Name can\'t be empty or have NULL value');
    	return false;
    }}
<% } %>  

<% if (((Boolean) colMask.get("MDF")).booleanValue()) { %>
if(trim(elements['mdfdivid'].value) == null || trim(elements['mdfdivid'].value) == ''){
    	alert('MDF can\'t be empty');
    	return false;
    }
<% } %>

<%-- <%  //CSCsi68703 - Limiting CCO DIR field value to 20 bytes.
	if( ((Boolean) colMask.get("CcoDir")).booleanValue()){ %>
	var ccoDirVal = trim(elements['ccoDir'].value);
    if(ccoDirVal != '' && ccoDirVal.length > 20 ) {
    	alert('Length of "CCO Dir" cannot be greater than 20.');
    	return false;
    }else{
    	var reg = /^[.:\w_-]+$/;
		if(!reg.test(ccoDirVal) && ccoDirVal.length > 0){
			alert('"CCO Dir" cannot contain special characters or spaces.');
			return false;
		}else{
			if(ccoDirVal.length <=2 
				&&  (ccoDirVal == '.' || ccoDirVal == '..')){
				alert('"CCO Dir" value cannot be . or ..');
				return false;				
			}
			
			if(ccoDirVal.length == 0) {
				alert('"CCO Dir" value can\'t be empty');
				return false;
			}
		}
    }
<% } %> --%>

    // See if we've already submitted this form.  If so then halt!
    if( elements['_submitformflag'].value==0 )
    {
        // Flag it.  Change the image too.
        elements['_submitformflag'].value=1;
        
        setImg('btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
        setImg('btnSaveUpdates2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");

        var length = elements.length;
        var listOfSoftwareTypes = '';
        var control = elements['selected_softwaretypes'];

		if( control != 'undefined' && control != null ) {
	        for( var i = 0; i < control.length; i++ ) {
	           listOfSoftwareTypes += control.options[i].value;
	           if( i != (control.length - 1 ) )
	               listOfSoftwareTypes += '|';
	        }
	
	        var hiddenVar = document.getElementsByName('softwaretypes')[0];
	        hiddenVar.value = listOfSoftwareTypes;
		}
		
        setImg( 'btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
        document.forms['editPlatform'].submit();
     }  // if( elements['_submitformflag'].value==0 )

} // function submitEditPlatform()

function resetForm() {
    var formObj = document.forms['editPlatform'];
    var elements = formObj.elements;

	formObj.reset();
	var result = "";
	
	if( elements['oldmdftxt'] != null ) {
		var oldMdfTxt = elements['oldmdftxt'].value;
		if( oldMdfTxt != "" ) {
			var arr = oldMdfTxt.split("$");
			for(i=0; i< arr.length; i++) {
				result += "<img src=\"../gfx/dot_black.gif\">&nbsp;" + arr[i] + "<br/>";
			}
		}
		var divObj = document.getElementById("mdfdivtxt");
		divObj.innerHTML = result;
		elements['mdfdivid'].value = elements['oldmdfids'].value;
		elements['mdftxthidden'].value = elements['oldmdftxt'].value;
	}
	

	
	var origavailablelist = document.getElementById('available_softwaretypes');
	if( origavailablelist != null ) {
	    for(i = origavailablelist.length-1; i>=0; i--) {
			origavailablelist.options[i] = null;
	    }
	
		var origselectedlist = document.getElementById('selected_softwaretypes');
	    for(i = origselectedlist.length-1; i>=0; i--) {
			origselectedlist.options[i] = null;
	    }
	
		var list = elements['origavailablests'].value;
		if(list != "") {
			var arr = list.split("$");
			for(i=0; i< arr.length; i = i + 2) {
	             var opt = new Option(arr[i+1], arr[i]);
	             origavailablelist.options[origavailablelist.options.length] = opt;
			}
		}
		
		list = elements['origselectedsts'].value;
		if(list != "") {
			var arr = list.split("$");
			for(i=0; i< arr.length; i = i + 2) {
	             var opt = new Option(arr[i+1], arr[i]);
	             origselectedlist.options[origselectedlist.options.length] = opt;
			}
		}
	}
}
//-->
</script>

<form name="editPlatform" action="RequestProcessor" method="post" >
<input type="hidden" name="platformid" value="<%=nPlatformId%>">
<input type="hidden" name="platformfamilyid" value="<%=mPlatformInfo.getPlatformFamilyId()%>">
<input type="hidden" name="pcodegroupid" value="<%=mPlatformInfo.getPCodeGroupId()%>">
<input type="hidden" name="callingForm" value="editPlatform">
<input type="hidden" name="_submitformflag" value="0">
<input type="hidden" name="softwaretypes" value="">

<center>
<%= htmlButtonSubmit1 %>&nbsp;&nbsp;&nbsp;
<img src="../gfx/btn_reset_image.gif" alt="reset" border="0" name="btnReset1" onclick="javascript:resetForm()"><br/><br/>

<table border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td align="left" valign="top">
      <span class="dataTableTitle">* required fields. </span>
    </td>
  </tr>
  
  <tr>
   <td> &nbsp;
   </td>
  </tr>
<tr>
    <td bgcolor="#BBD1ED">
                  <table border="0" cellpadding="3" cellspacing="1">
<% if(((Boolean) colMask.get("Platform")).booleanValue()) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">Platform Name *</span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                                        <input type="text" name="platformName" size="12" value="<%=mPlatformInfo.getPlatformName()%>"
                                                OnKeyUp='toUpper(this);' OnChange='toUpper(this);' onBlur='toUpper(this);' >
                                                                <input type="hidden" name="oldplatformName" value="<%=mPlatformInfo.getPlatformName()%>">
                                </span>
                        </td>
                     </tr>
<% } 

 if(((Boolean) colMask.get("PltFamily")).booleanValue()) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">Platform Family *</span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<input type="text" name="platformfamilyName" size="12" value="<%=mPlatformInfo.getPlatformFamilyName()%>" 
                           			OnKeyUp='toUpper(this);' OnChange='toUpper(this);' onBlur='toUpper(this);' >
								<input type="hidden" name="oldplatformfamilyName" value="<%=mPlatformInfo.getPlatformFamilyName()%>">
                           	</span>
                        </td>
                     </tr>
<% } 

   if( ((Boolean) colMask.get("OsType")).booleanValue() ) { %>
    
                     <tr>
                        <td align="left" valign="top"  bgcolor="#d9d9d9">
                           <span class="dataTableTitle">OS Type *</span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                                <%if(listOfNonOs != null && !(listOfNonOs.isEmpty())) {%>
                           		<select name="ostype">
                           		<% for(int i=0; i < listOfNonOs.size(); i++) { 
                           		      if( mPlatformInfo.getOsType() != null && mPlatformInfo.getOsType().equals(listOfNonOs.get(i))) {
                           		    	if (listOfNonOs.get(i).equals("NX-OS System Software")){
                           		%>
                           		     <option value="<%=listOfNonOs.get(i)%>" selected>NX-OS</option>
                           		<%}else{ %>
                           		     <option value="<%=listOfNonOs.get(i)%>" selected><%=listOfNonOs.get(i)%></option>
                           		<%}}else {if(listOfNonOs.get(i).equals("NX-OS System Software")){ %>
                           		     <option value="<%=listOfNonOs.get(i)%>">NX-OS</option>
                           		<%}else{%>
                           		<option value="<%=listOfNonOs.get(i)%>"><%=listOfNonOs.get(i)%></option>
                           		<% }
                           		  }}
                           		%>
                           		</select>
                           		<%}else{%>
                           		<select name="ostype">                         		
                           		     <option value="" selected>List Is Empty</option>
                           		</select>
                           		<%}%>
								<input type="hidden" name="oldostype" value="<%=mPlatformInfo.getOsType()%>">
                           	</span>
                        </td>
                     </tr>
<% }  if (((Boolean) colMask.get("MDF")).booleanValue()) { %>
<tr>
<td align="left" valign="top"  bgcolor="#d9d9d9">
   <span class="dataTableTitle">MDF Concepts *</span>
</td>
<td align="left" valign="top" bgcolor="#ffffff">
   <span class="dataTableTitle">
       <div id="mdfdivtxt">
       <% 
          StringBuffer buffer = new StringBuffer();
          handler.addListAsString( buffer, mPlatformInfo.getMdf());
          String strMdfIds = mPlatformInfo.getMdfIdsAsString();
       %>
       <%=buffer%>
       </div>
      <a href="javascript:mdfPopupPost('editPlatform', 'mdfdivtxt', 'div', 'editPlatform', 'mdfdivid', 'mdftxthidden', '<%=mPlatformInfo.getOsType()%>')">Update MDF Based Cisco Product</a> 
      <input type="hidden" name="mdfdivid" value="<%=strMdfIds%>">
      <input type="hidden" name="oldmdfids" value="<%=strMdfIds%>">
      <input type="hidden" name="oldmdftxt" value="<%=mPlatformInfo.getMdfNamesAsString()%>">
      <input type="hidden" name="mdftxthidden" value="<%=mPlatformInfo.getMdfNamesAsString()%>">
   	</span>
</td>
</tr>
<%  } if( ((Boolean) colMask.get("PCodeGroup")).booleanValue()) { %>
	<tr>
	<td align="left" valign="top" bgcolor="#d9d9d9">
	   <span class="dataTableTitle">PCode Group </span>
	</td>
	<td align="left" valign="top" bgcolor="#ffffff">
	   <span class="dataTableTitle">
	   <%if (mPlatformInfo.getPCodeGroupName() == null || mPlatformInfo.getPCodeGroupName() == ""){ %>
	   		<input type="text" name="pcodeGroupName" size="12" value=""
	            OnKeyUp='toUpper(this);' OnChange='toUpper(this);' onBlur='toUpper(this);' >
	    <%}else{%>
	   			<input type="text" name="pcodeGroupName" size="12" value="<%=mPlatformInfo.getPCodeGroupName()%>"
	   			OnKeyUp='toUpper(this);' OnChange='toUpper(this);' onBlur='toUpper(this);' >
	   	<%} %>
			<input type="hidden" name="oldpcodeGroupName" value="<%=mPlatformInfo.getPCodeGroupName()%>">
	   	</span>
	</td>
	</tr>
 <% } if (((Boolean) colMask.get("SoftwareType")).booleanValue()) {%>  
                  <tr>
                       <td align="left" valign="top"  bgcolor="#d9d9d9">
                          <span class="dataTableTitle">Software Type</span>
                       </td>
                       <td align="left" valign="top" bgcolor="#ffffff">
                          <span class="dataTableTitle">
                              <table >
                                  <tr>
                                      <td>
                                   <select name="available_softwaretypes" multiple size=10 style="font-family:Verdana;">
                                       <%
                                                   Vector list = mPlatformInfo.getAvailableNonIosSoftwareTypes();
                                                   if(list != null){
                                                   Enumeration enu = list.elements();
                                                   while( enu.hasMoreElements() ) {
                                                       Pair pair = ( Pair ) enu.nextElement();
                                       %>
                                                 <option value="<%=pair.getFirst()%>" disabled>
                                                       <%=pair.getSecond()%>
                                                 </option>
                                       <%
                                                   }}else{
                                       %>
                                       <option value="" disabled >List is Empty</option>
                                       <%} %>
                                   </select>
                                       </td>
                                    <td><span class="dataTableData">
                                    <input type="hidden" name="origavailablests" value="<%=mPlatformInfo.getSoftwareTypesAsString(mPlatformInfo.getAvailableSoftwareTypes())%>">
                                    <input type="button" name="Add"	value="   Add >>   " disabled
                                        onclick="add( 'available_softwaretypes',
                                            'selected_softwaretypes')">
                                       <br/>
                                    <input type="hidden" name="origselectedsts" value="<%=mPlatformInfo.getSoftwareTypesAsString(mPlatformInfo.getSelectedSoftwareTypes())%>">
                                    <input type="button" name="Remove" value="<< Delete " disabled
                                        onclick="add('selected_softwaretypes',
                                            'available_softwaretypes' )">
                                        </span>
                                    </td>
                                      <td>
                              <select name="selected_softwaretypes" multiple size=10 style="font-family:Verdana;">
                                       <%
                                                   list = mPlatformInfo.getSelectedSoftwareTypes();
                                                   if(list != null){
                                                   Enumeration enu = list.elements();
                                                   while( enu.hasMoreElements() ) {
                                                       Pair pair = ( Pair ) enu.nextElement();
                                       %>
                                                 <option value="<%=pair.getFirst()%>" disabled >
                                                       <%=pair.getSecond()%>
                                                 </option>
                                       <%
                                                   }}else{
                                       %>
                                                <option value="" disabled>List Is Empty
                                                 </option>
                                       <% } %>
                               </select>
                                          <input type="hidden" name="origsoftwaretypes" value="<%=mPlatformInfo.getSoftwareTypesAsString()%>">
                                          
                                      </td>
                                  </tr>
                              </table>

                          </span>
                       </td>
                    </tr>  
<% }
    if ( ((Boolean) colMask.get("ERPPlt")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top"  bgcolor="#d9d9d9">
                           <span class="dataTableTitle">ERP Product Family </span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<select name="erpProductFamily">
                           		<% 
                           		 if( mPlatformInfo.getPlatformProductFamily() == null ) {
                           		 %>
                           		 	<option selected>Select One</option>
                           		 <%
                           		 } else {
                           		 %>
                           		    <option>Select One</option>
                           		 <% }
                           		 for(int i=0; i < listOfERP.size(); i++) { 
                           		      if( mPlatformInfo.getPlatformProductFamily() != null && 
                           		      		mPlatformInfo.getPlatformProductFamily().equals(listOfERP.get(i))) {
                           		%>
                           		     <option selected><%=listOfERP.get(i)%></option>
                           		<%    } else { %>
                           		     <option><%=listOfERP.get(i)%></option>
                           		<%    }
                           		  }
                           		%>
                           		</select>
								<input type="hidden" name="olderpProductFamily" value="<%=mPlatformInfo.getPlatformProductFamily()%>">
                           	</span>
                        </td>
                     </tr>
<% }

   if( ((Boolean) colMask.get("CcoDir")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top"  bgcolor="#d9d9d9">
                           <span class="dataTableTitle">CCO Dir </span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           <%
                           	String ccoDirVal = mPlatformInfo.getCcoDir() != null ? mPlatformInfo.getCcoDir() : "" ;
                           %>
                           		<input type="text" maxLength="20" name="ccoDir" value="<%=ccoDirVal%>">
                           		<input type="hidden" name="oldccoDir" value="<%=ccoDirVal%>">
                           	</span>
                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("PlatformManagers")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top"  bgcolor="#d9d9d9">
                           <span class="dataTableTitle">Platform Managers</span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<textarea name="platformmanagers" rows=3 cols=50><%=mPlatformInfo.getPlatformManagersAsString()%></textarea>
                           		<input type="hidden" name="oldplatformmanagers" value="<%=mPlatformInfo.getPlatformManagersAsString()%>">
                           	</span>
                        userid's must be seperated by comma(',').                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("PlatformPdtContacts")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top"  bgcolor="#d9d9d9">
                           <span class="dataTableTitle">Platform PDT Contacts</span>
                        </td>
                        <td align="left" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<textarea name="platformpdtcontacts" rows=3 cols=50><%=mPlatformInfo.getPlatformPdtContactsAsString()%></textarea>
                           		<input type="hidden" name="oldplatformpdtcontacts" value="<%=mPlatformInfo.getPlatformPdtContactsAsString()%>">
                           	</span>
                        userid's must be seperated by comma(',').                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("EndOfSale")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">End of Sales</span>
                        </td>
                        <td align="center" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<input type="checkbox" name="endOfSales" <%=((mPlatformInfo.isEndOfSale()) ? "CHECKED" : "")%>>
                           		<input type="hidden" name="oldendOfSales" value="<%=mPlatformInfo.getEndOfSale()%>">
                           	</span>
                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("EndOfLife")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">End of Life</span>
                        </td>
                        <td align="center" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<input type="checkbox" name="endOfLife" <%=((mPlatformInfo.isEndOfLife()) ? "CHECKED" : "")%>>
                           		<input type="hidden" name="oldendOfLife" value="<%=mPlatformInfo.getEndOfLife()%>">
                           	</span>
                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("EndOfSpare")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">End of Spare</span>
                        </td>
                        <td align="center" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<input type="checkbox" name="endOfSpare" <%=((mPlatformInfo.isEndOfSpare()) ? "CHECKED" : "")%>>
                           		<input type="hidden" name="oldendOfSpare" value="<%=mPlatformInfo.getEndOfSpare()%>">
                           	</span>
                        </td>
                     </tr>
<% } 
   if( ((Boolean) colMask.get("IsBootImageRequired")).booleanValue() ) { %>
                     <tr>
                        <td align="left" valign="top" bgcolor="#d9d9d9">
                           <span class="dataTableTitle">Boot Image Required</span>
                        </td>
                        <td align="center" valign="top" bgcolor="#ffffff">
                           <span class="dataTableTitle">
                           		<input type="checkbox" name="bootImageRequired" <%=((mPlatformInfo.isBootImageRequired()) ? "CHECKED" : "")%>>
                           		<input type="hidden" name="oldbootImageRequired" value="<%=mPlatformInfo.getIsBootImageRequired()%>">
                           	</span>
                        </td>
                     </tr>
<% } %>
                  </table>
        </td>
     </tr>
</table>
<br />
<%= htmlButtonSubmit2 %><br/><br/>
</center>
</form>

<ul>
    <li> <a href="NonIosPlatformSetupEdit.jsp">Platform Mapping View</a> </li>
</ul>
<%= Footer.pageFooter(globals) %>
