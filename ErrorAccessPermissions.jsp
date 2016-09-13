<!--.........................................................................
: DESCRIPTION:
: Release information page like the additional milestone owners.
:
: AUTHORS:
: @author Elliott Lee (tenchi@cisco.com)
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2003, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String pathGfx;
  TableMaker tableReleasesYouOwn;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
%>
<%= SpritGUI.pageHeader( globals,null,null ) %>
<%= banner.render() %>

<center>
  <%=
    SpritGUI.renderErrorBox( globals,"You're not authorized to access",""
        + "You do not appear to have the proper access permissions to view\n"
        + "this page.  If you feel you have reached this message in error\n"
        + "please contact the SPRIT administrators.\n"
        )
  %>
</center>

<%= Footer.pageFooter(globals) %>
<!-- end -->
