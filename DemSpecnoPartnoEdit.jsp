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

<%@ page import="java.util.*" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>

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

<%
  Context ctx = null;
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
  ReleaseNumberHelper releaseNumberHelper = new ReleaseNumberHelper();
  ReleaseNumber releaseNumber = releaseNumberHelper.getReleaseNumber(releaseNumberId);
  String osTypeName = releaseNumber.getOsTypeName();
  String softwareType = releaseNumber.getSoftwareTypeName(); 
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
    document.demEditSoftwareSelection.submit();
  }
</script>
<form name="demEditSoftwareSelection" method="post" action="SoftwareSearchProcessor">
<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>
<input name="from" value="demEdit" type="hidden">
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
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		new boolean [] { true, false },
          		new String [] { "View", "Edit" },
          		new String [] { "DemSpecnoPartnoView.jsp?" + webParamsDefault,
            		                "DemSpecnoPartnoEdit.jsp?srcReleaseId=" + 
            		                    WebUtils.escUrl(releaseNumberId.toString()) + "&" + webParamsDefault}
            		        ) ) );
           %>
         </td>
    	<td valign="middle" width="30%" align="left">
          <% 
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
           %>
         </td>
   </table>

<jsp:useBean id="releaseBean" scope="session"
    class="com.cisco.eit.sprit.ui.ReleaseBean"></jsp:useBean>

<br/> <br/><br/>

<font size="+1" face="Arial,Helvetica"><b>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Component Partno List
</b></font>
<%
  // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

  // Declare DemMfgLabelEntity variables.
  DemMfgLabelEntityHome dmleHome;
  DemMfgLabelEntity dmleObj;
  Collection dmleCollection;
  Map dmleLabelToPrefixMap = new HashMap();

  // Load the DEM part number prefixes.  Also map the objects just in case we
  // need them later for some server-side processing.
  ctx = new InitialContext();
  dmleHome = (DemMfgLabelEntityHome) ctx.lookup(
     "demmfglabel.DemMfgLabelEntityHome"
     );
  dmleCollection= dmleHome.findAll();
  Iterator iter = dmleCollection.iterator();
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
  //String releasename = ps.getARelease(releaseNumberId.intValue());
  String releasename= releaseNumber.getReleaseNumber();
  Integer srcReleaseId = releaseNumberId;
  
  if( request.getParameter("srcReleaseId") != null && 
  	!"".equals( request.getParameter("srcReleaseId")))
  	srcReleaseId = new Integer( request.getParameter("srcReleaseId")) ;

  Vector list = ps.getComponentPartNo(releaseNumberId);
  Map    fieldnameToVlabelnameMap = new HashMap();

  int myIndex = list.size();
  // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
%>


  <!-- main content table -->
