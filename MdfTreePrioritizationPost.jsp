<!--.........................................................................
: DESCRIPTION:
:   MDF Navigator Popup window.
:
:   - Displays passed MDF IDs and MDF names in the select box at the top of
:     the page for user visibility.

:   - If any of these MDF are marked 'D' in the DB, it displays them in
:     'Deleted MDF from originally selected MDF' select box in the
:     'Selected MDF Based Cisco Product' section at the top.

:   - If any of the associated MDF are not found to be Obsolete in the DB,
:     it displays them in 'Obsoleted MDF' box in the
:     'Selected MDF Based Cisco Product' section at the top.

:   - As user select/deselect MDF from the MDF tree, 'Currently Mapped MDF'
:     will be udated to reflect the latest selection on this form.
:   - When this popup gets submitted, it will update the calling form in the
:     following elements:
:        a. MDF Display object (either textarea or div only)
:        b. MDF IDs in the hidden field ($-delimited)
:        c. MDF names in the hidden field ($-delimited)
:
:   NOTE:
:   - To pass a large volume of MDF from the calling form, the calling form
:     must submit MDF info thru POST method. Otherwise, this MDF navigator will break
:     due to not being able to read the info coming as GET.
:
: AUTHORS:
: @author Nadia Lee (nadialee@cisco.com)
:
: Copyright (c) 2005, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Vector" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>


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
<%@ page import="com.cisco.eit.sprit.model.prioritization.RequestPrioritizationJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.MdfInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.RequestPrioritizationInfo" %>
<%@ page import = "java.util.StringTokenizer" %>


<%
//
// Initialize globals
//
SpritGlobalInfo globals;
String          pathGfx;
final String    THIS_FILE = "[MdfTreePrioritizationPost.jsp] ";
long            startTime = System.currentTimeMillis();
long            now       = System.currentTimeMillis();

globals = SpritInitializeGlobals.init(request,response);
pathGfx = globals.gs( "pathGfx" );

Vector mdfSavedListVector			   = null;




// System.out.println("\n<===== " + THIS_FILE + "BEGIN =====>" );
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
// - These parameters from 'MdfTreeJavaScriptForm' that
//   contains the values passed from the calling form.
//----------------------------------------------------------
String dispFname            = request.getParameter("dispFname");
String dispEname            = request.getParameter("dispEname");
String dispEtype            = request.getParameter("dispEtype");
String hiddenFname          = request.getParameter("hiddenFname");
String hiddenMdfIdEname     = request.getParameter("hiddenMdfIdEName");
String hiddenMdfNameEname   = request.getParameter("hiddenMdfNameEname");
String swType               = request.getParameter("swType");
String osTypeId              = request.getParameter("osTypeId");
String sessionmdfDiv         = request.getParameter("sessionmdfDiv");



//----------------------------------------------------------
// - "hiddenMdfId" and "hiddenMdfName" are also from
//   'mdfTreeJavaScriptForm.' form.
// - contains $-delimeted midId values nad $-delimited mdfName values
//   that are read from calling form and saved into
//   'mdfTreeJavaScriptForm'.
//----------------------------------------------------------
String hiddenMdfIdVals   = request.getParameter("hiddenMdfId");   // $-delimeted value
String hiddenMdfNameVals = request.getParameter("hiddenMdfName"); // $-delimeted value


dispFname           = dispFname==null ?          "" : dispFname.trim() ;
dispEname           = dispEname==null ?          "" : dispEname.trim() ;
dispEtype           = dispEtype==null ?          "" : dispEtype.trim() ;
hiddenFname         = hiddenFname==null ?        "" : hiddenFname.trim() ;
hiddenMdfIdEname    = hiddenMdfIdEname==null ?   "" : hiddenMdfIdEname.trim() ;
hiddenMdfNameEname  = hiddenMdfNameEname==null ? "" : hiddenMdfNameEname.trim() ;
hiddenMdfIdVals     = hiddenMdfIdVals==null ?    "" : hiddenMdfIdVals.trim() ;
hiddenMdfNameVals   = hiddenMdfNameVals==null ?  "" : hiddenMdfNameVals.trim() ;

/*
System.out.println( THIS_FILE + "DEBUG 10. dispFname=" + dispFname +
    ", dispEname=" + dispEname +
    ", dispEtype=" + dispEtype +
    ", hiddenFname=" + hiddenFname +
    ", hiddenMdfIdEname=" + hiddenMdfIdEname +
    ", hiddenMdfNameEname=" + hiddenMdfNameEname + "\n");

System.out.println( THIS_FILE + "DEBUG 10. hiddenMdfIdVals=" + hiddenMdfIdVals + "\n");
System.out.println( THIS_FILE + "DEBUG 10. hiddenMdfNameVals=" + hiddenMdfNameVals + "\n");
*/

