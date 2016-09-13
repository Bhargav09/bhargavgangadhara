--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE client_webservice_request_seq;
CREATE SEQUENCE client_webservice_request_seq START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE client_webservice_request CASCADE CONSTRAINTS;
CREATE TABLE client_webservice_request ( 
  CLIENT_WEBSERVICE_REQUEST_ID  NUMBER       NOT NULL,
  CLIENT_REQUEST_ID             NUMBER       NOT NULL,    -- from request xml
  CLIENT_NAME_ID               NUMBER       NOT NULL,    -- from request xml
  SPRIT_REQUEST_ID             NUMBER       NOT NULL,
  CREATED_DATE                 DATE         NOT NULL,
  CREATED_BY                   VARCHAR2(8)  NOT NULL,
  ADM_TIMESTAMP                DATE         NOT NULL, 
  ADM_USERID                   VARCHAR2(8)  NOT NULL, 
  ADM_COMMENT                  VARCHAR2(50),
  ADM_FLAG                     CHAR (1)     NOT NULL);

ALTER TABLE           client_webservice_request
ADD CONSTRAINT        pk_client_webservice_request
PRIMARY KEY           (CLIENT_WEBSERVICE_REQUEST_ID);

ALTER TABLE           client_webservice_request
ADD CONSTRAINT        fk_client_webservice_request
FOREIGN KEY           (SPRIT_REQUEST_ID)
REFERENCES            webservice_request(SPRIT_REQUEST_ID);

ALTER TABLE           client_webservice_request
ADD CONSTRAINT        uk_client_webservice_request
UNIQUE                (CLIENT_REQUEST_ID,CLIENT_NAME_ID);

