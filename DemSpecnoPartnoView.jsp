<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004-2008, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.dataobject.AdditionsInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumberHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumber" %>
<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>

<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>

<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

<%
  Context ctx = new InitialContext();
  Integer 			releaseNumberId;
  ReleaseNumberModelHomeLocal   rnmHome;
  ReleaseNumberModelInfo        rnmInfo;
  ReleaseNumberModelLocal       rnmObj;
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


  MonitorUtil monUtil = new MonitorUtil();
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "IBOM Spec Num Part Num");

  if( !spritAccessManager.isUserDem() ) {
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
  rnmInfo = null;
  String osTypeName = null;
  boolean isEditable = true;
  ReleaseNumberHelper releaseNumberHelper = new ReleaseNumberHelper();
  ReleaseNumber releaseNumber = releaseNumberHelper.getReleaseNumber(releaseNumberId);
  System.out.println("Release Number="+releaseNumber.getReleaseNumberId()+" OsType="+releaseNumber.getOsTypeName());
  osTypeName = releaseNumber.getOsTypeName();
  String softwareType = releaseNumber.getSoftwareTypeName(); 
  
  //check if os type is IOS, IOX or CATOS
  if(SpritUtility.isOsTypeIosIoxCatos(osTypeName)) {
	  try {
		    // Setup
		    jndiName = "ejblocal:ReleaseNumberModel.ReleaseNumberModelHome";
		    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup(jndiName);
		    rnmObj = rnmHome.create();
		    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
		    
		    isEditable = !rnmInfo.isMaintenanceNthRelease();
		    //osTypeName= rnmInfo.getOsType();
		    //System.out.println("Os Type="+osTypeName);
		} catch( Exception e ) {
		    throw e;
		}  // catch  
  }
  
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(SpritUtility.isOsTypeIosIoxCatos(osTypeName)){
	  banner.addReleaseNumberElement(releaseNumberId);
  }else {
	  banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
		 SpritGUI.renderOSTypeNav(globals,osTypeName,releaseNumber.getReleaseNumber(),"bom",WebUtils.getParameter(request,"osTypeId"),releaseNumberId.toString())
      );
  }
  
 //html macros
 htmlNoValue = "<span class=\"noData\"><center>---</center></span>";

%>
<script>
  function changeSoftwareType() {
    document.demViewSoftwareSelection.submit();
  }
