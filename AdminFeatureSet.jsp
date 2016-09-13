<!--.........................................................................
: DESCRIPTION:
: Admin Page: Manage feature set information.
:
: AUTHORS:
: @author Amy (amyl@cisco.com)
:
: Copyright (c) 2003-2004, 2009-2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.lang.Exception" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.sql.Driver" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.ArrayUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.logic.adminfeaturesetsession.AdminFeatureSetSessionLocal" %>
<%@ page import="com.cisco.eit.sprit.logic.adminfeaturesetsession.AdminFeatureSetSessionHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.adminfeaturesetjdbc.AdminFeatureSetJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.AdminFeatureSetUtil" %>
<%@ page import="com.cisco.eit.sprit.dataobject.FeatureSetInfo" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritDb" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<%
  AdminFeatureSetSessionLocal afssLocalObj;
  AdminFeatureSetSessionHomeLocal afssHomeLocalObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String htmlButtonSubmit1;
  String htmlButtonSubmit2;
  String htmlButtonDelete1;
  String htmlButtonDelete2;
  String pathGfx;
  String servletMessages;  

  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
      
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
  // HTML macros
  htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
	  globals,
	  "btnPrefixSetAdd1",
	  "Add new Image Prefix and Feature Set pair",
          "javascript:showAddPopup()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_PREFIXSET_ADD,
          "actionBtnSaveUpdates('btnPrefixSetAdd1')",
          "actionBtnSaveUpdatesOver('btnPrefixSetAdd1')"
	  );
  htmlButtonSubmit2 = ""
      + SpritGUI.renderButtonRollover(
          globals,
          "btnPrefixSetAdd2",
          "Add new Image Prefix and Feature Set pair",
          "javascript:showAddPopup()",
          pathGfx + "/" + SpritConstants.GFX_BTN_PREFIXSET_ADD,
          "actionBtnSaveUpdates('btnPrefixSetAdd2')",
          "actionBtnSaveUpdatesOver('btnPrefixSetAdd2')"
          );
          
  htmlButtonDelete1 = ""
        + SpritGUI.renderButtonRollover(
  	  globals,
  	  "btnDelete1",
  	  "Delete Feature Set",
            "javascript:submitForm('featureSetGrid')",
  	  pathGfx + "/" + SpritConstants.GFX_BTN_DELETE_CHECKED,
            "actionBtnDelete('btnDelete1')",
            "actionBtnDeleteOver('btnDelete1')"
	  );
	  
  htmlButtonDelete2 = ""
        + SpritGUI.renderButtonRollover(
  	  globals,
  	  "btnDelete2",
  	  "Delete Feature Set",
            "javascript:submitForm('featureSetGrid')",
  	  pathGfx + "/" + SpritConstants.GFX_BTN_DELETE_CHECKED,
            "actionBtnDelete('btnDelete2')",
            "actionBtnDeleteOver('btnDelete2')"
	  );
	  
%>
<%= SpritGUI.pageHeader( globals,"Feature Set Editor","" ) %>
<%= banner.render() %>

<span class="headline">
  Feature Set Description and Designator Editor
</span><br /><br />

<%
  if( !spritAccessManager.isAdminFeatureSet() ) {
    response.sendRedirect("ErrorAccessPermissions.jsp");
  }  // if( !spritAccessManager.isAdminFeatureSet() )

  // Initialize the session...
  afssLocalObj = null;
  try {
    Context ctx = new InitialContext();
    afssHomeLocalObj = (AdminFeatureSetSessionHomeLocal)
      ctx.lookup("ejblocal:AdminFeatureSetSession.AdminFeatureSetSessionHome");
    afssLocalObj = afssHomeLocalObj.create();
  } catch(Exception e) {
    System.out.println("AdminFeatureSet.jsp: Can't create session for this page! " + e.getMessage() );
  }  // try-catch
%>

<%= SpritGUI.renderReleaseTabUnderline(globals) %>

