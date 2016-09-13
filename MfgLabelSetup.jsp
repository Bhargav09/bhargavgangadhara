<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004-2005, 2008, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="java.util.HashMap" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>

<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumberHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumber" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>

<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>

<%
  Context ctx;
  Integer 			releaseNumberId;
  SpritAccessManager 		spritAccessManager;
  SpritGlobalInfo 		globals;
  SpritGUIBanner 		banner;
  String 			jndiName;
  String 			pathGfx;
  TableMaker 			tableReleasesYouOwn; 
  Vector 			opusRecords = new Vector();
  CisrommAPI 			cisrommAPI;
  String			htmlNoValue;
  
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  if( !spritAccessManager.isAdminDem() ) {
       response.sendRedirect("ErrorAccessPermissions.jsp");
       return;
  }

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
 
  try {
     releaseNumberId = new Integer( WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  
  // Get release number information.
  String osType = null;
  String softwareType = null;
  ReleaseNumber releaseNumber = null;
  if( releaseNumberId != null ) {
      ReleaseNumberHelper helper = new ReleaseNumberHelper();
      releaseNumber = helper.getReleaseNumber(releaseNumberId);
      osType = releaseNumber.getOsTypeName();
      softwareType = releaseNumber.getSoftwareTypeName();
  }
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(SpritUtility.isOsTypeIosIoxCatos(osType)){
	  banner.addReleaseNumberElement(releaseNumberId);
  }else {
	    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
	    		SpritGUI.renderOSTypeNav(globals,osType,releaseNumber.getReleaseNumber(),"bom",WebUtils.getParameter(request,"osTypeId"),releaseNumberId.toString())
        );
  }
  
 //html macros
 htmlNoValue = "<span class=\"noData\"><center>---</center></span>";

%>
<script>
  function changeSoftwareType() {
    document.mfgLabelSetupSoftwareSelection.submit();
  }
</script>
<form name="mfgLabelSetupSoftwareSelection" method="post" action="SoftwareSearchProcessor">
<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>
<input name="from" value="mfgLabelSetup" type="hidden">
</form>
<% if( "IOS".equalsIgnoreCase( osType )) { %>
<%= SpritReleaseTabs.getTabs(globals, "bom") %>
<% } else if("IOX".equalsIgnoreCase( osType )){ %>
<%= SpritReleaseTabs.getNonIosTabs(globals, "bom") %>
<% }else {%>
<%= SpritReleaseTabs.getOSTypeTabs(globals, "bom")%>
<% }%>

<%
  String webParamsDefault = "";
  if( releaseNumberId != null )
        webParamsDefault = "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString()) 
  			+"&osTypeId="+ WebUtils.getParameter(request,"osTypeId"); 
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>
 
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" align="left" width="70%">
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		new boolean [] { true, true, false, true, true },
          		new String [] { "Component Partno", "Label Setup", "PartNo Prefix Setup", "Exceptions", "Additions" },
          		new String [] { "DemSpecnoPartnoView.jsp?" + webParamsDefault,
          		                "LabelSetup.jsp?" + webParamsDefault,
            		                "MfgLabelSetup.jsp?" + webParamsDefault,
            		                "MfgExceptions.jsp?" + webParamsDefault,
            		                "MfgAdditions.jsp?" + webParamsDefault,
            		              }, false
            		        ) ) );
           %>
    	</td>
      </tr>
   </table>
<br/><br/>

<font size="+1" face="Arial,Helvetica"><b>
  Add / Delete Part Number Prefixes
</b></font>
<br /><br />

<jsp:useBean id="labelBean" scope="session"
    class="com.cisco.eit.sprit.ui.addLabelBean"></jsp:useBean>

<% /*.......................................................................*/
  // Get an instance of the DemMfgLabel bean and retrieve all the records we
  // can get our hands on.
  DemMfgLabelEntityHome dmleHome;
  DemMfgLabelEntity dmleObj;
  Collection dmleCollection;
