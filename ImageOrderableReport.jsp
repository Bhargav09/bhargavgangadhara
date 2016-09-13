<!--.........................................................................
: DESCRIPTION:
: Image Orderable Report page.
:
: AUTHORS:
: @author Rob Nevitt (rnevitt@cisco.com)
:
: Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>


<%@ page import="java.util.Properties" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="java.sql.CallableStatement" %>
<%@ page import="java.sql.Types" %>

<%@ page import="com.cisco.eit.sprit.util.SpritDb" %>


<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.marketmatrix.MarketMatrixJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.MarketMatrixGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.FilterUtil" %>
<%@ page import="com.cisco.eit.sprit.dataobject.MarketMatrixInfo" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ taglib uri="http://www.extremecomponents.org" prefix="ec"%>
<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>

<%
  Context ctx;
  Integer releaseNumberId;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseNumberModelLocal rnmObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String jndiName;
  String pathGfx;
  String releaseNumber = null;
  TableMaker tableReleasesYouOwn; 
  Vector mmInfoords = new Vector();
  String webParamsDefault;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  MarketMatrixInfo mmInfo;
  
  try {
    releaseNumberId = new Integer(
        WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  
  	MonitorUtil monUtil = new MonitorUtil();
    	monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image Orderable Report");
  
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }
  
  // Get release number information.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();
  } catch( Exception e ) {
    throw e;
  }  // catch  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber)
   );
   try {
   mmInfoords = (Vector) MarketMatrixJdbc.getRecordsAll(releaseNumberId);   
   }catch(Exception e){}
 
%>
<%= SpritGUI.pageHeader( globals,"Image Orderable Report","" ) %>
<%= banner.render() %>

<%= SpritReleaseTabs.getTabs(globals, "mm") %>


<%
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );
  webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString()); 

  // String filterImageName = FilterUtil.getFilterParameter(request,"filtImgnm");
  // String filterProductSoftwareDesc = FilterUtil.getFilterParameter(request,"filtProdSoftdesc");

  String filterImageName = StringUtils.elimSpaces( WebUtils.getParameter(request,"filtImgnm") );
  String filterProductSoftwareDesc = StringUtils.elimSpaces( 
  	WebUtils.getParameter(request,"filtProdSoftdesc") );
  if ( filterImageName == null || "".equals( filterImageName ) )
  	filterImageName = "*";
  if ( filterProductSoftwareDesc == null || "".equals( filterProductSoftwareDesc ) )
  	filterProductSoftwareDesc = "*";

  String filterUrl = ""
        + "filtProdSoftdesc=" + WebUtils.escUrl( filterProductSoftwareDesc )
        + "&filtImgnm=" + WebUtils.escUrl( filterImageName );

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 /* secNavBar.addFilters(
        "filtImgnm", filterImageName, 25,
        pathGfx+"/"+"filter_label_imgname.gif",
        "Sorry, no Help available.",
        "Image Name filter"
        );
  secNavBar.addFilters(
        "filtProdSoftdesc", filterProductSoftwareDesc, 25,
        pathGfx+"/"+"filter_label_sw_prod_desc.gif",
        "Sorry, no Help available.",
        "Product Softwatre Description filter"
        ); */
 %>
 
  <table border="0" cellpadding="3" cellspacing="0">
    <tr bgcolor="#BBD1ED">
    	<td width="75%" valign="middle" align="left">
          <form action="<%=globals.gs("currentPage")%>" method="GET">
          <input type="hidden" name="releaseNumberId" value= 
            "<%=WebUtils.escHtml(releaseNumberId.toString())%>">
          <% 
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render( 
          		spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"MM"),
            		true,
            		"MarketMatrix.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixEdit.jsp?" + webParamsDefault + "&" + filterUrl,
            		"MarketMatrixReport.jsp?" + webParamsDefault + "&" + filterUrl
                		+ "&outputType=excel"
            		) ) );
           %>
        </form>


         </td>
         <td width="25%" valign="middle" align="right">
           <table>
             <tr>
                <td class="tabNavData">
                   <a href="pcodeGroupEdit.jsp?<%=webParamsDefault%>" id="tabNavLink"><nobr>Product Code Group Editor</nobr></a>
                </td>
              </tr>
           </table>
         </td>
         <td>
         </td>
      </tr>
   </table>


 <center>
 
 <center><h2>Image Orderable Report</h2></center>
 <% 

List skus = new java.util.ArrayList();
java.util.Map sku = new java.util.HashMap();

