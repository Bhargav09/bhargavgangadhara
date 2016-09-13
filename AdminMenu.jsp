
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%
  Properties props;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
//  String pathGfx;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  props = (Properties) globals.go( "properties" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );

  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
%>
<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<%

if( spritAccessManager.isAdminSprit() ) {
  StringBuffer htmlSpritInfo;
  String htmlNoEntry =
      "<span class=\"warningText\"><i>Will not be sent</i></span>";

  htmlSpritInfo = new StringBuffer();
  htmlSpritInfo.append(
      SpritGUI.renderInfoBox( globals, "SPRIT System Info", ""
          + "<table border=\"0\" cellpadding=\"2\" cellspacing=\"0\">\n"

          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Environment mode:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    <font size=\"+1\"><b>\n"
          + "    " + WebUtils.escHtml( globals.gs("envMode") ) + "\n"
          + "    </b></font>\n"
          + "  </span></td>\n"
          + "</tr>\n"

          + "<tr><td colspan=\"2\"><hr size=\"1\" /></td></tr>\n"

          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Your effective user ID:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    " + WebUtils.escHtml( spritAccessManager.getUserId() ) + "\n"
          + "  </span></td>\n"
          + "</tr>\n"
          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Your autenticated user ID:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    " + WebUtils.escHtml( spritAccessManager.getUserIdAuthenticated() ) + "\n"
          + "  </span></td>\n"
          + "</tr>\n"

          + "<tr><td colspan=\"2\"><hr size=\"1\" /></td></tr>\n"

          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Email addresses:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    <table border=\"0\" cellpadding=\"2\" cellspacing=\"0\">\n"

          + "    <tr><td colspan=\"2\" bgcolor=\"#a0a0a0\"><span class=\"dataTableTitle\">\n"
          + "      Admin Feature Set change:\n"
          + "    </span></td></tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Dev:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailFeatureSetChangeDev")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Test:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailFeatureSetChangeTest")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Prod:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailFeatureSetChangeProd")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"

          + "    <tr><td>&nbsp;</td></tr>\n"

          + "    <tr><td colspan=\"2\" bgcolor=\"#a0a0a0\"><span class=\"dataTableTitle\">\n"
          + "      New Feature Set request:\n"
          + "    </span></td></tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Dev:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>To:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescDevTo")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">&nbsp;</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>Cc:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescDevCc")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Test:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>To:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescTestTo")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">&nbsp;</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>Cc:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescTestCc")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Prod:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>To:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescProdTo")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">&nbsp;</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\"><b>Cc:</b> "
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailRequestNewFsetDescProdCc")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    </tr>\n"

          + "    <tr><td>&nbsp;</td></tr>\n"

          + "    <tr><td colspan=\"2\" bgcolor=\"#a0a0a0\"><span class=\"dataTableTitle\">\n"
          + "      New image notification:\n"
          + "    </span></td></tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Dev:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailNewImageDev")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Test:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailNewImageTest")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Prod:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailNewImageProd")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"

          + "    <tr><td>&nbsp;</td></tr>\n"

          + "    <tr><td colspan=\"2\" bgcolor=\"#a0a0a0\"><span class=\"dataTableTitle\">\n"
          + "      Memory change notification:\n"
          + "    </span></td></tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Dev:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailMemoryChangeDev")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Test:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailMemoryChangeTest")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"
          + "    <tr>\n"
          + "      <td align=\"left\"><span class=\"dataTableTitle\">Prod:</span></td>\n"
          + "      <td align=\"left\"><span class=\"dataTableData\">"
              + StringUtils.nvlOrBlank(
                  WebUtils.escHtml(props.getProperty("emailMemoryChangeProd")),
                  htmlNoEntry
                  )
              + "</span></td>\n"
          + "    </tr>\n"

          + "    </table>\n"

          + "<tr><td colspan=\"2\"><hr size=\"1\" /></td></tr>\n"

          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Logs dir:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    " + WebUtils.escHtml( props.getProperty("logDir") ) + "\n"
          + "  </span></td>\n"
          + "</tr>\n"
          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    Master logfile:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    " + WebUtils.escHtml( props.getProperty("logFileMaster") )+ "\n"
          + "  </span></td>\n"
          + "</tr>\n"

          + "<tr><td colspan=\"2\"><hr size=\"1\" /></td></tr>\n"

          + "<tr>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableTitle\">\n"
          + "    JDBC pool name:\n"
          + "  </span></td>\n"
          + "  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">\n"
          + "    " + WebUtils.escHtml( props.getProperty("dbJdbcPoolName") ) + "\n"
          + "  </span></td>\n"
          + "</tr>\n"

          + "</table>\n"
          )
      );
  %>
    <table border="0" align="right" cellpadding="10"><tr><td align="left">
      <%= htmlSpritInfo.toString() %>
      <center><span class="caption">
        This information is only available to <b>AdminSprit</b> role members.
      </span></center><br />
    </td></tr></table>
  <%
}  // if( !spritAccessManager.isAdmin() )
%>
<%
 String envMode;
 String serverName = "eit";

   // Figure out if we're in a different environment mode!
   envMode = globals.gs( "envMode" );
   if( envMode.equals("dev") ) {
     serverName = "eitdev";
   }  // if( envMode.equals("dev") )

   if( envMode.equals("test") ) {
     serverName = "eittest";
   }  // if( envMode.equals("test") )

