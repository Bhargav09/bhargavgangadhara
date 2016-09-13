<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004, 2008 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Vector" %>
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
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>

<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import ="javax.rmi.PortableRemoteObject" %>


<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>

<%
  Context ctx = new InitialContext();
  Integer 			releaseNumberId;
  SpritAccessManager 		spritAccessManager;
  SpritGlobalInfo 		globals;
  SpritGUIBanner 		banner;
  String 			jndiName;
  String 			pathGfx;
  String 			releaseNumber = null;
  TableMaker 			tableReleasesYouOwn; 
  Vector 			opusRecords = new Vector();
  CisrommAPI 			cisrommAPI;
  String			htmlNoValue;
  
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  String osTypeId = WebUtils.getParameter(request,"osTypeId");
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
%>
<jsp:useBean id="releaseBean" scope="session" class="com.cisco.eit.sprit.ui.ReleaseBean">
</jsp:useBean>

<% 
String callingForm  = request.getParameter("callingForm") ;
String nextpage = "DemSpecnoPartnoView.jsp";

if (callingForm.equals("demaddspecnoservlet")) {
    int releasenumberid = Integer.parseInt(request.getParameter("releaseNumberId"));
    int myindex = Integer.parseInt(request.getParameter("myindex"));
//    System.out.println("myIndex = " + myindex ) ;
//    System.out.println(releasenumberid);
    String releasename = null;

    try {
    
      Object homeObject = ctx.lookup("partnosession.PartnoSessionHome");
      PartnoSessionHome partnohome = (PartnoSessionHome) 
           PortableRemoteObject.narrow(homeObject, PartnoSessionHome.class);
      PartnoSession ps = partnohome.create();
      
//      System.out.println("in release  bean rnumber" + request.getParameter("releasenumberid"));

      for(int i=0; i< myindex; i++) {   
          String paramplatform = "_"+i+"pfamily";
    	  String parammainpart = "_"+i+"mainnovalue";
    	  String paramsparepart = "_"+i+"sparenovalue";
          String paramlabelseq = "_"+i+"labelseq";
//	  System.out.println("Platform"+ paramplatform);
//	  System.out.println(" param Platform Value" + request.getParameter(paramplatform));
//	  System.out.println("Main value" + request.getParameter(parammainpart));
//          System.out.println("spare value" + request.getParameter(paramsparepart));
//	  System.out.println("Release Number" + request.getParameter("releasenumberid"));
//	  System.out.println("label seq" + request.getParameter(paramlabelseq));

	  int labelseq = Integer.parseInt(request.getParameter(paramlabelseq));
	  int pf = Integer.parseInt(request.getParameter(paramplatform));
	  String mainpartno = request.getParameter(parammainpart);
	  String sparepartno = request.getParameter(paramsparepart);

          ps.addSpecPartno (releasenumberid, labelseq, pf, mainpartno, sparepartno,"N");
      }
   } catch (Exception e) {
      nextpage = "error.jsp";
      System.out.println("in add block of specno");
      e.printStackTrace();
   }

//   System.out.println("Nextpage"+nextpage);
}

response.sendRedirect( nextpage + "?releaseNumberId=" + releaseNumberId + "&osTypeId=" + osTypeId);

%>
