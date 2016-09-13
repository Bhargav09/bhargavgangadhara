--Copyright (c) 2006 by Cisco Systems, Inc.

DROP SEQUENCE response_metadata_seq;
CREATE SEQUENCE response_metadata_seq START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE response_metadata CASCADE CONSTRAINTS;
CREATE TABLE response_metadata ( 
  RESPONSE_METADATA_ID     NUMBER          NOT NULL,
  RESPONSE_CODE            VARCHAR2(16)    NOT NULL,
  RESPONSE_SOURCE          VARCHAR2(16)    NOT NULL,    -- SPRIT | Ypublish
  RESPONSE_TYPE            VARCHAR2(8)     NOT NULL,    -- Info  | Error
  RESPONSE_DESCRIPTION     VARCHAR2(2000)  NOT NULL,
  CREATED_DATE             DATE            NOT NULL,
  CREATED_BY               VARCHAR2(8)     NOT NULL,
  ADM_TIMESTAMP            DATE            NOT NULL, 
  ADM_USERID               VARCHAR2(8)     NOT NULL, 
  ADM_COMMENT              VARCHAR2(50),
  ADM_FLAG                 CHAR (1)        NOT NULL);

ALTER TABLE           response_metadata
ADD CONSTRAINT        pk_response_metadata
PRIMARY KEY           (RESPONSE_METADATA_ID);

ALTER TABLE           response_metadata
ADD CONSTRAINT        uk_response_metadata
UNIQUE                (RESPONSE_CODE,RESPONSE_SOURCE,RESPONSE_TYPE);

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10200',
        'SPRIT',
        'Error',
        'Error while validating request-xml against the schema. This validation can return multiple errors and/or warnings',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10201',
        'SPRIT',
        'Error',
        'Error while validating a value in request-xml against the database',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10300',
        'SPRIT',
        'Error',
        'Duplicate request. A request already exists in the system for the ClientName and ClientRequestId specified in the request-xml',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');


INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10500',
        'SPRIT',
        'Error',
        'A Problem with the metadata for an image has been found. This error message is caused when the XML transaction is being processed into individual elements. This error could be caused by duplicate information or missing information, that the schema did not pick up. This message is at an image level rather than the whole transaction.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10501',
        'SPRIT',
        'Error',
        'Duplicate image encountered. SPRIT encountered data already in the database with the same name as this image. Duplicate images are not allowed and this message indicates this scenario was encountered.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10600',
        'SPRIT',
        'Error',
        'Image Missing in the specified source location.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10700',
        'SPRIT',
        'Info',
        'SPRIT received your request. SPRIT is contacting Ypublish to complete the transaction. Ypublish will process your request and updates the planner. Later, please submit a SPRIT webservice status request to know the updated status for this request.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10800',
        'SPRIT',
        'Info',
        'Ypublish Accepted the transaction.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10801',
        'SPRIT',
        'Error',
        'Ypublish Rejected the transaction.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10900',
        'SPRIT',
        'Error',
        'CCO Posted images can not be deleted in SPRIT Database.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '10901',
        'SPRIT',
        'Error',
        'Image does not exist in SPRIT Database to perform SPRIT deletion.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11000',
        'SPRIT',
        'Info',
        'Successful transaction processing has occurred in SPRIT.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11001',
        'SPRIT',
        'Error',
        'Transaction processing failed in SPRIT.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11002',
        'SPRIT',
        'Error',
        'System Error. SPRIT admin notified via email.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11100',
        'SPRIT',
        'Error',
        'CCO Posted images can not be posted again.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11101',
        'SPRIT',
        'Error',
        'CCO Remove can be performed only on the CCO Posted images.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11102',
        'SPRIT',
        'Error',
        'CCO Posted Images can only be CCO Reposted.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '11103',
        'SPRIT',
        'Error',
        'No such Image Id exists in SPRIT.',
        sysdate,
        'susingh',
        sysdate,
        'susingh',
        '',
        'V');
        
        
-- CSCtl23741 Size Validation for Webservices
INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13006',
        'SPRIT',
        'Error',
        'The image size is exceeding 5GB limit.',
        sysdate,
        'spathala',
        sysdate,
        'spathala',
        'Manually inserted',
        'V');   

commit;

