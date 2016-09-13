--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE webservice_request_type_seq;
CREATE SEQUENCE webservice_request_type_seq START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE webservice_request_type CASCADE CONSTRAINTS;
CREATE TABLE webservice_request_type ( 
  REQUEST_TYPE_ID          NUMBER       NOT NULL,
  REQUEST_TYPE_NAME        VARCHAR2(20)  NOT NULL,
  CREATED_DATE             DATE         NOT NULL,
  CREATED_BY               VARCHAR2(8)  NOT NULL,
  ADM_TIMESTAMP            DATE         NOT NULL, 
  ADM_USERID               VARCHAR2(8)  NOT NULL, 
  ADM_COMMENT              VARCHAR2(50),
  ADM_FLAG                 CHAR (1)     NOT NULL);

ALTER TABLE           webservice_request_type
ADD CONSTRAINT        pk_webservice_request_type
PRIMARY KEY           (REQUEST_TYPE_ID);

ALTER TABLE           webservice_request_type
ADD CONSTRAINT        uk_webservice_request_type
UNIQUE                (REQUEST_TYPE_NAME);

INSERT INTO webservice_request_type
VALUES (webservice_request_type_seq.nextval,
        'POST',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'REPOST',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'REMOVE',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'CREATE',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'EDIT',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'DELETE',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'STATUS',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

commit;

