////
///
//
//
//
--*****************************************
--Copyright (c) 2002-2005, 2007-2008, 2012 by Cisco Systems, Inc.
--1) shr_runs_comp_extn
--*****************************************


CREATE TABLE SHR_RUNS_COMP_EXTN (
       RUNS_COMP_EXTN_ID    NUMBER NOT NULL,
       RUNS_COMP_EXTN_NAME  VARCHAR2(32) NOT NULL,
       RUNS_COMP_EXTN_DESC  VARCHAR2(256) NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);

CREATE SEQUENCE shr_runs_comp_extn_seq START WITH 1 INCREMENT BY 1 NOCACHE;

ALTER TABLE SHR_RUNS_COMP_EXTN
ADD CONSTRAINT UK_SHR_RUNS_COMP_EXTN_NAME 
UNIQUE (RUNS_COMP_EXTN_NAME);

ALTER TABLE SHR_RUNS_COMP_EXTN
ADD (CONSTRAINT PK_SHR_RUNS_COMP_EXTN_ID 
PRIMARY KEY ( RUNS_COMP_EXTN_ID) ) ;

--*****************************************
--2) shr_image_type
--*****************************************


CREATE SEQUENCE shr_image_type_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_IMAGE_TYPE (
       IMAGE_TYPE_ID        NUMBER NOT NULL,
       IMAGE_TYPE_NAME      VARCHAR2(64) NOT NULL,
       IMAGE_TYPE_DESC      VARCHAR2(256) NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);

ALTER TABLE SHR_IMAGE_TYPE 
ADD CONSTRAINT UK_SHR_IMAGE_TYPE_NAME 
UNIQUE ( IMAGE_TYPE_NAME);

ALTER TABLE SHR_IMAGE_TYPE
ADD (CONSTRAINT PK_SHR_IMAGE_TYPE_ID 
PRIMARY KEY ( IMAGE_TYPE_ID) ) ;

--*****************************************
--3) shr_image_prefix
--*****************************************


CREATE SEQUENCE shr_image_prefix_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_IMAGE_PREFIX (
       IMAGE_PREFIX_ID      NUMBER NOT NULL,
       IMAGE_PREFIX_NAME    VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_IMAGE_PREFIX
ADD CONSTRAINT UK_SHR_IMAGE_PREFIX_NAME 
UNIQUE (IMAGE_PREFIX_NAME);

ALTER TABLE SHR_IMAGE_PREFIX
ADD ( CONSTRAINT PK_SHR_IMAGE_PREFIX_ID 
PRIMARY KEY(IMAGE_PREFIX_ID));

--*****************************************
--4) shr_feature_set_name
--*****************************************


CREATE SEQUENCE shr_feature_set_name_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_FEATURE_SET_NAME (
       FEATURE_SET_NAME_ID  NUMBER NOT NULL,
       FEATURE_SET_NAME     VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_FEATURE_SET_NAME 
ADD CONSTRAINT UK_SHR_FEATURE_SET_NAME 
UNIQUE (FEATURE_SET_NAME);

ALTER TABLE SHR_FEATURE_SET_NAME
ADD (CONSTRAINT PK_SHR_FEATURE_SET_NAME_ID 
PRIMARY KEY (FEATURE_SET_NAME_ID) ) ;

--*****************************************
--5) shr_feature_set_desc
--*****************************************


CREATE SEQUENCE shr_feature_set_desc_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_FEATURE_SET_DESC (
       FEATURE_SET_DESC_ID  NUMBER NOT NULL,
       FEATURE_SET_DESC     VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_FEATURE_SET_DESC
ADD CONSTRAINT UK_SHR_FEATURE_SET_DESC
UNIQUE(FEATURE_SET_DESC);


ALTER TABLE SHR_FEATURE_SET_DESC
ADD( CONSTRAINT PK_SHR_FEATURE_SET_DESC_ID 
     PRIMARY KEY( FEATURE_SET_DESC_ID) ) ;

--*****************************************
--6) shr_feature_set_designator
--*****************************************


