<!--.........................................................................
: File name: IssuImageMasterList.jsp:
: Description:
:   - Create/Delete ISSU Image master list.
:
: Paramters:
:   act=edit: Issu Image Master List Edit page.
:             - adminSprit and adminIssu can access this page with act=edit.
:
:   act=view: Issu Image Master List View page.
:             - Open to public.
:
: AUTHORS:
: @author Nadia Lee (nadialee)
: @when: Aug 2006
:
: Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................
-->

<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.dataobject.IssuImageInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.issu.Issu" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
String THIS_FILE = "[IssuImageMasterList.jsp] ";
THIS_FILE = THIS_FILE.toString();

final String P_ACT_EDIT = "edit";
final String P_ACT_VIEW = "view";

SpritAccessManager spritAccessManager;
SpritGlobalInfo globals;
SpritGUIBanner banner;
String htmlButtonSubmit1;
String htmlButtonSubmit2;
String pathGfx;
String servletMessages;

// Initialize globals
globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );
spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );


// Set up banner for later
banner =  new SpritGUIBanner( globals );
banner.addContextNavElement( "REL:",
    SpritGUI.renderReleaseNumberNav(globals,null)
    );

// HTML macros
htmlButtonSubmit1 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSaveUpdates1",
            "Save Updates",
            "javascript:submitForm()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates1')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
            );

htmlButtonSubmit2 = ""
    + SpritGUI.renderButtonRollover(
            globals,
            "btnSaveUpdates2",
            "Save Updates",
            "javascript:submitForm()",
            pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
            "actionBtnSaveUpdates('btnSaveUpdates2')",
            "actionBtnSaveUpdatesOver('btnSaveUpdates2')"
            );
%>
<! ---------- IssuImageMasterList.jsp -------------- -->

<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>

<%

//-------------------------------------------------------------
// CES Monitor
//-------------------------------------------------------------
MonitorUtil monUtil = new MonitorUtil();

monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "ISSU Image Master List");

//-------------------------------------------------------------
// - This page behaves as two functions: 1) edit and 2) view.
// - Find out which one is required this time.
//-------------------------------------------------------------
String act = request.getParameter("act");

if( act == null ) { act = P_ACT_VIEW ; }
act = act.trim();
act = act.toLowerCase();
if( !act.equals(P_ACT_EDIT) ) { act=P_ACT_VIEW; }

//-----------------------------------------------------
// Only adminSprit and adminIssu can access this page
// with act=edit.
//-----------------------------------------------------
if( act.equals(P_ACT_EDIT) &&
    !spritAccessManager.isAdminSprit() &&
    !spritAccessManager.isAdminIssu() )
{
    response.sendRedirect("ErrorAccessPermissions.jsp");
}  // if( act.equals(P_ACT_EDIT) &&
%>

<span class="headline">
    <align="center">ISSU Image Master List<align="center">
</span><br /><br />

<%
//-----------------------------------------------------
// See if there were any messages generated
//-----------------------------------------------------
servletMessages = (String) request.getAttribute( "Sprit.servMsg" );

if( servletMessages!=null )
{
    PrintWriter printWriter;
    printWriter = response.getWriter();
    printWriter.print( ""
        + "<br />\n"
        + servletMessages
        + "<br /><br />\n\n"
        );
}  // if( servletMessages!=null )

Vector  issuImageVect       = Issu.getAllValidMasterIssuImage();
int     issuImageTotalCnt   = issuImageVect.size();

// ISSU is currenly available only for IOS.
Vector  iosOsTypeInfoVect          = Issu.getIosOsTypeInfo();
%>

<script language="javascript"><!--
// ===========================================================
// CUSTOM JAVASCRIPT ROUTINES
// ===========================================================

