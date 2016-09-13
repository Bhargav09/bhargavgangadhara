--Copyright (c) 2007 by Cisco Systems, Inc.
/*
 	Current Release - 6.9 CSCsj91893
 	Last updated by - holchen
 	Last updated date - Aug 30, 2007 
 */
 
 DROP TABLE SHR_IMAGE_POSTING_TYPE;
 
 CREATE TABLE SHR_IMAGE_POSTING_TYPE(
     IMAGE_POSTING_TYPE_ID    NUMBER               NOT NULL,
     IMAGE_POSTING_TYPE_NAME    VARCHAR2(50)       NOT NULL,
     POSTING_TYPE_ID         NUMBER                NOT NULL,
     POSTING_TYPE_NAME 	VARCHAR2(50)       	   NOT NULL,
     CREATED_DATE     DATE                         NOT NULL,
     CREATED_BY       VARCHAR2(15 BYTE)            NOT NULL,
     ADM_TIMESTAMP    DATE                         NOT NULL,
     ADM_USERID       VARCHAR2(15 BYTE)            NOT NULL,
     ADM_FLAG         VARCHAR2(1 BYTE)             NOT NULL,
     ADM_COMMENT      VARCHAR2(50 BYTE)
 );
  
 ALTER TABLE SHR_IMAGE_POSTING_TYPE ADD(
 CONSTRAINT FK_SHR_IMAGE_POSTING_TYPE
 FOREIGN KEY (POSTING_TYPE_ID) 
 REFERENCES SHR_POSTING_TYPE (POSTING_TYPE_ID));
 
 ALTER TABLE SHR_IMAGE_POSTING_TYPE  ADD CONSTRAINT UK_SHR_IMAGE_POSTING_TYPE  UNIQUE(IMAGE_POSTING_TYPE_NAME, POSTING_TYPE_ID);
 
 DROP SEQUENCE SHR_IMAGE_POSTING_TYPE_SEQ;
 
 CREATE SEQUENCE SHR_IMAGE_POSTING_TYPE_SEQ  START WITH 1 NOCACHE;
 
 ALTER TABLE SHR_IMAGE ADD IMAGE_POSTING_TYPE_ID NUMBER;
  
 GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON  SHR_IMAGE_POSTING_TYPE TO SPRIT;

 