//  Context ctx;

  ctx = new InitialContext();
  dmleHome = (DemMfgLabelEntityHome) ctx.lookup(
      "demmfglabel.DemMfgLabelEntityHome"
      );

  // Get all web parameters.  Stick them into a Map.
  Enumeration webVarsEnum;
  String webVarName;
  String webVarValue;
  String fieldPrefix;
  String fieldIdStr;
  Integer fieldIdInt;
  Map webVarsMap;

  // Scan all incoming parameters and see if we can save the prefix data.
  fieldPrefix = new String("partnoprefix_");
  webVarsMap = null;
  webVarsEnum = request.getParameterNames();
  if( webVarsEnum!=null ) {
    webVarsMap = new HashMap();
    while( webVarsEnum.hasMoreElements() ) {
      // Get a copy of the web variable name and value!
      webVarName = (String) webVarsEnum.nextElement();
      webVarValue = new String( "" );
      if( webVarName != null ) {
        if( request.getParameter( webVarName ) != null ) {
	  webVarValue = request.getParameter( webVarName );
	}  // if( webVarValue==null ) {
      }  // if( webVarName!=null ) {

      // See if this variable has "_partnoprefix" in its name.  If so then
      // we should capture and map the variable.  It is possible the variable
      // value will be empty!  Note that the indexOf() should be exactly 0
      // since we are expecting the ID to be to the right.
      if( webVarName.indexOf(fieldPrefix)==0 ) {
        // See if we can strip the ID out of the webVarName.  The ID follows
        // the prefix, we know the prefix starts at 0, so use the prefix
        // length.
        fieldIdStr = new String( webVarName.substring(
	    fieldPrefix.length())
            );
	fieldIdInt = new Integer(fieldIdStr);

	webVarsMap.put( (Integer) fieldIdInt, (String) webVarValue );
      }  // if( webVarName.indexOf("partnoprefix_")==0 )
    }  // while( webVarsEnum.hasMoreElements() )
  }  // if( webVarsEnum!=null )

  // See if we can update any of the objects?
  if( webVarsMap != null ) {
    if( webVarsMap.size() > 0 ) {
      // OK.  If the map wasn't null and there were mappable elements then it
      // means that the user has probably altered the data and now is requesting
      // an update.  We'll iterate through all of the known labels and see if
      // we can assign a new value to it...

      // Get a new enumeration to figure out what the objects are that we need
      // to update.  Iterate through those objects and look up their values in
      // the webVarsMap.  If there is no key in the webVarsMap then that is
      // still OK as it means the value for the database should be nulled.
      //
      // NOTE: we'll recycle the dmleObj object here---treat it as a locally
      // scoped variable.
      Collection dmleColl = dmleHome.findAll();
      Iterator iter = dmleColl.iterator();
      
      while( iter.hasNext() ) {
          // Get this object.
          dmleObj = (DemMfgLabelEntity) iter.next();
          fieldIdInt = dmleObj.getLabelSeqId();

          // Update!
          dmleObj.setPartNoPrefix( (String) webVarsMap.get(
              (Integer) fieldIdInt ) );
      }  // while( item.hasNext() )
    }  // if( webVarsMap.size() > 0 )
  }  // if( webVarsMap != null )
/*.......................................................................*/ %>

