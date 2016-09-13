<!--.........................................................................
: DESCRIPTION:
: ExportControlEdit page.  Should contain facilities to add update export control data.
:
: 
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
:
: Copyright (c) 2002-2004, 2010 by Cisco Systems, Inc.
:.........................................................................-->



<%@ page import="java.util.Date" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.*" %>

<%@ page import="java.sql.Timestamp"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.model.exportcontrol.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.ExportControlRecordInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.relpcodegroupeditor.*"%>


<%!
	// instance variables and methods declaration
	final String mJNDIName= "ejblocal:ExportControlBean.ExportControlLocalHome";
%>

<%
 System.out.println("TEstinG");
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String pathGfx;
  TableMaker tableReleasesYouOwn;
  Integer releaseNumberId = null;
  
  String operationResult="Changes saved!";
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  SpritAccessManager acc;
  acc = (SpritAccessManager) globals.go( "accessManager" );
  String userId =  acc.getUserId();

  // Set up banner for later
  //banner =  new SpritGUIBanner( globals );
  //banner.addReleaseNumberElement( request,"releaseNumberId" );
  
   // Set up banner for later
    banner =  new SpritGUIBanner( globals );
    banner.addContextNavElement( "REL:",
        SpritGUI.renderReleaseNumberNav(globals,null)
      );
  
%>

<%= SpritGUI.pageHeader( globals,"Feature Set Editor","" ) %>

<%= banner.render() %>

<SCRIPT type=text/javascript>
  var browserIsWrong = false;
  var browserMessage = "";

  if( is_ie ) {
    // Internet Explorer flavors
    if( !is_ie6up ) {
      browserIsWrong = true;
      browserMessage = ""
          + "You appear to be using an outdated version of "
          + "Internet Explorer.  Please upgrade to MSIE 6.0.";
    }  // if( !is_ie6up )
  } else if( is_nav ) {
    // Netscape Navigator
    browserIsWrong = true;
    browserMessage = "Netscape Navigator may work with SPRIT"
        + "but MSIE 6 is preferred.";
    if( !is_nav7up ) {
      browserMessage += "Your version of Netscape is also too old. "
          + "Please upgrade to version 7.0 or later.";
    }  // if( !is_nav7up )
  } else {
    browserIsWrong = true;
    browserMessage = "You may not be using a supported browser. "
        + "SPRIT is designed to work best on MSIE 6.0.";
  }  // else

  if( browserIsWrong ) {
    document.write( ""
 + "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\" width=\"100%\">\n"
 + "<tr><td bgcolor=\"#ffff00\" align=\"center\"><font size=\"-2\" face=\"Arial, Helvetica\">\n"
 + "  " + browserMessage + "\n"
 + "</td></tr>\n"
 + "</table>\n"
 );
  }  // if( browserIsWrong )

  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................

  function actionBtnSaveImages(elemName) {
    setImg( elemName,"../gfx/btn_save_updates.gif" );
  }
  function actionBtnSaveImagesOver(elemName) {
    setImg( elemName,"../gfx/btn_save_updates_over.gif" );
  }

  function validateAndSubmitForm() {
  	  // I guess no validation is required as we set the maximum 
  	  // length for all the fields.
	  document.editfrom.submit();
  }

  function toUpper(objThisCtrl) 
  {
    objThisCtrl.value=objThisCtrl.value.toUpperCase();
  }

  function toLower(objThisCtrl) 
  {
      objThisCtrl.value=objThisCtrl.value.toLowerCase();
  }


</SCRIPT>

