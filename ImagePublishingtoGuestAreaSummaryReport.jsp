<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.Connection, com.cisco.eit.sprit.logic.imgGuestPublishSummaryNotify.*" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="javax.jms.*, javax.naming.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.cisco.eit.sprit.gui.*, com.cisco.eit.sprit.utils.email.*,com.cisco.rtim.util.*,  com.cisco.eit.db.*, com.cisco.eit.sprit.utils.email.*,com.cisco.eit.sprit.util.*,com.cisco.eit.sprit.model.dao.imgGuestPubSummary.*,com.cisco.eit.sprit.dataobject.*" %>
<%@ page import="javax.mail.Multipart" %>
<%@ page import="javax.mail.Transport" %>
<%@ page import="javax.mail.internet.InternetAddress" %>
<%@ page import="javax.mail.internet.MimeBodyPart" %>
<%@ page import="javax.mail.internet.MimeMessage" %>
<%@ page import="javax.mail.internet.MimeMultipart" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
Connection con=null;
try{
 Class.forName("oracle.jdbc.OracleDriver");
 con=DriverManager.getConnection("jdbc:oracle:thin:@willow.cisco.com:1521:PRODRTIM","shr_rda","shr_rda");
 String outData=sendSummaryEmail(con);
 out.println("SMTP host-->"+getSmtpHost()+"<br>");
 out.println(outData);
 
}catch(SQLException e){
	out.println(e.toString());
}finally{
	try{		
	 if(con!=null) con.close();
	 //out.println("CON Closed..");
	}catch(Exception e1){}
		
}	
%>
<%!
public Map getOsTypeImagesMap(java.sql.Connection con) throws SQLException{
		
		//String sql = DbQueryLoader.getInstance().getQuery("imgGuestPubSummary.xml","getImageGuestPubSummary");
		//Object[] parameters = new Object[]{imageId, migrationPath};
		//List rows = jdbcTemplate.queryForList(sql, parameters);
         
		Statement st=con.createStatement();
        ResultSet rs=st.executeQuery(sql1);
         
         
		Map osTypeImagesMap = new HashMap();

		//List rows = jdbcTemplate.queryForList(sql);
		
		//Iterator it = rows.iterator();
		while(rs.next()) {
			//Map resultMap = (Map)it.next();
       String release_number=rs.getString("release_number");
       String image_name=rs.getString("image_name");
       String cdc_access_level_name=rs.getString("cdc_access_level_name");
       String created_by=rs.getString("created_by");
       String created_date=rs.getString("created_date");
       
			GuestAreaImagePubVo vo = new GuestAreaImagePubVo();
			vo.setReleaseNumber(release_number!=null? release_number:"");
			vo.setImageName(image_name!=null? image_name:"");
			vo.setAccessLevel(cdc_access_level_name!=null?	cdc_access_level_name:"");
			vo.setCreatedBy(created_by!=null? created_by:"");
			vo.setCreateDate(created_date!=null? created_date:"");

			String osTypeId = rs.getString("os_type_id");

			 if(osTypeImagesMap.get(osTypeId)!=null)
				  ((Set)(osTypeImagesMap.get(osTypeId))).add(vo);

			  else {
				  Set imageSet = new HashSet();
				  imageSet.add(vo);
				  osTypeImagesMap.put(osTypeId, imageSet);
			  }
		}
		rs.close();
		st.close();
		
		return osTypeImagesMap;
	}
