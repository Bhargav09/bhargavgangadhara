<!--.........................................................................
: DESCRIPTION:
: It allows PMs to send email to IRE team If any of the
: images are missing in archive directory.
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.*" %>
<%@ page import="" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.util.DateUtil" %>

<%
  Context                       ctx;
  Integer                       releaseNumberId;
  ReleaseNumberModelHomeLocal   rnmHome;
  ReleaseNumberModelInfo        rnmInfo;
  ReleaseNumberModelLocal       rnmObj;

  SpritAccessManager            spritAccessManager;
  SpritGlobalInfo               globals;
  SpritGUIBanner                banner;
  String                        jndiName;
  String                        pathGfx;
  String                        releaseNumber = null;

  String                        htmlNoValue;
  String                        osType = null;
  DateUtil                      dateUtil = new DateUtil();

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;

  try {
     releaseNumberId = new Integer( WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }

  // Get release number information.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ejblocal:ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup(jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();
    osType = rnmInfo.getOsType();

  } catch( Exception e ) {
    throw e;
  }  // catch

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber,osType)
   );

   Vector list = (Vector) session.getAttribute("missingImages");
   if(list == null || list.size() == 0) {
       response.sendRedirect("/web/jsp/IosCcoView.jsp?releaseNumberId="
               + rnmInfo.getReleaseNumberId());
       return;
   }

 //html macros
 htmlNoValue = "<span class=\"noData\"><center>---</center></span>";
 String htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit1",
      "Submit",
      "javascript:submitButton()",
      pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
      "actionBtnSubmit('btnSubmit1', '" + SpritConstants.GFX_BTN_SUBMIT + "')",
      "actionBtnSubmitOver('btnSubmit1', '" + SpritConstants.GFX_BTN_SUBMIT_OVER + "')"
      );
%>

<script language="javascript"> <!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
  function actionBtnSubmit(elemName, imagename) {
    if( document.forms['ireForm'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }
  function actionBtnSubmitOver(elemName, imagename) {
    if( document.forms['ireForm'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }

  function submitButton() {
      var formObj = document.forms['ireForm'];
      var buildEnggId = formObj.buildEnggId.value;
      if( buildEnggId == '') {
         alert( "Please enter build engineer id" );
         return false;
      }

      var elements = formObj.elements;

      if( elements['_submitformflag'].value==0 ) {
           elements['_submitformflag'].value=1;
           formObj.submit();
      }
  }
-->
</script>

<%= SpritGUI.pageHeader( globals,"CCO","" ) %>
<%= banner.render() %>

<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
%>

  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" width="70%" align="left">
          <%
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render(
          		new boolean [] { true,
                                 true,
                                 ( spritAccessManager.isAdminSprit() ||
                                     spritAccessManager.isAdminCco()) ? true : false,
                                 true},
          		new String [] { "View", "Post", "Repost", "Report" },
          		new String [] { "IosCcoView.jsp?releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Edit&releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Repost&releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Report&releaseNumberId=" + releaseNumberId}
            		        ) ) );

           %>
         </td>
    	<td valign="middle" width="30%" align="left">
          <%
            if(spritAccessManager.isAdminSprit() ||
                 spritAccessManager.isAdminCco()) {
            out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render(
          		new boolean [] { true },
          		new String [] { "UPopulation" },
          		new String [] { "UPopulation.jsp?releaseNumberId=" + releaseNumberId},
                      false
            		        ) ) );
            }
           %>
         </td>
      </tr>
   </table>


<form method="POST" name="ireForm" action="IosCcoProcessor?releaseNumberId="<%=releaseNumberId%>">
<input type="hidden" name="ireEmail" value="Yes"/>
<input type="hidden" name="_submitformflag" value="0" />
    <table>
    <center>
    <br>
     <br>
      <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
            <td colspan="2" align="center" valign="top">
              <font size="+1" face="Arial,Helvetica"><b>
                 Email to IRE Team: <%=rnmInfo.getFullReleaseNumber()%>
                </b></font></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Build Engineer Id:</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <input type="text" name="buildEnggId" value=""/></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Images missing from the Archive.</span></td>
            <td align="left" valign="top"><span class="dataTableData">
<%
    Enumeration enum = list.elements();
    while(enum.hasMoreElements()) {
%>
        <%=enum.nextElement()%><br>
<%
    }
%>
              </span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Comments:</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <textarea type="TextArea" name="comments" rows=4 cols="50"></textarea></span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </center></table>
</form>
<br><center><%=htmlButtonSubmit1%></center>

<%= Footer.pageFooter(globals) %>
<!-- end -->
