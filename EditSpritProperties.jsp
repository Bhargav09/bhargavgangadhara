<!--
.........................................................................
: DESCRIPTION:
: SpritPropertiesEdit page.  Should contain facilities to add update Sprit Properties data.
:
: 
: AUTHORS:
: @author Roshan Shaik (aroshan@cisco.com)
:
: Copyright (c) 2005, 2010 by Cisco Systems, Inc.
:.........................................................................
-->



<%@ page import="java.util.Date" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
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
<%@ page import="com.cisco.eit.sprit.model.spritproperties.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.SpritPropertyInfo" %>


<%!
	// instance variables and methods declaration
	final String mJNDIName= "SpritPropertiesBean.SpritPropertiesHome";
%>

<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String pathGfx;
  TableMaker tableReleasesYouOwn;
  Integer releaseNumberId = null;
  
  String operationResult="Changes saved!";
  String operationErrorResult= "";
  String operationErrorResult1= "";
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );

  SpritAccessManager acc;
  acc = (SpritAccessManager) globals.go( "accessManager" );
  String userId =  acc.getUserId();

  //TODO: check for Admin access here

  // Set up banner for later
  //banner =  new SpritGUIBanner( globals );
  //banner.addReleaseNumberElement( request,"releaseNumberId" );
  
   // Set up banner for later
    banner =  new SpritGUIBanner( globals );
    banner.addContextNavElement( "REL:",
        SpritGUI.renderReleaseNumberNav(globals,null)
      );
  
%>

<%= SpritGUI.pageHeader( globals,"Sprit Properties Admin Module","" ) %>

<%= banner.render() %>

