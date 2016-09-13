/*
	Copyright (c) 2008 by Cisco Systems, Inc.
	Populate SPRIT_EMAIL_ALIAS table for Sprit 7.3 CSCso81716 - Sprit OPUS submission should handle BOM part number missing	
*/

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'OpusMissingBOMComponetPartNo','dev', 'sprit-notification-test@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'OpusMissingBOMComponetPartNo','test', 'sprit-notification-test@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'OpusMissingBOMComponetPartNo','prod', 'sprit-notification@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
                       values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'OpusMissingBOMComponetPartNo','prod', 'swnpi@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

commit;