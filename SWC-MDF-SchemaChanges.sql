/* Copyright (c) 2006 by cisco Systems, Inc. All rights reserved. */
-- SWC-MDF-SchemaChanges.sql

connect shr_rda/shr_rda@testrda

-- ======================= Schema Drop Script ================================

ALTER TABLE SHR_IMAGE
 DROP COLUMN MDF_SWT_CONCEPT_ID;

-- ALTER TABLE SHR_IMAGE DROP COLUMN ios_ion_type;

DROP TABLE SHR_IND_PLATFORM_MDFSWTYPE;
DROP TABLE SHR_OSTYPE_MDFSWTYPE;
DROP TABLE SHR_MDF_PROD_HAS_SWTYPE;
DROP TABLE SHR_MDF_SWTYPE_ATTR;

DROP SEQUENCE SHR_OSTYPE_MDFSWTYPE_SEQ;
DROP SEQUENCE SHR_IND_PLATFORM_MDFSWTYPE_SEQ;

-- ==================== Schema Creation Script ===============================

-- ================== TABLE : SHR_MDF_SWTYPE_ATTR ============================

CREATE TABLE SHR_MDF_SWTYPE_ATTR
(
  MDF_SWT_CONCEPT_ID            NUMBER(38)      NOT NULL,
  MDF_SWT_CONCEPT_NAME          VARCHAR2(640 BYTE) NOT NULL,
  MDF_SWT_CONCEPT_DESC          VARCHAR2(4000 BYTE),
  MDF_SWT_PARENT_CONCEPT_ID     NUMBER(38),
  MDF_SWT_PARENT_CONCEPT_NAME   VARCHAR2(4000 BYTE),
  LEVEL_NO                      NUMBER(3),
  LIFECYCLE                     VARCHAR2(4000 BYTE),
  PUBLISHING_SYSTEM             VARCHAR2(4000 BYTE),
  MDF_SWT_CONCEPT_DISPLAY_NAME  VARCHAR2(640 BYTE),
  IS_LEAF_NODE                  CHAR(1),
  SUBMITTED_BY                  VARCHAR2(25 BYTE),
  LAST_MODIFIED_DATE            DATE,
  ADM_CREATED_AT                DATE,
  ADM_TIMESTAMP                 DATE,
  ADM_FLAG                      VARCHAR2(1 BYTE),
  ADM_COMMENT                   VARCHAR2(100 BYTE)
);


CREATE UNIQUE INDEX PK_MDF_SWTYPE_ATTR ON SHR_MDF_SWTYPE_ATTR
(MDF_SWT_CONCEPT_ID);

CREATE INDEX IX_MDF_SWTYPE_ATTR_MDF_NAME ON SHR_MDF_SWTYPE_ATTR
(MDF_SWT_CONCEPT_NAME);

CREATE INDEX IX_MDF_SWTYPE_ATTR_PID ON SHR_MDF_SWTYPE_ATTR
(MDF_SWT_PARENT_CONCEPT_ID);

ALTER TABLE SHR_MDF_SWTYPE_ATTR ADD (
  PRIMARY KEY
 (MDF_SWT_CONCEPT_ID)
    USING INDEX );


GRANT SELECT ON SHR_MDF_SWTYPE_ATTR TO SHR_RDA_READONLY;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON SHR_MDF_SWTYPE_ATTR TO SPRIT;


-- ================== TABLE : SHR_MDF_PROD_HAS_SWTYPE ==========================

CREATE TABLE SHR_MDF_PROD_HAS_SWTYPE
(
  MDF_CONCEPT_ID        NUMBER(38)              NOT NULL,
  MDF_CONCEPT_NAME      VARCHAR2(640 BYTE)      NOT NULL,
  MDF_SWT_CONCEPT_ID    NUMBER(38)              NOT NULL,
  MDF_SWT_CONCEPT_NAME  VARCHAR2(4000 BYTE)     NOT NULL,
  PRODUCT_LIFECYCLE     VARCHAR2(4000 BYTE),
  SWT_LIFECYCLE         VARCHAR2(4000 BYTE),
  LAST_MODIFIED_DATE    DATE,
  ADM_CREATED_AT        DATE,
  ADM_TIMESTAMP         DATE,
  ADM_FLAG              VARCHAR2(1 BYTE),
  ADM_COMMENT           VARCHAR2(100 BYTE)
);

CREATE UNIQUE INDEX PK_SHR_MDF_PROD_HAS_SWTYPE ON SHR_MDF_PROD_HAS_SWTYPE
(MDF_CONCEPT_ID, MDF_SWT_CONCEPT_ID)

CREATE INDEX IX_MDF_PROD_HAS_SWTYPE_MDFID ON SHR_MDF_PROD_HAS_SWTYPE
(MDF_CONCEPT_ID);

