<!--.........................................................................
: DESCRIPTION:
: Market Matrix Add records that gets shown in a pop-up.
:
: AUTHORS:
: 
: @author Selvaraj Aran (aselvara@cisco.com)
:
: Copyright (c) 2003, 2004 by Cisco Systems, Inc.
:.........................................................................-->

<script language="javascript"><!--
 
 function validateAndSubmitForm(formName) {
   var formObj;
   var errormsg = "Choose at least one Image to be added and click Add Images.";
   var error = true;
   formObj = document.forms[formName];
   elements = formObj.elements;
   
   //alert(document.forms[formName]);
   
   //formObj.submit();
   //validating the fields to make sure atleast one images is marked delete
   for (i =0; i<formObj.imageFeatureSetIndex.value; i++) {
     var imageRecordAdd = "_"+i+"_select";
      if(formObj.elements[imageRecordAdd].checked == true) {
        error = false;

         if( elements['_submitFormFlag'].value=="1" ) {
           return;
         }  // if( elements['_submitFormFlag'].value=="1" )
         elements['_submitFormFlag'].value="1";

         formObj.submit();
      
      }  // if    
   }  // for
   if(error)
     alert(errormsg);
  } 
//--></script>

<!-- SPRIT -->
<%@ page import="javax.naming.Context" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.rmi.PortableRemoteObject" %>

<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>

<%@ page import="com.cisco.eit.sprit.dataobject.ImageNameInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.marketmatrix.MarketMatrixJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.AddMarketMatrixRecordInfo" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.util.ImageDbUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>


<%
  // Initialize globals  
  Context ctx;
  Integer releaseNumberId = null;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo = null;
  ReleaseNumberModelLocal rnmObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  String htmlButtonAddImages1 = "";
  String htmlButtonAddImages2 = "";
  String jndiName;
  String pathGfx;
  String releaseNumber = null;
  String			htmlNoValue;
  String             userId ="";
  
  //html macros
  htmlNoValue = "<span class=\"noData\">---</span>";
 
  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
  userId=spritAccessManager.getUserId();

  // Get release number information.
  releaseNumberId = new Integer(WebUtils.getParameter(request,"releaseNumberId"));
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

  // Deny access.  Send to error page.
  //if( !spritAccessManager.isMilestoneOwner(releaseNumber,"UP") ) { 
  //  response.sendRedirect( "ErrorAccessPermissions.jsp" );
  //}  // if( !spritAccessManager.isMilestoneOnwer() )
%>  
 
 
<%= SpritGUI.pageHeader( globals,"SPRIT - Market Matrix","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","SPRIT - Market Matrix" ) %>


<%
String releaseId = request.getParameter("releaseNumberId");
//HTML Macros
htmlButtonAddImages1 = SpritGUI.renderButtonRollover(
	globals,
	"btnAddImages1",
	"Add Images",
	"javascript:validateAndSubmitForm('mmAdd')",
	pathGfx + "/" + "btn_image_add.gif",
	"setImg('btnAddImages1','" + pathGfx + "/" + "btn_image_add.gif" + "')",
	"setImg('btnAddImages1','" + pathGfx + "/" + "btn_image_add_over.gif" + "')"
	);
htmlButtonAddImages2 = SpritGUI.renderButtonRollover(
        globals,
        "btnAddImages2",
        "Add Images",
        "javascript:validateAndSubmitForm('mmAdd')",
        pathGfx + "/" + "btn_image_add.gif",
        "setImg('btnAddImages2','" + pathGfx + "/" + "btn_image_add.gif" + "')",
        "setImg('btnAddImages2','" + pathGfx + "/" + "btn_image_add_over.gif" + "')"
        );
 %>
 
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  
<form action="MMProcessor" method="post" name="mmAdd">
<input type="hidden" name="_submitFormFlag" value="0" />
<input type="hidden" name="callingForm" value="mmAdd">
<input type="hidden" name="releaseNumberId" value="<%=releaseId%>" />
<center>
   <table>
   <tr>
   <td></td>
   <td>
        Select Images to be saved into Market Matrix
   </td>
     </tr>
   <table>
   <table>
     <tr> 
     <td>
       <%= htmlButtonAddImages1 %>
     </td>
     </tr>	   
    </table>
  <br /><br />

