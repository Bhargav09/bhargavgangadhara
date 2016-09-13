<!--.........................................................................
: DESCRIPTION:
: Main Menu page.  Basic searches, boxes for your releases, and a cute
: welcome message.  Aw...
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2003-2008, 2010, 2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>

<%@ page import="java.util.TreeMap" %>
<%@ page import="java.util.Iterator" %>
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
<%@ page import="com.cisco.eit.sprit.dataobject.OSTypeInfo" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.ui.ReleaseBean" %>

<%
  Context           ctx;
  ReleaseNumberModelHomeLocal   rnmHome;
  OSTypeInfo              osTypeInfo;
  ReleaseNumberModelLocal   rnmObj;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  String            jndiName;
  String            pathGfx;
  String htmlButtonGo;
  TableMaker            tableReleasesYouOwn;
  Iterator osIterator = null;
  Iterator myReleasesIterator = null;

  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
      
  MonitorUtil monitorUtil = new MonitorUtil();
  monitorUtil.cesMonitorStart("SPRIT-6.6-CSCse84666-MyReleases load time", request);
  
%>
<%= SpritGUI.pageHeader( globals,"Main Menu","" ) %>
<%= banner.render() %>
<%
	ArrayList osTypeResults;
  String    htmlMyReleases = null;  
  String    htmlReleaseNumber;
  String    htmlReleaseOwners;
  String    htmlReleaseViews;
  String    releaseNumberString;
  String    osType="IOS";  
  
  // Get release number model object so we can do lookup on the
  // release string.
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
  } catch( Exception e ) {
    throw e;
  }  // catch  
  
  // HTML macros
  htmlButtonGo = ""
      + SpritGUI.renderButtonRollover(
	  globals,
	  "btnGo",
	  "Go",
	  "javascript:submitSoftwareSelector()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_GO,
	  "actionBtnGo('btnGo')",
	  "actionBtnGoOver('btnGo')"
	  );
	  
  // Get results.
  try {
    ReleaseBean releaseBean = new ReleaseBean();
    releaseBean.getReleaseInfo(request.getRemoteUser());
    //System.out.println("Over 1000 releases test...");
    //releaseBean.getReleaseInfo("dklenke");

    // Render the Releases You Own box into memory first.
    tableReleasesYouOwn = new TableMaker();
    tableReleasesYouOwn.setHtmlPre( SpritConstants.TABLE_DATA_PRE );
    tableReleasesYouOwn.setHtmlPost( SpritConstants.TABLE_DATA_POST );

    tableReleasesYouOwn.newRow(
    "bgcolor=\"" + SpritConstants.TABLE_DATA_HEADER_COLOR_BG + "\""
    );
    tableReleasesYouOwn.addTD( null,  "<span class=\"dataTableTitle\">"
    + "Release"
    + "</span>" );
    tableReleasesYouOwn.addTD( null,  "<span class=\"dataTableTitle\">"
    + "<nobr>Owner(s)</nobr>"
    + "</span>" );
    tableReleasesYouOwn.addTD( null,  "<span class=\"dataTableTitle\">"
    + "Views"
    + "</span>" );
    
    List keys = Arrays.asList(releaseBean.getReleaseOwners().keySet().toArray());
    Collections.sort(keys, Collections.reverseOrder());
    myReleasesIterator = keys.iterator();
    while( myReleasesIterator.hasNext() ) {
      // Start new row.
      tableReleasesYouOwn.newRow(
      "bgcolor=\"" + SpritConstants.TABLE_DATA_BODY_COLOR_BG + "\""
      );

      // Get details for this release Number String.
      htmlReleaseNumber = null;
      htmlReleaseViews = null;
      
      releaseNumberString = (String) myReleasesIterator.next();
      
      System.out.println("releaseNumberString: "+releaseNumberString);  
      htmlReleaseOwners = "Not&nbsp;avail.";
      ArrayList releaseOwnersList = (ArrayList) releaseBean.getReleaseOwners().get(releaseNumberString);
      System.out.println("releaseOnwersList Size: "+releaseOwnersList.size());
      if ( releaseOwnersList != null && releaseOwnersList.size() > 0 ) {
          htmlReleaseOwners = 
              WebUtils.escHtml( 
                  StringUtils.joinStringArray(
                  StringUtils.stringArrayListToArray(releaseOwnersList),
                  ", ","",""
                  ) 
              );
      }
        
      
      // Create new links and stuff.
     				htmlReleaseNumber = "<nobr>"
	+ "<a href=\"ReleaseInfo.jsp?releaseNumberId="
	+ WebUtils.escUrl(releaseBean.getReleaseIDs()
			.get(releaseNumberString).toString())
	+ "\">" + WebUtils.escHtml(releaseNumberString)
	+ "</a>" + "</nobr>";

	/**
	IOSXE/CatOS/IOS-XR/NX-OS
	TODO: OS_TYPE_DISPLAY_NAME needs to be uniform across tools. 
	Currently thats not the case.			
	*/
	System.out.println ("SWT: "+ releaseBean.getOsTypeNames().get(releaseNumberString));
	if (!(releaseBean.getOsTypeNames().get(releaseNumberString)
			.toString().equals("IOS")
			)) {
		if (releaseBean.getOsTypeNames().get(releaseNumberString)
				.toString().equals("IOSXE")){
		htmlReleaseNumber = "<nobr>"
				+ "<a href=\"NonIosReleaseView.jsp?osTypeId=306"
				//+ WebUtils.escUrl(releaseBean.getOsTypeNames()
				//		.get(releaseNumberString).toString())
				+ "&releaseName="
				+ WebUtils.escUrl(releaseNumberString
						.toString()) + "\">"
				+ WebUtils.escHtml(releaseNumberString)
				+ "</a>" + "</nobr>";
		}
		
		if (releaseBean.getOsTypeNames().get(releaseNumberString)
				.toString().equals("IOS-XR")){
		htmlReleaseNumber = "<nobr>"
				+ "<a href=\"NonIosReleaseView.jsp?osTypeId=118"
				//+ WebUtils.escUrl(releaseBean.getOsTypeNames()
				//		.get(releaseNumberString).toString())
				+ "&releaseName="
				+ WebUtils.escUrl(releaseNumberString
						.toString()) + "\">"
				+ WebUtils.escHtml(releaseNumberString)
				+ "</a>" + "</nobr>";
		}
		
		if (releaseBean.getOsTypeNames().get(releaseNumberString)
				.toString().equals("NX-OS")){
		htmlReleaseNumber = "<nobr>"
				+ "<a href=\"NonIosReleaseView.jsp?osTypeId=312"
				//+ WebUtils.escUrl(releaseBean.getOsTypeNames()
				//		.get(releaseNumberString).toString())
				+ "&releaseName="
				+ WebUtils.escUrl(releaseNumberString
						.toString()) + "\">"
				+ WebUtils.escHtml(releaseNumberString)
				+ "</a>" + "</nobr>";
		}

	}

	System.out.println(htmlReleaseNumber);

	htmlReleaseViews = ""
			+ "<a href=\"ImageList.jsp?releaseNumberId="
			+ WebUtils.escUrl(releaseBean.getReleaseIDs()
					.get(releaseNumberString).toString())
			+ "\">IL</a>&nbsp;"
			+ "<a href=\"UpgradePlanner.jsp?releaseNumberId="
			+ WebUtils.escUrl(releaseBean.getReleaseIDs()
					.get(releaseNumberString).toString())
			+ "\">UP</a>&nbsp;"
			+ "<a href=\"MarketMatrix.jsp?releaseNumberId="
			+ WebUtils.escUrl(releaseBean.getReleaseIDs()
					.get(releaseNumberString).toString())
			+ "\">MM</a>&nbsp;";
			
			if (!(releaseBean.getOsTypeNames().get(releaseNumberString)
					.toString().equals("IOS"))) {
				if (releaseBean.getOsTypeNames()
						.get(releaseNumberString).toString()
						.equals("IOSXE")) {
					htmlReleaseViews = ""
							+ "<a href=\"CsprImageViewAll.jsp?releaseName="
							+ WebUtils.escUrl(releaseNumberString
									.toString()) + "&osTypeId=306"
							+ "\">IL</a>";

					//CsprImageViewAll.jsp?releaseName=3.4.0SG&osTypeId=306
				}
				
				if (releaseBean.getOsTypeNames()
						.get(releaseNumberString).toString()
						.equals("NX-OS")) {
					htmlReleaseViews = ""
							+ "<a href=\"CsprImageViewAll.jsp?releaseName="
							+ WebUtils.escUrl(releaseNumberString
									.toString()) + "&osTypeId=312"
							+ "\">IL</a>";

					//CsprImageViewAll.jsp?releaseName=3.4.0SG&osTypeId=306
				}
				
				if (releaseBean.getOsTypeNames()
						.get(releaseNumberString).toString()
						.equals("IOS-XR")) {
					htmlReleaseViews = ""
							+ "<a href=\"CsprImageViewAll.jsp?releaseName="
							+ WebUtils.escUrl(releaseNumberString
									.toString()) + "&osTypeId=118"
							+ "\">IL</a>";

					//CsprImageViewAll.jsp?releaseName=3.4.0SG&osTypeId=306
				}
			}

			if (releaseBean.isReleaseION(releaseBean.getReleaseIDs()
					.get(releaseNumberString).toString())) {
				htmlReleaseViews = htmlReleaseViews
						+ "<a href=\"CcoServicePackPostSelect.jsp?osTypeURL=ION&releaseNumberId="
						+ WebUtils.escUrl(releaseBean.getReleaseIDs()
								.get(releaseNumberString).toString())
						+ "\">MP</a>&nbsp;";
			}

			tableReleasesYouOwn.addTD(
					null,
					"<span class=\"dataTableData\">"
							+ StringUtils.nvl(htmlReleaseNumber, "---")
							+ "</span>");
			tableReleasesYouOwn.addTD(
					null,
					"<span class=\"dataTableData\">"
							+ StringUtils.nvl(htmlReleaseOwners, "---")
							+ "</span>");
			tableReleasesYouOwn.addTD(
					null,
					"<span class=\"dataTableData\">"
							+ StringUtils.nvl(htmlReleaseViews, "---")
							+ "</span>");
			
			System.out.println(htmlReleaseViews);
		} // while( myReleasesIterator.hasNext() )

		
		if (releaseBean.getReleaseOwners().keySet().size() < 1) {
			tableReleasesYouOwn.newRow("bgcolor=\""
					+ SpritConstants.TABLE_DATA_BODY_COLOR_BG + "\"");
			tableReleasesYouOwn
					.addTD("colspan=\"3\" align=\"center\"",
							"<span class=\"dataTableData\">You have no releases.</span>");
		}

		// Create the output into memory.
		htmlMyReleases = SpritGUI.renderInfoBox(globals, "My Releases",
				tableReleasesYouOwn.renderTable());

		osTypeResults = (ArrayList) rnmObj.getSoftwareType();
		if (osTypeResults != null && osTypeResults.size() > 0)
			osIterator = osTypeResults.iterator();              // if osTypeResults is not empty we create an inerator

	} catch (Exception e) {
%><%= e.getMessage() %><%
  }  // catch