//---------------------------------------------------------------------
// Changes the update images if the form hasn't been submitted.
//---------------------------------------------------------------------
function actionBtnSaveUpdates(eName)
{
    fName = "issuImageEditForm";

    if( document.forms[fName].elements['_submittedFormFlag'].value==0 )
    {
        setImg( eName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
} // function actionBtnSaveUpdates(eName)

//---------------------------------------------------------------------
// Changes the over images if the form hasn't been submitted.
//---------------------------------------------------------------------
function actionBtnSaveUpdatesOver(eName)
{
    fName = "issuImageEditForm";

    if( document.forms[fName].elements['_submittedFormFlag'].value==0 )
    {
        setImg( eName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
} // function actionBtnSaveUpdatesOver(eName)

//---------------------------------------------------------------------
// Change the value to its uppercase.
//---------------------------------------------------------------------
function toUpper(obj)
{
    obj.value=obj.value.toUpperCase();
}

//---------------------------------------------------------------------
// Submit the form.
//---------------------------------------------------------------------
function submitForm()
{
    var THIS_FUNC = "[submitIssuImageMasterList.jsp: submitForm] ";
    var formObj;
    var elements;
    var fName = "issuImageEditForm";


    // Make a shortcut to our form's objects.
    formObj = document.forms[fName];
    elements = formObj.elements;

    // See if we've already submitted this form.  If so then halt!
    if( elements['_submittedFormFlag'].value==0 )
    {

        // Flag it.  Change the image too.
        elements['_submittedFormFlag'].value=1;

        setImg( 'btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );
        setImg( 'btnSaveUpdates2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

        //----------------------------------------------------
        // Submit the form.
        //----------------------------------------------------

        formObj.submit();

    }  // if( elements['_submittedFormFlag'].value==0 )

} // function submitForm

//--></script>

<form name="issuImageEditForm" action="IssuImageProcessor" method="post" >

<input type="hidden" name="_submittedFormFlag" value="0" />
<input type="Hidden" name="act"  value="<%=act%>" >

<center>

<%
if( act.equals( P_ACT_EDIT ) )
{
%>
<%= htmlButtonSubmit1 %><br /><br />
<%}
%>

<%
//----------------------------------------------------------------------
// Display summary.
//----------------------------------------------------------------------
%>
<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#BBD1ED">
                <table border="0" cellpadding="3" cellspacing="1">
                <tr bgcolor="#d9d9d9">
                    <td align="center" valign="top">
                        <span class="dataTableTitle">Total Number of Images</span>
                    </td>
                </tr>
                <tr bgcolor="#ffffff">
                    <td align="center" valign="top">
                        <span class="dataTableData"><%=issuImageTotalCnt%></span>
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

<!----------------------- Display ISSU Images ----------------------->
<table border="0" cellpadding="1" cellspacing="0">
<tr>
    <td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#BBD1ED">
                <table border="0" cellpadding="3" cellspacing="1">
                <tr bgcolor="#d9d9d9">
<%
                if( act.equals( P_ACT_EDIT ) )
                {
%>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">Delete</span>
                    </td>
<%              }
%>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">ISSU Image</span>
                    </td>
                    <td align="center" valign="top">
                        <span class="dataTableTitle">OS Type</span>
                    </td>

                </tr>
<%
            //-------------------------------------------------
            // Add new image
            //-------------------------------------------------
            if( act.equals( P_ACT_EDIT ) )
            {
%>
                <tr bgcolor="#ffffff">
                    <td align="left" valign="top">
                        <span class="dataTableData">&nbsp;</span>
                    </td>

                    <td align="center" valign="top">
                        <span class="dataTableTitle">Add</span>
                        <img src="../gfx/ico_arrow_right_orange.gif" />
                        <input type="text" size="20" name="newIssuImageName">
                    </td>
                    <td align="center" valign="top">
                        <select name="newIssuImageOsTypeId">
<%
                        if( iosOsTypeInfoVect!=null && !iosOsTypeInfoVect.isEmpty() )
                        {
%>
                            <option value=<%=(Integer) iosOsTypeInfoVect.elementAt(0)%>><%=(String) iosOsTypeInfoVect.elementAt(1)%></option>
<%
                        }
%>
                        </select>
                    </td>
                </tr>
<%
            } //  if( act.equals( P_ACT_EDIT ) )

//---------------------------------------------------
// Display retrieved ISSU image names, one per row.
//---------------------------------------------------
IssuImageInfo   issuImageInfo;
Integer         issuImageId;
String          issuImageName;
String          osTypeName;

for(int idx=0; idx<issuImageTotalCnt; idx++)
{
    issuImageInfo   = (IssuImageInfo) issuImageVect.elementAt(idx);
    issuImageId     = issuImageInfo.getIssuImageId();
    issuImageName   = issuImageInfo.getIssuImageName();
    osTypeName      = issuImageInfo.getOsTypeName();
%>
                <tr bgcolor="#ffffff">
<%
                if( act.equals( P_ACT_EDIT ) )
                {
%>
                    <td align="center" valign="top">
                        <input type=checkbox name=deleteIssuImageId value=<%=issuImageId%>>
                    </td>
<%              }
%>
                    <td align="left" valign="top">
                        <span class="dataTableData"><%=issuImageName%></span>
                    </td>
                    <td align="left" valign="top">
                        <span class="dataTableData"><%=osTypeName%></span>
                    </td>
                </tr>

<%
} // for(int idx=0; idx<issuImageTotalCnt; idx++)
%>
                </table>
            </td>
        </tr>
        </table>
    </td>
</tr>

</table>

<br />
<%
if( act.equals( P_ACT_EDIT ) )
{
%>
<%= htmlButtonSubmit2 %>
<%}
%>

</center>
</form>


<%= Footer.pageFooter(globals) %>

<%
//System.out.println("<----- IssuImageMasterList.jsp. END ----->" );
%>
