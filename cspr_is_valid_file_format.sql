 DROP TABLE CSPR_IS_VALID_FILE_FORMAT;
 
 DROP SEQUENCE CSPR_IS_VALID_FILE_FORMAT_SEQ;
 
 CREATE TABLE CSPR_IS_VALID_FILE_FORMAT
 (
   FILE_FORMAT_ID                NUMBER           NOT NULL,
   IS_VALID_FILE_FORMAT_VALUE    CHAR(1 BYTE)     NOT NULL,
   FILE_FORMAT_DESC              VARCHAR2(500 BYTE),
   CREATED_BY                    VARCHAR2(8 BYTE) NOT NULL,
   CREATED_DATE                  DATE             NOT NULL,
   ADM_USERID                    VARCHAR2(8 BYTE) NOT NULL,
   ADM_TIMESTAMP                 DATE             NOT NULL,
   ADM_FLAG                      CHAR(1 BYTE)     NOT NULL,
   ADM_COMMENT                   VARCHAR2(100 BYTE)
);
 
 
 ALTER TABLE CSPR_IS_VALID_FILE_FORMAT
 ADD CONSTRAINT PK_FILE_FORMAT_ID
 PRIMARY KEY(FILE_FORMAT_ID);
 
 
 
  
 CREATE SEQUENCE CSPR_IS_VALID_FILE_FORMAT_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
  
 GRANT ALL ON CSPR_IS_VALID_FILE_FORMAT TO SHR_RDA;
  
 GRANT ALL ON CSPR_IS_VALID_FILE_FORMAT_SEQ TO SHR_RDA;


 insert into CSPR_IS_VALID_FILE_FORMAT values (
     CSPR_IS_VALID_FILE_FORMAT_SEQ.nextval,
    'N',
    'pl',
    'holchen',
    sysdate,
    'holchen', 	
    sysdate,
    'V',
    'MANUALLY CREATED' ) ;



 insert into CSPR_IS_VALID_FILE_FORMAT values (
     CSPR_IS_VALID_FILE_FORMAT_SEQ.nextval,
    'N',
    'cgi',
    'holchen',
    sysdate,
    'holchen', 	
    sysdate,
    'V',
    'MANUALLY CREATED' ) ;