%>

<!-- Master holding table -->
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <!-- Left column -->
  <td valign="top" align="left">
    <%= htmlMyReleases %>
  </td>
  
  <!-- Spacer -->
  <td><img src="<%= pathGfx %>/<%= SpritConstants.GFX_BLANK %>" width="16" /></td>
  
  <!-- Welcome message and search boxes -->
  <script language="javascript"><!--
    // Launches the search window, sets the search type, and submits the form
    // to that window.
    //
    // IN:
    // searchType: Either "exact" or "fielded".
    function submitForm(searchType) {
      showReleaseSelector("PleaseWait.jsp");
      
      // Set our search type.
      document.forms['releaseForm'].elements['searchType'].value=searchType;

      // Now that the window is up there submit the form!
      document.forms['releaseForm'].submit();
    }
  //--></script>
  <td valign="top" align="left">
    Welcome to the Software Productization and Release Information
    Tool!  Begin by searching for your release.
    <br /><br />

    <form name="releaseForm" method="get" action="ReleaseSelectorPopupResult.jsp" target="releaseSelector">
    <%= 
      // releaseForm.goReleaseNumberExact
      // goReleaseNumberFielded
    
      ReleaseSelectorGUI.renderSelectionForm( 
          globals,
          "releaseForm",
          "javascript:submitForm(&quot;exact&quot;)",
          "javascript:submitForm(&quot;fielded&quot;)",
          "javascript:submitForm(&quot;zabp&quot;)",
          null,                     // exact search
          null,null,null,null,null, // fielded search
          null,null,null,null,          //nth release search
          null,null                 // options
          )
    %>
    </form>
    