CREATE INDEX IX_MDF_PROD_HAS_SWTYPE_SWTID ON SHR_MDF_PROD_HAS_SWTYPE
(MDF_SWT_CONCEPT_ID);


ALTER TABLE SHR_MDF_PROD_HAS_SWTYPE ADD (
  PRIMARY KEY
 (MDF_CONCEPT_ID, MDF_SWT_CONCEPT_ID)
    USING INDEX );

GRANT SELECT ON SHR_MDF_PROD_HAS_SWTYPE TO SHR_RDA_READONLY;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON SHR_MDF_PROD_HAS_SWTYPE TO SPRIT;

-- ================== TABLE : SHR_OSTYPE_MDFSWTYPE ============================

CREATE TABLE SHR_OSTYPE_MDFSWTYPE
(
  OSTYPE_MDFSWTYPE_ID           INTEGER      NOT NULL,      
  OS_TYPE_ID			INTEGER      NOT NULL,
  MDF_SWT_CONCEPT_ID            INTEGER      NOT NULL,
  LAST_MODIFIED_DATE 	        DATE,
  ADM_CREATED_AT                DATE,
  ADM_TIMESTAMP                 DATE,
  ADM_FLAG                      VARCHAR2(1 BYTE),
  ADM_COMMENT                   VARCHAR2(100 BYTE)
);


CREATE UNIQUE INDEX PK_SHR_OSTYPE_MDFSWTYPE ON SHR_OSTYPE_MDFSWTYPE
(OS_TYPE_ID, MDF_SWT_CONCEPT_ID)

CREATE INDEX IX_SHR_OSTYPE_MDFSWTYPE_OSID ON SHR_OSTYPE_MDFSWTYPE
(OS_TYPE_ID);

CREATE INDEX IX_SHR_OSTYPE_MDFSWTYPE_SWTID ON SHR_OSTYPE_MDFSWTYPE
(MDF_SWT_CONCEPT_ID);

ALTER TABLE SHR_OSTYPE_MDFSWTYPE ADD (
  PRIMARY KEY
 (OSTYPE_MDFSWTYPE_ID)
    USING INDEX );

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON SHR_OSTYPE_MDFSWTYPE TO SPRIT;

-- ================== SEQUENCE : SHR_OSTYPE_MDFSWTYPE_SEQ ============================

CREATE SEQUENCE SHR_RDA.SHR_OSTYPE_MDFSWTYPE_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;



GRANT SELECT ON SHR_OSTYPE_MDFSWTYPE_SEQ TO SPRIT;

-- ================== TABLE : SHR_IND_PLATFORM_MDFSWTYPE ===========================

CREATE TABLE SHR_IND_PLATFORM_MDFSWTYPE
(
  INDIVIDUAL_PLATFORM_MDFSWT_ID      INTEGER      NOT NULL,      
  INDIVIDUAL_PLATFORM_ID	          INTEGER      NOT NULL,
  MDF_SWT_CONCEPT_ID                    INTEGER      NOT NULL,
  CREATED_BY             VARCHAR2(8 BYTE)       NOT NULL,
  CREATED_DATE           DATE                   NOT NULL,
  ADM_USERID             VARCHAR2(8 BYTE)       NOT NULL,
  ADM_TIMESTAMP          DATE                   NOT NULL,
  ADM_FLAG               CHAR(1 BYTE)           NOT NULL,
  ADM_COMMENT            VARCHAR2(50 BYTE)
);

CREATE UNIQUE INDEX PK_SHR_IND_PLATFORM_MDFSWTYPE ON SHR_IND_PLATFORM_MDFSWTYPE
(INDIVIDUAL_PLATFORM_ID, MDF_SWT_CONCEPT_ID)

CREATE INDEX IX_SHR_INDPLAT_MDFSWTYPE_PID ON SHR_IND_PLATFORM_MDFSWTYPE
(INDIVIDUAL_PLATFORM_ID);

CREATE INDEX IX_SHR_INDPLAT_MDFSWTYPE_SWTID ON SHR_IND_PLATFORM_MDFSWTYPE
(MDF_SWT_CONCEPT_ID);

ALTER TABLE SHR_IND_PLATFORM_MDFSWTYPE ADD (
  PRIMARY KEY
 (INDIVIDUAL_PLATFORM_MDFSWT_ID)
    USING INDEX );

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON SHR_IND_PLATFORM_MDFSWTYPE TO SPRIT;

-- ================== SEQUENCE : SHR_IND_PLATFORM_MDFSWTYPE_SEQ ============================

CREATE SEQUENCE SHR_RDA.SHR_IND_PLATFORM_MDFSWTYPE_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

