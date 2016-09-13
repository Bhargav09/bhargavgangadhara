<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004-2006, 2008, 2010, 2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.BOMData" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumberHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumber" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.dataobject.BOMCacheData" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

<%
  String thisFile = "BomView.jsp";
  
  Integer           releaseNumberId;
  SpritAccessManager        spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  String            pathGfx;
  String            releaseNumber = null;
  TableMaker            tableReleasesYouOwn; 
  Vector            opusRecords = new Vector();
  CisrommAPI            cisrommAPI;
  String            htmlNoValue;
  String            osType = null;
  
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  BOMCacheData bomInfo;
  
    MonitorUtil monUtil = new MonitorUtil();
    monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "BOM View");

 
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
  try {
    // Setup
	ReleaseNumberHelper releaseNumberHelper = new ReleaseNumberHelper();
	ReleaseNumber objReleaseNumber = releaseNumberHelper.getReleaseNumber(releaseNumberId);	  
	releaseNumber = objReleaseNumber.getReleaseNumber();
    osType = objReleaseNumber.getOsTypeName();
  } catch( Exception e ) {
    throw e;
  }  // catch  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  //System.out.println("Inside " + thisFile + " ostype " + osType + " " +releaseNumber );
  if(SpritUtility.isOsTypeIosIoxCatos(osType)){
  banner.addContextNavElement( "REL:",
	      SpritGUI.renderReleaseNumberNav(globals,releaseNumber,osType)
	   );
  }else{
	    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
	    		SpritGUI.renderOSTypeNav(globals,osType,releaseNumber,"op",WebUtils.getParameter(request,"osTypeId"),releaseNumberId.toString())
	    );
  }
  
   try {
       cisrommAPI = new CisrommAPI();
     } catch( Exception e ) {
       throw e;
     }  // try
  
 //html macros
 htmlNoValue = "<span class=\"noData\"><center>---</center></span>";

%>
<script>
function changeSoftwareType() {
    document.bomViewSoftwareSelection.submit();
  }
</script>
<form name="bomViewSoftwareSelection" method="post" action="SoftwareSearchProcessor">
<%--digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie 
= SpritGUI.pageHeader( globals,"Opus View","" ) --%>
<%= SpritGUI.pageHeader( globals,"eGenie View","" ) %>
<%= banner.render() %>
<input name="from" value="bomView" type="hidden">
</form>
<!--digarg : rally(US10040) Name change in sprit tab. OPUS -->
<% if( "IOS".equalsIgnoreCase( osType )) { %>
	<%= SpritReleaseTabs.getTabs(globals, "eGenie") %> <!-- digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie -->
<% } else if("IOX".equalsIgnoreCase( osType )){ %>
	<%= SpritReleaseTabs.getNonIosTabs(globals, "eGenie") %> <!--  digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie -->
<% }else {%>
	<%= SpritReleaseTabs.getOSTypeTabs(globals, "eGenie")%> <!-- digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie -->
<% }%>


<%
  String webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString())
        +"&osTypeId=" + WebUtils.getParameter(request,"osTypeId"); 


//  String filterProdName = StringUtils.elimSpaces( WebUtils.getParameter(request,"filterProdName") );

//  if ( filterProdName == null || "".equals( filterProdName ) )
//      filterProdName = "*";

//  String filterUrl = ""
//        + "filterProdName=" + WebUtils.escUrl( filterProdName );

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
//  secNavBar.addFilters(
//        "filterProdName", filterProdName, 12,
//        null,
//        "Sorry, no Help available.",
//        "Product Name filter"
//        );
 %>
 
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
      <td>
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
            secNavBar.render( 
                new boolean [] { true, false, true },
                new String [] { "[eGenie Status]", "[Bom Status]", "[eGenie Submit]" },//digarg : rally(US10040) Name change in sprit tab. OPUS to eGenie
                new String [] { "OpusView.jsp?" + webParamsDefault,
                                    "BomView.jsp?" + webParamsDefault,
                                    "Opus.jsp?" + webParamsDefault }
                            ) ) );
           %>
      </td>
     </tr>
     <tr bgcolor="#BBD1ED">
     <td><br/></td>
     </tr>
   </table>


<%

   Vector listBomRecords = BOMData.getCacheBOMData(releaseNumber, osType);
   if( listBomRecords.size() == 0 ) {
%>
             <center><br/><br/><br/><br/><br/><br/>
               <table cellspacing="0" cellpadding="3" border="1">
             <tr bgcolor="#d9d9d9">
               <td align="center"><span class="dataTableData">
                  You are in <b>VIEW BOM STATUS</b> mode <BR>
                  There are no BOM records submitted for this release - <b>
                <%=releaseNumber%></b></span></td>
             </tr>
               </table>
              </center>
<%
    } else {
%>

   <br/><br/><br/><center>

        <table cellspacing="0" cellpadding="0" border="0">
         <tr bgcolor="#BBD1ED">
          <td align="center"><span class="dataTableData"><font size="2"><b>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Cache BOM Data
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </td>
         </tr>
        </table>
        <br/>

    <table cellspacing="0" cellpadding="2" border="1">
    <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Status</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Date</td>
      <!--<td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Seq No</td>-->
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Version</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Comp. Seq</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Component</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Qty</td>
    </tr>
    <%
//    listBomRecords = FilterUtil.filterBomVector( listBomRecords, filterProdName );
    if( listBomRecords !=null ) {
        Iterator iter = listBomRecords.iterator();
        while( iter.hasNext() ) {
            bomInfo = (BOMCacheData) iter.next();
     %>   
    <tr  bgcolor="#ffffff">  
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getProcessStatus()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getProcessDate()  %></font></td>
  <!--<td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getCacheSeq() %></font></td>-->
      <td class="dataTableData" valign="top" align="left"><nobr><font size="1"><%= bomInfo.getProductName() %></font></nobr></a></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getVersion() %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getComponentSeq()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getComponent()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getQuantity()  %></font></td>
    </tr>
    <%
    
       }  // while( iter.hasNext() )
    }
    %>
    </center>
   </table>
<br/>

<%
   } // end of else
%>


<%= Footer.pageFooter(globals) %>
<!-- end -->