<%
  Iterator iter;
  SpritSecondaryNavBar navBar;
  String filterFeatureSet;
  String filterFeatureSetDesc;
  String filterImagePrefix;
  String htmlCellStyle;
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
  
  // What is the sorting column, default to Image Prefix.
  sortCol = WebUtils.getParameter(request,"sortCol");
  if( sortCol.equals("") ) {
    sortCol = "imagePrefix";
  }  // if( sortCol.equals("") )
  
  // What is the current sorting direction for the lists?  Force to "a" or
  // "d", but default to "a".  Oh and while we're at it calculate the
  // reverse direction sort.
  sortDirCurrent = WebUtils.getParameter(request,"sortDir");
  if( !sortDirCurrent.equals("d") ) {
    sortDirCurrent = "a";
    sortDirReverse = "d";
  } else {  // if( !sortDirCurrent.equals("d") )
    sortDirReverse = "a";
  }  // else if( !sortDirCurrent.equals("d") )
  
  // Gather filters.
  filterImagePrefix = FilterUtil.getFilterParameter( request,"filterImagePrefix" );
  filterFeatureSet = FilterUtil.getFilterParameter( request,"filterFeatureSet" );
  filterFeatureSetDesc = FilterUtil.getFilterParameter( request,"filterFeatureSetDesc" );

  // Render nav bar.
  navBar = new SpritSecondaryNavBar( globals );  
  navBar.addFilters( 
      "filterImagePrefix", filterImagePrefix, 10,
      pathGfx + "/filter_label_imgprfx.gif",
      "Filter the following list by entering part of the Image Prefix.  Wildcards accepted.",
      "Image Prefix Filters" );
  navBar.addFilters( 
      "filterFeatureSet", filterFeatureSet, 10,
      pathGfx + "/filter_label_fset.gif",
      "Filter the following list by entering part of the Feature Set.  Wildcards accepted.",
      "Image Prefix Filters" );
  navBar.addFilters( 
      "filterFeatureSetDesc", filterFeatureSetDesc, 10,
      pathGfx + "/filter_label_fsetdesc.gif",
      "Filter the following list by entering part of the Feature Set Description.  Wildcards accepted.",
      "Image Prefix Filters" );

  out.println( ""
      + "<form action=\"AdminFeatureSet.jsp\" method=\"get\">\n"
      + "<input type=\"hidden\" name=\"sortCol\" value=\"" 
          + WebUtils.escHtml(sortCol) + "\" />\n"
      + "<input type=\"hidden\" name=\"sortDir\" value=\"" 
          + WebUtils.escHtml(sortDirCurrent) + "\" />\n"
      + SpritGUI.renderTabContextNav( globals,navBar.render() + "\n" )
      + "</form>"
      );
      
  // Add an extra form that only just refreshes this page.  This will be used by the
  // pop-up windows!
  out.println( ""
      + "<form action=\"AdminFeatureSet.jsp\" method=\"get\" name=\"refreshForm\">\n"
      + "<input type=\"hidden\" name=\"sortCol\" value=\"" 
          + WebUtils.escHtml(sortCol) + "\" />\n"
      + "<input type=\"hidden\" name=\"sortDir\" value=\"" 
          + WebUtils.escHtml(sortDirCurrent) + "\" />\n"
      + "<input type=\"hidden\" name=\"filterImagePrefix\" value=\"" 
          + WebUtils.escHtml(filterImagePrefix) + "\" />\n"
      + "<input type=\"hidden\" name=\"filterFeatureSet\" value=\"" 
          + WebUtils.escHtml(filterFeatureSet) + "\" />\n"
      + "<input type=\"hidden\" name=\"filterFeatureSetDesc\" value=\"" 
          + WebUtils.escHtml(filterFeatureSetDesc) + "\" />\n"
      + "</form>"
      );
%>
<br />