%>

<%=SpritGUI.pageHeader( globals, "MDF Based Cisco Product", "" ) %>
<%=SpritGUI.pageBanner( globals, "popup","MDF Based Cisco Product - " + swType ) %>

<%
Context             ctx;
MdfSessionHomeLocal mdfHome;
MdfSessionLocal     mdfObj;
String              jndiName;
List                mdfTreeList;
Vector              startingMdfIdVect;
String              mdfStr  = "";

//-----------------------------------------------------------------
// - mappedMdfIdVect. Vector of Integer.
//        Contains MDF IDs that are passed from calling form.
// - Will be used to see if any of these already associated MDF became
//   obsoleted.
// - Already associated, but obsoleted ones will show up in the MDF Navigator
//   to give a capability of de-associating them.
//-----------------------------------------------------------------

Vector  mappedMdfIdVect     = new Vector();
Vector  mappedMdfNameVect   = new Vector();

//-----------------------------------------------------------------
// invalidMappedMdfInfoVect.
//      Contains mapped MDF that became invalid.
//      ex: shr_mdf_products_attr.adm_flag <> 'V'.
//
// obsoleteMappedMdfInfoVect: Contains mapped, but obsolete MDF.
//-----------------------------------------------------------------
Vector  invalidMappedMdfInfoVect;
Vector  obsoleteMappedMdfInfoVect;

