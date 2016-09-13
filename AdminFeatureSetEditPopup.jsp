<!--.........................................................................
: DESCRIPTION:
: Admin Page: Manage feature set information.
:
: AUTHORS:
: @author Amy (amyl@cisco.com)
:
: Copyright (c) 2003-2007, 2009-2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.lang.Exception" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Driver" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Enumeration" %>

<%@ page import="javax.ejb.ObjectNotFoundException"%>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.dataobject.CompressionInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.adminfeaturesetsession.AdminFeatureSetSessionLocal" %>
<%@ page import="com.cisco.eit.sprit.logic.adminfeaturesetsession.AdminFeatureSetSessionHomeLocal" %>
<%@ page import="com.cisco.eit.shrrda.featureset.FeatureSetLocal" %>
<%@ page import="com.cisco.eit.shrrda.featureset.FeatureSetLocalHome" %>
<%@ page import="com.cisco.eit.shrrda.featuresetname.FeatureSetName" %>
<%@ page import="com.cisco.eit.shrrda.featuresetname.FeatureSetNameHome" %>
<%@ page import="com.cisco.eit.shrrda.featuresetdesc.FeatureSetDesc" %>
<%@ page import="com.cisco.eit.shrrda.featuresetdesc.FeatureSetDescHome" %>
<%@ page import="com.cisco.eit.shrrda.featuresetdesignator.FeatureSetDesignator" %>
<%@ page import="com.cisco.eit.shrrda.featuresetdesignator.FeatureSetDesignatorHome" %>
<%@ page import="com.cisco.eit.shrrda.imageprefix.ImagePrefix" %>
<%@ page import="com.cisco.eit.shrrda.imageprefix.ImagePrefixHome" %>
<%@ page import="com.cisco.eit.sprit.dataobject.FeatureSetInfo" %>
<%@ page import="com.cisco.eit.sprit.util.PrepareMail" %>
<%@ page import="com.cisco.eit.sprit.model.adminfeaturesetjdbc.AdminFeatureSetJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.utils.email.Mailer" %> 
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<% // .......................................................................
  Properties props;
  SpritGlobalInfo globals;
  SpritAccessManager spritAccessManager;
  String pathGfx;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go("accessManager");
  pathGfx = globals.gs( "pathGfx" );
  props = (Properties) globals.go( "properties" );
// ....................................................................... %>

<%= SpritGUI.pageHeader( globals,"Add Descriptions and Designators","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Add Descriptions and Designators" ) %>

