<!--.........................................................................
: DESCRIPTION:
: CCO Post.
:
: AUTHORS:
: @author Raju (rruddara@cisco.com)
:
: Copyright (c) 2004 by Cisco Systems, Inc.
:.........................................................................-->
<%@ page import="java.util.Properties,
                 com.cisco.eit.sprit.model.cco.UPopulation,
                 java.io.PrintWriter,
                 com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo,
                 com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal,
                 com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal,
                 com.cisco.eit.sprit.dataobject.UPopulationInfo,
                 com.cisco.eit.sprit.model.cco.UPopulationUtil,
                 java.sql.Connection,
                 com.cisco.eit.sprit.util.*,
                 com.cisco.eit.sprit.ui.SpritSecondaryNavBar,
                 com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModel" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="javax.naming.InitialContext"%>

<%@ page import="com.cisco.eit.sprit.model.pcodegroup.*" %>
<%@ page import="java.util.*" %>

<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  ReleaseNumberModelInfo rnmInfo =
          (ReleaseNumberModelInfo) request.getAttribute("rnmInfo");
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addReleaseNumberElement( rnmInfo.getReleaseNumberId() );

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  Integer releaseNumberId = rnmInfo.getReleaseNumberId();

  String webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());
%>

<%= SpritGUI.pageHeader( globals,"cco","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getTabs(globals, "cco") %>
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" width="70%" align="left">
          <%
             out.println( SpritGUI.renderTabContextNav( globals,
          	 secNavBar.render(
         		new boolean [] { true, true, true, true },
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
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render(
          		new boolean [] { false },
          		new String [] { "UPopulation" },
          		new String [] { "UPopulation.jsp?" + webParamsDefault },
                      false
            		        ) ) );
           %>
         </td>
      </tr>
   </table>

<%
  // Get release number information.

    Vector listOfHeader = (Vector) session.getAttribute("UpopHeader");
    Vector listOfUpopInfo = (Vector) session.getAttribute("UpopBody");
    String strErrorMessage = (String) session.getAttribute("ErrorMessage");
    String htmlNoValue = "<span class=\"noData\"><center>&nbsp;</center></span>";
%>

<%
    if( strErrorMessage != null ) {
%>
   <br><br><br><center>
   <%=SpritGUI.renderErrorBox(
                            globals, "Error!!!",
                                strErrorMessage)%>
<%--
   <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
        <table cellspacing="0" cellpadding="0" border="0">
         <tr>
          <td align="left"><span class="dataTableData"><font size="2"><b>
            <%=strErrorMessage%>
            </b></font></span></td>
         </tr>
        </table>
      </td></tr>
      </table>
   </td></tr>
   </table></center>
--%>

<%
    }
%>
   <br><br><br><center>
   <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
        <table cellspacing="0" cellpadding="0" border="0">
         <tr>
          <td align="center"><span class="dataTableData"><font size="2"><b>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            UPopulation
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </b></font></span></td>
         </tr>
        </table>
      </td>
      </tr>
      </table>
    </td>
    </tr>
    </table>
    <br/><br/><br/>

   <table cellspacing="0" cellpadding="2" border="1">
     <tr>
<%--          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">File Status</td>--%>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Release Id</td>
<%--          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Category</td>--%>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Status</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">FCS Date</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Obsolete Date</td>
     </tr>
     <tr bgcolor="#ffffff">
<%--       <td class="dataTableData" valign="top" align="left" ><nobr><font size="1"><%= listOfHeader.get(0) %></font></nobr></td>--%>
       <td class="dataTableData" valign="top" align="left" ><nobr><font size="1"><%= listOfHeader.get(0) %></font></nobr></td>
<%--       <td class="dataTableData" valign="top" align="left"><nobr><font size="1"><%= listOfHeader.get(2) %></font></nobr></a></td>--%>
       <td class="dataTableData" valign="top" align="left"><font size="1">
            <%=SpritUtility.nvlORempty( (String) listOfHeader.get(1), htmlNoValue)%></font></td>
       <td class="dataTableData" valign="top" align="left"><nobr><font size="1">
            <%=SpritUtility.nvlORempty( (String) listOfHeader.get(2), htmlNoValue)%></font></nobr></td>
       <td class="dataTableData" valign="top" align="left"><nobr><font size="1">
            <%=SpritUtility.nvlORempty( (String) listOfHeader.get(3), htmlNoValue)%></font></nobr></td>
     </tr>
   </table>
   <br/><br/><br/>
   <table cellspacing="0" cellpadding="2" border="1">
     <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">File Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Image Prefix</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Id</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Crypto Flag</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">RAM</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">ROM</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Advisory</td>
     </tr>
    <%
       Iterator iter = listOfUpopInfo.iterator();
       UPopulationInfo uPopulationInfo;

       while( iter.hasNext() ) {
          uPopulationInfo = (UPopulationInfo) iter.next();
          if( uPopulationInfo.getIsImageCheckFailed() )
              continue;                           
     %>

    <tr bgcolor="#ffffff">
      <td class="dataTableData" valign="top" align="left" ><nobr><font size="1">
           <%=uPopulationInfo.getCccoImage() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="left" ><nobr><font size="1">
           <%=uPopulationInfo.getPlatformName() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="left"><nobr><font size="1">
           <%= uPopulationInfo.getPlatformId() %></font></nobr></a></td>
      <td class="dataTableData" valign="top" align="left"><font size="1">
           <%= uPopulationInfo.getSoftwareName() %></font></td>
      <td class="dataTableData" valign="top" align="left"><nobr><font size="1">
           <%= uPopulationInfo.getSoftwareId() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1">
           <%= uPopulationInfo.getCryptValue() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1">
           <%= uPopulationInfo.getRAM() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1">
           <%= uPopulationInfo.getROM() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="left" ><nobr><font size="1">
           <%= SpritUtility.nvlORempty(uPopulationInfo.getDefer(),htmlNoValue) %></font></nobr></td>
    </tr>
    <%

       }  // while( iter2.hasNext() )
    %>
    </center>
</table><br />


<%= Footer.pageFooter(globals) %>
<!-- end -->
