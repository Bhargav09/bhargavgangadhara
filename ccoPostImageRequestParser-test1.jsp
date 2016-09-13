<%@ page import="com.cisco.eit.sprit.xml.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.*" %>

<%
  out.println("start");
  out.println("<br>");

  // -----------------------------------------------------------------------------
  // For this test, copy ccoPostImageSampleRequest.xml under WEB-INF location
  // as below:
  // cp service/xml/ccoPostImageSampleRequest.xml WEB-INF/classes/com/cisco/eit/sprit/xml
  //
  //-------------------------------------------------------------------------------

  PostDeleteImageRequestParser parser =
    new PostDeleteImageRequestParser("test",
      "./ccoPostImageSampleRequest.xml");

  PostDeleteImageRequestObj reqObj = parser.loadCustomData();

  out.println("RequestObject object attributes:<br>" +
      reqObj.getObjectAttributes("html"));
  out.println("<br>");

  out.println("Done");
%>