%>
<%!
public String sendSummaryEmail(java.sql.Connection con){
	try {
		String emailTo = "sprit-notification-test,hdonepud,smitkrister,";
		
		//String emailTo = "hdonepud";
		
		String emailSubject = "Image Publishing to Guest Area Summary Report";
		String emailContentType = "text/html";
		boolean footerRequired = true;
		StringBuffer message = new StringBuffer();
		
		StringBuffer summaryMessage = new StringBuffer();
		//ImgGuestPubSummaryDAO dao = (ImgGuestPubSummaryDAO)SpringUtil.getApplicationContext().getBean("imgGuestPubSummaryDAO");
		
		//ostypeId, imageSet map
		Map ostypeIdImageSetMap = getOsTypeImagesMap(con);
		Iterator it = ostypeIdImageSetMap.entrySet().iterator();
		
		if(!it.hasNext())
			return "";
		//for email to address
		Set emailToSet = new HashSet();
		StringBuffer emailToSbf = new StringBuffer();
		while (it.hasNext()){
			Map.Entry entry = (Map.Entry)it.next();
			String osTypeId = (String)entry.getKey(); // osTypeId
			
			List osTypeAndApproverList = getApproverInfo(con,osTypeId);
			
			for (int i=0; i<osTypeAndApproverList.size(); i++){
				GuestAreaImagePubVo vo = (GuestAreaImagePubVo)osTypeAndApproverList.get(i);
				
				if(i==0){
					message.append("<span style=\"font:bold 14px Arial\"><u>");
					message.append(vo.getSoftwareType());
					message.append(":</u></span><br/><br/>");
					
			   		message.append("<table border=\"1\" width=\"80%\" style=\"font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED \">");
					message.append("<col width=\"20%\"  />");
					message.append("<col width=\"10%\"  />");
					message.append("<col width=\"50%\"  />");
					message.append("<col width=\"20%\"  />");
					
					
					message.append("<tr style=\"font-weight: bold; background-color: #D9D9D9\">");
					message.append("<td>Approver Type</td><td>Approver Id</td>");
					message.append("<td>Approver Comments</td><td>Approval Date</td>");
					message.append("</tr>");						
				}

				message.append("<tr style=\"text-align: left\"><td>");
				message.append(vo.getapporverType());
				message.append("</td>" );
				message.append("<td>");
				message.append(vo.getapporverId());
				message.append("</td>" );
				message.append("<td>");
				message.append(vo.getApprovalComment());
				message.append("</td>" );
				message.append("<td>");
				message.append(vo.getApprovalDate());
				message.append("</td></tr>");
				
				if(!"BU Manager".equalsIgnoreCase(vo.getapporverType()))
					emailToSet.add(vo.getapporverId());
		    }
			
			if(osTypeAndApproverList.size() > 0)
				message.append("</table><br/>");
	   		
				Set imageSet = (HashSet)entry.getValue();
		   	Iterator imageSetIterator = imageSet.iterator();
		   	
		   	if(imageSetIterator.hasNext()){
		   		message.append("<table border=\"1\" width=\"80%\" style=\"font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED \">");
				message.append("<col width=\"15%\"  />");
				message.append("<col width=\"35%\"  />");
				message.append("<col width=\"15%\"  />");
				message.append("<col width=\"15%\"  />");
				message.append("<col width=\"20%\"  />");
				
				
				message.append("<tr style=\"font-weight: bold; background-color: #D9D9D9\">");
				message.append("<td> Release Number</td><td>Image Name</td><td>Access Level</td>");
				message.append("<td>Created By</td><td>Created Date</td>");
				message.append("</tr>");
		   		
			   	while (imageSetIterator.hasNext()){
				   	GuestAreaImagePubVo imageInfoVo = (GuestAreaImagePubVo)imageSetIterator.next();
					message.append("<tr style=\"text-align: left\"><td>");
					message.append(imageInfoVo.getReleaseNumber());
					message.append("</td>" );
					message.append("<td>");
					message.append(imageInfoVo.getImageName());
					message.append("</td>" );
					message.append("<td>");
					message.append(imageInfoVo.getAccessLevel());
					message.append("</td>" );
					message.append("<td>");
					message.append(imageInfoVo.getCreatedBy());
					message.append("</td>" );
					message.append("<td>");
					message.append(imageInfoVo.getCreateDate());
					message.append("</td></tr>");
				}
			   	
		   		message.append("</table><br><br>");
		   	}
			
			//send to each software type approver
		   	summaryMessage.append(message);
			//sendMail("Image publishing to Guest Area", SpritUtility.convertToArray(emailTo,","), emailSubject, message, emailContentType, footerRequired);
			message.delete(0,message.length());
		//}
	}//end while
	
	//send summary report	
	Iterator emailSetIt = emailToSet.iterator();  
	while(emailSetIt.hasNext()){
			emailToSbf.append(emailSetIt.next().toString());
			emailToSbf.append(",");
	}

	//if( "prod".equalsIgnoreCase(System.getProperty("envMode")))	
		emailTo = "cdo_fin_ops, sprit-notification, " + emailToSbf.toString();
	
	sendMail("Image publishing to Guest Area", SpritUtility.convertToArray(emailTo,","), emailSubject, summaryMessage, emailContentType, footerRequired);
	//String arr[]={"hdonepud","hdonepud"};
	//Mailer.sendMail("Image publishing to Guest Area", arr, emailSubject, summaryMessage, emailContentType, footerRequired);
		
	return summaryMessage.toString();
	
	
	} catch (Exception e) {
		System.out.println("Error while sending email: " + e.getMessage());
		//out.println(e.getMessage());
		return "null";
	}
}

