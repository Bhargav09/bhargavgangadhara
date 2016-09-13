<!--.........................................................................
: DESCRIPTION: Result page of CcoPublishMonitorForm.jsp after procesing is finished.
:   - Display one transaction per line.
:   - If a transaction has multiple releases (in case of non-IOS), the release numbers
:     will be displayed as comma-delimited per transaction.
:
: AUTHORS:
: @author nadialee
:
: WRITTEN WHEN:  July 2005
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<!------------ CcoPublishMonitorTransOutput.jsp : Begin  --------->

<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>

<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSession" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSessionHome" %>

<%@ page import="com.cisco.eit.sprit.dataobject.CcoPublishTransMonitorParamInfo" %>
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
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
final String THIS_FILE                  = "[CcoPublishMonitorTransOutput.jsp] " ;

final String TABLE_OUTLINE_COLOR        = "#3d127b";
final String PAGING_BGCOLOR             = "#808080";
final String TABLE_CELL_GAP_COLOR       = "#BBD1ED";
final String TABLE_COL_HEADING_BGCOLOR  = "#d9d9d9";
final String TABLE_COL_DATA_COLOR       = "#ffffff";

final String TRANS_OUTPUT_URL           = "CcoPublishMonitorTransOutput.jsp?";
final String IMAGE_OUTPUT_URL           = "CcoPublishMonitorImageOutput.jsp?";


final int    MAX_LN_CNT_FOR_BOTTOM_PAGE_HEAD    = 15;


String excelUpload = "no";
String transDateTo ="";
String transDateFrom = "";

SpritAccessManager  spritAccessManager;
SpritGlobalInfo     globals;
SpritGUIBanner      banner;
String              pathGfx;
String              servletMessages;
String              loginUid            = "";
int                 thisPageTotalLnCnt  = 0;

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

if(request.getParameter("excelUpload") != null)
{
	 excelUpload = request.getParameter("excelUpload");
	if(excelUpload.equals("yes"))
	{
		response.setContentType("application/vnd.ms-excel");
		
	}
}

transDateFrom = request.getParameter("transDateFrom");
transDateTo = request.getParameter("transDateTo");
%>

<%= SpritGUI.pageHeader( globals,"Monitor Menu","" ) %>
<%= banner.render() %>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="JavaScript" src="../js/calendar.js"></script>
<script language="JavaScript">
function uploadToExcel()
{
  document.transReport.excelUpload.value = "yes";
  document.transReport.method = "Get";
  document.transReport.submit();
 
}

</script>
<span class="headline">
    <align="center">CCO Publishing - Transaction Status<align="center">
</span>
<br />
<span class="subHeadline">
    <align="center">Sorted by Transaction ID <align="center"> <br>
    
</span>
<br />


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
// Parameter values, passed from CcoPublishMonitorProcessor.java.
// - Come to this page only after CcoPublishMonitorProcessor.java is
//   processed.
//--------------------------------------------------------------------
CcoPublishTransMonitorParamInfo paramInfo =
    (CcoPublishTransMonitorParamInfo) session.getAttribute("ccoTransMonitorParamInfo");

Integer recPerPageCnt   = paramInfo.getRecPerPageCnt();

//--------------------------------------------------------------------
// Determine the current page number.
//--------------------------------------------------------------------
String  pThisPageNo     = (String) request.getParameter("pg");
int     thisPageNoInt   = -1;
Integer thisPageNo;

// This is when the result output page is loaded for the first time.
// Default is the page no. 1.
if( pThisPageNo==null || pThisPageNo.trim().length()==0 )
{
    thisPageNoInt  = 1;
}
else
{
    thisPageNoInt = ( new Integer(pThisPageNo.trim()) ).intValue();
}

thisPageNo = new Integer(thisPageNoInt);

//====================================================================
// Get the output data for this page using user-selected criteria
// stored in session and page number from request.
//====================================================================
Context ctx;
CcoPublishMonitorSessionHome     ccoPublishMonitorSessionHome;
CcoPublishMonitorSession         ccoPublishMonitorSession;

try {

    ctx = JNDIContext.getInitialContext();

    ccoPublishMonitorSessionHome =(CcoPublishMonitorSessionHome)ctx.lookup("CcoPublishMonitorSession.CcoPublishMonitorSessionHome");

    
    ccoPublishMonitorSession     = ccoPublishMonitorSessionHome.create();


} catch(Exception e) {
    System.out.println(
        THIS_FILE + "Exception: CcoPublishMonitorSession create block");
    e.printStackTrace();
    throw e;
} // try: catch

