<!--.........................................................................
: DESCRIPTION:
:  Software Search Page for MD5 Association
:
: AUTHORS:
: @asuman
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

<%@ page import="com.cisco.eit.sprit.gui.Footer" %>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.*" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper,
                   com.cisco.eit.sprit.controller.NonIosCcoRequestContext" %>


<%--@ page import="com.cisco.eit.sprit.controller.GetReleaseNumberServelet" --%>

<%--@ page import="com.cisco.eit.sprit.controller.GetImageNameServlet" --%>


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
    
  SpritGlobalInfo globals = SpritInitializeGlobals.init(request,response); 
    
  String pathGfx = globals.gs( "pathGfx" );     

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

<input name="selectedReleaseNumber" value="" type="hidden">
<input name="selectedImageName" value="" type="hidden"> 
  
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
		
				
		StringBuffer  osTypeSelect = new StringBuffer(); 

	    osTypeSelect.append(SpritUtility.getAllSoftwareTypeSelectWidget("osType",true,""));             
		
		

%>
  
  
  <%= osTypeSelect.toString() %> 
  
  
  </td>
  </tr>
  </table>
  </td>
</tr>



<tr>
<td>
<table>
<tr>

  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top" class="infoboxData"><b>Exact Release Number:</b></td>
  <td align="left" valign="top">&nbsp;</td> 
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  
  
   
  <!-- Release Name Dropdown -->
    
  
  <td align="left" valign="top">
  
  	<select name ="releaseNumber" id="releaseNumber"  onFocus = " sendMessageToServer('releaseNumber')"   
  				onChange = " sendMessageToServer('imageName')" style = "width:500px;margin:0px 0 5px 0;">
               		
               			</select>   
  </td>
  

  
  <td align="left" valign="top">&nbsp;</td>
  
  
  </tr>
</table>
</td>
</tr>


<!-- Image Name Dropdown -->
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
  <td align="left" valign="top" ><b>&nbsp;</b></td>
  
 
 <td align="left" valign="top">
  
  		<select name ="imageName" id="imageName"   style = "width:500px;margin:0px 0 5px 0;" onChange = " sendAllDataToServer()">               		
               			</select> 
  </td>
  
  
  <!--td align="left" valign="top"--><!--/td-->              <!-- Blank Space &nbsp; for GO button -->
  <!--td align="left" valign="top"-->
  <%--= htmlButtonGo --%>                                    <!-- Displaying Go button -->
	<!--/td-->


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


<!-- Added some extra line breaks on 27/11/2013. Added by asuman-->
<br>
<br>
<br>
<br>

<!--Added busy indicator on 05/12/2013-->
 
<div id="busy_indicator">Loading ...</div>

<br>
<br> 
<br>
<br>

<table>
	<tr  id = "attachSynchTable">

	</tr>
</table>


<!-- Table to be shown in case of any error -->

