<!--.........................................................................
: DESCRIPTION:
: Adding Result Page
:
: AUTHORS:
: @author Sricharan Vangapalli (svangapa@cisco.com)
:
: Copyright (c) 2008 by Cisco Systems, Inc.
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
  //String pathGfx;
  globals = SpritInitializeGlobals.init(request,response);
  //pathGfx = globals.gs( "pathGfx" );
%>  

<%= SpritGUI.pageHeader( globals,"Add Images Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Add Images Result" ) %>
<script language="javascript">
window.opener.parent.document.productizationEdit.submit();
function closeForm() {
     self.close();
  }  // function closeForm

//reloads the parent page
function reLoad() {
    window.opener.parent.document.productizationEdit.submit();
  }  // function reLoad
  
</script>
<html>
<head>
  <title>SPRIT - Add Images to Productization is Done... </title>
  
</head>
<body onLoad = "reLoad()">

<form>

<center>
<table></table>
<table>
<tr>
  <td bgcolor="#3d127b"><img src="../gfx/b1x1.gif" /></td>
</tr>
<tr>
<td >
<% if (request.getAttribute("message") != null) { %>
  <%= (String)request.getAttribute("message") %>
<% } else { %>
  <b>Images successfully added to Productization Page</b> 
<% } %>  
</td>
</tr>
<tr>
 <td bgcolor="#3d127b"><img src="../gfx/b1x1.gif" /></td>
</tr>
</table>
<table>
  <tr> <td> 
  <a href="javascript:closeForm()"><img
        src="../gfx/btn_close.gif" border="0" /></a>
  </td></tr>     
</table>
<center>
</form>

</body>
</html>

<%=Footer.pageFooter(globals)%>
