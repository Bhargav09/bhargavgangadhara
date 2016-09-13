<!--.........................................................................
: DESCRIPTION:
: Admin Page: Manage feature set information.
:
: AUTHORS:
: @author Amy (amyl@cisco.com)
:
: Copyright (c) 2003-2005, 2009-2010 by Cisco Systems, Inc.
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
<%@ page import="javax.ejb.ObjectNotFoundException"%>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.shrrda.featureset.FeatureSetLocal" %>
<%@ page import="com.cisco.eit.shrrda.featureset.FeatureSetLocalHome" %>
<%@ page import="com.cisco.eit.shrrda.featuresetname.FeatureSetName" %>
<%@ page import="com.cisco.eit.shrrda.featuresetname.FeatureSetNameHome" %>
<%@ page import="com.cisco.eit.shrrda.imageprefix.ImagePrefix" %>
<%@ page import="com.cisco.eit.shrrda.imageprefix.ImagePrefixHome" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<% // .......................................................................
  SpritGlobalInfo globals;
  SpritAccessManager spritAccessManager;
  String pathGfx;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go("accessManager");
  pathGfx = globals.gs( "pathGfx" );
// ....................................................................... %>

<%= SpritGUI.pageHeader( globals,"Add an Image Prefix / Feature Set Pair","" ) %>
<%= SpritGUI.pageBanner( globals,"popup","Add an Image Prefix / Feature Set Pair" ) %>

Please enter the Image Prefix and Feature Set pair to be added to
the list.
<span class="note">NOTE: Both fields are lowercase only. The maximum chars for image prefix is 20 and feature set name is 75.</span>
<br /><br />