GRANT SELECT ON SHR_IND_PLATFORM_MDFSWTYPE_SEQ TO SPRIT;

-- ======================= ALTER TABLE : SHR_IMAGE ===================================

ALTER TABLE SHR_RDA.SHR_IMAGE
 ADD (MDF_SWT_CONCEPT_ID  NUMBER);

ALTER TABLE SHR_RDA.SHR_IMAGE
 ADD (ios_ion_type  varchar2(5));

CREATE INDEX ix_MDF_SWT_CONCEPT_ID
 ON shr_image(MDF_SWT_CONCEPT_ID)
 STORAGE (INITIAL 3M NEXT 3M PCTINCREASE 0 MAXEXTENTS UNLIMITED);

CREATE INDEX ix_ios_ion_type_image
 ON shr_image(ios_ion_type)
 STORAGE (INITIAL 3M NEXT 3M PCTINCREASE 0 MAXEXTENTS UNLIMITED);

-- =========================== TABLE, SEQUENCE & SYNONYMS : DROP & CREATE SPRIT =======================================

connect sprit/sprit@testrda;

DROP SYNONYM SHR_IND_PLATFORM_MDFSWTYPE;
DROP SYNONYM SHR_IND_PLATFORM_MDFSWTYPE_SEQ;
DROP SYNONYM SHR_OSTYPE_MDFSWTYPE_SEQ;
DROP SYNONYM SHR_MDF_SWTYPE_ATTR;
DROP SYNONYM SHR_MDF_PROD_HAS_SWTYPE;
DROP SYNONYM SHR_OSTYPE_MDFSWTYPE;
DROP TABLE SWT_RULE_ENGINE;

CREATE SYNONYM SHR_IND_PLATFORM_MDFSWTYPE FOR SHR_RDA.SHR_IND_PLATFORM_MDFSWTYPE;
CREATE SYNONYM SHR_IND_PLATFORM_MDFSWTYPE_SEQ FOR SHR_RDA.SHR_IND_PLATFORM_MDFSWTYPE_SEQ;
CREATE SYNONYM SHR_OSTYPE_MDFSWTYPE_SEQ FOR SHR_RDA.SHR_OSTYPE_MDFSWTYPE_SEQ;
CREATE SYNONYM SHR_MDF_SWTYPE_ATTR FOR SHR_RDA.SHR_MDF_SWTYPE_ATTR;
CREATE SYNONYM SHR_MDF_PROD_HAS_SWTYPE FOR SHR_RDA.SHR_MDF_PROD_HAS_SWTYPE;
CREATE SYNONYM SHR_OSTYPE_MDFSWTYPE FOR SHR_RDA.SHR_OSTYPE_MDFSWTYPE;

CREATE TABLE SWT_RULE_ENGINE
(
  RULE_ENGINE_ID      NUMBER,
  RULE_NAME           VARCHAR2(25 BYTE)         NOT NULL,
  EXECUTION_ORDER     NUMBER                    NOT NULL,
  SQL_CONDITION       VARCHAR2(1000 BYTE)       NOT NULL,
  SWT_MDF_CONCEPT_ID  NUMBER                    NOT NULL,
  ADM_CREATED_AT      DATE,
  ADM_TIMESTAMP       DATE,
  ADM_FLAG            VARCHAR2(1 BYTE),
  ADM_COMMENT         VARCHAR2(100 BYTE)
);

CREATE UNIQUE INDEX PK_SWT_RULE_ENGINE ON SWT_RULE_ENGINE
(RULE_ENGINE_ID);

ALTER TABLE SWT_RULE_ENGINE ADD (
  PRIMARY KEY
 (RULE_ENGINE_ID)
    USING INDEX );

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON SWT_RULE_ENGINE TO SHR_RDA;

CREATE SEQUENCE SWT_RULE_ENGINE_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

GRANT SELECT ON SWT_RULE_ENGINE_SEQ TO SHR_RDA;

-- ======================= SYNONYMS : DROP & CREATE SHR_RDA_READONLY ===================================

connect SHR_RDA_READONLY/SHR_RDA_READONLY@testrda;

DROP SYNONYM SHR_MDF_SWTYPE_ATTR;
DROP SYNONYM SHR_MDF_PROD_HAS_SWTYPE;

CREATE SYNONYM SHR_MDF_SWTYPE_ATTR FOR SHR_RDA.SHR_MDF_SWTYPE_ATTR;
CREATE SYNONYM SHR_MDF_PROD_HAS_SWTYPE FOR SHR_RDA.SHR_MDF_PROD_HAS_SWTYPE;

-- ======================= SYNONYMS : DROP & CREATE SHR_RDA ===================================



