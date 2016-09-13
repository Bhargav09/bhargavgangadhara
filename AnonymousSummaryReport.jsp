<!--.........................................................................
: Description:
:   - GET Report.
:
: AUTHORS:
: @author Raju 
:
: Copyright (c) 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................
-->
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.anonymous.*" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
SpritAccessManager spritAccessManager;
SpritGlobalInfo globals;
SpritGUIBanner banner;
String pathGfx;

// Initialize globals
globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );
spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

// Set up banner for later
banner =  new SpritGUIBanner( globals );
banner.addContextNavElement( "REL:",
    SpritGUI.renderReleaseNumberNav(globals,null)
    );
%>

<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<%
StringBuffer body = null;
if( spritAccessManager.isAdminSprit() || spritAccessManager.isGlobalExportTrade() )
{
	body = AnonymousReportHelper.getAnonymousReport(true, request.getRemoteUser());
} else 
{
	body = AnonymousReportHelper.getAnonymousReport(false, request.getRemoteUser());
}  
%>
<span class="headline">
  Anonymous Publishing Report
</span><br/><br/>
<% if( request.getAttribute("message") != null ) { %>
	<font color="red"><%=request.getAttribute("message")%></font>
<% } %>
<%=body.toString()%>
<%= Footer.pageFooter(globals) %>
