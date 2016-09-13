-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: Add a record to RESPONSE_METADATA. 
--
-- Created by :   nadialee 
-- Created at:    Sept 2006  
-------------------------------------------------------------------

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 0 , 'SPRIT', 'Info', 'Request is successfully processed in SPRIT.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12001 , 'SPRIT', 'Error', 'No such release number exists in SPRIT.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12002 , 'SPRIT', 'Error', 'No such image exists in SPRIT.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12003 , 'SPRIT', 'Error', 'No such ISSU state exists in SPRIT.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12004 , 'SPRIT', 'Error', 'No such image ID found in SHR_IMAGE_ISSU_STATE table in SPRIT . SPRIT admin notified via email.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12005 , 'SPRIT', 'Error', 'ISSU state update Transaction failed. SPRIT admin notified via email.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into RESPONSE_METADATA
values ( RESPONSE_METADATA_SEQ.nextval, 12006 , 'SPRIT', 'Error', 'No such ISSU capable image found.', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

commit;
