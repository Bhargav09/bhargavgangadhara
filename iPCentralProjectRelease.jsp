<!--.........................................................................
: DESCRIPTION:
: Testing IPcentral project release service
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
:
: Copyright (c) 2003-2008, 2010 by Cisco Systems, Inc.^
: All rights reserved.
:.........................................................................-->


<%@ page import="org.apache.axis.client.Call" %>
<%@ page import="org.apache.axis.client.Service" %>
<%@ page import="org.apache.axis.encoding.XMLType" %>
<%@ page import="org.apache.axis.utils.Options" %>

<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%

  //--------------------------------------------------------------
  //  CHANGE ONLY THIS SECTION
  //-------------------------------------------------------------

  String endpoint = "http://wwwin-bhtrived-dev.cisco.com/sprit/service/axis/WebService";
  //String operation= "requestStatus";
  String operation= "iPCentralProjectRelease";
  String xmlLoc = "/auto/eit-tools/apps/bhtrived/sprit/web/jsp/test/xml/";
  String filename = "iPCentralProjectReleaseRequest-1.xml";

  //--------------------------------------------------------------
  //  DO NOT CHANGE ANY THING BELOW
  //-------------------------------------------------------------

  out.println("start");
  out.println("<br>");

  Service service = new Service();
  Call    call    = (Call) service.createCall();

  call.setTargetEndpointAddress(new java.net.URL(endpoint));
  call.setOperationName(new javax.xml.namespace.QName("urn:sprit", operation));

  String in0 = SpritUtility.readFile(xmlLoc + filename);

  String ret = (String) call.invoke(new Object[] {in0});

  out.println("printing response xml to console");
  System.out.println(ret); 
  out.println("<br>");

  out.println("Done");
%>


