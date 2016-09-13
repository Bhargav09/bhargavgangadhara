<%@ page import="com.cisco.eit.sprit.util.logging.*" %>

<%
  
  out.println("start");
  out.println("<br>");
   //Invoke the following two lines in any of your client code to log
    SpritLogging sl = new SpritLogging();
    sl.logInfoMessage("Test New Log");
        
  out.println("<br>");

  out.println("Done");
%>

