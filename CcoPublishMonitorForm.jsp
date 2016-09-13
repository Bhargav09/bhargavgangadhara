<!--.........................................................................
: DESCRIPTION: Customized report to view CCO Publishing Transaction status
:              based on user selected criteria.
:
: AUTHORS:
: @author nadialee
:
: WRITTEN WHEN:  Jun 2005
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<!------------ CcoPublishMonitorForm.jsp : Begin  --------->

<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>

<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSession" %>
<%@ page import="com.cisco.eit.sprit.logic.ccopublishmonitorsession.CcoPublishMonitorSessionHome" %>
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
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
final String THIS_PAGE                  = "[CcoPublishMonitorForm.jsp] ";
final String TABLE_OUTLINE_COLOR        = "#3d127b";
final String FORM_HEADING_BGCOLOR       = "#808080";
final String FORM_HEADING_TEXTCOLOR     = "#ffffff";
final String TABLE_CELL_GAP_COLOR       = "#BBD1ED";
final String TABLE_COL_HEADING_BGCOLOR  = "#d9d9d9";
final String TABLE_COL_DATA_COLOR       = "#ffffff";


SpritAccessManager spritAccessManager;
SpritGlobalInfo     globals;
SpritGUIBanner      banner;
String              htmlButtonSubmit1;
String              htmlButtonSubmit2;
String              pathGfx;
String              servletMessages;
String              loginUid        = "";
Timestamp           nowTimestamp    = SpritUtility.nowTimestamp();
String              todayDateStr    = SpritUtility.getMMddyyFomat2(nowTimestamp);

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

// HTML macros
htmlButtonSubmit1 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSubmit1",
            "Submit to reder output",
            "javascript:submitThisForm(document.forms['CcoPublishMonitorForm'])",
            pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
            "actionBtnSubmit('btnSubmit1')",
            "actionBtnSubmitOver('btnSubmit1')"
            );

htmlButtonSubmit2 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSubmit2",
            "Submit to reder output",
            "javascript:submitThisForm(document.forms['CcoPublishMonitorForm'])",
            pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
            "actionBtnSubmit('btnSubmit2')",
            "actionBtnSubmitOver('btnSubmit2')"
            );
%>

<%= SpritGUI.pageHeader( globals,"Monitor Menu","" ) %>
<%= banner.render() %>


<span class="headline">
    <align="center">CCO Publishing Transaction Monitor <align="center">
</span><br />

<%
// See if there were any messages generated
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
// Order By: defines items for 'Output Criteria - Order By' options.
//====================================================================
//-------------------------------------------------------------
// transOuputOrderByVect and imageOutputOrderByVect determines
// order of display in the drop down.
//-------------------------------------------------------------
Vector transOuputOrderByVect    = new Vector();
Vector imageOutputOrderByVect   = new Vector();

transOuputOrderByVect.addElement("swType");
transOuputOrderByVect.addElement("osType");
transOuputOrderByVect.addElement("transId");
transOuputOrderByVect.addElement("release");
transOuputOrderByVect.addElement("transType");
transOuputOrderByVect.addElement("transStatus");
transOuputOrderByVect.addElement("transStatusTime");
transOuputOrderByVect.addElement("transCreatedTime");
transOuputOrderByVect.addElement("transSubmitted By");

imageOutputOrderByVect.addElement("osType");
imageOutputOrderByVect.addElement("transId");
imageOutputOrderByVect.addElement("release");
imageOutputOrderByVect.addElement("transType");
imageOutputOrderByVect.addElement("transStatus");
imageOutputOrderByVect.addElement("transStatusTime");
imageOutputOrderByVect.addElement("transCreatedTime");
imageOutputOrderByVect.addElement("transSubmitted By");
imageOutputOrderByVect.addElement("imageName");
imageOutputOrderByVect.addElement("imageIsPublished");

//-------------------------------------------------------------
// ouputOrderByTextHash : determines displayed text on the form
//-------------------------------------------------------------
Hashtable ouputOrderByTextHash = new Hashtable();