public  List getApproverInfo(Connection con,String osTypeId){
	List imgGuestPubSummaryList = new ArrayList();
try{
	
	//System.out.println("osTypeId--->"+osTypeId);
	//String sql = DbQueryLoader.getInstance().getQuery("imgGuestPubSummary.xml", "getImaGuestPubApproverInfo");
	
	//List rows = jdbcTemplate.queryForList(sql, new Object[]{Integer.valueOf(osTypeId)});
	//Iterator it = rows.iterator();
     PreparedStatement ps=con.prepareStatement(sql2);
     
     ps.setInt(1,Integer.valueOf(osTypeId).intValue());
     ResultSet rs=ps.executeQuery();
     
	while(rs.next()) {
		
		String os_type_name=rs.getString("os_type_name");
		String approver_type=rs.getString("approver_type");
		String approver_id=rs.getString("approver_id");
		String approval_comment=rs.getString("approval_comment");
		String approval_date=rs.getString("approval_date");
		
		GuestAreaImagePubVo vo = new GuestAreaImagePubVo();
		vo.setSoftwareType(os_type_name !=null? os_type_name :"");
		vo.setapporverType(approver_type !=null? approver_type :"");
		vo.setapporverId(approver_id !=null? approver_id :"");
		vo.setApprovalComment(approval_comment !=null?	approval_comment :"");
		vo.setApprovalDate(approval_date !=null? approval_date :"");

		imgGuestPubSummaryList.add(vo);
	}
	rs.close();
	ps.close();
  }catch(SQLException e){
	  System.out.println(e);
  }catch(Exception e){
	  System.out.println(e);
  }
  
	return 	imgGuestPubSummaryList;
}

