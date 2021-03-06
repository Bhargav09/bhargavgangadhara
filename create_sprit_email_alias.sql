--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE SPRIT_EMAIL_ALIAS_SEQ;
 
DROP TABLE SPRIT_EMAIL_ALIAS CASCADE CONSTRAINTS;

CREATE TABLE SPRIT_EMAIL_ALIAS(
SPRIT_EMAIL_ALIAS_ID  NUMBER         NOT NULL,
OS_TYPE_ID            NUMBER             NULL,
ACTIVITY_NAME         VARCHAR2(100)  NOT NULL,
ENVIRONMENT           VARCHAR2(20)   NOT NULL,
EMAIL_ALIAS           VARCHAR2(100)  NOT NULL,
CREATED_BY            VARCHAR2 (8)   NOT NULL,
CREATED_DATE          DATE           NOT NULL,
ADM_USERID            VARCHAR2 (8)   NOT NULL,
ADM_TIMESTAMP         DATE           NOT NULL,
ADM_FLAG              CHAR (1)       NOT NULL,
ADM_COMMENT           VARCHAR2 (100)      NULL
);
 
CREATE SEQUENCE SPRIT_EMAIL_ALIAS_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
 
ALTER TABLE SPRIT_EMAIL_ALIAS
ADD CONSTRAINT PK_SPRIT_EMAIL_ALIAS
PRIMARY KEY (SPRIT_EMAIL_ALIAS_ID);
 
ALTER TABLE SPRIT_EMAIL_ALIAS
ADD ( CONSTRAINT FK_SPRIT_EMAIL_ALIAS_OS_TYPE
      FOREIGN KEY (OS_TYPE_ID) 
   REFERENCES SHR_OS_TYPE );