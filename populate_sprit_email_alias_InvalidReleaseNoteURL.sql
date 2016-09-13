/*
	Copyright (c) 2008 by Cisco Systems, Inc.
	Populate SPRIT_EMAIL_ALIAS table for Sprit 7.3.1 CSCsr29014 - Validate Release/Product Notes URL	
*/

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'InvalidReleaseNoteURL','dev', 'sprit-cron-job-notification@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');
insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'InvalidReleaseNoteURL','test', 'sprit-cron-job-notification@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');
insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'InvalidReleaseNoteURL','prod', 'sprit-cron-job-notification@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');    

commit;