<form name="demmodule" action="DemSubmit.jsp" method="post">

  <input type=hidden name="isFirst" value="no">
  <input type=hidden name="releaseNumberId" value="<%= releaseNumberId %>">
  <input type="hidden" name="callingForm" value="demaddspecnoservlet">
  <input type="hidden" name="releasename" value="<%= releasename %>">
  <input type="hidden" name="osTypeId" value="<%= WebUtils.getParameter(request,"osTypeId") %>">
  
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
    <td valign="top"><span class="dataTableTitle">Main Part Number<br/>
    		<font size="-2" face="Arial,Helvetica" color="#807090">
    		          Example: 12-3456-78
          	</font></td></span></td>
    <td valign="top"><span class="dataTableTitle">Spare Part Number<br/>
    		<font size="-2" face="Arial,Helvetica" color="#807090">
    		          Example: 12-3456-78
          	</font></span></td>
  </tr>
      <%
      int nIndex = -1;
      for(int lIndex=0; lIndex<list.size(); lIndex++) {
          AdditionsInfo info = (AdditionsInfo) list.elementAt(lIndex);
        
          Integer pfamily = info.getPlatformFamilyId();
          Integer labelseq = info.getLabelSeqId();
      %>

  <tr bgcolor="#ffffff">
    <td><span class="dataTableData"><%= info.getPlatformFamily() %></span></td>
    <td><span class="dataTableData"><%= info.getLabelName() %></span></td>
	<%
	if (info.getHardCoded()) {
	  if (info.getMain()) {
        %>
    <td><span class="dataTableData"><%= info.getMainHardCodedPartNo()%></span>
<%--
	    <input type="hidden" name="<%="_"+lIndex+"mainnovalue"%>"
		size="11" value="<%=info.getMainHardCodedPartNo() %>">
--%>
    </td>
        <%
          } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
          }

	  if (info.getSpare()) {
        %>
    <td><span class="dataTableData"><%= info.getSpareHardCodedPartNo() %></span>
<%--
            <input type="hidden" name="<%="_"+lIndex+"sparenovalue"%>"
            	size="11" value= "<%=info.getSpareHardCodedPartNo() %>">
--%>
    </td>
        <%
          } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
          }
         } else {
           nIndex++;
%>
        <input type="hidden" name="<%="_"+ nIndex +"pfamily"%>"
            value="<%=pfamily%>">
        <input type="hidden" name="<%="_"+nIndex+"pfamilyname"%>"
            value="<%= info.getPlatformFamily()%>">
        <input type="hidden" name="<%="_"+nIndex+"labelseq"%>"
            value="<%=labelseq%>">
        <input type="hidden" name="<%="_"+nIndex+"labelname"%>"
            value="<%= info.getLabelName() %>">
<%
            Vector vpartno = null;
//            if( srcReleaseId.equals( releaseNumberId ) )
                vpartno = ps.partnoFindbyReleaseLPlatfromExceptAdditions(
                    srcReleaseId, labelseq, pfamily);
/*
            else
                vpartno = ps.partnoFindbyReleaseLPlatfromExceptAdditions(
                    srcReleaseId, labelseq, pfamily);
*/


            if( vpartno == null || vpartno.size() == 0) {
              if (info.getMain() ) {
		      validateFieldList.add("_"+nIndex+"mainnovalue");
		      fieldnameToVlabelnameMap.put(
			   "_"+nIndex+"mainnovalue",
			   info.getLabelName());

        %>
    <td><span class="dataTableData">
    	<input type="text" name="<%="_"+nIndex+"mainnovalue"%>"
                size="11" value= ""></span>
    </td>
        <%
              } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
              }

              if (info.getSpare()) {
                validateFieldList.add("_"+nIndex+"sparenovalue");
                fieldnameToVlabelnameMap.put(
                     "_"+nIndex+"sparenovalue",
                     info.getLabelName());
            %>
    <td><span class="dataTableData">
    	<input type="text" name="<%="_"+nIndex+"sparenovalue"%>"
                    size="11" value= ""></span>
    </td>
        <%
              } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
              }
            } else {
//            for (int psIndex=0; psIndex<vpartno.size(); psIndex++) {
              if (info.getMain()) {
		      validateFieldList.add("_"+nIndex+"mainnovalue");
		      fieldnameToVlabelnameMap.put(
			   "_"+nIndex+"mainnovalue", info.getLabelName());

        %>
    <td><span class="dataTableData">
    	<input type="text" name="<%="_"+nIndex+"mainnovalue"%>"
                size="11" value= "<%=vpartno.elementAt(0) %>"></span>
    </td>
        <%
              } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
              }

              if (info.getSpare()) {
                validateFieldList.add("_"+nIndex+"sparenovalue");
                fieldnameToVlabelnameMap.put(
                     "_"+nIndex+"sparenovalue", info.getLabelName());
            %>
    <td><span class="dataTableData">
    	<input type="text" name="<%="_"+nIndex+"sparenovalue"%>"
                    size="11" value= "<%=vpartno.elementAt(1) %>"></span>
    </td>
        <%
              } else {
        %>
    <td><span class="dataTableData">&nbsp;</span></td>
        <%
              }
//            }  // for (int psIndex=0; psIndex<vpartno.size(); psIndex++)
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
  </br></br>
  <center>
        <!-- submit buttons -->
        <!--input type="submit" name="action" value="save"-->
        <!--input type="image" src="gfx/btn_save_updates.gif" border="0"
            name="action" value="save"
            onClick="document.forms['demmodule'].submit()" -->
        <a href="javascript:checkSubmit()"><img
            src="../gfx/btn_save_updates.gif" border="0" name="Continue" /></a>
  </center>
  <input type="hidden" name="myindex" value="<%=(nIndex + 1)%>">

</form>

<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->


<script type="text/javascript">

