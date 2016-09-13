<%
/*
<!--.........................................................................
: DESCRIPTION:
: CCO Post.
:
: AUTHORS:
: @author Raju (rruddara@cisco.com)
:
: Copyright (c) 2004 by Cisco Systems, Inc.
:.........................................................................-->
*/
%>
<%@ page import="java.util.Properties,
                 com.cisco.eit.sprit.model.cco.UPopulation,
                 java.io.PrintWriter,
                 com.cisco.eit.sprit.model.releasenumbermodel.*,
                 com.cisco.eit.sprit.util.*,
                 com.cisco.eit.sprit.util.SpritUtility,
                 com.cisco.eit.sprit.util.SpritConstants,
                 com.cisco.eit.sprit.util.SpritGlobalInfo,
                 com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="" %>
<%@ page import="" %>
<%@ page import="" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="javax.naming.InitialContext"%>

<%@ page import="com.cisco.eit.sprit.model.pcodegroup.*" %>
<%@ page import="java.util.*" %>

<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  Integer releaseNumberId = null;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
    SpritAccessManager spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
    String user =  spritAccessManager.getUserId(); 

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
//  banner.addReleaseNumberElement( request,"releaseNumberId" );
%>

<%
// Get release number ID.  Try to convert it to an Integer from the web value!
try {
	releaseNumberId = new Integer(
	        WebUtils.getParameter(request,"releaseNumberId"));
} catch( Exception e ) {
}

        if( releaseNumberId==null &&
                SpritUtility.isNullOrEmpty(request.getParameter("releaseNumber"))) {
	// No release number!  Bad!  Redirect to error page.
%>
      <jsp:forward page="ReleaseNoId.jsp" />
<%
}

  // Get release number information.
   ReleaseNumberModelInfo rnmInfo = null;
  try {
    // Setup
    String jndiName = "ejblocal:ReleaseNumberModel.ReleaseNumberModelHome";
    InitialContext ctx = new InitialContext();
    ReleaseNumberModelHomeLocal rnmHome =
    	(ReleaseNumberModelHomeLocal) ctx.lookup(jndiName);
    ReleaseNumberModelLocal rnmObj = rnmHome.create();
    if( !SpritUtility.isNullOrEmpty(request.getParameter("releaseNumber")) ) {
        rnmInfo = rnmObj.getReleaseNumberInfo(request.getParameter("releaseNumber"));
        banner.addReleaseNumberElement( rnmInfo.getReleaseNumberId() );
    }
    else
        rnmInfo = rnmObj.getReleaseNumberInfo( globals, releaseNumberId);

    request.setAttribute("rnmInfo", rnmInfo );
  } catch( Exception e ) {
    throw e;
  }  // catch




    String strFormat = request.getParameter("format");
    short nShort;
    if( "Text".equalsIgnoreCase(strFormat)) {
        nShort = UPopulation.TEXT_FORMAT;
        response.setContentType("text/plain");
    } else if( "Xml".equalsIgnoreCase(strFormat)) {
        nShort = UPopulation.XML_FORMAT;
        response.setContentType("text/plain");
    } else {
        nShort = UPopulation.HTML_FORMAT;
    }

    try {
        UPopulation upop = new UPopulation(rnmInfo, user);
        if( nShort == UPopulation.HTML_FORMAT) {
            Vector listOfHeader = new Vector();
            Vector listOfUpopInfo = new Vector();
            upop.populateUPopulationData(listOfHeader, listOfUpopInfo);

            String strErrorMessage = upop.getErrorMessage(true);
            if(!SpritUtility.isNullOrEmpty(strErrorMessage))
                session.setAttribute("ErrorMessage", strErrorMessage);
            
            session.setAttribute("UpopHeader", listOfHeader);
            session.setAttribute("UpopBody", listOfUpopInfo);
%>
        <jsp:forward page="UPopulationHtml.jsp?releaseNumberId=<%=rnmInfo.getReleaseNumberId()%>"/>
<%        
        } else {
            StringBuffer bufferUPopdata = upop.getUPopulationData(nShort);
            out.println( bufferUPopdata.toString() );
        }

    } catch( Exception e ) {
//        e.printStackTrace( new PrintWriter(out));
        e.printStackTrace();
        if("Html".equalsIgnoreCase(strFormat)) {
            session.setAttribute( "ErrorMessage", e.getMessage());
%>
        <jsp:forward page="UPopulationHtml.jsp?releaseNumberId=<%=rnmInfo.getReleaseNumberId()%>"/>
<%        
        } else 
            response.sendError( 500 ); // internal error.
    }

%>
