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

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
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

<%@ page import="com.cisco.eit.sprit.ui.dataobject.LabelInfo,com.cisco.eit.sprit.ui.dataobject.PlatformFamilyInfo,com.cisco.eit.shrrda.platformfamily.*,java.util.Vector,com.cisco.eit.sprit.ui.addLabelBean" %>

<%@ page import="com.cisco.eit.sprit.logic.labelsession.*" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

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
  
  MonitorUtil monUtil = new MonitorUtil();
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "BOM Label Setup");

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
  if( releaseNumberId != null )  {
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
    document.labelSetupSoftwareSelection.submit();
  }
</script>
<form name="labelSetupSoftwareSelection" method="post" action="SoftwareSearchProcessor">
<%= SpritGUI.pageHeader( globals,"DEM","" ) %>
<%= banner.render() %>
<input name="from" value="labelSetup" type="hidden">
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
    	<td valign="middle" align="left">
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		new boolean [] { true, false, true, true, true },
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
  Add / Delete Label Information
</b></font>
<br /><br />
		
<jsp:useBean id="labelBean" scope="session" class="com.cisco.eit.sprit.ui.addLabelBean">
</jsp:useBean>


<%

// Load the DEM part number prefixes.  Also map the objects just in case we
// need them later for some server-side processing.
//  ctx = new InitialContext(System.getProperties());
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
 //labelBean.getPFamily();
 LabelSession lbl = labelBean.getLabelSession();

 Vector LabelAssignedAll = null;
 LabelAssignedAll = lbl.findLabelAssignToAll(osType);
 for(int labelAllIndex=0; labelAllIndex<LabelAssignedAll.size(); labelAllIndex++){
//  System.out.println("Label All value "+ LabelAssignedAll.elementAt(labelAllIndex));
  }

 Vector pfInfoVector = lbl.getAllPlatformFamily(osType);
 PlatformFamilyInfo pfInfo = null;

 /*for(int pfIndex=0; pfIndex<pfInfoVector.size(); pfIndex++){
    pfInfo = (PlatformFamilyInfo) pfInfoVector.elementAt(pfIndex); 
    System.out.println(pfInfo.getPlatformFamilyName());
   } */
 
 
 //Vector vpf = null;
// Vector vpf = lbl.getvpfamily();
 //Vector vpfname = null;
// Vector vpfname = lbl.getvpfname();

//System.out.println(vpfname.size()) ;

//System.out.println(request.getRemoteUser());
// System.out.println(request.getAttribute("releaseid"));
 Vector labelInfoVector = null;
 LabelInfo labelInfo = null;
// System.out.println("calling labelbean");
 labelInfoVector = labelBean.getLabels(osType);    
 Vector uniqueLabels = null;
 uniqueLabels = lbl.getUniqueLabel();
//Following are added for the sort function
String sortByWhat = request.getParameter("sort");  
 if(sortByWhat != null){
  Vector tempLabelInfoVector = labelBean.getLabelsSortedBy(sortByWhat, labelInfoVector);
 }
%>



<script language="JavaScript">
<!--
var  LabelToAll = new Array();
var  labelPrefixMap = new Array(<%=setLabelPrefix.size()%>);
var  platformLabelMap = new Array();
var  alllabels = new Array();

