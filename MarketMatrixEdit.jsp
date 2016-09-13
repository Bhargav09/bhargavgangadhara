<!--.........................................................................
: DESCRIPTION:
: Market Matrix page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
: @author Kelly M. (kellmill@cisco.com) Fix for CSCsg40246.
:
: Copyright (c) 2003-2007 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Vector" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>

<%@ page import="com.cisco.eit.shrrda.individualplatform.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.marketmatrix.MarketMatrixJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.MarketMatrixGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
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
<%@ page import="com.cisco.eit.sprit.util.ImageDbUtil" %>
<%@ page import="com.cisco.eit.sprit.beans.ImageCcoPusPostedInfo" %>

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
  Vector mmRecords = new Vector();
  String htmlButtonSaveUpdates1 = "";
  String htmlButtonSaveUpdates2 = "";
  String htmlButtonAddImages1 ="";
  String htmlButtonAddImages2 ="";
  String webParamsDefault;
  String initOrderableInstrValue = SpritConstants.initSelection;
  String initOrderableInstrNumValue = "0";
  HashMap pcodeDups = new HashMap();
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  	MonitorUtil monUtil = new MonitorUtil();
    	monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Market Matrix Edit");

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
    banner.addReleaseNumberElement( request,"releaseNumberId" ); //CSCsj36148
  //banner.addContextNavElement( "REL:",SpritGUI.renderReleaseNumberNav(globals,releaseNumber));
   try {
   	mmRecords = (Vector) MarketMatrixJdbc.getRecordsAll(releaseNumberId);   
   }catch(Exception e){
   	System.out.println("Error in the MarketMatrixJdbc.getRecordsAll(releaseNumberId)="+e);
   	e.printStackTrace();
   }
   
   pcodeDups = (HashMap) MarketMatrixJdbc.getPcodeDups();
  
%>
<%= SpritGUI.pageHeader( globals,"Market Matrix","<script language=\"javascript\" src=\"../js/ajax.js\"></script>" ) %>
<%= banner.render() %>

<%= SpritReleaseTabs.getTabs(globals, "mm") %>
<%
  webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());

  //String filterImageName = FilterUtil.getFilterParameter(request,"filtImgnm");
  //String filterProductSoftwareDesc = FilterUtil.getFilterParameter(request,"filtProdSoftdesc");

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
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber, "MM"),
          		    false,
               		"MarketMatrix.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixEdit.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixReport.jsp?" + webParamsDefault + "&" + filterUrl
                		+ "&outputType=excel"
            		) ) );
           %>
        </form>


         </td>
         <td width="25%" valign="middle" align="right">
           <table>
             <tr>
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


<%
   
// Make sure we can see this page.  If not then send them to view
// mode!
if( !spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"MM") ) {
  response.sendRedirect( ""
      + "MarketMatrix.jsp?releaseNumberId=" 
      + WebUtils.escUrl(releaseNumberId.toString())
      );
}  // if( !spritAccessManager.isMilestoneOnwer() )


 // HTML macros
 htmlButtonSaveUpdates1 = SpritGUI.renderButtonRollover(
 	globals,
 	"btnSaveUpdates1",
 	"Save Updates",
 	"javascript:validateAndsubmitForm('mmUpdate')",
 	pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
 	"actionBtnSaveUpdates('btnSaveUpdates1')",
 	"actionBtnSaveUpdatesOver('btnSaveUpdates1')"
 	);
 htmlButtonSaveUpdates2 = SpritGUI.renderButtonRollover(
 	globals,
 	"btnSaveUpdates2",
 	"Save Updates",
 	"javascript:validateAndsubmitForm('mmUpdate')",
 	pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
 	"actionBtnSaveUpdates('btnSaveUpdates2')",
 	"actionBtnSaveUpdatesOver('btnSaveUpdates2')"
 	);
 
 htmlButtonAddImages1 = SpritGUI.renderButtonRollover(
 	globals,
 	"btnAddImages1",
 	"Add Images",
 	"javascript:ImageAddPopup('mmUpdate')",
 	pathGfx + "/" + "btn_image_add.gif",
 	"setImg('btnAddImages1','" + pathGfx + "/" + "btn_image_add.gif" + "')",
 	"setImg('btnAddImages1','" + pathGfx + "/" + "btn_image_add_over.gif" + "')"
 	);
 htmlButtonAddImages2 = SpritGUI.renderButtonRollover(
         globals,
         "btnAddImages2",
         "Add Images",
         "javascript:ImageAddPopup('mmUpdate')",
         pathGfx + "/" + "btn_image_add.gif",
         "setImg('btnAddImages2','" + pathGfx + "/" + "btn_image_add.gif" + "')",
         "setImg('btnAddImages2','" + pathGfx + "/" + "btn_image_add_over.gif" + "')"
         );
 