<form action="SoftwareSearchProcessor" method="post" name="softwareSelector" onSubmit="return submitSoftwareSelector();">
<table border="0" cellpadding="2" cellspacing="0"><tbody>
<tr>
<td>
<table border="0" cellpadding="2" cellspacing="0"><tbody><tr><td bgcolor="#bbd1ed" >

  <table border="0" cellpadding="0" cellspacing="0">
  <tbody><tr><td bgcolor="#ffffff">

    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr>
      <td bgcolor="#bbd1ed"><img src="<%=pathGfx%>/b1x1.gif" width="8"></td>
      <td bgcolor="#bbd1ed"><span class="infoboxTitle">
        Select Other Software Type
      </span></td>
      <td background="<%=pathGfx%>/wedge_lightblue.gif"><img src="<%=pathGfx%>/b1x1.gif" height="1" width="24"></td>
    </tr>
    </tbody></table>


    <table border="0" cellpadding="8" cellspacing="0">
    <tbody><tr><td align="left"><span class="infoboxData">

Use this form to select a Software type and enter the release to work on.
Click the <b>Go</b> button to begin the search.
Click <b>Help</b> for examples.<br><br>


<table border="0" cellpadding="0" cellspacing="0">
<tbody><tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top"><b>Software Type *:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top">
<a href="javascript:resetSWAction()" onmouseover="setImg('resetSoftwareType','../gfx/btn_resetfield_over.gif');" onmouseout="setImg('resetSoftwareType','../gfx/btn_resetfield.gif');"><img src="<%=pathGfx%>/btn_resetfield.gif" alt="Reset Software Type drop down to the right" name="resetSoftwareType" border="0"></a><a href="javascript:nonIOSSoftwareHelp()" onmouseover="setImg('helpReleaseNumberExact','../gfx/btn_help_mini_over.gif');" onmouseout="setImg('helpReleaseNumberExact','../gfx/btn_help_mini.gif');"><img src="<%=pathGfx%>/btn_help_mini.gif" alt="Help" name="helpReleaseNumberExact" border="0"></a></td>
  <td align="left" valign="top">&nbsp;</td>  	
  <td align="left" valign="top">

