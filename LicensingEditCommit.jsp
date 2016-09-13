<!--.........................................................................................
: DESCRIPTION:
: Edit commit is in progress and after commit redirects to UpgradePlannerLicensing.jsp
:
: AUTHORS:
: @author Akshay Buradkar (aburadka@cisco.com)
:
: Copyright (c) 2002-2003, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................................-->

<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="java.net.*" %>

<%
  SpritGlobalInfo globals;
// Initialize globals
  String pathGfx;
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
%>  

<%= SpritGUI.pageHeader( globals,"Edit Pseudo Images Result","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Edit Pseudo Images Result" ) %>

<% if (true) {
String releaseNumber = request.getParameter("releaseNumberId"); 
String message = request.getParameter("Result");
String redirectURL = "UpgradePlannerLicensing.jsp";
redirectURL += "?releaseNumberId="+request.getParameter("releaseNumberId")
		    + "&outputType=" + request.getParameter("outputType")
			+ "&filtImgnm=" + request.getParameter("filtImgnm")
			+ "&filtFsetdesc=" + request.getParameter("filtFsetdesc")
			+ "&sortCcoDir=" + request.getParameter("sortCcoDir")
			+ "&sortImgnmDir=" + request.getParameter("sortImgnmDir")
			+ "&sortPriField=" + request.getParameter("sortPriField")
		    +"&Result="+request.getParameter("Result")
		    ;

response.sendRedirect(redirectURL);
%>
<% } %>

<%=Footer.pageFooter(globals)%>