<%
  // Gather the image prefix and feature set from web params.
  String imagePrefixName;
  String featureSetName;
  
  imagePrefixName = StringUtils.elimSpaces(
      WebUtils.getParameter(request,"imagePrefixName")
      );
  featureSetName = StringUtils.elimSpaces(
      WebUtils.getParameter(request,"featureSetName")
      );

  // Create input table.  Repopulate the form with old values if we can.
  TableMaker table;
  String htmlCellStyle;

  table = new TableMaker();

  htmlCellStyle = "class=\"dataTableTitle\" align=\"center\" bgcolor=\"#d9d9d9\"";
  table.newRow();
  table.addTD(htmlCellStyle,"Image Prefix Name");
  table.addTD(htmlCellStyle,"Feature Set Name");

  htmlCellStyle = "class=\"dataTableData\" align=\"center\" bgcolor=\"#ffffff\"";

  table.newRow();
  table.addTD(htmlCellStyle,"<input type=\"text\" size=\"12\" "
      + "name=\"imagePrefixName\" value=\"" 
      + WebUtils.escHtml(imagePrefixName) + "\" maxlength=\"20\" />" );
  table.addTD(htmlCellStyle,"<input type=\"text\" size=\"85\" "
      + "name=\"featureSetName\" value=\"" 
      + WebUtils.escHtml(featureSetName) + "\" maxlength=\"75\" />" );

  // Decide if we are to be adding the new Image Name Prefix and Feature Set
  // combo!  We'll look at the web params.
  if( WebUtils.getParameter(request,"_submitformflag").equals("1") ) {
    // Yup.  Submitted!  Try to add.  Actually, first try to get the home
    // objects for both the Image Prefix and Feature Set beans.

    Collection fsColl;
    FeatureSetLocal fsObj = null;
    FeatureSetLocalHome fsHomeObj = null;
    FeatureSetName fsnObj = null;
    FeatureSetNameHome fsnHomeObj = null;
    ImagePrefix ipObj;
    ImagePrefixHome ipHomeObj;

    try {
      Context ctx = new InitialContext();

      // Get home objs.
      fsHomeObj = (FeatureSetLocalHome) ctx.lookup("ejblocal:ShrFeatureSetBean.FeatureSetHome");
      fsnHomeObj = (FeatureSetNameHome) ctx.lookup("ShrFeatureSetNameBean.FeatureSetNameHome");
      ipHomeObj = (ImagePrefixHome) ctx.lookup("ShrImagePrefixBean.ImagePrefixHome");
      
      // Image Prefix.  Get it or create it.
	try {

 		
	 	ipObj = (ImagePrefix) ipHomeObj.findByImagePrefixNameIgnoreAdmFlag(imagePrefixName);
 			
	 	if (ipObj.getAdmFlag().equals("D")) {
			ipObj.setAdmTimestamp(new Timestamp( (new java.util.Date()).getTime() ));
			ipObj.setAdmUserId(spritAccessManager.getUserId());
			ipObj.setAdmFlag("V");
	        	ipObj.setAdmComment("Resurrected By Sprit Admin Feature Set"); 				
	 	}

 	
	} catch (ObjectNotFoundException  onfExc) {
		// Not avail.  Create a new one?        
		ipObj = ipHomeObj.create( imagePrefixName, 
		        new Timestamp( (new java.util.Date()).getTime() ),
		        spritAccessManager.getUserId(),
		         "V",
		        "SPRIT Updates");
	} catch( Exception e ) {
	        throw e;
	}  // try-catch-catch

      // Feature Set Name.  Get it or create it.
      try {
	fsnObj = (FeatureSetName) fsnHomeObj.findByFeatureSetNameIgnoreAdmFlag(featureSetName);
      			
	if (fsnObj.getAdmFlag().equals("D")) {
		fsnObj.setAdmTimestamp(new Timestamp( (new java.util.Date()).getTime() ));
		fsnObj.setAdmUserId(spritAccessManager.getUserId());
		fsnObj.setAdmFlag("V");
		fsnObj.setAdmComment("Resurrected By Sprit Admin Feature Set");
	}

	} catch (ObjectNotFoundException onfExc) {
        // Not avail.  Create a new one?
        	fsnObj = fsnHomeObj.create( featureSetName, 
           	 new Timestamp( (new java.util.Date()).getTime() ),
            	spritAccessManager.getUserId(),
           	 "V",
           	 "SPRIT Updates");
        
      } catch( Exception e ) {
        throw e;
      }  // try-catch-catch
      
      // Feature Set.  Get it or create it.
      try {
           Collection fsCol = fsHomeObj.findByImagePrefixIdAndFeatureSetNameIdIgnoreAdmFlag(
            ipObj.getImagePrefixId(),
            fsnObj.getFeatureSetNameId()
            );
            
           Iterator fsItr = fsCol.iterator();
           boolean recordcreated = false;
           
           while(fsItr.hasNext()) {

            	fsObj = (FeatureSetLocal) fsItr.next();
            
            	if ((fsObj.getFeatureSetDescId() == null) && (fsObj.getFeatureSetDesignatorId() == null) && fsObj.getAdmFlag().equals("D") ) {
            		fsObj.setAdmTimestamp(new Timestamp( (new java.util.Date()).getTime() ));
			fsObj.setAdmUserId(spritAccessManager.getUserId());
			fsObj.setAdmFlag("V");
            		fsObj.setAdmComment("Resurrected by Sprit Admin Feature Set");
            		recordcreated = true;
            		%>
			   <script language="JavaScript"><!--
				window.opener.document.forms['refreshForm'].submit();
				self.close();
			   //--></script>
            		<%
            
            	} else if((fsObj.getFeatureSetDescId() == null) && (fsObj.getFeatureSetDesignatorId() == null) && fsObj.getAdmFlag().equals("V") ) {
        		// Hm.  Already here.  Tell the user they need to reenter!
            		%>
        		<center><span class="errorInline">
        		  <b>ERROR:</b> The <%=ipObj.getImagePrefix()%>-<%=fsnObj.getFeatureSetName()%>
        		  combination already exists!  Please enter different names
       	   		  below or <a href="javascript:self.close()">close</a> this
        		  window.
        		</span></center><br />
        
        		<script language="JavaScript"><!--
	        	  window.opener.document.forms['refreshForm'].submit();
	         
        		//--></script>
            		<%
        
            	}// else (if (fsObj.getFeatureSetDescId() == null && ...)
           } // while(fsItr.hasNext())
           
           fsItr = fsCol.iterator();
           
           while(fsItr.hasNext() && recordcreated == false) {
           	fsObj = (FeatureSetLocal) fsItr.next();
            	if (fsObj.getAdmFlag().equals("D")) {
            		fsObj.setAdmTimestamp(new Timestamp( (new java.util.Date()).getTime() ));
	    		fsObj.setAdmUserId(spritAccessManager.getUserId());
	    		fsObj.setAdmFlag("V");
            		fsObj.setAdmComment("Resurrected by Sprit Admin Feature Set");
            		fsObj.setFeatureSetDescId(null);
            		fsObj.setFeatureSetDesignatorId(null);
            		recordcreated = true;
            		%>
            		<script language="JavaScript"><!--
	        	  window.opener.document.forms['refreshForm'].submit();
	       	 	  self.close();
	         	 //--></script>
            		<%
            		
            	} 
         } // while(fsItr.hasNext())
     
     	if (recordcreated == false) {
        // Not avail.  Create a new one!
        	
        	fsObj = fsHomeObj.create(
           	 ipObj.getImagePrefixId(),            
            	fsnObj.getFeatureSetNameId(),
         	null,
            	null,
            
            new Timestamp( (new java.util.Date()).getTime() ),
            spritAccessManager.getUserId(),
            "V",
            "SPRIT Updates",
            null
            );  
            
        	// Now refresh the parent window and close this one.
        	%>
        	<script language="JavaScript"><!--
        	  window.opener.document.forms['refreshForm'].submit();
        	  self.close();
        	//--></script>
        	<%
        }
      } catch( Exception e ) {
        throw e;
      }  // try-catch-catch
    } catch(Exception e) {
      System.out.println("AdminFeatureSetPrefixSet.jsp: Adding error: " + e.getMessage() );
    }  // try-catch
  } else {  // if( WebUtils.getParameter(request,"_submitformflag").equals("1") )
    // Nope.  Just got here the first time or has an error.
  }  // if( WebUtils.getParameter(request,"_submitformflag").equals("1") )  

  // Create HTML submit buttons
  String htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
          globals,
          "btnSaveUpdates1",
          "Save Updates",
          "javascript:submitForm()",
          pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
          "actionBtnSaveUpdates('btnSaveUpdates1')",
          "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
          );
