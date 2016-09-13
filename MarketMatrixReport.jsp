<!--.........................................................................
: DESCRIPTION:
: Market Matrix page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2003-2006 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.marketmatrix.MarketMatrixJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.dataobject.MarketMatrixInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>


<%
  Context ctx;
  SpritAccessManager  spritAccessManager;
  Integer releaseNumberId;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseNumberModelLocal rnmObj;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String jndiName;
  String pathGfx;
  String releaseNumber = null;
  TableMaker tableReleasesYouOwn; 
  Vector mmRecords = new Vector();
  String htmlButtonDeleteChecked1 = "";
  String htmlButtonDeleteChecked2 = "";
  String htmlButtonSaveUpdates1 = "";
  String htmlButtonSaveUpdates2 = "";
  String webParamsDefault;
  response.setContentType("application/vnd.ms-excel");
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  	MonitorUtil monUtil = new MonitorUtil();
    	monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Market Matrix Report");

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  MarketMatrixInfo mmInfo;
  
  try {
    releaseNumberId = new Integer(
        WebUtils.getParameter(request,"releaseNumberId"));
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
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();
  } catch( Exception e ) {
    throw e;
  }  // catch  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber)
   );
   try {
   mmRecords = (Vector) MarketMatrixJdbc.getRecordsAll(releaseNumberId);   
   }catch(Exception e){}

  String filterImageName = StringUtils.elimSpaces( WebUtils.getParameter(request,"filtImgnm") );
  String filterProductSoftwareDesc = StringUtils.elimSpaces( 
  	WebUtils.getParameter(request,"filtProdSoftdesc") );
  if ( filterImageName == null || "".equals( filterImageName ) )
  	filterImageName = "*";
  if ( filterProductSoftwareDesc == null || "".equals( filterProductSoftwareDesc ) )
  	filterProductSoftwareDesc = "*";

  String filterUrl = ""
        + "filtProdSoftdesc=" + WebUtils.escUrl( filterProductSoftwareDesc )
        + "&filtImgnm=" + WebUtils.escUrl( filterImageName );
%>
<%
  webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());
        
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );

// Make sure we can see this page.  If not then send them to view
// mode!
/*if( !spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"MM") ) {
  response.sendRedirect( ""
      + "MarketMatrix.jsp?releaseNumberId=" 
      + WebUtils.escUrl(releaseNumberId.toString())
      );
}  // if( !spritAccessManager.isMilestoneOnwer() )
// removed by rnevitt to allow access to all userse */

%>

  <center>
     <table cellspacing="0" cellpadding="2" border="1">
      <tr>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Image Name</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Product Description</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Code</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Price</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Status</td>
	   <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Orderable</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Flash</td>
           <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">DRAM</td>
     </tr>
     <%
      Vector listOfMMInfo = FilterUtil.filterMMVector( 
    	mmRecords, filterImageName, filterProductSoftwareDesc );

      if( listOfMMInfo != null ) {
	Iterator iter = listOfMMInfo.iterator();
	int imageTotal = mmRecords.size();
	while( iter.hasNext() ) {
	mmInfo = (MarketMatrixInfo) iter.next();

      %>   
    
     <tr>
       <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><%= mmInfo.getPlatformList() %></nobr></td>
       <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><%= mmInfo.getImageName() %></nobr></td>
       <td class="dataTableData" valign="top" align="left" bgcolor="#ffffff" rowspan="2"><%= mmInfo.getProductDesc() %></td>
       <td class="dataTableData" valign="top" align="left" bgcolor="#ffffff"><nobr><%= mmInfo.getPcodeMain() %></nobr></a></td>
       <td class="dataTableData" valign="top" align="right"><nobr><%= mmInfo.getPcodeMainPrice() %></nobr></td>
       <td class="dataTableData" valign="top" align="center" bgcolor="#ffffff"><nobr><%= mmInfo.getPcodeMainStatus() %></nobr></td>
       <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeMainOrderable() %></nobr></td>
       <td class="dataTableData" valign="top" align="right" rowspan="2"><nobr><%= mmInfo.getMinFlash() %></nobr></td>
       <td class="dataTableData" valign="top" align="right" rowspan="2"><nobr><%= mmInfo.getMinDram() %></nobr></td>
     </tr>
   
     <%  if(mmInfo.getPcodePrefixSpare()!= null){
     %>
     <tr>
           <td class="dataTableData" valign="top" align="left" bgcolor="#ffffff"><nobr><%= mmInfo.getPcodeSpare() %></nobr></a></td>
           <td class="dataTableData" valign="top" align="right"><nobr><%= mmInfo.getPcodeSparePrice() %></nobr></td>
       <td class="dataTableData" valign="top" align="center" bgcolor="#ffffff"><nobr><%= mmInfo.getPcodeSpareStatus() %></nobr></td>
             <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeSpareOrderable() %></nobr></td>
     </tr>
     <%
     }//if(mmInfo.getPcodePrefixSpare()!= null)
     else {%>
     
     <tr></tr>
     
     <%
     }
     }  // while( iter2.hasNext() )
     }
 
     %>
 </table><br />
 </center>
 
 
  
<!-- end -->