CREATE SEQUENCE shr_feature_set_designator_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_FEATURE_SET_DESIGNATOR (
       FEATURE_SET_DESIGNATOR_ID NUMBER NOT NULL,
       FEATURE_SET_DESIGNATOR VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_FEATURE_SET_DESIGNATOR
ADD CONSTRAINT UK_SHR_FEATURE_SET_DESIGNATOR
UNIQUE(FEATURE_SET_DESIGNATOR);

ALTER TABLE SHR_FEATURE_SET_DESIGNATOR
ADD ( CONSTRAINT PK_SHR_FEATURE_SET_DESIGNAT_ID 
PRIMARY KEY (FEATURE_SET_DESIGNATOR_ID) ) ;

--*****************************************
--7) shr_feature_set
--*****************************************

CREATE SEQUENCE shr_feature_set_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_FEATURE_SET (
       FEATURE_SET_ID       NUMBER NOT NULL,
       IMAGE_PREFIX_ID      NUMBER NOT NULL,
       FEATURE_SET_NAME_ID  NUMBER NOT NULL,
       FEATURE_SET_DESC_ID  NUMBER NOT NULL,
       FEATURE_SET_DESIGNATOR_ID NUMBER NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_FEATURE_SET
ADD CONSTRAINT UK_SHR_FEATURE_SET
UNIQUE (IMAGE_PREFIX_ID,FEATURE_SET_NAME_ID
       ,FEATURE_SET_DESC_ID,FEATURE_SET_DESIGNATOR_ID);

ALTER TABLE SHR_FEATURE_SET
ADD ( CONSTRAINT PK_SHR_FEATURE_SET_ID 
      PRIMARY KEY( FEATURE_SET_ID) ) ;

ALTER TABLE SHR_FEATURE_SET
ADD  ( CONSTRAINT FK_SHR_FEATURE_SET_NAME_ID
       FOREIGN KEY (FEATURE_SET_NAME_ID)
       REFERENCES SHR_FEATURE_SET_NAME ) ;


ALTER TABLE SHR_FEATURE_SET
ADD  ( CONSTRAINT FK_SHR_FS_IMAGE_PREFIX_ID
       FOREIGN KEY (IMAGE_PREFIX_ID)
       REFERENCES SHR_IMAGE_PREFIX ) ;


ALTER TABLE SHR_FEATURE_SET
ADD  ( CONSTRAINT FK_SHR_FEATURE_SET_DESIGNAT_ID
       FOREIGN KEY (FEATURE_SET_DESIGNATOR_ID)
       REFERENCES SHR_FEATURE_SET_DESIGNATOR ) ;


ALTER TABLE SHR_FEATURE_SET
ADD  ( CONSTRAINT FK_SHR_FEATURE_SET_DESC_ID
       FOREIGN KEY (FEATURE_SET_DESC_ID)
       REFERENCES SHR_FEATURE_SET_DESC ) ;
  
--*****************************************
--8) shr_image
--*****************************************


CREATE SEQUENCE shr_image_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_IMAGE (
       IMAGE_ID             NUMBER NOT NULL,
       IMAGE_PREFIX_ID      NUMBER NOT NULL,
       FEATURE_SET_NAME_ID  NUMBER NOT NULL,
       RUNS_COMP_EXTN_ID    NUMBER NOT NULL,
       RELEASE_NUMBER_ID    NUMBER NOT NULL,
       IMAGE_TYPE_ID        NUMBER NULL,
       AUDIT_IMAGE_ID       NUMBER NULL,
       IMAGE_NAME           VARCHAR2(64) NOT NULL,
       IS_IN_IMAGE_LIST     CHAR(1) NULL,
       IS_BUILT_FOR         CHAR(1) NULL,
       IS_ARF_DEVTEST_OK    CHAR(1) NULL,
       IS_NETBOOTED         CHAR(1) NULL,
       IS_GOING_TO_CCO      CHAR(1) NULL,
       IS_GOING_TO_MFG      CHAR(1) NULL,
       IS_CCO_ORDERABLE     CHAR(1) NULL,
       IS_MFG_ORDERABLE     CHAR(1) NULL,
       IS_DEFERRED          CHAR(1) NULL,
       DEFERRAL_ID          VARCHAR2(20) NULL,
       IS_SOFTWARE_ADVISORY CHAR(1) NULL,
       SOFTWARE_ADVISORY_ID VARCHAR2(20) NULL,
       IS_OBSOLETE          CHAR(1) NULL,
       ON_RELEASE_ARCHIVE_DATE DATE NULL,
       ON_TFTPBOOT_DATE     DATE NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL,
       CREATED_BY           VARCHAR2(20) NOT NULL,
       CREATED_DATE         DATE NOT NULL
);