<table border="0" align="center" cellpadding="2" cellspacing"0" width="300">
<tr>
<td align="center" width="100" id = "errorSynchTable"></td>
</tr>
</table>
    
  	
  	<br>
  	<br>
  	<br>
  	<br>
  	<br>
  	<br>
  	


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

  
  <!--script type="text/javascript" src="json2.js"--><!--/script-->
  
  <script language="javascript">
  
    
  
  <!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
  -->
 
  window.onload = setupFunc;
  
  
  // method to hide busy indicator on page load 
  function setupFunc() {
	  
	  //alert("Before hideBusysign in setupFunc method");
	      
    hideBusysign();
    
    //alert("After hideBusysign in setupFunc method");
          
  }
  
  
  // method to display busy sign
  function hideBusysign() {
	  	  
    document.getElementById('busy_indicator').style.display ='none';
  }
  
  // method ti hide busy sign
  function showBusysign() {
	  	  
    document.getElementById('busy_indicator').style.display ='inline';
  }
  
   
  var xmlHttpRequest;
  
  if(window.XMLHttpRequest)
 	 {
 	 	xmlHttpRequest = new XMLHttpRequest();
 	 }
  else if(window.ActiveXObject)
 	 {
 	 	xmlHttpRequest = new ActiveXObject("MICROSOFT.XMLHTTP"); 
 	 }
  
  
  // Method to submit form as an ajax call 
  function sendAllDataToServer()
  {
	  
	  
	  
	  var osTypeId = document.getElementsByName("osType")[0].value;
	  
	  var relName = document.getElementById("releaseNumber").options[document.getElementById("releaseNumber").selectedIndex].text;
	  
	  var imgName = document.getElementById("imageName").options[document.getElementById("imageName").selectedIndex].text
	 
	  var relId =  document.getElementById("releaseNumber").value;
	 
	  var imgId = document.getElementById("imageName").value;
	  
	  var osTypeName = document.getElementsByName("osType")[0].options[document.getElementsByName("osType")[0].selectedIndex].text;
	  
	  
	  if(osTypeId!=null && osTypeId!="" && relId!=null && relId!="" && imgId!=null && imgId!="")
	  {
		  	
		  	xmlHttpRequest.open("POST","MD5AssociationServlet?osType=" + osTypeId + 
		  			"&flag=submit" + "&relName=" + relName + "&imgName=" + imgName  + "&imgId=" + imgId + "&osTypeName=" + osTypeName 
		  			,true);
		  	
		  	
		  	//hideBusysign();
		  	if(document.getElementById("errorSynchTable").innerHTML!=null && document.getElementById("errorSynchTable").innerHTML!= "")
		  		{
		  		      document.getElementById("errorSynchTable").innerHTML = "";
		  		}
		  	
		  	showBusysign();
		  	
  			xmlHttpRequest.onreadystatechange = receiveSynchtable;
  			  					  			
  			xmlHttpRequest.send();
  			
	  }
	  else
	  {
		  alert("Not sending data to server as some parameters are null/empty");
	  }
	  
  }
  
  
  // Method to get the Synch Table from server
  function receiveSynchtable()
  {
	  if(xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200)
		 {
		  hideBusysign();
		  if(xmlHttpRequest.responseText != null)
			{
		  		document.getElementById("attachSynchTable").innerHTML = xmlHttpRequest.responseText; 
			}
		  else
			{
			// Removing Synch Table if it already exists
			  if( document.getElementById("attachSynchTable").innerHTML != null )
				  {
				  	document.getElementById("attachSynchTable").innerHTML = null;  
				  }
			    
			  document.getElementById("errorSynchTable").innerHTML = "Server Response is NULL";
			}
		  
		 }
	  else if((xmlHttpRequest.readyState==4 && xmlHttpRequest.status != 200) || (xmlHttpRequest.readyState==0 && xmlHttpRequest.status != 200))
		  {
		    		  		 		    
		    alert("Ajax Call (for submitting the form) failed");
		    
		    hideBusysign();
		    
		     
		    if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
		  	{
		    	document.getElementById("attachSynchTable").innerHTML = "";
		  	}
			
			document.getElementById("errorSynchTable").innerHTML = "Ajax Call Failed";
		  }	  
  }
  
  
  // Method to make ajax calls for getting imageName/releaseNumber data
  function sendMessageToServer(name)
  {
		  	 // alert("inside sendMessageToServer");
	  
		  	 if(name === "releaseNumber")
		  {
		  
		  //alert("inside sendMessageToServer & inside releaseNumber");
		  	
		  var x = document.getElementsByName("osType");
	
		  	
		  		if(x[0].value !== "")
			  	{
			  	
		  			//alert("inside sendMessageToServer & inside releaseNumber & osType is not null");	
			  	
			  	
			  		xmlHttpRequest.open("POST","MD5AssociationServlet?osType=" + x[0].value + "&flag=rel",true);			  					  
 	  	  				 	  	  
			  		
			  		if(document.getElementById("errorSynchTable").innerHTML!=null && document.getElementById("errorSynchTable").innerHTML!= "")
			  		{
			  		      document.getElementById("errorSynchTable").innerHTML = "";
			  		}
			  		
			  		showBusysign();			  					  		
			  		
			  		xmlHttpRequest.onreadystatechange = receiveReleaseNumberData;			  					  		
			  		
		  			xmlHttpRequest.send();		  			
		  		    		  
		  		}
		  		else
			  	{
			  		alert("Please select a Software Type first to proceed");
			  		
			  		// Displaying "null" message in release drop down
			  		var select = document.getElementById("releaseNumber");
	  				
			  		while ( select.firstChild ) 
	  	 	    	 	select.removeChild( select.firstChild );
	  				
			  		var el1 = document.createElement("option"); 
	  		    	 
	 	    		el1.textContent = "Select SWT first";
	 	    		el1.value = "";
	 	    		select.appendChild(el1);
	 	    		
	 	    		
	 	    		alert("SWT type needs to be selected for choosing Release and thus Image");
	 	    		
	 	    		// Displaying "null" message in imageName drop down
	 	    		var imageSelect = document.getElementById("imageName");
	 	    		
	 	    		var el2 = document.createElement("option");
	 	    		
	 	    		while ( imageSelect.firstChild ) 
	 	    			imageSelect.removeChild( imageSelect.firstChild );
	 	    		el2.textContent = "Select SWT and Release Number first";
	 	    		el2.value = "";
	 	    		imageSelect.appendChild(el2);
	 	    		
			  		
			  	}
		  
			}
	  
	  else if(name === "imageName")
		  {
		  
		 // alert("inside sendMessageToServer & inside imageName"); 
		  		var x = document.getElementsByName("releaseNumber");
			  	var y = document.getElementsByName("osType");
		  	
		  
		  		if( x[0].value !== "" && y[0].value !== "" )
		  		{
		  					  		
		  			xmlHttpRequest.open("POST","MD5AssociationServlet?releaseNumber=" + x[0].value + "&flag=img" + "&osType=" + y[0].value, true);
		  	    	
		  			
		  			if(document.getElementById("errorSynchTable").innerHTML!=null && document.getElementById("errorSynchTable").innerHTML!= "")
			  		{
			  		      document.getElementById("errorSynchTable").innerHTML = "";
			  		}
		  			
		  			showBusysign();
		  			
		  			xmlHttpRequest.onreadystatechange = receiveImageNameData;
		  			
		  				  			
		  			xmlHttpRequest.send();
		  		    
		  		}
		  		else
		  		{
		  				alert("Please select a Release Number and Software type to proceed");
		  				
		  				var select = document.getElementById("imageName");
		  				
		  				while ( select.firstChild ) 
		  	 	    	 	select.removeChild( select.firstChild );
		  				
		  				var el = document.createElement("option"); 
		  		    	 
		 	    		el.textContent = "Select SWT and Release Number first";
		 	    		el.value = "";
		 	    		select.appendChild(el);
		  				
		  		}
		  	
		  	
		  	}
		  		      
  }
  
  // Gets the data for populating releaseNumber dropdown
  function receiveReleaseNumberData()
  {
 		  
	  if(xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200)
 		 {
		  hideBusysign();
 			var myObj;
 			 				
 				myObj = JSON.parse( xmlHttpRequest.responseText );
 	      	      	         	    
 	    	var select = document.getElementById("releaseNumber");
 	             	     
 	     	while ( select.firstChild ) 
 	    	 	select.removeChild( select.firstChild );
 	    
 	    	if( myObj.length > 0 ) // json returned is not null
 	    	{
 	    		 	     	             	    	 
 	   			var nodeLength = select.childNodes.length;
 	  	
 	            // Populating the dropdown for release Name 	     
 	    		if( nodeLength == 0 )
 	    		{
 	    	  	    	
 	    			var elFirst = document.createElement("option");
 	    			elFirst.textContent = "Select One";
 	    			elFirst.value = "";
 	    			select.appendChild(elFirst);
 	    			
 	    			for(var i=0; i<myObj.length;i++)
 	    	 		{
 	    	 			var id = myObj[i].id;
 	    	 			var name = myObj[i].value;
 	    	 			var el = document.createElement("option"); 
 	    	 
 	    	    		el.textContent = name;
 	    	    		el.value = id;
 	    	    		select.appendChild(el);
 	    	 	
 	    	 		}
 	    		
 	    		}
 	    
 	    	    
 	         
 	    	}
 	    	else
 	    	{
 	    		
 	    		var el1 = document.createElement("option"); 
	    	 
 	    		el1.textContent = "No Release Found";
 	    		el1.value = "";
 	    		select.appendChild(el1);
 	    		
 	    		// No image present as No release found
 	    		
 	    		var imageSelect = document.getElementById("imageName");
 	    		
 	    		var el2 = document.createElement("option");
 	    		
 	    		while ( imageSelect.firstChild ) 
 	    			imageSelect.removeChild( imageSelect.firstChild );
 	    		
 	    		el2.textContent = "No Image present as no Release found";
 	    		el2.value = "";
 	    		imageSelect.appendChild(el2);
 	    		
 	    		if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
 	   	  		{
 	   	    		document.getElementById("attachSynchTable").innerHTML = "";
 	   	  		}
 	    		if( document.getElementById("errorSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
 	   	  		{
 	   	    		document.getElementById("errorSynchTable").innerHTML = "";
 	   	  		}
 	    		
 	    	}
 	           	           	   
 	 }
 	 else if((xmlHttpRequest.readyState==4 && xmlHttpRequest.status != 200) || (xmlHttpRequest.readyState==0 && xmlHttpRequest.status != 200))
 	 {
 		 alert("Ajax call (for gettin release name data) failed");
 		 
 		 hideBusysign();
 		
 		if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
	  	{
	    	document.getElementById("attachSynchTable").innerHTML = "";
	  	}
		
		document.getElementById("errorSynchTable").innerHTML = "Ajax Call Failed";
 	 }
  }
  
  // Gets the data for populating imageName dropdown
  function receiveImageNameData()
  {
	 	 	  	  	  
	  if(xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200)
 		 {
		  hideBusysign();
 			var myObj;
 					 
 				myObj = JSON.parse( xmlHttpRequest.responseText );
 			 	    	
 	    	var select = document.getElementById("imageName");
 	             	     
 	     	while ( select.firstChild ) 
 	    	 	select.removeChild( select.firstChild ); 
 	    	 	     		 	     		
 	     	if( myObj.length > 0 )
 	    	{ 	    		 	    		
 	         	     	             	    	 
 	   			var nodeLength = select.childNodes.length;
 	  			
 	             	     
 	    		if( nodeLength == 0  )
 	    		{
 	    			
 	    			var elFirst = document.createElement("option");
 	    			elFirst.textContent = "Select One";
 	    			elFirst.value = "";
 	    			select.appendChild(elFirst);
 	    			
 	    			for(var i=0; i<myObj.length;i++)
 	    	 		{
 	    	 			var id = myObj[i].id;
 	    	 			var name = myObj[i].value;
 	    	 		 
 	    	 			var el = document.createElement("option"); 	    	 
 	    	    		el.textContent = name;
 	    	    		el.value = id;
 	    	    		
 	    	    		select.appendChild(el);
 	    	    		
 	    	 		}
 	    		
 	    		}
 		 
 	    	}
 	    	else
 	    	{
 	    		alert("There are no images present for the selected Release Number");
 	    		
 	    		var el = document.createElement("option"); 
 	 	    	 
 	    		el.textContent = "No Image Found";
 	    		el.value = "";
 	    		
 	    		select.appendChild(el);
 	    		hideBusysign();
 	    		
 	    		if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
 			  	{
 			    	document.getElementById("attachSynchTable").innerHTML = "";
 			  	}
 	    		
 	    		 
 	 
 	    	} 	     	           	           	   
 	 }
 	 else if ((xmlHttpRequest.readyState==4 && xmlHttpRequest.status != 200) || (xmlHttpRequest.readyState==0 && xmlHttpRequest.status != 200))
 	 {
 			alert("Ajax call (for getting imageName data) failed");
 			
 			hideBusysign();
 			
 			if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
			  	{
			    	document.getElementById("attachSynchTable").innerHTML = "";
			  	}
 			
 			document.getElementById("errorSynchTable").innerHTML = "Ajax Call Failed";
 			
 			
 	 }
  
  }
    
 
// Resets SWT Dropdown 		  
  function resetSWAction()
  {
 	 document.forms['softwareSelector'].elements['osType'].value=''; // Resetting The Software Type Widget
  }
  
 
// Method to make ajax call for synching MD5
function SynchMD5()
{
		 		    	    
	    var osTypeId = document.getElementsByName("osType")[0].value;
	    
	    var md5InSDSP = document.getElementsByName("md5_in_sdsp")[0].value;
	    
	    var imageId = document.getElementsByName("imageName")[0].value;	
	   	   	    
	   	    
	    if( (osTypeId!==null) && (osTypeId!=="") && (md5InSDSP !==null) && (md5InSDSP !=="") && (imageId !==null) && (imageId !==""))
	    {	    		    		    	
	    
	    	xmlHttpRequest.open("POST","MD5AssociationServlet?osType=" + osTypeId + "&flag=synch" + "&md5InSDSP=" + 
	    			md5InSDSP + "&selectedImageId=" + imageId ,true);	    	
	    	
	    	
	    	if(document.getElementById("errorSynchTable").innerHTML!=null && document.getElementById("errorSynchTable").innerHTML!= "")
	  		{
	  		      document.getElementById("errorSynchTable").innerHTML = "";
	  		}
	    	showBusysign();
			
	    	xmlHttpRequest.onreadystatechange = getMD5ResponseFromServer;
			  					  			
			xmlHttpRequest.send();
	    }
	    else
	    {
	    	alert("Can't Synch MD5 as the MD5 value returned from YPublish WebService is NULL");	
	    }
		
}


// This method gets the authentication for MD5 from server
function getMD5ResponseFromServer()
{
	 if(xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200)
	{
		 hideBusysign();
		var serverResponseObject  =  JSON.parse( xmlHttpRequest.responseText );
		
		var md5Response = serverResponseObject.md5SynchResponse;				
		
		if(!(md5Response === ""))
		{
			var equalityButton = document.getElementById("equalityCheck");
			
			equalityButton.disabled  = true;
												
			var newMd5 = document.getElementsByName("md5_in_sdsp");
									
			document.getElementsByName('md5_in_sprit')[0].value = newMd5[0].value; 
			
		}
		else
			{
				alert("Update failed")
			}
	}
	 else if((xmlHttpRequest.readyState==4 && xmlHttpRequest.status != 200) || (xmlHttpRequest.readyState==0 && xmlHttpRequest.status != 200))
		 {
		 		alert("Ajax call (for synching MD5 data) failed");
		 		hideBusysign();
		 		
		 		if( document.getElementById("attachSynchTable").innerHTML != null || document.getElementById("attachSynchTable").innerHTML != "" )
			  	{
			    	document.getElementById("attachSynchTable").innerHTML = "";
			  	}
 			
 			document.getElementById("errorSynchTable").innerHTML = "Ajax Call Failed";
		 }
	
}


</script>

<style>

#select_width{
 width:400px;   
}



#busy_indicator {
  display: none;
  float: right;
  background: rgb(255,241,168);
  margin-top: 5px;
  z-index: 1000;
  width: 200;
  font-weight: bold;
  text-align: center;
  font-size: 1em;

</style>

<%= Footer.pageFooter(globals) %>
</spritui:page>



<!-- end -->




