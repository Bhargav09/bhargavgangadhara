-- Copyright (c) 2009 by Cisco Systems, Inc.
/*
 	Current Release - Sprit 7.5.1 
 	Last updated by - holchen
 	Last updated date - May 7, 2009 
 */
 
 /*
 	Set SW retirement type in table sprit_properties
 */
 
 insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE,  
 ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)values(SPRIT_PROPERTIES_SEQ.nextval, 'SWRETIREMENTTYPE', 1, 'SW Retirement Type', 'Regular IOS', 
 'Regular IOS', 'Regular IOS',  sysdate, 'holchen','V', 'manually insert')
 
 
 insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE,  
 ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)values(SPRIT_PROPERTIES_SEQ.nextval, 'SWRETIREMENTTYPE', 2, 'SW Retirement Type', 
 'PSIRT', 'PSIRT', 'PSIRT',  sysdate, 'holchen','V', 'manually insert')
 
 
 insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE,  
 ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)values(SPRIT_PROPERTIES_SEQ.nextval, 'SWRETIREMENTTYPE', 3, 'SW Retirement Type', 
'Digital signature', 'Digital signature', 'Digital signature',  sysdate, 'holchen','V', 'manually insert')