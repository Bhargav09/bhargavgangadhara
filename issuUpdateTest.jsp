<!-- Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc. All rights reserved. -->

<!--
//-------------------------------------------------------------------
// - Webservice test for operation 'issuStateUpdateRequest.
// - sample client code
//
// Author: nadialee
// When:   Sept 2006
//-------------------------------------------------------------------
-->

<%@ page import="org.apache.axis.client.Call" %>
<%@ page import="org.apache.axis.client.Service" %>
<%@ page import="org.apache.axis.encoding.XMLType" %>
<%@ page import="org.apache.axis.utils.Options" %>

<%@ page import="java.io.*" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.FileNotFoundException" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>


<%
out.println(">>>>>>>>> ISSU State Update TEST<<<<<<<<<<<");

out.println("start >>>>>> ");
out.println("<br>");


//BufferedReader  bufreader  = null;
//FileReader      filereader = null;
//String          linebuf;
//StringBuffer    xmldoc;
String          in0;
String          errMsg = "";

try {

    out.println("DEBUG 1 <br> ");


//    in0 = "hi there";

    in0 =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
        "<SpritRequest>" +
        "    <ClientName>ISSU</ClientName>" +
        "    <ClientRequestId>155</ClientRequestId>" +
        "    <Action>IssuStateUpdate</Action>" +
        "    <Release ReleaseNumber=\"12.2(100)SB\">" +
        "        <Image>" +
        "            <ImageName>c10k2-p11u2-mz</ImageName>" +
        "            <IssuState>VER</IssuState>" +
        "        </Image>" +
        "        <Image>" +
        "            <ImageName>xxx</ImageName>" +
        "            <IssuState>ISSU_OFF_YYY</IssuState>" +
        "        </Image>" +
        "    </Release>" +
        "    <SubmittedBy>nadia</SubmittedBy>" +
        "</SpritRequest>" ;

    String endpoint = "http://wwwin-aselvara-dev.cisco.com/sprit/service/axis/WebService";

    Service service = new Service();
    Call    call    = (Call) service.createCall();

    call.setTargetEndpointAddress(new java.net.URL(endpoint));

    call.setOperationName(new javax.xml.namespace.QName("urn:sprit", "issuStateUpdateRequest"));


    String ret = (String) call.invoke(new Object[] {in0});

    //  out.println("jsp: DEBUG 4 <br>");

    out.println(ret);

    out.println("<br>");

    out.println("Done >>>>>>");

} catch( Exception e ) {
    errMsg = "ERROR: " + e.toString();
    out.println(errMsg);

} // finally
%>
