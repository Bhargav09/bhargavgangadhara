<%@ page import="org.apache.axis.client.Call" %>
<%@ page import="org.apache.axis.client.Service" %>
<%@ page import="org.apache.axis.encoding.XMLType" %>
<%@ page import="org.apache.axis.utils.Options" %>

<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%

  //--------------------------------------------------------------
  //  CHANGE ONLY THIS SECTION
  //-------------------------------------------------------------

  String endpoint = "http://wwwin-aselvara-dev.cisco.com/sprit/service/axis/WebService";
  String operation= "ccoPostImage";
  String xmlLoc = "/auto/eit-tools/apps/vpalani/sprit/web/jsp/test/xml/";
  String filename = "repostImage-1.xml";

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