ouputOrderByTextHash.put("swType", "SW Type");
ouputOrderByTextHash.put("osType", "OS Type");
ouputOrderByTextHash.put("transId", "Trans ID");
ouputOrderByTextHash.put("release", "Release");
ouputOrderByTextHash.put("transType", "Trans Type");
ouputOrderByTextHash.put("transStatus", "Trans Status");
ouputOrderByTextHash.put("transStatusTime", "Trans Status Time");
ouputOrderByTextHash.put("transCreatedTime", "Trans Submitted Time");
ouputOrderByTextHash.put("transSubmittedBy", "Trans Submitted By");
ouputOrderByTextHash.put("imageName", "Image Name");
ouputOrderByTextHash.put("imageIsPublished", "Is Image Published");


//==============================================================
//
//==============================================================
Context ctx;
CcoPublishMonitorSessionHome     ccoPublishMonitorSessionHome;
CcoPublishMonitorSession         ccoPublishMonitorSession;

Vector  allOsTypeVect = null;
Vector  aOsTypeVect;
Integer aOsTypeId;
String  aOsType;

try {

    ctx = JNDIContext.getInitialContext();

    Object homeObject    =
        ctx.lookup("CcoPublishMonitorSession.CcoPublishMonitorSessionHome");

    ccoPublishMonitorSessionHome =
        (CcoPublishMonitorSessionHome)PortableRemoteObject.narrow(homeObject, CcoPublishMonitorSessionHome.class);

    ccoPublishMonitorSession     = ccoPublishMonitorSessionHome.create();

    allOsTypeVect = ccoPublishMonitorSession.getAllOsType();


} catch(Exception e) {
    System.out.println(
        "[CcoPublishTransStatusForm] Error: CcoPublishMonitorSession create block");
    e.printStackTrace();
    throw e;
} // try: catch
%>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="JavaScript" src="../js/calendar.js"></script>

<script language="javascript"><!--
// ====================================================
// CUSTOM JAVASCRIPT ROUTINES
// ====================================================

//........................................................................
// DESCRIPTION:
// Changes the up/over images if the form hasn't been submitted.
//........................................................................
function actionBtnSubmit(elemName) {

//    if( document.forms['CcoPublishMonitorForm'].elements['_submitformflag'].value==0 )
//    {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT%>" );
//    }


}

function actionBtnSubmitOver(elemName) {
//    if( document.forms['CcoPublishMonitorForm'].elements['_submitformflag'].value==0 )
//    {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT_OVER%>" );
//    }
}

//........................................................................
// DESCRIPTION:
// Verifies value of input box 'recPerPageCnt'.
//
// - Value must be an integer between 1-30.
//........................................................................
function validateRecPerPageCnt( textObj, textName )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.validateRecPerPageCnt] ";

    cleanWhiteSpace( textObj );

    num = textObj.value;

    // Checking for a number.
    if( isNaN(num) )
    {
        alert( textName + " must be a number." );
        return false;
    } // if( isNaN(num) )

    num = Math.round( num );

    // Checking for a postivie number
    if( num < 1 || num > 30 )
    {
        alert( textName + " must be between 1 and 30." );
        return false;
    } // if( num < 1 )

    // Round the number just in case user enters a decimal number.
    textObj.value = num;

    return true;

} // function validateRecPerPageCnt

//........................................................................
// DESCRIPTION:
// Submit the form.
// - If the form is already submitted, halt ...
// - If not,
//    . change the value of '_submitformflag' to 1 to indicate that form is submitted.
//       (this functionality is removed.)
//    . change submit button to wait icon.
//    . validate required fields.
//    . submit the form.
//........................................................................
function submitThisForm( formObj)
{

    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.submitThisForm] ";

/*
    // See if we've already submitted this form.  If so then halt!
    //   1: already submitted.
    //   0: not yet submitted.
    if( formObj.elements['_submitformflag'].value==1 )
    { return;  }
*/

    if( ! validateFormElement( formObj ) )
    {
        return;
    }
    //----------------------------------------------------------------
    // Ready to submit the form.
    // - Flag it. (this functionality is removed)
    // - Change the image.
    // - And submit the form.
    //----------------------------------------------------------------