%>

<span class="headline">
  Admin Menu
</span><br /><br />

<span class="subHeadline">
  Data Selection Lists
</span><br />
<ul>
  <li> <a href="EditSpritProperties.jsp">Sprit Properties Admin</a> </li>
</ul>

<span class="subHeadline">
  Data Mapping
</span><br />
<ul>
	<!--CSCud06651 -->
	<%
    if( spritAccessManager.isAdminFeatureSet() ) {
  %>
	<li><a href="AdminFeatureSet.jsp">Feature Set Descriptions and
			Designator Control-IOS</a></li>
	<%
    }  // if( spritAccessManager.isAdminFeatureSet() )
  %>
	<%
    if( spritAccessManager.isAdminFeatureSet() ) {
  %>
	<li><a href="NonIosAdminFeatureSet.jsp">Feature Set
			Descriptions and Designator Control-Non-IOS</a></li>
	<%
    }  // if( spritAccessManager.isAdminFeatureSet() )
  %>
	<!--CSCud06651-->
	<%
  if( spritAccessManager.isAdminSprit() ) {
  %>
     <li> <a href="http://wwwin-<%=serverName%>.cisco.com/siis/pcgi/sysMaint.cgi"> Global Variables </a> </li>
  <%
     }  // if( spritAccessManager.isAdminSprit() )
  %>
  <%
  if( spritAccessManager.isAdminSprit() ) {
  %>
        <li> <a href="ExportControlSetupEdit.jsp">Export Control Value Set up</a> </li>
      <!-- <li> <a href="http://wwwin-<%=serverName%>.cisco.com/siis/pcgi/exportControl.cgi"> Encryption Module </a> </li> -->
  <%
       }  // if( spritAccessManager.isAdminSprit() )
  %>
 
   <!--digarg CSCuc15774 
   creating seperate Platform Mapping link for Non-IOS-->  
  <!-- <li> <a href="PlatformSetup.jsp">Platform Mappings</a> </li> --> 
  <li> <a href="PlatformSetup.jsp">Platform Mappings-IOS</a> </li>
  <li> <a href="NonIosPlatformSetup.jsp">Platform Mappings-Non-IOS</a> </li>
  <!-- end digarg -->
</ul>


<%
  if( spritAccessManager.isAdminSprit() ) {
%>

<!-------  Doc Publish ---------------------->
<span class="subHeadline">
  Doc Publish
</span><br />
<ul>
  <li> <a href="go?action=docpublishadmin">Doc Publish Admin</a> </li>
</ul>

<%
     }  // if( spritAccessManager.isAdminSprit() )
%>


<!-------  Metadata Association Admin ---------------------->

<span class="subHeadline">
  Metadata 
</span><br />
<ul>
    <li> <a href="AdminSoftwareTypeMetadata.jsp"> Metadata Association </a> </li>
</ul>
<!-------  Access Level Approval ----------------------  >

<span class="subHeadline">
  Access Level Approval 
</span><br />
<ul>
    <li> <a href="FreeSoftwareAccessApproval.jsp?action=Edit"> Free Software Approval </a> </li>
</ul>
<!-------- Prioritization Approval ----------------->
<span class="subHeadline">
  Publish Prioritization Approval
