<!--
.........................................................................
: DESCRIPTION:
: Search by Platform to generate report

: CREATION DATE:
: 12/31/07, sprit 6.10.1  CSCsj76625

: AUTHORS:
: @author Holly Chen (holchen@cisco.com)
:
: Copyright (c) 2007-2008, 2010 by Cisco Systems, Inc.
:.........................................................................
-->

<%@ page import="java.util.Date" %>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.model.dao.adminPlatformReport.AdminPlatformReportDAO"%>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="JavaScript" src="../js/cisromm.js"></script>
<script language="JavaScript" src="../js/prototype.js"></script>

<%
  //SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  //String pathGfx;
  //String userId;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  //pathGfx = globals.gs( "pathGfx" );
  //spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  //userId =  spritAccessManager.getUserId();
  //pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
%>
<%= SpritGUI.pageHeader( globals,"Sprit Admin Platform Report","" ) %>
<%= banner.render() %>



<span class="headline">
      Platform Report 
</span><br /><br />

<!--  
<span class="subHeadline">
    Options
</span><br />
-->
<center>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <!-- Left column -->
  <td valign="top" align="left">
    <table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td bgcolor="#808080"><img src="../gfx/b1x1.gif" width="12" height="1"></td>
  <td class="popupTitle">Platform Report</td>

  <td bgcolor="#808080"><img src="../gfx/b1x1.gif" width="12" height="1"></td>
  <td background="../gfx/wedge_gray.gif"><img src="../gfx/b1x1.gif" width="32" height="1" /></td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td bgcolor="#808080" colspan="5"><img src="../gfx/b1x1.gif" /></td>
</tr>
<tr>
  <td bgcolor="#808080"><img src="../gfx/b1x1.gif" /></td>
  <td bgcolor="#d9d9d9" colspan="3"><img src="../gfx/b1x1.gif" height="11" /></td>
  <td bgcolor="#808080"><img src="../gfx/b1x1.gif" /></td>

</tr>
<tr>
  <td bgcolor="#808080"><img src="../gfx/b1x1.gif" /></td>
  <td bgcolor="#d9d9d9"><img src="../gfx/b1x1.gif" /></td>
  <td class="popupData">
<table border="0" cellpadding="1" cellspacing="0">
<tr><td bgcolor="#3D127B">
  <table border="0" cellpadding="0" cellspacing="0">
  <tr><td bgcolor="#BBD1ED">
    <table border="0" cellpadding="3" cellspacing="1">
<tr bgcolor="#d9d9d9">

  <td><span class="dataTableTitle">Release</span></td>
  <td><span class="dataTableTitle">Image List</span></td>
  <td><span class="dataTableTitle">Upgrade Planner</span></td>
  <td><span class="dataTableTitle">Marker Matrix</span></td>
  <td><span class="dataTableTitle">DEM(Bom Structure)</span></td>
  <td><span class="dataTableTitle">Opus</span></td>
  <td><span class="dataTableTitle">CCO</span></td>
 
</tr>
<FORM name= "platformReportForm" method=POST action="AdminPlatformReport.jsp">
<%	String[]  selectedPlatforms = request.getParameterValues("platformSelect"); 
	if(selectedPlatforms!=null && selectedPlatforms.length > 0){
		for(int i=0;i< selectedPlatforms.length; i++){%>
		<input type="hidden" name="selectedPlatforms" value="<%=selectedPlatforms[i]%>"/>
<%	}} %>

<%	String[]  releaseMap = request.getParameterValues("releaseMap"); 
	if(releaseMap!=null && releaseMap.length > 0){
		for(int i=0;i< releaseMap.length; i++){%>
		<input type="hidden" name="releaseMap" value="<%=releaseMap[i]%>"/>
<%	}} %>

<%	String[]  releaseSelect = request.getParameterValues("releaseSelect"); 
	if(releaseSelect!=null && releaseSelect.length > 0){
		for(int i=0;i< releaseSelect.length; i++){%>
		<input type="hidden" name="releaseSelect" value="<%=releaseSelect[i]%>"/>
<%	}} %>

</FORM>

<% 	String  releaseNumberIdString = request.getParameter("releaseSelected");
   if(releaseNumberIdString.length()>0){
   		String [] releaseNumberIds = releaseNumberIdString.split(",");
   		for (int i=0; i<releaseNumberIds.length; i++){
	   		String releaseNumberId = releaseNumberIds[i];
	   		AdminPlatformReportDAO dao = (AdminPlatformReportDAO)SpringUtil.getApplicationContext().getBean("adminPlatformReportDAO");  //Spring JDBC 	 
            String releaseName = dao.getReleaseNameById(releaseNumberId);
     
%>

<tr bgcolor="#ffffff">
  <td><span class="dataTableData"><nobr><a href="ReleaseInfo.jsp?releaseNumberId=<%=releaseNumberId%>"><%=releaseName%></a></nobr></span></td>
  <td><span class="dataTableData"><a href="ImageList.jsp?releaseNumberId=<%=releaseNumberId %>">IL</a></span></td>
  <td><span class="dataTableData"><a href="UpgradePlanner.jsp?releaseNumberId=<%=releaseNumberId %>">UP</a>
  <td><span class="dataTableData"><a href="MarketMatrix.jsp?releaseNumberId=<%=releaseNumberId %>">MM</a>&nbsp;</span></td>
  <td><span class="dataTableData"><a href="DemSpecnoPartnoView.jsp?releaseNumberId=<%=releaseNumberId %>">DEM</a>&nbsp;</span></td>
  <td><span class="dataTableData"><a href="Opus.jsp?releaseNumberId=<%=releaseNumberId %>">Opus</a>&nbsp;</span></td>
  <td><span class="dataTableData"><a href="CsprIosCcoView.jsp?releaseNumberId=<%=releaseNumberId %>">CCO</a>&nbsp;</span></td>
</tr>
<%    }
   }	%>
</table>
</td></tr></table>
</td></tr>
</table>
</td></tr></table><br>
<br><center><table><tr><td><a href="javascript: document.platformReportForm.submit();">
	  		        <img src="../gfx/btn_back.gif" alt="Back" border="0"
	            	name="btnBack"></a></td></tr></table></center>

</center>
<%= Footer.pageFooter(globals) %>