<!--.........................................................................
: DESCRIPTION:
: Non-IOS Release selector results page that gets shown in a pop-up.
:
: AUTHORS:
: @author Sricharan Vangapalli (svangapa@cisco.com)
:
: Copyright (c) 2008 by Cisco Systems, Inc.
:.........................................................................-->

<%@ page import = "com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleasenumber.CsprReleaseNumberLocal" %>
<%@ page import = "java.util.Collection" %>
<%@ page import = "java.util.Iterator" %>

<% 
  Integer               osTypeId            = null;
  String                osType              = null;
  String                selectedTab         = null;
  String				mode				= null;
  SpritGlobalInfo       globals;
  NonIosCcoPostHelper   nonIosCcoPostHelper = new NonIosCcoPostHelper();
  
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);

  if(osType == null || osType.equals("")) {
     osType = (String) request.getAttribute("osType");
     osTypeId = (Integer) request.getAttribute("osTypeId");
  }
  // Get os type ID.  Try to convert it to an Integer from the web value!
  try {
    if(osType == null || osType.equals("")) {
     osTypeId = nonIosCcoPostHelper.getOSTypeId(request); 
     osType = nonIosCcoPostHelper.getOSType(osTypeId);
    }
  } catch ( Exception e ) {
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  if(osType == null || osType.equals("")) {
   // No os type!  Bad! Redirect to error page.
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }
  
  selectedTab = WebUtils.getParameter(request,"selectedTab");
  mode = WebUtils.getParameter(request,NonIosCcoPostHelper.MODE);

  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
%>

<%= SpritGUI.pageHeader( globals,"Select Release Number","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Select Release Number" ) %>

<script language="javascript"><!--
  // Redirects the user to the appropriate tab!
  //
  // IN: releaseNumberId: ID to use.
  // osType: OS Type to use 
  // selectedTab: which tab/page to forward to:
  //     "op":  Opus
  //     "bom": DEM/BOM
  function releaseView( releaseNumberId, osType, selectedTab ) {
    var pageUrl;
    
    if( selectedTab == "op" ) {
      pageUrl = "Opus.jsp?releaseNumberId=" + releaseNumberId;
    } else if( selectedTab == "bom" ) {
      pageUrl = "DemSpecnoPartnoView.jsp?releaseNumberId=" + releaseNumberId;
    } else if ( selectedTab == "CCOPost" ) {
      pageUrl = "NonIosCcoView.jsp?mode=<%= mode %>&releaseName=" + releaseNumberId;
    }

    window.opener.location = pageUrl 
      + "&osTypeId=" + osType;
    self.close();
  }
//--></script>

<table border="0" cellpadding="3" cellspacing="1" width="100%">
  <tbody>
    <tr>
<%
  Collection relColl = 
      EJBHomeFactory.getFactory().getCsprReleaseNumberLocalHome().findByOsTypeId(osTypeId);
  Iterator itr = relColl.iterator();
  int collSize = relColl.size();
%>
      <td>
      We found <b><%= collSize %></b> matching records. Please click on one of the following release 
      numbers to view that release: 
      </td>
    </tr>  
    <tr>
    <td align="center">
<%
  String resultsArray[];
  resultsArray = new String[collSize];
  int idx = 0;
  while (itr.hasNext()) {
    CsprReleaseNumberLocal local = (CsprReleaseNumberLocal)itr.next(); 
    if (selectedTab != null && selectedTab.equals("CCOPost")) {
    	resultsArray[idx] = ""
              + "<a href=\"javascript:releaseView(&quot;"
              +  WebUtils.escUrl(local.getReleaseName()) 
              + "&quot;" +
              ",&quot;" + osTypeId + "&quot;" +
              ",&quot;" + selectedTab + "&quot;)\">" 
              + WebUtils.escHtml(local.getReleaseName()) + "</a>";
    } else {
    	resultsArray[idx] = ""
              + "<a href=\"javascript:releaseView(&quot;"
              +  WebUtils.escUrl(local.getReleaseNumberId().toString()) 
              + "&quot;" +
              ",&quot;" + osTypeId + "&quot;" +
              ",&quot;" + selectedTab + "&quot;)\">" 
              + WebUtils.escHtml(local.getReleaseName()) + "</a>";
    }
    idx++;
  } // end of while

  // Render that buffer of Strings[] with our multicolumn renderer!
  out.print(""
    + SpritGUI.renderTableStringArrayColumns(
      globals,
      resultsArray,
      3,null,null,
      null,null,null,null ));
%>
</td></tr></tbody></table>
<%= Footer.pageFooter(globals) %>
<!-- end -->
