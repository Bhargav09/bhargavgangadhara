<!--.........................................................................
: DESCRIPTION:
:     Hidden Post Expiration Notification format
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2006 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="java.io.*, com.cisco.eit.sprit.util.*" %>
<html>
<body>

<br> The following Hidden post Release is going to expire on <%=request.getParameter("ExpirationDate")%> <br>
<ul>
    <li>
    	<%=request.getParameter("ReleaseNumber")%>
	</li>
</ul>

<br>
<br>
Thanks
<br>

</body>
</html>
