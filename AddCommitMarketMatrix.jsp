<!--.........................................................................
: DESCRIPTION:
: Adding Result Page
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
:
: Copyright (c) 2004, 2010 by Cisco Systems, Inc.
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
  String pathGfx;
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
%>  

<%= SpritGUI.pageHeader( globals,"Add Images Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Add Images Result" ) %>
<script language="javascript">
window.opener.parent.document.mmUpdate.submit();
function closeForm() {
     self.close();
  }  // function closeForm

//reloads the parent page
function reLoad() {
    window.opener.parent.document.mmUpdate.submit();
  }  // function reLoad
  
</script>
<html>
<head>
  <title>SPRIT - Add Images to Market Matrix is Done... </title>
  
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
<%=request.getParameter("result")%>
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
