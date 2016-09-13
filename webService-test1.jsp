<!--
.........................................................................
: DESCRIPTION:
: Web service tesing page
:
: 
: AUTHORS:
: @modified by Holly Chen (holchen@cisco.com)
: Add stagin endpoint and operations under "CHANGE ONLY THIS SECTION"
: Copyright (c) 2007-2008, 2010, 2012 by Cisco Systems, Inc.
:.........................................................................
-->
<%@ page import="org.apache.axis.client.Call" %>
<%@ page import="org.apache.axis.client.Service" %>
<%@ page import="org.apache.axis.encoding.XMLType" %>
<%@ page import="org.apache.axis.utils.Options" %>

<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%

  //--------------------------------------------------------------
  //  CHANGE ONLY THIS SECTION
  //-------------------------------------------------------------
    
  //developer's PC, point to your own PC, chnange the port number to yours
  //String endpoint = "http://creeper:10006/sprit/service/axis/WebService";
  //String endpoint = "http://creeper:8606/sprit/service/axis/WebService";
  
  //Sprit staging
  String endpoint = "http://wwwin-hdonepud-dev.cisco.com/sprit/service/axis/WebService";
  
  //Opeartion, only one operation for each test
  String operation= "createImageInSprit";
  //put your own test file, only one file each test
  String filename = "createImage-test-2.xml";
  
  
  
  //For edit Image 
  //String operation= "EditImageInSprit";
  //String filename = "editImage-test-2.xml";
  
  //For delete Image  
  //String operation= "DeleteImageInSprit";
  
  //for posting image
   //String operation= "ccoPostImage";
   //String filename = "postImage-test.xml";
   
   
   //testing for Dave
   //String filename = "DaveTest.xml";
  
   //for reposting image
   //String operation= "ccoRepostImage";
   //String filename = "repostImage-test.xml";
   
  
  
  
  
 
  

  //--------------------------------------------------------------
  //  DO NOT CHANGE ANY THING BELOW
  //-------------------------------------------------------------

  out.println("start");
  out.println("<br>");

  Service service = new Service();
  Call    call    = (Call) service.createCall();

  call.setTargetEndpointAddress(new java.net.URL(endpoint));
  call.setOperationName(new javax.xml.namespace.QName("urn:sprit", operation));

  String in0 = 
    SpritUtility.readFile(application.getRealPath("/web/jsp/test/xml/" + filename));

  String ret = (String) call.invoke(new Object[] {in0});

  out.println("printing response xml to console");
  System.out.println(ret); 
  out.println("<br>");

  out.println("Done");
%>