<%
    if(labelInfoVector != null) {
        int nPos = 0;
        for(int lIndex=0; lIndex < labelInfoVector.size(); lIndex++) {
           labelInfo = (LabelInfo) labelInfoVector.elementAt(lIndex);
           if( labelInfo.getIsIncluded() )
                out.println("alllabels[ " + nPos++ + " ] = \"" + labelInfo.getLabelName() + "\";");
        }

        for(int lIndex=0; lIndex < labelInfoVector.size(); lIndex++) {
           labelInfo = (LabelInfo) labelInfoVector.elementAt(lIndex);
           if( labelInfo.getIsIncluded() )
                out.println("platformLabelMap[ \""+ labelInfo.getPlatform() + "&&&" +
                       labelInfo.getLabelName() + "\" ] = \"1\";");
        }
    }

    
    for(int labelAllIndex=0; labelAllIndex<LabelAssignedAll.size(); labelAllIndex++)
       out.println("LabelToAll["+labelAllIndex+"] = \""+LabelAssignedAll.elementAt(labelAllIndex)+"\";");

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
      var AllisSelected = false;
      obj = formObj.LabelName;
      objName = obj[obj.selectedIndex].text;
      objValue = obj[obj.selectedIndex].value;

      if (objValue == "0") {
              strError += " Select Label Name  \n";
              reqflag=false;
      }

      if ((objValue == "-1")&(formObj.newLabelName.value.length == 0)) {
          strError += " Enter New Label Name  \n";
          reqflag=false;
      }

      if( reqflag ) {
          var tempName;
          if( objValue == "-1" )
              tempName = formObj.newLabelName.value;
          else
              tempName = formObj.LabelName[formObj.LabelName.selectedIndex].text;

          if( formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text == "<%=osType%>_ALL" ) {
              //
              for( var i=0; i < alllabels.length; i++ ) {
                  if( alllabels[i] == tempName ) {
                     strError += " Platform: '" + formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text +
                        "' cannot be assigned to Label : '" + alllabels[i] + "' as it is already assigned to some platform, Please delete it before add. \n";
                     reqflag=false;
                      break;
                  }
              }
          } else {
              // check if there is any ALL is associated with this combination
              for( var i=0; i < LabelToAll.length; i++ ) {
                  if( LabelToAll[i] == tempName ) {
                      strError += " Platform: '" + formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text +
                        "' cannot be assigned to Label : '" + tempName + "' as '<%=osType%>_ALL' is already assigned to same label. \n";
                      reqflag=false;
                      break;
                  }
              }
          }


          if( platformLabelMap[formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text + "&&&" +
                tempName] == "1" ) {
              strError += " Platform : '" + formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text +
                     "' and Label : '" + tempName + "' Already added \n";
              reqflag=false;
          }
      }

      if( reqflag ) {
          var tempName;
          if( objValue == "-1" )
              tempName = formObj.newLabelName.value;
          else
              tempName = formObj.LabelName[formObj.LabelName.selectedIndex].text;

          if( platformLabelMap[formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text + "&&&" +
                tempName] == "1" ) {
              strError += " Platform : " + formObj.PlatformFamily[formObj.PlatformFamily.selectedIndex].text +
                     "and Label : " + tempName + " Already added \n";
              reqflag=false;
          }
      }

      if ((!(formObj.Main.checked))&(!(formObj.Spare.checked))) {
          reqflag=false;
          strError += " Main or Spare must be selected \n";
      }

      if ((formObj.HardCoded.checked)&(formObj.HardCodedPartno.value.length == 0)) {
          reqflag=false;
          strError += " Enter HardCodedPartno to HardCode \n";
      }


      if ((!(formObj.HardCoded.checked))&(!(formObj.HardCodedPartno.value.length == 0))) {
          reqflag=false;
          strError += " Select HardCode to Enter HardCodePartno \n";
      }


      if ((formObj.HardCoded.checked)&(!(formObj.HardCodedPartno.value.length == 0))) {
          if(!validateField(formObj.HardCodedPartno)) {
             reqflag=false;
             strError += " Enter a valid HardCodedPartno: 12-3456-78 or 12-34567-89 \n";
          }
      }


      for(var arrLen =0; arrLen<LabelToAll.length; arrLen++) {

          if( objValue == LabelToAll[arrLen] ) {
//             reqflag = false;
//             AllisSelected = true;

          }
      }

      if (AllisSelected)  {
          strError += "You have selected a Label which is already assigned to All Platforms \n";
      }

      if(reqflag) {

          if( (objValue != "0") && (objValue != "-1") ) {
              if( formObj.HardCodedPartno.value.length > 0 ) {

                  if( (labelPrefixMap[ objName ] != null) &&
                      (!validateField2(formObj.HardCodedPartno, objName,
                        labelPrefixMap[ objName ] ))) {
                      reqflag = false;
                  }
              }
          }

          if( reqflag )
              formObj.submit();
      }	else {
          alert(strError);
      }
}