ALTER TABLE SHR_IMAGE
ADD CONSTRAINT UK_SHR_IMAGE
UNIQUE (IMAGE_PREFIX_ID,FEATURE_SET_NAME_ID,RUNS_COMP_EXTN_ID,IMAGE_ID);


ALTER TABLE SHR_IMAGE
ADD (CONSTRAINT PK_SHR_IMAGE_ID 
     PRIMARY KEY (IMAGE_ID) ) ;

ALTER TABLE SHR_IMAGE
ADD  ( CONSTRAINT FK_SHR_IMAGE_FS_NAME_ID
       FOREIGN KEY (FEATURE_SET_NAME_ID)
       REFERENCES SHR_FEATURE_SET_NAME ) ;


ALTER TABLE SHR_IMAGE
ADD  ( CONSTRAINT FK_SHR_IMAGE_PREFIX_ID
       FOREIGN KEY (IMAGE_PREFIX_ID)
       REFERENCES SHR_IMAGE_PREFIX ) ;


ALTER TABLE SHR_IMAGE
ADD  ( CONSTRAINT FK_SHR_IMAGE_TYPE_ID
       FOREIGN KEY (IMAGE_TYPE_ID)
       REFERENCES SHR_IMAGE_TYPE ) ;


ALTER TABLE SHR_IMAGE
ADD  ( CONSTRAINT FK_SHR_IMAGE_RELEASE_NUMBER_ID
       FOREIGN KEY (RELEASE_NUMBER_ID)
       REFERENCES SHR_RELEASE_NUMBER ) ;


ALTER TABLE SHR_IMAGE
ADD  ( CONSTRAINT FK_SHR_IMAGE_RUNS_COMP_EXTN_ID
       FOREIGN KEY (RUNS_COMP_EXTN_ID)
       REFERENCES SHR_RUNS_COMP_EXTN ) ;


--*****************************************
--9) shr_image_feature_set
--*****************************************



CREATE SEQUENCE shr_image_feature_set_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_IMAGE_FEATURE_SET (
       IMAGE_FEATURE_SET_ID NUMBER NOT NULL,
       IMAGE_ID             NUMBER NOT NULL,
       FEATURE_SET_ID       NUMBER NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_IMAGE_FEATURE_SET
ADD CONSTRAINT UK_SHR_IMAGE_FEATURE_SET
UNIQUE ( IMAGE_ID,IMAGE_FEATURE_SET_ID);

ALTER TABLE SHR_IMAGE_FEATURE_SET
ADD ( CONSTRAINT PK_SHR_IMAGE_FEATURE_SET_ID 
      PRIMARY KEY ( IMAGE_FEATURE_SET_ID) ) ;

ALTER TABLE SHR_IMAGE_FEATURE_SET
ADD ( CONSTRAINT FK_SHR_FEATURE_SET_ID
       FOREIGN KEY (FEATURE_SET_ID)
       REFERENCES SHR_FEATURE_SET ) ;


ALTER TABLE SHR_IMAGE_FEATURE_SET
ADD  ( CONSTRAINT FK_SHR_IMAGE_FS_IMAGE_ID
       FOREIGN KEY (IMAGE_ID)
       REFERENCES SHR_IMAGE ) ;

--*****************************************
--10) shr_platform_family
--*****************************************



CREATE SEQUENCE shr_platform_family_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_PLATFORM_FAMILY (
       PLATFORM_FAMILY_ID   NUMBER NOT NULL,
       PLATFORM_FAMILY_NAME VARCHAR2(64) NOT NULL,
       PLATFORM_FAMILY_ENGG_NAME VARCHAR2(64) NULL,
       PLATFORM_FAMILY_DESC VARCHAR2(256) NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);

ALTER TABLE SHR_PLATFORM_FAMILY
ADD CONSTRAINT UK_SHR_PLATFORM_FAMILY_NAME
UNIQUE(PLATFORM_FAMILY_NAME);

ALTER TABLE SHR_PLATFORM_FAMILY
ADD ( CONSTRAINT PK_SHR_PLATFORM_FAMILY_ID 
PRIMARY KEY (PLATFORM_FAMILY_ID) ) ;

