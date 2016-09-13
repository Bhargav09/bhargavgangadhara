<%@ page import="com.cisco.eit.sprit.xml.CreateEditImageRequestParser" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CreateEditImageRequestObj" %>

<%
  out.println("start");
  out.println("<br>");

  // -----------------------------------------------------------------------------
  // For this test, copy editImageSampleRequest.xml under WEB-INF location
  // as below:
  // cp service/xml/editImageSampleRequest.xml WEB-INF/classes/com/cisco/eit/sprit/xml
  //
  //-------------------------------------------------------------------------------

  CreateEditImageRequestParser parser =
    new CreateEditImageRequestParser("test",
      "./editImageSampleRequest.xml");

  CreateEditImageRequestObj reqObj = parser.getRequestObject();

  // Uncomment below line to test printing empty object.
  //reqObj = new CreateEditImageRequestObj();

  out.println("RequestObject object attributes:<br>" + 
      reqObj.getObjectAttributes("html"));
  out.println("<br>");
  out.println("Done");
%>