//    formObj.elements['_submitformflag'].value=1;

    setImg( 'btnSubmit1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
    setImg( 'btnSubmit2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

    formObj.submit();

} // function submitThisForm()

//........................................................................
// DESCRIPTION:
//  - validate all required fields.
//  - validate all date range
//........................................................................
function validateFormElement( formObj )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.validateFormElement] ";

    if( ! validateDateRange(formObj.elements['transDateFrom'], formObj.elements['transDateTo']) )
    {
        alert( "Please check CCO Publishing Transaction Date range.");
        return false;
    }

/*
    //
    // save the code in case we might use it in the future.
    //
    if( ! validateRequiredCheckbox( formObj.elements['ccoTransType'] ) )
    {
        alert( "Please select value(s) for 'Transaction Type'." );
        return false;
    }

    if( ! validateRequiredCheckbox( formObj.elements['ccoTransStatus'] ) )
    {
        alert( "Please select value(s) for 'Transaction Status'." );
        return false;
    }

*/

    if( ! cleanList( formObj.elements['osTypeList'] ) )
    {
        alert( "Please check your 'OS Type/Software Type' values." );
        return false;
    }

    if( ! validateRequiredList( formObj.elements['osTypeList'] ) )
    {
        alert( "Please select 'OS Type/Software Type'." );
        return false;
    }

    if( ! validateRecPerPageCnt( formObj.elements['recPerPageCnt'] ) )
    {
        return false;
    }

    return true;

} // function validateFormElement( formObj )

//........................................................................
// DESCRIPTION:
//  - validate a required checkbox.
//  - if "All" is checked, deselect every other options.
//........................................................................
function validateRequiredCheckbox( chkObj )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.validateRequiredCheckbox] ";

    if( chkObj==null || chkObj==undefined )
    { return true; }

    selected = false;
    for( i=0; i<chkObj.length; i++ )
    {
        if( chkObj[i].checked )
        {
            selected = true;

            // if "All" is checked, deselect every other options.
            if( chkObj[i].value.toUpperCase() == 'ALL' )
            {
                deselectCheckboxExcept( chkObj, i );
            }

            break;

        } // if( chkObj[i].chedked )
    } // for( i=0; i<chkObj.length; i++ )

    if( selected )
    { return true; }
    else
    { return false; }

} // function validateRequiredCheckbox( chkObj )

//........................................................................
// DESCRIPTION:
//  - Deselect every option of the checkbox EXCEPT the passed idx.
//
// IN: chkObj:  Checkbox object
//     idx:     Integer:
//              - index of checkboxObj to be saved. All other options
//                will be de-selected.
//........................................................................
function deselectCheckboxExcept( chkObj, idx )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.deselectCheckbox] ";

    if( chkObj==null || chkObj==undefined )
    { return true; }

    for( i=0; i<chkObj.length; i++ )
    {
        if( chkObj[i].checked && chkObj[i].value.toUpperCase() != 'ALL' )
        {
            chkObj[i].checked = false;
        }
    } // for( i=0; i<chkObj.length; i++ )

     return;

} // function deselectCheckboxExcept( chkObj, idx )

//........................................................................
// DESCRIPTION:
//  - From the select box, if 'Select All' (expected to have value -1)
//    is selected along with other items, de-select all the other items.
//  - This is to pass cleaned selection to the servelt.
//........................................................................
function cleanList( listObj )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.cleanList] ";

    if( listObj==null || listObj==undefined )
    { return true; }

    // see if 'Select All (value -1) is included in the user selection ...
    selectAll = false;
    for( i=0; i<listObj.length; i++ )
    {
        if( listObj.options[i].value == -1 && listObj.options[i].selected )
        {
            selectAll = true;
            break;
        }
    }

    // - 'Select All (value -1) is included.
    // - Deselect all the other user selection ...
    if( selectAll )
    {
        for( i=0; i<listObj.length; i++ )
        {
            if( listObj.options[i].value != -1 && listObj.options[i].selected )
            {
                listObj.options[i].selected = false;
            }
        }
    } // if( selectAll )

    return true;

} // function cleanList( listObj )


