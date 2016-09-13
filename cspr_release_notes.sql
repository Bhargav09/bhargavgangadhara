--Copyright (c) 2007-2008 by Cisco Systems, Inc.

ALTER TABLE CSPR_RELEASE_CCO_POST
DROP CONSTRAINT SYS_C0043948;

ALTER TABLE CSPR_RELEASE_CCO_POST
ADD(NEWS_STORY VARCHAR2(4000),
    RELEASE_MESSAGE VARCHAR2(350)
);

ALTER TABLE CSPR_RELEASE_CCO_POST
DISABLE CONSTRAINT FK_RELEASE_NUMBER_ID;

CREATE TABLE CSPR_RELEASE_NOTES (
    RELEASE_NOTE_ID NUMBER,
    CSPR_RELEASE_CCO_POST_ID NUMBER,
    RELEASE_NUMBER_ID NUMBER NOT NULL,
    RELEASE_NOTE_LABEL VARCHAR2(60) NOT NULL,
    RELEASE_NOTE_URL VARCHAR2(1000) NOT NULL,
    CREATED_BY VARCHAR2(8) NOT NULL,
    CREATED_DATE DATE NOT NULL,
    ADM_USERID VARCHAR2(8) NOT NULL,
    ADM_TIMESTAMP DATE NOT NULL,
    ADM_FLAG CHAR(1) NOT NULL,
    ADM_COMMENT VARCHAR2(50)
);

CREATE SEQUENCE CSPR_RELEASE_NOTES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

ALTER TABLE CSPR_RELEASE_NOTES
ADD CONSTRAINT PK_RELEASE_NOTES_ID
PRIMARY KEY(RELEASE_NOTE_ID);

ALTER TABLE CSPR_RELEASE_NOTES
ADD ( CONSTRAINT FK_CSPR_RELEASE_CCO_POST_ID
        FOREIGN KEY(CSPR_RELEASE_CCO_POST_ID)
        REFERENCES CSPR_RELEASE_CCO_POST 
);

ALTER TABLE CSPR_RELEASE_NOTES ADD (
  CONSTRAINT UK_CSPR_RELEASE_NOTE_URL
 UNIQUE (RELEASE_NUMBER_ID, RELEASE_NOTE_LABEL, RELEASE_NOTE_URL,SOURCE_LOCATION ))
 	
	

GRANT ALL ON CSPR_RELEASE_NOTES TO SHR_RDA;
 
GRANT ALL ON CSPR_RELEASE_NOTES_SEQ TO SHR_RDA;
 
CREATE TABLE CSPR_IMAGE_NOTES(
	IMAGE_URL_ID              NUMBER              NOT NULL,
	IMAGE_ID                  NUMBER              NOT NULL,
	URL_LABEL                 VARCHAR2(100)       NOT NULL,
	URL_VALUE                 VARCHAR2(250)       NOT NULL,
	CREATED_BY     			  VARCHAR2(8 BYTE)    NOT NULL,	
	CREATED_DATE              DATE                NOT NULL,
	ADM_USERID                VARCHAR2(8)		  NOT NULL,
	ADM_TIMESTAMP             DATE                NOT NULL,
	ADM_FLAG                  CHAR(1)        	  NOT NULL,
	ADM_COMMENT               VARCHAR2(50)
);


ALTER TABLE CSPR_IMAGE_NOTES
ADD CONSTRAINT PK_IMAGE_NOTES_ID
PRIMARY KEY(IMAGE_URL_ID);

 
ALTER TABLE CSPR_IMAGE_NOTES ADD (
   CONSTRAINT UK_CSPR_IMAGE_NOTES
 UNIQUE (IMAGE_ID, URL_LABEL, URL_VALUE, SOURCE_LOCATION))
  
   
CREATE SEQUENCE CSPR_IMAGE_NOTES_SEQ  START WITH 1 NOCACHE;
 
GRANT ALL ON CSPR_IMAGE_NOTES TO SHR_RDA;
 
GRANT ALL ON CSPR_IMAGE_NOTES_SEQ TO SHR_RDA;

