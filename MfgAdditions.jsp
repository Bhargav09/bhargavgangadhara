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

<%@ page import="java.util.*,
                 com.cisco.eit.sprit.ui.dataobject.LabelInfo" %>
<%@ page import="javax.ejb.*" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.*" %>
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
<%@ page import="com.cisco.eit.sprit.logic.additions.*" %>
<%@ page import="com.cisco.eit.sprit.model.pcodegroup.*" %>
<%@ page import="com.cisco.eit.sprit.model.demlabel.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumberHelper" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumber.ReleaseNumber" %>
<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.*" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%
  Context ctx = new InitialContext();
  Integer 			releaseNumberId;
  SpritAccessManager 		spritAccessManager;
  SpritGlobalInfo 		globals;
  SpritGUIBanner 		banner;
  String 			jndiName;
  String 			pathGfx;
  TableMaker 			tableReleasesYouOwn; 
  Vector 			opusRecords = new Vector();
  String			htmlNoValue;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
    MonitorUtil monUtil = new MonitorUtil();
    monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "BOM Mfg Additions");


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
 htmlNoValue = "<span class=\"noData\"><center>---</center></span>";

%>
<script>
  function changeSoftwareType() {
    document.mfgAdditionsSoftwareSelection.submit();
  }
</script>
<form name="mfgAdditionsSoftwareSelection" method="post" action="SoftwareSearchProcessor">

<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>
<input name="from" value="mfgAdditions" type="hidden">
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
          		new boolean [] { true, true, true, true, false },
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

<%
    AdditionsSessionHome additionHome = (AdditionsSessionHome) 
    	ctx.lookup("additions.AdditionsSessionHome");
    AdditionsSession additionSession = additionHome.create();

    PCodeGroupHome pcodeGroupHome = (PCodeGroupHome)
		ctx.lookup("PCodeGroupBean.PCodeGroupHome");
    
/*
    FeatureEntityHome featureHome = ( FeatureEntityHome )
	ctx.lookup("feature.FeatureEntityHome");
    Enumeration enum = featureHome.findByReleaseId( releaseNumberId );
*/    
    Vector listOfPlatforms, listOfLabels, listOfAdditions ;
    
    listOfPlatforms = additionSession.getPlatforms(releaseNumberId);
    listOfLabels = additionSession.getLabels(releaseNumberId);
    listOfAdditions = additionSession.getAllAdditionsByRelease( releaseNumberId );
    
        String strErrorMessage = ( String ) (request.getAttribute( "errorMessage" )==null?"":request.getAttribute( "errorMessage" ));
    

    DemMfgLabelEntityHome dmleHome = (DemMfgLabelEntityHome) 
          ctx.lookup( "demmfglabel.DemMfgLabelEntityHome" );
    HashMap dmleLabelToPrefixMap = new HashMap();
    Collection dmleCollection= dmleHome.findAll();
    Iterator iter = dmleCollection.iterator();

    while( iter.hasNext() ) {

       // Get this object.
       DemMfgLabelEntity dmleObj = (DemMfgLabelEntity) iter.next();
       if( dmleObj.getPartNoPrefix() != null )
           dmleLabelToPrefixMap.put(
              (String) dmleObj.getLabel(),
              (String) dmleObj.getPartNoPrefix() );
    }

    Set setLabelPrefix = dmleLabelToPrefixMap.keySet();
    
%>

<%=strErrorMessage%>

<form name="additions_form" method='POST' 
     action="AdditionsProcess?releaseNumberId=<%=releaseNumberId%>&osTypeId=<%= WebUtils.getParameter(request,"osTypeId") %>">
  <table>
  <center>
  <br/><br/><br/><br/>
  <table border="0" cellpadding="1" cellspacing="0" width="60%">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1" width="100%">
  <tr bgcolor="#d9d9d9">
    <td valign="top" width="26%"><span class="dataTableTitle">Part No.</span></td>
    <td valign="top" width="30%"><span class="dataTableTitle">Platform</span></td>
    <td valign="top" width="30%"><span class="dataTableTitle">Label</span></td>
    <td valign="top" width="7%"><span class="dataTableTitle">Main</span></td>
    <td valign="top" width="7%"><span class="dataTableTitle">Spare</span></td>
  </tr>
  <tr bgcolor="#ffffff">
    <td valign="center" width="26%><span class="dataTableData">
        <input type="text" name="newHardcodedPartNo" value=""></span></td>
    <td valign="center" width="30%"><span class="dataTableData">
         <select name="newPlatforms" multiple size=5 
                  style="font-family:Verdana;width:100%;" >
<%    
                Enumeration enu = listOfPlatforms.elements();
                while( enu.hasMoreElements() ) {
%>
                  <option value="<%=enu.nextElement()%>">
                      <%=enu.nextElement()%>
                  </option>
<%
                }
