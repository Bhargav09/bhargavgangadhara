--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE webservice_request_seq;
CREATE SEQUENCE webservice_request_seq START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE webservice_request CASCADE CONSTRAINTS;
CREATE TABLE webservice_request ( 
  SPRIT_REQUEST_ID         NUMBER       NOT NULL,
  REQUEST_TYPE_ID          NUMBER       NOT NULL,
  REQUEST_XML              CLOB         NOT NULL,
  RESPONSE_XML             CLOB,
  CREATED_DATE             DATE         NOT NULL,
  CREATED_BY               VARCHAR2(16)  NOT NULL,
  ADM_TIMESTAMP            DATE         NOT NULL, 
  ADM_USERID               VARCHAR2(8)  NOT NULL, 
  ADM_COMMENT              VARCHAR2(50),
  ADM_FLAG                 CHAR (1)     NOT NULL);

ALTER TABLE           webservice_request
ADD CONSTRAINT        pk_webservice_request
PRIMARY KEY           (SPRIT_REQUEST_ID);

ALTER TABLE           webservice_request
ADD CONSTRAINT        fk_webservice_request
FOREIGN KEY           (REQUEST_TYPE_ID)
REFERENCES            webservice_request_type(REQUEST_TYPE_ID);

