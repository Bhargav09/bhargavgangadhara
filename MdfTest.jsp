<!--.........................................................................
: DESCRIPTION:
:    MDF Navigator Calling form for TEST ONLY.
:
: AUTHORS:
: @author Nadia Lee
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->


<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Properties" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.rmi.PortableRemoteObject" %>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.ui.ReleaseSelectorGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript">

var popupWindow = null;


//======================================================================
// Make MDF Navigator popup window.
//======================================================================
/*
function popup(popupName, fName, eName, swType )
{

    var THIS_FUNC = "[popup] ";

    // dummy value for testing.
    swType = 'Cisco Network Assistant';

//    alert( THIS_FUNC + "debug 1");

    var windowWidth  = 500;
    var windowHeight = 600;
    var locX = 500;
    var locY = 200;
    var windowFeatures = "width=" + windowWidth
                     + ",height=" + windowHeight
                     + ",scrollbars=yes"
                     + ",resizable=yes"
                     + ",screenX=" + locX
                     + ",screenY=" + locY
                     + ",left=" + locX
                     + ",top=" + locY;

    if( popupName==null || popupName=="" ) {
        alert( THIS_FUNC + ": Parameter 'popupName' is not defined. " +
            "This is an application error. Please contact application admin." );
        return;
    }


    //-----------------------------------------------------------------
    // Pass current MDF IDs and MDF names in $-delimited format.
    //-----------------------------------------------------------------
    var listObj     = document.forms[fName].elements[eName];
    var paramMdf    = "";

    for( var i=0; i<listObj.length; i++ )
    {
        paramMdf +=
            "&mdf=" + listObj.options[i].value + "$" +
            listObj.options[i].text;
    }

    //-----------------------------------------------------------------
    // Attach calling object names as parameter.
    //-----------------------------------------------------------------
    urlParam = "?f=" + fName + "&e=" + eName +
        "&swType=" + swType + paramMdf;

    popupName = popupName + urlParam;

    //-----------------------------------------------------------------
    // Close window first to make sure that our window has the desired
    // features
    //-----------------------------------------------------------------
    if ( popupWindow != null  && !popupWindow.closed ) {
        popupWindow.close();
    }

    alert( THIS_FUNC + "debug 90: popupName = " + popupName );
    //-----------------------------------------------------------------
    // Open the new popup window, Owner is the name of the window.
    //-----------------------------------------------------------------
    popupWindow = window.open(popupName, 'Owner', windowFeatures );
//    popupWindow.focus();

} // function popup
*/

</script>


<%
  Context           ctx;
  int               idx;
  ReleaseNumberModelHomeLocal   rnmHome;
  ReleaseNumberModelInfo    rnmInfo;
  ReleaseNumberModelLocal   rnmObj;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  String            jndiName;
  String            pathGfx;
  TableMaker            tableReleasesYouOwn;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );

SpritGUI.pageHeader( globals,"Main Menu","" );
banner.render();

ArrayList myReleasesArray;
  ArrayList releaseOwners;
  ArrayList rnmLookupResults;
  CisrommAPI    cisrommAPI;
  Integer   releaseNumberId;
  String    htmlMyReleases = null;
  String    htmlReleaseNumber;
  String    htmlReleaseOwners;
  String    htmlReleaseViews;
  String    releaseNumberString;
  String    osType="IOS";
  // Get release number model object so we can do lookup on the
  // release string.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
  } catch( Exception e ) {
    throw e;
  }  // catch