<br>
<br>
<%

     	if( "novalue".equals( request.getParameter( "hidfield" ) ) ) { 
					// When user submitted the form for saving pcode group.

		// Get All the request data and 
		//		make the list of ReleasePCodeGroupEditorInfo.
		
		Context ctx = new InitialContext();
		ExportControlLocal      exportControl=null;
                ExportControlLocalHome  exportControlLocalHome=null;
                Collection     exportControlResults=null;
		Iterator       exportControlIter=null;
		
		
		int totalExportControlRecords = Integer.parseInt(request.getParameter("exportControlRecordsCount"));
		String addCode           = (request.getParameter("addCode")).trim();
	        String addExportLevel    = (request.getParameter("addExportLevel")).trim();
                String addDescription    = (request.getParameter("addDescription")).trim();
	         
	             
	        
       		try {
       		    
       		    exportControlLocalHome = (ExportControlLocalHome) ctx.lookup("ejblocal:ExportControlBean.ExportControlHome");
       		    
       		  } catch(Exception e) {
       		    System.out.println("ExportControlSetUpEdit can't create Line 181 " + e.getMessage() );
       		}  // try-catch
       		
       		// for adding export control
       		//System.out.println( "  The value of addcode is "+(request.getParameter("addCode")).trim() );
       	       if ( !"".equals(addCode) ) {
       	        exportControlResults = exportControlLocalHome.findAllByCode(addCode);
		exportControlIter    = exportControlResults.iterator();
		if(exportControlIter.hasNext() ) {
		   exportControl= (ExportControlLocal) exportControlIter.next();
		   if(exportControl.getAdmFlag().equals("D") ) {
		      exportControl.setExportLevel(addExportLevel);
	              exportControl.setDescription(addDescription);
	              exportControl.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
	              exportControl.setAdmUserId(userId);
	              exportControl.setAdmFlag("V");
	              exportControl.setAdmComment("Re-Created in Export control Page");
	           } 
	           else {
	             operationResult="The Export Control Code "+addCode +" already exists";
	             System.out.println("The Code already exists ");
	           }
	         }else {
	           exportControlLocalHome.create(addCode,
	                                    addExportLevel,
	                                    addDescription,
	                                    userId,
	                                    new Timestamp((new java.util.Date()).getTime()),
	                                    userId,
	                                    new Timestamp((new java.util.Date()).getTime()),
	                                    "V",
	                                    "Created in Export control"
	                                   );
	          }
	        }//end of ADD records
       		
       		for(int exportControlIndex=0; exportControlIndex< totalExportControlRecords; exportControlIndex++)
                 {
		    //collecting the parameternames and values
		    String paramCode               = "code"+exportControlIndex;
	            String paramHiddenCode         = "hiddenCode"+exportControlIndex;
	            String paramExportLevel        = "exportLevel"+exportControlIndex;
	            String paramHiddenExportLevel  = "hiddenExportLevel"+exportControlIndex;
		    String paramDescription        = "description"+exportControlIndex;
		    String paramHiddenDescription  = "hiddenDescription"+exportControlIndex;
		    String paramIsDeleteChecked    = "deleteExportControlRecord"+exportControlIndex;
		    
		    exportControlResults =null;
		    exportControlIter = null;
		
		    
		    //System.out.println("FOOOOR LOOP at line 203");
		    //System.out.println(paramCode);
		    //System.out.println("paramCode is "+request.getParameter(paramCode));
		    //System.out.println("paramHiddenCode is "+paramHiddenCode+" "+request.getParameter(paramHiddenCode));
		    //System.out.println("paramDescription is "+paramDescription+" "+request.getParameter(paramDescription));
		    //System.out.println("paramHiddenDescription is "+paramHiddenDescription+" "+request.getParameter(paramHiddenDescription));
		    //System.out.println("paramExportLevel is "+paramExportLevel+" "+request.getParameter(paramExportLevel));
		    //System.out.println("paramHiddenExportLevel is "+paramHiddenExportLevel+" "+request.getParameter(paramHiddenExportLevel));
		   
		  if ( !((request.getParameter(paramCode)).equals( (request.getParameter(paramHiddenCode))))
		    || !((request.getParameter(paramExportLevel)).equals((request.getParameter(paramHiddenExportLevel))))
		    || !((request.getParameter(paramDescription)).equals((request.getParameter(paramHiddenDescription))))
		    || ((request.getParameter(paramIsDeleteChecked)) != null) 
		     ) {
		     
		        	     
		     	try{
		     	  
		     	  if(!( request.getParameter(paramCode).equals( request.getParameter(paramHiddenCode)) ) ) {
		     	   exportControlResults = exportControlLocalHome.findAllByCode(request.getParameter(paramCode));
		     	   exportControlIter    = exportControlResults.iterator();
		     	      if(exportControlIter.hasNext() ) {
		     	        exportControl= (ExportControlLocal) exportControlIter.next();
		     	        if(exportControl.getAdmFlag().equals("D") ) {
		     	         exportControl.setExportLevel(request.getParameter(paramExportLevel));
		     	         exportControl.setDescription(request.getParameter(paramDescription));
		     	         exportControl.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
                                 exportControl.setAdmUserId(userId);
                                 exportControl.setAdmFlag("V");
		     	         exportControl.setAdmComment("Updated in Export control Page");
		     	         
		     	         //Delete old ones
		     	         exportControlResults=null;
		     	         exportControlIter=null;
		     	         
		     	          System.out.println("paramCode is "+request.getParameter(paramCode));
		                  System.out.println("paramHiddenCode is "+paramHiddenCode+" "+request.getParameter(paramHiddenCode));
		     	         
		     	         exportControlResults = exportControlLocalHome.findAllByCode(request.getParameter(paramHiddenCode));
				 exportControlIter    = exportControlResults.iterator();
			  	 if(exportControlIter.hasNext() ) {
			  	   exportControl= (ExportControlLocal) exportControlIter.next();
			  	   exportControl.setExportLevel(request.getParameter(paramExportLevel));
				   exportControl.setDescription(request.getParameter(paramDescription));
				   exportControl.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
				   exportControl.setAdmUserId(userId);
				   exportControl.setAdmFlag("D");
				   exportControl.setAdmComment("Code has been replaced on Export Control Page");
				}
		     	        continue;
		     	       }
		     	       else if(exportControl.getAdmFlag().equals("V") ) {
		     	        operationResult="The Export Control Code "+ request.getParameter(paramCode) +" already exists";
		     	        //System.out.println("This " + request.getParameter(paramCode) +"Already exists!!!" );
		     	        continue;
		     	       }
		     	      }
		     	   }
		     	    
			   exportControlResults = exportControlLocalHome.findAllByCode(request.getParameter(paramHiddenCode));
			   exportControlIter    = exportControlResults.iterator();
			  
			   while( exportControlIter.hasNext() ) {
		     	      exportControl = (ExportControlLocal) exportControlIter.next();
		     	      exportControl.setCode(request.getParameter(paramCode));
		     	      exportControl.setExportLevel(request.getParameter(paramExportLevel));
		     	      exportControl.setDescription(request.getParameter(paramDescription));
		     	      exportControl.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
		     	      exportControl.setAdmUserId(userId);
		     	      if("Y".equals(request.getParameter(paramIsDeleteChecked))) {
		     	       exportControl.setAdmFlag("D");
		     	       exportControl.setAdmComment("Deleted in Export control Page");
		     	      }
		     	      else {
		     	        exportControl.setAdmFlag("V");
		     	        exportControl.setAdmComment("Updated in Export control Page");
		     	      }
		     	    } // end of while
		     	  
		          
		         } //end of try
		         catch(Exception e) {
		     	   System.out.println("Exception at line 226"+ e);
		         }
		     
		     
		  }// end of if
		           
 		} //end of for loop;
		
%>		
		<span class="summaryOK"><b><%=operationResult%></b></span>
		<span class="footnote">
		  (<script type="text/javascript">document.write(new Date().toString())</script>.)<br />
		</span><br><br>
<%		
	}