<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td valign="top">

    <table border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#d9d9d9">
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Select<br />
        <a href="javascript:checkboxSelectAll('mmAdd','_select')"><img src="../gfx/btn_all_mini.gif" border="0" /></a><br />
        <a href="javascript:checkboxSelectNone('mmAdd','_select')"><img src="../gfx/btn_none_mini.gif" border="0" /></a><br />
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Image Name
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Platform
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Product Code Group
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Feature Set Description
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        Feature Set Designator
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        MinFlash
      </span></td>
      <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
        MinDram
      </span></td>
    </tr>
    
    <%
        Iterator marketMatrixRecordsVector = null;
	Collection marketMatrixRecordsToAddColl = null;
	AddMarketMatrixRecordInfo marketMatrixInfo = null;
	try
        { 
        MarketMatrixJdbc marketMatrixJdbc = new MarketMatrixJdbc();
        marketMatrixRecordsToAddColl = marketMatrixJdbc.getMarketMatrixRecordsToAdd(releaseNumberId,userId);
        int marketMatrixRecordsTotal = marketMatrixRecordsToAddColl.size();
    %>
    <input type="Hidden" name="imageFeatureSetIndex"  value="<%= marketMatrixRecordsTotal %>" />
    <%
        ArrayList marketMatrixRecordsToAddArray = new ArrayList(marketMatrixRecordsToAddColl);
        
        if (marketMatrixRecordsToAddArray != null) {
	marketMatrixRecordsVector = marketMatrixRecordsToAddArray.iterator();
	// Take one by one and display them.

	int imageFeatureSetIndex = 0;

	while (marketMatrixRecordsVector.hasNext()) {
	  marketMatrixInfo = (AddMarketMatrixRecordInfo) marketMatrixRecordsVector.next();
	
    %>
    
    <input type="Hidden" name="<%="_"+imageFeatureSetIndex+"ImageFeatureSetId"%>"  value="<%= marketMatrixInfo.getImageFeatureSetId()  %>" />
    <input type="Hidden" name="<%="_"+imageFeatureSetIndex+"PcodeGroupId"%>"  value="<%= marketMatrixInfo.getPcodeGroupId()  %>" />
    <tr>
      <td align="center" valign="top" class="tableCell"><span class="dataTableData">
        <input type="checkbox" value='Y' name="<%="_"+imageFeatureSetIndex+"_select"%>" />
      </span></td>
      <td align="left" valign="top" class="tableCell"><span class="dataTableData">
        <%= marketMatrixInfo.getImageName() %>
      </span></td>
      <td class="tableCell" valign="top" align="left"><span class="dataTableData">
	<%= marketMatrixInfo.getPlatformList() %>
       <td class="tableCell" valign="top" align="left"><span class="dataTableData">
	<%= marketMatrixInfo.getPcodeGroupName() %>
      <td align="left" class="tableCell" valign="top" align="center"><span class="dataTableData">
	<%= StringUtils.nvl(marketMatrixInfo.getFeatureSetDesc(),htmlNoValue) %>
      </span> </td>
      <td align="left" class="tableCell" valign="left" align="center"><span class="dataTableData">
	<%= StringUtils.nvl(marketMatrixInfo.getFeatureSetDesignator(),htmlNoValue)%>
      </span> </td>
      <td class="tableCell" valign="top" align="center"><span class="dataTableData">
	<%= marketMatrixInfo.getMinFlash() %>
      </span> </td>
      <td class="tableCell" valign="top" align="center"><span class="dataTableData">
      	<%= marketMatrixInfo.getMinDram()%>
      </span> </td>
    </tr>
	  
	  <%
	  imageFeatureSetIndex ++;
	  } 
	  }
	  }catch(Exception E)
	  {}
	  %>
    
    </table>
  </td>
</tr>
</table>
<br />

   <table>
     <tr> 
     <td>
       <%= htmlButtonAddImages2 %>
     </td>
     </tr>	   
    </table>
    <br />
  
</center>
</form>

</body>
</html>

<!-- end -->
