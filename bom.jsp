<!--.........................................................................
: DESCRIPTION:
: BOM data.
:
: AUTHORS:
: @author rruddara (rruddara@cisco.com)
:
: Copyright (c) 2003-2004, 2010 by Cisco Systems, Inc.
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
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.dataobject.OpusInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.BOMCacheData" %>

<%
  Integer 						releaseNumberId;
  SpritAccessManager 			spritAccessManager;
  SpritGlobalInfo 				globals;
  SpritGUIBanner 				banner;
  String 						pathGfx;
  String 						releaseNumber = null;
  TableMaker 					tableReleasesYouOwn; 
  Vector 						opusRecords;
  Vector 						bomRecords;
  CisrommAPI 					cisrommAPI;
  String						htmlNoValue;

  
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  OpusInfo opusInfo;
  BOMCacheData bomInfo;
 
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
    String jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    InitialContext ctx = new InitialContext();
    ReleaseNumberModelHomeLocal rnmHome = 
    	(ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    ReleaseNumberModelLocal rnmObj = rnmHome.create();
    ReleaseNumberModelInfo rnmInfo = 
    	rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();
  } catch( Exception e ) {
    throw e;
  }  // catch  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber)
   );

  opusRecords = (Vector)session.getAttribute("OpusData");
  bomRecords = (Vector)session.getAttribute("bomData");  
  
 //html macros
 htmlNoValue = "<span class=\"noData\">---</span>";
%>

<%= SpritGUI.pageHeader( globals,"Market Matrix","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getTabs(globals, "tool") %>

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
          	OPUS Release Submission Status Check
          	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          	</b></font></span></td>
         </tr>
         <tr>
          <td align="center"><span class="dataTableData"><font size="2"><b>
          	Release: <%=releaseNumber%>
          	</b></font></span></td>
         </tr>
        </table>
      </td>
      </tr>
      </table>
    </td>
    </tr>
    </table>
    <br><br>

<%
    String servletMessages = (String)
  	request.getAttribute( "errorMessage" );
    if( servletMessages != null ) {
%>
        <%=servletMessages%>
        <br/><br/>
<%
    }  // if( servletMessages!=null )
%>


        <table cellspacing="0" cellpadding="" border="0">
         <tr bgcolor="#BBD1ED">
          <td align="center"><span class="dataTableData"><font size="2"><b>
          	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          	Cache OPUS Data
          	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </td>
         </tr>
        </table>
   <br>
   <table cellspacing="0" cellpadding="2" border="1">
    <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Seq No</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Description</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">First Order</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">FCS Date</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Price</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Availability</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">DRAM</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Flash</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Image</td> 
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform Product Family</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Item Type</td>          
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Boot Image</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Version</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Encryption</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Stat</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Date</td>
    </tr>
    <%
    if( opusRecords!=null ) {
        Iterator iter = opusRecords.iterator();
        int imageTotal = opusRecords.size();
        while( iter.hasNext() ) {
        opusInfo = (OpusInfo) iter.next();
     %>   
   
    <tr bgcolor="#ffffff">  
      <td class="dataTableData" valign="top" align="left" ><font size="1"><%= opusInfo.getRecordId() %></font></td>
      <td class="dataTableData" valign="top" align="left"><nobr><font size="1"><%= opusInfo.getPcodeName() %></font></nobr></a></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= opusInfo.getPcodeDesc() %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= opusInfo.getFirstOrderDate()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= opusInfo.getFcsDate()  %></font></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1"><%= opusInfo.getPcodePrice() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1"><%= opusInfo.getAvailability() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1"><%= opusInfo.getMinDram() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1"><%= opusInfo.getMinFlash() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="left" ><nobr><font size="1"><%= opusInfo.getImageName() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="center"><nobr><font size="1">
              <%= StringUtils.nvl(opusInfo.getPlatformProductFamily(),htmlNoValue) %></font></nobr></td>      
      <td class="dataTableData" valign="top" align="right"><nobr><font size="1"><%= opusInfo.getItemType() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="center"><nobr><font size="1">
	                <%= StringUtils.nvl(opusInfo.getBootImage(),htmlNoValue) %></nobr></td>      
      <td class="dataTableData" valign="top" align="left" ><nobr><font size="1"><%= opusInfo.getReleaseString() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="center" ><nobr><font size="1"><%= opusInfo.getEncryptionValue() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="center" ><nobr><font size="1"><%= opusInfo.getProcessStatus() %></font></nobr></td>
      <td class="dataTableData" valign="top" align="center" ><nobr><font size="1"><%= opusInfo.getProcessDate() %></font></nobr></td>
    </tr>
    <%
    
       }  // while( iter2.hasNext() )
    }

    %>
</table><br />

<br /><br />
        <table cellspacing="0" cellpadding="0" border="0">
         <tr bgcolor="#BBD1ED">
          <td align="center"><span class="dataTableData"><font size="2"><b>
          	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          	Cache BOM Data
          	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </td>
         </tr>
        </table>
        <br>

    <table cellspacing="0" cellpadding="2" border="1">
    <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Seq No</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Version</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Comp. Seq</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Component</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Qty</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Status</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Process Date</td>
    </tr>
    <%
    if( bomRecords !=null ) {
        Iterator iter = bomRecords.iterator();
        while( iter.hasNext() ) {
        	bomInfo = (BOMCacheData) iter.next();
     %>   
    <tr  bgcolor="#ffffff">  
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getCacheSeq() %></font></td>
      <td class="dataTableData" valign="top" align="left"><nobr><font size="1"><%= bomInfo.getProductName() %></font></nobr></a></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getVersion() %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getComponentSeq()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getComponent()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getQuantity()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getProcessStatus()  %></font></td>
      <td class="dataTableData" valign="top" align="left"><font size="1"><%= bomInfo.getProcessDate()  %></font></td>
    </tr>
    <%
    
       }  // while( iter.hasNext() )
    }
    %>
    
	</table>

<br /><br />
</center>
</form>
  

<%= Footer.pageFooter(globals) %>
<!-- end -->