<%   	
		String mdfProjectFlag = "";
        SpritInitializeGlobals globalsInfo = SpritInitializeGlobals.getInstance();
		mdfProjectFlag = globalsInfo.getProperty(SpritConstants.MDF_PROJECT_FLAG);
		StringBuffer  osTypeSelect = new StringBuffer();


		    if (mdfProjectFlag == null) {
			    mdfProjectFlag = "False";  // use of this flag ?
		    }
		
            if ("True".equalsIgnoreCase(mdfProjectFlag)) 
            {
				MonitorUtil.cesMonitorCall("SPRIT-6.4-CSCsd68488-Software Type Tree", request);  // what is the meaning of this?
					
                osTypeSelect.append(SpritUtility.getSoftwareTypeSelectWidget("osType",true,osType)); // getting the widget for selecting the software here in main page
            } 
            
            else 
            {

               osTypeResults = (ArrayList) rnmObj.getSoftwareType();
               if( osTypeResults!=null && osTypeResults.size()>0 )
                   osIterator = osTypeResults.iterator(); 

               osTypeSelect.append("<select name=\"osType\" size=\"1\">");
               osTypeSelect.append("<option	value=''>Select One...</option>");
	           while (osIterator.hasNext()) {
		           osTypeInfo = (OSTypeInfo) osIterator.next();
                   osTypeSelect.append("<option value=\"" + osTypeInfo.getOsTypeId() + "\">" + osTypeInfo.getOsType() + "</option>");
               }

               osTypeSelect.append("</select>");
		    }

%>

<%= osTypeSelect.toString() %>   <!-- Changing string buffer to string and displaying it -->

  </td>
</tr>
<tr>
  <td><img src="<%=pathGfx%>/b1x1.gif" height="5"></td>
</tr>
</tbody></table>

