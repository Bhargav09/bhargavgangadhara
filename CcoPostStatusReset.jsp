<!--.........................................................................
: DESCRIPTION:
:  Software Search Page for Reset function
:
: AUTHORS:
: @author Sakthivel Annakamu[sannakam@cisco.com]
:
: Copyright (c) 2003-2008 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.*" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.rmi.PortableRemoteObject" %>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.*" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper,
                   com.cisco.eit.sprit.controller.NonIosCcoRequestContext" %>

<%@ page import="java.sql.*" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.OSTypeInfo" %>
<%@ page import="com.cisco.eit.sprit.ui.*" %>
<%@ page import="com.cisco.eit.sprit.util.*" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritUtility" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="Reset Admin Function">
<spritui:header/>


<%
// Initialize globals
  String htmlButtonGo;
  Integer osTypeId=null;

  SpritGlobalInfo globals = SpritInitializeGlobals.init(request,response);
  SpritAccessManager spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );
  String pathGfx = globals.gs( "pathGfx" );
  NonIosCcoPostHelper nonIosCcoPostHelper = new NonIosCcoPostHelper();

  String strMode =null;
  // String releaseName =null;
  String imageName = null;
  NonIosCcoRequestContext nonIosCcoRequestContext =null;
  boolean isSoftwareTypePM = false;
  String osType = null;

  String action = request.getParameter(NonIosCcoPostHelper.ACTION);
  
  // String form of osTypeId and MdfConceptId
  String osTypeIdMdfConceptId = request.getParameter(NonIosCcoPostHelper.OS_TYPE_ID);
  
  // Check os is Non IOS or not
  if(osTypeIdMdfConceptId!=null) {
	  	if(osTypeIdMdfConceptId.length()>1)
	       	osTypeId = Integer.valueOf(osTypeIdMdfConceptId.substring(0, osTypeIdMdfConceptId.indexOf(':')));
  }
  if(osTypeId!=null&&!osTypeId.equals("")&&!osTypeId.equals("1")&&!osTypeId.equals("2")&&!osTypeId.equals("41")){

	  strMode = request.getParameter(NonIosCcoPostHelper.MODE);
	  // releaseName = request.getParameter(NonIosCcoPostHelper.RELEASE_NAME);
	  imageName = request.getParameter(NonIosCcoPostHelper.IMAGE_NAME);
	  nonIosCcoRequestContext = (NonIosCcoRequestContext)session.getAttribute("nonIosCcoRequestContext");	  
	  osType = nonIosCcoPostHelper.getOSType(osTypeId);
  }
  if (nonIosCcoRequestContext == null) {
		  nonIosCcoRequestContext = new NonIosCcoRequestContext(request);
	  }
  String errorMessage = (String)session.getAttribute("errorMessage");
  
  // HTML macros
  htmlButtonGo = ""+ SpritGUI.renderButtonRollover(globals,"btnGo","Go","javascript:submitSoftwareSelector()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_GO,"actionBtnGo('btnGo')","actionBtnGoOver('btnGo')");  
%>
 

<!-- Master holding table -->
<table border="0" cellpadding="0" cellspacing="0">
<tr>
 
  
  <!-- Spacer -->
  <td><img src="<%= pathGfx %>/<%= SpritConstants.GFX_BLANK %>" width="16" /></td>
  
   <td valign="top" align="left">
    Welcome to the CCO Post Transaction Status Reset Page. Begin by searching for your release.
    <br /><br />

<form name="softwareSelector" method="post" action="SoftwareSearchProcessor" onSubmit="return submitSoftwareSelector();">  
    
<!--form action="SoftwareSearchProcessor" method="post" name="softwareSelector"-->
<!--spritui:table -->
<table border="0" cellpadding="2" cellspacing="0" ><tbody><tr><td>
<table border="0" cellpadding="2" cellspacing="0"><tbody><tr><td bgcolor="#bbd1ed" >
<input name="from" value="reset" type="hidden"> <!-- Don't understand the need of it -->
<input name="seletedOsName" value="" type="hidden"> <!-- Don't understand the need of it -->
  <table border="0" cellpadding="0" cellspacing="0">
  <tbody><tr><td bgcolor="#ffffff">
    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr>
      <td bgcolor="#bbd1ed"><img src="<%=pathGfx%>/b1x1.gif" width="8"></td> <!-- #bbd1ed->Color of the outer box ( light blue ) -->
      <td bgcolor="#bbd1ed" class="infoboxTitle">
        Select Software Type
      </td>
      <td background="<%=pathGfx%>/wedge_lightblue.gif"><img src="<%=pathGfx%>/b1x1.gif" height="1" width="24"></td>
    </tr>
    </tbody></table>


    <table border="0" cellpadding="8" cellspacing="0">
    <tbody><tr><td align="left" class="infoboxData">

Use this form to select a Software type and enter the release to work on.
Click the <b>Go</b> button to begin the search.</br> </br>


<table border="0" cellpadding="0" cellspacing="0">
<tbody>

<!-- Select Software Type -->
<tr>
<td>
<table>
<tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Software Type *:</b></td>
  <td align="left" valign="top" ><b>&nbsp;</b></td> <!-- &nbsp -> Non Breaking Space -->
  <td align="left" valign="top">
<a href="javascript:resetSWAction()" onmouseover="setImg('resetSoftwareType','../gfx/btn_resetfield_over.gif');" onmouseout="setImg('resetSoftwareType','../gfx/btn_resetfield.gif');"><img src="<%=pathGfx%>/btn_resetfield.gif" alt="Reset Software Type drop down to the right" name="resetSoftwareType" border="0"></a><a href="javascript:nonIOSSoftwareHelp()" ></a></td>
  <td align="left" valign="top">&nbsp;</td>  	
  <td align="left" valign="top">
<%   	
		String mdfProjectFlag = "";
        SpritInitializeGlobals globalsInfo = SpritInitializeGlobals.getInstance();
		mdfProjectFlag = globalsInfo.getProperty(SpritConstants.MDF_PROJECT_FLAG);
		StringBuffer  osTypeSelect = new StringBuffer();

		MonitorUtil.cesMonitorCall("SPRIT-6.4-CSCsd68488-Software Type Tree", request);
		//String osTypeID=request.getParameter("osTypeId");
		osType = nonIosCcoPostHelper.getOSType(osTypeId);
		// System.out.println("OS TypeId : "+osTypeID+" OS Type : "+osType);
		if(osTypeIdMdfConceptId!=null && !osTypeIdMdfConceptId.equals("")) {
			String selectedOsName=request.getParameter("seletedOsName");
			osTypeSelect.append(SpritUtility.getAllSoftwareTypeSelectWidget("osType",true,selectedOsName));             
		} else {
			osTypeSelect.append(SpritUtility.getAllSoftwareTypeSelectWidget("osType",true,""));             
		}
		// System.out.println(osTypeSelect.toString());
%>

<%= osTypeSelect.toString() %>

  </td>
  </tr>
  </table>
  </td>
</tr>


<!-- Exact Release Number -->
<tr>
<td><table><tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Exact Release Number:</b></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  <% if(request.getParameter("swreleaseNumberExact")==null) {   %> <!-- Checking for the presence of swreleaseNumberExact parameter value -->
  <td align="left" valign="top"><input name="swreleaseNumberExact" value="" size="20" type="text"></td>
  <%}else { %>
    <td align="left" valign="top"><input name="swreleaseNumberExact" value="<%= request.getParameter("swreleaseNumberExact") %>" size="20" type="text"></td>
  <% } %>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top">
  <%= htmlButtonGo %>
	</td>
</tr>
</table>
</td>
</tr>

</tbody>
</table>

</td>
</tr>
    </tbody>
    </table>
  </td>
  </tr>
  </tbody>
  </table>
</td>
</tr>
</tbody>
</table>
<br/>

<!-- Newly added -->

<!-- What is the use of result? How are we updating any records? -->

<%
  if(request.getParameter("result") != null && request.getParameter("result").equals("success")) {
%>
<center>
  <table border="0" cellpadding="0" cellspacing="0" width="60%">
    <tr>     
      <td> Records are successfully updated </td>
    </tr>
  </table>
</center>
<%
  }
%>


<%
  if(errorMessage != null && !errorMessage.equals("")) {
%>
<center>
  <table border="0" cellpadding="0" cellspacing="0" width="60%">
    <tr>
      <td width="20%" valign=\"top\"><font face="Arial,Helvetica" color="#FF0000"><b><blink>WARNING!!!</blink>:</b></font></td>
      <td>
        <table border="1" bordercolor="#FF0000" cellpadding="0" cellspacing="0" width="100%">
<%=errorMessage%>
        
        </table>
      </td>
    </tr>
  </table>
</center>
<%
  }
%>


<!-- The place where I think the new table is getting displayed -->
  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.ACTION %>" value="" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.MODE %>" value="<%= strMode %>" />
  <% if(osTypeIdMdfConceptId!=null&&!osTypeIdMdfConceptId.equals("")){ 
  		String resetAdminGuiStr = SpritUtility.getResetAdminGui( request, globals, "", "view",  // getResetAdminGui is the UI componenet for resetting the flag
  				osTypeId, osType, request.getParameter("swreleaseNumberExact"), imageName, nonIosCcoRequestContext );
  		if(!SpritUtility.No_Image_CcoPostStatusReset)
  		{
  %>			
  <%= SpritUtility.getSaveUpdatesButton(globals,"btnSaveUpdates1",pathGfx) %>
  
  <%	}%>	
		<%=resetAdminGuiStr%>
		<% if(!SpritUtility.No_Image_CcoPostStatusReset){%>
		<%= SpritUtility.getSaveUpdatesButton(globals,"btnSaveUpdates2",pathGfx) %>
 <% }} %>
   
<!-- Newly Added End -->
  
</form>

</td>   
</tr>
</tr>
</table>

</span></td></tr>
    </tbody></table>
  </td></tr>
  </tbody></table>
</td></tr>
</tbody></table>

<script language="javascript"><!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================

  // ........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  // ........................................................................
  function actionBtnGo(elemName) {
       setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO%>" );
      }
  function actionBtnGoOver(elemName) {
     setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO_OVER%>" );
      }
  
  // ........................................................................
  // DESCRIPTION:
  // Submit the form.
  // ........................................................................
  
  function submitSoftwareSelector() {  
    var formObj;
    var elements; 
    var submit = true ;
    
    formObj = document.forms['softwareSelector']; // object for refering to the form
    elements = formObj.elements;

	var index=formObj.osType.selectedIndex;	// gives the selected index
    var seletedOsName=formObj.osType.options[index].text; // gives the text present on the specified index because of optios[index].text


	// var x=document.getElementById("osType");

    
    if (formObj.osType.value== '' ) 
    {
      submit = false;
      alert("Choose a Software Type to Begin Search ");
      return false;
    }
    
	if ((formObj.osType.value== '1'||formObj.osType.value== '41'||formObj.osType.value== '2')&&formObj.swreleaseNumberExact.value=='' ) 
	{
      submit = false;
      alert("For IOS,ION and IOX Type please enter exact Release Number ");
      return false;
    } 
		
    
    if(submit) {
		formObj.seletedOsName.value=seletedOsName;
		document.forms['softwareSelector'].submit(); 
    }
  }  
  
 function resetReleaseNumberExactSWAction()
 {
	  document.forms['softwareSelector'].elements['swreleaseNumberExact'].value='';
 } 
 
 function resetSWAction()
 {
	 document.forms['softwareSelector'].elements['osType'].value='';
 } 

  function selectAllType() {
	
	var formObj = document.forms['softwareSelector'];
    var elements = formObj.elements;
	var selectedValue=formObj.TypeSelectAll.value;

	for (i=0; i<formObj.totalSize.value; i++) {
		var type="_Type"+i;
	    var TypeSelect = formObj.elements[type];
        if(formObj.TypeSelectAll.value=='All Post'){
			formObj.elements[type].value='Post';
	   } else if(selectedValue=='All RePost'){
		   TypeSelect.value='Repost';
	   } else if(selectedValue=='All Delete'){
		   TypeSelect.value='Delete';
	   } else if(selectedValue=='All New'){
		   TypeSelect.value='New';
	   } else if(selectedValue== 'All Type None'){		   
		   var prevType="_PrevType"+i;
		   TypeSelect.value=formObj.elements[prevType].value;
	   }	   
	}
}

  function ValidateAndSubmit(formName) {
	  
	  var formObj= document.forms['softwareSelector'];
	  var elements= formObj.elements; 
      
	  var isChanged=false;
	
	for (i=0; i<formObj.totalSize.value; i++) {
		var prevStatus="_PrevStatus"+i;
		var currentStatus="_Status"+i;
		
		var prevType="_PrevType"+i;
		var currentType= "_Type"+i;

		var currentStatusValue=formObj.elements[currentStatus].value;
		var prevStatusValue=formObj.elements[prevStatus].value;

		// alert("current : "+currentStatusValue);
		// alert("previous : "+prevStatusValue);

		var currentTypeValue=formObj.elements[currentType].value;
		var prevTypeValue=formObj.elements[prevType].value;

		if(currentStatusValue!=prevStatusValue){
			isChanged=true;
			// break;
		}
		if(currentTypeValue!=prevTypeValue){
			isChanged=true;
			// break;
		}
	}
	
	if(isChanged) {
		var index=formObj.osType.selectedIndex;	
		var seletedOsName=formObj.osType.options[index].text;
		formObj.seletedOsName.value=seletedOsName;
		formObj.elements['from'].value='resetupdate';
		document.forms['softwareSelector'].submit(); 
	}
	else {
		alert("Could not proceed.No Value of Status and Type has changed. ");
	    return;
	}
	
  }

function selectAllStatus() {
	var formObj= document.forms['softwareSelector'];
    var elements= formObj.elements; 
    var selectedValue=formObj.StatusSelectAll.value;
		
	for (i=0; i<formObj.totalSize.value; i++) {
		var type="_Status"+i;
		var TypeSelect = formObj.elements[type];
	    if(selectedValue=='All Success'){
			TypeSelect.value='Success';
	   } else if(selectedValue=='All Fail'){
		   TypeSelect.value='Fail';
	   } else if(selectedValue=='All InProgress'){
		   TypeSelect.value='Inprogress';
	   } else if(selectedValue== 'All Status None'){
		   var prevStatus="_PrevStatus"+i;
		   TypeSelect.value=formObj.elements[prevStatus].value;
	   }	   
	}	
}
// --></script>

 
   
  </td>
</tr>
</tbody></table>
</table>

     
<spritui:footer/>

</spritui:page>
<!-- end -->