<!-- Controlling scripts -->
<script language="javascript"><!-- - - - - - - - - - - - - - - - - - - - - -
  //........................................................................
  // DESCRIPTION:
  //     Takes a validated partnoprefix string and canonicalizes it.  Duh.
  //     The result should be a comma-separated string of numbers with no
  //     spaces in it.
  //
  // INPUT:
  //     partnoprefix (string): String to be processed.
  //
  // OUTPUT:
  //     fixedstring (string): Canonicalized string.
  //
  //........................................................................
  function partNoPrefixCanonicalize( pnpValue ) {
    pnpValue = pnpValue.replace( /\s/g,"" );
    pnpValue = pnpValue.replace( /,+/g,",");
    pnpValue = pnpValue.replace( /^,/,"");
    pnpValue = pnpValue.replace( /,$/,"");

    return( pnpValue );
  }

  //........................................................................
  // DESCRIPTION:
  //     Tells you whether or not the value is a valid part number.
  //
  // INPUT:
  //     partnoprefix (string): String to be tested.
  //
  // OUTPUT:
  //     error condition (int): One of these values:
  //
  //         0: Invalid number.
  //         1: Number OK!
  //
  //........................................................................
  function partNoPrefixTest( pnpValue ) {
    var regex;

    regex = /[^0-9, ]/;
    if( regex.test( pnpValue ) ) {
      // DOH!  Illegal characters!
      return( 0 );
    } else {
      return( 1 );
    }  // else if
  }

  //........................................................................
  // DESCRIPTION:
  //     Checks one of the partnoprefix fields to see if it's a valid
  //     entry.
  //
  // INPUT:
  //     formName (string): Name of the form holding the field.
  //     fieldName (string): Name of field to be manipulated.
  //     labelName (string): Visible name of the field.
  //........................................................................
  function partNoPrefixFieldVerify(formName,fieldName,labelName) {
    var formObj;
    var fieldObj;
    var fieldValue;

    formObj = document.forms[formName];
    fieldObj = formObj.elements[fieldName];
    fieldValue = fieldObj.value;
    // Search for characters which are NOT numbers, spaces, or commas.
    if( partNoPrefixTest(fieldValue)==0 ) {
      // Oops.  Illegal chars found.  Throw focus back on the erroneous field.
      alert( "ERROR: You've entered an illegal value for label \""
          + labelName + "\"!  Press OK to return to the form to correct it. "
          + "(Follow the example to the right.)" );

      fieldObj.blur();
      fieldObj.focus();
      fieldObj.select();
    } else {
      // OK.  Let's try to clean up the field, though.
      fieldObj.value = partNoPrefixCanonicalize(fieldValue);
    }  // if( partNoPrefixTest(fieldValue)==0 )
  }  // function partNoPrefixFieldVerify

  function checkIfEmpty(formName,fieldName,labelName) {
    var formObj;
    var fieldObj;
    var fieldValue;

    formObj = document.forms[formName];
    fieldObj = formObj.elements[fieldName];
    fieldValue = fieldObj.value;

    if(fieldValue == "") {
      return 0;
    } else {
      return 1;
    }
  }
  //........................................................................
  // DESCRIPTION:
  //     Submits this form and checks for errors.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  function submitForm(formName) {
    var formObj;
    var fieldObj;
    var fieldValue;
    var idx;
    var nameRegex;

    formObj = document.forms[formName];

    // OK!  Check every parameter!  But scan only for the "partnoprefix_"
    // ones.
    nameRegex = /^partnoprefix_/;
    for( idx=0; idx<formObj.length; idx++ ) {
      fieldObj = formObj.elements[idx];
      fieldValue = fieldObj.value;
      if( nameRegex.test( fieldObj.name ) == 1 ) {

        if( checkIfEmpty(formName,fieldObj.name,fieldObj.value) == 0) {
           alert( "ERROR: Part no prefix can't be null. " );
          fieldObj.focus();
          fieldObj.select();
          return;
        }

        // Check this field to see if it has any other characters other
        // than the space, comma, and numbers.
        if( partNoPrefixTest( fieldValue ) == 0 ) {
          alert( "ERROR: You have a label with an invalid partno prefix! "
              + "Press OK to return to the form to correct it." );
          fieldObj.focus();
          fieldObj.select();
          return;
        } else {
          // Looks OK but let's clean up the value just in case.
          fieldObj.value = partNoPrefixCanonicalize( fieldValue );
        }  // else if( partNoPrefixTest( fieldValue ) == 0 )
      }  // if( nameRegex.test( formObj.elements[idx].name ) == 1 )
    }  // for( idx=0; idx<formObj.length; idx++ )

    // No more errors!
    formObj.submit();
  }  // function submitForm
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --></script>

<!--
  Layout table: left cell will be the grid of information, right cell to
  be the on-screen help.