%>

<%
     boolean showDelete = true;
     CisrommAPI cisrommAPI;

     try {
       cisrommAPI = new CisrommAPI();
     } catch( Exception e ) {
       throw e;
     }  // try
boolean goneToCco = false;
boolean goneToOpus = false;

if( cisrommAPI.getMilestoneActualDate(releaseNumberId.intValue(),"CCO FCS")!=null) {
  showDelete = false;
  goneToCco = true;
}  // if cisrommAPI...

if(cisrommAPI.getMilestoneActualDate(releaseNumberId.intValue(),"OPUS")!=null) {
  showDelete = false;
  goneToOpus = true;
}  // if cisrommAPI...

%>
       
 <form name="mmUpdate" action="MMProcessor" method="post" >
 <INPUT TYPE="HIDDEN" NAME="releaseNumberId" VALUE="<%=releaseNumberId%>"/>
 <INPUT TYPE="HIDDEN" NAME="callingForm" VALUE="mmUpdate"/>
 <input type="hidden" name="_submitformflag" value="0" />
 
 <center>
 <br>
 <%=MarketMatrixGUI.htmlSummarize(mmRecords, pcodeDups)%>
 <br>
 
 <table>
  <tr> <td> 
    <%= htmlButtonSaveUpdates1 %>
  </td>
    <td>
      <%= htmlButtonAddImages1 %>
  </td>
  </tr>	   