<script language="JavaScript"><!--
  //............................................................................
  // DESCRIPTION:
  // Handles the rollover stuff for the image buttons.  Images won't
  // change if the form has been submitted.
  //
  // IN:
  // elemName: the name of the element to toggle
  //............................................................................
  function actionBtnSaveUpdates(elemName) {
    if( document.forms['featureSetGrid'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_PREFIXSET_ADD%>" );
    }  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
    if( document.forms['featureSetGrid'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_PREFIXSET_ADD_OVER%>" );
    }  // if
  }
  
  function actionBtnDelete(elemName) {
    if( document.forms['featureSetGrid'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_DELETE_CHECKED%>" );
      }  // if
  }
  function actionBtnDeleteOver(elemName) {
    if( document.forms['featureSetGrid'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_DELETE_CHECKED_OVER%>" );
      }  // if
  }

  //............................................................................
  // DESCRIPTION:
  // Pops up a new window to manage the Image Prefix and Feature Set
  // additions.
  //
  // IN:
  // url: URL to pop up stuff.
  //............................................................................
  function showAddPopup() {
    var url;
    var win;
    var posx,posy;

    posx = mousePosX-32;  
    posy = mousePosY-32;  

    url = "AdminFeatureSetPrefixSet.jsp";
    win = window.open( url,"adminFeatureSetAddPrefix",
        "resizable=yes,scrollbars=yes,width=650,height=265"
        + ",top=" + 50
        + ",left=" + 50 );

    win.focus();
  }

  //............................................................................
  // DESCRIPTION:
  // Pops up a new window to manage the Image Prefix and Feature Set
  // additions.
  //
  // IN:
  // imagePrefixNameId: Image prefix name.
  // featureSetNameId: Feature set name.
  //............................................................................
  function showEditPopup( imagePrefixNameId, featureSetNameId ) {
    var url;
    var win;
    var posx,posy;

    posx = mousePosX-32;  
    posy = mousePosY-32;  

    url = "AdminFeatureSetEditPopup.jsp?imagePrefixNameId="+imagePrefixNameId+
        "&featureSetNameId="+featureSetNameId;
    win = window.open( url,"adminFeatureSetEditPopup",
        "resizable=yes,scrollbars=yes,width=600,height=560"
        + ",top=" + 50
        + ",left=" + 50 );

    win.focus();
  }

  //........................................................................
  // DESCRIPTION:
  //     Submits this form.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  function submitForm(formName) {
    var formObj;
    formObj = document.forms[formName];
    elements = formObj.elements;
    
    // Check to see if we've submitted this before!
    if( elements['_submitformflag'].value==1 ) {
       return;
    }

    elements['_submitformflag'].value=1;
    formObj.submit();

  } 

//--></script>

Here you can add or remove Image Prefix and Feature Set pairs, and
(dis)associate Descriptions and Designator pairs with them.

<form action="DelAdminFeatureSetProcessor" method="GET" name="featureSetGrid">



<%





  // Actually get the data as a master grid.
  Vector featureSetsVector = null;
  Vector featureSetsVectorFiltered = null;
  try {
    int row = 0;
    
    featureSetsVector = AdminFeatureSetJdbc.getRecordsAll();

    // Filter and sort the vector.
    featureSetsVectorFiltered = (Vector) FilterUtil.filterAFSVector(
        featureSetsVector,
        filterImagePrefix,
        filterFeatureSet,
        filterFeatureSetDesc
        );
    AdminFeatureSetUtil.sortAFSRecords(
        featureSetsVectorFiltered,
        sortCol,
        sortDirCurrent
        );
    out.println( "<b>" + featureSetsVectorFiltered.size() + "</b> of " 
        + "<b>" + featureSetsVector.size() + "</b> records shown." );
  } catch( Exception e ) {
    out.println( SpritGUI.renderErrorBox( globals,
        "Feature Set data error",
        "Can't retrieve Feature Set data: " + e.getMessage()
        ) );
  }  // try-catch  
  
  // See if there were any messages generated
  servletMessages = (String)
  request.getAttribute( "Sprit.servMsg" );
  
  if( servletMessages!=null ) {
      PrintWriter printWriter;
      printWriter = response.getWriter();
      printWriter.print( ""
          + "<br />\n"
          + servletMessages 
          + "<br /><br />\n\n"
          );
  }  // if( servletMessages!=null )
        
  // Figure out sorting links
  urlBase = "AdminFeatureSet.jsp?"
      + "filterImagePrefix=" + WebUtils.escUrl(filterImagePrefix) + "&"
      + "filterFeatureSet=" + WebUtils.escUrl(filterFeatureSet) + "&"
      + "filterFeatureSetDesc=" + WebUtils.escUrl(filterFeatureSetDesc) + "&"
      + "sortDir=";
  if( sortCol.equals("imagePrefix") ) {
    urlSortImagePrefix = urlBase + sortDirReverse +"&sortCol=imagePrefix";
  } else {  // if( sortCol.equals("imagePrefix") )
    urlSortImagePrefix = urlBase + "a" + "&sortCol=imagePrefix";
  }  // else if( sortCol.equals("imagePrefix") )
  if( sortCol.equals("featureSetName") ) {
    urlSortFeatureSetName = urlBase + sortDirReverse +"&sortCol=featureSetName";
  } else {  // if( sortCol.equals("featureSetName") )
    urlSortFeatureSetName = urlBase + "a" + "&sortCol=featureSetName";
  }  // else if( sortCol.equals("featureSetName") )
  if( sortCol.equals("featureSetDesc") ) {
    urlSortFeatureSetDesc = urlBase + sortDirReverse +"&sortCol=featureSetDesc";
  } else {  // if( sortCol.equals("featureSetDesc") )
    urlSortFeatureSetDesc = urlBase + "a" + "&sortCol=featureSetDesc";
  }  // else if( sortCol.equals("featureSetDesc") )
  if( sortCol.equals("featureSetDesignator") ) {
    urlSortFeatureSetDesignator = urlBase + sortDirReverse +"&sortCol=featureSetDesignator";
  } else {  // if( sortCol.equals("featureSetDesignator") )
    urlSortFeatureSetDesignator = urlBase + "a" + "&sortCol=featureSetDesignator";
  }  // else if( sortCol.equals("featureSetDesignator") )
  
  // Add headers.
 
  	htmlCellStyle = "class=\"dataTableTitle\" align=\"center\" bgcolor=\"#d9d9d9\"";
  	htmlFeatureSetTable.newRow();
	htmlFeatureSetTable.addTD(htmlCellStyle,"Delete");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"<a href=\""+urlSortImagePrefix+"\">Image Prefix</a>");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"<a href=\""+urlSortFeatureSetName+"\">Feature Set</a>");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"<a href=\""+urlSortFeatureSetDesc+"\">Feature Set Description</a>");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"<a href=\""+urlSortFeatureSetDesignator+"\">Designator</a>");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"CCO");
 	htmlFeatureSetTable.addTD(htmlCellStyle,"&nbsp;");  
  // Add meat.
	htmlCellStyle = "class=\"dataTableData\" align=\"left\" bgcolor=\"#ffffff\"";
	if( featureSetsVector==null ) {
		htmlFeatureSetTable.newRow();
		htmlFeatureSetTable.addTD( htmlCellStyle+" colspan=\"5\"",""
	        + "<center><span class=\"noData\">No records found!<br />"
	        + "(This is possibly a database error...)</span></center>"
	        );
	  } else {  // if( featureSetsVector==null )
	    iter = featureSetsVectorFiltered.iterator();
	int counter = 0;
	while( iter.hasNext() ) {
		htmlFeatureSetTable.newRow();
		FeatureSetInfo fsi;
		fsi = (FeatureSetInfo) iter.next();
	        counter++;
		htmlFeatureSetTable.addTD(htmlCellStyle,"<input type=\"checkbox\" name=\"CHK_"+counter+"\" value=\""+fsi.featureSetId+"\">");
		htmlFeatureSetTable.addTD(htmlCellStyle,fsi.imagePrefixName);
		htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetName);
		htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetDesc);
		htmlFeatureSetTable.addTD(htmlCellStyle,fsi.featureSetDesignator);
		htmlFeatureSetTable.addTD(htmlCellStyle,fsi.goingToCCO);
		htmlFeatureSetTable.addTD(htmlCellStyle,""          
		+ "<a href=\"javascript:showEditPopup('" 
	              + fsi.imagePrefixId + "','" 
	              + fsi.featureSetNameId + "')\">"
	          + "<img src=\"" + pathGfx + "/btn_edit_mini.gif\" border=\"0\" />"
	          + "</a>"
	          + " <!-- " + fsi.featureSetId + " -->"
	          );
	}  // while( iter.hasNext() )
	out.println("<input type=\"hidden\" name=\"_rows\" value=\""+counter+"\" />");
  }  // else if( featureSetsVector==null )
  
  // Produce output.  
  htmlFeatureSetGrid.append( htmlFeatureSetTable.renderTable() );
%>

<br />

  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="sortCol" value="<%= 
      WebUtils.escHtml(sortCol)
      %>" />
  <input type="hidden" name="sortDir" value="<%= 
      WebUtils.escHtml(sortDirCurrent)
      %>" />

  <blockquote>
    <center>
      <%= htmlButtonSubmit1 %> <%= htmlButtonDelete1 %><br /><br />
  
      <%= htmlFeatureSetGrid %><br />
    
      <%= htmlButtonSubmit2 %> <%= htmlButtonDelete2 %>
    </center>
  </blockquote>
</form>





<%= Footer.pageFooter(globals) %>
<!-- end -->