//====================================================================
// Retrieve transaction ID and release ID that for this page only.
//====================================================================
//--------------------------------------------------------------------
// Retrieve distinct(transaction_id, release_id pair) that satifies
// the user criteria.
//--------------------------------------------------------------------
//Vector transIdReleaseIdByCriteriaVect =
//            ccoPublishMonitorSession.getPublishTransIdReleaseId( paramInfo );

Vector transIdByCriteriaVect =
            ccoPublishMonitorSession.getPublishTransId( paramInfo );

// - Find the total number of output pages.
// - Last page may have less number of records to display.
Integer pageTotalCnt = SpritUtility.getPageTotalCnt(
                                    transIdByCriteriaVect,
                                    recPerPageCnt);

// Retrieve for this page only.
Vector thisPageTransIdVect = SpritUtility.getThisPageItemVect(
                                    transIdByCriteriaVect,
                                    thisPageNo,
                                    recPerPageCnt );

/*
// - This section is not needed when the trans info report output
//   displays a transaction per line.
// - This section was needed when the report displayed
//   (transaction, release) pair per line.
Vector thisPageReleaseIdVect = SpritUtility.getThisPageItemVect(
                                    allReleaseIdByCriteriaVect,
                                    thisPageNo,
                                    recPerPageCnt );

// Remove duplicate items to optimize query later.
Vector thisPageUniqueTransIdVect = SpritUtility.removeDuplicateInteger(
                                            thisPageTransIdVect );

Vector thisPageUniqueReleaseIdVect = SpritUtility.removeDuplicateInteger(
                                    thisPageReleaseIdVect );
// ----- end of commenting out
*/

int     pageTotalCntInt = pageTotalCnt.intValue();


int     recTotalCntInt  = transIdByCriteriaVect.size();




if(excelUpload.equals("yes"))
{
	thisPageTransIdVect =transIdByCriteriaVect; 
	response.setContentType("application/vnd.ms-excel");
	
}

//====================================================================
// Retrieve CCO yPublish transaction information to display for this page
//====================================================================
paramInfo.setPageTotalCnt(pageTotalCnt);
paramInfo.setRecTotalCnt(new Integer(recTotalCntInt));
paramInfo.setThisPageTransIdVect(thisPageTransIdVect);
//paramInfo.setThisPageReleaseIdVect(thisPageUniqueReleaseIdVect);
paramInfo.setThisPageNo(thisPageNo);

/* Commented by Sham for modifying the report. This method is currently used to get the report data

Vector outputVect = ccoPublishMonitorSession.ProcessPublishTransInfo( paramInfo ); 

*/

Vector outputVect = ccoPublishMonitorSession.ProcessPublishTransInfo( paramInfo );





//=========================================================================
// Make Table paging header
//=========================================================================
	