-->
<center>
  <table border="0" cellspacing="0" cellpadding="0">
  <tr>
    <!-- Left cell -->
    <td valign="top">
    <%
      String qryStr = "";
      if(releaseNumberId != null) {
        qryStr = "?releaseNumberId=" + releaseNumberId;
      }
      if (qryStr.length() > 0) {
        qryStr += "&osTypeId=" + WebUtils.getParameter(request,"osTypeId");
      } else {
        qryStr += "?osTypeId=" + WebUtils.getParameter(request,"osTypeId");
      }
    %>
      <form action="MfgLabelSetup.jsp<%= qryStr %>" method="post" name="demmfglabelform">
 	<input type="hidden" name="callingForm" value="viewLabelswithdelete">

        <center>

	<table cellspacing="0" cellpadding="2" Border="0">
	<tr bgcolor="#d9d9d9">
	  <td>&nbsp;</td>
	  <td align="left"><span class="dataTableTitle">
	      Label
	    </font></span>
	  </td>
	  <td align="left"><span class="dataTableTitle">
	      Partno Prefix
	    </span>
	  </td>
	  <td>&nbsp;</td>
	</tr>

	<% /*..............................................................*/
	  // Declare "local" variables.
	  Integer labelSeqId;
	  String labelSeqIdString;
	  String label;
	  String partNoPrefix;
	  String partNoPrefixFieldName;

	  // Display all columns/rows!
          dmleCollection = dmleHome.findAll();
          Iterator iter = dmleCollection.iterator();
          
	  while( iter.hasNext() ) {
	    // Get this object.
	    dmleObj = (DemMfgLabelEntity) iter.next();

	    // Map the objects.
	    labelSeqId = dmleObj.getLabelSeqId();
	    label = dmleObj.getLabel();
	    partNoPrefix = dmleObj.getPartNoPrefix();

	    labelSeqIdString = new String( labelSeqId.toString() );
            partNoPrefixFieldName = new String( "partnoprefix_"
                + labelSeqIdString );

	    // Render this row.
	    out.print( "\t<!-- " + WebUtils.escHtml(labelSeqIdString)
	        + " -->\n" );
	    out.print( "\t<tr bgcolor=\"#ffffff\">\n" );
	    out.print( "\t  <td></td>\n" );

	    out.print( "\t  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">"
		+ WebUtils.escHtml(label)
		+ "</span></td>\n" );
	    out.print( "\t  <td valign=\"top\" align=\"left\"><span class=\"dataTableData\">"
		+ "<input type=\"text\" name=\""
		    + WebUtils.escHtml(partNoPrefixFieldName)
		    + "\" size=\"20\" maxlength=\"20\" "
                    + "onchange=\"partNoPrefixFieldVerify('demmfglabelform','"
                        + WebUtils.escHtml(partNoPrefixFieldName)
                        + "','"
                        + WebUtils.escHtml(label)
                        + "');\" "
		    + WebUtils.makeFormAttributeValue(partNoPrefix)
		    + " />"
		+ "</span>"
		+ "</td>\n" );

	    // End this row.
	    out.print( "\t  <td></td>\n" );
	    out.print( "\t</tr>\n\n" );
	  }  // while( iter.hasNext() )
	/*..............................................................*/ %>

	<tr>
	  <td colspan="4"><img src="../gfx/b1x1.gif" /></td>
	</tr>
	</table><br />

	<a href="javascript:submitForm('demmfglabelform')"><img
	    src="../gfx/btn_save_updates.gif" border="0" /></a>

	</center>
      </form>
    </td>

    <!-- Spacer cell -->
    <td>
      <img src="../gfx/b1x1.gif" width="32" />
    </td>

    <!-- Right cell -->
    <td valign="top">
      <table border="0" cellpadding="8" cellspacing="0">
      <tr><td align="left" width="300" bgcolor="#e8e8e8">
        <%@ include file="MfgLabelSetup_help.jsp" %>
      </td></tr>
      </table>
    </td>
  </tr>
  </table>
</center>

<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->