<SCRIPT type=text/javascript>
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form "hasn't" been submitted.
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
		
		// When user submitted the form for saving changes.
		// Get All the request data and save
		
		Context ctx = new InitialContext();
		SpritProperties     spritProperties =null;
                SpritPropertiesHome  spritPropertiesHome=null;
                Collection     spritPropertiesResults=null;
		Iterator       spritPropertiesIter=null;
		
		
		int totalspritProperties = Integer.parseInt(request.getParameter("spritPropertiesCount"));
       		spritPropertiesHome = (SpritPropertiesHome) ctx.lookup("SpritPropertiesBean.SpritPropertiesHome");

		String propName = request.getParameter("addPropertyName");
		String newName = request.getParameter("newPropertyName");
		if ( newName != null && newName.trim().length() > 0 ) {
			propName = newName;
		}
		String addSeq = request.getParameter("addPropertySeq");
		// String addPropertyName           = propName.trim();
		Integer addPropertySeq = null;
    		String addDescription = null;
		String addProdValue = null;
		String addTestValue = null;
		String addDevValue  = null;
		
		if ( propName != null && propName.trim().length() > 0  ) {
			
			try{
				addPropertySeq    = Integer.valueOf(request.getParameter("addPropertySeq").trim());
			} catch ( Exception e ) {
				e.printStackTrace();
				out.println("<B> Property Sequence is required <B><BR>");
			}
			try{
				 addDescription    = (request.getParameter("addDescription")).trim();
			} catch ( Exception e ) {
				e.printStackTrace();
				out.println("<B> Property Description is required <B><BR>");
			}
			try{
				addProdValue    = (request.getParameter("addProdValue")).trim();
			} catch ( Exception e ) {
				e.printStackTrace();
				out.println("<B> Property ProdValue is required <B><BR>");
			}
			try{
				addTestValue    = (request.getParameter("addTestValue")).trim();
			} catch ( Exception e ) {
				e.printStackTrace();
				out.println("<B> Property TestValue is required <B><BR>");
			}
			try{
				addDevValue    = (request.getParameter("addDevValue")).trim();
			} catch ( Exception e ) {
				e.printStackTrace();
				out.println("<B> Property DevValue is required <B><BR>");
			}
		}
	         
		if ( propName != null && propName.trim().length() > 0 
			&& addSeq != null && addSeq.trim().length() > 0 
			&& addDescription != null && addDescription.trim().length() > 0 
			&& addProdValue != null && addProdValue.trim().length() > 0 
			&& addTestValue != null && addTestValue.trim().length() > 0 
			&& addDevValue != null && addDevValue.trim().length() > 0 
		   )
		{
	             
	        
       		try {
       		    
       		    spritProperties= (SpritProperties) spritPropertiesHome.findByPropertyNameAndPropertySeq(propName, addPropertySeq);
		    if(spritProperties.getAdmFlag().equals("D") ) {
			      spritProperties.setPropertySeq(addPropertySeq);
			      spritProperties.setDescription(addDescription);
			      spritProperties.setProdValue(addProdValue);
			      spritProperties.setTestValue(addTestValue);
			      spritProperties.setDevValue(addDevValue);
			      spritProperties.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
			      spritProperties.setAdmUserId(userId);
			      spritProperties.setAdmFlag("V");
			      spritProperties.setAdmComment("Re-Created in Sprit Properties Page");
		    } 
		   else {
			     operationResult="The Sprit Property "+propName +" already exists";
			     System.out.println("The Code already exists ");
		   } // if(spritProperties.getAdmFlag().equals("D") )
		} catch ( javax.ejb.ObjectNotFoundException e ) {
			spritPropertiesHome.create(propName,
					    addPropertySeq,
					    addDescription,
					    addProdValue,
					    addTestValue,
					    addDevValue,
					    userId,
					    new Timestamp((new java.util.Date()).getTime()),
					    "V",
					    "Created in SpritPropertiesBean"
				   );
	       }

		} // if ( propName != null && propName.trim().length > 0 ) 
	              		
       		for(int spritPropertyIndex=0; spritPropertyIndex< totalspritProperties; spritPropertyIndex++)
                 {
		    //collecting the parameternames and values
			String paramPropertyName               = "propertyName"+spritPropertyIndex;
			String paramHiddenPropertyName         = "hiddenPropertyName"+spritPropertyIndex;
			String paramPropertySeq        = "propertySeq"+spritPropertyIndex;
			String paramHiddenPropertySeq   = "hiddenPropertySeq"+spritPropertyIndex;
			String paramDescription        = "description"+spritPropertyIndex;
			String paramHiddenDescription  = "hiddenDescription"+spritPropertyIndex;
			String paramProdValue        = "prodValue"+spritPropertyIndex;
			String paramHiddenProdValue  = "hiddenProdValue"+spritPropertyIndex;
			String paramTestValue        = "testValue"+spritPropertyIndex;
			String paramHiddenTestValue  = "hiddenTestValue"+spritPropertyIndex;
			String paramDevValue        = "devValue"+spritPropertyIndex;
			String paramHiddenDevValue  = "hiddenDevValue"+spritPropertyIndex;
			String paramIsDeleteChecked    = "deleteSpritProperty"+spritPropertyIndex;

			spritPropertiesResults =null;
			spritPropertiesIter = null;

			String propertyName           = (request.getParameter( paramPropertyName )).trim();
			String hiddenPropertyName           = (request.getParameter(paramHiddenPropertyName )).trim();
			Integer propertySeq    = Integer.valueOf(request.getParameter( paramPropertySeq ).trim());
			Integer hiddenPropertySeq    = Integer.valueOf(request.getParameter( paramHiddenPropertySeq ).trim());
			String description    = (request.getParameter(paramDescription)).trim();
			String hiddenDescription    = (request.getParameter(paramHiddenDescription)).trim();
			String prodValue    = (request.getParameter(paramProdValue)).trim();
			String hiddenProdValue    = (request.getParameter(paramHiddenProdValue)).trim();
			String testValue    = (request.getParameter(paramTestValue)).trim();
			String hiddenTestValue    = (request.getParameter(paramHiddenTestValue)).trim();
			String devValue    = (request.getParameter(paramDevValue)).trim();
			String hiddenDevValue    = (request.getParameter(paramHiddenDevValue)).trim();
			String isDeleteChecked    = (request.getParameter( paramIsDeleteChecked));
		    
		   // System.out.println("FOOOOR LOOP at line 203");
		   // System.out.println(paramPropertyName);
		   // System.out.println("paramPropertyName is "+request.getParameter(paramPropertyName));
		   // System.out.println("paramHiddenPropertyName is "+paramHiddenPropertyName+" "+request.getParameter(paramHiddenPropertyName));
		   // System.out.println("paramDescription is "+paramDescription+" "+request.getParameter(paramDescription));
		   // System.out.println("paramHiddenDescription is "+paramHiddenDescription+" "+request.getParameter(paramHiddenDescription));
		   // System.out.println("paramPropertySeq is "+paramPropertySeq+" "+request.getParameter(paramPropertySeq));
		   // System.out.println("paramHiddenPropertySeq is "+paramHiddenPropertySeq+" "+request.getParameter(paramHiddenPropertySeq));
		   
		    if( !((request.getParameter(paramPropertySeq)).equals((request.getParameter(paramHiddenPropertySeq))))
		    || !((request.getParameter(paramDescription)).equals((request.getParameter(paramHiddenDescription))))
		    || !((request.getParameter(paramProdValue)).equals((request.getParameter(paramHiddenProdValue))))
		    || !((request.getParameter(paramTestValue)).equals((request.getParameter(paramHiddenTestValue))))
		    || !((request.getParameter(paramDevValue)).equals((request.getParameter(paramHiddenDevValue))))
		    || (isDeleteChecked != null) 
		     ) {
		     
		        	     
		     	try{

		             System.out.println( " Inside the IF " ); 
						     	    
		     	     spritProperties = (SpritProperties) spritPropertiesHome.findByPropertyNameAndPropertySeq( hiddenPropertyName,hiddenPropertySeq);
			     if ( spritProperties == null ) {
				System.out.println(" spritProperties is null for " +  hiddenPropertyName + " seq= " + hiddenPropertySeq );
			     }else {
			      spritProperties.setPropertySeq(propertySeq);
		     	      spritProperties.setDescription(description);
			      spritProperties.setProdValue(prodValue);
			      spritProperties.setTestValue(testValue);
			      spritProperties.setDevValue(devValue);
		     	      spritProperties.setAdmTimestamp(new Timestamp((new java.util.Date()).getTime()));
		     	      spritProperties.setAdmUserId(userId);
		     	      if("Y".equals(isDeleteChecked)) {
				      if ( hiddenPropertyName.equalsIgnoreCase("MINFLASH")) {
			                if ( SpritPropertiesJdbc.isMinFlashValueDeletable(prodValue) ) {
		     	                   spritProperties.setAdmFlag("D");
		     	                   spritProperties.setAdmComment("Deleted in Sprit Properties Page");
				        }else {
			                 operationErrorResult +="<br>The Sprit Property "+hiddenPropertyName +", value = " + 
						 prodValue + " can't be deleted.";
				        }
				      }else  if ( hiddenPropertyName.equalsIgnoreCase("MINDRAM")) {
			                if ( SpritPropertiesJdbc.isMinDRAMValueDeletable(prodValue) ) {
		     	                   spritProperties.setAdmFlag("D");
		     	                   spritProperties.setAdmComment("Deleted in Sprit Properties Page");
				        }else {
			                 operationErrorResult +="<br/>The Sprit Property "+hiddenPropertyName +", value = " + 
						 prodValue + " can't be deleted.";
				        }
				      } else {
		     	                   spritProperties.setAdmFlag("D");
		     	                   spritProperties.setAdmComment("Deleted in Sprit Properties Page");
				      }
		     	      }
		     	      else {
		     	        spritProperties.setAdmFlag("V");
		     	        spritProperties.setAdmComment("Updated in Sprit Properties Page");
		     	      }
			     }
		         } //end of try
		         catch(Exception e) {
		     	   e.printStackTrace();
			   throw e;
		         }
		     
		  }// end of if
		           
 		} //end of for loop;

	if ( "".equals(operationErrorResult) ) {		
%>		
		<span class="summaryOK"><b><%=operationResult%></b></span>
<%      
	} else { 
%>		
	        <b bgColor="#ff0000"><%=operationErrorResult%></b>

<%		
	}
