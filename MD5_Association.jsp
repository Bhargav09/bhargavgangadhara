<!--.........................................................................
: DESCRIPTION:
:  Software Search Page for MD5 Association
:
: AUTHORS:
: @
:
: Copyright (c) 2003-2008 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->


<%--@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"--%>
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

<spritui:page title="MDF Association Admin Function">
<spritui:header/>

<%
// Initialize globals
  String htmlButtonGo;
  Integer osTypeId=null;

  SpritGlobalInfo globals = SpritInitializeGlobals.init(request,response); // initializes the common global variables
  SpritAccessManager spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER ); // returns object of the given string and ACCESS_MANAGER = "accessManager"
  String pathGfx = globals.gs( "pathGfx" ); // returns the value for key = "pathGfx"
  NonIosCcoPostHelper nonIosCcoPostHelper = new NonIosCcoPostHelper(); 

  String strMode =null;
  // String releaseName =null;
  String imageName = null;
  NonIosCcoRequestContext nonIosCcoRequestContext =null;
  boolean isSoftwareTypePM = false;
  String osType = null;

  String action = request.getParameter(NonIosCcoPostHelper.ACTION); //NonIosCcoPostHelper.ACTION = "action", getting parameter action from the form  
  // String form of osTypeId and MdfConceptId
  String osTypeIdMdfConceptId = request.getParameter(NonIosCcoPostHelper.OS_TYPE_ID); // OS_TYPE_ID = "osTypeId", getting parameter ostypeId from the form
  
  // Check os is Non IOS or not
  if(osTypeIdMdfConceptId!=null) 
  {
	  	if(osTypeIdMdfConceptId.length()>1)
	       	osTypeId = Integer.valueOf(osTypeIdMdfConceptId.substring(0, osTypeIdMdfConceptId.indexOf(':'))); // integer parsing and extracting the required part for osTypeId
  }
  
  if(osTypeId!=null&&!osTypeId.equals("")&&!osTypeId.equals("1")&&!osTypeId.equals("2")&&!osTypeId.equals("41"))
  {
	  strMode = request.getParameter(NonIosCcoPostHelper.MODE); // MODE = "mode", get the mode of sending data
	  // releaseName = request.getParameter(NonIosCcoPostHelper.RELEASE_NAME);
	  imageName = request.getParameter(NonIosCcoPostHelper.IMAGE_NAME); // IMAGE_NAME = "imageName", get the Image Name parameter from the form 
	  nonIosCcoRequestContext = (NonIosCcoRequestContext)session.getAttribute("nonIosCcoRequestContext");	  // session is some inherent variable
	  osType = nonIosCcoPostHelper.getOSType(osTypeId); // getting osType(String) from osTypeId(Integer)
  }
  if (nonIosCcoRequestContext == null) {
		  nonIosCcoRequestContext = new NonIosCcoRequestContext(request); // Initialising NonIosCcoRequestContext ( get, set one)
	  }
  String errorMessage = (String)session.getAttribute("errorMessage"); // session is some inherent variable
  
  // HTML macros
  htmlButtonGo = ""+ SpritGUI.renderButtonRollover(globals,"btnGo","Go","javascript:submitSoftwareSelector()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_GO,"actionBtnGo('btnGo')","actionBtnGoOver('btnGo')");  // This method os inside sprit/com/cisco/eitsprit/ui/SpritGUI.Java(7 params)

//javascript:submitSoftwareSelector() lets the work to be done in the same page
%>

<!-- Master holding table -->
<table border="0" cellpadding="0" cellspacing="0">
<tr>
 
  
  <!-- Spacer -->
  <td><img src="<%= pathGfx %>/<%= SpritConstants.GFX_BLANK %>" width="16" /></td>
 
<td valign="top" align="left">
<b>
    Welcome to the MD5 Association Page. Begin by searching for your release.
    </b>
    
    <br /><br />

<form name="softwareSelector" method="post" action="SoftwareSearchProcessor" onSubmit="return submitSoftwareSelector();">  <!-- SoftwareSearchProcessor is the Servlet -->
    
<!--form action="SoftwareSearchProcessor" method="post" name="softwareSelector"-->
<!--spritui:table -->
<table border="0" cellpadding="2" cellspacing="0" ><tbody><tr><td>
<table border="0" cellpadding="2" cellspacing="0"><tbody><tr><td bgcolor="#bbd1ed" >
<input name="from" value="md5_Synch" type="hidden">   <!--  The value parameter of the hidden input type is md5_synch-->
<input name="seletedOsName" value="" type="hidden">
  <table border="0" cellpadding="0" cellspacing="0">
  <tbody><tr><td bgcolor="#ffffff">
    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr>
      <td bgcolor="#bbd1ed"><img src="<%=pathGfx%>/b1x1.gif" width="8"></td>
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


<!-- Software Type Row -->
<tr>
<td>
<table>
<tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Software Type *:</b></td>
  <td align="left" valign="top" ><b>&nbsp;</b></td> <!-- &nbsp -> Non Breaking Space -->
  <td align="left" valign="top">
  <a href="javascript:resetSWAction()" onmouseover="setImg('resetSoftwareType','../gfx/btn_resetfield_over.gif');" onmouseout="setImg('resetSoftwareType','../gfx/btn_resetfield.gif');"><img src="<%=pathGfx%>/btn_resetfield.gif" alt="Reset Software Type drop down to the right" name="resetSoftwareType" border="0"></a><a href="javascript:nonIOSSoftwareHelp()" ></a></td>
  <!-- Above line is for reset image that is used for resetting the software type -->
  
  
  <td align="left" valign="top">&nbsp;</td>  	
  <td align="left" valign="top">
  


<!--  Widget to show the drop down menu for choosing Software Type -->
  
<% 
		String mdfProjectFlag = "";
        SpritInitializeGlobals globalsInfo = SpritInitializeGlobals.getInstance(); // Just making a new Object of Class SpritInitializeGlobals.
		mdfProjectFlag = globalsInfo.getProperty(SpritConstants.MDF_PROJECT_FLAG); //MDF_PROJECT_FLAG = "MDFProject"
		
		
		StringBuffer  osTypeSelect = new StringBuffer(); // Creating a new StringBuffer

		MonitorUtil.cesMonitorCall("SPRIT-6.4-CSCsd68488-Software Type Tree", request);
		//String osTypeID=request.getParameter("osTypeId");
		osType = nonIosCcoPostHelper.getOSType(osTypeId); // getting osType(String) from osTypeId(Integer)
		// System.out.println("OS TypeId : "+osTypeID+" OS Type : "+osType);
		if(osTypeIdMdfConceptId!=null && !osTypeIdMdfConceptId.equals("")) 
		{
			String selectedOsName  =   request.getParameter("seletedOsName"); // getting selected OS Name
			osTypeSelect.append(SpritUtility.getAllSoftwareTypeSelectWidget("osType",true,selectedOsName));   //getAllSoftwareTypeSelectWidget gives the dropdown for entire SWT view          
		}
		
		else 
		{
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


<!-- Exact Release Number Row -->
<tr>
<td>

<table>

<tr>

  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Exact Release Number:</b></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  
  
   
  
  <!-- Widget to show Release-Name Dropdown -->
  
 <%-- String softwareTypeId = request.getParameter("osType"); --%>
 
     <% StringBuffer releaseNameSelect = new StringBuffer(); %>
       
       <%--      if(softwareTypeId != null) --%>
       
       <% 
            {
            	//out.println("Software Type Dropdown value = "+softwareTypeId);            	            	
            	
            	String swReleaseName = request.getParameter("swreleaseNumberExact"); 
            	
            	%>
            	<td align="left" valign="top">
            	<% 
            	if(swReleaseName == null)
            	{
            		releaseNameSelect.append(SpritUtility.getReleaseNameWidget("swreleaseNumberExact","100",true,""));
            	}
            	else
            	{
            		releaseNameSelect.append(SpritUtility.getReleaseNameWidget("swreleaseNumberExact","100",true,swReleaseName));
            	}
            	
            }
%>

 <%= releaseNameSelect.toString() %> 
  
  </td>
  
  
  
  <%-- if(request.getParameter("swreleaseNumberExact")==null) {   --%>
  
  <!--td align="left" valign="top"-->
  
  <!--input name="swreleaseNumberExact" value="" size="20" type="text"-->
  
  <!--/td-->
  
  <%--}else { --%>
    
    <!--td align="left" valign="top"-->
    
    <!--input name="swreleaseNumberExact" value="<%--= request.getParameter("swreleaseNumberExact") --%>" size="20" type="text"-->
    
    <!--/td-->
  
  <%-- } --%>
  
  
  
  
  
  <td align="left" valign="top">&nbsp;</td>
  
  
  </tr>
</table>
</td>
</tr>


<!-- Image Name Row -->
<tr>
<td>
<table>
<tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Select Image Name:</b></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  
  
  
  <!-- We have to use some widget here like in Software Type part, for now we have some dummy items in the dropdown menu -->
  
  <!-- td align="left" valign="top" -->
  <!-- select name= "image_Name" id = "select_width" -->
  <!-- option name="imageName" value="" size="20" type="text" selected = "selected" --><!--/option-->
  <!-- option name="imageName" value="Anuraj" size="20" type="text"-->  <!-- /option -->
  <!-- option name="imageName" value="Divya" size="20" type="text"-->  <!-- /option -->
  <!-- option name="imageName" value="Suma" size="20" type="text"-->  <!--/option-->
  <!-- option name="imageName" value="Akash" size="20" type="text"-->  <!-- /option -->
  <!-- /select -->
  <!-- /td-->
    
  
  <% StringBuffer imageNameSelect = new StringBuffer(); %>
       
       <%--      if(softwareTypeId != null) --%>
       
       <% 
            {
            	//out.println("Software Type Dropdown value = "+softwareTypeId);            	            	
            	
            	String imageName1 = request.getParameter("imageName"); 
            	
            	%>
            	<td align="left" valign="top">
            	<% 
            	if(imageName == null)
            	{
            		imageNameSelect.append(SpritUtility.getImageNameWidget("imageName","7966",true,""));
            	}
            	else
            	{
            		imageNameSelect.append(SpritUtility.getImageNameWidget("imageName","7966",true,imageName1));
            	}
            	
            }
%>

 <%= imageNameSelect.toString() %> 
  
  </td>
  
  
  
  
  
  
  
  
  
  
  
  
  <td align="left" valign="top">&nbsp;</td>              <!-- Blank Space for GO button -->
  <td align="left" valign="top">
  <%= htmlButtonGo %>                                    <!-- Displaying Go button -->
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




  
<!-- Displaying the new table for synching MD5, We don't need save update button as in the table itself we will have a Synch button  -->


  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.ACTION %>" value="" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.MODE %>" value="<%= strMode %>" />
  
  
  <% if(osTypeIdMdfConceptId!=null&&!osTypeIdMdfConceptId.equals(""))
  { 
  				String synchMD5AdminGuiStr =  SpritUtility.getMD5_Synch_AdminGui( request, globals, "", "view",  
  				
  						osTypeId, osType, request.getParameter("swreleaseNumberExact"), imageName, nonIosCcoRequestContext );	
  		
  				%>
  
  	
  	<br>
  	<br>
  	<br>
  	<br>
  	<br>
  	<br>
  	
  	<%= synchMD5AdminGuiStr %>  		
		
 
	<%	} %>
	



</form>

</td>   
</tr>
</tr>
</table>

</span>
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

    
  <script language="javascript"><!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================

  // ........................................................................
  // DESCRIPTION:
  // Submit the form.
  // ........................................................................
  -->
  function submitSoftwareSelector() {  
    var formObj;
    var elements; 
    var submit = true ;
    
    formObj = document.forms['softwareSelector'];
    elements = formObj.elements;

	var index=formObj.osType.selectedIndex;	
    var seletedOsName=formObj.osType.options[index].text; // getting the value of dropdown named oType


	// var x=document.getElementById("osType");

    
    if (formObj.osType.value== '' )
    {
      submit = false;
      alert("Choose a Software Type to Begin Search ");
      return false;
    }
    
    if (formObj.swreleaseNumberExact.value== '' ) 
    {
        submit = false;
        alert("Choose a Release Number to Begin Search ");
        return false;
      }
    
   
      
      if (formObj.imageName.value== '' ) 
    {
        submit = false;
        alert("Choose an Image Name to Begin Search ");
        return false;
      }
      
      
    
	if ((formObj.osType.value== '1'||formObj.osType.value== '41'||formObj.osType.value== '2')&&formObj.swreleaseNumberExact.value=='' ) 
	{
      submit = false;
      alert("For IOS,ION and IOX Type please enter exact Release Number ");
      return false;
    } 
		
    
    if(submit) 
    {
		formObj.seletedOsName.value=seletedOsName;
		document.forms['softwareSelector'].submit(); 
    }
  }  
 
  
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  // ........................................................................
  function actionBtnGo(elemName) 
  {
       setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO%>" );
  }
  
  function actionBtnGoOver(elemName) 
  {
     setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO_OVER%>" );
  }
  
  function resetReleaseNumberExactSWAction()
  {
 	  document.forms['softwareSelector'].elements['swreleaseNumberExact'].value='';
  } 
  
  function resetSWAction()
  {
 	 document.forms['softwareSelector'].elements['osType'].value=''; // Resetting The Software Type Widget
  }
  
  function resetImageNameAction()
  {
 	 document.forms['softwareSelector'].elements['imageName'].value=''; // Resetting The Software Type Widget
  }
  

  /*
function ValidateAndSubmit(formName)
{
	  
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
*/

/*
function ValidateAndSubmit(formName)
{
		
	var formObj= document.forms['softwareSelector'];
	var elements= formObj.elements;
	
	var md5_in_sprit = formObj.md5_in_sprit.value;
	var md5_in_sdsp = formObj.md5_in_sdsp.value;
	
	//for (i=0; i<formObj.totalSize.value; i++) 
	//{
	if( md5_in_sprit!= md5_in_sdsp )
		{
			formObj.elements['md5_in_sprit'].value = formObj.elements['md5_in_sdsp'].value;
			return true
		}
	//}
	return false;
}
*/



function getOSTypeName()
	{
	
	var seletedOsName=formObj.osType.options[index].text;
	
	window.location.replace("MD5_Association.jsp?osType="+seletedOsName);
	
	}
	


</script>

<style>

#select_width{
 width:400px;   
}
</style>


</spritui:page>



<!-- end -->