</table>
    <table cellspacing="0" cellpadding="2" border="1">
     <tr>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">DEL</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Platform</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Image Name</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Product Description</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Generate Spare</td>
          <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Product Code</td>
          <!--<td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Price</td> -->
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
    	mmRecords, filterImageName, filterProductSoftwareDesc );
  
    if( listOfMMInfo != null ) {
  	
  	    // The master values for orderable instructions.
  	    HashMap orderableInstrValues = new HashMap();
        try {
            orderableInstrValues = MarketMatrixJdbc.getOrderableInstrValues();
        } catch (Exception dbe) {
            dbe.printStackTrace();
        }
        Set instrKeys = orderableInstrValues.keySet();
        
        Iterator iter = listOfMMInfo.iterator();
        int mmTotal = listOfMMInfo.size();
	int recIndex = 0;
        String statusSpareColor = "#ffffff";
        String statusColor = "#ffffff";
	
    %>
    <input type="Hidden" name="<%="TotalMMIndex"%>" value="<%= mmTotal  %>" />  
    <%
		ImageDbUtil dbUtil=new ImageDbUtil();
        while( iter.hasNext() ) {
        mmInfo = (MarketMatrixInfo) iter.next();
	String errorMainColor = "#ffffff";
	String errorSpareColor = "#ffffff";
	String errorDescColor = "#ffffff";        
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
      <input type="Hidden" name="<%="_"+recIndex+"PcodeId"%>" value="<%= mmInfo.getPcodeId()  %>" />  
      <input type="Hidden" name="<%="_"+recIndex+"inPCSpare"%>" value="<%= mmInfo.getPcodeSpare()  %>" />  
     <!--  <input type="Hidden" name="<%="_"+recIndex+"inPCMainPrice"%>" value="<%= mmInfo.getPcodeMainPrice()  %>" /> -->  
     <!-- <input type="Hidden" name="<%="_"+recIndex+"inPCSparePrice"%>" value="<%= mmInfo.getPcodeSparePrice()  %>" /> -->  
      <input type="Hidden" name="<%="_"+recIndex+"inPcodePrefixSpare"%>" value="<%= mmInfo.getPcodePrefixSpare()  %>" /> 
      <input type="Hidden" name="<%="_"+recIndex+"inMainOrderableInstr"%>" value="<%= mmInfo.getMainOrderableInstr()  %>" /> 
      <input type="Hidden" name="<%="_"+recIndex+"inSpareOrderableInstr"%>" value="<%= mmInfo.getSpareOrderableInstr()  %>" />
      <input type="Hidden" name="<%="_"+recIndex+"inMainOrderableComment"%>" value="<%= mmInfo.getMainOrderableComment()  %>" /> 
      <input type="Hidden" name="<%="_"+recIndex+"inSpareOrderableComment"%>" value="<%= mmInfo.getSpareOrderableComment()  %>" /> 
	  <%
		ImageCcoPusPostedInfo info = dbUtil.getImageCcoOpusPostedInfo(releaseNumber, mmInfo.getImageId(), mmInfo.getImageName());
		showDelete = info.isDeleteAllowed().booleanValue();
	  %>
             
      <%  if( showDelete ){ %>
      <td class="dataTableData" valign="top" align="left" rowspan="2"><nobr><input type="checkbox" value="Y" name="<%="_"+recIndex+"delete"%>"/></nobr></td>
      <%  }else if(! showDelete) { %>
		  <td class="dataTableData" valign="top" align="left" rowspan="2"><%= info.getStatus() %></td>
	  <% }
		  %>   
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

      
        <% 
            if (mmInfo.getEndOfSpare().equals("N")){
        	if(mmInfo.getPcodePrefixSpare()!= null){
        	
                  
		  if (!mmInfo.getPcodePrefixSpare().equals("")) {
		  %>
		  	<td align="center" valign="top" rowspan="2"><span class="dataTableData">
		  	<input type="checkbox" checked value="<%=mmInfo.getPcodePrefixSpare()%>" name="<%="_"+recIndex+"PcodePrefixSpare"%>"/>
		  	</span></td>		                		
		  <% } else { %>
		  	<td align="center" valign="top" rowspan="2"><span class="dataTableData">
		  	<input type="checkbox" value="S" name="<%="_"+recIndex+"PcodePrefixSpare"%>"/>
		  	</span></td>		                		
		  <% }
		
		} else { %>
			<td align="center" valign="top" rowspan="2"><span class="dataTableData">
			<input type="checkbox" value="S" name="<%="_"+recIndex+"PcodePrefixSpare"%>"/>
			</span></td>		                		
		<% } 
	
	   } else { %>
		  <td align="center" valign="top" rowspan="2">&nbsp;</td>
	<% }%>
      
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

      <!-- <td class="dataTableData" valign="top" align="right"><nobr><input type="text" name="<%="_"+recIndex+"PCMainPrice"%>" size="14" value="<%= mmInfo.getPcodeMainPrice()  %>" onChange="checkProductApproval('<%= mmInfo.getPcodeMain() %>', '<%= mmInfo.getPcodeMainStatus() %>');" /></nobr></td> -->
      <td class="dataTableData" valign="top" align="center" bgcolor=<%=statusColor%>><nobr><%= mmInfo.getPcodeMainStatus() %></nobr></td>
      <% if ( mmInfo.getPcodeMainOrderable() != null && ! "".equals(mmInfo.getPcodeMainOrderable()) ) { %>
      <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeMainOrderable() %></nobr></td>
      <% } else { %>
      <td class="dataTableData" align="center" valign="top">&nbsp;</td>
      <% }      
      %>
     <!-- <td class="dataTableData" valign="top" align="center"><nobr><select name="<%="_"+recIndex+"mainOrderableInstr"%>">
      <% Integer curValue = null;
         if ( mmInfo.getMainOrderableInstr() != null && ! new Integer(0).equals(mmInfo.getMainOrderableInstr()) ) {
            curValue = mmInfo.getMainOrderableInstr();
         }
         if ( curValue == null ) {
      %>
        <option value="<%=initOrderableInstrNumValue%>" selected><%=initOrderableInstrValue%></option>
      <%
         }
         
         Iterator instructions = instrKeys.iterator();
         while ( instructions.hasNext() ) {
           Integer nextValue = (Integer) instructions.next();
           String selectedValue = "";
           if ( curValue != null && curValue.equals(nextValue) )
             selectedValue = "selected";
      %>
        <option value="<%=nextValue%>" <%=selectedValue%>><%=orderableInstrValues.get(nextValue)%></option>
      <% } %>
      </select></nobr></td>
      
      <td class="dataTableData" valign="top" align="center"><nobr><textarea name="<%="_"+recIndex+"mainOrderableComment"%>" rows=1 cols="30" onkeypress="return imposeMaxLength(this, 1000)"><%=mmInfo.getMainOrderableComment()%></textarea></nobr></td>
      -->
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

      <!-- <td class="dataTableData" valign="top" align="right"><nobr><input type="text" name="<%="_"+recIndex+"PCSparePrice"%>" size="14" value="<%= mmInfo.getPcodeSparePrice()  %>" onChange="checkProductApproval('<%= mmInfo.getPcodeSpare() %>', '<%= mmInfo.getPcodeSpareStatus() %>');" /></nobr></td> -->
      <td class="dataTableData" valign="top" align="center" bgcolor=<%=statusSpareColor%>><nobr><%= mmInfo.getPcodeSpareStatus() %></nobr></td>
      <% if ( mmInfo.getPcodeSpareOrderable() != null && ! "".equals(mmInfo.getPcodeSpareOrderable()) ) { %>
      <td class="dataTableData" valign="top" align="center"><nobr><%= mmInfo.getPcodeSpareOrderable() %></nobr></td>
      <% } else { %>
      <td valign="top" align="center">&nbsp;</td>
      <% } %>
      <!--
      <td class="dataTableData" valign="top" align="center"><nobr><select name="<%="_"+recIndex+"spareOrderableInstr"%>">
      <% curValue = null;
         if ( mmInfo.getSpareOrderableInstr() != null && ! new Integer(0).equals(mmInfo.getSpareOrderableInstr()) ) {
            curValue = mmInfo.getSpareOrderableInstr();
         }

         if ( curValue == null ) {
      %>
        <option value="<%=initOrderableInstrNumValue%>" selected><%=initOrderableInstrValue%></option>
      <%
         }
      
         instructions = instrKeys.iterator();
         while ( instructions.hasNext() ) {
           Integer nextValue = (Integer) instructions.next();
           String selectedValue = "";
           if ( curValue != null && curValue.equals(nextValue) )
             selectedValue = "selected";
      %>
        <option value="<%=nextValue%>" <%=selectedValue%>><%=orderableInstrValues.get(nextValue)%></option>
      <% }
      %>
      </select></nobr></td>
      
      <td class="dataTableData" valign="top" align="center"><nobr><textarea name="<%="_"+recIndex+"spareOrderableComment"%>" rows=1 cols="30" onkeypress="return imposeMaxLength(this, 1000)"><%=mmInfo.getSpareOrderableComment()%></textarea></nobr></td>
    -->   
    </tr>
    <%
    }//if(mmInfo.getPcodePrefixSpare()!= null)
    else %>
    
    <tr></tr>
    
    <%
    recIndex ++;
    }  // while( iter2.hasNext() )
    }

    %>
