--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE client_name_seq;
CREATE SEQUENCE client_name_seq START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE client_name CASCADE CONSTRAINTS;
CREATE TABLE client_name ( 
  CLIENT_NAME_ID           NUMBER         NOT NULL,
  CLIENT_NAME              VARCHAR2(250)  NOT NULL,
  CREATED_DATE             DATE         NOT NULL,
  CREATED_BY               VARCHAR2(8)  NOT NULL,
  ADM_TIMESTAMP            DATE         NOT NULL, 
  ADM_USERID               VARCHAR2(8)  NOT NULL, 
  ADM_COMMENT              VARCHAR2(50),
  ADM_FLAG                 CHAR (1)     NOT NULL);

ALTER TABLE           client_name
ADD CONSTRAINT        pk_client_name
PRIMARY KEY           (CLIENT_NAME_ID);

ALTER TABLE           client_name
ADD CONSTRAINT        uk_client_name
UNIQUE                (CLIENT_NAME);