<table border="0" cellpadding="0" cellspacing="0">
	<tbody><tr>
	  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
	  <td align="left" valign="top">&nbsp;</td>
	  <td align="left" valign="top"><b>Options*:</b></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td align="left" valign="top">
      <input name="softwareView" value="SMR" checked="checked" type="radio"> Release Info 
      <input name="softwareView" value="SMD" type="radio"> Manage Metadata 
      <input name="softwareView" value="SCCO" type="radio"> CCO Post
      <!-- temporarily removed for Sprit 7.0 release 
      <input name="softwareView" value="SMO" type="radio"> Opus 
      <input name="softwareView" value="SDB" type="radio"> DEM/BOM
       -->
	  </td>
	</tr>
	<tr>
	  <td><img src="<%=pathGfx%>/b1x1.gif" height="5"></td>
        </tr>
    </tbody>
  </table>

<table border="0" cellpadding="0" cellspacing="0">
<tbody>



<!-- Release Number Field -->

<tr>
  <td align="left" valign="top"><img src="<%=pathGfx%>/ico_arrow_right_orange.gif"></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top"><b>Search by Release Number:</b></td>
  <td align="left" valign="top">&nbsp;</td>
  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  <td align="left" valign="top">
<a href="javascript:resetReleaseNumberExactSWAction()" onmouseover="setImg('resetReleaseNumberExact','../gfx/btn_resetfield_over.gif');" onmouseout="setImg('resetReleaseNumberExact','../gfx/btn_resetfield.gif');"><img src="<%=pathGfx%>/btn_resetfield.gif" alt="Reset exact search box to the right" name="resetReleaseNumberExact" border="0"></a><a href="javascript:nonIOSReleaseHelp()" onmouseover="setImg('helpReleaseNumberExact','../gfx/btn_help_mini_over.gif');" onmouseout="setImg('helpReleaseNumberExact','../gfx/btn_help_mini.gif');"><img src="<%=pathGfx%>/btn_help_mini.gif" alt="Help" name="helpReleaseNumberExact" border="0"></a></td>
  <td align="left" valign="top">&nbsp;</td>
  <td align="left" valign="top"><input name="swreleaseNumberExact" value="" size="20" type="text"></td>
  <td>&nbsp;</td>
  <td valign="bottom" align="center">
  &nbsp;&nbsp;
  </td>
  <td align="center">
      <%= htmlButtonGo %>  <!--  Adding the Go button -->
  </td>  
</tr>
<tr>
  <td colspan="7"></td>
  <td valign="top"><img src="<%=pathGfx%>/exmpl_relsel_single_catos.gif"></td>
</tr>
<tr>
  <td><img src="<%=pathGfx%>/b1x1.gif" height="13"></td>
</tr>
</tbody></table>

</span></td></tr>
    </tbody></table>
  </td></tr>
  </tbody></table>
</td></tr>
</tbody></table>



  <table border="0" cellpadding="0" cellspacing="0">
  <tbody><tr><td bgcolor="#ffffff">
   <table border="0" cellpadding="8" cellspacing="0">
    <tbody><tr><td align="left"><span class="infoboxData">
</form>  

</td>   
</tr>
</tr>
</table>

</span></td></tr>
    </tbody></table>
  </td></tr>
  </tbody></table>
</td></tr>
</tbody></table>

<script language="javascript"><!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================

  //........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function actionBtnGo(elemName) {
       setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO%>" );
      }
  function actionBtnGoOver(elemName) {
     setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_GO_OVER%>" );
      }
  
  //........................................................................  
  // DESCRIPTION:
  // Submit the form.
  //........................................................................  
  function submitSoftwareSelector() {  
    var formObj;
    var elements; 
    var submit = true ;
    
    formObj = document.forms['softwareSelector'];
    elements = formObj.elements;
    
    if (formObj.osType.value== '' ) {
      submit = false;
      alert("Choose a Software Type to Begin Search ");
      return false;
    }  
    
    if(submit) {
    document.forms['softwareSelector'].submit(); 
    }
  }  
  
 function resetReleaseNumberExactSWAction()
  {
  document.forms['softwareSelector'].elements['swreleaseNumberExact'].value='';  } 
 
 function resetSWAction()
  {
  document.forms['softwareSelector'].elements['osType'].value='';  } 
//--></script>

 
   
  </td>
</tr>
</tbody></table>
</table>

     
<%= Footer.pageFooter(globals) %>
<%
monitorUtil.cesMonitorEnd();
%>
<!-- end -->
