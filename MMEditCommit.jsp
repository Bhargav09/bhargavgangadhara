<!--.........................................................................
: DESCRIPTION:
: Edit commit is in progress and after commit redirects to MarketMatrixEdit.jsp
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2003 , 2004 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->


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

<%= SpritGUI.pageHeader( globals,"Edit Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Edit Result" ) %>

<% if (true) {
%>
<% String releaseNumber = request.getParameter("releaseNumberId"); 
String redirectURL = "MarketMatrixEdit.jsp";
redirectURL += "?releaseNumberId="+request.getParameter("releaseNumberId");
response.sendRedirect(redirectURL);
%>
<% } %>

<%=Footer.pageFooter(globals)%>