%>

    <font size=+1><b>This form is to test MDF Navigator</b></font>
    <br /><br />

    <hr>
    MDF Navigator TEST with <b>DIV</b> and <b>POST</b> with Intermediate JavaScript page:     <br />

    <form name='mdfDivPostDispForm' method="get" action="">

    <input type="hidden" name="mdfId"   value="268438202$277410767$268438196">
    <input type="hidden" name="mdfName" value="Cisco Aironet 350 Wireless LAN Client Adapter$Cisco Aironet 5 GHz 54 Mbps Wireless LAN Client Adapter$Cisco Aironet 340 Wireless PC Card Adapter">

    <div id="mdfDivPost">
        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Catalyst 4503 Switch<br />

        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Catalyst 4506 Switch<br />

        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Catalyst 4507R Switch<br />
    </div>
    <br />
    <a href="javascript:mdfPopupPost(
                                'mdfDivPostDispForm',
                                'mdfDivPost',
                                'div',
                                'mdfDivPostHiddenForm',
                                'hiddenMdfId',
                                'hiddenMdfName',
                                'Cisco Network Assistant' )"> Change MDF (DIV,POST)</a>
    <br />
    <font color="ff0000">Submitting MDF IDs and MDF names as POST Method</font>

    </form>

    <form name="mdfDivPostHiddenForm" style="display: none;" action="" method="post">

        <input name="dispFname" value="mdfDivPostDispForm">
        <input name="dispEname" value="mdfDivPost">
        <input name="dispEtype" value="div">

        <input name="hiddenFname"         value="mdfDivPostHiddenForm">
        <input name="hiddenMdfIdEName"    value="hiddenMdfId">
        <input name="hiddenMdfNameEname"  value="hiddenMdfName">
        <input name="swType"              value="Cisco Network Assistant">

        <input name="hiddenMdfId"         value="277241554$277241586$277241600">
        <input name="hiddenMdfName"       value="Cisco Catalyst 4503 Switch$Cisco Catalyst 4506 Switch$Cisco Catalyst 4507R Switch">

    </form>

    <hr>


    MDF Navigator TEST with <b>DIV</b> and <b>GET</b>:
    <br /><br />

    <form name='mdfDivGetForm' action="" method="post" >

    <input type="hidden" name="mdfId"   value="268438202$277410767$268438196">
    <input type="hidden" name="mdfName" value="Cisco Aironet 340 Wireless PC Card Adapter$Cisco Aironet 350 Wireless LAN Client Adapter$Cisco Aironet 5 GHz 54 Mbps Wireless LAN Client Adapter (CB20A)">

    <div id="mdfDivGet">
        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Aironet 350 Wireless LAN Client Adapter<br />
        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Aironet 5 GHz 54 Mbps Wireless LAN Client Adapter<br />
        <img src="../gfx/dot_black.gif">&nbsp;
        Cisco Aironet 340 Wireless PC Card Adapter<br />
    </div>
    <br />

    <a href="javascript:mdfPopup('MdfTree.jsp',
                                 'mdfDivGetForm',
                                 'VxWorks',
                                 'mdfDivGet',
                                 'div',
                                 'mdfId',
                                 'mdfName' )">Change MDF (DIV, GET)</a>
    <br />
    <font color="ff0000">Calling MDF Navigator with GET(URL)</font>
    </form>

    <hr>

    <br />MDF Navigator test with <b>SELECT BOX</b> and <b>GET</b> </br>
    <font color="ff0000">MDF Navigator doesn't support SELECT box any longer</font>

    <form name='mdfSelectGetForm' method="post" >

    <select name="mdfList" multiple="multiple" width="200" size="5">
        <option value=274400187>Cisco Aironet POS Diversity Dipole</option>
        <option value=277524941>Cisco Aironet CB20A Wireless LAN Adapter</option>
        <option value=268438196>Cisco Aironet 340 Wireless PC Card Adapter</option>
    </select>
    <br />
    <a href="javascript:mdfPopup('MdfTree.jsp',
                                 'mdfSelectGetForm',
                                 'VxWorkds',
                                 'mdfList',
                                 'select',
                                 '',
                                 '' )">Change MDF (SELECT)</a>
    </form>


<%
    System.out.println("<===== [MdfTest.jsp] END  =====>" );
%>

<%= Footer.pageFooter(globals) %>
<!-- end -->
