<!--.........................................................................
: DESCRIPTION:
: Market Matrix page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
: @author Kelly M. (kellmill@cisco.com) Fix for CSCsg40246.
:
: Copyright (c) 2003-2007, 2010-2011 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>

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
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.MarketMatrixGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.dataobject.MarketMatrixInfo" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>

<%
  Context ctx;
  Integer releaseNumberId;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseNumberModelLocal rnmObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String jndiName;
  String pathGfx;
  String releaseNumber = null;
  Vector mmInfoords = new Vector();
  HashMap pcodeDups = new HashMap();
  String webParamsDefault;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  MarketMatrixInfo mmInfo;
  
  try {
    releaseNumberId = new Integer(
        WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  
  	MonitorUtil monUtil = new MonitorUtil();
    monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Market Matrix View");
  
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
  banner.addReleaseNumberElement( request,"releaseNumberId" ); //CSCsj36148
  //banner.addContextNavElement( "REL:", SpritGUI.renderReleaseNumberNav(globals,releaseNumber));
   try {
   mmInfoords = (Vector) MarketMatrixJdbc.getRecordsAll(releaseNumberId);   
   }catch(Exception e){}
   
   pcodeDups = (HashMap) MarketMatrixJdbc.getPcodeDups();
 
%>
<%= SpritGUI.pageHeader( globals,"Market Matrix","" ) %>
<%= banner.render() %>

<%= SpritReleaseTabs.getTabs(globals, "mm") %>


<%
  webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString()); 

  // String filterImageName = FilterUtil.getFilterParameter(request,"filtImgnm");
  // String filterProductSoftwareDesc = FilterUtil.getFilterParameter(request,"filtProdSoftdesc");

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

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  secNavBar.addFilters(
        "filtImgnm", filterImageName, 25,
        pathGfx+"/"+"filter_label_imgname.gif",
        "Sorry, no Help available.",
        "Image Name filter"
        );
  secNavBar.addFilters(
        "filtProdSoftdesc", filterProductSoftwareDesc, 25,
        pathGfx+"/"+"filter_label_sw_prod_desc.gif",
        "Sorry, no Help available.",
        "Software Product Description filter"
        );
 %>
 
  <table border="0" cellpadding="3" cellspacing="0">
    <tr bgcolor="#BBD1ED">
    	<td width="75%" valign="middle" align="left">
          <form action="<%=globals.gs("currentPage")%>" method="GET">
          <input type="hidden" name="releaseNumberId" value= 
            "<%=WebUtils.escHtml(releaseNumberId.toString())%>">
          <% try {
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"MM"),
            		true,
            		"MarketMatrix.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixEdit.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixReport.jsp?" + webParamsDefault + "&" + filterUrl
                		+ "&outputType=excel"
            		) ) );
             } catch (Exception e) {
			 	System.out.println("Exception"+ e);
			 }
           %>
        </form>


         </td>
         <td width="25%" valign="middle" align="right">
           <table>
             <tr>
                <td class="tabNavData">
                   <a href="pcodeGroupEdit.jsp?<%=webParamsDefault%>" id="tabNavLink"><nobr>Product Code Group Editor</nobr></a>
                </td>
              </tr>
              <tr>
                <td class="tabNavData">
                <center><strike>-----</strike></center>
                </td>
              </tr>
              <tr>
              	<td class="tabNavData">
              		<a href="ImageOrderableReport.jsp?releaseNumberId=<%=releaseNumberId %>" id="tabNavLink"><nobr>Image Orderable Report</nobr></a>
           		</td> 
           	  </tr>
           </table>
         </td>
         <td>
         </td>
      </tr>
   </table>


 <form name="MMTable">
 <center>
 <br>
 <%=MarketMatrixGUI.htmlSummarize(mmInfoords, pcodeDups)%>
 <br>

    <table cellspacing="0" cellpadding="2" border="1">
     <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Image Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Product Description</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Code</td>
         <!-- <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Price</td> -->
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Status</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Orderable</td>
          <!-- Orderable Instruction and Comments are not necessary in MM page - CSCtj24016 
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Orderable Instruction</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Orderable Comments</td> -->
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Flash</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">DRAM</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform Managers</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">PDT Contacts</td>

    </tr>
    <%
    Vector listOfMMInfo = FilterUtil.filterMMVector( 
    	mmInfoords, filterImageName, filterProductSoftwareDesc );
    String statusSpareColor = "#ffffff";
    String statusColor = "#ffffff";

    if( listOfMMInfo != null ) {
        Iterator iter = listOfMMInfo.iterator();
        while( iter.hasNext() ) {
	String errorMainColor = "#ffffff";
	String errorSpareColor = "#ffffff";
	String errorDescColor = "#ffffff";        
        mmInfo = (MarketMatrixInfo) iter.next();
        if(mmInfo.getPcodeMainStatus().equals("SPRIT")) 
        	statusColor = "#BBD1ED";
        else if(mmInfo.getPcodeMainStatus().equals("OPUS")) 
        	statusColor = "#a0ffa0";
        else if(mmInfo.getPcodeMainStatus().equals("ERP")) 
        	statusColor = "#ffffff";
   	
        if(mmInfo.getPcodeSpareStatus().equals("SPRIT")) 
        	statusSpareColor = "#BBD1ED";
        else if(mmInfo.getPcodeSpareStatus().equals("OPUS")) 
        	statusSpareColor = "#a0ffa0";
        else if(mmInfo.getPcodeSpareStatus().equals("ERP")) 
        	statusSpareColor = "#ffffff";     
        	
       if((mmInfo.getPcodeMain().indexOf("**") ) >= 0)
    	errorMainColor = "#ff0000";
       if(mmInfo.getPcodeMain().length() > 18)
    	errorMainColor = "#ff0000";
    	if(pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeMain()))
        	errorMainColor = "#ff0000"; 
       if((mmInfo.getPcodeSpare().indexOf("**") ) >= 0)
	errorSpareColor = "#ff0000";
       if(mmInfo.getPcodeSpare().length() > 18)
    	errorSpareColor = "#ff0000";
    	if(pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeSpare())) 
    	    errorSpareColor = "#ff0000";
       if((mmInfo.getProductDesc().indexOf("**") ) >= 0 )
        errorDescColor = "#ff0000";
       if (mmInfo.getProductDesc().length() > 60) 
        errorDescColor = "#ff0000";
     %>   
   
    <tr>
      <td class="dataTableData" valign="top" align="left" rowspan="2"><%= mmInfo.getPlatformList() %></td>
      <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><%= mmInfo.getImageName() %></nobr></td>
      
       <% if(0 <= ( mmInfo.getProductDesc().indexOf("****") ) &&  ( mmInfo.getProductDesc().indexOf("****") ) < 5) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorDescColor%> rowspan="2"><nobr><%= mmInfo.getProductDesc() %></nobr><br/>Error: Product Code Platform Description is empty</a></td>
       <% } else if((mmInfo.getProductDesc().indexOf("****") ) >= 5) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorDescColor%> rowspan="2"><nobr><%= mmInfo.getProductDesc() %></nobr><br/>Error: Feature Set Description is empty</a></td>
       <% } else if (mmInfo.getProductDesc().length() > 60) { %>
       	  <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorDescColor%> rowspan="2"><nobr><%= mmInfo.getProductDesc() %></nobr><br/>Error: Product Description is exceeding 60char limit</a></td>
       <% } else { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorDescColor%> rowspan="2"><nobr><%= mmInfo.getProductDesc() %></nobr></a></td>
       <% } %>    
      
       
       <% if((mmInfo.getPcodeMain().indexOf("****") ) == 1) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorMainColor%>><nobr><%= mmInfo.getPcodeMain() %></nobr><br/>Error: Product Code Platform Prefix is empty</a></td>
       <% } else if((mmInfo.getPcodeMain().indexOf("****") ) == 5) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorMainColor%>><nobr><%= mmInfo.getPcodeMain() %></nobr><br/>Error: Feature Set Designator is empty</a></td>
       <% } else if (mmInfo.getPcodeMain().length() > 18 || (pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeMain()))) { %>
       	  <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorMainColor%>><nobr><%= mmInfo.getPcodeMain() %></nobr>
       	  	  <% if( mmInfo.getPcodeMain().length() > 18 ) { %>
       	  		<br/>Error: Product Code is exceeding 18char limit
       	  	  <% } if (pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeMain())) { %>
       	  		<br/>Error: Product Code is duplicate</a></td>
       	  	  <% } %>
       <% } else { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorMainColor%>><nobr><%= mmInfo.getPcodeMain() %></nobr></a></td>
       <% } %>
     <!-- <td class="dataTableData" valign="top" align="right"><nobr><%= mmInfo.getPcodeMainPrice() %></nobr></td> -->
      
      <td class="dataTableData" valign="top" align="center" bgcolor=<%=statusColor%>><nobr><%= mmInfo.getPcodeMainStatus() %></nobr></td>
       <% if ( mmInfo.getPcodeMainOrderable() != null && ! "".equals(mmInfo.getPcodeMainOrderable()) ) { %>
      <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeMainOrderable() %></nobr></td>
      <% } else { %>
      <td class="dataTableData" align="center" valign="top">&nbsp;</td>
      <% } %> 
     <!-- <%   if ( mmInfo.getMainOrderableInstr() != null ) {%>
      <td class="dataTableData" valign="top" align="center" ><nobr><%= mmInfo.getOrderableInstrString(mmInfo.getMainOrderableInstr()) %></nobr></td>
      <% } else { %>
      <td align="center" valign="top">&nbsp;</td>
      <% }
         if ( mmInfo.getMainOrderableComment() != null && ! "".equals(mmInfo.getMainOrderableComment()) ) { %>
      <td class="dataTableData" valign="top" align="center" ><nobr>
      <textarea name="mainOrderableComment" rows=1 cols="30" READONLY><%=mmInfo.getMainOrderableComment()%></textarea></nobr></td>
      <% } else { %>
      <td align="center" valign="top">&nbsp;</td>
      <% } %>  -->
      <td class="dataTableData" valign="top" align="right" rowspan="2"><nobr><%= mmInfo.getMinFlash() %></nobr></td>
      <td class="dataTableData" valign="top" align="right" rowspan="2"><nobr><%= mmInfo.getMinDram() %></nobr></td>
      <% if ( ! "".equals(mmInfo.getProgramManagerList()) ) { %>
      <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><%= mmInfo.getProgramManagerList()%></nobr></td>
      <% } else { %>
      <td align="center" valign="top" rowspan="2">&nbsp;</td>
      <% }
         if ( ! "".equals(mmInfo.getPDTContactList()) ) { %>
      <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><%= mmInfo.getPDTContactList()%></nobr></td>
      <% } else { %>
      <td align="center" valign="top" rowspan="2">&nbsp;</td>
      <% } %>

 
    </tr>
  
   <%
     Boolean displaySpareInfo = Boolean.FALSE;

     if ( ! mmInfo.getPcodeSpareStatus().equals("SPRIT") ) {

        if ( mmInfo.getPcodePrefixSpare() != null ) {
           displaySpareInfo = Boolean.TRUE;
        }

     } else {

        if ( mmInfo.getEndOfSpare().equals("N") &&
          mmInfo.getPcodePrefixSpare() != null ) {
           displaySpareInfo = Boolean.TRUE;
        }
     }

     if ( displaySpareInfo == Boolean.TRUE ) {
    %>
    <tr>
       <% if((mmInfo.getPcodeSpare().indexOf("****") ) == 1) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorSpareColor%>><nobr><%= mmInfo.getPcodeSpare() %></nobr><br/>Error: Product Code Platform Prefix is empty</a></td>
       <% } else if((mmInfo.getPcodeSpare().indexOf("****") ) == 5) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorSpareColor%>><nobr><%= mmInfo.getPcodeSpare() %></nobr><br/>Error: Feature Set Designator is empty</a></td>
       <% } else if (mmInfo.getPcodeSpare().length() > 18 || (pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeSpare()))) { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorSpareColor%>><nobr><%= mmInfo.getPcodeSpare() %></nobr>
          	  <% if( mmInfo.getPcodeSpare().length() > 18 ) { %>
       	  		<br/>Error: Product Code is exceeding 18char limit
       	  	  <% } if (pcodeDups != null && pcodeDups.containsKey(mmInfo.getPcodeSpare())) { %>
       	  		<br/>Error: Product Code is duplicate</a></td>
       	  	  <% } %>
       <% } else { %>
          <td class="dataTableData" valign="top" align="left" bgcolor=<%=errorSpareColor%>><nobr><%= mmInfo.getPcodeSpare() %></nobr></a></td>
       <% } %>    
      <!-- <td class="dataTableData" valign="top" align="right"><nobr><%= mmInfo.getPcodeSparePrice() %></nobr></td> -->
      <td class="dataTableData" valign="top" align="center" bgcolor=<%=statusSpareColor%>><nobr><%= mmInfo.getPcodeSpareStatus() %></nobr></td>
      <% if ( mmInfo.getPcodeSpareOrderable() != null && ! "".equals(mmInfo.getPcodeSpareOrderable()) ) { %>
      <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeSpareOrderable() %></nobr></td>
      <% } else { %>
      <td valign="top" align="center">&nbsp;</td>
      <% } %>
     <!-- <%   if ( mmInfo.getSpareOrderableInstr() != null ) {
      %>
      <td class="dataTableData" valign="top" align="center" ><nobr><%= mmInfo.getOrderableInstrString(mmInfo.getSpareOrderableInstr()) %></nobr></td>
      <% } else { %>
      <td valign="top" align="center">&nbsp;</td>
      <% }
         if ( mmInfo.getSpareOrderableComment() != null && ! "".equals(mmInfo.getSpareOrderableComment()) ) { %>
      <td class="dataTableData" valign="top" align="center" ><nobr>
      <textarea name="spareOrderableComment" rows=1 cols="30" READONLY><%=mmInfo.getSpareOrderableComment()%></textarea></nobr></td>
      <% } else { %>
      <td valign="top" align="center">&nbsp;</td>
      <% } %>-->
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

</form>
  

<%= Footer.pageFooter(globals) %>
<!-- end -->