StringBuffer pageHeadRow = new StringBuffer();

    pageHeadRow = pageHeadRow
    		.append("  <form name=\"transReport\" action=\"CcoPublishMonitorTransOutput.jsp\" > \n")
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
     
            if(excelUpload.equals("no"))
            {
            	pageHeadRow.append("                <font color=\"#55ff00\"><span class=\"smallBoldText\">");
               	pageHeadRow.append(i);
            }
            if(excelUpload.equals("yes"))
            {
            
            	pageHeadRow.append("                <font color=\"#ffffff\"><span class=\"sectionTitle\">");

            	pageHeadRow.append("Transaction Report From: ");
            	pageHeadRow.append(transDateFrom);
            	pageHeadRow.append(" To: ");
            	pageHeadRow.append(transDateTo);
            }
            
           
            pageHeadRow.append("</span></font> \n");
   }
   else
   {
        pageHeadRow = pageHeadRow
            .append("                <font color=\"#ffffff\" >")
            .append("<span class=\"smallBoldText\">")
            .append("<a href=\"").append(TRANS_OUTPUT_URL).append("&pg=");
	        if(excelUpload.equals("no"))
	        {
	         	pageHeadRow.append(i).append("\" >");
	        }
	                   
	        pageHeadRow.append(i).append("</a></span></font> \n");
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

colHeadRow = colHeadRow.append("                <tr> \n")
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Ln</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("SW Type</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Transaction ID</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Release</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Transaction Type</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Submit Time</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Submitted By</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Current Status</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Current Status Time (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Snap Copy Time(Minutes)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Trans.Begin Time (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Snap Copy End Time (PST)</span> \n")
          .append("                    </td> \n" )
           .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Total Trans.Time </span> \n")
          .append("                    </td> \n" )
           .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Trans.End Time (PST)</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Image Size(bytes)</span> \n")
          .append("                    </td> \n" )
           .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Total Images</span> \n")
          .append("                    </td> \n" )
           .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Prioritized</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Bus.Unit</span> \n")
          .append("                    </td> \n" )
          .append("                    <td align=\"center\" valign=\"top\" ")
          .append("bgcolor=\"")
          .append(TABLE_COL_HEADING_BGCOLOR)
          .append("\"> \n")
          .append("                        <span class=\"dataTableTitle\">")
          .append("Image Info</span> \n")
          .append("                    </td> \n" )
          .append("                </tr> \n" );

%>

<br />
<a href="CcoPublishMonitorForm.jsp">New Search </a>


<br />

<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="<%=PAGING_BGCOLOR%>">
        <table border="0" cellpadding="0" cellspacing="0">
<%
out.println(pageHeadRow);
%>
        <tr>
            <td bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                <table border="0" cellpadding="3" cellspacing="1" width="100%">
<%
out.println(colHeadRow);

                CcoPublishTransInfo  aRow;
                String               imageInfoUrl;
                HashMap				 transactionDetailsMap;

                thisPageTotalLnCnt = outputVect.size() + 1;

                Vector  relNumVect;
                String  relListStr = "";

                for( int rowIdx=0; rowIdx<outputVect.size(); rowIdx++ )
                {
                    aRow = (CcoPublishTransInfo) outputVect.elementAt(rowIdx);
                    
                    imageInfoUrl =
                        IMAGE_OUTPUT_URL +
                        "transId=" + aRow.getTransId() +
                        "&pg=1";

                    // Make a comma-delimited release number string.
                    relNumVect = aRow.getReleaseNumberVect();
                    
                    //New additions in the report 
                    transactionDetailsMap = aRow.getTransactionDetailsMap();
                    
                    
                    if( relNumVect==null || relNumVect.isEmpty() )
                    {
                        relListStr = "&nbsp;";
                    }
                    else
                    {
                        for( int relIdx=0; relIdx<relNumVect.size(); relIdx++ )
                        {
                            if( relIdx==0 )
                            {  relListStr = (String) relNumVect.elementAt(relIdx); }
                            else
                            {  relListStr += ", &nbsp; " + (String) relNumVect.elementAt(relIdx); }
                        } // for
                    } // else
%>
                <tr bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getLnCnt().intValue()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getOsType()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getTransId()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=relListStr%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getTransType()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=SpritUtility.getMMddyyyyFomat(aRow.getTransCreatedTime())%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getTransCreatedByUid()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=aRow.getTransStatus()%></span>
                    </td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=SpritUtility.getMMddyyyyFomat(aRow.getTransStatusTime())%>
                    </span></td> 
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_transaction_time") != null? transactionDetailsMap.get("snap_mirror_transaction_time"):""%>
                    </span></td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_begin_time") != null? transactionDetailsMap.get("snap_mirror_begin_time"):""%>
                    </span></td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("snap_mirror_end_time") != null? transactionDetailsMap.get("snap_mirror_end_time"):""%>
                    </span></td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("total_transaction_time") != null? transactionDetailsMap.get("total_transaction_time"):""%>
                    </span></td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("transaction_end_time") != null? transactionDetailsMap.get("transaction_end_time"):""%>
                    </span></td>
                     <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("image_size") != null? transactionDetailsMap.get("image_size"):""%>
                    </span></td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("no_of_images") != null? transactionDetailsMap.get("no_of_images"):""%>
                    </span></td>
                         <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("priority_value") != null? transactionDetailsMap.get("priority_value"):""%>
                    </span></td>
                       <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><%=transactionDetailsMap.get("business_unit_name") != null? transactionDetailsMap.get("business_unit_name"):""%>
                    </span></td>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData"><a href="<%=imageInfoUrl%>" target="imageWindow">Image Info</a></span>
                    </td>
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
<%
out.println(pageHeadRow);
%>
        <tr bgcolor="<%=TABLE_OUTLINE_COLOR%>">
            <td colspan="10">
                <font color="#ffffff" class="smallBoldText">
                Total <%=recTotalCntInt%> Record(s) found.
                </font>
                <img src="../gfx/b1x1.gif" height="20">
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>

<br />

<BR>
<table align = "center">
<input type="hidden" name="excelUpload" value="no">
<input type="hidden" name="transDateFrom" value="<%=transDateFrom %>">
<input type="hidden" name="transDateTo" value="<%=transDateTo%>">


<tr>
   <td align="center">
      		    <a href="javascript:uploadToExcel()" >Report </a>
    </td>
   </tr>
   </form>
</table>   

<%= Footer.pageFooter(globals) %>

<!------------ CcoPublishMonitorTransOutput.jsp : End  --------->