--*****************************************
--11) shr_individual_platform
--*****************************************


CREATE SEQUENCE shr_individual_platform_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_INDIVIDUAL_PLATFORM (
       INDIVIDUAL_PLATFORM_ID NUMBER NOT NULL,
       INDIVIDUAL_PLATFORM_NAME VARCHAR2(64) NOT NULL,
       PLATFORM_FAMILY_ID   NUMBER NOT NULL,
       CCO_DIR              VARCHAR2(20) NULL,
       PLATFORM_PRODUCT_FAMILY VARCHAR2(10) NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);

ALTER TABLE SHR_INDIVIDUAL_PLATFORM
ADD CONSTRAINT UK_SHR_INDVL_PLATFORM_NAME
UNIQUE(INDIVIDUAL_PLATFORM_NAME);

ALTER TABLE SHR_INDIVIDUAL_PLATFORM
ADD  (CONSTRAINT PK_SHR_INDVL_PLATFORM_ID 
PRIMARY KEY ( INDIVIDUAL_PLATFORM_ID) ) ;

ALTER TABLE SHR_INDIVIDUAL_PLATFORM
ADD  ( CONSTRAINT FK_SHR_PLATFORM_FAMILY_ID
       FOREIGN KEY (PLATFORM_FAMILY_ID)
       REFERENCES SHR_PLATFORM_FAMILY ) ;



--*****************************************
--12) shr_platform_image
--*****************************************



CREATE SEQUENCE shr_platform_image_seq START WITH 1 INCREMENT BY 1 NOCACHE;


CREATE TABLE SHR_PLATFORM_IMAGE (
       PLATFORM_IMAGE_ID    VARCHAR2(20) NOT NULL,
       IMAGE_ID             NUMBER NOT NULL,
       INDIVIDUAL_PLATFORM_ID NUMBER NOT NULL,
       MIN_FLASH            NUMBER(4) NOT NULL,
       DRAM                 NUMBER(4) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);

--ALTER TABLE SHR_PLATFORM_IMAGE
--ADD CONSTRAINT UK_SHR_PLATFORM_IMAGE
--UNIQUE(IMAGE_ID,INDIVIDUAL_PLATFORM_ID);

ALTER TABLE SHR_PLATFORM_IMAGE
ADD (CONSTRAINT PK_SHR_PLATFORM_IMAGE_ID 
     PRIMARY KEY( PLATFORM_IMAGE_ID) ) ;

ALTER TABLE SHR_PLATFORM_IMAGE
ADD  ( CONSTRAINT FK_SHR_PLATFORM_IMAGE_ID
       FOREIGN KEY (IMAGE_ID)
       REFERENCES SHR_IMAGE ) ;


ALTER TABLE SHR_PLATFORM_IMAGE
ADD  ( CONSTRAINT FK_SHR_INDVL_PLATFORM_ID
       FOREIGN KEY (INDIVIDUAL_PLATFORM_ID)
       REFERENCES SHR_INDIVIDUAL_PLATFORM ) ;

--*****************************************
--13) shr_pf_image_prefix
--*****************************************



CREATE SEQUENCE shr_pf_image_prefix_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE SHR_PF_IMAGE_PREFIX (
       PF_IMAGE_PREFIX_ID   VARCHAR2(20) NOT NULL,
       PLATFORM_FAMILY_ID   NUMBER NOT NULL,
       IMAGE_PREFIX_ID      NUMBER NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_FLAG             VARCHAR2(20) NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NOT NULL
);

ALTER TABLE SHR_PF_IMAGE_PREFIX
ADD CONSTRAINT UK_SHR_PF_IMAGE_PREFIX 
UNIQUE(PLATFORM_FAMILY_ID,IMAGE_PREFIX_ID);

ALTER TABLE SHR_PF_IMAGE_PREFIX
ADD( CONSTRAINT PK_SHR_PF_IMAGE_PREFIX_ID 
PRIMARY KEY (PF_IMAGE_PREFIX_ID) ) ;

ALTER TABLE SHR_PF_IMAGE_PREFIX
ADD  ( CONSTRAINT FK_SHR_PF_IMAGE_PREFIX_PF_ID
       FOREIGN KEY (PLATFORM_FAMILY_ID)
       REFERENCES SHR_PLATFORM_FAMILY ) ;