</table><br />
 <table>
 <tr> <td> 
   <%= htmlButtonSaveUpdates2 %>
 </td>
    <td>
      <%= htmlButtonAddImages2 %>
  </td>
 </tr>	   
</table>
</center>

</form>

<script language="javascript"><!--
  //........................................................................
  // DESCRIPTION:
  //     Submits this form and checks for errors.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  
  // global variable to track price column changes on approved products
  var approvedProdPriceChanged = false;
  
  // check if the price change made on approved product and set global variable to true.
  function checkProductApproval(productCode, status) {
  
  	// in case of SPRIT check status from MFG_CACHE_OPUS server side AJAX call 
  	if (status.toUpperCase() == 'SPRIT') {
  		if (productCode != null && productCode.length >0 ) {
  			var xmlHttp = GetXmlHttpObject();
  			makeAjaxRequest(xmlHttp, 'NonIosAjaxHelper', 'POST', 'productCode='+ productCode+'&action=isProductApproved');
  			if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") { 

			  	if( xmlHttp.status == 200 && xmlHttp.responseText != null && xmlHttp.responseText != '') { 
					if (xmlHttp.responseText == 'true') {
						approvedProdPriceChanged = true;
					} else {
						approvedProdPriceChanged = false;
					}
			  	} 
			}
		}
	} else {
		// rest (OPUS & ERP) always alert when user edit price
		approvedProdPriceChanged = true;
	} 
  }
  
  function validateAndsubmitForm(formName) {
    var formObj;
    formObj = document.forms[formName];
    elements = formObj.elements;

    // Check to see if we've submitted this before!
    if( elements['_submitformflag'].value==1 ) {
       return;
    }
    
    /*for (j =0; j<formObj.TotalMMIndex.value; j++) {  
	  var mainOrderableComments = "_"+j+"mainOrderableComment";
	  var spareOrderableComments = "_"+j+"spareOrderableComment";
    
	  if(mainOrderableComments != null && validateTxtAreaLen(formObj.elements[mainOrderableComments].value, 1000)) {
	  	formObj.elements[mainOrderableComments].focus();
	  	alert("'Main Orderable Comments' exceeds 1000 characters");
	  	return false;
	  }
	  
	  if((formObj.elements[spareOrderableComments] != undefined) && spareOrderableComments != null && validateTxtAreaLen(formObj.elements[spareOrderableComments].value, 1000)) {
	  	formObj.elements[spareOrderableComments].focus();
	  	alert("'Spare Orderable Comments' exceeds 1000 characters");
	  	return false;
	  }
    }*/
    /* for (i =0; i<formObj.TotalMMIndex.value; i++) {        
      var pcodeMainPrice = "_"+i+"PCMainPrice";
      var pcodeSparePrice = "_"+i+"PCSparePrice";

      var pcodeMainPriceValue = formObj.elements[pcodeMainPrice].value;
      if(formObj.elements[pcodeSparePrice] != null) {
          var pcodeSparePriceValue = formObj.elements[pcodeSparePrice].value;
          if(pcodeSparePriceValue == ""){ 
	        formObj.elements[pcodeSparePrice].value = "0";
	      }
      }
    
      if(pcodeMainPriceValue == ""){ 
        formObj.elements[pcodeMainPrice].value = "0";
      }
      
    }
    
    if (approvedProdPriceChanged) {
    	var message = "Product(s) have been already approved in OPUS, so you need to work with PDT/OPUS team to update \nthe price in OPUS as updating in SPRIT will not affect in OPUS. However still you need to update the \nprice in SPRIT so Product(s) in subsequent releases will have the correct price when they are copied over.";
    	
    	alert(message);
    }
    */
    elements['_submitformflag'].value=1;
    formObj.submit();

  }  

//........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function actionBtnSaveUpdates(elemName) {
  
	if( document.forms['mmUpdate'].elements['_submitformflag'].value==0 ) {
	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
	}  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
	if( document.forms['mmUpdate'].elements['_submitformflag'].value==0 ) {
	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
	}  // if
  }
  
    function ImageAddPopup(formName) {
        var win;
        var posx,posy;
        
        posx = mousePosX-32;
        posy = mousePosY-32;
        
        var formObj;
        var elements;  
        var releaseId;
        formObj = document.forms[formName];
        elements = formObj.elements;
        releaseId = formObj.releaseNumberId.value;
    
        win = window.open( "MarketMatrixAdd.jsp?releaseNumberId="+releaseId,"MMAddREcs",
            "resizable=yes,scrollbars=yes,width=800,height=600"
            + ",top=" + 25
            + ",left=" + 200 );
    
        win.focus();
  }
  
 //--> 
</script>

<%= Footer.pageFooter(globals) %>
<!-- end -->