%>
         </select>
        </span></td>
    <td valign="center" width="30%"><span class="dataTableData">
         <select name="newLabel" size=5
                  style="font-family:Verdana;width:100%;" >
<%
                enu = listOfLabels.elements();
                while( enu.hasMoreElements() ) {
                  String strLabel = ( String ) enu.nextElement();
%>
                  <option value="<%=strLabel%>">
                      <%=strLabel%>
                  </option>
<%
                }
%>
         </select>
        </span></td>
    <td valign="center" align="center" width="7%"><span class="dataTableData">
        <input type="checkbox" name="newMain"></span></td>
    <td valign="center" align="center" width="7%"><span class="dataTableData">
        <input type="checkbox" name="newSpare"></span></td>
  </tr>

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>

  <table>
  <center>
  <br/><br/>
  <table border="0" cellpadding="1" cellspacing="0" width="70%">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1" width="100%">
  <tr bgcolor="#d9d9d9">
    <td valign="center" width="15%"><span class="dataTableTitle">Delete</span></td>
    <td valign="center" width="25%"><span class="dataTableTitle">Part Number</span></td>
    <td valign="center" width="40%"><span class="dataTableTitle">&nbsp;&nbsp;Platform&nbsp;&nbsp;</span></td>
    <td valign="center" width="40%"><span class="dataTableTitle">&nbsp;&nbsp;Label&nbsp;&nbsp;</span></td>
    <td valign="center" width="10%"><span class="dataTableTitle">&nbsp;&nbsp;Main&nbsp;&nbsp;</span></td>
    <td valign="center" width="10%"><span class="dataTableTitle">&nbsp;&nbsp;Spare&nbsp;&nbsp;</span></td>
  </tr>
<%
    Enumeration enumAdditions = listOfAdditions.elements();
    while( enumAdditions.hasMoreElements() ) {
        AdditionsInfo additionInfo = ( AdditionsInfo ) enumAdditions.nextElement();

        Integer partNoId = additionInfo.getPartnoSeqId();
%>
  <tr bgcolor="#ffffff">
    <td valign="top"><span class="dataTableData">
       <input type="hidden" name="partno_seqid_<%=partNoId.intValue()%>">
       <input type="checkbox" name="del_hard_<%=partNoId.intValue()%>">
        </span></td>
    <td valign="top"><span class="dataTableData"><%=additionInfo.getHardCodedPartNo()%>
        <input type="hidden" name="hard_partno_<%=partNoId.intValue()%>" 
             value=<%=additionInfo.getHardCodedPartNo()%>>
        </span></td>
    <td valign="top"><span class="dataTableData">
          <%=additionInfo.getPlatformFamily()%></span></td>
    <td valign="top"><span class="dataTableData">
          <%=additionInfo.getLabelName()%></span></td>
    <td valign="top"><span class="dataTableData">
        <input type="hidden" name="old_main_<%=partNoId.intValue()%>"
            value="<%=((additionInfo.getMain()) ? "Y" : "N")%>">
        <input type="checkbox" name="main_<%=partNoId.intValue()%>" 
	    <% if( additionInfo.getMain() ) { %>
		  CHECKED
	    <% } %>
	    > </span></td>
    <td valign="top" width="10%"><span class="dataTableData">
        <input type="hidden" name="old_spare_<%=partNoId.intValue()%>"
            value="<%=((additionInfo.getSpare()) ? "Y" : "N" )%>">
        <input type="checkbox" name="spare_<%=partNoId.intValue()%>" 
	    <% if( additionInfo.getSpare() ) { %>
		  CHECKED
	    <% } %>
	    > </span></td>
  </tr>
<%
    }
%>

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>

  <br/><img src="../gfx/btn_save_updates.gif" alt="Save Additons" border="0" name="btnSaveUpdates1"
  	onclick="javascript:checkRequired(document.additions_form)"
  	onmouseover="setImg('btnSaveUpdates1','../gfx/btn_save_updates_over.gif')" onmouseout="setImg('btnSaveUpdates1','../gfx/btn_save_updates.gif')" />
  </center><br/><br/>
 </form>
<script language="JavaScript">
<!--
var  labelPrefixMap = new Array(<%=setLabelPrefix.size()%>);
var  LabelToAll = new Array();
var  platformLabelMap = new Array();
var  labelToAnyPlatform = new Array();