ALTER TABLE SHR_PF_IMAGE_PREFIX
ADD  ( CONSTRAINT FK_SHR_PF_IMAGE_PREFIX_ID
       FOREIGN KEY (IMAGE_PREFIX_ID)
       REFERENCES SHR_IMAGE_PREFIX ) ;

--******************************************************************************************************

CREATE TABLE SHR_PC_PREFIX (
       PC_PREFIX            VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);


ALTER TABLE SHR_PC_PREFIX
       ADD  ( CONSTRAINT PK_SHR_PC_PREFIX PRIMARY KEY (PC_PREFIX) ) ;

--******************************************************************************************************

CREATE TABLE SHR_PC_TYPE (
       PC_TYPE              VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_USERID           VARCHAR2(8) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL
);


ALTER TABLE SHR_PC_TYPE
       ADD  ( CONSTRAINT PK_SHR_PC_TYPE PRIMARY KEY (PC_TYPE) ) ;

--******************************************************************************************************



CREATE TABLE SHR_REL_PF (
       REL_PF_ID            NUMBER NOT NULL,
       PLATFORM_FAMILY_ID   NUMBER NOT NULL,
       RELEASE_NUMBER_ID    NUMBER NOT NULL,
       PF_ABBREV            VARCHAR2(20) NOT NULL,
       PF_DESC              VARCHAR2(20) NOT NULL,
       ADM_TIMESTAMP        DATE NOT NULL,
       ADM_USERID           VARCHAR2(20) NOT NULL,
       ADM_FLAG             CHAR(1) NOT NULL,
       ADM_COMMENT          VARCHAR2(50) NULL,
       CREATED_BY           VARCHAR2(20) NOT NULL,
       CREATED_DATE         DATE NOT NULL
);

CREATE SEQUENCE SHR_REL_PF_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

ALTER TABLE SHR_REL_PF
       ADD  ( CONSTRAINT PK_SHR_REL_PF PRIMARY KEY (REL_PF_ID) ) ;

ALTER TABLE SHR_REL_PF
       ADD  ( CONSTRAINT FK_SHR_REL_PF_FAMILY_ID
              FOREIGN KEY (PLATFORM_FAMILY_ID)
                             REFERENCES SHR_PLATFORM_FAMILY ) ;

ALTER TABLE SHR_REL_PF
       ADD  ( CONSTRAINT FK_SHR_REL_PF_REL_NUMBER_ID
              FOREIGN KEY (RELEASE_NUMBER_ID)
                             REFERENCES SHR_RELEASE_NUMBER ) ;

--******************************************************************************************************



CREATE TABLE SHR_PRODUCT_CODE (
       PRODUCT_CODE_ID            NUMBER NOT NULL,
       PC_PREFIX                  VARCHAR2(20) NOT NULL,
       PC_TYPE                    VARCHAR2(20) NOT NULL,
       FEATURE_SET_DESIGNATOR_ID  NUMBER NOT NULL,
       IMAGE_FEATURE_SET_ID       NUMBER NOT NULL,
       REL_PF_ID                  NUMBER NOT NULL,
       PRODUCT_CODE               VARCHAR2(20) NOT NULL,
       PC_PRICE                   NUMBER NOT NULL,
       IS_MEDIA_DISPLAY           CHAR(1) NOT NULL,
       MEDIA_VALUE                VARCHAR2(20) NULL,
       ERP_APPROVAL               CHAR(1) NOT NULL,
       ADM_TIMESTAMP              DATE NOT NULL,
       ADM_USERID                 VARCHAR2(8) NOT NULL,
       ADM_FLAG                   CHAR(1) NOT NULL,
       ADM_COMMENT                VARCHAR2(50) NULL,
       CREATED_BY                 VARCHAR2(8) NOT NULL,
       CREATED_DATE               DATE NOT NULL
);
  
CREATE SEQUENCE SHR_PRODUCT_CODE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT PK_SHR_PRODUCT_CODE PRIMARY KEY (
              PRODUCT_CODE_ID) ) ;



ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT FK_SHR_PRODUCT_CODE_FS_DESIG
              FOREIGN KEY (FEATURE_SET_DESIGNATOR_ID)
                             REFERENCES SHR_FEATURE_SET_DESIGNATOR ) ;


ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT FK_SHR_PRODUCT_CODE_PC_PREFIX
              FOREIGN KEY (PC_PREFIX)
                             REFERENCES SHR_PC_PREFIX ) ;


ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT FK_SHR_PRODUCT_CODE_PC_TYPE
              FOREIGN KEY (PC_TYPE)
                             REFERENCES SHR_PC_TYPE ) ;


ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT FK_SHR_PRODUCT_CODE_REL_PF_ID
              FOREIGN KEY (REL_PF_ID)
                             REFERENCES SHR_REL_PF ) ;