function validateField(formObj)
{
var regexI;
var regexII;
regexI = /^\d{2}-\d{4}-\d{2}$/;
regexII = /^\d{2}-\d{5}-\d{2}$/;

if(regexI.test(formObj.value) || regexII.test(formObj.value) )
   return true;
else
   return false;

}

  // .........................................................................
  // On focus this checks to see if the user should be able to enter a new
  // label.
  // .........................................................................
  function LabelNewFocus()
  {
  var obj,objForm,objName,objValue;
  var idx;

  objForm = document.add_label
  obj = objForm.LabelName;
  objName = obj[obj.selectedIndex].text;
  objValue = obj[obj.selectedIndex].value;

  // New label NOT selected?
  if( objValue!="-1" )
    {
    objForm.newLabelName.blur();

    // User hasn't selected create new label.  Ask them if they still
    // want to create a new label.
    if( confirm(
        "You've clicked on the field to enter a NEW label but you have " +
        "another label name already selected to the left.  Click OK to " +
        "continue add a new label, click Cancel to keep your current setting."
        ) )
      {
      // Force selection of the add new label selector!  Figure out which
      // of the label options is the right one!
      for( idx=0; idx<obj.length; idx++ )
        {
        if( obj[idx].value=="-1" )
          {
          obj.selectedIndex = idx;
          }  // if
        }  // for

      // Focus on new label field.
      objForm.newLabelName.focus();
      }  // if( confirm(...) )
    else
      {
      obj.focus();

      }  // else
    }  // if( objValue>=0 )
  }  // LabelNewFocus()

  // .........................................................................
  // When the label selector changes, if the user selects the add new label
  // then change focus to the new label field!
  // .........................................................................
  function LabelChange()
  {
  var obj,objForm,objName,objValue;

  objForm = document.add_label
  obj = objForm.LabelName;
  objName = obj[obj.selectedIndex].text;
  objValue = obj[obj.selectedIndex].value;

  // New label selected?
  if( objValue=="-1" )
    {
    // We're creating a new label!  Focus please!
    objForm.newLabelName.focus();
    }  // if
  }  // LabelChange()

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

-->
</script>




<br />
<form action="AddLabelProcessor?releaseNumberId=<%=releaseNumberId%>&osTypeId=<%=WebUtils.getParameter(request,"osTypeId")%>" method="post" name="add_label" >
<INPUT TYPE="HIDDEN" NAME="callingForm" VALUE="viewLabelswithadd">

  <table>
  <center>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">
  <tr bgcolor="#d9d9d9">
    <td valign="top"><span class="dataTableTitle">Platform</span></td>
    <td valign="top"><span class="dataTableTitle">Select Label</span></td>
    <td valign="top"><span class="dataTableTitle">New Label</span></td>
    <td valign="top"><span class="dataTableTitle">Main</span></td>
    <td valign="top"><span class="dataTableTitle">Spare</span></td>
    <td valign="top"><span class="dataTableTitle">Hardcoded</span></td>
    <td valign="top"><span class="dataTableTitle">Hardcoded Partno </span></td>
  </tr>
  <tr bgcolor="#ffffff">
    <td valign="top"><span class="dataTableData">
      <select name="PlatformFamily" size="1">
      	 <%  	     		
 
 	   for(int pfIndex=0; pfIndex<pfInfoVector.size(); pfIndex++){
 	    pfInfo = (PlatformFamilyInfo) pfInfoVector.elementAt(pfIndex); %>
               <option value="<%= pfInfo.getPlatformFamilyId() %>">
 		   <%=pfInfo.getPlatformFamilyName() %>
      	       </option>
 
     
      	 <% } %>
      	      
	 </select></span>
    </td>
    <td valign="top"><span class="dataTableData">
      <select name="LabelName" size="1" onchange="LabelChange()">
         <option value="0">---Select---</option>
           <%
             try
             {
                for(int lIndex=0; lIndex<uniqueLabels.size(); lIndex++){
      	   %>
      	          <option value="<%= uniqueLabels.elementAt(lIndex) %>">
    	             <%= uniqueLabels.elementAt(lIndex) %>
    	          </option>    	
           <%   }
              } catch(Exception e) { 
                  e.printStackTrace();
              } 
           %>
         <option value="-1">---Add New---</option>
      </select></span>
     </td>
    <td valign="top"><span class="dataTableData">
        <input type="text" name="newLabelName" size="10"
        	onfocus="LabelNewFocus()" /></span>
    </td>

    <td valign="top" align="center"><span class="dataTableData">
      <input type="checkbox" name="Main"/></span>
    </td>

    <td valign="top" align="center"><span class="dataTableData">
      <input type="checkbox" name="Spare"/></span>
    </td>

    <td valign="top" align="center"><span class="dataTableData">
      <input type="checkbox" name="HardCoded"/></span>
    </td>

    <td valign="top" align="center"><span class="dataTableData">
      <input type="text" name="HardCodedPartno" size="10" /></span>
    </td>

  </tr>
      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>
