--Copyright (c) 2007 by Cisco Systems, Inc.
/*
 	Current Release - 6.9 CSCsj91933 - Related Software - CCO Post transaction
 	Last updated by - holchen
 	Last updated date - Sept 6, 2007 
 */
 
 DROP TABLE CSPR_RELATED_SOFTWARE;
 
 DROP SEQUENCE CSPR_RELATED_SOFTWARE_SEQ;
 
 CREATE TABLE CSPR_RELATED_SOFTWARE(
   RELATED_SW_ID	 NUMBER            	  NOT NULL,
   IMAGE_ID              NUMBER                   NOT NULL,
   SOFTWARE_TYPE_MDF_ID  NUMBER          	  NOT NULL,
   PRODUCT_MDF_ID	 NUMBER(38)      	  NOT NULL,
   RELEASE_NAME          VARCHAR2(20 BYTE)        NOT NULL,
   RELEASE_NUMBER_ID     NUMBER			  NOT NULL, 
   MACHINE_OS_TYPE_ID	 NUMBER,	
   CREATED_BY            VARCHAR2(8 BYTE)         NOT NULL,
   CREATED_DATE          DATE                     NOT NULL,
   ADM_USERID            VARCHAR2(8 BYTE)         NOT NULL,
   ADM_TIMESTAMP         DATE                     NOT NULL,
   ADM_FLAG              CHAR(1 BYTE)             NOT NULL,
   ADM_COMMENT           VARCHAR2(50 BYTE)
 );  
 
 ALTER TABLE CSPR_RELATED_SOFTWARE
 ADD CONSTRAINT PK_RELATED_SW_ID
 PRIMARY KEY(RELATED_SW_ID);
 
 ALTER TABLE CSPR_RELATED_SOFTWARE ADD(
 CONSTRAINT FK_RELATED_SOFTWARE_CSPR_IMAGE
 FOREIGN KEY (IMAGE_ID) 
 REFERENCES CSPR_IMAGE (IMAGE_ID));
 
 
 ALTER TABLE CSPR_RELATED_SOFTWARE ADD(
 CONSTRAINT FK_RELATED_SWT_MDF_PROD_ATTR
 FOREIGN KEY (PRODUCT_MDF_ID) 
 REFERENCES SHR_MDF_PRODUCTS_ATTR(MDF_CONCEPT_ID));
 
 
 ALTER TABLE CSPR_RELATED_SOFTWARE ADD(
 CONSTRAINT FK_RELATED_SWT_MDF_SWTYPE_ATTR
 FOREIGN KEY (SOFTWARE_TYPE_MDF_ID) 
 REFERENCES SHR_MDF_SWTYPE_ATTR (MDF_SWT_CONCEPT_ID));
 
 DROP SEQUENCE CSPR_RELATED_SOFTWARE_SEQ;
  
 CREATE SEQUENCE CSPR_RELATED_SOFTWARE_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
  
 GRANT ALL ON CSPR_RELATED_SOFTWARE TO SHR_RDA;
  
 GRANT ALL ON CSPR_RELATED_SOFTWARE_SEQ TO SHR_RDA;
 