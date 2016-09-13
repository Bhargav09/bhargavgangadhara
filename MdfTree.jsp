<!--.........................................................................
: DESCRIPTION:
: MDF Navigator
:
: AUTHORS:
: @author Nadia Lee (nadialee@cisco.com)
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Vector" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<!-- SPRIT -->
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.logic.mdfsession.MdfSessionHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.logic.mdfsession.MdfSessionLocal" %>

<%@ page import="com.cisco.eit.sprit.dataobject.MdfInfo" %>

<%
//
// Initialize globals
//
SpritGlobalInfo globals;
String          pathGfx;
final String    THIS_FILE = "[MdfTree.jsp] ";
long            startTime = System.currentTimeMillis();
long            now       = System.currentTimeMillis();

globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );

System.out.println("\n<===== " + THIS_FILE + "BEGIN =====>" );
%>

<script language="javascript">

// window.opener.parent.document.editUp.submit();
function closeForm()
{
     self.close();
}  // function closeForm

//reloads the parent page
function reLoad()
{
    window.opener.parent.document.editUp.submit();
}  // function reLoad

</script>

<%
//----------------------------------------------------------
// Parse parameters
// - f: form name.
//      -- user-selected MDF IDs will be passed back to this form.
//
// - e: elemenet name on 'f'.
//      -- user-selected MDF IDs will be passed back to this element
//         on the passed form.
//
// - swType: software type. ex: VxWorks.
//      -- Will display MDF tree that are associated with
//         this swType.
//----------------------------------------------------------
String parentFname                  = request.getParameter("f");
String parentMdfObjName             = request.getParameter("ename");
String parentMdfObjtype             = request.getParameter("etype");
String parentMdfIdHiddenObjName     = request.getParameter("mdfIdHidden");
String parentMdfNameHiddenObjName   = request.getParameter("mdfNameHidden");
String swType                       = request.getParameter("swType");
String[] mdfArr                     = request.getParameterValues("mdf");
%>

<%=SpritGUI.pageHeader( globals, "MDF Based Cisco Product", "" ) %>
<%=SpritGUI.pageBanner( globals, "popup","MDF Based Cisco Product - " + swType ) %>

<%
Context             ctx;
MdfSessionHomeLocal mdfHome;
MdfSessionLocal     mdfObj;
String              jndiName;
List                mdfTreeList;
ArrayList           mdfTreeArrayList;
Vector              startingMdfIdVect;
String              mdfStr  = "";


// - mappedMdfIdVect. Vector of Integer.
//        Contains MDF IDs that are passed from calling form.
// - Will be used to see if any of these already associated MDF became
//   obsoleted.
// - Already associated, but obsoleted ones will show up in the MDF Navigator
//   to give a capability of de-associating them.

Vector              mappedMdfIdVect = new Vector();

// invalidMappedMdfInfoVect.
//      Contains mapped MDF that became invalid.
//      ex: shr_mdf_products_attr.adm_flag <> 'V'.
//
// obsoleteMappedMdfInfoVect: Contains mapped, but obsolete MDF.
Vector  invalidMappedMdfInfoVect;
Vector  obsoleteMappedMdfInfoVect;

