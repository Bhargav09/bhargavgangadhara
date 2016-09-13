<!--.........................................................................
// Copyright (c) 2008 by Cisco Systems, Inc.
.........................................................................--!>

<%@ page import="java.io.*" %>
<%@ page import="com.cisco.eit.sprit.util.*" %>

<style type="text/css">
table.tlook {
    border-width: 1px 1px 1px 1px;
    border-spacing: 2px;
    border-style: solid solid solid solid;
    border-color: gray gray gray gray;
    border-collapse: collapse;
    background-color: white;
}
table.tlook th {
    border-width: 1px 1px 1px 1px;
    padding: 1px 1px 1px 1px;
    border-style: inset inset inset inset;
    border-color: gray gray gray gray;
    background-color: white;
    -moz-border-radius: 0px 0px 0px 0px;
}
table.tlook td {
    border-width: 1px 1px 1px 1px;
    padding: 1px 1px 1px 1px;
    border-style: inset inset inset inset;
    border-color: gray gray gray gray;
    background-color: white;
    -moz-border-radius: 0px 0px 0px 0px;
}
</style>
<html>
<body>

<br>
<br><b>SPRIT found the following releases have "Dvd Major Release mdf" - Please fix it ASAP. </b><br><br><br>
<%=request.getParameter("DvdMajorReleaseInfo")%>
    <br><br>
Thanks
<br>


</body>
</html>