</span><br />
<ul>
    <li> <a href="RequestEditPrioritization.jsp?action=Edit"> Request/Edit Prioritization </a> </li>
    
 <%
  if( spritAccessManager.isGovernanceTeam() || spritAccessManager.isAdminSprit() ) {
%>

<!-------  Governanace Team  ---------------------->
    <li> <a href="SoftwarePublishPrioritizationApprove.jsp?action=Edit"> Approve Prioritization </a> </li>
  <%
  } 
  %>
    <li> <a href="SoftwarePublishPrioritizationRequestViewCancel.jsp?action=prioritizationStatus"> View /Report Prioritization </a> </li>
     
</ul>

<!-------  Opt Out ---------------------->
<span class="subHeadline">
  Opt Out
</span><br />
<ul>
    <li> <a href="OptOut.jsp?type=View"> View Opt Out </a> </li>
    <li> <a href="OptOut.jsp?type=Edit"> Edit Opt Out </a> </li>
 </ul>


<!-------  ISSU ---------------------->
<span class="subHeadline">
  ISSU
</span><br />

<ul>
    <li> <a href="IssuImageMasterListSetup.jsp">ISSU Image Master List</a> </li>
</ul>

<span class="subHeadline">
  User Permissions
</span><br />
<ul>
  <%
    if( spritAccessManager.isAdminSprit() ) {
  %>
    <li> <a href="RoleSetupMenu.jsp">Role setup</a> </li>
  <%
    }  // if( spritAccessManager.isAdminSprit() )

   if( spritAccessManager.isAdminSprit() ) {
  %>
    <li> <a href="http://wwwin-<%=serverName%>.cisco.com/siis/pcgi/grouper.cgi"> Grouper Information </a> </li>
  <%
    }  // if( spritAccessManager.isAdminSprit() )
  %>
</ul>


<!-- ----------Miscellaneous Part--------- -->

<span class="subHeadline">
  Miscellaneous
</span><br />
<ul>
  <li> <a href="javascript:notImpl();">Message of the Day editor</a> </li>
  <li> <a href="go?action=outage&mode=1">Outage Administration</a> </li>
  <li> <a href="MD5_Association.jsp">MD5 Association Page</a></li>
</ul>

<%
  if( spritAccessManager.isAdminSprit() || spritAccessManager.isAdminCco() || spritAccessManager.isRoleMember("adminMajorDvdMdf")) {
%>

<!-- ---------------24 X 7 Support Part-------------- -->
<span class="subHeadline">
  24x7 Support
</span><br />

<%
  if( spritAccessManager.isAdminSprit() || spritAccessManager.isRoleMember("adminMajorDvdMdf")) {
%>

<%
  if( spritAccessManager.isAdminSprit() ) {
%>

<ul>
 <li> <a href="Admin24x7Support.jsp">24x7 Support Menu</a> </li>
 </ul>

 <ul>
 <li> <a href="CcoPostStatusReset.jsp">CCO Post Status Reset </a> </li>
 </ul>

 <ul>
 <li> <a href="go?action=autopublish">Auto Publish</a> </li>
 </ul>

 <ul>
 <li> <a href="go?action=bulkpost">Bulk Post</a> </li>
 </ul>
 
<%
  }
%>
 
 <ul>
 <li> <a href="go?action=dvdmajormdf">Dvd Major Release Mdf View</a> </li>
 </ul>
 <ul>
 <li> <a href="go?action=dvdmajormdf&output=dvdmajorrelrulespage">Dvd Major Release Mdf Rule Engine</a> </li>
 </ul>

<%
     }  else {
%>
 <ul>
 <li> <a href="go?action=bulkpost">Bulk Post</a> </li>
 </ul>
<%
     }  // if( spritAccessManager.isAdminSprit() ) else
  }
%>

<!-------  Software Retirement ---------------------->
<span class="subHeadline">
  Software Retirement
</span><br />

 <ul>
     <a href="go?action=qotidentify"> Software Retirement</a> 
     
 </ul>

<span class="subHeadline">
  Global Export Trading
</span><br />

 <ul>
     <a href="AnonymousSummaryReport.jsp">Anonymous Summary Report</a> 
 </ul>
 
 <!--  
 <ul>
     <a href="AdminSpritQOTIdentify.jsp"> Software Retirement  MockUp </a> 
     
 </ul>
-->
<br clear="all" />

<%= Footer.pageFooter(globals) %>
<!-- end -->