Vector listOfMMInfo = FilterUtil.filterMMVector( 
    	mmInfoords, filterImageName, filterProductSoftwareDesc );

        Connection conn = SpritDb.jdbcGetConnection();
        if( conn==null ) {
        throw new Exception( "Can't get connection." );
        }  // if( conn==null )

        //Call a procedure with 3 parameters
        CallableStatement cs = conn.prepareCall("{call get_pcode_orderable_state(?,?,?)}");
        String existInOrderableTool   = "";
        Date    pricingToolVisibleDate   ;



    if( listOfMMInfo != null ) {
		Iterator iter = listOfMMInfo.iterator();
		int imageTotal = mmInfoords.size();

		while( iter.hasNext() ) {
			mmInfo = (MarketMatrixInfo) iter.next();
			sku = new java.util.HashMap();
 	  		sku.put("SKUName", mmInfo.getPcodeMain() );
	  		sku.put("ImageName", mmInfo.getImageName());
	  		sku.put("ImageDescription", mmInfo.getProductDesc() );
                  	sku.put("PDTOwner", mmInfo.getPDTContactList() );
           	        sku.put("PlatformPMOwner", mmInfo.getProgramManagerList() );
                        cs.setString(1, mmInfo.getPcodeMain());
                        cs.registerOutParameter(2, Types.VARCHAR);
                        cs.registerOutParameter(3, Types.DATE);
                        cs.execute();
                        existInOrderableTool   = cs.getString(2);
                        pricingToolVisibleDate = cs.getDate(3); 
                        //System.out.println("existInOrderableTool   "+existInOrderableTool);
                        //System.out.println("pricingToolVisibleDate   "+pricingToolVisibleDate);
           	        //sku.put("Date SKU orderable", existInOrderableTool );
           	        sku.put("InOrderableTool", existInOrderableTool );
           	        sku.put("DateSKUvisibleonpricelist", pricingToolVisibleDate);
			skus.add(sku);
                      if(mmInfo.getPcodeSpare() != null && ! "".equals(mmInfo.getPcodeSpare()) ) { 
			sku = new java.util.HashMap();
 	  		sku.put("SKUName", mmInfo.getPcodeSpare() );
	  		sku.put("ImageName", mmInfo.getImageName());
	  		sku.put("ImageDescription", mmInfo.getProductDesc() );
                  	sku.put("PDTOwner", mmInfo.getPDTContactList() );
           	        sku.put("PlatformPMOwner", mmInfo.getProgramManagerList() );
                        cs.setString(1, mmInfo.getPcodeSpare());
                        cs.registerOutParameter(2, Types.VARCHAR);
                        cs.registerOutParameter(3, Types.DATE);
                        cs.execute();
                        existInOrderableTool   = cs.getString(2);
                        pricingToolVisibleDate = cs.getDate(3); 
                        //System.out.println("existInOrderableTool   "+existInOrderableTool);
                        //System.out.println("pricingToolVisibleDate   "+pricingToolVisibleDate);
           	        //sku.put("Date SKU orderable", existInOrderableTool );
           	        sku.put("InOrderableTool", existInOrderableTool );
           	        sku.put("DateSKUvisibleonpricelist", pricingToolVisibleDate);
           	        //sku.put("Date SKU orderable", "***");
           	        //sku.put("Date SKU visible on price list", "***");
			skus.add(sku);
                      } //end of sparepcde record
		} //end of while loop
	}

request.setAttribute("pres",  skus );
%>
 	<ec:table
 	       items="pres" 
           action="./ImageOrderableReport.jsp"
           imagePath="../gfx/extremecomponent/orderable/*.gif"
 		   view="compact"
           title="" width="100%"
           rowsDisplayed="15">
    <ec:exportPdf
        fileName="imageorderablereport.pdf"
        tooltip="Export PDF"
        headerColor="black"
        headerBackgroundColor="#b6c2da"
        headerTitle="Image Orderable Report" />
	<ec:exportXls
		   view="xls"
    	   fileName="imageorderablereport.xls"
           tooltip="Export Excel" />
	<ec:exportCsv 
 	   fileName="imageorderablereport.txt" 
 	   tooltip="Export CSV" 
 	   delimiter=","/>
                         
     	<ec:row highlightRow="true">

    
           	<ec:column property="SKUName" />
            <ec:column property="ImageName" />
            <ec:column property="ImageDescription"  />
           	<ec:column property="PDTOwner"  />
            <ec:column property="PlatformPMOwner"  />
           	<ec:column property="InOrderableTool"  />
            <ec:column property="DateSKUvisibleonpricelist"   />
      	</ec:row>
   	</ec:table>

<br />
</center>


  

<%= Footer.pageFooter(globals) %>
<!-- end -->