<%
    enu = listOfAdditions.elements();
    int nLabelToAllPos = 0;
    while(enu.hasMoreElements()) {
        AdditionsInfo info = (AdditionsInfo) enu.nextElement();

        if( info.getPlatformFamily().endsWith("_ALL")) {
           out.println("LabelToAll[" + nLabelToAllPos++ +"] = \""+ info.getLabelName() +"\";");
        } else {
           out.println("platformLabelMap[ \""+ info.getPlatformFamily() + "&&&" +
                  info.getLabelName() + "\" ] = \"1\";");
           out.println("labelToAnyPlatform[ \""+ info.getLabelName() + "\" ] = \"1\";");
        }
    }

    Iterator iter1 = setLabelPrefix.iterator();
    while( iter1.hasNext() ) {
       String strName = ( String ) iter1.next();
       out.println( "labelPrefixMap[ '" + strName + "' ] = '" +
          ( String ) dmleLabelToPrefixMap.get( strName ) + "';" );
    }
%>



function checkRequired(formObj) {

      var strError = "";
      var reqflag  = true;

      if ( formObj.newHardcodedPartNo.value.length > 0 ) {

         var regexI;
         var regexII;
         regexI = /^\d{2}-\d{4}-\d{2}$/;
         regexII = /^\d{2}-\d{5}-\d{2}$/;

         if( !(regexI.test(formObj.newHardcodedPartNo.value) ||
               regexII.test(formObj.newHardcodedPartNo.value))) {
              alert( " Enter a valid HardCodedPartno: 12-3456-78 or 12-34567-89 \n" );
              return false;
          }

          // first check Label is selected or not
          obj = formObj.newLabel;
          if( obj.selectedIndex < 0 ) {
              strError += "Please select Label";
              alert( strError );
              return false;
          }

	  objName = obj[obj.selectedIndex].text;
	  objValue = obj[obj.selectedIndex].value;

          // then check the prefix is ok
	  if( (labelPrefixMap[ objName ] != null) &&
	      (!validateField2(formObj.newHardcodedPartNo, objName,
		labelPrefixMap[ objName ] ))) {
	      return false;
	  }

          // check atleast one platform is selected.
          if( formObj.newPlatforms.selectedIndex  < 0 ) {
              alert( "Select one platform atleast." );
              return false;
          }

          // check atleasr main or spare is selected
         if ((!(formObj.newMain.checked))&(!(formObj.newSpare.checked))) {
             alert( " Main or Spare must be selected \n" );
             return false;
         }

      }

      obj = formObj.newLabel;
<%--      objName = obj[obj.selectedIndex].text;--%>
<%--      objValue = obj[obj.selectedIndex].value;--%>
      if(formObj.newHardcodedPartNo.value.length > 0 ) {
          var selLabelName = obj[obj.selectedIndex].text;
    <%--
          if( objValue == "-1" )
              tempName = formObj.newLabelName.value;
          else
              tempName = formObj.LabelName[formObj.LabelName.selectedIndex].text;
    --%>
    <%--      alert( "Here it is " + formObj.newPlatforms[formObj.newPlatforms.selectedIndex] );--%>
          var noOfPlatformSelected = 0;
          var isAllSelected = false;
          for(var i=0; i<formObj.newPlatforms.length; i++ ) {
              var tempObject = formObj.newPlatforms[i];
              if( tempObject.selected ) {
                  noOfPlatformSelected++;
              } else {
                  continue;
              }

              if(tempObject.text.indexOf('_ALL') != -1) {
                  isAllSelected = true;

                  // check if there is any platform and label combo exists
                  if( labelToAnyPlatform[selLabelName] == "1" ) {
                        alert( 'Label ' + selLabelName + ' is already associated to some platforms. Please delete it before you add <%=osType%>_ALL' );
                        return false;
                  }
              } else {
                  // check If there is any ALL exist with this label
                  for(var k=0; k<LabelToAll.length;k++) {
                     if(LabelToAll[k] == selLabelName) {
                        alert( 'Label: ' + selLabelName + ' associated with <%=osType%>_ALL.' );
                        return false;
                     }
                  }
                  if( platformLabelMap[tempObject.text + '&&&' + selLabelName ] == "1" ) {
                        alert( 'Label: ' + selLabelName + ' and Platform: ' + tempObject.text + ' combination already exists.' );
                        return false;
                  }
              }
          }

          if( noOfPlatformSelected > 1 && isAllSelected ) {
              alert( "Please select <%=osType%>_ALL or any other platforms, but not both" );
              return false;
          }
      }
      submitThisPage();
}


function validateField(formObjTxtField)
{
var regexI;
var regexII;
regexI = /^\d{2}-\d{4}-\d{2}$/;
regexII = /^\d{2}-\d{5}-\d{2}$/;

alert( '3 -- ' + formObjTxtField.value );
if( regexI.test(formObjTxtField.value) || regexII.test(formObjTxtField.value) )
   return true;
else
   return false;

}

function validateField2(formObj,labelName,prefixes)
{
var regex;
var prefix;
var e;
var formValidatorObj;
var errMsg;

// Set up the form validator pointer.
//formValidatorObj = document.forms['__partnovalidator'];

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



function submitThisPage() {
   document.forms['additions_form'].submit();
}
-->
</script>


<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
