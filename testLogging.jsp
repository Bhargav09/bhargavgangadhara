<%@ page import="com.cisco.eit.sprit.util.logging.*" %>
<%@ page import="com.cisco.eit.sprit.model.beans.*" %>
<%@ page import="com.cisco.eit.sprit.utils.*" %>
<%@ page import="com.cisco.eit.sprit.beans.*" %>

<%@ page import="java.io.*" %>
<%
  AutoPublishReleaseQueue autoPublishReleaseQueue = new AutoPublishReleaseQueue();
                            autoPublishReleaseQueue.setReleaseNumberId(new Integer(7822));
                            autoPublishReleaseQueue.setReleaseNumber("2.0.Test");
                            autoPublishReleaseQueue.setPredTransactionId(new Integer(6153));
                            autoPublishReleaseQueue.setOsTypeId(new Integer(17));
                            autoPublishReleaseQueue.setCreatedBy("srajucha");
                            autoPublishReleaseQueue.setAdmUserId("srajucha");
                        autoPublishReleaseQueue.setCcoTransactionType("Repost");
                        autoPublishReleaseQueue.setAdmComment("RePost Test");
                        autoPublishReleaseQueue.setRequestedSource("DocPublish");

  autoPublishReleaseQueue.addImage(new AutoPublishImageQueue(
            new AutoPublishImageQueuePK(null, new Integer(1111)), 
                                                "Raju - Test Image" , 
                                                 "sraju"));
  autoPublishReleaseQueue.addImage(new AutoPublishImageQueue(
            new AutoPublishImageQueuePK(null, new Integer(2222)), 
                                                "Raju - Test Image2" , 
                                                 "sraju"));
  SpritDaoFactory.getAutoPublishReleaseQueueDAO().create(autoPublishReleaseQueue);
/*
  out.println("start");
  out.println("<br>");
    Logger         logger   = Logger.getLogger("com.cisco.eit.sprit.util.logging.SpritLogging");
      FileHandler    file     = null;
    try {   
            file = new FileHandler("/users/vpalani/SpritLog.log");
            
        } catch(IOException ioe) {
            out.println("Could not create a file...");
        }
  Formatter fs =  new java.util.logging.SimpleFormatter();
  file.setFormatter(fs);
  logger.addHandler(file);
  logger.info("Try New Message");  
  logger.warning("Try New warning Message");    
  logger.severe(" Severe Message ");
   
  out.println("<br>");
*/
  out.println("Done");
%>