String sql1="  select    sot.os_type_id,    release_number,    ci.image_name,   cyil.created_date,  cyil.created_by,   cal.cdc_access_level_name "+
  " from  cspr_ypublish_trans_log cytl, cspr_ypublish_image_log cyil,shr_os_type sot,cspr_image ci,cspr_cdc_access_level cal,cspr_access_level_approval ap "+
  " where transaction_type = 'Post' and "+ 
  //" cytl.created_date > sysdate- 30 "+
  " to_char(cytl.created_date,'MON-YY')='MAR-14'"+ 
  " and ( metadata_xml like '%<AccessLevel>Guest Registered</AccessLevel>%' OR  metadata_xml like '%<AccessLevel>Anonymous</AccessLevel>%' )"+ 
 " and cytl.transaction_id = cyil.transaction_id and sot.os_type_id = cyil.os_type_id and cytl.os_type_id != 1"+
 " and ypublish_status_log = 'Published' and ci.cdc_access_level_id = cal.cdc_access_level_id and ci.cdc_access_level_id in (0, 1)"+
 " and ci.image_id = cyil.image_id and ap.OS_TYPE_ID = sot.os_type_id and cytl.adm_flag='V'"+
 " and cyil.adm_flag='V' and sot.adm_flag='V' and ci.adm_flag='V'"+
 " group by  sot.os_type_id,    os_type_name,    release_number,    ci.image_name,   cyil.created_date,    cyil.created_by ,    cal.cdc_access_level_name"+
 " union all "+ 
 " select   sot.os_type_id,   release_number,   ci.image_name,   cyil.created_date,   cyil.created_by,    cal.cdc_access_level_name "+
 " from cspr_ypublish_trans_log cytl, cspr_ypublish_image_log cyil, shr_os_type sot, shr_image ci, cspr_cdc_access_level cal, cspr_access_level_approval ap"+
 " where transaction_type = 'Post' and "+
 //" cytl.created_date > sysdate- 30 "+
 " to_char(cytl.created_date,'MON-YY')='MAR-14'"+
 " and ( metadata_xml like '%<AccessLevel>Guest Registered</AccessLevel>%' OR  metadata_xml like '%<AccessLevel>Anonymous</AccessLevel>%' )"+
 " and cytl.transaction_id = cyil.transaction_id and sot.os_type_id = cyil.os_type_id and cytl.os_type_id = 1"+
 " and ap.os_type_id = sot.os_type_id  and ypublish_status_log = 'Published' and ci.cdc_access_level_id = cal.cdc_access_level_id and ci.cdc_access_level_id in (0, 1)"+
 " and ci.image_id = cyil.image_id and cytl.adm_flag='V' and cyil.adm_flag='V' and sot.adm_flag='V' and ci.adm_flag='V' "+
 " group by  sot.os_type_id,  os_type_name,   release_number,   ci.image_name,   cyil.created_date,  cyil.created_by ,    cal.cdc_access_level_name"+
 " order by 1"; 
 
 String sql2=" 	select		os_type_name,		approver_type,		approver_id,	approval_comment,        approval_date"+
             "    from           cspr_access_level_approval ap,          shr_os_type sot "+
             " where    	ap.os_type_id = ?           	and sot.OS_TYPE_ID = ap.OS_TYPE_ID 	and ap.approval_date  > to_date('01-12-2009','mm-dd-yyyy') 	and ap.adm_flag='V'"+
              " and sot.adm_flag='V'";



 public  void sendMail(String from, String recipients[], String subject, StringBuffer messageBody, String strContentType,  boolean bFooterRequired) {
    int recipientsIdx;
    int recipientsNum;

    try {

        // Set the host smtp address
        Properties props =new Properties(); //System.getProperties();
        //System.out.println("SPRIT SMTP Mailer.java ="+getSmtpHost());
        props.put("mail.smtp.host", getSmtpHost());

        // create some properties and get the default Session
        javax.mail.Session session = javax.mail.Session.getInstance(props, null);

        // create a message
        MimeMessage message = new MimeMessage(session);

        // set the from and to address
        // InternetAddress addressFrom = new InternetAddress(from, "Sprit
        // Notification System"); //use this to default to the user
        InternetAddress addressFrom = new InternetAddress(
                "sprit-notification@cisco.com", "Sprit Notification System");
        message.setFrom(addressFrom);

        // for redirecting and monitoring facilities incase of some failure
        boolean redirect = false;
        if (redirect) {
            for (int j = 0; j < recipients.length; j++) {
                System.out.println("original recipient " + j + " : "
                        + recipients[j]);
            }

            String forwardrecipients[] = { "hdonepud","smitkrister" };
            //recipients = forwardrecipients;
            for (int k = 0; k < recipients.length; k++) {
                System.out.println("redirect recipient " + k + " : "
                        + recipients[k]);
            }

        }

        // Make sure we have someone to mail to!
        if (recipients.length < 1) {
            return;
        } // if( recipients.length<1 )

        // Remove any null or blank recipients from the recipients list.
        // First begin by counting the number of legit recipients. Then
        // allocate the new InternetAddress array, then store legit
        // values into it.
        System.out.println(recipients);
        recipientsNum = 0;
        for (int i = 0; i < recipients.length; i++) {
            if (!StringUtils.nvlOrBlank(recipients[i], "").trim()
                    .equals("")) {
                recipientsNum++;
            } // if( StringUtils.nvlOrBlank(recipients[i],"").equals("") )
        } // for

        // Got anything at all to send?
        if (recipientsNum < 1) {
            return;
        } // if( recipientsNum<1 )

        // Set address array.
        InternetAddress[] addressTo = new InternetAddress[recipientsNum];
        recipientsIdx = 0;
        for (int i = 0; i < recipients.length; i++) {
            if (!StringUtils.nvlOrBlank(recipients[i], "").trim()
                    .equals("")) {
                addressTo[recipientsIdx] = new InternetAddress(
                        recipients[i]);
                System.out.println("recipients["+i+"]"+recipients[i]);
                recipientsIdx++;
            } // if( StringUtils.nvlOrBlank(recipients[i],"").equals("") )
        } // for
        //addressTo[recipientsIdx] = new InternetAddress("hdonepud");
        System.out.println(recipients.length);
        message.setRecipients(javax.mail.Message.RecipientType.TO,
                addressTo);
        System.out.println("1");
        // Setting the Subject and Content Type
        message.setSubject(subject);
        System.out.println("11");
        // Body of the message is set
        if (bFooterRequired) {
        	System.out.println("1Footer");
        	if (strContentType.equals("text/html")) {
				messageBody.append("<HR>");
				messageBody.append("</HR>");
			} else {
				messageBody
						.append("__________________________________________________________________________\n");
			}
        	System.out.println("1contectType");
        	// if the content type is html, then the footer will show the hyperlink with department name
        	String footer="This application created and maintained by <a href=\"http://wwwin-rtim.cisco.com\">Software Information Services</a> (SIS). For support and on call, click <a href=\"http://wwwin-riss.cisco.com/sprit/help/faq.shtml\" target=\"_blank\">here</a>. \n";
        	String footerStr = "This application created and maintained by Software Information Services (SIS) at http://wwwin-rtim.cisco.com . For support and on call, click here http://wwwin-riss.cisco.com/sprit/help/faq.shtml. ";
        	if (strContentType.equals("text/html")) {
        		System.out.println("1text/html");
        		//messageBody.append(Footer.pageFooter(true));
        		messageBody.append(footer);
        		System.out.println("1text/html1");
        	} else {
        		System.out.println("1text/htmlelse");
        		// if the content type is plain, then the footer is not rendering the a href so show the url directly
        		//messageBody.append(Footer.pageFooter(false));
        		messageBody.append(footerStr);
        		System.out.println("1text/htmlelse2");
        	}
        	System.out.println("1<><>>");			
			//Fix for HTML emails
			if (strContentType.equals("text/html")) {
				messageBody.append("</BR>");
			}else{
				messageBody.append("\n");
			}
        } 
        System.out.println("2");
        messageBody.append("Note : This operation has been performed in PROD Environment \n");
        
        MimeBodyPart messageBodyPart = new MimeBodyPart();
        messageBodyPart.setContent(messageBody.toString(), strContentType);
        
        System.out.println("3");
        
        Multipart multipart = new MimeMultipart();

        multipart.addBodyPart(messageBodyPart);
        System.out.println("4");
        
        message.setContent(multipart);

        System.out.println("Sending the message");
        Transport.send(message);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
  String getSmtpHost(){
	String smtpHost=null;
		Collection smptCollection =   SpritUtility.getSpritEmailAliasCollection(null,"SmtpHost","dev");
		if(smptCollection!=null && !smptCollection.isEmpty()){
			Iterator it = smptCollection.iterator();
			while(it.hasNext()){				
				smtpHost = (String)it.next();
				System.out.println("SMTP host-->"+smtpHost);
				break;
			}
		}
	

	return smtpHost;
}
%>
</body>
</html>
