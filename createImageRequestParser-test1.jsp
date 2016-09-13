<%@ page import="com.cisco.eit.sprit.xml.CreateEditImageRequestParser" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CreateEditImageRequestObj" %>

<%
  out.println("start");
  out.println("<br>");

  // -----------------------------------------------------------------------------
  // For this test, copy createImageSampleRequest.xml under WEB-INF location
  // as below:
  // cp service/xml/createImageSampleRequest.xml WEB-INF/classes/com/cisco/eit/sprit/xml
  //
  //-------------------------------------------------------------------------------

  CreateEditImageRequestParser parser =
    new CreateEditImageRequestParser("test",
      "./createImageSampleRequest.xml");

  CreateEditImageRequestObj reqObj = parser.getRequestObject();

  out.println("RequestObject object attributes:<br>" + 
      reqObj.getObjectAttributes("html"));
  out.println("<br>");

  out.println("Done");
%>