%>
	
		
		<span class="footnote">
		  (<script type="text/javascript">document.write(new Date().toString())</script>.)<br />
		</span><br><br>
<%		
	}
%>

<center>
<FORM name=editfrom method=POST action="EditSpritProperties.jsp">
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
    	 Name 
    	</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
    	 New 
    	</span></td>

    	<td align="center" valign="top"><span class="dataTableTitle">
    	 Seq 
    	</span></td>
    	<td align="center" valign="top"><span class="dataTableTitle">
    	  Description (Optional)
    	</span></td>	
    	
    	<td align="center" valign="top"><span class="dataTableTitle">
	 ProdValue
    	</span></td>	
    	
    	<td align="center" valign="top"><span class="dataTableTitle">
	 TestValue
    	</span></td>	
    	
    	<td align="center" valign="top"><span class="dataTableTitle">
	 DevValue
    	</span></td>	
    	
    	</tr>
        <tr bgcolor="#F5D6A4">
    	<td align="left" valign="top"><span class="dataTableData">
    	Add
    	<img src="<%=pathGfx%>/ico_arrow_right_orange.gif" />
	      	<select name="addPropertyName" size="1">
	    	<option	value=""></option>
                <%
			String[] nameArray = SpritPropertiesJdbc.getAllSpritPropertyNames();
			for ( int idx=0;idx < nameArray.length; idx++ ) 
			{
		%>
		
	    	<option	value="<%=nameArray[idx]%>"><%=nameArray[idx]%></option>
                 <%
			}
		 %>
		
	         </select>
    	</span>
        </td>
	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="newPropertyName" size="8" value=""/>
    	</span></td>
       
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addPropertySeq" size="5" value=""/>
    	</span></td>
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addDescription" size="15" value=""/>
    	</span></td>
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addProdValue" size="5" value=""/>
    	</span></td>
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addTestValue" size="5" value=""/>
    	</span></td>
    	<td align="right" valign="top"><span class="dataTableData">
    	  <input type="text" name="addDevValue" size="5" value=""/>
    	</span></td>
        </tr>
        <tr><td></td></tr>
        <tr><td></td></tr>
        <tr><td></td></tr>
        
        </table>
  
      <TABLE cellSpacing=0 cellPadding=2 border=1>
        <TBODY>
          <tr>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Delete</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Property</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Seq</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Description(Optional)</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Prod Value</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Test Value</TD>
            <TD class=dataTableTitle align=middle bgColor=#d9d9d9>Dev Value</TD>
          </tr>
           
             <%
	        Iterator spritPropertiesVector = null;
	  	Collection spritPropertiesCollection = null;
	  	SpritPropertyInfo spritPropertyInfo = null;
	  	int spritPropertyNumber=0;
	  	
	  	try
	          { 
	          SpritPropertiesJdbc spritPropertiesJdbc = new SpritPropertiesJdbc();
	          spritPropertiesCollection = spritPropertiesJdbc.getAllSpritProperties();
	          //spritPropertiesCollection = spritPropertiesJdbc.getAllMinFlashMinDramProperties();
	          int spritPropertiesTotal = spritPropertiesCollection.size();
	     
	          ArrayList spritPropertiesToDisplayArray = new ArrayList(spritPropertiesCollection);
	          if (spritPropertiesToDisplayArray != null) {
	  	    spritPropertiesVector = spritPropertiesToDisplayArray.iterator();
	  	
	  
	  	
	  
	  	while (spritPropertiesVector.hasNext()) {
	  	  spritPropertyInfo = (SpritPropertyInfo) spritPropertiesVector.next();
	  	
              %>
          
        <tr>
        <td align="center" valign="top" class="tableCell"><span class="dataTableData">
	        <input type="checkbox" value='Y' name="deleteSpritProperty<%=spritPropertyNumber%>" />
        </span></td>
        
        <td class=dataTableData vAlign=top align=left>
	   <%=spritPropertyInfo.getPropertyName()%> 
	    <input type=hidden name="hiddenPropertyName<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getPropertyName()%>"  />
	    <input type=hidden size="8" MAXLENGTH=8 name="propertyName<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getPropertyName()%>" /> 
        </td>
        <td align="right" valign="top"><span class="dataTableData">
           <input type=text size="5" MAXLENGTH="50" name="propertySeq<%=spritPropertyNumber%>" value="<%= spritPropertyInfo.getPropertySeq()%>">
	   <input type="Hidden" name="hiddenPropertySeq<%=spritPropertyNumber%>" value="<%= spritPropertyInfo.getPropertySeq()%>" />       
		  
	  </span></td>
        <td class=dataTableData vAlign=top align=left>
         <input type=text size="25" MAXLENGTH="50" name="description<%=spritPropertyNumber%>"
         value="<%=spritPropertyInfo.getDescription()%>" />
         <input type=hidden name="hiddenDescription<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getDescription()%>"  />
        </td>
        <td class=dataTableData vAlign=top align=left>
         <input type=text size="5" MAXLENGTH="50" name="prodValue<%=spritPropertyNumber%>"
         value="<%=spritPropertyInfo.getProdValue()%>" />
         <input type=hidden name="hiddenProdValue<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getProdValue()%>"  />
        </td>
        <td class=dataTableData vAlign=top align=left>
         <input type=text size="5" MAXLENGTH="50" name="testValue<%=spritPropertyNumber%>"
         value="<%=spritPropertyInfo.getTestValue()%>" />
         <input type=hidden name="hiddenTestValue<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getTestValue()%>"  />
        </td>
        <td class=dataTableData vAlign=top align=left>
         <input type=text size="5" MAXLENGTH="50" name="devValue<%=spritPropertyNumber%>"
         value="<%=spritPropertyInfo.getDevValue()%>" />
         <input type=hidden name="hiddenDevValue<%=spritPropertyNumber%>" value="<%=spritPropertyInfo.getDevValue()%>"  />
        </td>
        </tr>
<%  
    spritPropertyNumber++;
    }
 
 %>
 
  <input type=hidden name=spritPropertiesCount value="<%=spritPropertiesTotal%>" />
 
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
		        Note: These are the Sprit Properties Codes used in SPRIT<br /><br />
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
