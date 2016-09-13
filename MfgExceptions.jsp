<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004-2006, 2008, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.*" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

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
<%@ page import="com.cisco.eit.sprit.logic.exceptions.*" %>
<%@ page import="com.cisco.eit.sprit.model.pcodegroup.*" %>
<%@ page import="com.cisco.eit.sprit.model.demlabel.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumberHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumber" %>
<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.*" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%
  Context ctx = new InitialContext();
  Integer 			releaseNumberId;
  SpritAccessManager 		spritAccessManager;
  SpritGlobalInfo 		globals;
  SpritGUIBanner 		banner;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
    MonitorUtil monUtil = new MonitorUtil();
    monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "BOM Mfg Exceptions");

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
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }
  
  // Get release number information.
  String osType = null;
  String softwareType = null;
  ReleaseNumber releaseNumber = null;
  try {
    // Setup
	ReleaseNumberHelper releaseNumberHelper = new ReleaseNumberHelper();
	releaseNumber = releaseNumberHelper.getReleaseNumber(releaseNumberId);
    osType = releaseNumber.getOsTypeName();
    softwareType = releaseNumber.getSoftwareTypeName();
  } catch( Exception e ) {
    throw e;
  }  // catch  

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

%>
<script>
  function changeSoftwareType() {
    document.mfgExceptionsSoftwareSelection.submit();
  }
</script>
<form name="mfgExceptionsSoftwareSelection" method="post" action="SoftwareSearchProcessor">

<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>

<input name="from" value="mfgExceptions" type="hidden">
</form>
<% if( "IOS".equalsIgnoreCase( osType )) { %>
<%= SpritReleaseTabs.getTabs(globals, "bom") %>
<% } else if("IOX".equalsIgnoreCase( osType )){ %>
<%= SpritReleaseTabs.getNonIosTabs(globals, "bom") %>
<% }else {%>
<%= SpritReleaseTabs.getOSTypeTabs(globals, "bom")%>
<% }%>

<%
  String webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString()) 
		+"&osTypeId="+ WebUtils.getParameter(request,"osTypeId");

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>
 
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" align="left">
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		new boolean [] { true, true, true, false, true },
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

  <center>
<jsp:useBean id="releaseBean" scope="session"
    class="com.cisco.eit.sprit.ui.ReleaseBean"></jsp:useBean>
<jsp:useBean id="labelBean" scope="session" class="com.cisco.eit.sprit.ui.addLabelBean">
</jsp:useBean>

<br/><br/><br/></center>
<font size="+1" face="Arial,Helvetica"><b>
  Add / Remove Exceptions for Product Structure that are assigned to '<%=osType%>_ALL' Product Group.
</b></font>
<%
    ExceptionsSessionHome exceptionHome = (ExceptionsSessionHome) 
    	ctx.lookup("exceptions.ExceptionsSessionHome");
    ExceptionsSession exceptionSession = exceptionHome.create();
    Collection listAllLabels = exceptionSession.findLabelEntityAssignToAll(osType);

    if(!listAllLabels.isEmpty()) {
%>
<form name="exception_form" method='POST' action="ExceptionProcess?releaseNumberId=<%=releaseNumberId%>&osTypeId=<%= WebUtils.getParameter(request,"osTypeId") %>">
  <table>
  <center><br/>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">
  <tr bgcolor="#d9d9d9">
    <td valign="top"><span class="dataTableTitle">Label</span></td>
    <td valign="top"><span class="dataTableTitle">Hardcoded Part No.</span></td>
    <td valign="top"><span class="dataTableTitle">All platforms</span></td>
    <td valign="top"><span class="dataTableTitle">&nbsp;</span></td>
    <td valign="top"><span class="dataTableTitle">Excluded Platforms</span></td>
  </tr>
<%
	    Iterator iter = listAllLabels.iterator();
        StringBuffer bufferLableIds = new StringBuffer();
        while( iter.hasNext() ) {
        	DemLabelEntity demLabelEntity = ( DemLabelEntity ) iter.next();

                bufferLableIds.append( demLabelEntity.getLabelSeqId() );
                if( iter.hasNext() ) 
                    bufferLableIds.append( '|' );
%>
  <tr bgcolor="#ffffff">
    <td><span class="dataTableData"><%=demLabelEntity.getLabelName()%></span></td>
    <td><span class="dataTableData"><%=demLabelEntity.getHardCodedPartno()%></span></td>
    <td><span class="dataTableData">
         <select id="available_<%=demLabelEntity.getLabelSeqId()%>" name="available_<%=demLabelEntity.getLabelSeqId()%>" multiple size=10 style="font-family:Verdana;" >
<%    
                Vector listExcludedPlatforms = exceptionSession.findIncludedPlatforms(demLabelEntity.getLabelName(), osType);
                Enumeration enu = listExcludedPlatforms.elements();
                while( enu.hasMoreElements() ) {
                    String val = ( String ) enu.nextElement();
%>
              <option value="<%=val%>">
                    <%=val%>
              </option>
<%
                }
%>
         </select></span>
    </td>
    <td><span class="dataTableData">
	<input type="button" name="Add"	value="   Add >>   " 
		onclick="add( 'available_<%=demLabelEntity.getLabelSeqId()%>', 
			'excluded_<%=demLabelEntity.getLabelSeqId()%>')">
	   <br/>
	<input type="button" name="Remove" value="<< Delete " 
		onclick="add('excluded_<%=demLabelEntity.getLabelSeqId()%>',
			'available_<%=demLabelEntity.getLabelSeqId()%>' )">
        </span>
    </td>
    <td><span class="dataTableData">
         <select id="excluded_<%=demLabelEntity.getLabelSeqId()%>" name="excluded_<%=demLabelEntity.getLabelSeqId()%>" multiple size=10 style="font-family:Verdana;width: 100%">    