<%
  // Get the IDs for the Image Name Prefix and the Feature Set Name.
  AdminFeatureSetSessionLocal afssLocalObj;
  AdminFeatureSetSessionHomeLocal afssHomeLocalObj;
  boolean hasRowWithBlankDescDesig = false;
  int rowsDisplayed = 0;
  Integer featureSetNameId;
  Integer imagePrefixNameId;
  Integer featureSetIdBlankDescDesig = null;
  Iterator iter;
  SpritSecondaryNavBar navBar;
  String featureSetName;
  String featureSetNameIdParam;
  String filterFeatureSet;
  String filterFeatureSetDesc;
  String filterImagePrefix;
  String htmlButtonSubmit1;
  String htmlCellStyle;
  String imagePrefixName;
  String imagePrefixNameIdParam;
  String sortCol;
  String sortDirCurrent;
  String sortDirReverse;
  String urlBase;
  String urlSortFeatureSetDesc;
  String urlSortFeatureSetDesignator;
  String urlSortFeatureSetName;
  String urlSortImagePrefix;
  StringBuffer htmlFeatureSetGrid = new StringBuffer();
  TableMaker htmlFeatureSetTable = new TableMaker();
  Vector reallyLongVectorName;


  // Get params.
  imagePrefixNameIdParam = WebUtils.getParameter(request,"imagePrefixNameId");
  featureSetNameIdParam = WebUtils.getParameter(request,"featureSetNameId");
  
  // Check availability.  This should NOT happen.
  if( imagePrefixNameIdParam.equals("") ) {
    out.println( SpritGUI.renderErrorBox( globals,
        "Missing Input Parameter",""
        + "The Image Name parameter was not transmitted to this page.  Please "
        + "report this problem to the SPRIT maintainers." ) );
  }  // if( imagePrefixNameIdParam.equals("") )
  if( featureSetNameIdParam.equals("") ) {
    out.println( SpritGUI.renderErrorBox( globals,
        "Missing Input Parameter",""
        + "The Feature Set Name parameter was not transmitted to this page.  Please "
        + "report this problem to the SPRIT maintainers." ) );
  }  // if( featureSetNameIdParam.equals("") )
  
  // Convert parameters
  imagePrefixNameId = new Integer(imagePrefixNameIdParam);
  featureSetNameId = new Integer(featureSetNameIdParam);
  
  // Get the Image Prefix and Feature Set info.
  imagePrefixName = AdminFeatureSetJdbc.getImagePrefixByImagePrefixId(imagePrefixNameId);
  featureSetName = AdminFeatureSetJdbc.getFeatureSetNameByFeatureSetNameId(featureSetNameId);
  
  // Get all the descriptions and designators for this feature set and image
  // prefix.
  reallyLongVectorName = AdminFeatureSetJdbc.getRecordsByImagePrefixIdAndFeatureSetNameId(
      imagePrefixNameId,
      featureSetNameId
      );

  // HTML macros
  htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
          globals,
          "btnSaveUpdates1",
          "Save updates",
          "javascript:submitForm()",
          pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
          "actionBtnSaveUpdates('btnSaveUpdates1')",
          "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
          );

  // Add headers.
  htmlCellStyle = "class=\"dataTableTitle\" align=\"center\" bgcolor=\"#d9d9d9\"";
  htmlFeatureSetTable.newRow();
  htmlFeatureSetTable.addTD(htmlCellStyle,"&nbsp;");
  htmlFeatureSetTable.addTD(htmlCellStyle,"Image Prefix");
  htmlFeatureSetTable.addTD(htmlCellStyle,"Feature Set");
  htmlFeatureSetTable.addTD(htmlCellStyle,"Feature Set Description");
  htmlFeatureSetTable.addTD(htmlCellStyle,"Designator");
  htmlFeatureSetTable.addTD(htmlCellStyle,"CCO");
  
  // Add meat.
  htmlCellStyle = "class=\"dataTableData\" align=\"left\"";
  if( reallyLongVectorName==null ) {
    htmlFeatureSetTable.newRow("bgcolor=\"#ffffff\"");
    htmlFeatureSetTable.addTD( htmlCellStyle+" colspan=\"5\"",""
        + "<center><span class=\"noData\">No records found!<br />"
        + "(This is possibly a database error...)</span></center>"
        );
  } else {  // if( featureSetsVector==null )
    htmlFeatureSetTable.newRow("bgcolor=\"#F5D6A4\"");
    htmlFeatureSetTable.addTD("valign=\"middle\"","<nobr>Add "
        + "<img src=\""+pathGfx+"/ico_arrow_right_orange.gif\" /></nobr>"
        );
    htmlFeatureSetTable.addTD(htmlCellStyle,imagePrefixName);
    htmlFeatureSetTable.addTD(htmlCellStyle,featureSetName);
    htmlFeatureSetTable.addTD(htmlCellStyle,""
        + "<input type=\"input\" name=\"featureSetDescNew\" size=\"25\" maxlength=\"60\" />" 
        );
    htmlFeatureSetTable.addTD(htmlCellStyle,""
        + "<input type=\"input\" name=\"featureSetDesignatorNew\" size=\"5\" maxlength=\"60\" />" 
        );
    htmlFeatureSetTable.addTD(htmlCellStyle,""
    +"<input type=\"checkbox\" checked value=\"Y\" name=\"isGoingToCCONew\"/>"
        );
    iter = reallyLongVectorName.iterator();
  
    while( iter.hasNext() ) {
      FeatureSetInfo fsi;
      fsi = (FeatureSetInfo) iter.next();
      
      // Skip if the description and designator are blank; note this row's
      // ID as well!  (There should only be ONE of these in the database.)
      if( StringUtils.nvlOrBlank(fsi.featureSetDesc,"").trim().equals("") 
          && StringUtils.nvlOrBlank(fsi.featureSetDesignator,"").trim().equals("") ) {
        hasRowWithBlankDescDesig = true;
        featureSetIdBlankDescDesig = fsi.featureSetId;
        continue;
      }  // if( ... )
      
      htmlFeatureSetTable.newRow("bgcolor=\"#ffffff\"");
      htmlFeatureSetTable.addTD(htmlCellStyle,"&nbsp;");
      htmlFeatureSetTable.addTD(htmlCellStyle,fsi.imagePrefixName );
      htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetName );
      htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetDesc );
      if( StringUtils.nvlOrBlank(fsi.featureSetDesignator,"").trim().equals("") ) {
        htmlFeatureSetTable.addTD(htmlCellStyle,""
            + "<input type=\"text\" size=\"5\" "
            + "name=\"featureSetDesignator_" + fsi.featureSetId 
            + "\" maxlength=\"60\""
            );
      } else {  // if( StringUtils.nvlOrBlank(fsi.featureSetDesignator,"").trim().equals("") )
        htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetDesignator );
      }  // else if( StringUtils.nvlOrBlank(fsi.featureSetDesignator,"").trim().equals("") )
      htmlFeatureSetTable.addTD(htmlCellStyle,fsi.goingToCCO );
      rowsDisplayed++;
    }  // while( iter.hasNext() )
  }  // else if( featureSetsVector==null )
  
  // Now check to to see if we can make updates to the display.
  // The _submitformflag variable should have been set.
  if( WebUtils.getParameter(request,"_submitformflag").equals("1") ) {
    Enumeration requestParamEnum;
    FeatureSetLocal fsObj2;
    FeatureSetLocal fsObj;
    FeatureSetDesc fsdescObj = null;
    FeatureSetDescHome fsdescHomeObj;
    FeatureSetDesignator fsdesignatorObj;
    FeatureSetDesignatorHome fsdesignatorHomeObj;
    FeatureSetLocalHome fsHomeObj;
    Integer featureSetDesignatorId;
    Integer featureSetId;
    String featureSetDesc;
    String featureSetDescNew;
    String featureSetDesignatorEdit;
    String featureSetDescEdit;
    String featureSetDesignatorNew;
    String isGoingToCCONew;
    String featureSetIdString;
    String paramName;
    String warnings = new String("");
    StringBuffer emailMessage = new StringBuffer();
    Context ctx = new InitialContext();
    
    afssLocalObj = null;
    try {
        
        afssHomeLocalObj = (AdminFeatureSetSessionHomeLocal)
        ctx.lookup("ejblocal:AdminFeatureSetSession.AdminFeatureSetSessionHome");
        afssLocalObj = afssHomeLocalObj.create();
    } catch(Exception e) {
        System.out.println(e);
    }  // try-catch
  
    // Acquire the home object for the feature sets.
    fsHomeObj = null;
    try {
      fsHomeObj = (FeatureSetLocalHome) ctx.lookup("ejblocal:ShrFeatureSetBean.FeatureSetHome");										 
      fsdescHomeObj = (FeatureSetDescHome) ctx.lookup("ShrFeatureSetDescBean.FeatureSetDescHome");
      fsdesignatorHomeObj = (FeatureSetDesignatorHome) ctx.lookup("ShrFeatureSetDesignatorBean.FeatureSetDesignatorHome");
    } catch(Exception e) {
      throw e;
    }  // try-catch
    
    // OK.  See if we have any descriptions and designators to add.
    featureSetDescNew = WebUtils.getParameter(request,"featureSetDescNew").trim();
    featureSetDesignatorNew = WebUtils.getParameter(request,"featureSetDesignatorNew").trim();
    isGoingToCCONew =WebUtils.getParameter(request,"isGoingToCCONew").trim();
    
    if( WebUtils.getParameter(request,"isGoingToCCONew").trim().equals("Y") ) {
     isGoingToCCONew="Y";
    }else {
     isGoingToCCONew="N";
    }
    System.out.println("AdminFeatrueSetEditPopup.jsp:1 Value of isGoingToCCONew is "+isGoingToCCONew);
    
    if( featureSetDescNew.length()>0 ) {
      // Determine if we need to create() a new featureSet record
      // or update an existing one!

      // Try to get the corresponding description and designator objects.
        // try-catch-catch
  
      featureSetId = new Integer(0);
      System.out.println("AdminFeatrueSetEditPopup.jsp:2 Value of isGoingToCCONew is "+isGoingToCCONew);
       afssLocalObj.restoreFeatureSetDescAndDesig( featureSetId, imagePrefixNameId, featureSetNameId, featureSetDescNew, featureSetDesignatorNew, isGoingToCCONew,spritAccessManager.getUserId());
    
  
  
      emailMessage.append( ""
              + "  - Added new Description/Designator pair:\n"
              + "      Description:  " + StringUtils.nvlOrBlank(featureSetDescNew,"---") + "\n"
              + "      Designator:   " + StringUtils.nvlOrBlank(featureSetDesignatorNew,"---") + "\n\n"
              );
       
    
           
    }  // if( featureSetDescNew.length()>0 )
    
    // Now go through the rest of the request parameters and see
    // if there are any updates to designators.
    requestParamEnum = request.getParameterNames();
    while( requestParamEnum.hasMoreElements() ) {
      paramName = (String) requestParamEnum.nextElement();
      if( paramName.indexOf("featureSetDesignator_")==0 ) {
        // Got anything to update?
        featureSetDesignatorEdit = WebUtils.getParameter(request,
            paramName ).trim();
        // There are 21 characters in "featureSetDesignator_".
        // Specifying 21 lets us skip that.
        featureSetIdString = paramName.substring(21);
        featureSetId = new Integer( featureSetIdString );
        fsObj = fsHomeObj.findByPrimaryKey(featureSetId);
        
        try {
        	fsdescObj = (FeatureSetDesc) fsdescHomeObj.findByPrimaryKey(fsObj.getFeatureSetDescId());
	} catch(Exception e) {
		System.out.println(e);
	}


        if( featureSetDesignatorEdit.length()>0 ) {
          System.out.println("AdminFeatrueSetEditPopup.jsp:2 Value of isGoingToCCONew is "+isGoingToCCONew);
 	      afssLocalObj.restoreFeatureSetDescAndDesig( featureSetId, fsObj.getImagePrefixId(), fsObj.getFeatureSetNameId(), fsdescObj.getFeatureSetDesc(), featureSetDesignatorEdit,isGoingToCCONew, spritAccessManager.getUserId());
 	      

 
 	
        }  // if( featureSetDesignatorEdit.length()>0 )
      }  // if( paramName.indexOf("featureSetDesignator_")==0 ) 
      else if(paramName.indexOf("compression_id_") == 0) {
        	String strCompressionId = WebUtils.getParameter(request,paramName ).trim();
        	Integer nCompressionId = new Integer( strCompressionId );
        	String strOldSoftwareType = WebUtils.getParameter(request,"orig_software_type_" + nCompressionId ).trim();
        	String strNewSoftwareType = WebUtils.getParameter(request,"softwareType_" + nCompressionId ).trim();
        	
        	if( !strOldSoftwareType.equals(strNewSoftwareType)) {
        		// update it
        		MonitorUtil.cesMonitorCall("SPRIT-6.4-CSCsf98528-Assigning Software Type to Images", request);
        		AdminFeatureSetJdbc.updateSoftwareType(imagePrefixNameId, featureSetNameId, 
        			nCompressionId, new Integer(strNewSoftwareType));
        	}
      }     
    }  // while( requestParamEnum.hasMoreElements() )
    
    // Now refresh the parent window and close this one.    
    %>    
    <script language="JavaScript"><!--
      <%
      if( emailMessage.length()>0 ) {
        String envMode;
      
        // Will send out e-mail!
        String recipients[] = new String[1];
        envMode = StringUtils.nvlOrBlank(globals.gs("envMode"),"");
        System.out.println("envMode : "+envMode+" User ID : "+spritAccessManager.getUserId());

        if( envMode.equals("dev") ) {
          recipients[0] = props.getProperty("emailFeatureSetChangeDev");
        } else if( envMode.equals("test") ) {
          recipients[0] = props.getProperty("emailFeatureSetChangeTest");
        } else {
          recipients[0] = props.getProperty("emailFeatureSetChangeProd");
        }  // else if( envMode.equals("dev") )
        
        emailMessage.insert( 0,""
            + "The Image Prefix and Feature Set Name pair:\n"
            + "\n"
            + "  Image Prefix:     " + imagePrefixName + "\n"
            + "  Feature Set Name: " + featureSetName + "\n"
            + "  Environment: " + PrepareMail.getEnvironment(envMode) + "\n"
            + "\n"
            + "has been updated by "+spritAccessManager.getUserId()+" via SPRIT admin interface with the following "
            + "change(s):\n"
            + "\n"
            );
        Mailer.sendMail(
            spritAccessManager.getUserId(),
            recipients,
            "[SPRIT] Feature Set Administration: updated Desc/Desig "
            + "(for Prefix/Set: " + imagePrefixName + "/" + featureSetName + ")",
            emailMessage
            );
      }  // if( emailMessage.length()>0 )


      if( !warnings.equals("") ) {
        // We have some warnings and errors.  Let's echo them out to the user.
        warnings = StringUtils.replaceSubstr(warnings,"\"","\\\"",-1,1);
        %>
        alert( "WARNINGS AND ERRORS:\n<%=warnings%>" );
        <%
      }  // if( !warnings.equals("") )
      %>
      window.opener.document.forms['refreshForm'].submit();
      self.close();
    //--></script>
    <%    
  }  // if( WebUtils.getParameter(request,"_submitformflag").equals("1") )
  
  // Produce output.  
  htmlFeatureSetGrid.append( htmlFeatureSetTable.renderTable() );
