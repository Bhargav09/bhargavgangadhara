<!--.........................................................................
: DESCRIPTION: Generate Image level CCO Publishing Transaction Monitor page.
:              - This page is requested from CcoPublishMonitorTransOutput.jsp
:                when 'Image Info' hyperlink is clicked.
:
: AUTHORS:
: @author nadialee
:
: WRITTEN WHEN:  July 2005
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<!------------ CcoPublishMonitorImageOutput.jsp : Begin  --------->

<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>

<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSession" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSessionHome" %>

<%@ page import="com.cisco.eit.sprit.dataobject.CcoPublishTransMonitorParamInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CcoPublishImageInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CcoPublishTransInfo" %>

<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
final String THIS_FILE                          = "[CcoPublishMonitorImageOutput.jsp] " ;

final String TRANS_TABLE_HEADING_BGCOLOR        = "#808080";
final String TRANS_TABLE_HEADING_TEXTCOLOR      = "#ffffff";

final String TABLE_OUTLINE_COLOR                = "#3d127b";
final String PAGING_BGCOLOR                     = "#808080";
final String TABLE_CELL_GAP_COLOR               = "#BBD1ED";
final String TABLE_DATA_HEAD_BGCOLOR            = "#d9d9d9";
final String TABLE_DATA_BGCOLOR                 = "#ffffff";
final int    MAX_LN_CNT_FOR_BOTTOM_PAGE_HEAD    = 15;

SpritAccessManager  spritAccessManager;
SpritGlobalInfo     globals;
SpritGUIBanner      banner;
String              pathGfx;
String              servletMessages;
String              loginUid            = "";
int                 thisPageTotalLnCnt  = 0;
String excelUpload ="";



// Initialize globals
globals             = SpritInitializeGlobals.init(request,response);
pathGfx             = globals.gs( "pathGfx" );
spritAccessManager  = (SpritAccessManager) globals.go( "accessManager" );

loginUid            = spritAccessManager.getUserId();

// Set up banner for later
banner =  new SpritGUIBanner( globals );
banner.addContextNavElement( "REL:",
    SpritGUI.renderReleaseNumberNav(globals,null)
    );

%>

<%= SpritGUI.pageHeader( globals,"Monitor Menu","" ) %>
<%= banner.render() %>

<script language="JavaScript" src="../js/sprit.js"></script>

<script language="JavaScript">


function uploadToExcel()
{

  document.imageReport.excelUpload.value = "yes";
  document.imageReport.method = "Get";
  document.imageReport.submit();
 
}

</script>

<span class="headline">
    <align="center">CCO Publishing - Image Status<align="center">
</span>
<br />
<span class="subHeadline">
    <align="center">Sorted by Release Number, Image Name<align="center">
</span>

<%

//====================================================================
// See if there were any messages to generate ....
//====================================================================
servletMessages = (String) request.getAttribute( "Sprit.servMsg" );

if( servletMessages!=null ) {
    PrintWriter printWriter;
    printWriter = response.getWriter();
    printWriter.print( ""
        + "<br />\n"
        + servletMessages
        + "<br /><br />\n\n"
        );
}  // if( servletMessages!=null )


//====================================================================
// User-selected parameter values from CcoPublishMonitorForm.
// - These parameters are redefined and stored in the session
//   of type CcoPublishTransMonitorParamInfo.
//
//====================================================================

//--------------------------------------------------------------------
// Parameter values from CcoPublishMonitorForm, passed from
// CcoPublishMonitorProcessor.java, stored in session.
//--------------------------------------------------------------------
CcoPublishTransMonitorParamInfo paramInfo =
    (CcoPublishTransMonitorParamInfo) session.getAttribute("ccoTransMonitorParamInfo");

Integer recPerPageCnt   = paramInfo.getRecPerPageCnt();

//--------------------------------------------------------------------
// Determine the current page number for Image output.
//--------------------------------------------------------------------
String  pThisPageNo     = (String) request.getParameter("pg");
String  pTransId        = (String) request.getParameter("transId");

pThisPageNo     = pThisPageNo==null ? "" : pThisPageNo.trim();
pTransId        = pTransId==null ? "" : pTransId.trim();

int     thisPageNoInt   = -1;
Integer thisPageNo;
Integer transId;

// This is when the result output page is loaded for the first time.
// Default is the page no. 1.
if( pThisPageNo==null || pThisPageNo.length()==0 )
{
    thisPageNoInt  = 1;
}
else
{
    thisPageNoInt = ( new Integer(pThisPageNo) ).intValue();
}

thisPageNo = new Integer(thisPageNoInt);



if( pTransId==null || pTransId.length()==0)
{
    throw new Exception( "Transaction ID is undefined.");
}
else
{
    transId = new Integer(pTransId);
}