function checkSubmit()
{
  var obj,objForm,objName,objValue;

  objForm = document.demmodule;

  var emptyflag = false;
  var valid = true;

  // validFieldList loop: begin
  <%
  for(int arrLen =0; arrLen<validateFieldList.size(); arrLen++) {
  out.println("    if(checkEmptyField(objForm."
       + validateFieldList.get(arrLen)+"))");
  out.print(
      "      {\n" +
      "      alert(\"Label \\\"" +
           fieldnameToVlabelnameMap.get(validateFieldList.get(arrLen)) +
           "\\\" is blank.  Please enter a part number.\");\n" +
      "      objForm." + validateFieldList.get(arrLen) + ".select();\n" +
      "      objForm." + validateFieldList.get(arrLen) + ".focus();\n" +
      "      return;\n" +
      "      }\n"
      );
  }
  %>
  // validFieldList loop: end

  <%
  for(int arrLen =0; arrLen<validateFieldList.size(); arrLen++)
    {
        String prefix = (String) dmleLabelToPrefixMap.get(
                    (String) fieldnameToVlabelnameMap.get(
                        (String) validateFieldList.get(arrLen)));
        if( prefix != null && !"".equals( prefix ) )
	    out.print(
		"    if(!validateField(objForm."
		    + validateFieldList.get(arrLen)
		    + ",\""
		    + WebUtils.escHtml(
			(String) fieldnameToVlabelnameMap.get(
			    (String) validateFieldList.get(arrLen)
			    )
			)
		    + "\",\""
		    + WebUtils.escHtml(
			(String) dmleLabelToPrefixMap.get(
			    (String) fieldnameToVlabelnameMap.get(
				(String) validateFieldList.get(arrLen)
				)
			    )
			)
		    + "\"))" +
		"      {\n" +
		"      objForm." + validateFieldList.get(arrLen) + ".select();\n" +
		"      objForm." + validateFieldList.get(arrLen) + ".focus();\n" +
		"      return;\n" +
		"      }\n"
		);
    }
  %>

  document.forms['demmodule'].submit();
  }


function checkEmptyField(formObj) {
	var checkempty = false;
	var regex;
	
	regex = /^\s*$/;
	
	if( formObj.value.length==0 || regex.test(formObj.value) ) {
	  checkempty = true;
	}  // if( formObj.value.length==0 || ... )
	
	return checkempty;
}

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
  W.focus()
  }


<!--
//.........................................................................
// DESCRIPTION:
// Validates the form field for format and part number prefixes.
//
// input:
// formObj: Field object to be validated.  This should be a text type of
//     field.  The field should *not* be blank!
// labelName: The name for this label (not the name of the field).
// prefixes: A string containing the valid prefixes!
//
// OUTPUT:
// result (bool): Either one of these:
//
//     true: The field is OK.
//     false: The field had a problem.
//
//......................................................................... -->

function validateField(formObj,labelName,prefixes)
{
	var regex;
	var prefix;
	var e;
	var formValidatorObj;
	var errMsg;
	
	    
	// Set up the form validator pointer.
	formValidatorObj = document.forms['__partnovalidator'];
	
	// Make sure the form field follows the XX-XXXX-XX or XX-XXXXX-XX pattern.
	regex = /^\d{2}-\d{4,5}-\d{2}$/;
	if( !regex.test(formObj.value) )
	  {
	  // Nope.  It doesn't.
	  alert( "Label \"" + labelName + "\" does not follow the part number "
	      + "format 12-3456-78 or 12-34567-89." );
	  return(false);
	  }  // if( !regex.test(formObj.value) )
	
	// Figure out the prefix for this number.
	prefix = formObj.value.replace(/^(\d+)-.*$/,"$1");
	
	// Make sure the prefixes only has valid characters: digits and commas.
	prefixes.replace(/[^0-9,]/g,"");
	
	// Break the prefixes down into little bits.
	prefixarray = prefixes.split( /,/ );
	
	// If we don't have a prefix then we can leave right now.
	if( prefixarray.length<1 )
	  {
	  // ANY value that the users put in for this field is legit.
	  return( true );
	  }  // if( prefixarray.length<1 )
	
	// OK, I guess we have to check each prefix now to see if it matches the
	// user-entered prefix.  If we find a match then we can return true.  If
	// it falls all the way through to the end then we need to return false
	// because the user prefix was invalid.
	for( i=0; i<prefixarray.length; i++ )
	  {
	  if( prefixarray[i] == prefix )
	    {
	    // Match!  We can successfully return.
	    return( true );
	    }  // if( prefixarray[i] == prefix )
	  }  // for( i=0; i<prefixarray.length; i++ )
	
	// Construct a neato error message which will tell the user exactly what
	// prefixes are legal.
	errMsg = "Label \"" + labelName + "\" does not begin with a legal prefix.";
	errMsg += "  (It must begin with ";
	for( i=0; i<prefixarray.length; i++ )
	  {
	  if( i>0 )
	    {
	    errMsg += "or ";
	    }  // if( i>0 )
	
	  errMsg += "\"" + prefixarray[i] + "\" ";
	  }  // for( i=0; i<prefixarray.length; i++ )
	errMsg += ".)";
	
	
	alert( errMsg );
	return(false);
}  // function validateField(formObj)

</script>
<!-- end -->