%>

<center>
<FORM name=editfrom method=POST action="ExportControlSetupEdit.jsp">
<input type="hidden" name="hidfield" value="novalue">
<table border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td align="center">
	    <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates1')"
		    onclick="javascript:validateAndSubmitForm()"
	    	onmouseout="actionBtnSaveImages('btnSaveUpdates1')" alt="Save Updates"
		    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates1><br /><br />
	</td>
  </tr>
  
  <tr>
    <td valign="top">
    <table border="0" cellpadding="3" cellspacing="1">
          <tr bgcolor="#d9d9d9">
    	<td align="center" valign="top"><span class="dataTableTitle">
    	  Code
    	</span></td>
    	<td align="center" valign="top"><span class="dataTableTitle">
    	  ExportLevel
    	</span></td>
    	<td align="center" valign="top"><span class="dataTableTitle">
    	  Description (Optional)
    	</span></td>	
    	<!--
    	<td align="center" valign="top"><span class="dataTableTitle">
    	</span></td>	
    	-->
    	</tr>
        <tr bgcolor="#F5D6A4">
    	<td align="left" valign="top"><span class="dataTableData">
    	Add
    	<img src="<%=pathGfx%>/ico_arrow_right_orange.gif" />
              <input type="text" name="addCode" size="8" value="" />
    	</span></td>
    	<td align="right" valign="top"><span class="dataTableData">
	      	<select name="addExportLevel" size="1">
	    	<% 
	    	for (int i = 0; i < SpritConstants.EXPORT_CONTROL_LEVEL.length; i++) { %>
	    	<option	value="<%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%>"><%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%></option>
	            <% } %>
	          	</select></span></td>
        
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addDescription" size="50" value=""/>
    	</span></td>
    	<!--
    	 <td align="right" valign="top">
    	   <a href="javascript:ResetForm('editImageList')"><img
                        src="<%=pathGfx%>/btn_resetfield.gif" border="0" /></a>
         </td>
         -->
        </tr>
        <tr><td></td></tr>
        <tr><td></td></tr>
        <tr><td></td></tr>
        <tr><td></td></tr>
        <tr><td></td></tr>

        
        </table>
  
      <TABLE cellSpacing=0 cellPadding=2 border=1>
        <TBODY>
          <tr>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Delete</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Code</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Export Level</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Description(Optional)</TD>
          </tr>
           
             <%
	        Iterator exportControlRecordsVector = null;
	  	Collection exportControlRecordsCollection = null;
	  	ExportControlRecordInfo exportControlRecordInfo = null;
	  	int exportControlRecordNumber=0;
	  	
	  	try
	          { 
	          ExportControlJdbc exportControldbc = new ExportControlJdbc();
	          exportControlRecordsCollection = exportControldbc.getAllExportControlRecords();
	          int exportControlRecordsTotal = exportControlRecordsCollection.size();
	     
	          ArrayList exportControlRecordsToDisplayArray = new ArrayList(exportControlRecordsCollection);
	          if (exportControlRecordsToDisplayArray != null) {
	  	    exportControlRecordsVector = exportControlRecordsToDisplayArray.iterator();
	  	
	  
	  	
	  
	  	while (exportControlRecordsVector.hasNext()) {
	  	  exportControlRecordInfo = (ExportControlRecordInfo) exportControlRecordsVector.next();
	  	
              %>
          
        <tr>
        <td align="center" valign="top" class="tableCell"><span class="dataTableData">
	        <input type="checkbox" value='Y' name=deleteExportControlRecord<%=exportControlRecordNumber%> />
        </span></td>
        
        <td class=dataTableData vAlign=top align=left>
	   <input type=text size="8" MAXLENGTH=8 name=code<%=exportControlRecordNumber%> value="<%=exportControlRecordInfo.getCode()%>" 
	    OnKeyUp='toLower(this);' 
	    OnChange='toLower(this);' 
	    onBlur='toLower(this);'>
	    <input type=hidden name="hiddenCode<%=exportControlRecordNumber%>" value="<%=exportControlRecordInfo.getCode()%>"  />
        </td>
        <td align="right" valign="top"><span class="dataTableData">
		  <select name=exportLevel<%=exportControlRecordNumber%> size="1">
		  <% 
		  for (int i = 0; i < SpritConstants.EXPORT_CONTROL_LEVEL.length; i++) { 
		  if (SpritConstants.EXPORT_CONTROL_LEVEL[i].equals((exportControlRecordInfo.getExportLevel().toString())))	{
		  %>
		  <option	value="<%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%>" Selected = "Selected"><%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%></option>
		  
		  <% }  else  {%>
		  <option	value="<%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%>"><%=SpritConstants.EXPORT_CONTROL_LEVEL[i]%></option>
		  
		  <% } } %> </select>
		  <input type="Hidden" name="hiddenExportLevel<%=exportControlRecordNumber%>" value="<%= exportControlRecordInfo.getExportLevel()%>" />       
		  
	  </span></td>
        <td class=dataTableData vAlign=top align=left>
         <input type=text size="50" MAXLENGTH="50" name="description<%=exportControlRecordNumber%>"
         value="<%=exportControlRecordInfo.getDescription()%>" />
         <input type=hidden name="hiddenDescription<%=exportControlRecordNumber%>" value="<%=exportControlRecordInfo.getDescription()%>"  />
        </td>
        </tr>
<%  
    exportControlRecordNumber++;
    }
 
 %>
 
  <input type=hidden name=exportControlRecordsCount value=<%=exportControlRecordsTotal%> />
 
 <%
   }
} catch( Exception e ) {
	e.printStackTrace(); // need to add some more exception to handle JDBC errors.
    throw e;
} 

%>        
  
 </TBODY>
      </TABLE>
    </td>
  
    <td>
      <img src="../gfx/b1x1.gif" width="50" />
    </td>
    <td valign="top" width="300">
      <table border="1" cellpadding="10" cellspacing="0">
        <tr>
          <td align="left" bgcolor="#d9d9d9">
            <span class="footnote">
            <span class="colorblack">
		        Note: These are the Export Control Codes used in SPRIT<br /><br />
		        <b>You can</b> Update the information in each line:<br />
		        Create a new entry by filling data into the empty line at the top of the table.
		        Delete any entry by selecting the check box <br> </br>
			Click the Save Updates button when ready. 
	    <span>
            <span>
          </td>
        </tr>
      </table>
      
    </td>
    
  </tr> 
  <tr>
   <td align="center">
      <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates2')"
			onclick="javascript:validateAndSubmitForm()"
		    onmouseout="actionBtnSaveImages('btnSaveUpdates2')" alt="Save Updates"
		    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates2>
    </td>
  </tr>
</table>
</FORM>
</center>
   
<%= Footer.pageFooter(globals) %>
<!-- end -->