final String TRANS_PAGE_URL = "CcoPublishMonitorImageOutput.jsp?";
final String IMAGE_PAGE_URL = "CcoPublishMonitorImageOutput.jsp?" +
                                    "transId=" + pTransId ;

//====================================================================
// Get Ready to retrieve data ...
//====================================================================

Context ctx;
CcoPublishMonitorSessionHome     ccoPublishMonitorSessionHome;
CcoPublishMonitorSession         ccoPublishMonitorSession;

try {

    ctx = JNDIContext.getInitialContext();

    ccoPublishMonitorSessionHome =(CcoPublishMonitorSessionHome)ctx.lookup

("CcoPublishMonitorSession.CcoPublishMonitorSessionHome");

    ccoPublishMonitorSession     = ccoPublishMonitorSessionHome.create();


} catch(Exception e) {
    System.out.println(
        THIS_FILE + "Exception: CcoPublishMonitorSession create block");
    e.printStackTrace();
    throw e;
} // try: catch

//====================================================================
// Retrieve all image IDs for the passed trans ID .
// order by release number, image name.
//====================================================================
Vector imageIdVect =
            ccoPublishMonitorSession.getPublishImageId( transId );

// Find the total number of output pages.
Integer pageTotalCnt = SpritUtility.getPageTotalCnt(
                                    imageIdVect,
                                    recPerPageCnt);

// Retrieve for this page only.
Vector thisPageImageIdVect = SpritUtility.getThisPageItemVect(
                                    imageIdVect,
                                    thisPageNo,
                                    recPerPageCnt );

int     pageTotalCntInt = pageTotalCnt.intValue();
int     recTotalCntInt  = imageIdVect.size();

//====================================================================
// Retrieve CCO yPublish image information to display for this page
//====================================================================

Vector outputVect = ccoPublishMonitorSession.ProcessPublishImageInfo( transId,
                                                                      thisPageImageIdVect,
                                                                      thisPageNo,
                                                                      recPerPageCnt );
if(request.getParameter("excelUpload") != null)
{
	 excelUpload = request.getParameter("excelUpload");
	
}
if(excelUpload.equals("yes"))
{
	response.setContentType("application/vnd.ms-excel");
	
}

//=========================================================================
// Make Table page heading
//=========================================================================
StringBuffer pageHeadRow = new StringBuffer();

    pageHeadRow = pageHeadRow
			.append("  <form name=\"imageReport\" action=\"CcoPublishMonitorImageOutput.jsp\" > \n")
            .append("        <tr> \n")
            .append("            <td>")
            .append("<img src=\"../gfx/b1x1.gif\" height=\"5\"></td> \n")
            .append("        </tr> \n")
            .append("        <tr> \n")
            .append("            <td align=\"center\" valign=\"middle\" class=\"smallBoldText\"> \n");

for( int i=1; i<=pageTotalCntInt; i++ )
{
    pageHeadRow = pageHeadRow
            .append("                ")
            .append("<img src=\"../gfx/b1x1.gif\" width=\"10\"> \n" );

    if( i== thisPageNoInt )
    {
        pageHeadRow = pageHeadRow
            .append("                <font color=\"#55ff00\"><span class=\"smallBoldText\">")
            .append(i)
            .append("</span></font> \n");
    }
    else
    {
        pageHeadRow = pageHeadRow
            .append("                <font color=\"#ffffff\" >")
            .append("<span class=\"smallBoldText\">")
            .append("<a href=\"").append(IMAGE_PAGE_URL).append("&pg=")
            .append(i).append("\">")
            .append(i).append("</a></span></font> \n");
    }
} // for

    pageHeadRow = pageHeadRow
            .append("            </td>\n")
            .append("        </tr> \n")
            .append("        <tr> \n")
            .append("            <td>")
            .append("<img src=\"../gfx/b1x1.gif\" height=\"5\"></td> \n")
            .append("        </tr> \n") ;


//=========================================================================
// Make Table column heading
//=========================================================================
StringBuffer colHeadRow = new StringBuffer();