//........................................................................
// DESCRIPTION:
//  - validate a required list box.
//  - At least one must be selected. Otherwise, return false.
//........................................................................
function validateRequiredList( listObj )
{
    var THIS_FUNC = "[CcoPublishTransStatusForm.jsp.validateRequiredList] ";

    if( listObj==null || listObj==undefined )
    { return true; }

    selected = false;
    for( i=0; i<listObj.length; i++ )
    {
        if( ( listObj.options[i].value == -1 || listObj.options[i].value > 0 )
            && listObj.options[i].selected )
        {
            selected = true;
            break;
        }
    }

    if( selected )
    { return true; }
    else
    { return false; }

} // function validateRequiredList( listObj )

//--></script>

<form name="CcoPublishMonitorForm" action="CcoPublishMonitorProcessor" method="post">

<input type="hidden" name="_submitformflag" value="0">
<input type="hidden" name="pageNo"          value="1">

<center>

<%= htmlButtonSubmit1 %><br /><br />

<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="<%=FORM_HEADING_BGCOLOR%>">
        <table border="0" cellpadding="0" cellspacing="0">
        <!--  Section 1: Selection Criteria  -->
        <tr>
            <td align="center" valign="middle"><span class="sectionTitle">
                <img src="../gfx/b1x1.gif" height="20">
                <font color="<%=FORM_HEADING_TEXTCOLOR%>">Selection Criteria</font>
            </span></td>
        </tr>
        <tr>
            <td bgcolor="<%=TABLE_CELL_GAP_COLOR%>">
                <table border="0" cellpadding="3" cellspacing="1">

                <!--  CCO Publishing Transaction Date Range  -->
                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            CCO Publishing Transaction Date :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData">From : </span>
                        <input name="transDateFrom" size="12" maxlength="8"
                               value="<%=todayDateStr%>"
                               onChange="verifyDate(this);"
                               onFocus="this.blur();">
                        <a href="javascript:show_calendar('CcoPublishMonitorForm.transDateFrom');"
                            onmouseover="window.status='Date Picker';return true;"
                            onmouseout="window.status='';return true;"><img
                                src="../gfx/calendar.gif" width=24 height=22 border=0
                                align="absmiddle"></a>

                        <a href="javascript:clearField(document.forms['CcoPublishMonitorForm'].elements['transDateFrom']);">clear</a>

                        <img src="../gfx/b1x1.gif" width="20">
                        <span class="dataTableData">To : </span>
                        <input type="text" name="transDateTo" size="12" maxlength="8"
                               value="<%=todayDateStr%>"
                               onChange="verifyDate(this);"
                               onFocus="this.blur();">
                        <a href="javascript:show_calendar('CcoPublishMonitorForm.transDateTo');"
                            onmouseover="window.status='Date Picker';return true;"
                            onmouseout="window.status='';return true;"><img
                                src="../gfx/calendar.gif" width=24 height=22 border=0
                                align="absmiddle"></a>

                        <a href="javascript:clearField(document.forms['CcoPublishMonitorForm'].elements['transDateTo']);">clear</a>
                        </span>
                    </td>
                </tr>

                <!--  CCO Publishing Transaction Type  -->
<!--   Save this code just in case we might use it in the future

                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            Transaction Type* :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData">
                            <input type="checkbox" name="ccoTransType" value="all" checked>All

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransType" value="<%=YPublishConstants.YPUBLISH_POSTING_TYPE_POST%>"><%=YPublishConstants.YPUBLISH_POSTING_TYPE_POST%>

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransType" value="<%=YPublishConstants.YPUBLISH_POSTING_TYPE_REPOST%>"><%=YPublishConstants.YPUBLISH_POSTING_TYPE_REPOST%>

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransType" value="<%=YPublishConstants.YPUBLISH_POSTING_TYPE_DELETE%>"><%=YPublishConstants.YPUBLISH_POSTING_TYPE_DELETE%>

                        </span>
                    </td>
                </tr>
