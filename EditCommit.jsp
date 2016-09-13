<!--.........................................................................
: DESCRIPTION:
: Edit commit is in progress and after commit redirects to ImageListEdit.jsp
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002 , 2003 by Cisco Systems, Inc.
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

<%= SpritGUI.pageHeader( globals,"Edit Images Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Edit Images Result" ) %>

<% if (true) {
%>
<% String releaseNumber = request.getParameter("releaseNumberId"); 
String redirectURL = "ImageListEdit.jsp";
redirectURL += "?releaseNumberId="+request.getParameter("releaseNumberId")+"&PlatformFilter="+request.getParameter("PlatformFilter")+"&ImageFilter="+request.getParameter("ImageFilter")+"&sort="+request.getParameter("sort");
response.sendRedirect(redirectURL);
%>
<% } %>

<%=Footer.pageFooter(globals)%>

