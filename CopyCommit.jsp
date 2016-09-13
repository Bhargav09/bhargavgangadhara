<!--.........................................................................
: DESCRIPTION:
: Copying Result Page
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002 , 2003 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<!-- SPRIT -->
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<%
  SpritGlobalInfo globals;
// Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
%>  

<%= SpritGUI.pageHeader( globals,"Copy Images Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Copy Images Result" ) %>
<script language="javascript">
window.opener.parent.document.editImageList.submit();
function closeForm() {
     self.close();
  }  // function closeForm

//reloads the parent page
function reLoad() {
    window.opener.parent.document.editImageList.submit();
  }  // function reLoad
  
</script>
<html>
<head>
  <title>SPRIT - Copy Image Commit is Done... </title>
  
</head>
<body onLoad = "reLoad()">

<form>

<center>
<table></table>
<table>
<tr>
  <td bgcolor="#3d127b"><img src="../gfx/b1x1.gif" /></td>
</tr>
<tr><td >
<%=request.getAttribute("result")%>
</td>
</tr>
<!-- Display Image Name Validation result e.g image1,image2$!max_Length -->
<%
	String imageNameValidation = (String) request.getAttribute("imageNameValidation");
	if (imageNameValidation != null && imageNameValidation.length() > 0) {
		String [] arrImageNames = imageNameValidation.split(",");
		String [] arrDelimiter = arrImageNames[(arrImageNames.length -1)].split("~!");
		arrImageNames[(arrImageNames.length -1)] = arrDelimiter[0];
%>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Formatted values of the image name/s is greater than <%= arrDelimiter[1]%> <br />
			<ul>
<%		
		for (int i=0;i<arrImageNames.length;i++){ 
%>
			<li><%= arrImageNames[i] %></li>
<%
	}
%>			
			</ul>			
	 		</td>
		</tr>
<%
	}	 
%>

<tr>
 <td bgcolor="#3d127b"><img src="../gfx/b1x1.gif" /></td>
</tr>
</table>
<table>
  <tr> <td> 
  <a href="javascript:closeForm()"><img
  	    src="../gfx/btn_copy_exit.gif" border="0" /></a>
  </td></tr>	   
</table>
<center>
</form>

</body>
</html>

<%=Footer.pageFooter(globals)%>