-->
                <!--  CCO Publishing Transaction Status  -->
<!--
                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            Transaction Status* :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData">
                            <input type="checkbox" name="ccoTransStatus" value="all" checked>All

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransStatus" value="<%=YPublishConstants.YPUBLISH_POSTING_STATUS_INPROGRESS%>"><%=YPublishConstants.YPUBLISH_POSTING_STATUS_INPROGRESS%>

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransStatus" value="<%=YPublishConstants.YPUBLISH_POSTING_STATUS_SUCCESS%>"><%=YPublishConstants.YPUBLISH_POSTING_STATUS_SUCCESS%>

                            <img src="../gfx/b1x1.gif" width="10">

                            <input type="checkbox" name="ccoTransStatus" value="<%=YPublishConstants.YPUBLISH_POSTING_STATUS_FAIL%>"><%=YPublishConstants.YPUBLISH_POSTING_STATUS_FAIL%>

                        </span>
                    </td>
                </tr>
-->

                <!--  OS Type/Software Type  -->
                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            OS Type / Software Type* :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <select name="osTypeList" size="4" multiple >
                            <option value="-1">Select All</option>
<%
                            for( int osIdx=0; osIdx<allOsTypeVect.size(); osIdx++ )
                            {
                                aOsTypeVect = (Vector)  allOsTypeVect.elementAt(osIdx);
                                aOsTypeId   = (Integer) aOsTypeVect.elementAt(0);
                                aOsType     = (String)  aOsTypeVect.elementAt(1);
%>

                                <option value="<%=aOsTypeId%>"><%=aOsType%></option>
<%
                            } // for
%>
                        </select>
                    </td>
                </tr>

                <!--  CCO Transaction Sbumitted by   -->
                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            CCO Publishing Transction Submitted By* :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <input type="radio" name="ccoTransSubmittedByUid" value="<%=loginUid%>" checked><%=loginUid%>

                        <img src="../gfx/b1x1.gif" width="10">

                        <input type="radio" name="ccoTransSubmittedByUid" value="">All
                    </td>
                </tr>

                <!--  Show all history?  -->
<!--

       // Save this section of code just in case we might need it in the future .

                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                           Apply to all transaction history?* :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <input type="radio" name="showHistory" value="Y">
                        <span class="dataTableData">
                            Yes (Use cautiously. It will generate huge amount of data.)
                        </span>

                        <br />

                        <input type="radio" name="showHistory" value="N" checked>
                        <span class="dataTableData">No (Recommended)</span>
                    </td>
                </tr>
-->

                <!--  Section #2: Output Criteria  -->
                <tr>
                    <td colspan="2" align="center" valign="middle" bgcolor="<%=FORM_HEADING_BGCOLOR%>">
                        <span class="sectionTitle">
                            <img src="../gfx/b1x1.gif" height="20">
                            <font color="<%=FORM_HEADING_TEXTCOLOR%>">Output Criteria</font>
                        </span>
                    </td>
                </tr>
                <tr>
                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_HEADING_BGCOLOR%>">
                        <span class="dataTableTitle">
                            Number of rows to display on the output page :
                        </span>
                    </td>

                    <td align="left" valign="top" bgcolor="<%=TABLE_COL_DATA_COLOR%>">
                        <span class="dataTableData">
                        <input type="text" name="recPerPageCnt" size="12" maxlength="2"
                               value="20"
                               onChange="javascript:validateRecPerPageCnt(document.forms['CcoPublishMonitorForm'].elements['recPerPageCnt'], 'Number of rows per output page');">
                        (Maximum: 30)
                        </span>
                    </td>
                </tr>
                </table>
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>

<br />

<%= htmlButtonSubmit2 %>

</center>
</form>

<%= Footer.pageFooter(globals) %>

<!------------ CcoPublishMonitorForm.jsp : End  --------->

