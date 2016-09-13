<!--.........................................................................
: DESCRIPTION:
: Test page for testing Hidden releases expiry notification function.
:
: AUTHORS:
: @author Sakthivel Annakam [sannakam@cisco.com]
:
: Copyright (c) 2007 Cisco Systems, Inc. All rights reserved.
:.........................................................................-->
<%@ page import="com.cisco.eit.sprit.logic.ypublish.IOSHiddenPostExpiryNotification"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.cisco.eit.sprit.util.*"%>
<%
out.println("Test is Starting\n");
//CAUTION: This is an test page for testing this functionality. Here the value true will be used for deciding
//for testing purpose. Don't use the value false in the below constructor.
IOSHiddenPostExpiryNotification note=new IOSHiddenPostExpiryNotification(true);
note.execute(null);
out.println("Test is successful");

/*Connection conn = SpritDb.jdbcGetConnection();
System.out.println("Conn got");
Statement stat = conn.createStatement();

ResultSet rs = stat.executeQuery("SELECT COUNT(*) FROM MFG_CACHE_OPUS WHERE VERSION='12.4(11)SW' AND IMAGE LIKE 'c2600%'");
System.out.println("Query executed");
while (rs.next()) {
int i=rs.getInt(1);
out.println(i);*
}*/
/*boolean isCCO=true;
boolean isOpus=false;
String status="None";
if(isCCO&&isOpus)
				status="CCO+OPUS Posted";
			else if(!isCCO&&!isOpus)
				status="Not Posted in CCO & OPUS";
			else  if(isCCO)
				status="CCO Posted";
			else 
				status="OPUS Posted";
				out.println(status);
				
				String releaseNumber="12.4(11)SW";
String imageId="something";
String imageName="ImageName";
String CCO_CHECK_SQL="SELECT IS_POSTED_TO_CCO FROM SHR_IMAGE WHERE IMAGE_NAME='"+imageName+"' AND "+"IMAGE_ID='"+imageId+"'";
String OPUS_CHECK_SQL="SELECT COUNT(*) FROM MFG_CACHE_OPUS WHERE VERSION='"+releaseNumber+"' AND IMAGE LIKE '"+imageName+"%'";
out.println(CCO_CHECK_SQL);
out.println(OPUS_CHECK_SQL);*/
	%>
