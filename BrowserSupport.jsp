<!--.........................................................................
: DESCRIPTION:
: Release information page like the additional milestone owners.
:
: AUTHORS:
: @author Elliott Lee (tenchi@cisco.com)
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) Cisco Systems, Inc. 2002.  All rights reserved.
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
%>
<%= SpritGUI.pageHeader( globals,"Release View","" ) %>
<%= banner.render() %>
<html>
<body onload = "browserVer()">
<br /><center><table border="1" cellpadding="5" cellspacing="0"><tr><td bgcolor="ffffff"><i><font color="#c00000"><center>Sprit has detected that you are using an incompatible browser.<br />Sprit works well with the following browsers: <table border=0 cellpadding=2 cellspacing=2><tr><td>
<ul>
<li>Internet Explorer 5+ (<a href="http://wwwin-download.cisco.com">Soft Tracker</a>)</li>
<li>Netscape 7+ (<a href="http://channels.netscape.com/ns/browsers/download.jsp">Netscape Downloads</a>)</li>
</ul></td></tr></table>
If you beleive you have received this message in error please contact the <a href="mailto:sprit-team@cisco.com">Sprit Team</a>.</center></font></i></td></tr></table></center><p />If you are using a Windows based PC you should be able to use Internet Explorer to access Sprit.  If you continue to have problems while using Internet Explorer, please upgarde to the most recent version by clicking the Soft Tracker link, above.  As of May 1, 2003 Cisco is upgrading it's support of Netscape from Netscape 4.79 to Netscape 7, as stated in the recent <a href="http://wwwin.cisco.com/pcgi-bin/HR/EC/news/display/Ds.cgi/42003/1293504022003?Db=1293504022003&C=WC11645&Do=html&Dl=42003">CEC article</a> and you will be able to upgrade then if you do not want to use Internet Explorer.<p />If you are using a UNIX based workstation, it is also upgrade to Netscape 7, our new corporate standard. 
If you dont have Netscape 7, Please contact <a href="mailto:sysadmin@cisco.com">Sysadmin</a>. If you do not want to use Netscape or you want to use a different browser you have the option of using any of the browsers listed above.<p />We apologize for any inconvenience that this may have caused. <br />Thank you for your understanding.<br />Sprit Team<table border=0 cellpadding=1 cellspacing=0 width="100%">
<%= Footer.pageFooter(globals) %>
<!-- end -->

</body>
<script language="javascript">


//reloads the parent page
function browserVer() {
    window.opener.parent.close();
  }  // function reLoad
  
</script>
</html>
