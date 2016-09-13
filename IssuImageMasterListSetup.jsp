<!--.........................................................................
: DESCRIPTION:
: Admin Menu Page: Displays links to all ISSU Master Image List Edit/View pages.
:
: AUTHORS:
: @author Nadia Lee (nadialee@cisco.com)
:
: Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="java.util.Properties" %>
<%
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
//  String pathGfx;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
%>
<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<span class="headline">
    ISSU Master Image Administration Module
</span><br /><br />

<span class="subHeadline">
    Options
</span><br />
<ul>
<%
if( spritAccessManager.isAdminSprit()
      || spritAccessManager.isAdminIssu()  )
{
%>
    <li><a href="IssuImageMasterList.jsp?act=edit">ISSU Image Master List Edit</a> </li>
<%
}  // if( spritAccessManager.isAdminSprit() || . . .
%>
    <li><a href="IssuImageMasterList.jsp?act=view">ISSU Image Master List View</a> </li>
</ul>

<%= Footer.pageFooter(globals) %>
<!-- end -->
