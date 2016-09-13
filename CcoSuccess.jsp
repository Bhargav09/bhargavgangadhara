<!--.........................................................................
: DESCRIPTION:
: No OS Type found.
:
: AUTHORS:
: @author Sunil Mathew (sunmathe@cisco.com)
:
: Copyright (c) Cisco Systems, Inc. 2005.  All rights reserved.
:.........................................................................-->
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String pathGfx;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( SpritConstants.PATH_GFX );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "",
      SpritGUI.renderOSTypeNav(globals,"CCO SUBMIT")
      );
%>
<%= SpritGUI.pageHeader( globals,NonIosCcoPostHelper.NO_OS_TYPE_PAGE_HDR,"" ) %>
<%= banner.render() %>

<center>
  <%=
    SpritGUI.renderErrorBox( globals,
                             "SUCCESS",
                             "CCO Submit Success"
        )
  %>
</center>

<%= Footer.pageFooter(globals) %>
<!-- end -->