try
{
    //------------------------------------------------------
    // Required parameter values:
    //------------------------------------------------------
    if( dispFname==null || dispFname.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'dispFname' is null.");
    }
    if( dispEname==null || dispEname.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'dispEname' is null.");
    }
    if( dispEtype==null || dispEtype.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'dispEtype' is null.");
    }
    if( hiddenFname==null || hiddenFname.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'hiddenFname' is null.");
    }
    if( swType==null || swType.trim().length()==0 )
    {
        throw new Exception( THIS_FILE + "Paremeter 'swType' is null.");
    }

//    System.out.println( THIS_FILE + "DEBUG 12" );


    //------------------------------------------------------
    // dispEtype: only TEXTAREA and DIV are expected.
    //------------------------------------------------------
    if( !dispEtype.equals("textarea") &&
        !dispEtype.equals("div") )
    {
        throw new Exception( THIS_FILE + "Paremeter 'dispEtype' has unknown value '" +
            dispEtype + "'.");
    }

//    System.out.println( THIS_FILE + "DEBUG 13" );



    //------------------------------------------------------
    // 1) Parse $-delimited mdfId and midName into Vector.
    //    This string will be used to check the MDF tree element if substring
    //    matches with MDF ID in the tree.
    //
    // 2) Reformat passed MDF IDs into mappedMdfIdVect.
    //    Will be used to check if any of these already associated MDF
    //    became obsolete, and if obsolete it will be still included in MDF tree
    //------------------------------------------------------
    StringTokenizer st;

    if( hiddenMdfIdVals!=null && hiddenMdfIdVals.trim().length()>0 )
    {
        st  = new StringTokenizer(hiddenMdfIdVals, "$" );
        while(st.hasMoreTokens())
        {
            mappedMdfIdVect.addElement(new Integer( st.nextToken()) );
        }

        st  = new StringTokenizer(hiddenMdfNameVals, "$" );
        while(st.hasMoreTokens())
        {
            mappedMdfNameVect.addElement(st.nextToken() );
        }
    } //  if( hiddenMdfIdVals!=null && hiddenMdfIdVals.trim().length()>0 )

    now = System.currentTimeMillis();
//    System.out.println( THIS_FILE + "DEBUG 15a. Ready to retrieve MDF from DB. " + (now-startTime)/1000 + " sec from start." );

if(41 == Integer.parseInt(osTypeId) || 39 == Integer.parseInt(osTypeId))
{
	swType = "IOS";
}

    jndiName    = "MdfSession.MdfSessionHome";
    ctx         = new InitialContext();
    mdfHome     = (MdfSessionHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    mdfObj      = mdfHome.create();

    startingMdfIdVect   = mdfObj.getAllStartingMdfId(swType);
    
    mdfTreeList         = (List) mdfObj.getMdfTree(swType, mappedMdfIdVect);
 
    invalidMappedMdfInfoVect  =
            mdfObj.getInvalidMdf(mappedMdfIdVect);
    
    obsoleteMappedMdfInfoVect  =
            mdfObj.getObsoleteMdf(mappedMdfIdVect);
    

    now = System.currentTimeMillis();
//    System.out.println( THIS_FILE + "DEBUG 20. Finish retrieving tree from DB for '" + swType + "'. " + (now-startTime)/1000 + " sec from start. mdfTreeList.size()=" + mdfTreeList.size() );

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
//    System.out.println( THIS_FILE + "DEBUG 20a. mdfTreeList.size()=" + mdfTreeList.size() );



String tmpMdfId;
String tempMdfStr;

if(osTypeId != "")
{

	/* To check whether mdf products exists with status Inprogress and approved */
	
	Integer osTypeIdInt = new Integer(osTypeId);
	
	if(RequestPrioritizationJdbc.getCsprSwSavedMDFProductsIds(osTypeIdInt) != null)
	{
	
		mdfSavedListVector			= RequestPrioritizationJdbc.getCsprSwSavedMDFProductsIds(osTypeIdInt);
	}
	

	
}

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

<!--
<input type="hidden" name="dispFname"      value="<%=dispFname%>">
<input type="hidden" name="dispEname"      value="<%=dispEname%>">
-->

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

<%
                //-------------------------------------------------
                // List currently mapped MDFs
                //-------------------------------------------------
%>
                <tr>
                    <td>
                        <img src="../gfx/b1x1.gif" width="20" border="0">
                    </td>
                    <td align="left">
                        <select name="mdfList" multiple size="4">
<%

                        if(mappedMdfIdVect==null || mappedMdfIdVect.isEmpty() )
                        {
%>
                            <option value="0">-- None Selected --</option>
<%
                        }
                        else
                        {
                            for( int i=0; i<mappedMdfIdVect.size(); i++ )
                            {
%>
                            <option value="<%=(Integer) mappedMdfIdVect.elementAt(i)%>"><%=(String) mappedMdfNameVect.elementAt(i)%></option>
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
                // List currently mapped, but INVALID MDFs (marked D).
                //-------------------------------------------------
                if( invalidMappedMdfInfoVect!=null &&
                    ! invalidMappedMdfInfoVect.isEmpty() )
                {

//                System.out.println( THIS_FILE + "DEBUG 40" );


%>
                <tr>
                    <td align="left" valign="top" class="warningTextSmall">
                        <b>Deleted MDF:</b>
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

//                System.out.println( THIS_FILE + "DEBUG 50" );

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
            onclick="javascript:submitTreeFormPostPrioritization(
                        'mdfTreeForm',
                        'mdfChkBox',
                        '<%=dispFname%>',
                        '<%=dispEname%>',
                        '<%=dispEtype%>',
                        '<%=hiddenFname%>',
                        '<%=hiddenMdfIdEname%>',
                        '<%=hiddenMdfNameEname%>',
                        '<%=sessionmdfDiv%>');" />
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
            
            boolean addFlag = true;
            
            if(mdfSavedListVector != null)
            {
            	Iterator savedItr = mdfSavedListVector.iterator();
            	
            	while(savedItr.hasNext())
            	{
            		String savedMdfId = (String)savedItr.next();
            		
            		int saveMdfIdInteger = Integer.parseInt(savedMdfId);
            		
            		//System.out.println("saved Mdf products "+saveMdfIdInteger);
            		
            		
            		if(saveMdfIdInteger == mdfId )
            			
            		{
            			addFlag = false;
            			break;
            		}
            	}
            	
            	
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
   				if(addFlag)
            	{
       		
%>
                mdfTree.add(<%= mdfId %>, <%= mdfInfo.getMdfParentId().intValue() %>, '<%=mdfName%>', '<%=metaclass%>', '' );
               
<%
            	}
            }// else
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
            onclick="javascript:submitTreeFormPostPrioritization(
                        'mdfTreeForm',
                        'mdfChkBox',
                        '<%=dispFname%>',
                        '<%=dispEname%>',
                        '<%=dispEtype%>',
                        '<%=hiddenFname%>',
                        '<%=hiddenMdfIdEname%>',
                        '<%=hiddenMdfNameEname%>',
                         '<%=sessionmdfDiv%>');" />

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

<input type="hidden" name="remove" value="removexxxx">
</center>


</form>


</body>
</html>

<%=Footer.pageFooter(globals)%>

<%
now = System.currentTimeMillis();
System.out.println("<===== " + THIS_FILE + "END.  Took " + (now-startTime)/1000 +
    " sec. MDF cnt=" + cnt + " =====>\n" );

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