</form>
  <!-- submit buttons -->
  <table border="0" cellspacing="0" cellpadding="0" width="100%">
    <tr>
      <td align="center" height="40">
         <a href="javascript:checkRequired(document.add_label)">
         <img src="../gfx/btn_add.gif" border="0" name="Add" /></a>
      </td>
     </tr>
  </table>

<%
    if(labelInfoVector != null) {
%>
<form action="processor" method="post" name="delete_label">
<INPUT TYPE="HIDDEN" NAME="callingForm" VALUE="viewLabelswithdelete">
<center>

  <table>
  <center>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">
  <tr bgcolor="#d9d9d9">
    <td valign="top"><span class="dataTableTitle">
    	<a href="LabelSetup.jsp?releaseNumberId=<%=releaseNumberId%>&sort=<%=labelBean.Platform %>">Platform</a>
    	</span>
    </td>
    <td valign="top"><span class="dataTableTitle">
    	<a href="LabelSetup.jsp?releaseNumberId=<%=releaseNumberId%>&sort=<%=labelBean.LabelName%>">Label</a>
    	</span>
    </td>
    <td valign="top"><span class="dataTableTitle">Main</span></td>
    <td valign="top"><span class="dataTableTitle">Spare</span></td>
    <td valign="top"><span class="dataTableTitle">Hardcoded</span></td>
    <td valign="top"><span class="dataTableTitle">Hardcoded Partno </span></td>
    <td valign="top"><span class="dataTableData">&nbsp;</span></td>
  </tr>

<%

    for(int lIndex=0; lIndex<labelInfoVector.size(); lIndex++) {
       labelInfo = (LabelInfo) labelInfoVector.elementAt(lIndex);
//       System.out.println( "labelInfo.getIsIncluded() --" + labelInfo.getIsIncluded() );
       if( labelInfo.getIsIncluded() ) {
%>

  <tr bgcolor="#ffffff">
    <td valign="top"><span class="dataTableData"><%= labelInfo.getPlatform() %>
    	</span></td>
    <td valign="top"><span class="dataTableData"><%= labelInfo.getLabelName() %>
    	</span></td>
    <td valign="top" align="center"><span class="dataTableData">
	<% if(labelInfo.getMain() ) { %>
    	  <img src="../gfx/ico_x.gif" />
    	<% } else { %>
          <img src="../gfx/ico_x_clear.gif" />
    	<% } %>
    	</span></td>
    <td valign="top" align="center"><span class="dataTableData">
	<% if(labelInfo.getSpare() ) { %>
    	  <img src="../gfx/ico_x.gif" />
    	<% } else { %>
          <img src="../gfx/ico_x_clear.gif" />
    	<% } %>
    	</span></td>
    <td valign="top" align="center"><span class="dataTableData">
	<% if(labelInfo.getHardCoded() ) { %>
    	  <img src="../gfx/ico_x.gif" />
    	<% } else { %>
          <img src="../gfx/ico_x_clear.gif" />
    	<% } %>
    	</span></td>
    <% if(labelInfo.getHardCodedPartno()==null || "null".equals(labelInfo.getHardCodedPartno())) labelInfo.setHardCodedPartno(""); %>   
    <td valign="top"><span class="dataTableData"><%= labelInfo.getHardCodedPartno() %></span></td>
    <td valign="top"><span class="dataTableData">
	<a href="DelPlatformLabelProcess?releaseNumberId=<%=releaseNumberId%>&osTypeId=<%=WebUtils.getParameter(request,"osTypeId")%>&submit=delete&labelid=<%=labelInfo.getLabelSeqId() %>" >
	<img src="../gfx/btn_delete.gif" alt="Delete the label"
	        border="0" /></a>
	<INPUT TYPE="HIDDEN" NAME="labelid" VALUE="<%= labelInfo.getLabelSeqId() %>" >
    	</span>
    </td>
  </tr>
<%     }
    }  %>
      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>
</center>
</form>

<%
    }
%>
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

