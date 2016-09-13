/**************************************************
These synonyms are to be created in sprit
-- Copyright (c) 2004-2008 by Cisco Systems, Inc.
Author: Selvaraj Aran(aselvara)
Created date: March 05,2008
****************************************************/

/*******************************************
1. Crate table cspr_platform_image
*******************************************/

CREATE TABLE CSPR_PLATFORM_IMAGE
(
  PLATFORM_IMAGE_ID       NUMBER                NOT NULL,
  IMAGE_ID                NUMBER                NOT NULL,
  INDIVIDUAL_PLATFORM_ID  NUMBER                NOT NULL,
  CREATED_BY              VARCHAR2(8 BYTE)      NOT NULL,
  CREATED_DATE            DATE                  NOT NULL,
  ADM_USERID              VARCHAR2(8 BYTE)      NOT NULL,
  ADM_TIMESTAMP           DATE                  NOT NULL,
  ADM_FLAG                CHAR(1 BYTE)          NOT NULL,
  ADM_COMMENT             VARCHAR2(50 BYTE)
);

 ALTER TABLE CSPR_PLATFORM_IMAGE
 ADD CONSTRAINT PK_PLATFORM_IMAGE
 PRIMARY KEY(platform_image_id);

 
 ALTER TABLE CSPR_PLATFORM_IMAGE ADD 
 CONSTRAINT UK_IMAGE_PLATFORM_ID  
 UNIQUE(IMAGE_ID, INDIVIDUAL_PLATFORM_ID);


GRANT ALL ON CSPR_PLATFORM_IMAGE TO SHR_RDA;

/*******************************************
2. Crate table cspr_pcode
*******************************************/

CREATE TABLE CSPR_PCODE
(
  PCODE_ID         NUMBER                         NOT NULL,
  IMAGE_ID         NUMBER                         NOT NULL,
  PCODE            VARCHAR2(18 BYTE)                  NULL,
  PRODUCT_DESC     VARCHAR2(60 BYTE)                  NULL,
  PCODE_TYPE       VARCHAR2(18 BYTE)              NOT NULL,
  PCODE_ORDERABLE  VARCHAR2(1 BYTE)                   NULL,
  PRICE            NUMBER                             NULL,
  pcode_price_source  VARCHAR2(10)                    null,
  PCODE_ORDERABLE_COMMENT      VARCHAR2(1000)         null,
  PCODE_ORDERABLE_INSTR_ID     NUMBER                 null,
  CREATED_BY       VARCHAR2(8 BYTE)               NOT NULL,
  CREATED_DATE     DATE                           NOT NULL,
  ADM_USERID       VARCHAR2(8 BYTE)               NOT NULL,
  ADM_TIMESTAMP    DATE                           NOT NULL,
  ADM_FLAG         CHAR(1 BYTE)                   NOT NULL,
  ADM_COMMENT      VARCHAR2(50 BYTE)
);

 ALTER TABLE CSPR_PCODE
 ADD CONSTRAINT PK_PCODE_ID
 PRIMARY KEY(PCODE_ID);

GRANT ALL ON  CSPR_PCODE TO SHR_RDA;

alter table cspr_image
add (MIN_FLASH               NUMBER(4),
    DRAM                    NUMBER(4));

GRANT ALL ON CSPR_IMAGE TO SHR_RDA;

ALTER TABLE cspr_image_mdf
ADD INDIVIDUAL_PLATFORM_ID Number;

alter table cspr_image_mdf drop constraint uk_cspr_image_mdf;

ALTER TABLE CSPR_IMAGE_MDF ADD 
CONSTRAINT UK_CSPR_IMAGE_MDF
UNIQUE (IMAGE_ID, MDF_CONCEPT_ID, INDIVIDUAL_PLATFORM_ID);


CREATE SEQUENCE CSPR_PLATFORM_PCODE_seq START WITH 1 INCREMENT BY 1 NOCACHE;


CREATE TABLE CSPR_PLATFORM_PCODE (
  PLATFORM_PCODE_ID         NUMBER              NOT NULL,
  PLATFORM_IMAGE_ID         NUMBER              NOT NULL,
  PCODE_ID                  NUMBER              NOT NULL,
  CREATED_BY                VARCHAR2(8 BYTE)    NOT NULL,
  CREATED_DATE              DATE                NOT NULL,
  ADM_USERID                VARCHAR2(8 BYTE)    NOT NULL,
  ADM_TIMESTAMP             DATE                NOT NULL,
  ADM_FLAG                  CHAR(1 BYTE)        NOT NULL,
  ADM_COMMENT               VARCHAR2(50 BYTE)       NULL
);

ALTER TABLE CSPR_PLATFORM_PCODE
ADD CONSTRAINT FK_PLATFORM_PCODE_IMAGE
FOREIGN KEY (PLATFORM_IMAGE_ID)
REFERENCES CSPR_PLATFORM_IMAGE(PLATFORM_IMAGE_ID);


ALTER TABLE CSPR_PLATFORM_PCODE
ADD CONSTRAINT  FK_PLATFORM_PCODE_ID
FOREIGN KEY (PCODE_ID)
REFERENCES CSPR_PCODE(PCODE_ID);

ALTER TABLE CSPR_PLATFORM_PCODE
ADD CONSTRAINT UK_CSPR_PLATFORM_PCODE
UNIQUE (PLATFORM_IMAGE_ID, PCODE_ID);

GRANT ALL ON CSPR_PLATFORM_PCODE TO SHR_RDA;

GRANT ALL ON CSPR_PLATFORM_PCODE_seq TO SHR_RDA;