try
{
/*
    System.out.println( THIS_FILE + "parentFname=" + parentFname +
        ", parentMdfObjName=" + parentMdfObjName +
        ", parentMdfObjtype=" + parentMdfObjtype +
        ", parentMdfIdHiddenObjName=" + parentMdfIdHiddenObjName +
        ", parentMdfNameHiddenObjName=" + parentMdfNameHiddenObjName );
*/
    // Required parameter values:
    if( parentFname==null || parentFname.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'f' is null.");
    }
    if( parentMdfObjName==null || parentMdfObjName.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'e' is null.");
    }
    if( swType==null || swType.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'swType' is null.");
    }

    // parentMdfObjtype: only select box and textarea are handled to
    // passed back the selected MDF values.
    if( parentMdfObjtype==null || parentMdfObjtype.trim().length()==0  )
    {
        parentMdfObjtype="select";
    }
    if( !parentMdfObjtype.equals("select") &&
        !parentMdfObjtype.equals("textarea") &&
        !parentMdfObjtype.equals("div") )
    {
        throw new Exception( THIS_FILE + "Paremeter 'parentMdfObjtype' has unknown value '" +
            parentMdfObjtype + "'.");
    }

    //
    // If parentMdfObjtype=="select", parentMdfIdHiddenObjName is ignored.
    //
    if( parentMdfIdHiddenObjName==null || parentMdfObjtype.trim().length()==0 )
    {
        parentMdfIdHiddenObjName="";
    }
    if( parentMdfNameHiddenObjName==null || parentMdfNameHiddenObjName.trim().length()==0 )
    {
        parentMdfNameHiddenObjName="";
    }

    parentFname = parentFname.trim();
    parentMdfObjName = parentMdfObjName.trim();
    swType      = swType.trim();

    // 1) Turn the passed multiple mdfId$mdfCocnept into a long string.
    //    This string will be used to check the MDF tree element if substring
    //    matches with MDF ID in the tree.
    //
    // 2) Reformat passed MDF IDs into mappedMdfIdVect.
    //    Will be used to check if any of these already associated MDF
    //    became obsolete, and if obsolete it will be still included in MDF tree

    StringTokenizer st;

    if( mdfArr!=null && mdfArr.length>0 )
    {
        for( int i=0; i<mdfArr.length; i++ )
        {
            if( mdfStr==null || mdfStr=="" )
            { mdfStr = mdfArr[i] ; }
            else
            { mdfStr += "@" + mdfArr[i]; }

            // Will be used to check if any of these
            // already associated MDF became obsoleted.

            st  = new StringTokenizer(mdfArr[i], "$" );
            mappedMdfIdVect.addElement( new Integer(st.nextToken()) );
        }
    }

//    now = System.currentTimeMillis();
//    System.out.println( THIS_FILE + "Ready to retrieve MDF from DB. " + (now-startTime)/1000 + " sec from start." );

    jndiName    = "MdfSession.MdfSessionHome";
    ctx         = new InitialContext();
    mdfHome     = (MdfSessionHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    mdfObj      = mdfHome.create();
    
    /** @dmarwaha
    Change for displaying the IOSXR (IOX) MDF concepts correctly in Aadmin page - IOS Platform Mappings
    Also update MdfTreePost.jsp
   */
    System.out.println("SWT in MDFTREE: "+swType);
    if(swType.equalsIgnoreCase("IOX")){
    	swType="IOS XR Software";
    }
    startingMdfIdVect   = mdfObj.getAllStartingMdfId(swType);
    mdfTreeList         = (List) mdfObj.getMdfTree(swType, mappedMdfIdVect);
    invalidMappedMdfInfoVect  =
            mdfObj.getInvalidMdf(mappedMdfIdVect);
    obsoleteMappedMdfInfoVect  =
            mdfObj.getObsoleteMdf(mappedMdfIdVect);

    now = System.currentTimeMillis();
//    System.out.println( THIS_FILE + "Finish retrieving tree from DB for '" + swType + "'. " + (now-startTime)/1000 + " sec from start. mdfTreeList.size()=" + mdfTreeList.size() );

    //---------------------------------------------------------------
    // If no top mdf found for the given software type
    //---------------------------------------------------------------
    if( startingMdfIdVect==null || startingMdfIdVect.isEmpty() )
    {
        throw new Exception( "There is no starting MDF concept found for " +
            "Software Type '" + swType + "'.");
    }

    if( mdfTreeList==null || mdfTreeList.isEmpty() )
    {
        throw new Exception( "There is no MDF concept found for " +
            "Software Type '" + swType + "'.");
    }
//    System.out.println( THIS_FILE + "DEBUG 5. mdfTreeList.size()=" + mdfTreeList.size() );


String tmpMdfId;
String tempMdfStr;

%>

<html>
<head>
    <title>SPRIT - MDF Based Cisco Product</title>
    <link rel="StyleSheet" href="../css/dtree.css" type="text/css" />
</head>
<body onLoad = "reLoad()">

<!--  Display waiting image while retrieving info from DB -->
<!--
<img src="../gfx/ico_waitloading.gif" name="pleasewait" alt="Please wait while displaying">
-->

<form name="mdfTreeForm" method="get" action="">

<input type="hidden" name="parentFname"      value="<%=parentFname%>">
<input type="hidden" name="parentMdfObjName" value="<%=parentMdfObjName%>">

<table border="0" cellpadding="2" cellspacing="0">
<tr>
    <td bgcolor="#bbd1ed">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#ffffff">
                <table border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td bgcolor="#bbd1ed">
                        <img src="../gfx/b1x1.gif" width="8" />
                    </td>
                    <td bgcolor="#bbd1ed">
                        <span class="infoboxTitle">
                            <b>Selected MDF Based Cisco Product</b>
                        </span>
                    </td>

                    <td background="../gfx/wedge_lightblue.gif">
                        <img src="../gfx/b1x1.gif" width="24" height="1" />
                    </td>
                    <td>
                        <img src="../gfx/b1x1.gif" width="20" border="0">
                    </td>
                </tr>
                </table>

                <table border="0" cellpadding="8" cellspacing="0">
                <tr>
                    <td>
                        <img src="../gfx/b1x1.gif" width="20" border="0">
                    </td>
                    <td align="left">
                        <select name="mdfList" multiple size="4">
<%
                        if(mdfArr==null || mdfArr.length==0 )
                        {
%>
                            <option value="0">-- None Selected --</option>
<%
                        }
                        else
                        {
                            for( int i=0; i<mdfArr.length; i++ )
                            {
                                st = new StringTokenizer(mdfArr[i], "$" );
%>
                            <option value="<%=st.nextToken()%>"><%=st.nextToken()%></option>
<%
                            }
                        }
%>
                        </select>
                    </td>
                </tr>
<%
                //-------------------------------------------------
                // List currently mapped, but OBSOLETE MDFs.
                //-------------------------------------------------
                if( obsoleteMappedMdfInfoVect!=null &&
                    ! obsoleteMappedMdfInfoVect.isEmpty() )
                {
                    Vector  aMdfInfo;
                    Integer aMdfId;
                    String  aMdf;
                    String  obsoleteMdfListStr = "";
%>
                <tr>
                    <td align="left" valign="top" class="warningTextSmall">
                        <b>Obsolete MDF:</b>
                    </td>
                    <td align="left" valign="top" class="warningTextSmall">
                        <select name="obsoleteMdfList" size="2">
<%
                    for( int obsoleteMdfIdx=0; obsoleteMdfIdx<obsoleteMappedMdfInfoVect.size(); obsoleteMdfIdx++ )
                    {
                        aMdfInfo = (Vector) obsoleteMappedMdfInfoVect.elementAt(obsoleteMdfIdx);

                        if( aMdfInfo == null || aMdfInfo.isEmpty() )
                        {
                            System.out.println("aMdfInfo = NULL");
                        }
                        else
                        {
                            aMdfId  = (Integer) aMdfInfo.elementAt(0);
                            aMdf    = (String) aMdfInfo.elementAt(1);
%>
                                <option value="<%=aMdfId%>"><%=aMdf%></option>
<%
                        } // else:  if( aMdfInfo == null || aMdfInfo.isEmpty() )

                    } // for
%>
                        </select>
                    </td>
                </tr>
<%
                }

                //-------------------------------------------------
                // List currently mapped, but INVALID MDFs.
                //-------------------------------------------------
                if( invalidMappedMdfInfoVect!=null &&
                    ! invalidMappedMdfInfoVect.isEmpty() )
                {
%>
                <tr>
                    <td align="left" valign="top" class="warningTextSmall">
                        <b>Deleted MDF from <br />
                           originally <br />
                           selected MDF :</b>
                    </td>
                    <td align="left" valign="top">
                        <select name="invalidMdfList" size="2">
<%
                    Vector  aMdfInfo;
                    String  invalidMdfListStr = "";
                    Integer aMdfId;
                    String  aMdf;

                    for( int invalidMdfIdx=0; invalidMdfIdx<invalidMappedMdfInfoVect.size(); invalidMdfIdx++ )
                    {
                        aMdfInfo = (Vector) invalidMappedMdfInfoVect.elementAt(invalidMdfIdx);

                        if( aMdfInfo == null || aMdfInfo.isEmpty() )
                        {
                            System.out.println("aMdfInfo = NULL");
                        }
                        else
                        {
                            aMdfId  = (Integer) aMdfInfo.elementAt(0);
                            aMdf    = (String) aMdfInfo.elementAt(1);
%>
                                <option value="<%=aMdfId%>"><%=aMdf%></option>
<%
                        } // else:  if( aMdfInfo == null || aMdfInfo.isEmpty() )

                    } // for
%>
                        </select>
                    </td>
                </tr>
<%
                }
%>
                </table>
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>

<center>
<table>
<tr>
    <td>
        <img src="../gfx/btn_submit.gif" alt="Save Updates" border="0"
            name="btnSaveUpdate1"
            onclick="javascript:submitTreeForm('mdfTreeForm', 'mdfChkBox', '<%=parentFname%>', '<%=parentMdfObjName%>','<%=parentMdfObjtype%>', '<%=parentMdfIdHiddenObjName%>', '<%=parentMdfNameHiddenObjName%>');" />
    </td>
    <td>
        <img src="../gfx/b1x1.gif" width="20" border="0">
    </td>
    <td>
        <a class="nostyle"
            href="javascript:document.forms['mdfTreeForm'].reset();updateThisForm(document.forms['mdfTreeForm'].elements['mdfChkBox'],
             document.forms['mdfTreeForm'].elements['mdfList'],
             document.forms['mdfTreeForm'].elements['obsoleteMdfList'] );"><img
            src="../gfx/btn_resetfield.gif" border="0" name="Reset"
            alt="Reset"></a>
    </td>
</tr>
</table>
</center>

<font class="instructionText">Please select all MDF based Cisco products to associate with your platform or image.</font>
<br /><br />

<p>
<font class="instructionText">
<a href="javascript: mdfTree.openAll();">open all</a> |
<a href="javascript: mdfTree.closeAll();">close all</a>
</font>
</p>
<br />

<%
// Get the first MDF parent ID.
MdfInfo     mdfInfo;
Integer     mdfIdInt;
int         mdfId;
int         startingMdfId = 0;
String      mdfName;
String      metaclass;

%>
<div class="tree">

<%--Start JS for tree--%>
<script language="JavaScript" src="../js/dtree.js"></script>
<script language="JavaScript" src="../js/MdfTree.js"></script>
<script language="JavaScript">

    mdfTree = new dTree('mdfTree');

    mdfTree.config.useSelection=false;
//    mdfTree.config.closeSameLevel=false;
    mdfTree.config.useCookies=false;

    mdfTree.add( 0, -1, 'MDF Based Cisco Product - <%=swType%>', '', '');

<%
    int cnt = 0;

    if(mdfTreeList != null)
    {

        Iterator iter = mdfTreeList.iterator();

        while(iter.hasNext())
        {
            cnt++;

            mdfInfo = (MdfInfo)iter.next();

            mdfIdInt    = mdfInfo.getMdfId();
            mdfId       = mdfIdInt.intValue();
            mdfName     = mdfInfo.getMdfConceptName();
            metaclass   = mdfInfo.getMetaclass();

            //
            // Sometimes, metaclass is null.
            //
            if(mdfName==null) { mdfName = ""; }
            if(metaclass==null) { metaclass = ""; }

            //
            // - following code is added because sometimes the data
            //   available may break the javascript.
            // - following code will ensure that the javascript does not
            // break and the data is shown as is.
            //
            if( mdfName.indexOf("\r\n") > 0 )
            {
                mdfName = SpritUtility.replaceString(mdfName, "\r\n", "");
            }
            if( mdfName.indexOf("\"") > 0 )
            {
                mdfName = SpritUtility.replaceString(mdfName, "\"", "&!!");
            }
            if( mdfName.indexOf("'") > 0 )
            {
                mdfName = SpritUtility.replaceString(mdfName, "'", "&!!!");
            }

            if( metaclass.indexOf("\r\n") > 0 )
            {
                metaclass = SpritUtility.replaceString(metaclass, "\r\n", "");
            }
            if( metaclass.indexOf("\"") > 0 )
            {
                metaclass = SpritUtility.replaceString(metaclass, "\"", "&!!");
            }
            if( metaclass.indexOf("\"") > 0 )
            {
                metaclass = SpritUtility.replaceString(metaclass, "'", "&!!!");
            }

            if( startingMdfIdVect.contains(mdfIdInt) )
            {
%>

/*
                // Write tree each time top node changes.
                // This way, there won't be too many node to display.
                // Browser can handle only up ~2000 nodes at a time.
                document.write(mdfTree);
                mdfTree = new dTree('mdfTree');
*/
/*
                mdfTree.add( <%=mdfId%>, -1, '<%=mdfName%>', '', '');
*/
                mdfTree.add( <%=mdfId%>, 0, '<%=mdfName%>', 'topnode', '');
<%
            }
            else
            {
%>
                mdfTree.add(<%= mdfId %>, <%= mdfInfo.getMdfParentId().intValue() %>, '<%=mdfName%>', '<%=metaclass%>', '' );
<%
            } // else
        }
    }
//    System.out.println( THIS_FILE + "*** Writing mdfTree *** cnt=" + cnt );
%>
    //----------------------------------------------
    // write the tree
    //----------------------------------------------
    document.write(mdfTree);

</script>
</div>

<center>
<table>
<tr>
    <td>
        <img src="../gfx/btn_submit.gif" alt="Save Updates" border="0"
            name="btnSaveUpdate2"
            onclick="javascript:submitTreeForm('mdfTreeForm', 'mdfChkBox', '<%=parentFname%>', '<%=parentMdfObjName%>','<%=parentMdfObjtype%>', '<%=parentMdfIdHiddenObjName%>', '<%=parentMdfNameHiddenObjName%>');" />
    </td>
    <td>
        <img src="../gfx/b1x1.gif" width="20" border="0">
    </td>
    <td>
        <a class="nostyle"
            href="javascript:document.forms['mdfTreeForm'].reset();updateThisForm(document.forms['mdfTreeForm'].elements['mdfChkBox'],
             document.forms['mdfTreeForm'].elements['mdfList'],
             document.forms['mdfTreeForm'].elements['obsoleteMdfList'] );"><img
            src="../gfx/btn_resetfield.gif" border="0" name="Reset"
            alt="Reset"></a>
    </td>
</tr>
</table>
</center>


</form>


</body>
</html>

<%=Footer.pageFooter(globals)%>

<%
now = System.currentTimeMillis();
System.out.println("<===== " + THIS_FILE + "END.  Took " + (now-startTime)/1000 +
    " sec. MDF cnt=" + cnt + " xxx =====>\n" );

} catch( Exception e ) {

//    throw new Exception (e.getMessage());

    System.out.println( THIS_FILE + e.getMessage() );
    System.out.println("<===== " + THIS_FILE + "END =====>\n" );

    out.println( SpritGUI.renderErrorBox( globals,
        "MDF Navigator Error for '" + swType + "'",
        e.getMessage()
        ) );

}  // catch
%>