ALTER TABLE SHR_PRODUCT_CODE
       ADD  ( CONSTRAINT FK_SHR_PRODUCT_CODE_IMAGE_FS
              FOREIGN KEY (IMAGE_FEATURE_SET_ID)
                             REFERENCES SHR_IMAGE_FEATURE_SET ) ;
                             
--*******************************************************
--*cspr_feature_set
--*******************************************************

CREATE SEQUENCE cspr_feature_set_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE CSPR_FEATURE_SET
  (
    CSPR_FEATURE_SET_ID       NUMBER NOT NULL ENABLE,
    FEATURE_SET_NAME_ID       NUMBER NOT NULL ENABLE,
    FEATURE_SET_DESC_ID       NUMBER,
    OS_TYPE_ID                NUMBER(*,0) NOT NULL ENABLE,
    ADM_TIMESTAMP DATE NOT NULL ENABLE,
    ADM_USERID      VARCHAR2(20 BYTE) NOT NULL ENABLE,
    ADM_FLAG        VARCHAR2(20 BYTE) NOT NULL ENABLE,
    ADM_COMMENT     VARCHAR2(50 BYTE) NOT NULL ENABLE,
    IS_GOING_TO_CCO CHAR(1 BYTE),
    CONSTRAINT UK_CSPR_FEATURE_SET UNIQUE (FEATURE_SET_NAME_ID, FEATURE_SET_DESC_ID),
    CONSTRAINT PK_CSPR_FEATURE_SET_ID PRIMARY KEY (CSPR_FEATURE_SET_ID),
    CONSTRAINT FK_CSPR_FEATURE_SET_NAME_ID FOREIGN KEY (FEATURE_SET_NAME_ID) REFERENCES SHR_RDA.SHR_FEATURE_SET_NAME (FEATURE_SET_NAME_ID) ENABLE,
    CONSTRAINT FK_CSPR_FEATURE_SET_DESC_ID FOREIGN KEY (FEATURE_SET_DESC_ID) REFERENCES SHR_RDA.SHR_FEATURE_SET_DESC (FEATURE_SET_DESC_ID) ENABLE,
    CONSTRAINT FK_CSPR_OS_TYPE_ID FOREIGN KEY (OS_TYPE_ID) REFERENCES SHR_RDA.SHR_OS_TYPE (OS_TYPE_ID) ENABLE
  );

       
       
CREATE SEQUENCE cspr_image_feature_set_seq START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE CSPR_IMAGE_FEATURE_SET( 
   CSPR_IMAGE_FEATURE_SET_ID   NUMBER NOT NULL ENABLE,
   IMAGE_ID NUMBER NOT NULL ENABLE, 
   CSPR_FEATURE_SET_ID NUMBER NOT NULL ENABLE,
   ADM_TIMESTAMP DATE NOT NULL ENABLE,
   ADM_USERID      VARCHAR2(20 BYTE) NOT NULL ENABLE,
   ADM_FLAG        VARCHAR2(20 BYTE) NOT NULL ENABLE,
   ADM_COMMENT     VARCHAR2(50 BYTE) NOT NULL ENABLE,
   IS_GOING_TO_CCO CHAR(1 BYTE),
   CONSTRAINT PK_IMAGE_FEATURE_SET_ID PRIMARY KEY (cspr_image_feature_set_id),
   CONSTRAINT FK_IMAGE_ID_FOR_FEATURE_SET FOREIGN KEY (IMAGE_ID) REFERENCES sprit.CSPR_IMAGE (IMAGE_ID) ENABLE,
   CONSTRAINT FK_CSPR_FEATURE_SET_ID FOREIGN KEY (CSPR_FEATURE_SET_ID) REFERENCES CSPR_FEATURE_SET (CSPR_FEATURE_SET_ID) ENABLE
);


--************** END OF FILE ********************************************