%>

<script language="JavaScript"><!--
  //..........................................................................
  // DESCRIPTION:
  // Handles the rollover stuff for the image buttons.  Images won't
  // change if the form has been submitted.
  //
  // IN:
  // elemName: the name of the element to toggle
  //..........................................................................
  function actionBtnSaveUpdates(elemName) {
    if( document.forms['addPrefixSet'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
    }  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['addPrefixSet'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
    }  // if
  }

  //..........................................................................
  // DESCRIPTION:
  // Checks and submits the form.
  //..........................................................................
  function submitForm() {
    // Check for elements to see if they are OK.  We want to force Image
    // Prefixes to be lowercase, max length 20 chars, Feature Sets also
    // lowercase, max length 20.
    
    var imagePrefixNameCheck;
    var featureSetNameCheck;
    var formObj;
    
    formObj = document.forms['addPrefixSet'];
    
    imagePrefixNameCheck = formObj.elements['imagePrefixName'].value;
    featureSetNameCheck = formObj.elements['featureSetName'].value;
    
    // Make sure they have both an imagePrefixName and featureSetName.
    if( imagePrefixNameCheck.length<1 ) {
      alert( "ERROR: You cannot submit a blank Image Prefix Name. "
          + "Please add one and resubmit." );
      return;
    }  //if( imagePrefixNameCheck.length<1 )
    if( featureSetNameCheck.length<1 ) {
      alert( "ERROR: You cannot submit a blank Feature Set Name. "
          + "Please add one and resubmit." );
      return;
    }  //if( featureSetNameCheck.length<1 )
    
    // Length check!
    if( imagePrefixNameCheck.length>20 ) {
      alert( "ERROR: The Image Prefix Name you've chosen exceeds the 20 "
          + "character limit.  Please trim it down and resubmit." );
      return;
    }  // if( imagePrefixNameCheck.length>20 )
    if( featureSetNameCheck.length>75 ) {
      alert( "ERROR: The Feature Set Name you've chosen exceeds the 75 "
          + "character limit.  Please trim it down and resubmit." );
      return;
    }  // if( featureSetNameCheck.length>75 )
    
    // Spaces check!
    if( imagePrefixNameCheck.indexOf(" ")>=0 ) {
      alert( "ERROR: The Image Prefix Name has space characters in it. "
          + "Please remove them and resubmit." );
      return;
    }  // if( imagePrefixNameCheck.indexOf(" ")>=0 )
    if( featureSetNameCheck.indexOf(" ")>=0 ) {
      alert( "ERROR: The Feature Set Name has space characters in it. "
          + "Please remove them and resubmit." );
      return;
    }  // if( featureSetNameCheck.indexOf(" ")>=0 )
        
    // Case check!
    imagePrefixNameCheck = imagePrefixNameCheck.replace(
        /[^A-Z]/g,""
        );
    featureSetNameCheck = featureSetNameCheck.replace(
        /[^A-Z]/g,""
        );
        
    if( imagePrefixNameCheck.length>0 ) {
      alert( "ERROR: You cannot have uppercase letters in your Image Prefix "
          + "Name.  Please correct this and resubmit." );
      return;
    }  // if( imagePrefixNameCheck.length>0 )
    if( featureSetNameCheck.length>0 ) {
      alert( "ERROR: You cannot have uppercase letters in your Feature "
          + "Set Name.  Please correct this and resubmit." );
      return;
    }  // if( featureSetNameCheck.length>0 )
    
    formObj.elements['_submitformflag'].value = "1";
    formObj.submit();
  }  // function submitForm()
//--></script>

<form name="addPrefixSet" method="get" action="AdminFeatureSetPrefixSet.jsp">
  <input type="hidden" name="_submitformflag" value="0" />

  <center>
    <%= table.renderTable() %><br />    
    <%= htmlButtonSubmit1 %>
  </center>
</form>

<%= Footer.pageFooter(globals) %>
<!-- end -->
