-------------------------------------------------------------------
-- Copyright (c) 2006-2010 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: Add a record to webservice_request_type table for
--           'ISSU STATE UPDATE' and 'ISSU STATE REPORT'
--           'for IPcentral Project'
--
-- Created by :    Selvaraj Aran(aselvara) 
-- CreatedDate:    08/31/2010
-- LastUpdatedBy : Selvaraj Aran(aselvara)
-- LastUpdatedDate:08/31/2010
-------------------------------------------------------------------
insert into sprit_properties 
(PROPERTY_ID
, PROPERTY_NAME
, PROPERTY_SEQ
, PROPERTY_DESC
, PROD_VALUE
, DEV_VALUE
, TEST_VALUE
, ADM_TIMESTAMP
, ADM_USERID
, ADM_FLAG
, ADM_COMMENT)
values(
   SPRIT_PROPERTIES_SEQ.nextval
 ,'IPCENTRALWEBSERVICEPASSWORD'
 , 1
 , 'This user id is created to log into IP Central system and consume data'
 , 'eAb.4cTg'
 , 'eAb.4cTg'
 , 'eAb.4cTg'
 ,  sysdate
 , 'aselvara'
 , 'V'
 , 'Manually populated'
 );

insert into sprit_properties 
(PROPERTY_ID
, PROPERTY_NAME
, PROPERTY_SEQ
, PROPERTY_DESC
, PROD_VALUE
, DEV_VALUE
, TEST_VALUE
, ADM_TIMESTAMP
, ADM_USERID
, ADM_FLAG
, ADM_COMMENT)
values(
   SPRIT_PROPERTIES_SEQ.nextval
 ,'IPCENTRALWEBSERVICEUSERID'
 , 1
 , 'This user id is created to log into IP Central system and consume data'
 , 'ipcentral.gen'
 , 'ipcentral.gen'
 , 'ipcentral.gen'
 ,  sysdate
 , 'aselvara'
 , 'V'
 , 'Manually populated'
 );

commit;