colHeadRow = colHeadRow.append("               <tr> \n")
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Ln</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Release</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Image Name</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Is Image Published?</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\" width=\"30\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Image Publishing Status Log</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Trans.Begin.Time (PST)</span> \n")
          .append("                    </td> \n" )
           .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Snap Copy End Time (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Snap Copy Time (Minutes)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Total Trans.Time</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Trans.End Time (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Image Size(bytes)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Bus Unit</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_DATA_HEAD_BGCOLOR)
          .append("\" width=\"50\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Messages (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                </tr> \n" );

//-----------------------------------------------------------------
// Retrieve Transaction Info to display ...
//-----------------------------------------------------------------

CcoPublishTransInfo transInfo = ccoPublishMonitorSession.getPublishTransInfo( transId ); 

Vector  detailsVector  = ccoPublishMonitorSession.getAllReleaseInfoByTransId( transId );

HashMap	transactionDetailsMap = (HashMap)detailsVector.elementAt(2);

%>

<br /><br />

<center>
<table border="0" cellpadding="1" cellspacing="0" bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
<tr>
    <td bgcolor="<%=TRANS_TABLE_HEADING_BGCOLOR%>">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td align="center" valign="top">
                <span class="sectionTitle">
                <img src="../gfx/b1x1.gif" height="5" width="600" >
                <font color="<%=TRANS_TABLE_HEADING_TEXTCOLOR%>">Transaction Summary Information</font>
                </span>
            </td>
        </tr>
        </table>
    </td>
</tr>

<tr>
    <td>
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                <table border="0" cellpadding="2" cellspacing="1" width="100%">
                <tr bgcolor="<%=TABLE_DATA_HEAD_BGCOLOR%>">
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>OS Type/</nobr><br /><nobr>Software Type</nobr>
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            Transaction ID
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            Transaction Type
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Submit Time</nobr>
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            Submitted By
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            Current Status
                        </span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Current Status Time</nobr>
                        </span>
                    </td>
                    <!-- New Columns for the report -->
                     <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Snap Copy Time(Minutes)</nobr>
                        </span>
                    </td>
                     <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Trans.Begin Time (PST)</nobr>
                        </span>
                    </td>
                      <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Snap Copy End Time (PST)</nobr>
                        </span>
                    </td>
                     <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Total Trans.Time</nobr>
                        </span>
                    </td>
                     <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Trans.End Time (PST)</nobr>
                        </span>
                    </td>
                      <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Image Size(bytes)</nobr>
                        </span>
                    </td>
                      <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Total Images</nobr>
                        </span>
                    </td>
                      <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Prioritized</nobr>
                        </span>
                    </td>
                     <td align="center" valign="top">
                        <span class="dataTableTitle">
                            <nobr>Bus Unit</nobr>
                        </span>
                    </td>
                   </tr>

                <tr bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                    <td align="center" valign="top">
                        <span class="dataTableData"><nobr><%=transInfo.getOsType()%></nobr></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><%=pTransId%></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><nobr><%=transInfo.getTransType()%></nobr></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><nobr><%=SpritUtility.getMMddyyyyFomat(transInfo.getTransCreatedTime())%></nobr></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><%=transInfo.getTransCreatedByUid()%></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><%=transInfo.getTransStatus()%></span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableData"><nobr><%=SpritUtility.getMMddyyyyFomat(transInfo.getTransStatusTime())%></nobr></span>
                    </td>
                     <td align="center" valign="top" >
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_transaction_time") != null? 
                        		transactionDetailsMap.get("snap_mirror_transaction_time"):""%>
                    </span></td>
                     <td align="center" valign="top" >
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_begin_time") != null? 
                        		transactionDetailsMap.get("snap_mirror_begin_time"):""%>
                    </span></td>
                     <td align="center" valign="top">
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_end_time") != null?
                        		transactionDetailsMap.get("snap_mirror_end_time"):""%>
                    </span></td>
                     <td align="center" valign="top">
                        <span class="dataTableData"><%=transactionDetailsMap.get("total_transaction_time") != null?
                        		transactionDetailsMap.get("total_transaction_time"):""%>
                    </span></td>
                      <td align="center" valign="top">
                        <span class="dataTableData"><%=transactionDetailsMap.get("transaction_end_time") != null?
                        		transactionDetailsMap.get("transaction_end_time"):""%>
                    </span></td>
                     <td align="center" valign="top">
                        <span class="dataTableData"><%=transactionDetailsMap.get("image_size") != null?
                        		transactionDetailsMap.get("image_size"):""%>
                    </span></td>
                    <td align="center" valign="top" >
                        <span class="dataTableData"><%=transactionDetailsMap.get("no_of_images") != null? 
                        		transactionDetailsMap.get("no_of_images"):""%>
                    </span></td>
                      <td align="center" valign="top" >
                         <span class="dataTableData"><%=transactionDetailsMap.get("priority_value") != null? 
                        		 transactionDetailsMap.get("priority_value"):""%>
                    </span></td>
                       <td align="center" valign="top" >
                        <span class="dataTableData"><%=transactionDetailsMap.get("business_unit_name") != null? 
                        		transactionDetailsMap.get("business_unit_name"):""%>
                    </span></td>
                </tr>
                </table>
            </td>
        </tr>
        </table>
</tr>
</table>
</center>

<br />

<center>
<span class="smallText">
<font color="#3D127B"><b>NOTE :</b></font>
<font color="#000000">&nbsp;<b>Is Image Published</b>&nbsp; and &nbsp;<b>Image Publishing Status Log</b>&nbsp; <br 

/>columns below are populated upon CCO publishing completion.</font>
</span>

<br />

<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="<%=PAGING_BGCOLOR%>">
        <table border="0" cellpadding="0" cellspacing="0">
        <!----------- Output available pages  ---------->
<%
out.println(pageHeadRow);
%>
        <!-------- Column Headings  -------->
        <tr>
            <td bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                <table border="0" cellpadding="3" cellspacing="1" width="100%">
<%
out.println(colHeadRow);
%>
                <!-------- Output data   -------->
<%
                CcoPublishImageInfo  aImageInfo;

                thisPageTotalLnCnt  = outputVect.size() + 1;

                for( int rowIdx=0; rowIdx<outputVect.size(); rowIdx++ )
                {
                    aImageInfo = (CcoPublishImageInfo) outputVect.elementAt(rowIdx);
                    System.out.println("got aImageInfo");
%>
                <tr bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getLnCnt().intValue()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><nobr><%=aImageInfo.getReleaseNumber()%></nobr></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getImageName()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getImageIsPublished() != null ? aImageInfo.getImageIsPublished():"" %></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getImageYpubStatusLog() != null ? aImageInfo.getImageYpubStatusLog():""%></span>
                    </td>
                    
                      <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getSnapMirrorBeginTime()  != null ? aImageInfo.getSnapMirrorBeginTime():""%></span>
                    </td>
                      <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getSnapMirrorEndTime() !=null ? aImageInfo.getSnapMirrorEndTime():""%></span>
                    </td>
                      <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getSnapMirrorTransactionTime() !=null ?aImageInfo.getSnapMirrorTransactionTime():""%></span>
                    </td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getTotalTransactionTime() !=null ?aImageInfo.getTotalTransactionTime():""%></span>
                    </td>
                      <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getTransactionEndTime() !=null ?aImageInfo.getTransactionEndTime():""%></span>
                    </td>
                       <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getImageSize() != null ? aImageInfo.getImageSize():"" %></span>
                    </td>
                    
                    <td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
                        <span class="dataTableData"><%=aImageInfo.getBusinessUnitName() != null ? aImageInfo.getBusinessUnitName():"" %></span>
                    <% String message = "";
		ArrayList mes = aImageInfo.getMessages();
		int mesSize = mes.size();
		if(mes != null){
		if(mesSize<=2){
		Iterator e1 = mes.iterator(); %>
		<td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
			<span class="dataTableData">
		<% while(e1.hasNext()){ %>
        <ul>
  		<li>
		<%= e1.next() %>
		</li>
		</ul>		
		<% } %>
		</span></td>
	<% }else{
		Iterator e2 = mes.iterator(); %>
		<td align="left" valign="top" bgcolor="<%=TABLE_DATA_BGCOLOR%>">
			<span class="dataTableData">
		<ul>
  		<li>
		<%=  mes.get(0)  %>
		 </li>
  		<li>
		<%= mes.get(1) %>
	</li>
	<%while(e2.hasNext()){
	//message += e2.next()+"$"+"\n";
	message += e2.next()+"$";
	}%>
  		<li>	
    <h4><a href="javascript:MessagePopup('<%=message%>')" onMouseOver="MessagePopup('<%=message%>')"> more </a></h4>
    </li>
  
	</ul>
	</span></td>
    <%}}%>             
                    
                </tr>
<%
                }

if( thisPageTotalLnCnt > MAX_LN_CNT_FOR_BOTTOM_PAGE_HEAD )
{
out.println(colHeadRow);
}
%>
                </table>
            </td>
        </tr>
        <!----------- Output available pages  ---------->
<%
out.println(pageHeadRow);
%>
        <!----------- Total Number of records  ---------->
        <tr bgcolor="<%=TABLE_OUTLINE_COLOR%>">
            <td colspan="10">
                <font color="#ffffff" class="smallBoldText">
                Total <%=recTotalCntInt%> record(s) found.
                </font>
                <img src="../gfx/b1x1.gif" height="20">
            </td>
        </tr>
        </table>
    </td>
</tr>
<BR>
<table align = "center">
<input type="hidden" name="excelUpload" value="no">
<input type="hidden" name="transId" value="<%=pTransId%>">

<tr>
   <td align="center">
      		   <b></b> <a href="javascript:uploadToExcel()" >Report </a> </b>
    </td>
   </tr>
 
</table>   
</table>
</form>

</center>

<%= Footer.pageFooter(globals) %>

<!------------ CcoPublishMonitorImageOutput.jsp : End  --------->

