--Copyright (c) 2006 by Cisco Systems, Inc.
/****************************************************
Following fields are added for Hidden CCO requirement
*****************************************************/

ALTER TABLE CSPR_IMAGE_POSTING_STATUS ADD EXPIRY_DATE DATE ;

ALTER TABLE CSPR_IMAGE_POSTING_STATUS ADD CCO_DOWNLOAD_URL VARCHAR2(4000) ;