%>

<script language="javascript"><!--
  //........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function actionBtnSaveUpdates(elemName) {
    if( document.forms['addDescDesigForm'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['addDescDesigForm'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
  }

  //........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function submitForm() {
    // Check for elements to see if they are OK.  We want to force 
    // Feature Set Descriptins to be uppercase, max length 60 chars,
    // Feature Set Designators also uppercase, max length 60.
    
    var featureSetDescCheck;
    var featureSetDesignatorCheck;
    var formObj;
    var madeChanges;
    
    formObj = document.forms['addDescDesigForm'];
    madeChanges = false;
    
    featureSetDescCheck = formObj.elements['featureSetDescNew'].value;
    featureSetDesignatorCheck = formObj.elements['featureSetDesignatorNew'].value;
       
    // Make sure they have at least the description.
    if( featureSetDescCheck.length<1 &&
        featureSetDesignatorCheck.length>0 ) {
      alert( "ERROR: You cannot submit a blank Feature Set Description "
          + "with a non-blank Designator. "
          + "(You may have a Description with blank Designator, however.)"
          + "Please add one and resubmit." );
      return;
    }  //if( featureSetDescCheck.length<1 )
    
    // Length check!
    if( featureSetDescCheck.length>60 ) {
      alert( "ERROR: The Feature Set Description you've chosen "
          + "exceeds the 60 "
          + "character limit.  Please trim it down and resubmit." );
      return;
    }  // if( featureSetDescCheck.length>60 )
    if( featureSetDesignatorCheck.length>60 ) {
      alert( "ERROR: The Feature Set Designator you've chosen "
          + "exceeds the 60 "
          + "character limit.  Please trim it down and resubmit." );
      return;
    }  // if( featureSetDesignatorCheck.length>60 )

    // Spaces check!
    if( featureSetDesignatorCheck.indexOf(" ")>=0 ) {
      alert( "ERROR: The Feature Set Designator has space characters in it. "
          + "Please remove them and resubmit." );
      return;
    }  // if( featureSetDesignatorCheck.indexOf(" ")>=0 )
    
    // Was there anything to add anyways?
    if( featureSetDescCheck.length>0 ) {
      madeChanges = true;
    }  // if( featureSetDescCheck.length>0 )
    
    // Case check!
    featureSetDescCheck = featureSetDescCheck.replace( /[^a-z]/g,"" );
    featureSetDesignatorCheck = featureSetDesignatorCheck.replace( /[^a-z]/g,"" );
        
    if( featureSetDescCheck.length>0 ) {
      alert( "ERROR: You cannot have lowercase letters in your "
          + "Feature Set Description.  Please correct this and "
          + "resubmit." );
      return;
    }  // if( featureSetDescCheck.length>0 )
    if( featureSetDesignatorCheck.length>0 ) {
      alert( "ERROR: You cannot have lowercase letters in your "
          + "Feature Set Designator.  Please correct this and "
          + "resubmit." );
      return;
    }  // if( featureSetDesignatorCheck.length>0 )
    
    // Rifle through any non-new designators and see if we need to
    // run a case check on them too.
    var i;
    var elemName;
    var elemValue;
    var elemValueFixed;
    
    for( i=0; i<formObj.elements.length; i++ ) {
      elemName = formObj.elements[i].name;
      if( elemName.match(/^featureSetDesignator_/) ) {
        elemValue = formObj.elements[i].value;

        if( elemValue.indexOf(" ")>=0 ) {
          alert( "ERROR: One of your Designators, \"" + elemValue 
              + "\" has spaces in it!  Please remove them and resubmit." );
          return;
        }  // if( elemValue.indexOf(" ")>=0 )

        elemValueFixed = elemValue.replace(/[^a-z]/g,"");
        if( elemValueFixed.length>0 ) {
          alert( "ERROR: One of your Designators, \"" + elemValue 
              + "\" has lowercase characters!  Please use only "
              + "uppercase characters and resubmit." 
              );
          return;
        }  // if( elemValueFixed.length>0 )
        
        // Otherwise it's OK!
        madeChanges = true;
      }  // if( elemName.match(/^featureSetDesignator_/) )
      
      if( elemName.match(/^compression_id_/) ) {
          elemValue = formObj.elements[i].value;
          var oldSWT = formObj.elements[ 'orig_software_type_' + elemValue].value;
          var newSWT = formObj.elements[ 'softwareType_' + elemValue].value;
          if( oldSWT != newSWT)
          	madeChanges = true;
      }      
    }  // for( i=0; i<formObj.elements.length; i++ )
    
    // Did we do anything to this form at all?
    if( madeChanges!=true ) {
      alert( "I didn't detect that you made any changes on this "
          + "page!  You can close this window if you are done." );
      return;
    }  // if( madeChanges!=true )
    if( formObj.elements['_submitformflag'].value==0 ) {
         formObj.elements['_submitformflag'].value=1;
         setImg('btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
         formObj.submit();
    }  // if( elements['_submitformflag'].value==0 )
    
    //formObj.elements['_submitformflag'].value = "1";
    //formObj.submit();
  }  // function submitForm()
//--></script>

<%
  if(rowsDisplayed>0) {
    %>
    You can add an additional Feature Set Description and Designator
    to be associated with this Image Prefix and Feature Set pair.  
    (Designators are optional.)
    <%
  } else {  // if(rowsDisplayed>0)
    %>
    You do not have any Feature Set Descriptions and Designators
    associated with this Image Prefix and Feature Set pair.  Please
    add the new Description and Designator below---Designators are
    optional.
    <%
  } // else if(rowsDisplayed>0)
%>
<b>Remember:</b> <i>you cannot edit your associations after you
submit</i>.*  Any corrections to this will require SPRIT 
administrator intervention!<br /><br />
    
<span class="note">*Note: You may, however, edit the Designators 
<u>only</u> if they are <u>blank</u>.</span>
<br /><br />

<form action="AdminFeatureSetEditPopup.jsp" method="get" name="addDescDesigForm">
<input type="hidden" name="_submitformflag" value="0" />
<input type="hidden" name="imagePrefixNameId" value="<%=imagePrefixNameId%>" />
<input type="hidden" name="featureSetNameId" value="<%=featureSetNameId%>" />
<center>
  <%= htmlFeatureSetGrid.toString() %><br />
  
  <table border="1" cellpadding="2" cellspacing="0">
    <tr>
        <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Compression Type</td>
        <td class="dataTableTitle" align="center" bgcolor="#d9d9d9">Software Type</td>
    </tr>
<%
	Iterator iterCompressionInfo = AdminFeatureSetJdbc.getCompressionAndSoftwareType(imagePrefixNameId, featureSetNameId ).iterator();
	while(iterCompressionInfo.hasNext()) {
		CompressionInfo info = (CompressionInfo) iterCompressionInfo.next();
		Iterator iterSoftTypes = info.getListOfSoftwareTypes().iterator();
		String strSelectedItem = info.getSoftwareTypeName();
		Integer nSelectedItemId = info.getSoftwareTypeId();
%>    
    <tr bgcolor="#ffffff">
        <td class="dataTableData" align="left">
            <input type="hidden" name="compression_id_<%=info.getImageCompressionId()%>" value="<%=info.getImageCompressionId()%>">
            <%=info.getImageCompressionName()%>
        </td>
        <td class="dataTableData" align="left">
            <input type="hidden" name="orig_software_type_<%=info.getImageCompressionId()%>" value="<%=nSelectedItemId%>">
            <select name="softwareType_<%=info.getImageCompressionId()%>">
<%
			while(iterSoftTypes.hasNext()) {
			    Integer nSoftwareTypeId = (Integer) iterSoftTypes.next();
			    String  strSoftwareType = (String) iterSoftTypes.next();
%>
                <option value="<%=nSoftwareTypeId%>" <%=(strSelectedItem.equals(strSoftwareType) ? "selected=\"yes\"" : "")%>>
                    <%=strSoftwareType%>
                </option>                
<%
			}
%>
            </select>
<%			
		}
%>            
        </td>
</tr>
</table>
</br> 
  <%= htmlButtonSubmit1 %>
</center>
</form>

<%= Footer.pageFooter(globals) %>
<!-- end -->