<%
                listExcludedPlatforms = exceptionSession.findExcludedPlatforms(demLabelEntity.getLabelName(), osType);
                String strOldExceptions = "";
                enu = listExcludedPlatforms.elements();
                while( enu.hasMoreElements() ) {
                    String val = ( String ) enu.nextElement();
                    strOldExceptions += val;
                    if( enu.hasMoreElements() ) 
                    	strOldExceptions += "|";
%>
              <option value="<%=val%>">
                     <%=val%>
              </option>
<%
                } // end of while( enum.hasMoreElements() ) 
%>
         </select></span>
         <input type="hidden" id="old_excluded_<%=demLabelEntity.getLabelSeqId()%>" name="old_excluded_<%=demLabelEntity.getLabelSeqId()%>" value="<%=strOldExceptions%>">
         <input type="hidden" id="sel_excluded_<%=demLabelEntity.getLabelSeqId()%>" name="sel_excluded_<%=demLabelEntity.getLabelSeqId()%>" value="">
    </td>
  </tr>
<%
      } // end of while( iter.hasNext() )
%>
     <input type="hidden" name="labelids" value="<%=bufferLableIds.toString()%>">
      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>
  <br/><img src="../gfx/btn_save_updates.gif" alt="Copy Images" border="0" name="btnCopyImages1" 
  	onclick="javascript:submitThisPage()" 
  	onmouseover="setImg('btnCopyImages1','../gfx/btn_save_updates_over.gif')" onmouseout="setImg('btnCopyImages1','../gfx/btn_save_updates.gif')" />
  </center><br/><br/>
 </form> 
  
<script language="javascript">
  function GetSourceRelease(releaseId) {
    W = window.open('ReleaseSelectorPopupBomCopy.jsp?actionClass=ReleaseSelectorPopupResultBomCopy.jsp&workingRelease='+releaseId,
    	'PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=500,height=500')
    W.focus();
  }
  
  function add( source, destination) {

       var srcSelectBox = document.getElementById(source);
       var dstSelectBox = document.getElementById(destination);
       for( var i = srcSelectBox.length-1; i>=0; i--) {	

           if(srcSelectBox.options[i].selected) {
               // add this to second box
               var opt = new Option(srcSelectBox.options[i].text, srcSelectBox.options[i].value);
               dstSelectBox.options[dstSelectBox.options.length] = opt;

               srcSelectBox.options[i].selected = false;
               // remove from the second one
               for(var j=i;j<srcSelectBox.length-1;j++) {
                   srcSelectBox.options[j].text=srcSelectBox.options[j+1].text;
                   srcSelectBox.options[j].value=srcSelectBox.options[j+1].value;
               }

               srcSelectBox.length--;
           }
       }
  }

  function submitThisPage() {

       var length = document.forms.exception_form.elements.length;
       var listOfExcludedPlatforms;
       for( var index = 0; index < length; index++ ) {
           var control = document.forms.exception_form.elements[index];
           if( control.type == 'select-multiple' && 
               control.name.substr(0, 'excluded_'.length ) == 'excluded_' ) {

	       listOfExcludedPlatforms = '';
	       for( var i = 0; i < control.length; i++ ) {
	          listOfExcludedPlatforms += control.options[i].text;
	          if( i != (control.length - 1 ) ) 
	              listOfExcludedPlatforms += '|';
	       }

//	       alert ( listOfExcludedPlatforms );
	       var id = 'sel_excluded_' + control.name.substr( 'excluded_'.length );

//	       alert ( id );
	       var hiddenVar = document.getElementById(id);

	       hiddenVar.value = listOfExcludedPlatforms;
//	       alert ( hiddenVar.value );
           }
       }
       
       document.forms[1].submit();
  }

</script>
<% } else { %>
     <br/><br/> There are no labels associated to <%=osType%>_ALL.<br/>
<% } %>
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