</script>
<form name="demViewSoftwareSelection" method="post" action="SoftwareSearchProcessor">
<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>
<input name="from" value="demView" type="hidden">
</form>
<% if( "IOS".equalsIgnoreCase( osTypeName )) { %>
<%= SpritReleaseTabs.getTabs(globals, "bom") %>
<% } else if("IOX".equalsIgnoreCase( osTypeName )){ %>
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
    	<td valign="middle" width="70%" align="left">
          <% 
          	//Added Sprit 6.9 CSCsj85205
          	if (isEditable){
	             out.println( SpritGUI.renderTabContextNav( globals,
	            		 secNavBar.render( 
			          		new boolean [] { false, true },
			          		new String [] { "View", "Edit" },
			          		new String [] { "DemSpecnoPartnoView.jsp?" + webParamsDefault,
			            		                "DemSpecnoPartnoEdit.jsp?srcReleaseId=" + 
			            		                    WebUtils.escUrl(releaseNumberId.toString()) + "&" + webParamsDefault}
			            		        ) ) );
          	}else{
	             out.println( SpritGUI.renderTabContextNav( globals,
	            		 secNavBar.render( 
			          		new boolean [] { false},
			          		new String [] { "View"},
			          		new String [] { "DemSpecnoPartnoView.jsp?" + webParamsDefault}
			            		        ) ) );          		
          	}
           %>
         </td>
    	<td valign="middle" width="30%" align="left">
          <% 
          	//Added Sprit 6.9 CSCsj85205
          	if(isEditable){
                out.println( SpritGUI.renderTabContextNav( globals,
               		 secNavBar.render( 
   		          		new boolean [] { true, true, true, true, true },
   		          		new String [] { "Copy BOM", "Label Setup", "PartNo Prefix Setup", "Exceptions", "Additions" },
   		          		new String [] { "javascript:GetSourceRelease('" + releaseNumberId + "', '" + osTypeName + "')",
   		          		                "LabelSetup.jsp?" + webParamsDefault,
   		            		                "MfgLabelSetup.jsp?" + webParamsDefault,
   		            		                "MfgExceptions.jsp?" + webParamsDefault,
   		            		                "MfgAdditions.jsp?" + webParamsDefault,
   		            		              }, false
   		            		        ) ) );

          	}
           %>
         </td>
      </tr>
   </table>

  <center><br/><br/><br/>
<!--  <img src="../gfx/btn_copy_image.gif" alt="Copy Images" border="0" name="btnCopyImages1" 
  	onclick="javascript:GetSourceRelease('<%=releaseNumberId%>')" 
  	onmouseover="setImg('btnCopyImages1','../gfx/btn_copy_image_over.gif')" onmouseout="setImg('btnCopyImages1','../gfx/btn_copy_image.gif')" /> -->
  </center>

<font size="+1" face="Arial,Helvetica"><b>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Component Partno List
</b></font>

<jsp:useBean id="releaseBean" scope="session"
    class="com.cisco.eit.sprit.ui.ReleaseBean"></jsp:useBean>

<%
  if (isEditable) {	
	  // Declare DemMfgLabelEntity variables.
	  DemMfgLabelEntityHome dmleHome;
	  DemMfgLabelEntity dmleObj;
	  Collection dmleColl;
	  Map dmleLabelToPrefixMap = new HashMap();
	
	  // Load the DEM part number prefixes.  Also map the objects just in case we
	  // need them later for some server-side processing.
	//  ctx = new InitialContext(System.getProperties());
	  dmleHome = (DemMfgLabelEntityHome) ctx.lookup(
	     "demmfglabel.DemMfgLabelEntityHome"
	     );
	  dmleColl = dmleHome.findAll();
	  Iterator iter = dmleColl.iterator();
	  while( iter.hasNext() ) {
	    // Get this object.
	    dmleObj = (DemMfgLabelEntity) iter.next();
	
	    if( dmleObj.getPartNoPrefix() != null )
	      {
	      // Map it.
	      dmleLabelToPrefixMap.put(
	          (String) dmleObj.getLabel(),
	          (String) dmleObj.getPartNoPrefix()
	          );
	      }  // if( dmleObj.getPartNoPrefix != null )
	    }  // while( dmleEnum.hasMoreElements() )
	  ArrayList validateFieldList = new ArrayList();
	  String releasenumberid = request.getParameter("releasenumberid");
	  PartnoSession ps = releaseBean.getPartnoSession();
	 // String releasename = ps.getARelease(releaseNumberId.intValue());
	  String releasename = releaseNumber.getReleaseNumber();
	  Integer srcReleaseId = releaseNumberId;
	  if( request.getParameter("srcReleaseId") != null && 
	  	!"".equals( request.getParameter("srcReleaseId")))
	  	srcReleaseId = new Integer( request.getParameter("srcReleaseId"));
	
	  Vector list = ps.getComponentPartNo(releaseNumberId);
	  Map    fieldnameToVlabelnameMap = new HashMap();
	//  int myIndex = vlabelpfamily.size();
	%>
	
	  <!-- main content table -->
	  
	  <table>
	  <center>
	  <br/><br/>
	  <table border="0" cellpadding="1" cellspacing="0" width="70%">
	  <tr><td bgcolor="#3D127B">
	    <table border="0" cellpadding="0" cellspacing="0" width="100%">
	    <tr><td bgcolor="#BBD1ED">
	      <table border="0" cellpadding="3" cellspacing="1" width="100%">
	  <tr bgcolor="#d9d9d9">
	    <td valign="top"><span class="dataTableTitle">Platform</span></td>
	    <td valign="top"><span class="dataTableTitle">Component Name</span></td>
	    <td valign="top"><span class="dataTableTitle">Main Part Number <br/>
	    		<font size="-2" face="Arial,Helvetica" color="#807090">
	    		          Example: 12-3456-78
	          	</font></td></span></td>
	    <td valign="top"><span class="dataTableTitle">Spare Part Number<br/>
	    		<font size="-2" face="Arial,Helvetica" color="#807090">
	    		          Example: 12-3456-78
	          	</font></span></td>
	  </tr>
	      <%
	      for(int lIndex=0; lIndex<list.size(); lIndex++) {
	          AdditionsInfo info = (AdditionsInfo) list.elementAt(lIndex);
	        
	          Integer pfamily = info.getPlatformFamilyId();
	          Integer labelseq = info.getLabelSeqId();
	      %>
	  
	  <tr bgcolor="#ffffff">
	    <td><span class="dataTableData"><%= info.getPlatformFamily() %></span></td>
	    <td><span class="dataTableData"><%= info.getLabelName()%></span></td>
		<%
		if ( info.getHardCoded() ) {
		  if ( info.getMain() ) {
	        %>
	    <td><span class="dataTableData"><%= info.getMainHardCodedPartNo() %></span></td>
	        <%
	          } else {
	        %>
	    <td><span class="dataTableData">&nbsp;</span></td>
	        <%
	          }
	
		  if (info.getSpare()) {
	        %>
	    <td><span class="dataTableData"><%= info.getSpareHardCodedPartNo()%></span></td>
	        <%
	          } else {
	        %>
	    <td><span class="dataTableData">&nbsp;</span></td>
	        <%
	          }
	         } else {
	         
	            Vector vpartno = ps.partnoFindbyReleaseLPlatfromExceptAdditions(
	                srcReleaseId, labelseq, pfamily);
	
	            if( vpartno == null || vpartno.size() == 0) {
	         %>
	    <td><span class="dataTableData">&nbsp;</span></td>
	    <td><span class="dataTableData">&nbsp;</span></td>
	         <%        
	            } else {
	              if ( info.getMain() ) {
	        %>
	    <td><span class="dataTableData"><%=vpartno.elementAt(0) %></span></td>
	        <%
	              } else {
	        %>
	    <td><span class="dataTableData">&nbsp;</span></td>
	        <%
	              }
	
	              if (info.getMain()) {
	            %>
	    <td><span class="dataTableData"><%=vpartno.elementAt(1) %></span></td>
	        <%
	              } else {
	        %>
	    <td><span class="dataTableData">&nbsp;</span></td>
	        <%
	              }
	            }
	         }
	        %>
	  </tr>
	       <% 
	         }
	        %>
	      </table>
	    </td></tr>
	    </table>
	  </td></tr>
	  </table>
 <% }else{
 %>	  <center><br><br><br>
 		<table cellspacing="0" cellpadding="3" border="1">
 		<tr bgcolor="#d9d9d9">
 		<td align="center"><span class="dataTableData">
 			Component Part Number List is not generated for Maintenance Nth Release <b><%=releaseNumber.getReleaseNumber()%></b>
 		</span></td>
 		</tr>
 		</table>
 	  </center>
<%  } %>
  
  
<script language="javascript">
  function GetSourceRelease(releaseId, osType ) {
	  <%
	  	if(SpritUtility.isOsTypeIosIoxCatos(osTypeName)) {
	  %>
	  W = window.open('ReleaseSelectorPopupBomCopy.jsp?osType=' + osType + '&actionClass=ReleaseSelectorPopupResultBomCopy.jsp&workingRelease='+releaseId,
    	'PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=500,height=500')
     <%
	  	} else {
     %>
	  W = window.open('go?action=copydemnonios&targetReleaseNumberId='+releaseId+'&mode=1&osType='+osType,
	        	'PlatformPopup','toolbar=no,ScrollBars=Yes,Resizable=Yes,locationbar=no,menubar=no,width=600,height=500')
	  <% }
	  %>
    W.focus();
  }
</script>
  

<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
